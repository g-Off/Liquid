//
//  Environment.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-27.
//

import Foundation

public final class Environment {
	public struct Key: Hashable {
		public let rawValue: String
		
		public init(_ rawValue: String) {
			self.rawValue = rawValue
		}
	}
	
	private(set) var values: [Key: Value] = [:]
	
	public init() {}
	
	public subscript(key: Key) -> Value? {
		get {
			return values[key]
		}
		set {
			values[key] = newValue
		}
	}
	
	public subscript(key: Key, default defaultValue: @autoclosure () -> Value) -> Value {
		get {
			return values[key] ?? defaultValue()
		}
		set {
			values[key] = newValue
		}
	}
}
