//
//  FilterContext.swift
//  
//
//  Created by Geoffrey Foster on 2019-11-18.
//

import Foundation

public struct FilterContext {
	public let encoder: Encoder
	
	init(context: Context) {
		self.init(encoder: context.encoder)
	}
	
	init(encoder: Encoder) {
		self.encoder = encoder
	}
}
