//
//  RootView.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 29.08.2021.
//

import SwiftUI
import Combine

struct RootView: View {
	@EnvironmentObject var calendarViewModel: CalendarViewModel

    var body: some View {
		NavigationView {
			CalendarScaledView()
		}
		.onAppear { calendarViewModel.makeInitialData() }
		.accentColor(.red)
    }
}
