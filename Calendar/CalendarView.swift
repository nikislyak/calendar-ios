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

	@State private var monthForScrolling: ScrollAction<UUID>?

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
							YearView(data: container.value) { month in
								calendarViewModel.onAppear(of: month)
							}
						}
					}
					.onChange(of: monthForScrolling) { action in
						if let action = action {
							if action.animated {
								withAnimation {
									scrollProxy.scrollTo(action.item, anchor: .top)
								}
							} else {
								scrollProxy.scrollTo(action.item, anchor: .top)
							}
							monthForScrolling = nil
						}
					}
					.onAppear {
						monthForScrolling = ScrollAction(item: initialMonth, animated: false)
					}
					.toolbar {
						ToolbarItem(placement: .navigationBarTrailing) {
							Button {} label: {
								Image(systemName: "magnifyingglass")
							}
						}
						ToolbarItemGroup(placement: .bottomBar) {
							Button {
								monthForScrolling = unwrap(
									calendarViewModel.years
										.first { $0.isCurrent }?.months
										.first { $0.isCurrent }?.id,
									true
								)
								.map(ScrollAction.init)
							} label: {
								Text(LocalizedStringKey("bottomBar.today"), tableName: "Localization")
							}
						}
					}
					.listStyle(.plain)
				}
			}
		}
	}
}
