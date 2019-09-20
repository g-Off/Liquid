//
//  Token.swift
//  
//
//  Created by Geoffrey Foster on 2019-08-30.
//

import Foundation

public enum Token: Equatable {
	/// A token representing a piece of text.
	case text(value: String)
	
	/// A token representing a variable.
	case variable(value: String)
	
	/// A token representing a template tag.
	case tag(value: RawTag)
	
	public static func ==(lhs: Token, rhs: Token) -> Bool {
		switch (lhs, rhs) {
		case let (.text(lhsValue), .text(rhsValue)): return lhsValue == rhsValue
		case let (.variable(lhsValue), .variable(rhsValue)): return lhsValue == rhsValue
		case let (.tag(lhsValue), .tag(rhsValue)): return lhsValue == rhsValue
			
		default:
			return false
		}
	}
}
