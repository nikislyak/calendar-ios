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
	@Environment(\.weekStarts) private var weekStarts

	let month: Identified<MonthData>

	var body: some View {
		Group {
			GeometryReader { proxy in
				Text(calendar.shortStandaloneMonthSymbols[month.month.rawValue - 1].capitalized)
					.fontWeight(.medium)
					.foregroundColor(month.isCurrent ? .accentColor : .primary)
					.font(.title2)
					.position(
						x: weekStarts[month.id].map { proxy[$0.center] }?.x ?? proxy.size.width / 2,
						y: proxy.size.height / 2
					)
			}
			ForEach(month.weeks) { week in
				WeekView(monthID: month.id, week: week.value)
					.buttonStyle(.plain)
			}
		}
	}
}
