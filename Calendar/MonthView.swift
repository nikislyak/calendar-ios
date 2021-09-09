//
//  MonthView.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 06.09.2021.
//

import Foundation
import SwiftUI

struct MonthData: Hashable {
	let month: Month
	let name: String
	var weeks: [Identified<WeekData>]
	let isCurrent: Bool
}

struct MonthView: View {
	@Environment(\.calendar) private var calendar

	let month: Identified<MonthData>

	let dayTapAction: (Int, Int) -> Void

	@State private var firstWeekdayFrame: CGRect?

	var body: some View {
		Group {
			GeometryReader {
				Text(calendar.shortStandaloneMonthSymbols[month.month.rawValue - 1].capitalized)
					.fontWeight(.medium)
					.foregroundColor(month.isCurrent ? .accentColor : .primary)
					.font(.title2)
					.position(x: firstWeekdayFrame?.midX ?? $0.size.width / 2, y: $0.size.height / 2)
			}

			ForEach(month.weeks) { week in
				WeekView(
					firstWeekDayFrame: $firstWeekdayFrame,
					parentID: week == month.weeks.first ? month.id : nil,
					data: week.value
				) { id in
					for week in month.weeks.enumerated() {
						if let index = week.element.days.firstIndex(where: { $0.id == id }) {
							dayTapAction(week.offset, index)
							return
						}
					}
				}
				.buttonStyle(PlainButtonStyle())
			}
		}
		.coordinateSpace(name: month.id)
	}
}
