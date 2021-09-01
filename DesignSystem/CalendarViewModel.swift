//
//  CalendarViewModel.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 01.09.2021.
//

import Foundation

final class CalendarViewModel: ObservableObject {
	private let manager: CalendarComponentsManager

	@Published var data = MonthData(month: .january, weeks: [])
	var headerData: [DayOfWeek] {
		manager.weekDays
	}

	init(manager: CalendarComponentsManager) {
		self.manager = manager
	}

	func makeInitialData() {
		let days = manager.makeCurrentMonth()
		data = .init(
			month: days.first?.month ?? .january,
			weeks: days.reduce(into: ([WeekData](), week: nil as Int?)) { acc, next in
				if acc.week == nil {
					acc.0.append(
						.init(days: [
							.init(
								id: .init(),
								value: .init(day: next, isSelected: false)
							)
						])
					)
					acc.week = 0
					return
				}
				guard let week = acc.week else { return }
				if !acc.0[week].days.isEmpty, next.dayOfWeek == .monday {
					acc.week? += 1
					acc.0.append(
						.init(days: [
							.init(
								id: .init(),
								value: .init(day: next, isSelected: false)
							)
						])
					)
					return
				}
				acc.0[week].days.append(
					.init(
						id: .init(),
						value: .init(day: next, isSelected: false)
					)
				)
			}
			.0
			.map { Identified(id: .init(), value: $0) }
		)
	}

	func localizedString(for weekDay: DayOfWeek) -> String {
		manager.localizedString(for: weekDay)
	}

	func localizedString(for month: Month) -> String {
		manager.localizedString(for: month)
	}
}
