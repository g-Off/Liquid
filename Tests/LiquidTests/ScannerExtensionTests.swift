//
//  ScannerExtensionTests.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-28.
//

import XCTest
@testable import Liquid

final class ScannerExtensionTests: XCTestCase {
	func testScanDecimalIgnores_e() throws {
		let parser = try Parser(string: "more_echos.echo2")
		XCTAssertEqual(parser.consume(.id), "more_echos")
		XCTAssertNotNil(parser.consume(.dot))
		XCTAssertEqual(parser.consume(.id), "echo2")
	}
	
	func testScanDecimal() throws {
		let parser = try Parser(string: "1.23")
		XCTAssertNil(parser.consume(.integer))
		XCTAssertEqual(parser.consume(.decimal), "1.23")
	}

	func testScanInt() throws {
		let parser = try Parser(string: "123")
		XCTAssertNil(parser.consume(.decimal))
		XCTAssertEqual(parser.consume(.integer), "123")
	}
}
