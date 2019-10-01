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
	
	var encoder: Encoder = Encoder()
	
	/// Environments are persisted across each render of a template so we store them as part of the template itself.
	/// The template then injects them during a render call and copies the values back upon completion.
	private let environment: Environment
	
	private let fileSystem: FileSystem
	
	public convenience init(sourceURL: URL, encoder: Encoder = Encoder(), environment: Environment = Environment()) throws {
		let source = try String(contentsOf: sourceURL)
		let fileSystem = LocalFileSystem(baseURL: sourceURL.deletingLastPathComponent())
		self.init(source: source, fileSystem: fileSystem, encoder: encoder, environment: environment)
	}
	
	public convenience init(source: String, encoder: Encoder = Encoder(), environment: Environment = Environment(), fileSystem: FileSystem? = nil) {
		struct ThrowingFileSystem: FileSystem {			
			func read(path: String) throws -> String {
				throw RuntimeError.reason("Invalid filesystem")
			}
		}
		self.init(source: source, fileSystem: fileSystem ?? ThrowingFileSystem(), encoder: encoder, environment: environment)
	}
	
	init(source: String, context: Context) {
		self.source = source
		self.encoder = context.encoder
		self.environment = context.environment
		self.fileSystem = context.fileSystem
		self.filters = context.filters
		self.tags = context.tags
	}
	
	private init(source: String, fileSystem: FileSystem, encoder: Encoder, environment: Environment) {
		self.source = source
		self.fileSystem = fileSystem
		self.environment = environment
		self.encoder = encoder
		
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
	
	public func render(context: Context) throws -> String {
		return try root.render(context: context).joined()
	}
	
	public func render(values: [String: Value] = [:]) throws -> String {
		let context = Context(fileSystem: fileSystem, values: values, environment: environment, tags: tags, filters: filters, encoder: encoder)
		return try render(context: context)
	}
	
	public func render(values: [String: ValueConvertible]) throws -> String {
		return try self.render(values: values.mapValues { try encoder.encode($0) })
	}
	
	public func render(values: [String: Any?]) throws -> String {
		return try self.render(values: values.mapValues { try encoder.encode($0) })
	}
}
