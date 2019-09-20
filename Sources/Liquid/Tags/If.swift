//
//  If.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-02.
//

import Foundation

final class If: Block, Tag {
	private class Condition {
		enum Operator {
			case equal
			case notEqual
			case lessThan
			case greaterThan
			case lessThanEqual
			case greaterThanEqual
			case contains
			
			func evaluate(lhs: Value, rhs: Value) -> Bool {
				switch self {
				case .equal:
					return lhs == rhs
				case .notEqual:
					return lhs != rhs
				case .lessThan:
					return lhs < rhs
				case .greaterThan:
					return lhs > rhs
				case .lessThanEqual:
					return lhs <= rhs
				case .greaterThanEqual:
					return lhs >= rhs
				case .contains:
					if lhs.isArray {
						return lhs.toArray().contains(rhs)
					} else if lhs.isDictionary {
						return lhs.toDictionary()[rhs.toString()] != nil
					} else if lhs.isString {
						return lhs.toString().contains(rhs.toString())
					} else {
						return false
					}
				}
			}
		}
		
		enum LogicalOperator {
			case and
			case or
		}
		
		private let lhs: Expression
		private let `operator`: Operator?
		private let rhs: Expression?
		var logicalCondition: (op: LogicalOperator, condition: Condition)?
		
		init(lhs: Expression, operator: Operator, rhs: Expression) {
			self.lhs = lhs
			self.operator = `operator`
			self.rhs = rhs
		}
		
		init(expression: Expression) {
			self.lhs = expression
			self.operator = nil
			self.rhs = nil
		}
		
		func evaluate(context: Context) -> Bool {
			var result: Bool
			if let `operator` = `operator`, let rhs = rhs {
				let lhsValue = lhs.evaluate(context: context)
				let rhsValue = rhs.evaluate(context: context)
				result = `operator`.evaluate(lhs: lhsValue, rhs: rhsValue)
			} else {
				result = lhs.evaluate(context: context).isTruthy
			}
			
			if let logicalCondition = logicalCondition {
				switch logicalCondition.op {
				case .and:
					return result && logicalCondition.condition.evaluate(context: context)
				case .or:
					return result || logicalCondition.condition.evaluate(context: context)
				}
			}
			return result
		}
	}
	
	private struct IfBlock {
		var condition: Condition?
		let body: BlockBody = BlockBody()
		
		init(condition: Condition? = nil) {
			self.condition = condition
		}
		
		func evaluate(context: Context) -> Bool {
			guard let condition = condition else { return true }
			return condition.evaluate(context: context)
		}
	}
	
	private var blocks: [IfBlock] = []
	private let inverted: Bool
	
	convenience init(name: String, markup: String?, context: ParseContext) throws {
		try self.init(name: name, markup: markup, context: context, inverted: false)
	}
	
	private init(name: String, markup: String?, context: ParseContext, inverted: Bool) throws {
		self.inverted = inverted
		super.init(name: name)
		try pushBlock(markup: markup)
	}
	
	static func unless(name: String, markup: String?, context: ParseContext) throws -> If {
		return try If(name: name, markup: markup, context: context, inverted: true)
	}
	
	func parse(_ tokenizer: Tokenizer, context: ParseContext) throws {
		while try parse(body: blocks.last!.body, tokenizer: tokenizer, context: context) {}
	}
	
	override func handleUnknown(tag: String, markup: String?) throws {
		if tag == "elsif" {
			try pushBlock(markup: markup)
		} else if tag == "else" {
			blocks.append(IfBlock())
		} else {
			try super.handleUnknown(tag: tag, markup: markup)
		}
	}
	
	private func pushBlock(markup: String?) throws {
		guard let markup = markup else {
			throw SyntaxError.missingMarkup
		}
		let parser = try Parser(string: markup)
		let condition = try parseLogicalCondition(parser)
		let block = IfBlock(condition: condition)
		blocks.append(block)
	}
	
	func render(context: Context) throws -> [String] {
		if let block = blocks.first {
			let result = block.evaluate(context: context)
			if result && !inverted || !result && inverted {
				return try block.body.render(context: context)
			}
		}
		for block in blocks.dropFirst() {
			if block.evaluate(context: context) {
				return try block.body.render(context: context)
			}
		}
		return []
	}
	
	private func parseLogicalCondition(_ parser: Parser) throws -> Condition {
		let condition = try parseCondition(parser)
		
		var logicalOperator: Condition.LogicalOperator? = nil
		if parser.consumeId("and") {
			logicalOperator = .and
		} else if parser.consumeId("or") {
			logicalOperator = .or
		}
		
		if let logicalOperator = logicalOperator {
			condition.logicalCondition = (logicalOperator, try parseLogicalCondition(parser))
		}
		
		return condition
	}
	
	private func parseCondition(_ parser: Parser) throws -> Condition {
		let lhs = Expression.parse(parser)
		if parser.look(.comparison) {
			let opString = parser.consume()
			let op: Condition.Operator
			switch opString {
			case "==":
				op = .equal
			case "!=", "<>":
				op = .notEqual
			case "<":
				op = .lessThan
			case ">":
				op = .greaterThan
			case "<=":
				op = .lessThanEqual
			case ">=":
				op = .greaterThanEqual
			case "contains":
				op = .contains
			default:
				throw SyntaxError.reason("Unknown operator \(opString)")
			}
			
			let rhs = Expression.parse(parser)
			
			return Condition(lhs: lhs, operator: op, rhs: rhs)
		}
		return Condition(expression: lhs)
	}
}
