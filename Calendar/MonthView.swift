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
	@EnvironmentObject private var layoutState: CalendarLayoutState

	let month: Identified<MonthData>

	var body: some View {
		GeometryReader { proxy in
			Text(calendar.shortStandaloneMonthSymbols[month.month.rawValue - 1].capitalized)
				.fontWeight(.medium)
				.foregroundColor(month.isCurrent ? .accentColor : .primary)
				.font(.title2)
				.position(
					x: monthNameOffset(proxy: proxy),
					y: proxy.size.height / 2
				)
		}
		ForEach(month.weeks) { week in
			WeekView(monthID: month.id, week: week.value)
		}
	}

	private func monthNameOffset(proxy: GeometryProxy) -> CGFloat {
		guard let anchor = layoutState.weekStarts[month.id] else { return proxy.size.width / 2 }
		return proxy[anchor].x
	}
}
