//
//  Comment.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-09.
//

import Foundation

class Comment: Block, Tag {
	init(name: String, markup: String?, context: ParseContext) throws {
		super.init(name: name)
	}
	
	func parse(_ tokenizer: Tokenizer, context: ParseContext) throws {
		let body = BlockBody()
		_ = try super.parse(body: body, tokenizer: tokenizer, context: context)
	}
	
	func render(context: RenderContext) -> [String] {
		return []
	}
}
