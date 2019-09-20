//
//  SyntaxError.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-02.
//

import Foundation

public enum SyntaxError: Error {
	case unknownTag(String)
	case unclosedTag(String)
	case missingMarkup
	case unexpectedToken(Character)
	case reason(String) // TODO: this is just a raw string explaining the failure
}

public enum RuntimeError: Error {
	case wrongType(String)
	case unknownFilter(String)
	
	case invalidArgCount(expected: Int, received: Int, tag: String)
	
	case unimplemented
}

func tagName(function: String = #function) -> String {
	guard let index = function.firstIndex(of: "(") else { return function }
	return String(function[..<index])
}
