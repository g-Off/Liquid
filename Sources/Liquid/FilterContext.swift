//
//  FilterContext.swift
//  
//
//  Created by Geoffrey Foster on 2019-11-18.
//

import Foundation

public struct FilterContext {
	public let encoder: Encoder
	public let translations: [String: String]?
	
	init(context: Context) {
		self.init(encoder: context.encoder, translations: context.translations)
	}
	
	init(encoder: Encoder, translations: [String: String]? = nil) {
		self.encoder = encoder
		self.translations = translations
	}
}
