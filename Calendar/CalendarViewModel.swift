//
//  CalendarViewModel.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 01.09.2021.
//

import Foundation
import Combine

final class CalendarViewModel: ObservableObject {
	private let manager: CalendarComponentsManager

	private let queue = DispatchQueue(label: "ru.nikitakislyakov1.calendar", target: .global(qos: .userInteractive))

	private var bag = Set<AnyCancellable>()

	var headerData: [DayOfWeek] {
		manager.weekDays
	}

	@Published var years = [Identified<YearData>]()

	init(manager: CalendarComponentsManager) {
		self.manager = manager
	}

	func makeYearData(from days: [Day]) -> [Identified<YearData>] {
		makeComponentsData(from: days, whileEqualBy: \.year) { days in
			let months = makeMonthsData(from: days)
			return .init(
				number: days.first!.year,
				months: months,
				isCurrent: months.contains { $0.isCurrent }
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
			let weeks = makeWeeksData(from: days)
			return .init(
				month: days.first!.month,
				name: localizedString(for: days.first!.month),
				weeks: weeks,
				isCurrent: weeks.contains { $0.isCurrent }
			)
		}
	}

	private func makeWeeksData<C: Collection>(from sameMonthDays: C) -> [Identified<WeekData>] where C.Element == Day {
		makeComponentsData(from: sameMonthDays, whileEqualBy: \.weekOfMonth) { days in
			.init(days: makeDaysData(from: days), isCurrent: days.contains { $0.isCurrent })
		}
	}

	private func makeDaysData<C: Collection>(from sameWeekDays: C) -> [Identified<DayData>] where C.Element == Day {
		sameWeekDays.map { .init(id: .init(), value: .init(day: $0, isSelected: false)) }
	}

	func makeInitialData() {
		manager.makeCurrentYear()
			.receive(on: queue)
			.map { [unowned self] in makeYearData(from: $0) }
			.receive(on: DispatchQueue.main)
			.assign(to: &$years)
	}

	func localizedString(for weekDay: DayOfWeek) -> String {
		manager.localizedString(for: weekDay)
	}

	func localizedString(for month: Month) -> String {
		manager.localizedString(for: month)
	}

	func onAppear(of month: MonthData) {
		guard let year = month.weeks.first?.days.first?.day.year,
			  month.month == .december || month.month == .january else { return }
		Just((year, years))
			.receive(on: queue)
			.map { [manager] year, data -> AnyPublisher<[Identified<YearData>], Never> in
				if month.month == .december, data.binarySearchFirstIndex(where: {
					$0.number < year + 1
						? .orderedAscending
						: $0.number == year + 1
						? .orderedSame
						: .orderedDescending

				}) == nil {
					return manager.makeDays(for: year + 1)
						.map { [unowned self] in data + makeYearData(from: $0) }
						.eraseToAnyPublisher()
				} else if month.month == .january, data.binarySearchFirstIndex(where: {
					$0.number < year - 1
						? .orderedAscending
						: $0.number == year - 1
						? .orderedSame
						: .orderedDescending

				}) == nil {
//					data = makeYearData(from: manager.makeDays(for: year - 1)) + data
					return Empty().eraseToAnyPublisher()
				} else {
					return Empty().eraseToAnyPublisher()
				}
			}
			.switchToLatest()
			.receive(on: DispatchQueue.main)
			.assign(to: &$years)
	}
}
