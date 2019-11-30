//
//  Include.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-27.
//

import Foundation

final class Include: Tag {
	private let templateName: Expression
	private let variable: Expression?
	private let attributes: [String: Expression]
	init(name: String, markup: String?, context: ParseContext) throws {
		guard let markup = markup else { throw SyntaxError.missingMarkup }
		let parser = try Parser(string: markup)
		
		self.templateName = Expression.parse(parser)
		
		if parser.consumeId("for") || parser.consumeId("with") {
			self.variable = Expression.parse(parser)
		} else {
			self.variable = nil
		}
		
		var attributes: [String: Expression] = [:]
		while let attribute = parser.consume(.id) {
			parser.consume(.colon)
			let value = Expression.parse(parser)
			attributes[attribute] = value
			parser.consume(.comma)
		}
		
		parser.consume(.endOfString)
		
		self.attributes = attributes
	}
	
	func parse(_ tokenizer: Tokenizer, context: ParseContext) throws {}
	
	func render(context: RenderContext) throws -> [String] {
		var result: [String] = []
		let templateName = self.templateName.evaluate(context: context).toString()
		let template = try loadTemplate(path: templateName, context: context)
		let variableName = templateName.components(separatedBy: "/").last!
		
		let value = variable?.evaluate(context: context) ?? context.value(named: variableName)
		
		try context.withScope {
			attributes.forEach { (key, expression) in
				let value = expression.evaluate(context: context)
				context.setValue(value, named: key)
			}
			
			if let value = value, value.isArray {
				for vv in value.toArray() {
					context.setValue(vv, named: variableName)
					result.append(try template.render(context: context))
				}
			} else {
				if let value = value {
					context.setValue(value, named: variableName)
				}
				result.append(try template.render(context: context))
			}
		}
		
		return result
	}
	
	private func loadTemplate(path: String, context: RenderContext) throws -> Template {
		guard !path.isEmpty else {
			throw FileSystemError(reason: "")
		}
		let cacheKey = RegisterKey("CachedPartials")
		var cached = (context[cacheKey] as? [String: Template]) ?? [:]
		
		if let template = cached[path] {
			return template
		}
		
		let source = try context.fileSystem.read(path: path)
		let template = Template(source: source, context: context)
		try template.parse()
		
		cached[path] = template
		context[cacheKey] = cached
		
		return template
	}
}
