//
//  CalendarScaledView.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 06.09.2021.
//

import Foundation
import SwiftUI

struct CalendarScaledView: View {
	@ObservedObject var calendarViewModel: CalendarViewModel

	@State var openedMonth: UUID?

	var body: some View {
		List {
			ForEach(calendarViewModel.data) { year in
				Section {
					Text(String(year.number))
						.foregroundColor(year.isCurrent ? .red : .black)
						.font(.title)
						.bold()
					LazyVGrid(
						columns: .init(repeating: .init(.flexible(), alignment: .top), count: 3),
						alignment: .center,
						spacing: 24,
						pinnedViews: []
					) {
						ForEach(year.months) { month in
							ZStack {
								NavigationLink(
									destination: CalendarView(calendarViewModel: calendarViewModel,
															  initialMonth: month.id),
									tag: month.id,
									selection: $openedMonth
								) { EmptyView() }

								CompactMonthView(monthData: month) {
									openedMonth = $0
								}
								.background(Color.white)
								.onAppear { calendarViewModel.onAppear(of: month.value) }
							}
						}
					}
				}
				.buttonStyle(PlainButtonStyle())
			}
		}
		.navigationBarTitleDisplayMode(.inline)
	}
}

struct CompactMonthView: View {
	let monthData: Identified<MonthData>
	let tapAction: (UUID) -> Void

	var body: some View {
		Button(action: { tapAction(monthData.id) }) {
			VStack(alignment: .leading, spacing: 4) {
				Text(monthData.name)
					.bold()
					.font(.title3)
					.foregroundColor(monthData.isCurrent ? .red : .black)

				ForEach(monthData.weeks) { week in
					HStack {
						if week.value.days.first?.day.dayOfWeek != .monday {
							Spacer()
						}
						ForEach(week.days) { day in
							Text(String(day.day.number))
								.font(.system(size: 10))
								.fontWeight(.semibold)
								.kerning(-0.5)
								.frame(minWidth: 10, minHeight: 10)
						}
					}
				}
			}
		}
	}
}
