//
//  ContentView.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 29.08.2021.
//

import SwiftUI

struct RootView: View {
    var body: some View {
		CalendarView(calendarViewModel: .init(manager: .init(calendar: .current, currentDate: .init())))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        RootView()
    }
}

struct MonthView: View {
	@Binding var data: MonthData

	var body: some View {
		ForEach(data.weeks) { container in
			WeekView(data: container.value) { id in
				for week in data.weeks.enumerated() {
					if let index = week.element.days.firstIndex(where: { $0.id == id }) {
						withAnimation {
							data.weeks[week.offset].days[index].isSelected.toggle()
						}
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
	var weeks: [Identified<WeekData>]
}

struct WeekView: View {
	let data: WeekData
	let dayTapAction: (UUID) -> Void

	var body: some View {
		HStack(alignment: .center, spacing: 8) {
			if data.days.first?.value.weekDay != .monday {
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

struct CalendarView: View {
	@StateObject var calendarViewModel: CalendarViewModel

	var body: some View {
		NavigationView {
			List {
				Section {
					Text("\(calendarViewModel.localizedString(for: calendarViewModel.data.month))")
						.bold()
						.foregroundColor(Color.red)
						.font(.title)
					MonthView(data: $calendarViewModel.data)
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
		.onAppear { calendarViewModel.makeInitialData() }
	}
}

struct DayView: View {
	let data: DayData
	let tapAction: () -> Void

	var body: some View {
		GeometryReader { proxy in
			Button(action: tapAction) {
				Text(String(data.number))
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
	let number: Int
	let weekDay: DayOfWeek
	var isSelected: Bool
}

@dynamicMemberLookup
struct Identified<T>: Identifiable {
	let id: UUID
	var value: T

	subscript<V>(dynamicMember keyPath: WritableKeyPath<T, V>) -> V {
		get { value[keyPath: keyPath] }
		set { value[keyPath: keyPath] = newValue }
	}
}
