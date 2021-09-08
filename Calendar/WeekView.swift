//
//  WeekView.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 06.09.2021.
//

import Foundation
import SwiftUI

struct WeekView: View {
	let data: WeekData
	let dayTapAction: (UUID) -> Void

	var body: some View {
		GeometryReader { proxy in
			HStack(alignment: .center, spacing: 8) {
				if data.days.first?.value.day.dayOfWeek != .monday {
					Spacer()
				}
				ForEach(data.days) { element in
					DayView(data: element.value) {
						dayTapAction(element.id)
					}
					.frame(width: proxy.size.width / 8, height: 44)
				}
			}
		}
	}
}

struct WeekData: Hashable {
	var days: [Identified<DayData>]
	let isCurrent: Bool
}
