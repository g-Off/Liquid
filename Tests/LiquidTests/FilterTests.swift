//
//  FilterTests.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-12.
//

import Foundation

import XCTest
@testable import Liquid

final class FilterTests: XCTestCase {
	func testAppendToString() {
		XCTAssertTemplate("{{ \"hello \" | append: \"world\" }}", "hello world")
		XCTAssertTemplate("{{ 32 | append: \"world\" }}", "32world")
		XCTAssertTemplate("{{ 32.94 | append: \"world\" }}", "32.94world")
	}
	
	func testPrepend() {
		XCTAssertTemplate("{{ \" world\" | prepend: \"hello\" }}", "hello world")
	}
	
	func testDowncase() {
		XCTAssertTemplate("{{ \"HELLO\" | downcase }}", "hello")
	}
	
	func testUpcase() {
		XCTAssertTemplate("{{ \"hello\" | upcase }}", "HELLO")
	}
	
	func testCapitalize() {
		XCTAssertTemplate("{{ \"hello world\" | capitalize }}", "Hello world")
	}
	
	func testStrip() {
		XCTAssertTemplate("{{ \" \r\n\thello\t\n\r \" | strip }}", "hello")
	}
	
	func testRstrip() {
		XCTAssertTemplate("{{ \" \r\n\thello\t\n\r \" | rstrip }}", " \r\n\thello")
	}
	
	func testLstrip() {
		XCTAssertTemplate("{{ \" \r\n\thello\t\n\r \" | lstrip }}", "hello\t\n\r ")
	}
	
	func testStripNewLines() {
		XCTAssertTemplate("{{ \"\r\nhe\nll\ro\r\" | strip_newlines }}", "hello")
	}
	
	func testNewlineToBr() {
		XCTAssertTemplate("{{ \"hello\nand\ngoodbye\n\" | newline_to_br }}", "hello<br />\nand<br />\ngoodbye<br />\n")
	}
	
	func testEscape() {
		XCTAssertEqual(try Filters.escapeFilter(value: Value("<strong>"), args: [], kwargs: [:], encoder: Encoder()).toString(), "&lt;strong&gt;")
	}
	
	func testEscapeOnce() throws {
		XCTAssertEqual(try Filters.escapeOnceFilter(value: Value("&lt;strong&gt;Hulk</strong>"), args: [], kwargs: [:], encoder: Encoder()).toString(), "&lt;strong&gt;Hulk&lt;/strong&gt;")
	}
	
	func testUrlEncode() {
		XCTAssertEqual(try Filters.urlEncodeFilter(value: Value("foo+1@example.com"), args: [], kwargs: [:], encoder: Encoder()).toString(), "foo%2B1%40example.com")
	}
	
	func testUrlDecode() {
		XCTAssertEqual(try Filters.urlDecodeFilter(value: Value("foo+bar"), args: [], kwargs: [:], encoder: Encoder()).toString(), "foo bar")
		XCTAssertEqual(try Filters.urlDecodeFilter(value: Value("foo%20bar"), args: [], kwargs: [:], encoder: Encoder()).toString(), "foo bar")
		XCTAssertEqual(try Filters.urlDecodeFilter(value: Value("foo%2B1%40example.com"), args: [], kwargs: [:], encoder: Encoder()).toString(), "foo+1@example.com")
		
		XCTAssertEqual(try Filters.urlDecodeFilter(value: Value("%20"), args: [], kwargs: [:], encoder: Encoder()).toString(), " ")
		XCTAssertEqual(try Filters.urlDecodeFilter(value: Value("%2"), args: [], kwargs: [:], encoder: Encoder()).toString(), "%2")
		XCTAssertEqual(try Filters.urlDecodeFilter(value: Value("%"), args: [], kwargs: [:], encoder: Encoder()).toString(), "%")
	}
	
	func testStripHtml() {
		XCTAssertTemplate("{{ \"<p>hello <b>w<span>or</span>ld</b></p>\" | strip_html }}", "hello world")
	}
	
	func testTruncateWords() {
		XCTAssertTemplate("{{ 'Ground control to Major Tom.' | truncatewords: 3 }}", "Ground control to…")
		XCTAssertTemplate("{{ 'Ground control to Major Tom.' | truncatewords: 3, '--' }}", "Ground control to--")
		XCTAssertTemplate("{{ 'Ground control to Major Tom.' | truncatewords: 3, '' }}", "Ground control to")
		XCTAssertTemplate("{{ 'one two three' | truncatewords: 2, 1 }}", "one two1")
	}
	
	func testTruncate() {
		XCTAssertTemplate("{{ \"Ground control to Major Tom.\" | truncate: 20 }}", "Ground control to M…")
		XCTAssertTemplate("{{ \"Ground control to Major Tom.\" | truncate: 25, \", and so on\" }}", "Ground control, and so on")
		XCTAssertTemplate("{{ \"Ground control to Major Tom.\" | truncate: 20, \"\" }}", "Ground control to Ma")
		XCTAssertTemplate("{{ '1234567890' | truncate: 5, 1 }}", "12341")
	}
	
	func testPlus() {
		XCTAssertTemplate("{{ 4 | plus: 2 }}", "6")
		XCTAssertTemplate("{{ 16 | plus: 4 }}", "20")
		XCTAssertTemplate("{{ 183.357 | plus: 12 }}", "195.357")
	}
	
	func testMinus() {
		XCTAssertTemplate("{{ 4 | minus: 2 }}", "2")
		XCTAssertTemplate("{{ 16 | minus: 4 }}", "12")
		XCTAssertTemplate("{{ 183.357 | minus: 12 }}", "171.357")
	}
	
	func testTimes() {
		XCTAssertTemplate("{{ 4 | times: 2 }}", "8")
		XCTAssertTemplate("{{ 16 | times: 4 }}", "64")
		XCTAssertTemplate("{{ 183.357 | times: 12 }}", "2200.284")
	}
	
	func testDividedBy() {
		XCTAssertTemplate("{{ 16 | divided_by: 4 }}", "4")
		XCTAssertTemplate("{{ 5 | divided_by: 3 }}", "1")
		XCTAssertTemplate("{{ 20 | divided_by: 7 }}", "2")
		XCTAssertTemplate("{{ 20 | divided_by: 7.0 }}", "2.85714286")
	}
	
	func testAbs() {
		XCTAssertTemplate("{{ -17 | abs }}", "17")
		XCTAssertTemplate("{{ 4 | abs }}", "4")
		XCTAssertTemplate("{{ -19.86 | abs }}", "19.86")
	}
	
	func testCeil() {
		XCTAssertTemplate("{{ 1.2 | ceil }}", "2")
		XCTAssertTemplate("{{ 2.0 | ceil }}", "2")
		XCTAssertTemplate("{{ 183.357 | ceil }}", "184")
	}
	
	func testFloor() {
		XCTAssertTemplate("{{ 1.2 | floor }}", "1")
		XCTAssertTemplate("{{ 2.0 | floor }}", "2")
		XCTAssertTemplate("{{ 183.357 | floor }}", "183")
	}
	
	func testRound() {
		XCTAssertTemplate("{{ 1.2 | round }}", "1")
		XCTAssertTemplate("{{ 2.7 | round }}", "3")
		XCTAssertTemplate("{{ 183.357 | round: 1}}", "183.4")
		XCTAssertTemplate("{{ 183.357 | round: 2}}", "183.36")
	}
	
	func testModulo() {
		XCTAssertTemplate("{{ 3 | modulo: 2 }}", "1")
		XCTAssertTemplate("{{ 24 | modulo: 7 }}", "3")
		XCTAssertTemplate("{{ 183.357 | modulo: 12 }}", "3.357")
	}
	
	func testSplit() {
		XCTAssertTemplate("{{ 'John, Paul, George, Ringo' | split: ', ' | size }}", "4")
		XCTAssertTemplate("{{ 'A1Z' | split: '1' | join: '' }}", "AZ")
		XCTAssertTemplate("{{ 'A1Z' | split: 1 | join: '' }}", "AZ")
	}
	
	func testJoin() {
		XCTAssertTemplate("{{ 'John, Paul, George, Ringo' | split: ', ' | join: '.' }}", "John.Paul.George.Ringo")
	}
	
	func testUnique() {
		XCTAssertTemplate("{{ 'ants, bugs, bees, bugs, ants' | split: ', ' | uniq | join: '.' }}", "ants.bugs.bees")
	}
	
	func testSize() {
		XCTAssertTemplate("{{ 'Ground control to Major Tom.' | size }}", "28")
		XCTAssertTemplate("{{ what.size }}", "28", ["what": "Ground control to Major Tom."])
	}
	
	func testFirst() {
		XCTAssertTemplate("{{ 'John, Paul, George, Ringo' | split: ', ' | first }}", "John")
		XCTAssertTemplate("{{ names.first }}", "John", ["names": ["John", "Paul", "George", "Ringo"]])
	}
	
	func testLast() {
		XCTAssertTemplate("{{ 'John, Paul, George, Ringo' | split: ', ' | last }}", "Ringo")
		XCTAssertTemplate("{{ names.last }}", "Ringo", ["names": ["John", "Paul", "George", "Ringo"]])
	}
	
	func testDefault() {
		XCTAssertTemplate("{{ nil | default: 'test' }}", "test")
		XCTAssertTemplate("{{ product_price | default: 2.99 }}", "2.99")
		XCTAssertTemplate("{{ product_price | default: 2.99 }}", "4.99", ["product_price": 4.99]) // TODO: Double needs to be parsable
		XCTAssertTemplate("{{ product_price | default: 2.99 }}", "2.99", ["product_price": nil])
	}
	
	func testReplace() {
		XCTAssertTemplate("{{ 'Take my protein pills and put my helmet on' | replace: 'my', 'your' }}", "Take your protein pills and put your helmet on")
	}
	
	func testReplaceFirst() {
		XCTAssertTemplate("{{ 'Take my protein pills and put my helmet on' | replace_first: 'my', 'your' }}", "Take your protein pills and put my helmet on")
	}
	
	func testRemove() {
		XCTAssertTemplate("{{ 'I strained to see the train through the rain' | remove: 'rain' }}", "I sted to see the t through the ")
	}
	
	func testRemoveFirst() {
		XCTAssertTemplate("{{ 'I strained to see the train through the rain' | remove_first: 'rain' }}", "I sted to see the train through the rain")
	}
	
	func testSlice() {
		XCTAssertTemplate("{{ 'Liquid' | slice: 0 }}", "L")
		XCTAssertTemplate("{{ 'Liquid' | slice: 2 }}", "q")
		XCTAssertTemplate("{{ 'Liquid' | slice: -3, 2 }}", "ui")
	}
	
	func testReverse() {
		XCTAssertTemplate("{{ 'apples,oranges,peaches' | split: ',' | reverse | join: ',' }}", "peaches,oranges,apples")
	}
	
	func testCompact() {
		let data = [
			"array": [nil, "hello", nil, nil, "world", nil]
		]
		XCTAssertTemplate("{{ array | size }}", "6", data)
		XCTAssertTemplate("{{ array | compact | size }}", "2", data)
		XCTAssertTemplate("{{ array | compact | join: ' ' }}", "hello world", data)
	}
	
	func testMap() {
		let data = [
			"pages": [
				["category": "business"],
				["category": "celebrities"],
				["category": "lifestyle"],
				["category": "sports"],
				["category": "technology"]
			]
		]
		XCTAssertTemplate("{{ pages | size }}", "5", data)
		XCTAssertTemplate("{{ pages | map: 'category' | size }}", "5", data)
		XCTAssertTemplate("{{ pages | map: 'category' | join: ' ' }}", "business celebrities lifestyle sports technology", data)
	}
	
	func testConcat() {
		XCTAssertTemplate("{{ names1 | concat: names2 | join: ',' }}", "bill,steve,larry,michael", ["names1": ["bill", "steve"], "names2": ["larry", "michael"]])
	}
	
	func testSort() {
		XCTAssertTemplate("{{ array | sort | join: ', ' }}", "Sally Snake, giraffe, octopus, zebra", ["array": ["zebra", "octopus", "giraffe", "Sally Snake"]])
		XCTAssertTemplate("{{ names | sort: 'name' | map: 'name' | join: ', ' }}", "Jane, Sally, bob, george", ["names": [["name": "bob"], ["name": "Sally"], ["name": "george"], ["name": "Jane"]]])
	}
	
	func testSortNatural() {
		XCTAssertTemplate("{{ array | sort_natural | join: ', ' }}", "giraffe, octopus, Sally Snake, zebra", ["array": ["zebra", "octopus", "giraffe", "Sally Snake"]])
		XCTAssertTemplate("{{ names | sort_natural: 'name' | map: 'name' | join: ', ' }}", "bob, george, Jane, Sally", ["names": [["name": "bob"], ["name": "Sally"], ["name": "george"], ["name": "Jane"]]])
	}
	
	func testDate() throws {
		NSTimeZone.default = TimeZone(abbreviation: "GMT")!
		var encoder = Encoder()
		encoder.locale = Locale(identifier: "en_US")

		XCTAssertEqual(try Filters.dateFilter(value: Value("2006-05-05T10:00:00Z"), args: [Value("%B")], kwargs: [:], encoder: encoder), Value("May"))
		XCTAssertEqual(try Filters.dateFilter(value: Value("2006-06-05T10:00:00Z"), args: [Value("%B")], kwargs: [:], encoder: encoder), Value("June"))
		XCTAssertEqual(try Filters.dateFilter(value: Value("2006-07-05T10:00:00Z"), args: [Value("%B")], kwargs: [:], encoder: encoder), Value("July"))
		
		XCTAssertEqual(try Filters.dateFilter(value: Value("2006-07-05T10:00:00Z"), args: [Value("")], kwargs: [:], encoder: encoder), Value("7/5/06, 10:00:00 AM"))
		XCTAssertEqual(try Filters.dateFilter(value: Value("2006-07-05T10:00:00Z"), args: [Value()], kwargs: [:], encoder: encoder), Value("7/5/06, 10:00:00 AM"))
		
		let yearString = "\(Calendar.autoupdatingCurrent.component(.year, from: Date()))"
		XCTAssertEqual(try Filters.dateFilter(value: Value("2004-07-16T01:00:00Z"), args: [Value("%m/%d/%Y")], kwargs: [:], encoder: encoder), Value("07/16/2004"))
		XCTAssertEqual(try Filters.dateFilter(value: Value("now"), args: [Value("%Y")], kwargs: [:], encoder: encoder), Value(yearString))
		XCTAssertEqual(try Filters.dateFilter(value: Value("today"), args: [Value("%Y")], kwargs: [:], encoder: encoder), Value(yearString))
		XCTAssertEqual(try Filters.dateFilter(value: Value("Today"), args: [Value("%Y")], kwargs: [:], encoder: encoder), Value(yearString))
		
		XCTAssertEqual(try Filters.dateFilter(value: Value(1152098955), args: [Value("%m/%d/%Y")], kwargs: [:], encoder: encoder), Value("07/05/2006"))
		XCTAssertEqual(try Filters.dateFilter(value: Value("1152098955"), args: [Value("%m/%d/%Y")], kwargs: [:], encoder: encoder), Value("07/05/2006"))
	}
	
	func testFilterArgs() {
		let echoFilter: FilterFunc = { (value, args, kwargs, encoder) -> Value in
			let strArgs = args.map { "\($0)" }.sorted()
			return Value(value.toString() + " - " + strArgs.description)
		}
		
		let filters = ["echo": echoFilter]
		XCTAssertTemplate("{{ 'testing' | echo: 'Fox Mulder', 1961 }}", "testing - [\"int: <1961>\", \"string: <Fox Mulder>\"]", filters: filters)
		
		let values: [String: Any] = ["name": "Dana Scully", "yob": 1964]
		XCTAssertTemplate("{{ 'testing' | echo: name, yob }}", "testing - [\"int: <1964>\", \"string: <Dana Scully>\"]", values, filters: filters)
	}
	
	func testFilterKWArgs() {
		let echoFilter: FilterFunc = { (value, args, kwargs, encoder) -> Value in
			let strKWArgs = kwargs.map { "\($0):\($1)" }.sorted()
			return Value(value.toString() + " - " + strKWArgs.description)
		}
		
		let filters = ["echo": echoFilter]
		XCTAssertTemplate("{{ 'testing' | echo: name: 'Fox Mulder', yob: 1961 }}", "testing - [\"name:string: <Fox Mulder>\", \"yob:int: <1961>\"]", filters: filters)
		
		let values: [String: Any] = ["name": "Dana Scully", "yob": 1964]
		XCTAssertTemplate("{{ 'testing' | echo: name: name, yob: yob }}", "testing - [\"name:string: <Dana Scully>\", \"yob:int: <1964>\"]", values, filters: filters)
	}
	
	func testFilterOrderedAndNamedArgs() {
		let echoFilter: FilterFunc = { (value, args, kwargs, encoder) -> Value in
			let strArgs = args.map { "\($0)" }.sorted()
			let strKWArgs = kwargs.map { "\($0):\($1)" }.sorted()
			return Value(value.toString() + " - " + strArgs.description + strKWArgs.description)
		}
		
		let filters = ["echo": echoFilter]
		XCTAssertTemplate("{{ 'testing' | echo: 1, 2, 3, name: 'Fox Mulder', yob: 1961 }}", "testing - [\"int: <1>\", \"int: <2>\", \"int: <3>\"][\"name:string: <Fox Mulder>\", \"yob:int: <1961>\"]", filters: filters)
	}
}
