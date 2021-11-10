//
//  View+extensions.swift
//  Calendar
//
//  Created by Nikita Kislyakov1 on 01.11.2021.
//

import Foundation
import SwiftUI

struct ScrollActionModifier<T: Hashable>: ViewModifier {
	let scrollProxy: ScrollViewProxy
	@Binding var action: ScrollAction<T>?

	func body(content: Content) -> some View {
		content.onChange(of: action) {
			guard let action = $0 else { return }
			if action.animated {
				withAnimation {
					scrollProxy.scrollTo(action.item, anchor: action.anchor)
				}
				self.action = nil
			} else {
				scrollProxy.scrollTo(action.item, anchor: action.anchor)
			}
		}
	}
}

extension View {
	func scrollAction<T: Hashable>(scrollProxy: ScrollViewProxy, action: Binding<ScrollAction<T>?>) -> some View {
		modifier(ScrollActionModifier(scrollProxy: scrollProxy, action: action))
	}
}
