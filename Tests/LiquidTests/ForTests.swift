//
//  ForTests.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-11.
//

import Foundation

import XCTest
@testable import Liquid

final class ForTests: XCTestCase {
	func test_for() {
		XCTAssertTemplate("{%for item in array%} yo {%endfor%}", " yo  yo  yo  yo ", ["array": [1, 2, 3, 4]])
		XCTAssertTemplate("{%for item in array%}yo{%endfor%}", "yoyo", ["array": [1, 2]])
		XCTAssertTemplate("{%for item in array%} yo {%endfor%}", " yo ", ["array": [1]])
		XCTAssertTemplate("{%for item in array%}{%endfor%}", "", ["array": [] as [Int]])
	}
	
	func test_for_reversed() {
		XCTAssertTemplate("{%for item in array reversed %}{{item}}{%endfor%}", "321", ["array": [1, 2, 3]])
	}
	
	func test_for_with_range() {
		XCTAssertTemplate("{%for item in (1..3) %} {{item}} {%endfor%}", " 1  2  3 ")
		XCTAssertTemplate("{% for i in (a..2) %}{% endfor %}", "", ["a": [1, 2]])
		XCTAssertTemplate("{% for item in (a..3) %} {{item}} {% endfor %}", " 0  1  2  3 ", ["a": "invalid integer"])
	}
	
	func test_for_with_variable_range() {
		XCTAssertTemplate("{%for item in (1..foobar.value) %} {{item}} {%endfor%}", " 1  2  3 ", ["foobar": ["value": 3]])
	}
	
	func test_for_helpers() {
		let assigns = ["array": [1, 2, 3]]
		XCTAssertTemplate("{%for item in array%} {{forloop.index}}/{{forloop.length}} {%endfor%}",
						  " 1/3  2/3  3/3 ",
						  assigns)
		XCTAssertTemplate("{%for item in array%} {{forloop.index}} {%endfor%}", " 1  2  3 ", assigns)
		XCTAssertTemplate("{%for item in array%} {{forloop.index0}} {%endfor%}", " 0  1  2 ", assigns)
		XCTAssertTemplate("{%for item in array%} {{forloop.rindex0}} {%endfor%}", " 2  1  0 ", assigns)
		XCTAssertTemplate("{%for item in array%} {{forloop.rindex}} {%endfor%}", " 3  2  1 ", assigns)
		XCTAssertTemplate("{%for item in array%} {{forloop.first}} {%endfor%}", " true  false  false ", assigns)
		XCTAssertTemplate("{%for item in array%} {{forloop.last}} {%endfor%}", " false  false  true ", assigns)
	}
	
	func test_for_and_if() {
		let assigns = ["array": [1, 2, 3]]
		XCTAssertTemplate("{%for item in array%}{% if forloop.first %}+{% else %}-{% endif %}{%endfor%}", "+--", assigns)
	}
	
	func test_for_else() {
		XCTAssertTemplate("{%for item in array%}+{%else%}-{%endfor%}", "+++", ["array": [1, 2, 3]])
		XCTAssertTemplate("{%for item in array%}+{%else%}-{%endfor%}",   "-", ["array": [] as [Int]])
		XCTAssertTemplate("{%for item in array%}+{%else%}-{%endfor%}",   "-", ["array": nil])
	}
	
	func test_limiting() {
		let assigns = ["array": [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]]
		XCTAssertTemplate("{%for i in array limit:2 %}{{ i }}{%endfor%}", "12", assigns)
		XCTAssertTemplate("{%for i in array limit:4 %}{{ i }}{%endfor%}", "1234", assigns)
		XCTAssertTemplate("{%for i in array limit:4 offset:2 %}{{ i }}{%endfor%}", "3456", assigns)
		XCTAssertTemplate("{%for i in array limit: 4 offset: 2 %}{{ i }}{%endfor%}", "3456", assigns)
	}
	
	func test_for_with_break() {
		let assigns = ["array": ["items": [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]]]
		
//		XCTAssertTemplate("{% for i in array.items %}{% break %}{% endfor %}", "", assigns)
//		XCTAssertTemplate("{% for i in array.items %}{{ i }}{% break %}{% endfor %}", "1", assigns)
//		XCTAssertTemplate("{% for i in array.items %}{% break %}{{ i }}{% endfor %}", "", assigns)
		XCTAssertTemplate("{% for i in array.items %}{{ i }}{% if i > 3 %}{% break %}{% endif %}{% endfor %}", "1234", assigns)
		
		// tests to ensure it only breaks out of the local for loop and not all of them.
//		XCTAssertTemplate("{% for item in array %}{% for i in item %}{% if i == 1 %}{% break %}{% endif %}{{ i }}{% endfor %}{% endfor %}", "3456", ["array":  [[1, 2], [3, 4], [5, 6]]])
		
		// test break does nothing when unreached
//		XCTAssertTemplate("{% for i in array.items %}{% if i == 9999 %}{% break %}{% endif %}{{ i }}{% endfor %}", "12345", ["array":  ["items":  [1, 2, 3, 4, 5]]])
	}

	func test_for_with_continue() {
		let assigns = ["array":  ["items":  [1, 2, 3, 4, 5]]]
		
		XCTAssertTemplate("{% for i in array.items %}{% continue %}{% endfor %}", "", assigns)
		XCTAssertTemplate("{% for i in array.items %}{{ i }}{% continue %}{% endfor %}", "12345", assigns)
		XCTAssertTemplate("{% for i in array.items %}{% continue %}{{ i }}{% endfor %}", "", assigns)
		XCTAssertTemplate("{% for i in array.items %}{% if i > 3 %}{% continue %}{% endif %}{{ i }}{% endfor %}", "123", assigns)
		XCTAssertTemplate("{% for i in array.items %}{% if i == 3 %}{% continue %}{% else %}{{ i }}{% endif %}{% endfor %}", "1245", assigns)
		
		// tests to ensure it only continues the local for loop and not all of them.
		XCTAssertTemplate("{% for item in array %}{% for i in item %}{% if i == 1 %}{% continue %}{% endif %}{{ i }}{% endfor %}{% endfor %}", "23456", ["array":  [[1, 2], [3, 4], [5, 6]]])
		
		// test continue does nothing when unreached
		XCTAssertTemplate("{% for i in array.items %}{% if i == 9999 %}{% continue %}{% endif %}{{ i }}{% endfor %}", "12345", ["array":  ["items":  [1, 2, 3, 4, 5]]])
	}
}
