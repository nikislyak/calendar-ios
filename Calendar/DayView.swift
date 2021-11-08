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
	let data: DayData

	var body: some View {
		Button { data.tapAction() } label: {
			VStack(spacing: 0) {
				Text(String(data.day.number))
					.font(.system(size: 18, weight: data.day.isCurrent ? .medium : .regular))
					.frame(maxWidth: .infinity)
					.padding(6)
					.background {
						Circle()
							.fill(data.day.isCurrent ? Color.accentColor : .clear)
					}
					.foregroundColor(data.day.isCurrent ? .white : .primary)

				Circle()
					.fill(.gray.opacity(0.5))
					.frame(width: 8, height: 8)
					.padding(8)
			}
		}
	}
}
