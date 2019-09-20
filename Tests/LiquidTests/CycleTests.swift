//
//  CycleTests.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-12.
//

import Foundation

import XCTest
@testable import Liquid

final class CycleTests: XCTestCase {
	
	func test_cycle() {
		XCTAssertTemplate(#"{%cycle "one", "two"%}"#, "one")
		XCTAssertTemplate(#"{%cycle "one", "two"%} {%cycle "one", "two"%}"#, "one two")
		XCTAssertTemplate(#"{%cycle "", "two"%} {%cycle "", "two"%}"#, " two")
		XCTAssertTemplate(#"{%cycle "one", "two"%} {%cycle "one", "two"%} {%cycle "one", "two"%}"#, "one two one")
		XCTAssertTemplate(#"{%cycle "text-align: left", "text-align: right" %} {%cycle "text-align: left", "text-align: right"%}"#, "text-align: left text-align: right")
	}
	
	func test_multiple_cycles() {
		XCTAssertTemplate("{%cycle 1,2%} {%cycle 1,2%} {%cycle 1,2%} {%cycle 1,2,3%} {%cycle 1,2,3%} {%cycle 1,2,3%} {%cycle 1,2,3%}", "1 2 1 1 2 3 1")
	}
	
	func test_multiple_named_cycles() {
		XCTAssertTemplate(#"{%cycle 1: "one", "two" %} {%cycle 2: "one", "two" %} {%cycle 1: "one", "two" %} {%cycle 2: "one", "two" %} {%cycle 1: "one", "two" %} {%cycle 2: "one", "two" %}"#, "one one two two one one")
	}
	
	func test_multiple_named_cycles_with_names_from_context() {
		XCTAssertTemplate(#"{%cycle var1: "one", "two" %} {%cycle var2: "one", "two" %} {%cycle var1: "one", "two" %} {%cycle var2: "one", "two" %} {%cycle var1: "one", "two" %} {%cycle var2: "one", "two" %}"#, "one one two two one one", ["var1": 1, "var2": 2])
	}
}
