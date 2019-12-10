//
//  CommentTests.swift
//  
//
//  Created by Katrina Butler on 2019-12-10.
//

import Foundation

import XCTest
@testable import Liquid

final class CommentTests: XCTestCase {
	func test_comment() {
		XCTAssertTemplate("Before {% comment %} This should be ignored!! {% endcomment %} after", "Before  after")
	}
}
