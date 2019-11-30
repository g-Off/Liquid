//
//  Break.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-04.
//

import Foundation

struct Break: Tag {
	init(name: String, markup: String?, context: ParseContext) throws {}
	func parse(_ tokenizer: Tokenizer, context: ParseContext) throws {}
	
	func render(context: RenderContext) -> [String] {
		context.push(interrupt: .break)
		return []
	}
}
