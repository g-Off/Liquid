//
//  Filter+Standard.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-09.
//

import Foundation

enum Filters {
	static func registerFilters(template: Template) {
		template.registerFilter(name: "append", filter: appendFilter)
		template.registerFilter(name: "prepend", filter: prependFilter)
		template.registerFilter(name: "downcase", filter: downcaseFilter)
		template.registerFilter(name: "upcase", filter: upcaseFilter)
		template.registerFilter(name: "capitalize", filter: capitalizeFilter)
		template.registerFilter(name: "strip", filter: stripFilter)
		template.registerFilter(name: "rstrip", filter: rstripFilter)
		template.registerFilter(name: "lstrip", filter: lstripFilter)
		template.registerFilter(name: "strip_newlines", filter: stripNewlinesFilter)
		template.registerFilter(name: "newline_to_br", filter: newlineToBRFilter)
		template.registerFilter(name: "escape", filter: escapeFilter)
		template.registerFilter(name: "escape_once", filter: escapeOnceFilter)
		template.registerFilter(name: "url_encode", filter: urlEncodeFilter)
		template.registerFilter(name: "url_decode", filter: urlDecodeFilter)
		template.registerFilter(name: "strip_html", filter: stripHTMLFilter)
		template.registerFilter(name: "truncate", filter: truncateFilter)
		template.registerFilter(name: "truncatewords", filter: truncateWordsFilter)
		template.registerFilter(name: "plus", filter: plusFilter)
		template.registerFilter(name: "minus", filter: minusFilter)
		template.registerFilter(name: "times", filter: multipliedByFilter)
		template.registerFilter(name: "divided_by", filter: dividedByFilter)
		template.registerFilter(name: "abs", filter: absFilter)
		template.registerFilter(name: "ceil", filter: ceilFilter)
		template.registerFilter(name: "floor", filter: floorFilter)
		template.registerFilter(name: "round", filter: roundFilter)
		template.registerFilter(name: "modulo", filter: moduloFilter)
		template.registerFilter(name: "split", filter: splitFilter)
		template.registerFilter(name: "join", filter: joinFilter)
		template.registerFilter(name: "uniq", filter: uniqueFilter)
		template.registerFilter(name: "size", filter: sizeFilter)
		template.registerFilter(name: "first", filter: firstFilter)
		template.registerFilter(name: "last", filter: lastFilter)
		template.registerFilter(name: "default", filter: defaultFilter)
		template.registerFilter(name: "replace", filter: replaceFilter)
		template.registerFilter(name: "replace_first", filter: replaceFirstFilter)
		template.registerFilter(name: "remove", filter: removeFilter)
		template.registerFilter(name: "remove_first", filter: removeFirstFilter)
		template.registerFilter(name: "slice", filter: sliceFilter)
		template.registerFilter(name: "reverse", filter: reverseFilter)
		template.registerFilter(name: "compact", filter: compactFilter)
		template.registerFilter(name: "map", filter: mapFilter)
		template.registerFilter(name: "concat", filter: concatFilter)
		template.registerFilter(name: "sort", filter: sortFilter)
		template.registerFilter(name: "sort_natural", filter: sortNaturalFilter)
		template.registerFilter(name: "date", filter: dateFilter)
	}
	
	static func appendFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		var result = value.toString()
		args.forEach {
			result += $0.toString()
		}
		return Value(result)
	}
	
	static func prependFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard let first = args.first, args.count == 1 else {
			throw RuntimeError.invalidArgCount(expected: 1, received: args.count, tag: tagName())
		}
		return Value(first.toString() + value.toString())
	}
	
	static func downcaseFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		return Value(value.toString().lowercased())
	}
	
	static func upcaseFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		return Value(value.toString().uppercased())
	}
	
	static func capitalizeFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		let string = value.toString()
		return Value(string.prefix(1).capitalized + string.dropFirst())
	}
	
	static func stripFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		return Value(value.toString().strip())
	}
	
	static func rstripFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		return Value(value.toString().rstrip())
	}
	
	static func lstripFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		return Value(value.toString().lstrip())
	}
	
	static func stripNewlinesFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		return Value(value.toString().replacingOccurrences(of: "\\s", with: "", options: [.regularExpression]))
	}
	
	static func newlineToBRFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		return Value(value.toString().replacingOccurrences(of: "\n", with: "<br />\n"))
	}
	
	static func escapeFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		return Value(value.toString().htmlEscape(decimal: true, useNamedReferences: true))
	}
	
	static func escapeOnceFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		return Value(value.toString().htmlUnescape().htmlEscape(decimal: true, useNamedReferences: true))
	}
	
	static func urlEncodeFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		let inputString = value.toString().replacingOccurrences(of: " ", with: "+")
		// Based on RFC3986: https://tools.ietf.org/html/rfc3986#page-13, and including the `+` char which was already escaped above.
		let allowedCharset = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-._~/?"))
		return Value(inputString.addingPercentEncoding(withAllowedCharacters: allowedCharset) ?? inputString)
	}
	
	static func urlDecodeFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		let string = value.toString().replacingOccurrences(of: "+", with: " ")
		return Value(string.removingPercentEncoding ?? string)
	}
	
	static func stripHTMLFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		return Value(value.toString().replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression))
	}
	
	static func truncateFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard !args.isEmpty, let firstArg = args.first else {
			throw RuntimeError.invalidArgCount(expected: 1, received: args.count, tag: tagName())
		}
		
		let suffix = args.count == 2 ? args[1].toString() : "…"
		let length = firstArg.toInteger() - suffix.count
		let string = value.toString()
		let endIndex = string.index(string.startIndex, offsetBy: length)
		return Value(String((string[string.startIndex..<endIndex]) + suffix))
	}
	
	static func truncateWordsFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard !args.isEmpty, let firstArg = args.first else {
			throw RuntimeError.invalidArgCount(expected: 1, received: args.count, tag: tagName())
		}
		
		let suffix = args.count == 2 ? args[1].toString() : "…"
		let wordCount = firstArg.toInteger()
		let string = value.toString()
		var lastEnumeratedIndex = string.startIndex
		var words: [String] = []
		string.enumerateSubstrings(in: string.startIndex..., options: [.byWords, .localized]) { (word, range, _, stop) in
			guard let word = word else { return }
			
			words.append(word)
			lastEnumeratedIndex = range.upperBound
			if words.count >= wordCount {
				stop = true
			}
		}
		
		if lastEnumeratedIndex == string.endIndex {
			return value
		}
		
		return Value(words.joined(separator: " ").appending(suffix))
	}
	
	static func plusFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.count == 1, let arg = args.first else {
			throw RuntimeError.invalidArgCount(expected: 1, received: args.count, tag: tagName())
		}
		if value.isInteger && arg.isInteger {
			return Value(value.toInteger() + arg.toInteger())
		}
		return Value(value.toDecimal() + arg.toDecimal())
	}
	
	static func minusFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.count == 1, let arg = args.first else {
			throw RuntimeError.invalidArgCount(expected: 1, received: args.count, tag: tagName())
		}
		if value.isInteger && arg.isInteger {
			return Value(value.toInteger() - arg.toInteger())
		}
		return Value(value.toDecimal() - arg.toDecimal())
	}
	
	static func multipliedByFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.count == 1, let arg = args.first else {
			throw RuntimeError.invalidArgCount(expected: 1, received: args.count, tag: tagName())
		}
		if value.isInteger && arg.isInteger {
			return Value(value.toInteger() * arg.toInteger())
		}
		return Value(value.toDecimal() * arg.toDecimal())
	}
	
	static func dividedByFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.count == 1, let arg = args.first else {
			throw RuntimeError.invalidArgCount(expected: 1, received: args.count, tag: tagName())
		}
		if value.isInteger && arg.isInteger {
			return Value(value.toInteger() / arg.toInteger())
		}
		return Value(value.toDecimal() / arg.toDecimal())
	}
	
	static func absFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		if value.isInteger {
			return Value(abs(value.toInteger()))
		}
		return Value(abs(value.toDecimal()))
	}
	
	static func ceilFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		if value.isInteger {
			return value
		}
		return Value(ceil(value.toDecimal().doubleValue))
	}
	
	static func floorFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		if value.isInteger {
			return value
		}
		return Value(floor(value.toDecimal().doubleValue))
	}
	
	static func roundFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.count <= 1 else {
			throw RuntimeError.invalidArgCount(expected: 1, received: args.count, tag: tagName())
		}
		guard !value.isInteger else { return value }
		let result = value.toDecimal().round(scale: args.first?.toInteger() ?? 0)
		return Value(result)
	}
	
	static func moduloFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.count == 1, let arg = args.first else {
			throw RuntimeError.invalidArgCount(expected: 1, received: args.count, tag: tagName())
		}
		
		if value.isInteger && arg.isInteger {
			return Value(value.toInteger() % arg.toInteger())
		}
		return Value(value.toDecimal().doubleValue.truncatingRemainder(dividingBy: arg.toDecimal().doubleValue))
	}
	
	static func splitFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard let separator = args.first?.toString() else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		let components = value.toString().components(separatedBy: separator)
		return Value(components.map { Value($0) })
	}
	
	static func joinFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard let separator = args.first?.toString() else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		return Value(value.toArray().map { $0.toString() }.joined(separator: separator))
	}
	
	static func uniqueFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		var seen: Set<Value> = []
		var unique: [Value] = []
		value.toArray().forEach {
			if seen.contains($0) { return }
			seen.insert($0)
			unique.append($0)
		}
		return Value(unique)
	}
	
	static func sizeFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		return Value(value.size)
	}
	
	static func firstFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		return value.toArray().first ?? Value()
	}
	static func lastFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		return value.toArray().last ?? Value()
	}
	static func defaultFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.count == 1, let arg = args.first else {
			throw RuntimeError.invalidArgCount(expected: 1, received: args.count, tag: tagName())
		}
		if value.isNil || (value.size == 0 && (value.isString || value.isArray || value.isDictionary)) {
			return arg
		} else {
			return value
		}
	}
	static func replaceFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.count == 2 else {
			throw RuntimeError.invalidArgCount(expected: 2, received: args.count, tag: tagName())
		}
		let target = args[0].toString()
		let replacement = args[1].toString()
		return Value(value.toString().replacingOccurrences(of: target, with: replacement))
	}
	
	static func replaceFirstFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.count == 2 else {
			throw RuntimeError.invalidArgCount(expected: 2, received: args.count, tag: tagName())
		}
		let target = args[0].toString()
		let replacement = args[1].toString()
		let string = value.toString()
		guard let range = string.range(of: target) else {
			return value
		}
		return Value(string.replacingCharacters(in: range, with: replacement))
	}
	
	static func removeFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.count == 1 else {
			throw RuntimeError.invalidArgCount(expected: 1, received: args.count, tag: tagName())
		}
		let target = args[0].toString()
		return Value(value.toString().replacingOccurrences(of: target, with: ""))
	}
	
	static func removeFirstFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.count == 1 else {
			throw RuntimeError.invalidArgCount(expected: 1, received: args.count, tag: tagName())
		}
		let target = args[0].toString()
		let string = value.toString()
		guard let range = string.range(of: target) else {
			return value
		}
		return Value(string.replacingCharacters(in: range, with: ""))
	}
	
	static func sliceFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard !args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 1, received: args.count, tag: tagName())
		}
		
		let offset = args[0].toInteger()
		let length = args.count == 2 ? args[1].toInteger() : 1
		let string = value.toString()
		
		let startIndex: String.Index
		let endIndex: String.Index
		if offset < 0 {
			startIndex = string.endIndex
			endIndex = string.startIndex
		} else {
			startIndex = string.startIndex
			endIndex = string.endIndex
		}
		guard
			let sliceStartIndex = string.index(startIndex, offsetBy: offset, limitedBy: endIndex),
			let sliceEndIndex = string.index(sliceStartIndex, offsetBy: length, limitedBy: string.endIndex)
			else {
				return Value()
		}
		
		return Value(String(string[sliceStartIndex..<sliceEndIndex]))
	}
	
	static func reverseFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		return Value(value.toArray().reversed())
	}
	
	static func compactFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.isEmpty else {
			throw RuntimeError.invalidArgCount(expected: 0, received: args.count, tag: tagName())
		}
		return Value(value.toArray().filter { !$0.isNil })
	}
	
	static func mapFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.count == 1 else {
			throw RuntimeError.invalidArgCount(expected: 1, received: args.count, tag: tagName())
		}
		
		let property = args[0]
		let results = value.toArray().map { $0.lookup(property, encoder: encoder) }
		return Value(results)
	}
	
	static func concatFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.count == 1 else {
			throw RuntimeError.invalidArgCount(expected: 1, received: args.count, tag: tagName())
		}
		guard args[0].isArray else {
			throw RuntimeError.wrongType("concat requires an array argument")
		}
		
		var array = value.toArray()
		array.append(contentsOf: args[0].toArray())
		return Value(array)
	}
	
	static func sortFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.count <= 1 else {
			throw RuntimeError.invalidArgCount(expected: 1, received: args.count, tag: tagName())
		}
		
		if let property = args.first {
			return Value(value.toArray().sorted(by: { (lhs, rhs) -> Bool in
				return lhs.lookup(property, encoder: encoder) < rhs.lookup(property, encoder: encoder)
			}))
		} else {
			return Value(value.toArray().sorted())
		}
	}
	
	static func sortNaturalFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.count <= 1 else {
			throw RuntimeError.invalidArgCount(expected: 1, received: args.count, tag: tagName())
		}
		
		if let property = args.first {
			return Value(value.toArray().sorted(by: { (lhs, rhs) -> Bool in
				return lhs.lookup(property, encoder: encoder).toString().caseInsensitiveCompare(rhs.lookup(property, encoder: encoder).toString()) == .orderedAscending
			}))
		} else {
			return Value(value.toArray().sorted(by: { (lhs, rhs) -> Bool in
				return lhs.toString().caseInsensitiveCompare(rhs.toString()) == .orderedAscending
			}))
		}
	}
	
	static func dateFilter(value: Value, args: [Value], encoder: Encoder) throws -> Value {
		guard args.count == 1 else {
			throw RuntimeError.invalidArgCount(expected: 1, received: args.count, tag: tagName())
		}
		
		guard let date = convertValueToDate(value, encoder: encoder) else {
			throw RuntimeError.wrongType("Could not convert to date")
		}
		
		let format = args[0].toString()
		let formatter: DateFormatter
		if format.isEmpty {
			formatter = DateFormatter()
			formatter.dateStyle = .short
			formatter.timeStyle = .medium
		} else {
			formatter = DateFormatter(strfFormatString: format)
		}
		return Value(formatter.string(from: date))
	}
	
	private static func convertValueToDate(_ value: Value, encoder: Encoder) -> Date? {
		if value.isInteger {
			return Date(timeIntervalSince1970: Double(value.toInteger()))
		}
		
		let string = value.toString()
		
		if let integer = Int(string) {
			return Date(timeIntervalSince1970: Double(integer))
		}
		
		if ["now", "today"].contains(string.lowercased()) {
			return Date()
		}
		return encoder.dateEncodingStrategry.date(from: string)
	}
}
