//
//  CompactMonthView.swift
//  Calendar
//
//  Created by OUT-Kislyakov-NP on 21.09.2021.
//

import SwiftUI

struct CompactMonthView: View {
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.calendar) private var calendar

	let width: CGFloat
	let month: Identified<MonthData>
	let tapAction: () -> Void

	private let daysSpacing: CGFloat = 0

	var body: some View {
		Button {
			tapAction()
		} label: {
			VStack(alignment: .leading, spacing: 0) {
				Text(month.name)
					.fontWeight(.semibold)
					.font(.title3)
					.foregroundColor(month.isCurrent ? .accentColor : .primary)

				VStack(alignment: .leading, spacing: 0) {
					ForEach(month.weeks) { week in
						HStack(spacing: daysSpacing) {
							if week.value.days.first?.day.dayOfWeek.rawValue != calendar.firstWeekday {
								Spacer()
							}
							ForEach(week.days) { day in
								Text(String(day.day.number))
									.font(.system(size: 10))
									.foregroundColor(dayNumberColor(day: day.value))
									.fontWeight(.semibold)
									.kerning(-0.5)
									.frame(width: dayWidth)
									.padding([.top, .bottom], 2)
									.background {
										Circle()
											.fill(day.day.isCurrent ? Color.accentColor : .clear)
									}
							}
						}
					}
				}
			}
		}
	}

	private func dayNumberColor(day: DayData) -> Color {
		day.day.isCurrent ? colorScheme == .light ? .white : .primary : colorScheme == .light ? .black : .primary
	}

	private var dayWidth: CGFloat {
		(width - CGFloat(6) * daysSpacing) / 7
	}
}
