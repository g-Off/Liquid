//
//  Filter.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-03.
//

import Foundation

struct Filter {
	let name: String
	let args: [Expression]
	let kwargs: [String: Expression]
	
	init(name: String, args: [Expression], kwargs: [String: Expression]) {
		self.name = name
		self.args = args
		self.kwargs = kwargs
	}
}

public typealias FilterFunc = (_ value: Value, _ args: [Value], _ kwargs: [String: Value], _ context: FilterContext) throws -> Value
