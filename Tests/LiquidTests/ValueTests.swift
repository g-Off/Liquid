//
//  ValueTests.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-12.
//

import Foundation

import XCTest
@testable import Liquid

final class ValueTests: XCTestCase {
	func testComparable() {
		XCTAssertFalse(Value() < Value(1))
		XCTAssertFalse(Value() <= Value(1))
		XCTAssertFalse(Value() > Value(1))
		XCTAssertFalse(Value() >= Value(1))
		XCTAssertFalse(Value() == Value(1))
	}
}
