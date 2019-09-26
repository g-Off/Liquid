//
//  Context.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-02.
//

import Foundation

class Scope {
	private var values: [String: Value]
	let mutable: Bool
	
	init(mutable: Bool = true, values: [String: Value] = [:]) {
		self.mutable = mutable
		self.values = values
	}
	
	subscript(key: String) -> Value? {
		get {
			return values[key]
		}
		set {
			guard mutable else { return }
			values[key] = newValue
		}
	}
}

public struct EnvironmentKey: Hashable {
	public let rawValue: String
	
	public init(_ rawValue: String) {
		self.rawValue = rawValue
	}
}

public struct RegisterKey: Hashable {
	public let rawValue: String
	
	public init(_ rawValue: String) {
		self.rawValue = rawValue
	}
}

public final class Context {
	enum Interrupt {
		case `break`
		case `continue`
	}
	
	private var scopes: [Scope]
	private var filters: [String: FilterFunc]
	
	// Registers are for internal data structure storage, like forloop's and cycles to store data
	private var registers: [String: Value] = [:]
	 //Environments are for mutliples runs of the same template with data that is persisted across
	private(set) var environment: [String: Value]
	
	public let encoder: Encoder
	
	init(values: [String: Value] = [:], environment: [String: Value] = [:], filters: [String: FilterFunc] = [:], encoder: Encoder) {
		self.scopes = [Scope(values: values)]
		self.environment = environment
		self.filters = filters
		self.encoder = encoder
	}
	
	func withScope<T>(_ scope: Scope? = nil, block: () throws -> T) rethrows -> T {
		if let scope = scope {
			pushScope(scope)
		}
		defer {
			if scope != nil {
				popScope()
			}
		}
		return try block()
	}
	
	private func pushScope(_ scope: Scope = Scope()) {
		scopes.append(scope)
	}
	
	func popScope() {
		_ = scopes.popLast()
	}
	
	func value(named name: String) -> Value? {
		var value: Value?
		for scope in scopes.reversed() {
			if let scopedValue = scope[name] {
				value = scopedValue
				break
			}
		}
		
		return value
	}
	
	func setValue(_ value: Value, named name: String) {
		let scope = scopes.reversed().first { $0.mutable }!
		scope[name] = value
	}
	
	subscript(key: EnvironmentKey) -> Value? {
		get {
			return environment[key.rawValue]
		}
		set {
			environment[key.rawValue] = newValue
		}
	}
	
	subscript(key: EnvironmentKey, default defaultValue: @autoclosure () -> Value) -> Value {
		get {
			return environment[key.rawValue] ?? defaultValue()
		}
		set {
			environment[key.rawValue] = newValue
		}
	}
	
	subscript(key: RegisterKey) -> Value? {
		get {
			return registers[key.rawValue]
		}
		set {
			registers[key.rawValue] = newValue
		}
	}
	
	subscript(key: RegisterKey, default defaultValue: @autoclosure () -> Value) -> Value {
		get {
			return registers[key.rawValue] ?? defaultValue()
		}
		set {
			registers[key.rawValue] = newValue
		}
	}
	
	private var interrupts: [Interrupt] = []
	
	func push(interrupt: Interrupt) {
		interrupts.append(interrupt)
	}
	
	func popInterrupt() -> Interrupt {
		guard let interrupt = interrupts.popLast() else {
			fatalError() // TODO: exception ?
		}
		return interrupt
	}
	
	var hasInterrupt: Bool {
		return !interrupts.isEmpty
	}
	
	func filter(named: String) -> FilterFunc? {
		return filters[named]
	}
}
