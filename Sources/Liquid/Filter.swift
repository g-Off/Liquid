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
	
	init(name: String, args: [Expression]) {
		self.name = name
		self.args = args
	}
}

public typealias FilterFunc = (_ value: Value, _ args: [Value], _ encoder: Encoder) throws -> Value
