//
//  File.swift
//  
//
//  Created by Geoffrey Foster on 2019-08-31.
//

import Foundation

public final class Template {
	let source: String
	
	private let root = BlockBody()
	private var filters: [String: FilterFunc] = [:]
	private var tags: [String: TagBuilder] = [:]
	
	private let locale: Locale
	
	var encoder: Encoder = Encoder()
	
	/// Environments are persisted across each render of a template so we store them as part of the template itself.
	/// The template then injects them during a render call and copies the values back upon completion.
	private var environment: [String: Value] = [:]
	
	public init(source: String, locale: Locale = .current) {
		self.source = source
		self.locale = locale
		
		encoder.locale = locale
		
		tags["assign"] = Assign.init
		tags["break"] = Break.init
		tags["capture"] = Capture.init
		tags["case"] = Case.init
		tags["comment"] = Comment.init
		tags["continue"] = Continue.init
		tags["cycle"] = Cycle.init
		tags["decrement"] = Decrement.init
		tags["for"] = For.init
		tags["if"] = If.init
		tags["increment"] = Increment.init
		tags["unless"] = If.unless
		
		Filters.registerFilters(template: self)
	}
	
	public func parse() throws {
		let parseContext = ParseContext()
		parseContext.tags = tags
		try root.parse(Tokenizer(source: source), context: parseContext, step: defaultUnknownTagHandler)
	}
	
	public func registerFilter(name: String, filter: @escaping FilterFunc) {
		filters[name] = filter
	}
	
	public func registerTag(name: String, tag: @escaping TagBuilder) {
		tags[name] = tag
	}
	
	public func render(values: [String: Value] = [:]) throws -> String {
		let context = Context(values: values, environment: environment, filters: filters, encoder: encoder)
		defer {
			// Merge the contexts environment back into the templates
			environment.merge(context.environment) { (lhs, rhs) -> Value in
				return rhs
			}
		}
		return try root.render(context: context).joined()
	}
	
	public func render(values: [String: ValueConvertible]) throws -> String {
		return try self.render(values: values.mapValues { try encoder.encode($0) })
	}
	
	public func render(values: [String: Any?]) throws -> String {
		return try self.render(values: values.mapValues { try encoder.encode($0) })
	}
}
