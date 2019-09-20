//
//  IfElseTests.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-12.
//

import Foundation

import XCTest
@testable import Liquid

final class IfElseTests: XCTestCase {
	func test_if() {
		XCTAssertTemplate(" {% if false %} this text should not go into the output {% endif %} ", "  ")
		XCTAssertTemplate(" {% if true %} this text should go into the output {% endif %} ",
						  "  this text should go into the output  ")
		XCTAssertTemplate("{% if false %} you suck {% endif %} {% if true %} you rock {% endif %}?", "  you rock ?")
	}
	
	func test_literal_comparisons() {
		XCTAssertTemplate("{% assign v = false %}{% if v %} YES {% else %} NO {% endif %}", " NO ")
		XCTAssertTemplate("{% assign v = nil %}{% if v == nil %} YES {% else %} NO {% endif %}", " YES ")
	}
	
	func test_if_else() {
		XCTAssertTemplate("{% if false %} NO {% else %} YES {% endif %}", " YES ")
		XCTAssertTemplate("{% if true %} YES {% else %} NO {% endif %}", " YES ")
		XCTAssertTemplate(#"{% if "foo" %} YES {% else %} NO {% endif %}"#, " YES ")
	}
	
	func test_if_boolean() {
		XCTAssertTemplate("{% if var %} YES {% endif %}", " YES ", ["var": true])
	}
	
	func test_if_or() {
		XCTAssertTemplate("{% if a or b %} YES {% endif %}", " YES ", ["a": true, "b": true])
		XCTAssertTemplate("{% if a or b %} YES {% endif %}", " YES ", ["a": true, "b": false])
		XCTAssertTemplate("{% if a or b %} YES {% endif %}", " YES ", ["a": false, "b": true])
		XCTAssertTemplate("{% if a or b %} YES {% endif %}", "", ["a": false, "b": false])
		
		XCTAssertTemplate("{% if a or b or c %} YES {% endif %}", " YES ", ["a": false, "b": false, "c": true])
		XCTAssertTemplate("{% if a or b or c %} YES {% endif %}", "", ["a": false, "b": false, "c": false])
	}
	
	func test_if_or_with_operators() {
		XCTAssertTemplate("{% if a == true or b == true %} YES {% endif %}", " YES ", ["a": true, "b": true])
		XCTAssertTemplate("{% if a == true or b == false %} YES {% endif %}", " YES ", ["a": true, "b": true])
		XCTAssertTemplate("{% if a == false or b == false %} YES {% endif %}", "", ["a": true, "b": true])
	}
	
	func test_comparison_of_strings_containing_and_or_or() {
		let awfulMarkup = "a == 'and' and b == 'or' and c == 'foo and bar' and d == 'bar or baz' and e == 'foo' and foo and bar"
		let assigns: [String: Any] = [ "a": "and", "b": "or", "c": "foo and bar", "d": "bar or baz", "e": "foo", "foo": true, "bar": true ]
		XCTAssertTemplate("{% if \(awfulMarkup) %} YES {% endif %}", " YES ", assigns)
	}
	
	func test_if_and() {
		XCTAssertTemplate("{% if true and true %} YES {% endif %}", " YES ")
		XCTAssertTemplate("{% if false and true %} YES {% endif %}", "")
		XCTAssertTemplate("{% if false and true %} YES {% endif %}", "")
	}
	
	func test_hash_miss_generates_false() {
		XCTAssertTemplate("{% if foo.bar %} NO {% endif %}", "", ["foo": [] as [Int]])
	}
	
	func test_if_from_variable() {
		XCTAssertTemplate("{% if var %} NO {% endif %}", "", ["var": false])
		XCTAssertTemplate("{% if var %} NO {% endif %}", "", ["var": nil])
		XCTAssertTemplate("{% if foo.bar %} NO {% endif %}", "", ["foo": ["bar": false]])
		XCTAssertTemplate("{% if foo.bar %} NO {% endif %}", "", ["foo": []])
		XCTAssertTemplate("{% if foo.bar %} NO {% endif %}", "", ["foo": nil])
		XCTAssertTemplate("{% if foo.bar %} NO {% endif %}", "", ["foo": true])
		
		XCTAssertTemplate("{% if var %} YES {% endif %}", " YES ", ["var": "text"])
		XCTAssertTemplate("{% if var %} YES {% endif %}", " YES ", ["var": true])
		XCTAssertTemplate("{% if var %} YES {% endif %}", " YES ", ["var": 1])
		XCTAssertTemplate("{% if var %} YES {% endif %}", " YES ", ["var": []])
		XCTAssertTemplate("{% if var %} YES {% endif %}", " YES ", ["var": []])
		XCTAssertTemplate(#"{% if "foo" %} YES {% endif %}"#, " YES ")
		XCTAssertTemplate("{% if foo.bar %} YES {% endif %}", " YES ", ["foo": ["bar": true]])
		XCTAssertTemplate("{% if foo.bar %} YES {% endif %}", " YES ", ["foo": ["bar": "text"]])
		XCTAssertTemplate("{% if foo.bar %} YES {% endif %}", " YES ", ["foo": ["bar": 1]])
		XCTAssertTemplate("{% if foo.bar %} YES {% endif %}", " YES ", ["foo": ["bar": []]])
		XCTAssertTemplate("{% if foo.bar %} YES {% endif %}", " YES ", ["foo": ["bar": []]])
		
		XCTAssertTemplate("{% if var %} NO {% else %} YES {% endif %}", " YES ", ["var": false])
		XCTAssertTemplate("{% if var %} NO {% else %} YES {% endif %}", " YES ", ["var": nil])
		XCTAssertTemplate("{% if var %} YES {% else %} NO {% endif %}", " YES ", ["var": true])
		XCTAssertTemplate(#"{% if "foo" %} YES {% else %} NO {% endif %}"#, " YES ", ["var": "text"])
		
		XCTAssertTemplate("{% if foo.bar %} NO {% else %} YES {% endif %}", " YES ", ["foo": ["bar": false]])
		XCTAssertTemplate("{% if foo.bar %} YES {% else %} NO {% endif %}", " YES ", ["foo": ["bar": true]])
		XCTAssertTemplate("{% if foo.bar %} YES {% else %} NO {% endif %}", " YES ", ["foo": ["bar": "text"]])
		XCTAssertTemplate("{% if foo.bar %} NO {% else %} YES {% endif %}", " YES ", ["foo": ["notbar": true]])
		XCTAssertTemplate("{% if foo.bar %} NO {% else %} YES {% endif %}", " YES ", ["foo": []])
		XCTAssertTemplate("{% if foo.bar %} NO {% else %} YES {% endif %}", " YES ", ["notfoo": ["bar": true]])
	}
	
	func test_nested_if() {
		XCTAssertTemplate("{% if false %}{% if false %} NO {% endif %}{% endif %}", "")
		XCTAssertTemplate("{% if false %}{% if true %} NO {% endif %}{% endif %}", "")
		XCTAssertTemplate("{% if true %}{% if false %} NO {% endif %}{% endif %}", "")
		XCTAssertTemplate("{% if true %}{% if true %} YES {% endif %}{% endif %}", " YES ")
		
		XCTAssertTemplate("{% if true %}{% if true %} YES {% else %} NO {% endif %}{% else %} NO {% endif %}", " YES ")
		XCTAssertTemplate("{% if true %}{% if false %} NO {% else %} YES {% endif %}{% else %} NO {% endif %}", " YES ")
		XCTAssertTemplate("{% if false %}{% if true %} NO {% else %} NONO {% endif %}{% else %} YES {% endif %}", " YES ")
	}
	
	func test_comparisons_on_null() {
//		XCTAssertTemplate("{% if null < 10 %} NO {% endif %}", "")
		XCTAssertTemplate("{% if null <= 10 %} NO {% endif %}", "")
//		XCTAssertTemplate("{% if null >= 10 %} NO {% endif %}", "")
//		XCTAssertTemplate("{% if null > 10 %} NO {% endif %}", "")
//
//		XCTAssertTemplate("{% if 10 < null %} NO {% endif %}", "")
//		XCTAssertTemplate("{% if 10 <= null %} NO {% endif %}", "")
//		XCTAssertTemplate("{% if 10 >= null %} NO {% endif %}", "")
//		XCTAssertTemplate("{% if 10 > null %} NO {% endif %}", "")
	}
	
	func test_else_if() {
		XCTAssertTemplate("{% if 0 == 0 %}0{% elsif 1 == 1%}1{% else %}2{% endif %}", "0")
		XCTAssertTemplate("{% if 0 != 0 %}0{% elsif 1 == 1%}1{% else %}2{% endif %}", "1")
		XCTAssertTemplate("{% if 0 != 0 %}0{% elsif 1 != 1%}1{% else %}2{% endif %}", "2")
		
		XCTAssertTemplate("{% if false %}if{% elsif true %}elsif{% endif %}", "elsif")
	}
	
	func test_unended_if() throws {
		let template = Template(source: "{% if true %}hello")
		XCTAssertThrowsError(try template.parse())
	}
}

