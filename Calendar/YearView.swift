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
	let data: YearData

	let onMonthAppear: (MonthData) -> Void
	
	var body: some View {
		Text(String(data.number))
			.bold()
			.font(.title)
			.foregroundColor(data.isCurrent ? .accentColor : .primary)
		ForEach(data.months) { container in
			MonthView(month: container)
				.onAppear {
					onMonthAppear(container.value)
				}
		}
	}
}
