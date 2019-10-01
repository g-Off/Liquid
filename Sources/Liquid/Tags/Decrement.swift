//
//  Decrement.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-06.
//

import Foundation

struct Decrement: Tag {
	private let variableName: String
	
	init(name: String, markup: String?, context: ParseContext) throws {
		guard let markup = markup else { throw SyntaxError.missingMarkup }
		let parser = try Parser(string: markup)
		self.variableName = try parser.unsafeConsume(.id)
		_ = parser.consume(.endOfString)
	}
	
	func parse(_ tokenizer: Tokenizer, context: ParseContext) throws {}
	
	func render(context: Context) throws -> [String] {
		let key = Environment.Key(variableName)
		let value = (context.environment[key]?.toInteger() ?? 0) - 1
		context.environment[key] = Value(value)
		return ["\(value)"]
	}
}
