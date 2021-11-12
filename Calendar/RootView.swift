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
		.toolbar {
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
}
