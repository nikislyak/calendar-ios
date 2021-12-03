//
//  CalendarStateTransitionView.swift
//  Calendar
//
//  Created by Nikita Kislyakov1 on 15.11.2021.
//

import Foundation
import SwiftUI

struct CalendarStateTransitionView: View {
	@EnvironmentObject private var calendarViewModel: CalendarViewModel
	@Environment(\.colorScheme) private var colorScheme

	@State private var openedMonth: UUID?
	@State private var trackedMonth: Identified<MonthData>?

	var body: some View {
		ZStack {
			if let monthID = openedMonth {
				CalendarView(initialMonth: monthID)
					.background(colorScheme == .light ? .white : .black)
					.transition(.calendarScale())
			} else {
				makeCalendarScaledView()
			}
		}
		.toolbar {
			ToolbarItem(placement: .navigation) {
				Button {
					withAnimation {
						openedMonth = nil
					}
				} label: {
					if openedMonth != nil {
						Label("\(trackedMonth.map { String($0.year) } ?? "Назад")", systemImage: "chevron.backward")
							.labelStyle(.titleAndIcon)
					}
				}
				.onChange(of: calendarViewModel.trackedMonth) { month in
					trackedMonth = month
				}
			}
			ToolbarItem(placement: .navigationBarTrailing) {
				Button {} label: {
					Image(systemName: "magnifyingglass")
						.resizable()
						.aspectRatio(contentMode: .fit)
				}
			}
			ToolbarItem(placement: .bottomBar) {
				Button {
					calendarViewModel.onTodayButtonTap()
				} label: {
					Text(LocalizedStringKey("bottomBar.today"), tableName: "Localization")
				}
			}
		}
	}

	@ViewBuilder
	private func makeCalendarScaledView() -> some View {
		CalendarScaledView(openedMonth: $openedMonth)
	}
}

private extension AnyTransition {
	static func calendarScale() -> AnyTransition {
		.move(edge: .bottom).combined(with: .scale)
	}
}
