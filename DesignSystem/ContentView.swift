//
//  ContentView.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 29.08.2021.
//

import SwiftUI

struct RootView: View {
	@StateObject var calendarViewModel: CalendarViewModel

    var body: some View {
		CalendarView(calendarViewModel: calendarViewModel)
			.onAppear { calendarViewModel.makeInitialData() }
    }
}

struct CalendarView: View {
	@ObservedObject var calendarViewModel: CalendarViewModel

	var body: some View {
		NavigationView {
			List {
				ForEach(calendarViewModel.data) { container in
					YearView(data: container.value)
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
}

struct YearView: View {
	let data: YearData

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
				MonthView(data: container.value) { _, _ in

				}
			}
		}
	}
}

struct YearData {
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
			.frame(alignment: .trailing)
			.buttonStyle(PlainButtonStyle())
		}
	}
}

struct MonthData {
	let month: Month
	let name: String
	var weeks: [Identified<WeekData>]
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

struct WeekData {
	var days: [Identified<DayData>]
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

struct DayData {
	let day: Day
	var isSelected: Bool
}
