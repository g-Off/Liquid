//
//  BlockBody.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-02.
//

import Foundation

class BlockBody {
	private var nodes: [Node] = []
	
	func parse(_ tokenizer: Tokenizer, context: ParseContext, step: (_ tagName: String?, _ markup: String?) throws -> Void) throws -> Void {
		while let token = tokenizer.next() {
			switch token {
			case .text(let value):
				nodes.append(StringNode(value))
			case .variable(let value):
				nodes.append(VariableNode(try Variable(string: value)))
			case .tag(let value):
				let tagName = value.name
				guard let tagType = context.tags[tagName] else {
					return try step(tagName, value.markup)
				}
				let tag = try tagType(tagName, value.markup, context)
				try tag.parse(tokenizer, context: context)
				nodes.append(tag)
			}
		}
		try step(nil, nil)
	}
	
	func render(context: Context) throws -> [String] {
		var result: [String] = []
		for node in nodes {
			result.append(contentsOf: try node.render(context: context))
			if context.hasInterrupt { break }
		}
		
		return result
	}
}
