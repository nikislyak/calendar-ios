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

	let dayTapAction: (Int, Int, Int) -> Void

	let onMonthAppear: (MonthData) -> Void

	var body: some View {
		Section {
			Text(String(data.number))
				.bold()
				.font(.title).foregroundColor(data.isCurrent ? .red : .black)

			ForEach(data.months) { container in
				Text(container.name)
					.fontWeight(.medium)
					.foregroundColor(container.isCurrent ? .red : .black)
					.font(.title2)
					.id(container.id)
				MonthView(data: container.value) { week, day in
					data.months.firstIndex { $0.id == container.id }.map { dayTapAction($0, week, day) }
				}
				.onAppear {
					onMonthAppear(container.value)
				}
			}
		}
	}
}
