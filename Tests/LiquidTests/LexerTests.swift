//
//  LexerTests.swift
//  
//
//  Created by Geoffrey Foster on 2019-08-29.
//

import XCTest
@testable import Liquid

final class LexerTests: XCTestCase {
	func testTextToken() {
		let tokenizer = Tokenizer(source: "hello {{ name }}, how are you?")
		XCTAssertEqual(tokenizer.tokens, [.text(value: "hello "), .variable(value: "name"), .text(value: ", how are you?")])
	}
}

