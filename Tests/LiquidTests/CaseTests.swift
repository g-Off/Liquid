//
//  CaseTests.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-12.
//

import Foundation

import XCTest
@testable import Liquid

final class CaseTests: XCTestCase {
	
	func test_case() {
		XCTAssertTemplate("{% case condition %}{% when 1 %} its 1 {% when 2 %} its 2 {% endcase %}", " its 2 ", ["condition": 2])
		XCTAssertTemplate("{% case condition %}{% when 1 %} its 1 {% when 2 %} its 2 {% endcase %}", " its 1 ", ["condition": 1])
		XCTAssertTemplate("{% case condition %}{% when 1 %} its 1 {% when 2 %} its 2 {% endcase %}", "", ["condition": 3])
		XCTAssertTemplate(#"{% case condition %}{% when "string here" %} hit {% endcase %}"#, " hit ", ["condition": "string here"])
		XCTAssertTemplate(#"{% case condition %}{% when "string here" %} hit {% endcase %}"#, "", ["condition": "bad string here"])
	}
	
	func test_case_with_else() {
		XCTAssertTemplate("{% case condition %}{% when 5 %} hit {% else %} else {% endcase %}", " hit ", ["condition": 5])
		XCTAssertTemplate("{% case condition %}{% when 5 %} hit {% else %} else {% endcase %}", " else ", ["condition": 6])
		XCTAssertTemplate("{% case condition %} {% when 5 %} hit {% else %} else {% endcase %}", " else ", ["condition": 6])
	}
	
	func test_case_on_size() {
		XCTAssertTemplate("{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}",  "", ["a": []])
		XCTAssertTemplate("{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}", "1", ["a": [1]])
		XCTAssertTemplate("{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}", "2", ["a": [1, 1]])
		XCTAssertTemplate("{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}",  "", ["a": [1, 1, 1]])
		XCTAssertTemplate("{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}",  "", ["a": [1, 1, 1, 1]])
		XCTAssertTemplate("{% case a.size %}{% when 1 %}1{% when 2 %}2{% endcase %}",  "", ["a": [1, 1, 1, 1, 1]])
	}
	
	func test_case_on_size_with_else() {
		XCTAssertTemplate("{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}", "else", ["a": []])
		XCTAssertTemplate("{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}", "1", ["a": [1]])
		XCTAssertTemplate("{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}", "2", ["a": [1, 1]])
		XCTAssertTemplate("{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}", "else", ["a": [1, 1, 1]])
		XCTAssertTemplate("{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}", "else", ["a": [1, 1, 1, 1]])
		XCTAssertTemplate("{% case a.size %}{% when 1 %}1{% when 2 %}2{% else %}else{% endcase %}", "else", ["a": [1, 1, 1, 1, 1]])
	}
	
	func test_case_on_length_with_else() {
		XCTAssertTemplate("{% case a.empty? %}{% when true %}true{% when false %}false{% else %}else{% endcase %}", "else")
		XCTAssertTemplate("{% case false %}{% when true %}true{% when false %}false{% else %}else{% endcase %}", "false")
		XCTAssertTemplate("{% case true %}{% when true %}true{% when false %}false{% else %}else{% endcase %}", "true")
		XCTAssertTemplate("{% case NULL %}{% when true %}true{% when false %}false{% else %}else{% endcase %}", "else")
	}
	
	func test_assign_from_case() {
		let code = "{% case collection.handle %}{% when 'menswear-jackets' %}{% assign ptitle = 'menswear' %}{% when 'menswear-t-shirts' %}{% assign ptitle = 'menswear' %}{% else %}{% assign ptitle = 'womenswear' %}{% endcase %}{{ ptitle }}"
		XCTAssertTemplate(code, "menswear", ["collection": ["handle": "menswear-jackets"]])
		XCTAssertTemplate(code, "menswear", ["collection": ["handle": "menswear-t-shirts"]])
		XCTAssertTemplate(code, "womenswear", ["collection": ["handle": "x"]])
		XCTAssertTemplate(code, "womenswear", ["collection": ["handle": "y"]])
		XCTAssertTemplate(code, "womenswear", ["collection": ["handle": "z"]])
	}
	
	func test_case_when_or() {
		let code1 = "{% case condition %}{% when 1 or 2 or 3 %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}"
		XCTAssertTemplate(code1, " its 1 or 2 or 3 ", ["condition": 1])
		XCTAssertTemplate(code1, " its 1 or 2 or 3 ", ["condition": 2])
		XCTAssertTemplate(code1, " its 1 or 2 or 3 ", ["condition": 3])
		XCTAssertTemplate(code1, " its 4 ", ["condition": 4])
		XCTAssertTemplate(code1, "", ["condition": 5])
		
		let code2 = #"{% case condition %}{% when 1 or "string" or null %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}"#
		XCTAssertTemplate(code2, " its 1 or 2 or 3 ", ["condition": 1])
		XCTAssertTemplate(code2, " its 1 or 2 or 3 ", ["condition": "string"])
		XCTAssertTemplate(code2, " its 1 or 2 or 3 ", ["condition": nil])
		XCTAssertTemplate(code2, "", ["condition": "something else"])
	}
	
	func test_case_when_comma() {
		let code1 = "{% case condition %}{% when 1, 2, 3 %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}"
		XCTAssertTemplate(code1, " its 1 or 2 or 3 ", ["condition": 1])
		XCTAssertTemplate(code1, " its 1 or 2 or 3 ", ["condition": 2])
		XCTAssertTemplate(code1, " its 1 or 2 or 3 ", ["condition": 3])
		XCTAssertTemplate(code1, " its 4 ", ["condition": 4])
		XCTAssertTemplate(code1, "", ["condition": 5])
		
		let code2 = #"{% case condition %}{% when 1, "string", null %} its 1 or 2 or 3 {% when 4 %} its 4 {% endcase %}"#
		XCTAssertTemplate(code2, " its 1 or 2 or 3 ", ["condition": 1])
		XCTAssertTemplate(code2, " its 1 or 2 or 3 ", ["condition": "string"])
		XCTAssertTemplate(code2, " its 1 or 2 or 3 ", ["condition": nil])
		XCTAssertTemplate(code2, "", ["condition": "something else"])
	}
}
