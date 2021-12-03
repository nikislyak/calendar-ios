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

	@Binding var openedMonth: UUID?

	@State private var yearScrollAction: ScrollAction<UUID>?

	private let spacing: CGFloat = 8

	var body: some View {
		GeometryReader { listProxy in
			ScrollViewReader { scrollProxy in
				ScrollView {
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
						ForEach(calendarViewModel.years) { year in
							Section {
								ForEach(year.months) { month in
									makeCompactMonthView(
										month: month,
										width: (listProxy.size.width - spacing * 2 - 32) / 3
									)
								}
							} header: {
								makeHeader(from: year)
							}
							.onAppear {
								calendarViewModel.onAppear(of: year.value)
							}
						}
					}
				}
				.buttonStyle(.plain)
				.scrollAction(scrollProxy: scrollProxy, action: $yearScrollAction)
			}
		}
		.onAppear {
			var id: UUID?
			if let month = calendarViewModel.trackedMonth,
			   let year = calendarViewModel.years.first(where: { $0.months.contains { $0.id == month.id } }) {
				id = year.id
			} else if let currentYearID = calendarViewModel.currentYearID {
				id = currentYearID
			}
			yearScrollAction = id.map { ScrollAction(item: $0, animated: false, anchor: .top) }
		}
		.onReceive(calendarViewModel.todayButtonTapPublisher) {
			yearScrollAction = calendarViewModel
				.currentYearID
				.map { .init(item: $0, animated: true, anchor: .top) }
		}
		.navigationBarTitleDisplayMode(.inline)
		.toolbar {
			ToolbarItem(placement: .navigationBarTrailing) {
				Button {} label: {
					Image(systemName: "magnifyingglass")
						.resizable()
						.aspectRatio(contentMode: .fit)
				}
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
		CompactMonthView(width: width, month: month) {
			withAnimation {
				openedMonth = month.id
			}
		}
	}
}
