//
//  CaptureTests.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-14.
//

import Foundation

import XCTest
@testable import Liquid

final class CaptureTests: XCTestCase {
	func test_capture() {
		XCTAssertTemplate("{{ var2 }}{% capture var2 %}{{ var }} foo {% endcapture %}{{ var2 }}{{ var2 }}", "content foo content foo ", ["var": "content"])
	}

	func test_capture_detects_bad_syntax() throws {
		let template = Template(source: "{{ var2 }}{% capture %}{{ var }} foo {% endcapture %}{{ var2 }}{{ var2 }}")
		XCTAssertThrowsError(try template.parse())
	}
}
