//
//  File.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-02.
//

import Foundation

public protocol Node {
	func render(context: Context) throws -> [String]
}

struct VariableNode: Node {
	private let variable: Variable
	
	init(_ variable: Variable) {
		self.variable = variable
	}
	
	func render(context: Context) throws -> [String] {
		return [try variable.evaluate(context: context).liquidString(encoder: context.encoder)]
	}
}

struct StringNode: Node {
	private let rawValue: String
	init(_ rawValue: String) {
		self.rawValue = rawValue
	}
	
	func render(context: Context) throws -> [String] {
		return [rawValue]
	}
}
