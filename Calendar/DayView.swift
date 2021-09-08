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
}

struct DayView: View {
	let data: DayData
	let tapAction: () -> Void

	var body: some View {
		GeometryReader { proxy in
			Button(action: tapAction) {
				Text(String(data.day.number))
					.frame(maxWidth: proxy.size.width / 2, maxHeight: proxy.size.height / 2)
			}
			.padding(4)
			.background(data.day.isCurrent ? Color.accentColor : .clear)
			.foregroundColor(data.day.isCurrent ? .white : .primary)
			.cornerRadius(proxy.size.width)
		}
	}
}
