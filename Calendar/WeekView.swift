//
//  WeekView.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 06.09.2021.
//

import SwiftUI

struct WeekData: Hashable {
	var days: [Identified<DayData>]
	let isCurrent: Bool
	let isFirstInMonth: Bool
}

struct WeekStartPreferenceKey: PreferenceKey {
	struct Data: Equatable {
		static func == (lhs: WeekStartPreferenceKey.Data, rhs: WeekStartPreferenceKey.Data) -> Bool {
			lhs.monthID == rhs.monthID
		}

		let monthID: UUID
		let rect: Anchor<CGRect>
	}

	typealias Value = [UUID: Data]

	static var defaultValue: Value = [:]

	static func reduce(value: inout Value, nextValue: () -> Value) {
		value.merge(nextValue()) { $1 }
	}
}

struct WeekView: View {
	@Environment(\.calendar) private var calendar
	
	let monthID: UUID
	let week: WeekData
	
	private let spacing: CGFloat = 8
	
	var body: some View {
		GeometryReader { proxy in
			HStack(spacing: spacing) {
				if week.days.first?.day.dayOfWeek.rawValue != calendar.firstWeekday {
					Spacer()
				}
				ForEach(week.days) { day in
					DayView(data: day.value) {}
					.frame(width: max((proxy.size.width - spacing * 6) / 7, 0))
					.anchorPreference(
						key: WeekStartPreferenceKey.self,
						value: .bounds
					) { anchor in
						guard day == week.days.first, week.isFirstInMonth else { return [:] }
						return [monthID: WeekStartPreferenceKey.Data(monthID: monthID, rect: anchor)]
					}
				}
			}
		}
	}
}
