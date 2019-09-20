//
//  Block.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-02.
//

import Foundation

open class Block {
	let name: String
	
	init(name: String) {
		self.name = name
	}
	
	func parse(body: BlockBody, tokenizer: Tokenizer, context: ParseContext) throws -> Bool {
		let endTagName = "end\(name)"
		
		var continueParsing: Bool = true
		try body.parse(tokenizer, context: context) { (tagName, markup) in
			guard let tagName = tagName else {
				throw SyntaxError.unclosedTag(name)
			}
			if tagName == endTagName {
				continueParsing = false
			} else {
				try handleUnknown(tag: tagName, markup: markup)
			}
		}
		return continueParsing
	}
	
	func handleUnknown(tag: String, markup: String?) throws {
		throw SyntaxError.unknownTag(tag)
	}
}
