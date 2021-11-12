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
				.onAppear {
					yearScrollAction = calendarViewModel.currentYearID.map {
						ScrollAction(item: $0, animated: false, anchor: .top)
					}
				}
				.buttonStyle(.plain)
				.scrollAction(scrollProxy: scrollProxy, action: $yearScrollAction)
				.navigationBarTitleDisplayMode(.inline)
				.onReceive(calendarViewModel.todayButtonTapPublisher) {
					yearScrollAction = calendarViewModel
						.currentYearID
						.map { .init(item: $0, animated: true, anchor: .top) }
				}
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
}
