//
//  XCTestCase+Extensions.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-09.
//

import XCTest
@testable import Liquid

func XCTAssertTemplate(_ templateString: String, _ expression2: String, _ values: [String: Any?] = [:], fileSystem: FileSystem = BlankFileSystem(), filters: [String: FilterFunc]? = nil, _ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) {
	let template = Template(source: templateString, fileSystem: fileSystem)
	filters?.forEach({ template.registerFilter(name: $0, filter: $1)})
	
	XCTAssertNoThrow(try template.parse(), message(), file: file, line: line)
	do {
		let result = try template.render(values: values)
		XCTAssertEqual(result, expression2, message(), file: file, line: line)
	} catch {
		XCTFail(error.localizedDescription, file: file, line: line)
	}
}
