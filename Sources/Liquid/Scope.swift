//
//  Scope.swift
//  
//
//  Created by Geoffrey Foster on 2019-11-27.
//

import Foundation

class Scope {
	private var values: [String: Value]
	let mutable: Bool
	
	init(mutable: Bool = true, values: [String: Value] = [:]) {
		self.mutable = mutable
		self.values = values
	}
	
	subscript(key: String) -> Value? {
		get {
			return values[key]
		}
		set {
			guard mutable else { return }
			values[key] = newValue
		}
	}
}
