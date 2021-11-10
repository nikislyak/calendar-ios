//
//  DayView.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 06.09.2021.
//

import Foundation
import SwiftUI

struct DayData: Hashable {
	let day: Day
	var isSelected: Bool
	let tapAction: () -> Void

	static func == (lhs: DayData, rhs: DayData) -> Bool {
		lhs.day == rhs.day && lhs.isSelected == rhs.isSelected
	}

	func hash(into hasher: inout Hasher) {
		hasher.combine(day)
		hasher.combine(isSelected)
	}
}

struct DayView: View {
	let day: Identified<DayData>

	var body: some View {
		Button { day.tapAction() } label: {
			VStack(spacing: 0) {
				Text(String(day.day.number))
					.font(.system(size: 18, weight: day.day.isCurrent ? .medium : .regular))
					.frame(maxWidth: .infinity)
					.padding(6)
					.background {
						Circle()
							.fill(day.day.isCurrent ? Color.accentColor : .clear)
					}
					.foregroundColor(foregroundColor())

				Circle()
					.fill(.gray.opacity(0.5))
					.frame(width: 8, height: 8)
					.padding(8)
			}
		}
	}

	private func foregroundColor() -> Color {
		day.day.isCurrent ? .white : day.day.isWeekend ? .secondary : .primary
	}
}
