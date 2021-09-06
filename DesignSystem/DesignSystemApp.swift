//
//  DesignSystemApp.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 29.08.2021.
//

import SwiftUI

@main
struct DesignSystemApp: App {
	@StateObject var calendarViewModel = CalendarViewModel(
		manager: .init(calendar: .autoupdatingCurrent, currentDate: .init())
	)

    var body: some Scene {
        WindowGroup {
			RootView(calendarViewModel: calendarViewModel)
        }
    }
}
