//
//  Parser.swift
//  
//
//  Created by Geoffrey Foster on 2019-08-29.
//

import Foundation

final class Parser {
	let tokens: [Lexer.Token]
	private var index: Array<Lexer.Token>.Index
	init(tokens: [Lexer.Token]) {
		self.tokens = tokens
		self.index = tokens.startIndex
	}
	
	convenience init(string: String) throws {
		self.init(tokens: try Lexer.tokenize(string))
	}
	
	func look(_ tokenKind: Lexer.Token.Kind, _ skip: Int = 0) -> Bool {
		guard index != tokens.endIndex else { return false }
		guard (index + skip) < tokens.endIndex else { return false }
		
		return tokens[index + skip].kind == tokenKind
	}
	
	func consumeId(_ id: String) -> Bool {
		guard index != tokens.endIndex else { return false }
		guard tokens[index].kind == .id else { return false }
		guard tokens[index].value == id else { return false }
		defer { index = tokens.index(after: index) }
		return true
	}
	
	func consume() -> String {
		defer {
			index = tokens.index(after: index)
		}
		return tokens[index].value ?? ""
	}
	
	@discardableResult
	func consume(_ tokenKind: Lexer.Token.Kind) -> String? {
		guard index != tokens.endIndex else { return nil }
		guard tokens[index].kind == tokenKind else { return nil }
		defer {
			index = tokens.index(after: index)
		}
		return tokens[index].value ?? ""
	}
	
	func unsafeConsume(_ tokenKind: Lexer.Token.Kind) throws -> String {
		guard tokens[index].kind == tokenKind else {
			throw SyntaxError.reason("Expected \(tokenKind) but found \(tokens[index].kind)")
		}
		defer {
			index = tokens.index(after: index)
		}
		return tokens[index].value ?? ""
	}
}
