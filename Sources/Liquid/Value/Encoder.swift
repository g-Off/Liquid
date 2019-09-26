//
//  Encoder.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-18.
//

import Foundation

public struct Encoder {
	public enum EncodingError: Error {
		case unencodableType(String)
	}
	
	public enum DateEncodingStrategy {
		case iso8601
		case formatted(DateFormatter)
		
		internal func date(from string: String) -> Date? {
			switch self {
			case .iso8601:
				if #available(OSX 10.12, iOS 10.0, watchOS 3.0, tvOS 10.0, *) {
					return ISO8601DateFormatter().date(from: string)
				} else {
					let formatter = DateFormatter()
					formatter.locale = Locale(identifier: "en_US_POSIX")
					formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
					return formatter.date(from: string)
				}
			case .formatted(let formatter):
				return formatter.date(from: string)
			}
		}
	}
	
	public enum KeyEncodingStrategy {

		/// Use the keys specified by each type. This is the default strategy.
		case useDefaultKeys

		/// Convert from "camelCaseKeys" to "snake_case_keys" before writing a key to JSON payload.
		///
		/// Capital characters are determined by testing membership in `CharacterSet.uppercaseLetters` and `CharacterSet.lowercaseLetters` (Unicode General Categories Lu and Lt).
		/// The conversion to lower case uses `Locale.system`, also known as the ICU "root" locale. This means the result is consistent regardless of the current user's locale and language preferences.
		///
		/// Converting from camel case to snake case:
		/// 1. Splits words at the boundary of lower-case to upper-case
		/// 2. Inserts `_` between words
		/// 3. Lowercases the entire string
		/// 4. Preserves starting and ending `_`.
		///
		/// For example, `oneTwoThree` becomes `one_two_three`. `_oneTwoThree_` becomes `_one_two_three_`.
		///
		/// - Note: Using a key encoding strategy has a nominal performance cost, as each string key has to be converted.
		case convertToSnakeCase
		
		func transform(key: String) -> DropKey {
			switch self {
			case .useDefaultKeys:
				return DropKey(rawValue: key)
			case .convertToSnakeCase:
				return DropKey(rawValue: _convertToSnakeCase(key))
			}
		}
		
		private func _convertToSnakeCase(_ stringKey: String) -> String {
            guard !stringKey.isEmpty else { return stringKey }

            var words : [Range<String.Index>] = []
            // The general idea of this algorithm is to split words on transition from lower to upper case, then on transition of >1 upper case characters to lowercase
            //
            // myProperty -> my_property
            // myURLProperty -> my_url_property
            //
            // We assume, per Swift naming conventions, that the first character of the key is lowercase.
            var wordStart = stringKey.startIndex
            var searchRange = stringKey.index(after: wordStart)..<stringKey.endIndex

            // Find next uppercase character
            while let upperCaseRange = stringKey.rangeOfCharacter(from: CharacterSet.uppercaseLetters, options: [], range: searchRange) {
                let untilUpperCase = wordStart..<upperCaseRange.lowerBound
                words.append(untilUpperCase)

                // Find next lowercase character
                searchRange = upperCaseRange.lowerBound..<searchRange.upperBound
                guard let lowerCaseRange = stringKey.rangeOfCharacter(from: CharacterSet.lowercaseLetters, options: [], range: searchRange) else {
                    // There are no more lower case letters. Just end here.
                    wordStart = searchRange.lowerBound
                    break
                }

                // Is the next lowercase letter more than 1 after the uppercase? If so, we encountered a group of uppercase letters that we should treat as its own word
                let nextCharacterAfterCapital = stringKey.index(after: upperCaseRange.lowerBound)
                if lowerCaseRange.lowerBound == nextCharacterAfterCapital {
                    // The next character after capital is a lower case character and therefore not a word boundary.
                    // Continue searching for the next upper case for the boundary.
                    wordStart = upperCaseRange.lowerBound
                } else {
                    // There was a range of >1 capital letters. Turn those into a word, stopping at the capital before the lower case character.
                    let beforeLowerIndex = stringKey.index(before: lowerCaseRange.lowerBound)
                    words.append(upperCaseRange.lowerBound..<beforeLowerIndex)

                    // Next word starts at the capital before the lowercase we just found
                    wordStart = beforeLowerIndex
                }
                searchRange = lowerCaseRange.upperBound..<searchRange.upperBound
            }
            words.append(wordStart..<searchRange.upperBound)
            let result = words.map({ (range) in
                return stringKey[range].lowercased()
            }).joined(separator: "_")
            return result
        }
	}
	
	public enum DecimalEncodingStrategy {
		case full
		case scaled(Int)
		
		func encode(value: Decimal) -> String {
			switch self {
			case .full:
				return "\(value)"
			case .scaled(let scale):
				return "\(value.round(scale: scale))"
			}
		}
	}
	
	public var dateEncodingStrategry: DateEncodingStrategy = .iso8601
	public var keyEncodingStrategy: KeyEncodingStrategy = .useDefaultKeys
	public var decimalEncodingStrategy: DecimalEncodingStrategy = .scaled(8)
	public internal(set) var locale: Locale = .current
	
	public func encode(_ input: Any?) throws -> Value {
		guard let input = input else {
			return Value()
		}
		switch input {
		case let value as ValueConvertible:
			return value.toValue(encoder: self)
		case let value as Drop:
			return Value(value)
		case let value as String:
			return Value(value)
		case let value as Int:
			return Value(value)
		case let value as Int8:
			return Value(Int(value))
		case let value as Float:
			return Value(Double(value))
		case let value as Double:
			return Value(value)
		case let value as Bool:
			return Value(value)
		case let value as [Any?]:
			return try Value(value.map { try encode($0) })
		case let value as [String: Any?]:
			return Value(try value.mapValues { try encode($0) })
		default:
			throw EncodingError.unencodableType(String(describing: type(of: input)))
		}
	}
}
