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

	@State private var scale: CGFloat = 1
	@State private var opacity: CGFloat = 1

	var body: some View {
		ZStack {
			CalendarScaledView(openedMonth: $openedMonth)
				.toolbar {
					ToolbarItem(placement: .navigation) {
						Button {
							withAnimation {
								openedMonth = nil
							}
						} label: {
							if openedMonth != nil {
								Label("Назад", systemImage: "chevron.backward")
							}
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
				.scaleEffect(scale, anchor: .bottom)
				.opacity(opacity)
				.animation(.easeInOut, value: scale)
				.animation(.easeInOut, value: opacity)

			if let monthID = openedMonth {
				CalendarView(initialMonth: monthID)
					.background(colorScheme == .light ? .white : .black)
					.transition(.calendarScale())
			}
		}
		.onChange(of: openedMonth) { id in
			scale = openedMonth != nil ? 3 : 1
			opacity = openedMonth != nil ? 0 : 1
		}
	}
}

private extension AnyTransition {
	static func calendarScale() -> AnyTransition {
		.move(edge: .bottom).combined(with: .scale)
	}
}
