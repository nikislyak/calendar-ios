//
//  CalendarView.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 06.09.2021.
//

import Foundation
import SwiftUI

struct CalendarView: View {
	let initialMonth: UUID

	@EnvironmentObject private var calendarViewModel: CalendarViewModel
	@State private var monthForScrolling: ScrollAction<UUID>?

	var body: some View {
		GeometryReader { listProxy in
			ScrollViewReader { scrollProxy in
				ScrollView {
					LazyVStack {
						ForEach(calendarViewModel.years) { year in
							YearView(year: year, listProxy: listProxy)
						}
					}
				}
				.scrollAction(scrollProxy: scrollProxy, action: $monthForScrolling)
				.buttonStyle(.plain)
			}
		}
		.onAppear {
			monthForScrolling = ScrollAction(item: initialMonth, animated: false, anchor: .top)
		}
		.onDisappear {
			calendarViewModel.trackedMonth = nil
		}
		.onReceive(calendarViewModel.todayButtonTapPublisher) {
			monthForScrolling = unwrap(
				calendarViewModel.years
					.first { $0.isCurrent }?.months
					.first { $0.isCurrent }?.id,
				true,
				.top
			)
			.map(ScrollAction.init)
		}
		.onPreferenceChange(VisibleMonthsPreferenceKey.self) { months in
			guard let month = months.first(where: { $0.value }) else { return }
			calendarViewModel.years
				.flatMap(\.months)
				.first { $0.id == month.key }
				.map { calendarViewModel.trackedMonth = $0 }
		}
	}
}
