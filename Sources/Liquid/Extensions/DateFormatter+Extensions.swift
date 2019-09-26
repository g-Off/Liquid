//
//  File.swift
//  
//
//  Created by Geoffrey Foster on 2019-09-18.
//

import Foundation

extension DateFormatter {
	convenience init(strfFormatString: String) {
		self.init()
		self.dateFormat = dateFormatString(from: strfFormatString)
	}
}

// %a - The abbreviated weekday name (``Sun'')
// %A - The  full  weekday  name (``Sunday'')
// %b - The abbreviated month name (``Jan'')
// %B - The  full  month  name (``January'')
// %c - The preferred local date and time representation
// %d - Day of the month (01..31)
// %H - Hour of the day, 24-hour clock (00..23)
// %I - Hour of the day, 12-hour clock (01..12)
// %j - Day of the year (001..366)
// %m - Month of the year (01..12)
// %M - Minute of the hour (00..59)
// %p - Meridian indicator (``AM''  or  ``PM'')
// %s - Number of seconds since 1970-01-01 00:00:00 UTC.
// %S - Second of the minute (00..60)
// %U - Week  number  of the current year,
//         starting with the first Sunday as the first
//         day of the first week (00..53)
// %W - Week  number  of the current year,
//         starting with the first Monday as the first
//         day of the first week (00..53)
// %w - Day of the week (Sunday is 0, 0..6)
// %x - Preferred representation for the date alone, no time
// %X - Preferred representation for the time alone, no date
// %y - Year without a century (00..99)
// %Y - Year with century
// %Z - Time zone name
// %% - Literal ``%'' character
enum STRFTokens: Character {
	case abbreviatedWeekdayName = "a"
	case fullWeekdayName = "A"
	case abbreviatedMonthName = "b"
	case fullMonthName = "B"
	case preferredLocalDateAndTime = "c"
	case dayOfMonth = "d"
	case hourOfDay24 = "H"
	case hourOfDay12 = "I"
	case dayOfYear = "j"
	case monthOfYear = "m"
	case minuteOfHour = "M"
	case meridian = "p"
	case secondsSince1970 = "s"
	case secondOfMinute = "S"
	case weekNumberOfYearFirstSunday = "U"
	case weekNumberOfYearFirstMonday = "W"
	case dayOfWeek = "w"
	case preferredDateRepresentation = "x"
	case preferredTimeRepresentation = "X"
	case yearWithoutCentury = "y"
	case yearWithCentury = "Y"
	case timeZoneName = "Z"
	case literalPercent = "%"
	
	func toFormatStringRepresentation() -> String {
		switch self {
		case .abbreviatedWeekdayName:
			return "EEEE"
		case .fullWeekdayName:
			return "E"
		case .abbreviatedMonthName:
			return "MMM"
		case .fullMonthName:
			return "MMMM"
		case .preferredLocalDateAndTime:
			return ""
		case .dayOfMonth:
			return "dd"
		case .hourOfDay24:
			return "HH"
		case .hourOfDay12:
			return "hh"
		case .dayOfYear:
			return "DDD"
		case .monthOfYear:
			return "MM"
		case .minuteOfHour:
			return "mm"
		case .meridian:
			return "a"
		case .secondsSince1970:
			return ""
		case .secondOfMinute:
			return "ss"
		case .weekNumberOfYearFirstSunday:
			return "ww"
		case .weekNumberOfYearFirstMonday:
			return "ww" // TODO: adjust U and W for sun/mon week start days
		case .dayOfWeek:
			return "F"
		case .preferredDateRepresentation:
			return ""
		case .preferredTimeRepresentation:
			return ""
		case .yearWithoutCentury:
			return "yy"
		case .yearWithCentury:
			return "y"
		case .timeZoneName:
			return "zzz"
		case .literalPercent:
			return "%"
		}
	}
}
func dateFormatString(from inputString: String) -> String {
	var format = ""
	let scanner = Scanner(string: inputString)
	while let c = scanner.liquid_scanCharacter() {
		switch c {
		case "%":
			guard let next = scanner.liquid_scanCharacter() else { fatalError() }
			guard let token = STRFTokens(rawValue: next) else { fatalError() }
			format.append(token.toFormatStringRepresentation())
		default:
			if let _ = STRFTokens(rawValue: c) {
				format.append("'\(c)'")
			} else {
				format.append(c)
			}
		}
	}
	return format
}
