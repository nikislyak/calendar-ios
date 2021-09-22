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

	@State private var preference: WeekStartPreferenceKey.Data?

	var body: some View {
		Group {
			GeometryReader { proxy in
				Text(calendar.shortStandaloneMonthSymbols[month.month.rawValue - 1].capitalized)
					.fontWeight(.medium)
					.foregroundColor(month.isCurrent ? .accentColor : .primary)
					.font(.title2)
					.position(
						x: preference.map { proxy[$0.rect] }?.midX ?? proxy.size.width / 2,
						y: proxy.size.height / 2
					)
			}

			ForEach(month.weeks) { week in
				WeekView(
					parentID: month.id,
					week: week.value
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
		.onPreferenceChange(WeekStartPreferenceKey.self) { value in
			value[month.id].map { preference = $0 }
		}
	}
}
