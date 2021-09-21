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
	let monthData: Identified<MonthData>
	let tapAction: (UUID) -> Void

	private let daysSpacing: CGFloat = 3

	var body: some View {
		Button(action: { tapAction(monthData.id) }) {
			VStack(alignment: .leading, spacing: 4) {
				Text(monthData.name)
					.bold()
					.font(.title3)
					.foregroundColor(monthData.isCurrent ? .accentColor : .primary)

				ForEach(monthData.weeks) { week in
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
								.background(
									(day.day.isCurrent ? Color.accentColor : .clear)
										.cornerRadius(dayWidth)
								)
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
