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

	let year: YearData

	var body: some View {
		ForEach(year.months) { month in
			MonthView(month: month)
				.onAppear {
					calendarViewModel.onAppear(of: month.value)
				}
		}
	}
}
