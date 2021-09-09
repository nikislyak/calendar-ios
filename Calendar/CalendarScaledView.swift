//
//  CalendarScaledView.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 06.09.2021.
//

import Foundation
import SwiftUI

struct CalendarScaledView: View {
	@Environment(\.colorScheme) private var colorScheme
	@ObservedObject var calendarViewModel: CalendarViewModel

	@State private var openedMonth: UUID?

	var body: some View {
		GeometryReader { proxy in
			ScrollViewReader { scrollProxy in
				List {
					ForEach(calendarViewModel.data) { year in
						Section {
							Text(String(year.number))
								.foregroundColor(year.isCurrent ? .accentColor : .primary)
								.font(.title)
								.bold()

							LazyVGrid(
								columns: .init(
									repeating: .init(
										.flexible(maximum: (proxy.size.width - 32) / 3),
										spacing: 16, alignment: .top
									),
									count: 3
								),
								alignment: .center,
								spacing: 24,
								pinnedViews: []
							) {
								ForEach(year.months) { month in
									ZStack {
										NavigationLink(
											destination: CalendarView(
												calendarViewModel: calendarViewModel,
												initialMonth: month.id
											),
											tag: month.id,
											selection: $openedMonth
										) {
											EmptyView()
										}

										CompactMonthView(width: (proxy.size.width - 32 - 32) / 3, monthData: month) {
											openedMonth = $0
										}
										.background(colorScheme == .light ? Color.white : .black)
										.onAppear { calendarViewModel.onAppear(of: month.value) }
									}
								}
							}
						}
						.buttonStyle(PlainButtonStyle())
					}
				}
				.toolbar {
					ToolbarItem(placement: .bottomBar) {
						Button(action: {
							scrollProxy.scrollTo(calendarViewModel.data.first { $0.isCurrent }?.id, anchor: .top)
						}) {
							Text(LocalizedStringKey("bottomBar.today"), tableName: "Localization")
						}
					}
				}
			}
			.navigationBarTitleDisplayMode(.inline)
		}
		.listStyle(PlainListStyle())
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				HStack {
					Button(action: {}) {
						Image(systemName: "magnifyingglass")
					}
				}
			}
		}
	}
}

struct CompactMonthView: View {
	@Environment(\.colorScheme) private var colorScheme
	@Environment(\.calendar) private var calendar

	let width: CGFloat
	let monthData: Identified<MonthData>
	let tapAction: (UUID) -> Void

	private let daysSpacing: CGFloat = 3

	var body: some View {
		Button(action: { tapAction(monthData.id) }) {
			VStack(alignment: .leading, spacing: 4) {
				Text(monthData.name)
					.bold()
					.font(.title3)
					.foregroundColor(monthData.isCurrent ? .accentColor : .primary)

				ForEach(monthData.weeks) { week in
					HStack(spacing: daysSpacing) {
						if week.value.days.first?.day.dayOfWeek.rawValue != calendar.firstWeekday {
							Spacer()
						}
						ForEach(week.days) { day in
							Text(String(day.day.number))
								.font(.system(size: 10))
								.foregroundColor(dayNumberColor(day: day.value))
								.fontWeight(.semibold)
								.kerning(-0.5)
								.frame(width: dayWidth)
								.background(
									(day.day.isCurrent ? Color.accentColor : .clear)
										.cornerRadius(dayWidth)
								)
						}
					}
				}
			}
		}
	}

	private func dayNumberColor(day: DayData) -> Color {
		day.day.isCurrent ? colorScheme == .light ? .white : .primary : colorScheme == .light ? .black : .primary
	}

	private var dayWidth: CGFloat {
		(width - CGFloat(6) * daysSpacing) / 7
	}
}
