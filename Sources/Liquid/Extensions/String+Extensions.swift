//
//  String+Extensions.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-15.
//

import Foundation

extension String {
	func strip() -> String {
		return self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
	}
	
	func rstrip() -> String {
		var idx = endIndex
		while idx != startIndex {
			idx = self.index(before: idx)
			if !CharacterSet.whitespacesAndNewlines.contains(self[idx]) {
				break
			}
		}
		return String(self[startIndex...idx])
	}
	
	func lstrip() -> String {
		var idx = startIndex
		while idx != endIndex {
			if !CharacterSet.whitespacesAndNewlines.contains(self[idx]) {
				break
			}
			idx = self.index(after: idx)
		}
		return String(self[idx..<endIndex])
	}
}
