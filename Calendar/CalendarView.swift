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
							YearView(year: year, monthScrollAction: $monthForScrolling)
						}
					}
				}
				.onAppear {
					monthForScrolling = ScrollAction(item: initialMonth, animated: false, anchor: .top)
				}
				.scrollAction(scrollProxy: scrollProxy, action: $monthForScrolling)
				.buttonStyle(.plain)
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
			}
		}
	}
}
