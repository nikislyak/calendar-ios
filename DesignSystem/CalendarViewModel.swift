//
//  CalendarViewModel.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 01.09.2021.
//

import Foundation

final class CalendarViewModel: ObservableObject {
	private let manager: CalendarComponentsManager

	var headerData: [DayOfWeek] {
		manager.weekDays
	}

	@Published var data = [Identified<YearData>]()

	init(manager: CalendarComponentsManager) {
		self.manager = manager
	}

	func makeYearData(from days: [Day]) -> [Identified<YearData>] {
		makeComponentsData(from: days, whileEqualBy: \.year) { days in
			.init(
				number: days.first!.year,
				months: makeMonthsData(from: days)
			)
		}
	}

	private func makeComponentsData<C: Collection, V: Equatable, Result>(
		from days: C,
		whileEqualBy keyPath: KeyPath<C.Element, V>,
		transform: ([C.Element]) -> Result
	) -> [Identified<Result>] where C.Element == Day {
		var days = AnyCollection(days)
		var result: [Identified<Result>] = []
		repeat {
			let componentDays = Array(days.takeWhile { $0[keyPath: keyPath] == $1[keyPath: keyPath] })
			days = AnyCollection(days.dropFirst(componentDays.count))
			result.append(
				.init(
					id: .init(),
					value: transform(componentDays)
				)
			)
		} while !days.isEmpty
		return result
	}

	private func makeMonthsData<C: Collection>(from sameYearDays: C) -> [Identified<MonthData>] where C.Element == Day {
		makeComponentsData(from: sameYearDays, whileEqualBy: \.month) { days in
			.init(
				month: days.first!.month,
				name: localizedString(for: days.first!.month),
				weeks: makeWeeksData(from: days)
			)
		}
	}

	private func makeWeeksData<C: Collection>(from sameMonthDays: C) -> [Identified<WeekData>] where C.Element == Day {
		makeComponentsData(from: sameMonthDays, whileEqualBy: \.weekOfMonth) { days in
			.init(days: makeDaysData(from: days))
		}
	}

	private func makeDaysData<C: Collection>(from sameWeekDays: C) -> [Identified<DayData>] where C.Element == Day {
		sameWeekDays.map { .init(id: .init(), value: .init(day: $0, isSelected: false)) }
	}

	func makeInitialData() {
		data = makeYearData(from: manager.makeCurrentYear())
	}

	func localizedString(for weekDay: DayOfWeek) -> String {
		manager.localizedString(for: weekDay)
	}

	func localizedString(for month: Month) -> String {
		manager.localizedString(for: month)
	}

	func onAppear(of month: MonthData) {
		guard let year = month.weeks.first?.days.first?.day.year else { return }
		func binarySearch(year: Int) -> Int? {
			var lowerIndex = 0
			var upperIndex = data.count - 1
			while true {
				let currentIndex = (lowerIndex + upperIndex) / 2
				if data[currentIndex].number == year {
					return currentIndex
				} else if lowerIndex > upperIndex {
					return nil
				} else {
					if data[currentIndex].number > year {
						upperIndex = currentIndex - 1
					} else {
						lowerIndex = currentIndex + 1
					}
				}
			}
		}
		if month.month == .december, binarySearch(year: year + 1) == nil {
			data.append(contentsOf: makeYearData(from: manager.makeDays(for: year + 1, direction: .forward)))
		} else if month.month == .january, binarySearch(year: year - 1) == nil {
//			data = makeYearData(from: manager.makeDays(for: year - 1, direction: .forward)) + data
		}
	}
}
