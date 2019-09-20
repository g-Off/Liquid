//
//  Lexer.swift
//  
//
//  Created by Geoffrey Foster on 2019-08-28.
//

import Foundation

public final class Tokenizer {
	public enum Token: Equatable {
		/// A token representing a piece of text.
		case text(value: String)
		
		/// A token representing a variable.
		case variable(value: String)
		
		/// A token representing a template tag.
		case tag(value: RawTag)
		
		public static func ==(lhs: Token, rhs: Token) -> Bool {
			switch (lhs, rhs) {
			case let (.text(lhsValue), .text(rhsValue)): return lhsValue == rhsValue
			case let (.variable(lhsValue), .variable(rhsValue)): return lhsValue == rhsValue
			case let (.tag(lhsValue), .tag(rhsValue)): return lhsValue == rhsValue
				
			default:
				return false
			}
		}
	}
	
	internal let tokens: [Token]
	private var position: Array<Token>.Index
	
	public init(source: String) {
		self.tokens = tokenize(source)
		self.position = tokens.startIndex
	}
	
	public func next() -> Token? {
		guard position != tokens.endIndex else { return nil }
		defer { position = tokens.index(after: position) }
		return tokens[position]
	}
}

private func tokenize(_ input: String) -> [Tokenizer.Token] {
	var scalars = Substring(input)
	var tokens: [Tokenizer.Token] = []
	while let token = scalars.readToken() {
		tokens.append(token)
	}
	if !scalars.isEmpty {
		// TODO: throw an exception?
	}
	return tokens
}

private extension Substring {
	mutating func readToken() -> Tokenizer.Token? {
		guard !isEmpty else { return nil }
		return readText() ?? readVariable() ?? readTag()
	}
	
	mutating func readVariable() -> Tokenizer.Token? {
		let start = self
		guard scan(until: ["{{"], consume: true) == "{{",
			let variable = scan(until: ["}}"])?.trimmingCharacters(in: .whitespacesAndNewlines),
			!variable.isEmpty,
			scan(until: ["}}"], consume: true) == "}}"
		else {
			self = start
			return nil
		}
		return .variable(value: variable)
	}
	
	mutating func readTag() -> Tokenizer.Token? {
		let start = self
		guard scan(until: ["{%"], consume: true) == "{%",
			let tag = scan(until: ["%}"])?.trimmingCharacters(in: .whitespacesAndNewlines),
			!tag.isEmpty,
			scan(until: ["%}"], consume: true) == "%}"
		else {
			self = start
			return nil
		}
		return .tag(value: RawTag(tag))
	}
	
	mutating func readText() -> Tokenizer.Token? {
		guard let string = scan(until: ["{{", "{%"]) else { return nil }
		return .text(value: string)
	}
	
	mutating func scan(until: [String], consume: Bool = false) -> String? {
		var string = ""
		while !isEmpty {
			if let i = until.first(where: { hasPrefix($0) }) {
				if consume {
					removeFirst(i.count)
					string += i
				}
				break
			}
			string += String(removeFirst())
		}
		return string.isEmpty ? nil : string
	}
}
