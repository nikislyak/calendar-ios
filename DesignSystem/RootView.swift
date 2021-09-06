//
//  RootView.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 29.08.2021.
//

import SwiftUI
import Combine

struct RootView: View {
	@ObservedObject var calendarViewModel: CalendarViewModel

    var body: some View {
		NavigationView {
			CalendarScaledView(calendarViewModel: calendarViewModel)
				.navigationViewStyle(StackNavigationViewStyle())
		}
		.onAppear { calendarViewModel.makeInitialData() }
		.accentColor(.red)
    }
}
