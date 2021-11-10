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

struct WeekLayoutPreferenceKey: PreferenceKey {
	typealias Value = [UUID: [UUID: Anchor<CGRect>]]

	static let defaultValue: Value = [:]

	static func reduce(value: inout Value, nextValue: () -> Value) {
		value.merge(nextValue()) { $0.merging($1) { $1 } }
	}
}

struct WeekView: View {
	@Environment(\.calendar) private var calendar

	let week: Identified<WeekData>

	private let spacing: CGFloat = 8

	var body: some View {
		HStack(spacing: spacing) {
			if week.days.first?.day.dayOfWeek.rawValue != calendar.firstWeekday {
				ForEach(0 ..< 7 - week.days.count) { _ in
					Color.clear
				}
			}
			ForEach(week.days) { day in
				DayView(day: day)
					.anchorPreference(
						key: WeekLayoutPreferenceKey.self,
						value: .bounds
					) { anchor in
						[week.id: [day.id: anchor]]
					}
			}
			if week.days.last?.day.dayOfWeek.rawValue != (calendar.firstWeekday + 6)
				.quotientAndRemainder(dividingBy: 7).remainder {
				ForEach(0 ..< 7 - week.days.count) { _ in
					Color.clear
				}
			}
		}
		.padding([.top, .bottom], 6)
		.padding([.leading, .trailing])
	}
}
