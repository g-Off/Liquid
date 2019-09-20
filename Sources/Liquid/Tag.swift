//
//  Tag.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-02.
//

import Foundation

public protocol Tag: Node {
	func parse(_ tokenizer: Tokenizer, context: ParseContext) throws
}

public typealias TagBuilder = (_ name: String, _ markup: String?, _ context: ParseContext) throws -> Tag

func defaultUnknownTagHandler(tag: String?, markup: String?) throws {
	if let tag = tag {
		throw SyntaxError.reason("Unknown tag \(tag)")
	}
}
