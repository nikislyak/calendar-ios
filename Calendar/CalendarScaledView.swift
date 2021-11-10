//
//  CalendarScaledView.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 06.09.2021.
//

import Foundation
import SwiftUI

struct CalendarScaledView: View {
	@Environment(\.colorScheme) private var colorScheme
	@EnvironmentObject private var calendarViewModel: CalendarViewModel

	@State private var openedMonth: UUID?
	@State private var yearScrollAction: ScrollAction<UUID>?

	private let spacing: CGFloat = 8

	var body: some View {
		GeometryReader { listProxy in
			ScrollViewReader { scrollProxy in
				ScrollView {
					LazyVStack {
						ForEach(calendarViewModel.years) { year in
							makeHeader(from: year)

							LazyVGrid(
								columns: .init(
									repeating: .init(
										.fixed((listProxy.size.width - spacing * 2 - 32) / 3),
										spacing: spacing,
										alignment: .top
									),
									count: 3
								),
								alignment: .center,
								spacing: 36
							) {
								ForEach(year.months) { month in
									makeCompactMonthView(
										month: month,
										width: (listProxy.size.width - spacing * 2 - 32) / 3
									)
								}
							}
							.onAppear {
								calendarViewModel.onAppear(of: year.value)
							}
						}
					}
				}
				.buttonStyle(.plain)
				.scrollAction(scrollProxy: scrollProxy, action: $yearScrollAction)
				.toolbar { makeToolbarItems() }
				.navigationBarTitleDisplayMode(.inline)
			}
		}
	}

	@ViewBuilder
	private func makeHeader(from year: Identified<YearData>) -> some View {
		Text(String(year.number))
			.foregroundColor(year.isCurrent ? .accentColor : .primary)
			.font(.largeTitle)
			.bold()
			.frame(maxWidth: .infinity, alignment: .leading)
			.padding([.leading, .trailing])
	}

	@ViewBuilder
	private func makeCompactMonthView(month: Identified<MonthData>, width: CGFloat) -> some View {
		NavigationLink(tag: month.id, selection: $openedMonth) {
			CalendarView(initialMonth: month.id)
				.environmentObject(calendarViewModel)
		} label: {
			CompactMonthView(width: width, monthData: month) {
				openedMonth = $0
			}
		}
	}

	@ToolbarContentBuilder
	private func makeToolbarItems() -> some ToolbarContent {
		ToolbarItem(placement: .navigationBarTrailing) {
			HStack {
				Button {} label: {
					Image(systemName: "magnifyingglass")
				}
			}
		}
		ToolbarItemGroup(placement: .bottomBar) {
			Button {
				yearScrollAction = calendarViewModel.years
					.first { $0.isCurrent }
					.map { .init(item: $0.id, animated: true, anchor: .top) }
			} label: {
				Text(LocalizedStringKey("bottomBar.today"), tableName: "Localization")
			}
		}
	}
}
