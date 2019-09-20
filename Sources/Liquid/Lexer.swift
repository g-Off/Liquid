//
//  Lexer.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-02.
//

import Foundation

enum Lexer {
	struct Token {
		enum Kind {
			case pipe
			case dot
			case colon
			case comma
			case openSquare
			case closeSquare
			case openRound
			case closeRound
			case question
			case dash
			case equal
			case comparison
			case string
			case integer
			case decimal
			case id
			case dotDot
			case endOfString
		}
		
		let kind: Kind
		let value: String?
		
		init(kind: Kind, value: String? = nil) {
			self.kind = kind
			self.value = value
		}
	}
	
	private static let specials: [Character: Token.Kind] = [
		"|": .pipe,
		".": .dot,
		":": .colon,
		",": .comma,
		"[": .openSquare,
		"]": .closeSquare,
		"(": .openRound,
		")": .closeRound,
		"?": .question,
		"-": .dash,
		"=": .equal
	]
	
	static func tokenize(_ string: String) throws -> [Token] {
		var tokens: [Token] = []
		let scanner = Scanner(string: string)
		while !scanner.isAtEnd {
			_ = scanner.liquid_scanCharacters(from: .whitespacesAndNewlines)
			guard !scanner.isAtEnd else { break }
			
			if let t = try? scanner.liquid_scanRegex(#"==|!=|<>|<=?|>=?|contains(?=\s)"#) {
				tokens.append(Token(kind: .comparison, value: t))
			} else if let t = try? scanner.liquid_scanRegex(#"'([^\']*)'"#, captureGroup: 1) {
				tokens.append(Token(kind: .string, value: t))
			} else if let t = try? scanner.liquid_scanRegex(#""([^\"]*)""#, captureGroup: 1) {
				tokens.append(Token(kind: .string, value: t))
			} else if let t = scanner.liquid_scanDecimal() {
				tokens.append(Token(kind: .decimal, value: t))
			} else if let t = scanner.liquid_scanInt() {
				tokens.append(Token(kind: .integer, value: t))
			} else if let t = try? scanner.liquid_scanRegex(#"[a-zA-Z_][\w-]*\??"#) {
				tokens.append(Token(kind: .id, value: t))
			} else if let _ = try? scanner.liquid_scanRegex(#"\.\."#) {
				tokens.append(Token(kind: .dotDot))
			} else if let c = scanner.liquid_scanCharacter() {
				if let tokenKind = specials[c] {
					tokens.append(Token(kind: tokenKind))
				} else {
					throw SyntaxError.unexpectedToken(c)
				}
			}
		}
		
		tokens.append(Token(kind: .endOfString))
		return tokens
	}
}
