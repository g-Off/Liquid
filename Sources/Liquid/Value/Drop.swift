//
//  Drop.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-16.
//

import Foundation

public struct DropKey: Hashable {
	public let rawValue: String
	
	public init(rawValue: String) {
		self.rawValue = rawValue
	}
}

public protocol Drop: class, ValueConvertible {
	func value(forKey key: DropKey, encoder: Encoder) throws -> Value?
}

#if false
// Disabled until I figure out best way to map NSObject, specifically NSNumber to proper types in the Encoder
// Right now, a bool NSNumber ends up being an Int, which doesn't work for a comparison
public func fetchValue(forKey key: DropKey, from object: NSObject, encoder: Encoder) throws -> Value? {
	guard let value = object.value(forKey: key.rawValue) else { return nil }
	
	return try encoder.encode(value)
}
#endif

#if false
// Disabled until figure out the best approach for Mirror
public func value(forKey key: DropKey, from object: Drop, encoder: Encoder) throws -> Value? {
	let mirror = Mirror(reflecting: object)
	let child = mirror.children.first { (label, value) -> Bool in
		return label == key.rawValue
	}
	
	child?.value
	
	return nil
}
#endif
