//
//  CalendarApp.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 29.08.2021.
//

import SwiftUI

@main
struct CalendarApp: App {
	private let calendar: Calendar = {
		var calendar = Calendar.autoupdatingCurrent
		calendar.locale = .autoupdatingCurrent
		return calendar
	}()

	@StateObject var calendarViewModel: CalendarViewModel = {
		var calendar = Calendar.autoupdatingCurrent
		calendar.locale = .autoupdatingCurrent
		let viewModel = CalendarViewModel(
			manager: .init(calendar: calendar, currentDate: .init())
		)
		return viewModel
	}()

    var body: some Scene {
        WindowGroup {
			RootView(calendarViewModel: calendarViewModel)
				.environment(\.calendar, calendar)
		}
    }
}
