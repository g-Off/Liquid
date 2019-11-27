//
//  Assign.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-06.
//

import Foundation

struct Assign: Tag {
	private let variableName: String
	private let variable: Variable
	
	init(name: String, markup: String?, context: ParseContext) throws {
		guard let markup = markup else { throw SyntaxError.missingMarkup }
		let parser = try Parser(string: markup)
		self.variableName = try parser.unsafeConsume(.id)
		parser.consume(.equal)
		self.variable = Variable(parser: parser)
	}
	
	func parse(_ tokenizer: Tokenizer, context: ParseContext) throws {}
	
	func render(context: RenderContext) throws -> [String] {
		context.setValue(try variable.evaluate(context: context), named: variableName)
		return []
	}
}
