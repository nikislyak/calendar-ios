//
//  WeekView.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 06.09.2021.
//

import Foundation
import SwiftUI

struct WeekView: View {
	@Environment(\.calendar) private var calendar

	@Binding var firstWeekDayFrame: CGRect?

	let parentID: UUID?
	let data: WeekData
	let dayTapAction: (UUID) -> Void

	var body: some View {
		GeometryReader { proxy in
			HStack(alignment: .center, spacing: 8) {
				if data.days.first?.value.day.dayOfWeek.rawValue != calendar.firstWeekday {
					Spacer()
				}
				ForEach(data.days) { day in
					GeometryReader { dayProxy in
						DayView(data: day.value) {
							dayTapAction(day.id)
						}
						.onAppear {
							if let parentID = parentID, day == data.days.first {
								firstWeekDayFrame = dayProxy.frame(in: .named(parentID))
							}
						}
					}
					.frame(width: (proxy.size.width - 48) / 7)
				}
			}
		}
	}
}

struct WeekData: Hashable {
	var days: [Identified<DayData>]
	let isCurrent: Bool
}
