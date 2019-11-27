//
//  Comment.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-09.
//

import Foundation

struct Comment: Tag {
	init(name: String, markup: String?, context: ParseContext) throws {
		fatalError()
	}
	
	func parse(_ tokenizer: Tokenizer, context: ParseContext) throws {
		fatalError()
	}
	
	func render(context: RenderContext) -> [String] {
		fatalError()
	}
}
