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

	@State private var yearForScrolling: UUID?

	var body: some View {
		GeometryReader { proxy in
			ScrollViewReader { scrollProxy in
				List {
					ForEach(calendarViewModel.years) { year in
						Section(
							header: Text(String(year.number))
								.foregroundColor(year.isCurrent ? .accentColor : .primary)
								.font(.title)
								.bold()
						) {
							LazyVGrid(
								columns: .init(
									repeating: .init(
										.fixed((proxy.size.width - 32 - 32) / 3),
										spacing: 16,
										alignment: .top
									),
									count: 3
								),
								alignment: .center,
								spacing: 24
							) {
								ForEach(year.months) { month in
									makeCompactMonthView(month: month, width: (proxy.size.width - 32 - 32) / 3)
								}
							}
						}
						.background(Color.clear)
						.buttonStyle(PlainButtonStyle())
					}
				}
				.listStyle(GroupedListStyle())
				.listRowBackground(Color.clear)
				.onChange(of: yearForScrolling) { id in
					if let id = id {
						withAnimation {
							scrollProxy.scrollTo(id, anchor: .top)
						}
						yearForScrolling = nil
					}
				}
				.toolbar {
					ToolbarItem(placement: .navigationBarTrailing) {
						HStack {
							Button {} label: {
								Image(systemName: "magnifyingglass")
							}
						}
					}
					ToolbarItem(placement: .bottomBar) {
						HStack {
							Spacer()
							Button {
								yearForScrolling = calendarViewModel.years.first { $0.isCurrent }?.id
							} label: {
								Text(LocalizedStringKey("bottomBar.today"), tableName: "Localization")
							}
							Spacer()
						}
					}
				}
				.navigationBarTitleDisplayMode(.inline)
			}
		}
	}

	@ViewBuilder
	private func makeCompactMonthView(month: Identified<MonthData>, width: CGFloat) -> some View {
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
			.hidden()

			CompactMonthView(width: width, monthData: month) {
				openedMonth = $0
			}
			.onAppear { calendarViewModel.onAppear(of: month.value) }
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
