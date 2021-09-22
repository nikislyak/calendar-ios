//
//  CalendarView.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 06.09.2021.
//

import Foundation
import SwiftUI

struct CalendarView: View {
	@ObservedObject var calendarViewModel: CalendarViewModel

	let initialMonth: UUID

	@State private var monthForScrolling: UUID?

	var body: some View {
		GeometryReader { proxy in
			VStack(spacing: 0) {
				HStack(alignment: .center, spacing: 4) {
					ForEach(calendarViewModel.headerData.indices) {
						Text("\(calendarViewModel.localizedString(for: calendarViewModel.headerData[$0]))")
							.font(.subheadline)
							.frame(maxWidth: (proxy.size.width - 24) / 7)
					}
				}
				.padding([.leading, .trailing], 16)
				.padding([.top, .bottom], 4)

				ScrollViewReader { scrollProxy in
					List {
						ForEach(calendarViewModel.years) { container in
							YearView(data: container.value) { month, week, day in
							} onMonthAppear: { month in
								calendarViewModel.onAppear(of: month)
							}
						}
					}
					.onChange(of: monthForScrolling) { id in
						if let id = id {
							withAnimation {
								scrollProxy.scrollTo(id, anchor: .top)
							}
							monthForScrolling = nil
						}
					}
					.onAppear { scrollProxy.scrollTo(initialMonth, anchor: .top) }
					.toolbar {
						ToolbarItem(placement: .navigationBarTrailing) {
							Button {} label: {
								Image(systemName: "magnifyingglass")
							}
						}
						ToolbarItemGroup(placement: .bottomBar) {
							Button {
								monthForScrolling = calendarViewModel.years
									.first { $0.isCurrent }?.months
									.first { $0.isCurrent }?.id
							} label: {
								Text(LocalizedStringKey("bottomBar.today"), tableName: "Localization")
							}
						}
					}
					.listStyle(PlainListStyle())
				}
			}
		}
	}
}
