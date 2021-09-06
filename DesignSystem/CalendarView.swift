//
//  CalendarView.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 06.09.2021.
//

import Foundation
import SwiftUI

struct CalendarView: View {
	@ObservedObject var calendarViewModel: CalendarViewModel

	let initialMonth: UUID

	var body: some View {
		ScrollViewReader { proxy in
			List {
				ForEach(calendarViewModel.data) { container in
					YearView(data: container.value) { month, week, day in
						calendarViewModel.data
							.firstIndex { $0.id == container.id }
							.map { year in
								withAnimation {
									calendarViewModel.data[year].months[month].weeks[week].days[day].isSelected.toggle()
								}
							}
					} onMonthAppear: { month in
						calendarViewModel.onAppear(of: month)
					}
				}
			}
			.onAppear { proxy.scrollTo(initialMonth, anchor: .top) }
			.toolbar {
				ToolbarItem(placement: .principal) {
					HStack(alignment: .center, spacing: 8) {
						ForEach(calendarViewModel.headerData.indices) {
							Text("\(calendarViewModel.localizedString(for: calendarViewModel.headerData[$0]))")
								.font(.subheadline)
							if $0 != calendarViewModel.headerData.indices.last {
								Spacer()
							}
						}
					}
				}
			}
		}
	}
}
