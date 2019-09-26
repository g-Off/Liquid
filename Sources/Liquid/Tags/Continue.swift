//
//  Continue.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-04.
//

import Foundation

struct Continue: Tag {
	init(name: String, markup: String?, context: ParseContext) throws {}
	func parse(_ tokenizer: Tokenizer, context: ParseContext) throws {}
	
	func render(context: Context) -> [String] {
		context.push(interrupt: .continue)
		return []
	}
}
