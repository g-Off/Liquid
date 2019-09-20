//
//  Capture.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-06.
//

import Foundation

class Capture: Block, Tag {
	private let variableName: String
	private let body: BlockBody = BlockBody()
	
	init(name: String, markup: String?, context: ParseContext) throws {
		guard let markup = markup else { throw SyntaxError.missingMarkup }
		let parser = try Parser(string: markup)
		self.variableName = try parser.unsafeConsume(.id)
		parser.consume(.endOfString)
		super.init(name: name)
	}
	
	func parse(_ tokenizer: Tokenizer, context: ParseContext) throws {
		_ = try super.parse(body: body, tokenizer: tokenizer, context: context)
	}
	
	func render(context: Context) throws -> [String] {
		let result = try body.render(context: context)
		context.setValue(Value(result.joined()), named: variableName)
		return []
	}
}
