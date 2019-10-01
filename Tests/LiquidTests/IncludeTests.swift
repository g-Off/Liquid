//
//  IncludeTests.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-28.
//

import XCTest
@testable import Liquid

final class IncludeTests: XCTestCase {
	private final class TestFileSystem: FileSystem {
		func read(path: String) throws -> String {
			switch path {
			case "product":
				return "Product: {{ product.title }} "
			case "locale_variables":
				return "Locale: {{echo1}} {{echo2}}"
			case "variant":
				return "Variant: {{ variant.title }}"
			case "nested_template":
				return "{% include 'header' %} {% include 'body' %} {% include 'footer' %}"
			case "body":
				return "body {% include 'body_detail' %}"
			case "nested_product_template":
				return "Product: {{ nested_product_template.title }} {%include 'details'%} "
			case "recursively_nested_template":
				return "-{% include 'recursively_nested_template' %}"
			case "pick_a_source":
				return "from TestFileSystem"
			case "assignments":
				return "{% assign foo = 'bar' %}"
			case "break":
				return "{% break %}"
			default:
				return path
			}
		}
	}
	
	private final class CountingFileSystem: FileSystem {
		var count: Int = 0
		func read(path: String) throws -> String {
			defer { count += 1 }
			return "from CountingFileSystem"
		}
	}
	
	func test_include_tag_with() throws {
		XCTAssertTemplate("{% include 'product' with products[0] %}", "Product: Draft 151cm ", ["products": [["title": "Draft 151cm"], ["title": "Element 155cm"]]], fileSystem: TestFileSystem())
	}
	
	func test_include_tag_with_default_name() throws {
		XCTAssertTemplate("{% include 'product' %}", "Product: Draft 151cm ", ["product": ["title": "Draft 151cm"]], fileSystem: TestFileSystem())
	}
	
	func test_include_tag_for() throws {
		XCTAssertTemplate("{% include 'product' for products %}", "Product: Draft 151cm Product: Element 155cm ", ["products": [["title": "Draft 151cm"], ["title": "Element 155cm"]]], fileSystem: TestFileSystem())
	}
	
	func test_include_tag_with_local_variables() throws {
		XCTAssertTemplate("{% include 'locale_variables' echo1: 'test123' %}", "Locale: test123 ", fileSystem: TestFileSystem())
	}
	
	func test_include_tag_with_multiple_local_variables() throws {
		XCTAssertTemplate("{% include 'locale_variables' echo1: 'test123', echo2: 'test321' %}", "Locale: test123 test321", fileSystem: TestFileSystem())
	}
	
	func test_include_tag_with_multiple_local_variables_from_context() throws {
		XCTAssertTemplate(
			"{% include 'locale_variables' echo1: echo1, echo2: more_echos.echo2 %}",
			"Locale: test123 test321",
			["echo1": "test123", "more_echos": ["echo2": "test321"]],
			fileSystem: TestFileSystem()
		)
	}
	
	func test_included_templates_assigns_variables() throws {
		XCTAssertTemplate("{% include 'assignments' %}{{ foo }}", "bar", fileSystem: TestFileSystem())
	}
	
	func test_nested_include_tag() throws {
		XCTAssertTemplate("{% include 'body' %}", "body body_detail", fileSystem: TestFileSystem())
		XCTAssertTemplate("{% include 'nested_template' %}", "header body body_detail footer", fileSystem: TestFileSystem())
	}
	
	func test_nested_include_with_variable() throws {
		XCTAssertTemplate("{% include 'nested_product_template' with product %}", "Product: Draft 151cm details ", ["product": ["title": "Draft 151cm"]], fileSystem: TestFileSystem())
		XCTAssertTemplate("{% include 'nested_product_template' for products %}", "Product: Draft 151cm details Product: Element 155cm details ", ["products": [["title": "Draft 151cm"], ["title": "Element 155cm"]]], fileSystem: TestFileSystem())
	}
	
//	func test_recursively_included_template_does_not_produce_endless_loop() throws {
//		infinite_file_system = Class.new do
//		func read_template_file(template_path)() throws {
//			"-{% include 'loop' %}"
//		}
//		end
//
//		Liquid::Template.file_system = infinite_file_system.new
//
//		assert_raises(Liquid::StackLevelError) do
//		Template.parse("{% include 'loop' %}").render!
//		end
//	}
	
	func test_dynamically_choosen_template() throws {
		XCTAssertTemplate("{% include template %}", "Test123", ["template": "Test123"], fileSystem: TestFileSystem())
		XCTAssertTemplate("{% include template %}", "Test321", ["template": "Test321"], fileSystem: TestFileSystem())
		XCTAssertTemplate("{% include template for product %}", "Product: Draft 151cm ", ["template": "product", "product": ["title": "Draft 151cm"]], fileSystem: TestFileSystem())
	}
	
	func test_include_tag_caches_second_read_of_same_partial() throws {
		let fileSystem = CountingFileSystem()
		XCTAssertTemplate("{% include 'pick_a_source' %}{% include 'pick_a_source' %}", "from CountingFileSystemfrom CountingFileSystem", fileSystem: fileSystem)
		XCTAssertEqual(fileSystem.count, 1)
	}
	
	func test_include_tag_doesnt_cache_partials_across_renders() throws {
		let fileSystem = CountingFileSystem()
		XCTAssertTemplate("{% include 'pick_a_source' %}", "from CountingFileSystem", fileSystem: fileSystem)
		XCTAssertEqual(fileSystem.count, 1)
		
		XCTAssertTemplate("{% include 'pick_a_source' %}", "from CountingFileSystem", fileSystem: fileSystem)
		XCTAssertEqual(fileSystem.count, 2)
	}
	
	func test_include_tag_within_if_statement() throws {
		XCTAssertTemplate("{% if true %}{% include 'foo_if_true' %}{% endif %}", "foo_if_true", fileSystem: TestFileSystem())
	}
	
	func test_render_raise_argument_error_when_template_is_undefined() throws {
		let undefinedVariableTemplate = Template(source: "{% include undefined_variable %}", fileSystem: TestFileSystem())
		XCTAssertNoThrow(try undefinedVariableTemplate.parse())
		XCTAssertThrowsError(try undefinedVariableTemplate.render())
		
		let nilTemplate = Template(source: "{% include nil %}", fileSystem: TestFileSystem())
		XCTAssertNoThrow(try nilTemplate.parse())
		XCTAssertThrowsError(try nilTemplate.render())
	}
	
	func test_including_via_variable_value() throws {
		XCTAssertTemplate("{% assign page = 'pick_a_source' %}{% include page %}", "from TestFileSystem", fileSystem: TestFileSystem())
		XCTAssertTemplate("{% assign page = 'product' %}{% include page %}", "Product: Draft 151cm ", ["product": ["title": "Draft 151cm"]], fileSystem: TestFileSystem())
		XCTAssertTemplate("{% assign page = 'product' %}{% include page for foo %}", "Product: Draft 151cm ", ["foo": ["title": "Draft 151cm"]], fileSystem: TestFileSystem())
	}
	
	func test_break_through_include() throws {
		XCTAssertTemplate("{% for i in (1..3) %}{{ i }}{% break %}{{ i }}{% endfor %}", "1", fileSystem: TestFileSystem())
		XCTAssertTemplate("{% for i in (1..3) %}{{ i }}{% include 'break' %}{{ i }}{% endfor %}", "1", fileSystem: TestFileSystem())
	}
}
