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
		let days = manager.makeCurrentMonth()
		data = makeYearData(from: days)
	}

	func localizedString(for weekDay: DayOfWeek) -> String {
		manager.localizedString(for: weekDay)
	}

	func localizedString(for month: Month) -> String {
		manager.localizedString(for: month)
	}
}

struct WhileSequence<SubSequence: Sequence>: Sequence {
	private let sequence: SubSequence
	private let predicate: (SubSequence.Element, SubSequence.Element) -> Bool

	init(sequence: SubSequence, predicate: @escaping (SubSequence.Element, SubSequence.Element) -> Bool) {
		self.sequence = sequence
		self.predicate = predicate
	}

	struct Iterator<SubSequence: Sequence>: IteratorProtocol {
		private let sequence: SubSequence
		private let predicate: (SubSequence.Element, SubSequence.Element) -> Bool

		init(sequence: SubSequence, predicate: @escaping (SubSequence.Element, SubSequence.Element) -> Bool) {
			self.sequence = sequence
			self.predicate = predicate
		}

		private var previous: SubSequence.Element?
		private var iterator: SubSequence.Iterator?

		mutating func next() -> SubSequence.Element? {
			if previous == nil {
				var iterator = sequence.makeIterator()
				previous = iterator.next()
				self.iterator = iterator
				return previous
			} else if let previous = previous,
					  let next = iterator?.next(),
					  predicate(previous, next) {
				self.previous = next
				return next
			} else {
				return nil
			}
		}
	}

	func makeIterator() -> Iterator<SubSequence> {
		Iterator(sequence: sequence, predicate: predicate)
	}
}

extension Sequence {
	func takeWhile(predicate: @escaping (Element, Element) -> Bool) -> WhileSequence<Self> {
		WhileSequence(sequence: self, predicate: predicate)
	}
}
