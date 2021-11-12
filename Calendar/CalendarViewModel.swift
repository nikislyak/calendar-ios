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

	var headerData: [DayOfWeek] {
		manager.weekDays
	}

	@Published var years = [Identified<YearData>]()

	var currentYearID: UUID?

	init(manager: CalendarComponentsManager) {
		self.manager = manager
	}

	var todayButtonTapPublisher: AnyPublisher<Void, Never> {
		todayButtonTapSubject.eraseToAnyPublisher()
	}

	private let todayButtonTapSubject = PassthroughSubject<Void, Never>()

	func onTodayButtonTap() {
		todayButtonTapSubject.send()
	}

	private func makeYearData(from days: [Day]) -> [Identified<YearData>] {
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
			.init(
				days: makeDaysData(from: days),
				isCurrent: days.contains { $0.isCurrent },
				isFirstInMonth: sameMonthDays.first?.weekOfMonth == days.first?.weekOfMonth
			)
		}
	}

	private func makeDaysData<C: Collection>(from sameWeekDays: C) -> [Identified<DayData>] where C.Element == Day {
		sameWeekDays.map { .init(id: .init(), value: .init(day: $0, isSelected: false) {}) }
	}

	func makeInitialData() {
		manager
			.makeCurrentYear()
			.receive(on: queue)
			.map { [unowned self] currentYear -> AnyPublisher<([Identified<YearData>], [Identified<YearData>], [Identified<YearData>]), Never> in
				let year = currentYear.first!.year
				return Publishers
					.Zip(
						manager.makeDays(for: year - 3 ... year - 1),
						manager.makeDays(for: year + 1 ... year + 3)
					)
					.map { [unowned self] in
						(makeYearData(from: $0), makeYearData(from: currentYear), makeYearData(from: $1))
					}
					.eraseToAnyPublisher()
			}
			.switchToLatest()
			.receive(on: DispatchQueue.main)
			.handleEvents(receiveOutput: { [unowned self] _, currentYear, _ in currentYearID = currentYear.first?.id })
			.map { $0 + $1 + $2 }
			.assign(to: &$years)
	}

	func localizedString(for weekDay: DayOfWeek) -> String {
		manager.localizedString(for: weekDay)
	}

	func localizedString(for month: Month) -> String {
		manager.localizedString(for: month)
	}

	func onAppear(of year: YearData) {
		Just((year, years))
			.map { year, data -> AnyPublisher<[Identified<YearData>], Never> in
				if year.number == data.first?.number {
					if data.dropFirst().first == nil {
						return Publishers
							.Zip(
								manager.makeDays(for: year.number - 3 ... year.number - 1),
								manager.makeDays(for: year.number + 1 ... year.number + 3)
							)
							.receive(on: queue)
							.map { [unowned self] in makeYearData(from: $0) + data + makeYearData(from: $1) }
							.eraseToAnyPublisher()
					} else {
						return manager
							.makeDays(for: year.number - 3 ... year.number - 1)
							.receive(on: queue)
							.map { [unowned self] in makeYearData(from: $0) + data }
							.eraseToAnyPublisher()
					}
				} else if year.number == data.last?.number {
					return manager
						.makeDays(for: year.number + 1 ... year.number + 3)
						.receive(on: queue)
						.map { [unowned self] in data + makeYearData(from: $0) }
						.eraseToAnyPublisher()
				} else {
					return Empty().eraseToAnyPublisher()
				}
			}
			.switchToLatest()
			.receive(on: DispatchQueue.main)
			.assign(to: &$years)
	}

	func onAppear(of month: MonthData) {
		guard let year = month.weeks.first?.days.first?.day.year,
			  month.month == .december || month.month == .january else { return }
		Just((year, years))
			.map { year, data -> AnyPublisher<[Identified<YearData>], Never> in
				if month.month == .december, year == data.last?.number {
					return manager
						.makeDays(for: year + 1 ... year + 3)
						.receive(on: queue)
						.map { [unowned self] in data + makeYearData(from: $0) }
						.eraseToAnyPublisher()
				} else if month.month == .january, year == data.first?.number {
					return manager
						.makeDays(for: year - 3 ... year - 1)
						.receive(on: queue)
						.map { [unowned self] in makeYearData(from: $0) + data }
						.eraseToAnyPublisher()
				} else {
					return Empty().eraseToAnyPublisher()
				}
			}
			.switchToLatest()
			.receive(on: DispatchQueue.main)
			.assign(to: &$years)
	}
}
