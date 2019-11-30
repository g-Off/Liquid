//
//  Cycle.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-06.
//

import Foundation

struct Cycle: Tag {
	private let name: String
	private let nameExpression: Expression?
	private let expressions: [Expression]
	init(name: String, markup: String?, context: ParseContext) throws {
		self.name = name
		guard let markup = markup else { throw SyntaxError.missingMarkup }
		
		var expressions: [Expression] = []
		let parser = try Parser(string: markup)
		let firstExpression = Expression.parse(parser)
		
		if let _ = parser.consume(.colon) {
			self.nameExpression = firstExpression
			expressions.append(Expression.parse(parser))
		} else {
			self.nameExpression = nil
			expressions.append(firstExpression)
		}
		
		while parser.consume(.comma) != nil {
			expressions.append(Expression.parse(parser))
		}
		
		parser.consume(.endOfString)
		
		self.expressions = expressions
	}
	
	func parse(_ tokenizer: Tokenizer, context: ParseContext) throws {}
	
	func render(context: RenderContext) -> [String] {
		let registerKey = RegisterKey(name)
		let lookupKey = nameExpression?.evaluate(context: context).toString() ?? expressions.map { $0.description }.joined(separator: ", ")
		var registration = (context[registerKey] as? [String: Int]) ?? [:]
		let iteration = registration[lookupKey] ?? 0
		let result = expressions[iteration].evaluate(context: context).toString()
		
		registration[lookupKey] = (iteration + 1) % expressions.count
		context[registerKey] = registration
		
		return [result]
	}
}
