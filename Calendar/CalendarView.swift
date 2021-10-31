//
//  CalendarView.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 06.09.2021.
//

import Foundation
import SwiftUI

enum ScrollStatePreferenceKey: PreferenceKey {
	static let defaultValue: [UUID: CGRect] = [:]

	static func reduce(value: inout [UUID: CGRect], nextValue: () -> [UUID: CGRect]) {
		value.merge(nextValue()) { $1 }
	}
}

struct CalendarView: View {
	@ObservedObject var calendarViewModel: CalendarViewModel

	let initialMonth: UUID
	@Binding var currentYear: UUID?

	@State private var monthForScrolling: ScrollAction<UUID>?
	@State private var weekStarts: [UUID: WeekStartPreferenceKey.Data] = [:]
	@State private var frames: [UUID: CGRect] = [:]

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
						.background(
							Color.clear
								.anchorPreference(
									key: ScrollStatePreferenceKey.self,
									value: .bounds
								) { anchor in
									[container.id: listProxy[anchor]]
								}
						)
					}
				}
				.environment(\.weekStarts, weekStarts)
				.onPreferenceChange(ScrollStatePreferenceKey.self) {
					print($0)
					frames = $0
				}
				.onPreferenceChange(WeekStartPreferenceKey.self) { value in
					weekStarts = value
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
				.toolbar { makeToolbarItems() }
				.listStyle(.plain)
				.buttonStyle(.plain)
			}
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
					true
				)
				.map(ScrollAction.init)
			} label: {
				Text(LocalizedStringKey("bottomBar.today"), tableName: "Localization")
			}
		}
	}

	private func handleFramesChange(
		_ newFrames: [UUID: CGRect],
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
			.flatMap {
				halfOfFrame.intersects($0) ? $0 : nil
			}
			.map {
				if $0.intersection(halfOfFrame).height >= safeAreaFrame.height / 2 {
					currentYear = container.id
				}
			}
	}
}
