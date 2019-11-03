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
			var args: [Expression]?
			if parser.consume(.colon) != nil {
				args = parseFilterArgs(parser)
			}
			filters.append(Filter(name: name, args: args ?? []))
		}
		parser.consume(.endOfString)
	}
	
	private func parseFilterArgs(_ parser: Parser) -> [Expression] {
		var args: [Expression] = []

		while !parser.look(.endOfString) {
			// Assuming all args are named parameters
			if parser.look(.id) && parser.look(.colon, 1) {
				guard let key = parser.consume(.id) else { fatalError("id should exist") }
				
				parser.consume(.colon)
				let expression = Expression.parse(parser)
				args.append(Expression(key: key, expression: expression))
				
				if !parser.look(.comma) {
					break
				}
				parser.consume(.comma)
				continue
			}
			
			// Assuming all args are ordered parameters
			args.append(Expression.parse(parser))
			if !parser.look(.comma) {
				break
			}
			parser.consume(.comma)
		}
		
		return args
	}
	
	func evaluate(context: Context) throws -> Value {
		var value = expression.evaluate(context: context)
		for filter in filters {
			guard let filterFunc = context.filter(named: filter.name) else {
				throw RuntimeError.unknownFilter(filter.name)
			}
			value = try filterFunc(value, filter.args.map { $0.evaluate(context: context) }, context.encoder)
		}
		return value
	}
}
