//
//  ContentView.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 29.08.2021.
//

import SwiftUI
import Combine

struct RootView: View {
	@StateObject var calendarViewModel: CalendarViewModel

    var body: some View {
		CalendarView(calendarViewModel: calendarViewModel)
			.onAppear { calendarViewModel.makeInitialData() }
    }
}

struct CalendarView: View {
	@ObservedObject var calendarViewModel: CalendarViewModel

	@Namespace var currentMonthID

	var body: some View {
		NavigationView {
			ScrollViewReader { proxy in
				List {
					ForEach(calendarViewModel.data) { container in
						YearView(currentMonthID: currentMonthID, data: container.value) { month, week, day in
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
				.navigationBarTitleDisplayMode(.inline)
				.toolbar {
					ToolbarItem(placement: .principal) {
						HStack(alignment: .center, spacing: 8) {
							ForEach(calendarViewModel.headerData.indices) {
								Text("\(calendarViewModel.localizedString(for: calendarViewModel.headerData[$0]))")
								if $0 != calendarViewModel.headerData.indices.last {
									Spacer()
								}
							}
						}
					}
				}
			}
		}
		.navigationViewStyle(StackNavigationViewStyle())
	}
}

struct YearView: View {
	let currentMonthID: Namespace.ID

	let data: YearData

	let dayTapAction: (Int, Int, Int) -> Void

	let onMonthAppear: (MonthData) -> Void

	var body: some View {
		Section {
			Text("\(data.number)")
				.bold()
				.font(.title)
			ForEach(data.months) { container in
				Text(container.value.name)
					.bold()
					.foregroundColor(Color.red)
					.font(.title2)
					.id(container.isCurrent ? currentMonthID : nil)
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

struct YearData: Hashable {
	let number: Int
	var months: [Identified<MonthData>]
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

struct MonthData: Hashable {
	let month: Month
	let name: String
	var weeks: [Identified<WeekData>]
	let isCurrent: Bool
}

struct WeekView: View {
	let data: WeekData
	let dayTapAction: (UUID) -> Void

	var body: some View {
		HStack(alignment: .center, spacing: 8) {
			if data.days.first?.value.day.dayOfWeek != .monday {
				Spacer()
			}
			ForEach(data.days) { element in
				DayView(data: element.value) {
					dayTapAction(element.id)
				}
				.frame(width: 44, height: 44)
			}
		}
	}
}

struct WeekData: Hashable {
	var days: [Identified<DayData>]
	let isCurrent: Bool
}

struct DayView: View {
	let data: DayData
	let tapAction: () -> Void

	var body: some View {
		GeometryReader { proxy in
			Button(action: tapAction) {
				Text(String(data.day.number))
					.frame(maxWidth: .infinity, maxHeight: .infinity)
			}
			.padding(8)
			.background(data.isSelected ? Color.red : .clear)
			.foregroundColor(data.isSelected ? .white : .black)
			.cornerRadius(proxy.size.width)
		}
	}
}

struct DayData: Hashable {
	let day: Day
	var isSelected: Bool
}
