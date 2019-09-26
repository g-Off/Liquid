//
//  ValueConvertible.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-16.
//

import Foundation

public protocol ValueConvertible {
	func toValue(encoder: Encoder) -> Value
}

extension Bool: ValueConvertible {
	public func toValue(encoder: Encoder) -> Value {
		return Value(self)
	}
}

extension String: ValueConvertible {
	public func toValue(encoder: Encoder) -> Value {
		return Value(self)
	}
}

extension Int: ValueConvertible {
	public func toValue(encoder: Encoder) -> Value {
		return Value(self)
	}
}

extension Double: ValueConvertible {
	public func toValue(encoder: Encoder) -> Value {
		return Value(self)
	}
}

extension Decimal: ValueConvertible {
	public func toValue(encoder: Encoder) -> Value {
		return Value(self)
	}
}

extension Array: ValueConvertible where Element: ValueConvertible {
	public func toValue(encoder: Encoder) -> Value {
		return Value(self.map { $0.toValue(encoder: encoder)} )
	}
}

extension Dictionary: ValueConvertible where Key == String, Value: ValueConvertible {
	public func toValue(encoder: Encoder) -> Liquid.Value {
		return Liquid.Value(self.mapValues { $0.toValue(encoder: encoder)} )
	}
}

extension Optional where Wrapped: ValueConvertible {
	public func toValue(encoder: Encoder) -> Liquid.Value {
		switch self {
		case .none:
			return Value()
		case .some(let value):
			return value.toValue(encoder: encoder)
		}
	}
}

extension Drop {
	public func toValue(encoder: Encoder) -> Value {
		return Value(self)
	}
}
