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
	@ObservedObject var calendarViewModel: CalendarViewModel

	@State private var openedMonth: UUID?
	@State private var yearFromDetailView: UUID?

	@State private var yearForScrolling: UUID?
	@State private var offsetY: CGFloat = 0

	var body: some View {
		GeometryReader { proxy in
			ScrollViewReader { scrollProxy in
				List {
					ForEach(calendarViewModel.years) { year in
						Section(
							header: Text(String(year.number))
								.foregroundColor(year.isCurrent ? .accentColor : .primary)
								.font(.title)
								.bold()
						) {
							LazyVGrid(
								columns: .init(
									repeating: .init(
										.fixed((proxy.size.width - 32 - 32) / 3),
										spacing: 16,
										alignment: .top
									),
									count: 3
								),
								alignment: .center,
								spacing: 24
							) {
								ForEach(year.months) { month in
									makeCompactMonthView(month: month, width: (proxy.size.width - 32 - 32) / 3)
								}
							}
						}
						.background(Color.clear)
						.buttonStyle(.plain)
					}
				}
				.listStyle(.plain)
				.listRowBackground(Color.clear)
				.onChange(of: yearForScrolling) { id in
					if let id = id {
						withAnimation {
							scrollProxy.scrollTo(id, anchor: .top)
						}
						yearForScrolling = nil
					}
				}
				.toolbar { makeToolbarItems() }
				.navigationBarTitleDisplayMode(.inline)
				.navigationBarTitle(
					calendarViewModel.years
						.first { $0.id == yearFromDetailView }
						.map { String($0.number) } ?? ""
				)
			}
		}
	}

	@ViewBuilder
	private func makeCompactMonthView(month: Identified<MonthData>, width: CGFloat) -> some View {
		ZStack {
			NavigationLink(
				destination: CalendarView(
					calendarViewModel: calendarViewModel,
					initialMonth: month.id
				) { yearFromDetailView = $0; yearForScrolling = $0 },
				tag: month.id,
				selection: $openedMonth
			) {
				EmptyView()
			}
			.hidden()

			CompactMonthView(width: width, monthData: month) {
				openedMonth = $0
			}
			.onAppear { calendarViewModel.onAppear(of: month.value) }
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
				yearForScrolling = calendarViewModel.years.first { $0.isCurrent }?.id
			} label: {
				Text(LocalizedStringKey("bottomBar.today"), tableName: "Localization")
			}
		}
	}
}
