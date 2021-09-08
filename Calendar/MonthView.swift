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
	let data: MonthData

	let dayTapAction: (Int, Int) -> Void

	var body: some View {
		ForEach(data.weeks) { container in
			WeekView(data: container.value) { id in
				for week in data.weeks.enumerated() {
					if let index = week.element.days.firstIndex(where: { $0.id == id }) {
						dayTapAction(week.offset, index)
						return
					}
				}
			}
			.buttonStyle(PlainButtonStyle())
		}
	}
}
