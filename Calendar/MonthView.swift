//
//  MonthView.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 06.09.2021.
//

import Foundation
import SwiftUI

struct MonthData: Hashable {
	let month: Month
	let year: Int
	let name: String
	var weeks: [Identified<WeekData>]
	let isCurrent: Bool
}

enum VisibleMonthsPreferenceKey: PreferenceKey {
	typealias Value = [UUID: Bool]

	static let defaultValue: Value = [:]

	static func reduce(value: inout Value, nextValue: () -> Value) {
		value.merge(nextValue()) { $1 }
	}
}

struct MonthView: View {
	@Environment(\.calendar) private var calendar
	@Environment(\.pixelLength) private var pixelLength
	@EnvironmentObject private var calendarViewModel: CalendarViewModel
	@State private var weeksLayout: [UUID: [UUID: Anchor<CGRect>]] = [:]

	let month: Identified<MonthData>
	let listProxy: GeometryProxy

	var body: some View {
		VStack(spacing: 0) {
			GeometryReader { proxy in
				if let frame = firstMonthDayCenter(proxy: proxy) {
					Text(calendar.shortStandaloneMonthSymbols[month.month.rawValue - 1].capitalized)
						.fontWeight(.semibold)
						.foregroundColor(month.isCurrent ? .accentColor : .primary)
						.font(.title3)
						.position(x: frame.midX, y: 0)
				}
			}
			.padding(.top, 24)
			.padding(.bottom, 12)

			ForEach(month.weeks) { week in
				WeekView(week: week)
					.overlay { makeWeekSeparator(for: week) }
			}
		}
		.background {
			GeometryReader { proxy in
				Color.clear
					.preference(
						key: VisibleMonthsPreferenceKey.self,
						value: [month.id: isVisibleOnScreen(listProxy: listProxy, monthProxy: proxy)]
					)
			}
		}
		.onPreferenceChange(WeekLayoutPreferenceKey.self) { value in
			weeksLayout = value
		}
	}

	private func isVisibleOnScreen(listProxy: GeometryProxy, monthProxy: GeometryProxy) -> Bool {
		let listFrame = listProxy.frame(in: .global)
		let monthFrame = monthProxy.frame(in: .global)
		return listFrame.contains(monthFrame)
	}

	private func firstMonthDayCenter(proxy: GeometryProxy) -> CGRect? {
		guard let firstWeek = month.weeks.first,
			  let anchors = weeksLayout[firstWeek.id],
			  let firstDay = firstWeek.days.first,
			  let dayAnchor = anchors[firstDay.id] else { return nil }
		return proxy[dayAnchor]
	}

	private func weekRect(weekIndex: Int, proxy: GeometryProxy) -> CGRect? {
		guard let anchors = weeksLayout[month.weeks[weekIndex].id] else { return nil }
		let rects = anchors.values.map { proxy[$0] }
		return rects.reduce(rects.first) { $0?.union($1) }
	}

	private func makeWeekSeparator(for week: Identified<WeekData>) -> some View {
		GeometryReader { proxy in
			if let index = month.weeks.firstIndex(of: week), let rect = weekRect(weekIndex: index, proxy: proxy) {
				Path { path in
					path.move(to: .init(x: week == month.weeks.first && week.days.count < 7 ? rect.minX : 0, y: 0))
					path.addLine(to: .init(
						x: week == month.weeks.last && week.days.count < 7 ? rect.maxX : proxy.size.width,
						y: 0
					))
				}
				.stroke(lineWidth: pixelLength)
				.foregroundColor(.secondary.opacity(0.5))
			}
		}
	}
}
