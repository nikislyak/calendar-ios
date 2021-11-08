//
//  CalendarView.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 06.09.2021.
//

import Foundation
import SwiftUI

enum ScrollStatePreferenceKey: PreferenceKey {
	static let defaultValue: [UUID: Anchor<CGRect>] = [:]

	static func reduce(value: inout [UUID: Anchor<CGRect>], nextValue: () -> [UUID: Anchor<CGRect>]) {
		value.merge(nextValue()) { $1 }
	}
}

struct CalendarView: View {
	@ObservedObject var calendarViewModel: CalendarViewModel

	let initialMonth: UUID

	@State private var monthForScrolling: ScrollAction<UUID>?
	@State private var frames: [UUID: Anchor<CGRect>] = [:]
	@EnvironmentObject private var calendarState: CalendarState
	@StateObject private var layoutState = CalendarLayoutState()

	var body: some View {
		GeometryReader { listProxy in
			ScrollViewReader { scrollProxy in
				List {
					ForEach(calendarViewModel.years) { container in
						YearView(data: container.value) { month in
							calendarViewModel.onAppear(of: month)
						}
						.onChange(of: frames) { newFrames in
							handleFramesChange(newFrames, container: container, listProxy: listProxy)
						}
						.background {
							Color.clear
								.anchorPreference(
									key: ScrollStatePreferenceKey.self,
									value: .bounds
								) { anchor in
									[container.id: anchor]
								}
						}
						.listRowSeparator(.hidden)
						.listRowInsets(.zero)
					}
				}
				.environmentObject(layoutState)
				.onPreferenceChange(ScrollStatePreferenceKey.self) {
					frames = $0
				}
				.onPreferenceChange(WeekLayoutPreferenceKey.self) { value in
					layoutState.weekLayouts = value
				}
				.onAppear {
					DispatchQueue.main.async {
						monthForScrolling = ScrollAction(item: initialMonth, animated: false, anchor: .top)
					}
				}
				.scrollAction(scrollProxy: scrollProxy, action: $monthForScrolling)
				.toolbar { makeToolbarItems() }
				.listStyle(.plain)
				.buttonStyle(.plain)
			}
		}
		.onDisappear {
			calendarState.currentYear = nil
		}
	}

	@ToolbarContentBuilder
	private func makeToolbarItems() -> some ToolbarContent {
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
					true,
					.top
				)
				.map(ScrollAction.init)
			} label: {
				Text(LocalizedStringKey("bottomBar.today"), tableName: "Localization")
			}
		}
	}

	private func handleFramesChange(
		_ newFrames: [UUID: Anchor<CGRect>],
		container: Identified<YearData>,
		listProxy: GeometryProxy
	) {
		let listFrame = listProxy.frame(in: .local)
		let safeAreaFrame = listFrame.inset(
			by: .init(
				top: listProxy.safeAreaInsets.top,
				left: 0,
				bottom: 0,
				right: 0
			)
		)
		let halfOfFrame = safeAreaFrame.inset(
			by: .init(
				top: 0,
				left: 0,
				bottom: safeAreaFrame.height / 2,
				right: 0
			)
		)
		newFrames[container.id]
			.flatMap { (anchor: Anchor<CGRect>) -> CGRect? in
				let frame = listProxy[anchor]
				return halfOfFrame.intersects(frame) ? frame : nil
			}
			.map {
				if $0.intersection(halfOfFrame).height >= safeAreaFrame.height / 2 {
					calendarState.currentYear = container.number
				}
			}
	}
}
