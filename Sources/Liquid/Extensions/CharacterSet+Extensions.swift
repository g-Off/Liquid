//
//  CharacterSet+Extensions.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-02.
//

import Foundation

extension CharacterSet {
	func contains(_ character: Character) -> Bool {
		return String(character).rangeOfCharacter(from: self) != nil
	}
}
