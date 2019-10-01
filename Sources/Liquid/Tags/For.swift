//
//  For.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-02.
//

import Foundation

class For: Block, Tag {
	private var forBlock = BlockBody()
	private var elseBlock: BlockBody?
	
	private let variableName: String
	private let reversed: Bool
	private var offset: Expression?
	private var limit: Expression?
	
	private enum CollectionType {
		case range(start: Expression, end: Expression)
		case collection(Expression)
	}
	
	private var collection: CollectionType
	
	public init(name: String, markup: String?, context: ParseContext) throws {
		guard let markup = markup else { throw SyntaxError.missingMarkup }
		
		let parser = try Parser(string: markup)
		guard let variableName = parser.consume(.id) else {
			throw SyntaxError.reason("Syntax Error in 'for loop' - Valid syntax: for [item] in [collection]")
		}
		self.variableName = variableName
		guard parser.consume(.id) == "in" else {
			throw SyntaxError.reason("Syntax Error in 'for loop' - Valid syntax: for [item] in [collection]")
		}
		
		if parser.consume(.openRound) != nil {
			let rangeStart = Expression.parse(parser)
			parser.consume(.dotDot)
			let rangeEnd = Expression.parse(parser)
			parser.consume(.closeRound)
			self.collection = .range(start: rangeStart, end: rangeEnd)
		} else {
			self.collection = .collection(Expression.parse(parser))
		}
		
		self.reversed = parser.consumeId("reversed")
		
		while let attribute = parser.consume(.id) {
			parser.consume(.colon)
			
			let value = Expression.parse(parser)
			if attribute == "offset" {
				self.offset = value
			} else if attribute == "limit" {
				self.limit = value
			} else {
				throw SyntaxError.reason("Invalid attribute in for loop. Valid attributes are limit and offset")
			}
		}
		
		parser.consume(.endOfString)
		
		super.init(name: name)
	}
	
	func parse(_ tokenizer: Tokenizer, context: ParseContext) throws {
		guard try parse(body: forBlock, tokenizer: tokenizer, context: context) else { return }
		if let elseBlock = elseBlock {
			_ = try parse(body: elseBlock, tokenizer: tokenizer, context: context)
		}
	}
	
	override func handleUnknown(tag: String, markup: String?) throws {
		if tag == "else" {
			elseBlock = BlockBody()
		} else {
			try super.handleUnknown(tag: tag, markup: markup)
		}
	}
	
	func render(context: Context) throws -> [String] {
		let item: (Int) -> Value
		var startIndex: Int
		var endIndex: Int
		
		switch collection {
		case .range(let start, let end):
			startIndex = start.evaluate(context: context).toInteger()
			endIndex = end.evaluate(context: context).toInteger() + 1
			item = { Value($0) }
		case .collection(let collection):
			let array = collection.evaluate(context: context).toArray()
			startIndex = array.startIndex
			endIndex = array.endIndex
			item = { array[$0] }
		}
		
		let offsetValue = offset?.evaluate(context: context).toInteger()
		let limitValue = limit?.evaluate(context: context).toInteger()
		
		var parents = context[RegisterKey(name)] as? [ForDrop] ?? []
		let loop = ForLoop(item: item, body: forBlock, variableName: variableName, startIndex: startIndex, endIndex: endIndex, reversed: reversed, offset: offsetValue, limit: limitValue, parent: parents.last)
		parents.append(loop.drop)
		context[RegisterKey(name)] = parents
		defer {
			var parents = context[RegisterKey(name)] as? [ForDrop]
			parents?.removeLast()
			context[RegisterKey(name)] = parents
		}
		if loop.isEmpty {
			return try elseBlock?.render(context: context) ?? []
		}
		
		return try loop.render(context: context)
	}
}

private struct ForLoop {
	private let item: (Int) -> Value
	private let body: BlockBody
	private let variableName: String
	private let range: Range<Int>
	private let reversed: Bool
	let drop: ForDrop
	
	init(item: @escaping (Int) -> Value, body: BlockBody, variableName: String, startIndex: Int, endIndex: Int, reversed: Bool, offset: Int?, limit: Int?, parent: Drop?) {
		self.item = item
		self.body = body
		self.variableName = variableName
		self.reversed = reversed
		
		func makeRange(start: Int, end: Int, offset: Int?, limit: Int?, reversed: Bool) -> Range<Int> {
			var r = start..<end
			if let offset = offset {
				r = reversed ? r.dropLast(offset) : r.dropFirst(offset)
			}
			if let limit = limit {
				r = reversed ? r.suffix(limit) : r.prefix(limit)
			}
			return r
		}
		self.range = makeRange(start: startIndex, end: endIndex, offset: offset, limit: limit, reversed: reversed)
		self.drop = ForDrop(length: range.count, parent: parent)
	}
	
	private func makeIterator() -> AnyIterator<Int> {
		var helper = ForHelper(range: range, reversed: reversed)
		
		var iterator = AnyIterator<Int> {
			defer { helper.advance() }
			return helper.test ? helper.index : nil
		}
		return iterator
	}
	
	var isEmpty: Bool {
		return range.isEmpty
	}
	
	func render(context: Context) throws -> [String] {
		var output: [String] = []
		
		try context.withScope(Scope(mutable: false, values: ["forloop": Value(drop)])) {
			outerLoop: for index in makeIterator() {
				output.append(contentsOf: try renderItemAtIndex(index, context: context))
				drop.increment()
				
				if context.hasInterrupt {
					switch context.popInterrupt() {
					case .break:
						break outerLoop
					case .continue:
						continue outerLoop
					}
				}
			}
		}
		return output
	}
	
	private func renderItemAtIndex(_ index: Int, context: Context) throws -> [String] {
		let value = item(index)
		let scope = Scope(mutable: false, values: [variableName: value])
		let results = try context.withScope(scope) {
			try body.render(context: context)
		}
		return results
	}
}

private struct ForHelper {
	private let range: Range<Int>
	private let reversed: Bool
	
	private(set) var index: Int
	
	init(range: Range<Int>, reversed: Bool) {
		self.range = range
		self.reversed = reversed
		self.index = reversed ? range.endIndex - 1 : range.startIndex
	}
	
	var test: Bool {
		return range.contains(index)
	}
	
	mutating func advance() {
		if reversed {
			index -= 1
		} else {
			index += 1
		}
	}
}

private class ForDrop: Drop {
	private var currentIndex: Int = 0
	@objc let length: Int
	let parent: Drop?
	
	init(length: Int, parent: Drop?) {
		self.length = length
		self.parent = parent
	}
	
	var first: Bool {
		return currentIndex == 0
	}
	
	var last: Bool {
		return currentIndex == length - 1
	}
	
	var index: Int {
		return currentIndex + 1
	}
	
	var index0: Int {
		return currentIndex
	}
	
	var rindex: Int {
		return length - currentIndex
	}
	
	var rindex0: Int {
		return length - currentIndex - 1
	}
	
	func value(forKey key: DropKey, encoder: Encoder) throws -> Value? {
		switch key.rawValue {
		case "length": return Value(length)
		case "first": return Value(first)
		case "last": return Value(last)
		case "index": return Value(index)
		case "index0": return Value(index0)
		case "rindex": return Value(rindex)
		case "rindex0": return Value(rindex0)
		case "parentloop":
			guard let parent = parent else { return Value() }
			return Value(parent)
		default:
			return nil
		}
	}
	
	func increment() {
		currentIndex += 1
	}
}
