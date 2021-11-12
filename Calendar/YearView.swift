//
//  YearView.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 06.09.2021.
//

import Foundation
import SwiftUI

struct YearData: Hashable {
	let number: Int
	var months: [Identified<MonthData>]
	let isCurrent: Bool
}

struct YearView: View {
	@EnvironmentObject private var calendarViewModel: CalendarViewModel

	let year: Identified<YearData>
	@Binding var monthScrollAction: ScrollAction<UUID>?

	var body: some View {
		Section {
			ForEach(year.months) { month in
				MonthView(month: month)
			}
		}
		.onAppear {
			if monthScrollAction == nil {
				calendarViewModel.onAppear(of: year.value)
			}
		}
	}
}
