//
//  FileSystem.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-28.
//

import Foundation

public protocol FileSystem {
	func read(path: String) throws -> String
}

struct LocalFileSystem: FileSystem {
	let baseURL: URL
	
	init(baseURL: URL) {
		self.baseURL = baseURL
	}
	
	func read(path: String) throws -> String {
		let fileURL = try templateURL(for: path)
		return try String(contentsOf: fileURL)
	}
	
	private func templateURL(for path: String) throws -> URL {
		var components = path.components(separatedBy: "/")
		guard !components.isEmpty else {
			throw FileSystemError(reason: "")
		}
		let filename = "_\(components.popLast()!).liquid"
		components.append(filename)
		let transformedPath = components.joined(separator: "/")
		return baseURL.appendingPathComponent(transformedPath)
	}
}

struct BlankFileSystem: FileSystem {
	func read(path: String) throws -> String {
		throw FileSystemError(reason: "This liquid context does not allow includes.")
	}
}

struct FileSystemError: Error {
	let reason: String
}
