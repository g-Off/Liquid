//
//  Scanner+Extensions.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-05.
//

import Foundation

private let validNumberCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "-."))
private let invalidNumberCharacters = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: "-.")).inverted

extension Scanner {
	var liquid_currentIndex: String.Index {
        get {
            let string = self.string
            var index = string.toUTF16Index(scanLocation)
            
            var delta = 0
            while index != string.endIndex && index.samePosition(in: string) == nil {
                delta += 1
                index = string.toUTF16Index(scanLocation + delta)
            }
            
            return index
        }
        set {
			scanLocation = string.toUTF16Offset(newValue)
		}
    }
	
	var liquid_remainingString: String {
		return String(self.string[liquid_currentIndex...])
	}
	
	func liquid_peekCharacter(at: Int = 0) -> Character? {
		guard !isAtEnd else { return nil }
		return string[string.index(liquid_currentIndex, offsetBy: at)]
	}
	
	func liquid_scanCharacter() -> Character? {
		let currentIndex = liquid_currentIndex
        let string = self.string
        guard currentIndex != string.endIndex else { return nil }
		defer { self.liquid_currentIndex = string.index(after: currentIndex) }
        return string[currentIndex]
	}
	
	func liquid_scanInt() -> String? {
		var int: Int = 0
		if self.scanInt(&int) {
			return "\(int)"
		}
		return nil
	}
	
	func liquid_scanDecimal() -> String? {
		guard let character = liquid_peekCharacter(), validNumberCharacters.contains(character) else { return nil }
		let currentLocation = self.liquid_currentIndex
		var decimal: Decimal = 0
		if self.scanDecimal(&decimal) {
			// Check to make sure we didn't just scan a number that is part of a range statement, i.e. (1..5)
			// If we did, then reverse out of the scan, resetting scan position, and return nil
			guard liquid_peekCharacter() != ".", liquid_peekCharacter(at: -1) != "." else {
				self.liquid_currentIndex = currentLocation
				return nil
			}
			let matchString = string[currentLocation..<liquid_currentIndex]
			// Check to make sure there's a decimal place, we don't want to capture Integer values
			guard matchString.rangeOfCharacter(from: invalidNumberCharacters) == nil else {
				self.liquid_currentIndex = currentLocation
				return nil
			}
			guard matchString.contains(".") else {
				self.liquid_currentIndex = currentLocation
				return nil
			}
			return "\(decimal)"
		}
		return nil
	}
	
	@discardableResult
	func liquid_scanCharacters(from set: CharacterSet) -> String? {
		let currentIndex = liquid_currentIndex
        
        let substringEnd = string[currentIndex...].firstIndex(where: { !set.contains($0) }) ?? string.endIndex
        guard currentIndex != substringEnd else { return nil }
        
        let substring = string[currentIndex ..< substringEnd]
        self.liquid_currentIndex = substringEnd
        return String(substring)
	}
	
	func liquid_scanRegex(_ regex: NSRegularExpression, captureGroup: Int = 0) -> String? {
		let range = NSRange((liquid_currentIndex..<self.string.endIndex), in: self.string)
		guard let match = regex.firstMatch(in: self.string, options: [.anchored], range: range) else {
			return nil
		}
		guard let matchRange = Range<String.Index>(match.range(at: captureGroup), in: self.string) else {
			return nil
		}
		
		self.scanLocation += match.range.length
		
		return String(self.string[matchRange])
	}
	
	func liquid_scanRegex(_ regexString: String, captureGroup: Int = 0) throws -> String? {
		let regex = try NSRegularExpression(pattern: regexString)
		return liquid_scanRegex(regex, captureGroup: captureGroup)
	}
}

private extension String {
	func toUTF16Index(_ offset: Int) -> Index {
		return self.utf16.index(self.utf16.startIndex, offsetBy: offset)
	}
	
	func toUTF16Offset(_ idx: Index) -> Int {
		return self.utf16.distance(from: self.utf16.startIndex, to: idx)
	}
}
