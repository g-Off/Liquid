//
//  Variable.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-03.
//

import Foundation

struct Variable {
	private let expression: Expression
	private var filters: [Filter] = []
	
	init(string: String) throws {
		self.init(parser: try Parser(string: string))
	}
	
	init(parser: Parser) {
		self.expression = Expression.parse(parser)
		parseFilters(parser)
	}
	
	private mutating func parseFilters(_ parser: Parser) {
		while parser.consume(.pipe) != nil {
			guard let name = parser.consume(.id) else {
				break // TODO: throw an error ?
			}
			
			var args: ([Expression], [String: Expression])?
			
			if parser.consume(.colon) != nil {
				args = parseFilterArgs(parser)
			}
			filters.append(Filter(name: name, args: args?.0 ?? [], kwargs: args?.1 ?? [:]))
		}
		parser.consume(.endOfString)
	}
	
	private func parseFilterArgs(_ parser: Parser) -> ([Expression], [String:Expression]) {
		var args: [Expression] = []
		var kwargs: [String: Expression] = [:]

		while !parser.look(.endOfString) {
			if parser.look(.id) && parser.look(.colon, 1) {
				let key = parser.consume(.id)!
				
				parser.consume(.colon)
				kwargs[key] = Expression.parse(parser)
			} else {
				args.append(Expression.parse(parser))
			}
		
			if !parser.look(.comma) {
				break
			}
			parser.consume(.comma)
		}
		
		return (args, kwargs)
	}
	
	func evaluate(context: RenderContext) throws -> Value {
		var value = expression.evaluate(context: context)
		for filter in filters {
			guard let filterFunc = context.filter(named: filter.name) else {
				throw RuntimeError.unknownFilter(filter.name)
			}
			value = try filterFunc(value, filter.args.map { $0.evaluate(context: context) }, filter.kwargs.mapValues { $0.evaluate(context: context) }, FilterContext(context: context))
		}
		return value
	}
}
