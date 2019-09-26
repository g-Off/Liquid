//
//  File.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-16.
//

import Foundation

extension Decimal {
    var intValue: Int {
		return NSDecimalNumber(decimal: self).intValue
	}
	
	var doubleValue: Double {
		return NSDecimalNumber(decimal: self).doubleValue
	}
	
	func round(scale: Int = 0) -> Decimal {
		var input: Decimal = self
		var output: Decimal = 0
		NSDecimalRound(&output, &input, scale, .plain)
		return output
	}
}
