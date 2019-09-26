//
//  Case.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-02.
//

import Foundation

class Case: Block, Tag {
	private struct CaseCondition {
		let expressions: [Expression]
		let body: BlockBody
		let isElse: Bool
	}
	private let expression: Expression
	private var conditions: [CaseCondition] = []

	init(name: String, markup: String?, context: ParseContext) throws {
		guard let markup = markup else {
			throw SyntaxError.missingMarkup
		}
		let parser = try Parser(string: markup)
		self.expression = Expression.parse(parser)
		parser.consume(.endOfString)
		super.init(name: name)
	}

	func parse(_ tokenizer: Tokenizer, context: ParseContext) throws {
		var body = BlockBody()
		while try parse(body: body, tokenizer: tokenizer, context: context) {
			body = conditions.last!.body
		}
	}

	override func handleUnknown(tag: String, markup: String?) throws {
		if tag == "when" {
			try recordWhenCondition(markup)
		} else if tag == "else" {
			recordElseCondition(markup)
		} else {
			try super.handleUnknown(tag: tag, markup: markup)
		}
	}

	private func recordWhenCondition(_ condition: String?) throws {
		guard let condition = condition else {
			throw SyntaxError.missingMarkup
		}
		let parser = try Parser(string: condition)
		var expressions: [Expression] = [Expression.parse(parser)]
		while let id = parser.consume(.id) {
			if id != "or" {
				throw SyntaxError.reason("Expected \"or\" but found \(id)")
			}
			expressions.append(Expression.parse(parser))
		}
		while parser.consume(.comma) != nil {
			expressions.append(Expression.parse(parser))
		}
		parser.consume(.endOfString)
		conditions.append(CaseCondition(expressions: expressions, body: BlockBody(), isElse: false))
	}

	private func recordElseCondition(_ condition: String?) {
		conditions.append(CaseCondition(expressions: [], body: BlockBody(), isElse: true))
	}

	func render(context: Context) throws -> [String] {
		var output: [String] = []
		let expressionValue = expression.evaluate(context: context)
		try context.withScope {
			var executeElse = true
			for condition in conditions {
				if condition.isElse {
					if executeElse {
						output = try condition.body.render(context: context)
						return
					}
				} else {
					for expression in condition.expressions {
						if expression.evaluate(context: context) == expressionValue {
							executeElse = false
							output.append(contentsOf: try condition.body.render(context: context))
						}
					}
				}
			}
		}
		return output
	}
}
