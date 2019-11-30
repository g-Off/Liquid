//
//  File.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-02.
//

import Foundation

struct Expression: CustomStringConvertible {
	var description: String {
		switch kind {
		case let .lookup(lookup):
			return lookup.map { $0.description }.joined(separator: "/")
		case .variable(let key):
			return key
		case .filter(let filter):
			return filter.rawValue
		case .value(let value):
			return value.description
		case .subscript(let key):
			return "[\(key)]"
		}
	}
	
	enum LookupFilter: String {
		case size
		case first
		case last
	}
	
	indirect enum Kind {
		case lookup([Expression])
		case variable(key: String)
		case filter(LookupFilter)
		case value(Value)
		case `subscript`(Expression)
	}
	
	private let kind: Kind
	
	init(kind: Kind) {
		self.kind = kind
	}
	
	init(_ value: Value) {
		self.kind = .value(value)
	}
	
	init(_ filter: LookupFilter) {
		self.kind = .filter(filter)
	}
	
	init(variable: String) {
		self.kind = .variable(key: variable)
	}
	
	init(subscript expression: Expression) {
		self.kind = .subscript(expression)
	}
	
	init(lookup: [Expression]) {
		self.kind = .lookup(lookup)
	}
	
	func evaluate(context: RenderContext) -> Value {
		return evaluate(context: context, data: nil)
	}
	
	private func evaluate(context: RenderContext, data: Value?) -> Value {
		var result: Value?
		switch kind {
		case let .lookup(expressions):
			result = expressions.first?.evaluate(context: context)
			for expression in expressions.dropFirst() {
				result = expression.evaluate(context: context, data: result)
			}
		case let .variable(key):
			if let data = data {
				result = data.lookup(Value(key), encoder: context.encoder)
			} else {
				result = context.value(named: key)
			}
		case let .filter(filter):
			if let data = data {
				if data.isDrop {
					result = data.lookup(Value(filter.rawValue), encoder: context.encoder)
				} else if data.isDictionary {
					result = data.lookup(Value(filter.rawValue), encoder: context.encoder)
				} else if data.isArray {
					switch filter {
					case .size:
						result = Value(data.toArray().count)
					case .first:
						result = data.toArray().first
					case .last:
						result = data.toArray().last
					}
				} else {
					switch filter {
					case .size:
						result = try? Filters.sizeFilter(value: data, args: [], kwargs: [:], context: FilterContext(context: context))
					case .first:
						result = try? Filters.firstFilter(value: data, args: [], kwargs: [:], context: FilterContext(context: context))
					case .last:
						result = try? Filters.lastFilter(value: data, args: [], kwargs: [:], context: FilterContext(context: context))
					}
				}
			} else {
				// dunno
			}
		case let .value(value):
			result = value
		case let .subscript(expression):
			if let data = data {
				let subscriptValue = expression.evaluate(context: context)
				result = data.lookup(subscriptValue, encoder: context.encoder)
			} else {
				// TODO: throw an error?
			}
		}
		
		return result ?? Value()
	}
	
	static func parse(_ parser: Parser) -> Expression {
		if parser.consume(.endOfString) != nil {
			return Expression(Value())
		} else if let value = parser.consume(.string) {
			return Expression(Value(value))
		} else if let value = parser.consume(.integer) {
			return Expression(Value(Int(value)!))
		} else if let value = parser.consume(.decimal) {
			return Expression(Value(Decimal(string: value)!))
		}
		
		var lookups: [Expression] = []
		while let key = parser.consume(.id) {
			
			if key == "nil" || key == "null" {
				return Expression(Value())
			} else if key == "true" {
				return Expression(Value(true))
			} else if key == "false" {
				return Expression(Value(false))
			}
			
			if let lookupFilter = LookupFilter(rawValue: key) {
				lookups.append(Expression(lookupFilter))
			} else {
				lookups.append(Expression(variable: key))
			}
			
			if parser.consume(.dot) != nil {
				continue
			}
			
			// lookup keys based on []
			while parser.consume(.openSquare) != nil {
				lookups.append(Expression(subscript: Expression.parse(parser)))
				_ = parser.consume(.closeSquare)
			}
			
			break
		}
		
		return Expression(lookup: lookups)
	}
}
