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
					.frame(maxWidth: proxy.size.width, maxHeight: proxy.size.height)
			}
			.background(
				(data.day.isCurrent ? Color.accentColor : .clear)
					.frame(maxWidth: dimension(proxy: proxy), maxHeight: dimension(proxy: proxy), alignment: .center)
					.cornerRadius(dimension(proxy: proxy))
			)
			.foregroundColor(data.day.isCurrent ? .white : .primary)
			.position(x: proxy.size.width / 2, y: proxy.size.height / 2)
		}
	}

	private func dimension(proxy: GeometryProxy) -> CGFloat {
		min(proxy.size.width, proxy.size.height)
	}
}
