//
//  RawTag.swift
//  
//
//  Created by Geoffrey Foster on 2019-08-30.
//

import Foundation

public struct RawTag: Equatable {
	public let name: String
	public let markup: String?
	
	init(_ string: String) {
		let split = string.split(separator: " ", maxSplits: 1)
		if split.count == 2 {
			name = String(split.first!)
			markup = String(split.last!)
		} else {
			name = string
			markup = nil
		}
	}
}
