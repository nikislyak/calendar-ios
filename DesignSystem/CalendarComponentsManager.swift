//
//  CalendarComponentsManager.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 01.09.2021.
//

import Foundation

final class CalendarComponentsManager {
	let currentDate: Date
	let calendar: Calendar
	let weekDays = Array(DayOfWeek.allCases.dropFirst() + CollectionOfOne(.sunday))

	init(calendar: Calendar, currentDate: Date) {
		self.calendar = calendar
		self.currentDate = currentDate
	}

	func makeDays(for interval: DateInterval) -> [Day] {
		var dateComponents: [DateComponents] = []
		calendar.enumerateDates(startingAfter: calendar.startOfDay(for: interval.start),
								matching: DateComponents(hour: 0, minute: 0, second: 1),
								matchingPolicy: .nextTimePreservingSmallerComponents,
								repeatedTimePolicy: .first, direction: .forward) { date, isMatch, stop in
			if let date = date {
				if date <= interval.end {
					dateComponents.append(calendar.dateComponents([.day, .month, .year, .weekday, .weekOfMonth],
																  from: date))
				} else {
					stop = true
				}
			}
		}

		return dateComponents.map {
			Day(number: $0.day!,
				dayOfWeek: DayOfWeek(rawValue: $0.weekday!)!,
				weekOfMonth: $0.weekOfMonth!,
				month: Month(rawValue: $0.month!)!,
				year: $0.year!)
		}
	}

	func makeCurrentMonth() -> [Day] {
		guard let interval = currentMonthInterval() else { return [] }
		return makeDays(for: interval)
	}

	func currentMonthInterval() -> DateInterval? {
		calendar.dateInterval(of: .month, for: currentDate)
	}

	func localizedString(for weekDay: DayOfWeek) -> String {
		let symbols = calendar.shortWeekdaySymbols
		let orderedSymbols = Array(symbols.dropFirst() + CollectionOfOne(symbols.first!))
		let index = weekDays.firstIndex(of: weekDay)!
		return orderedSymbols[index]
	}

	func localizedString(for month: Month) -> String {
		let symbols = calendar.standaloneMonthSymbols
		let index = Month.allCases.firstIndex(of: month)!
		return symbols[index]
	}
}
