//
//  File.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-03.
//

import Foundation

public final class Value: Equatable, Comparable {
	fileprivate enum Storage {
		case `nil`
		case bool(Bool)
		case string(String)
		case int(Int)
		case decimal(Decimal)
		case array([Value])
		case dictionary([String: Value])
		case drop(Drop)
	}
	
	fileprivate var storage: Storage
	
	init() {
		self.storage = .nil
	}
	
	fileprivate init(storage: Storage) {
		self.storage = storage
	}
	
	convenience init(_ value: Bool) {
		self.init(storage: .bool(value))
	}
	
	convenience init(_ value: String) {
		self.init(storage: .string(value))
	}
	
	convenience init(_ value: Int) {
		self.init(storage: .int(value))
	}
	
	convenience init(_ value: Double) {
		self.init(storage: .decimal(Decimal(value)))
	}
	
	convenience init(_ value: Decimal) {
		self.init(storage: .decimal(value))
	}
	
	convenience init(_ value: [Value]) {
		self.init(storage: .array(value))
	}
	
	convenience init(_ value: [String: Value]) {
		self.init(storage: .dictionary(value))
	}
	
	convenience init(_ value: Drop) {
		self.init(storage: .drop(value))
	}
	
	// MARK: -
	
	var isTruthy: Bool {
		switch storage {
		case .nil, .bool(false):
			return false
		default:
			return true
		}
	}
	
	var size: Int {
		switch storage {
		case .array(let value):
			return value.count
		case .dictionary(let value):
			return value.count
		case .string(let value):
			return value.count
		default:
			return 0
		}
	}
	
	// MARK: -
	
	func lookup(_ key: Value, encoder: Encoder) -> Value {
		switch (storage, key.storage) {
		case let (.array(array), .int(index)):
			return array[index]
		case let (.dictionary(dictionary), .string(key)):
			return dictionary[key] ?? Value()
		case let (.drop(drop), .string(key)):
			return (try? drop.value(forKey: encoder.keyEncodingStrategy.transform(key: key), encoder: encoder)) ?? Value()
		default:
			return Value()
		}
	}
	
	// MARK: - Type check conveniences
	
	var isNil: Bool {
		if case .nil = storage {
			return true
		}
		return false
	}
	
	var isInteger: Bool {
		if case .int = storage {
			return true
		}
		return false
	}
	
	var isDecimal: Bool {
		if case .decimal = storage {
			return true
		}
		return false
	}
	
	var isString: Bool {
		if case .string = storage {
			return true
		}
		return false
	}
	
	var isArray: Bool {
		if case .array = storage {
			return true
		}
		return false
	}
	
	var isDictionary: Bool {
		if case .dictionary = storage {
			return true
		}
		return false
	}
	
	var isDrop: Bool {
		if case .drop = storage {
			return true
		}
		return false
	}
	
	// MARK: - Type conversions
	
	func toInteger() -> Int {
		switch storage {
		case .int(let value):
			return value
		case .decimal(let value):
			return value.intValue
		default:
			return 0
		}
	}
	
	func toDecimal() -> Decimal {
		switch storage {
		case .int(let value):
			return Decimal(value)
		case .decimal(let value):
			return value
		default:
			return 0
		}
	}
	
	func toArray() -> [Value] {
		if case let .array(value) = storage {
			return value
		}
		return []
	}
	
	func toDictionary() -> [String: Value] {
		if case let .dictionary(value) = storage {
			return value
		}
		return [:]
	}
	
	func toString() -> String {
		switch storage {
		case .bool(let value):
			return "\(value ? "true" : "false")"
		case .string(let value):
			return value
		case .int(let value):
			return "\(value)"
		case .decimal(let value):
			return "\(value)"
		default:
			return ""
		}
	}
	
	func toDrop() -> Drop? {
		if case let .drop(drop) = storage {
			return drop
		}
		return nil
	}
	
	// MARK: -
	
	func liquidString(encoder: Encoder) -> String {
		switch storage {
		case .bool(let value):
			return "\(value ? "true" : "false")"
		case .string(let value):
			return value
		case .int(let value):
			return "\(value)"
		case .decimal(let value):
			return encoder.decimalEncodingStrategy.encode(value: value)
		default:
			return ""
		}
	}
	
	// MARK: - Array manipulation
	
	func push(value: Value) {
		guard case var .array(array) = storage else {
			return
		}
		array.append(value)
		self.storage = .array(array)
	}
	
	@discardableResult
	func pop() -> Value? {
		guard case var .array(array) = storage else {
			return nil
		}
		let last = array.popLast()
		self.storage = .array(array)
		return last
	}
	
	// MARK: - Dictionary manipulation
	
	subscript(at: String) -> Value? {
		get {
			guard case let .dictionary(dictionary) = storage else {
				return nil
			}
			return dictionary[at]
		}
		set {
			guard case var .dictionary(dictionary) = storage else {
				return
			}
			dictionary[at] = newValue
			self.storage = .dictionary(dictionary)
		}
	}
	
	// MARK: - Equatable
	
	public static func ==(lhs: Value, rhs: Value) -> Bool {
		return lhs.storage == rhs.storage
	}
	
	// MARK: - Comparable
	
	public static func <(lhs: Value, rhs: Value) -> Bool {
		return lhs.storage < rhs.storage
	}
	
	public static func <=(lhs: Value, rhs: Value) -> Bool {
		return lhs.storage <= rhs.storage
	}
	
	public static func >(lhs: Value, rhs: Value) -> Bool {
		return lhs.storage > rhs.storage
	}
	
	public static func >=(lhs: Value, rhs: Value) -> Bool {
		return lhs.storage >= rhs.storage
	}
}

extension Value: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(storage)
	}
}

extension Value.Storage: Equatable {
	static func ==(lhs: Value.Storage, rhs: Value.Storage) -> Bool {
		switch (lhs, rhs) {
		case (.nil, .nil):
			return true
		case let (.bool(l), .bool(r)):
			return l == r
		case let (.string(l), .string(r)):
			return l == r
		case let (.int(l), .int(r)):
			return l == r
		case let (.decimal(l), .decimal(r)):
			return l == r
//		case let (.int(l), .float(r)):
//		case let (.float(l), .int(r)):
		case let (.array(l), .array(r)):
			return l == r
		case let (.dictionary(l), .dictionary(r)):
			return l == r
		case let (.drop(l), .drop(r)):
			return l === r
		default:
			return false
		}
	}
}

extension Value.Storage: Hashable {
	func hash(into hasher: inout Hasher) {
		switch self {
		case .nil:
			break
		case .bool(let value):
			hasher.combine(value)
		case .string(let value):
			hasher.combine(value)
		case .int(let value):
			hasher.combine(value)
		case .decimal(let value):
			hasher.combine(value)
		case .array(let value):
			hasher.combine(value)
		case .dictionary(let value):
			hasher.combine(value)
		case .drop(let value):
			hasher.combine(ObjectIdentifier(value))
		}
	}
}

extension Value.Storage: Comparable {
	static func <(lhs: Value.Storage, rhs: Value.Storage) -> Bool {
		switch (lhs, rhs) {
		case let (.int(l), .int(r)):
			return l < r
		case let (.decimal(l), .decimal(r)):
			return l < r
//		case let (.int(l), .float(r)):
//			return Float(l) < r
//		case let (.float(l), .int(r)):
//			return l < Float(r)
		case let (.string(l), .string(r)):
			return l < r
		default:
			return false
		}
	}
	
	static func <=(lhs: Value.Storage, rhs: Value.Storage) -> Bool {
		switch (lhs, rhs) {
		case let (.int(l), .int(r)):
			return l <= r
		case let (.decimal(l), .decimal(r)):
			return l <= r
//		case let (.int(l), .float(r)):
//		case let (.float(l), .int(r)):
		case let (.string(l), .string(r)):
			return l <= r
		default:
			return lhs == rhs
		}
	}
	
	static func >(lhs: Value.Storage, rhs: Value.Storage) -> Bool {
		// TODO: combos of int and float could be allowed
		switch (lhs, rhs) {
		case let (.int(l), .int(r)):
			return l > r
		case let (.decimal(l), .decimal(r)):
			return l > r
//		case let (.int(l), .float(r)):
//		case let (.float(l), .int(r)):
		case let (.string(l), .string(r)):
			return l > r
		default:
			return false
		}
	}
	
	static func >=(lhs: Value.Storage, rhs: Value.Storage) -> Bool {
		switch (lhs, rhs) {
		case let (.int(l), .int(r)):
			return l >= r
		case let (.decimal(l), .decimal(r)):
			return l >= r
//		case let (.int(l), .float(r)):
//		case let (.float(l), .int(r)):
		case let (.string(l), .string(r)):
			return l >= r
		default:
			return lhs == rhs
		}
	}
}

extension Value.Storage: CustomStringConvertible, CustomDebugStringConvertible {
	public var description: String {
		switch self {
		case .nil:
			return "<nil>"
		case let .bool(value):
			return "bool: <\(value)>"
		case let .string(value):
			return "string: <\(value)>"
		case let .int(value):
			return "int: <\(value)>"
		case let .decimal(value):
			return "float: <\(value)>"
		case let .array(value):
			return "array: <\(value)>"
		case let .dictionary(value):
			return "dictionary: <\(value)>"
		case let .drop(value):
			return "drop: <\(value)>"
		}
	}
	
	public var debugDescription: String {
		return description
	}
}

extension Value: CustomStringConvertible, CustomDebugStringConvertible {
	public var description: String {
		return storage.description
	}
	
	public var debugDescription: String {
		return storage.debugDescription
	}
}
