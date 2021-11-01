//
//  Auxiliary.swift
//  Calendar
//
//  Created by Никита Кисляков on 23.09.2021.
//

import Foundation
import SwiftUI

func unwrap<T0, T1>(_ t0: T0?, _ t1: T1?) -> (T0, T1)? {
	guard let t0 = t0, let t1 = t1 else { return nil }
	return (t0, t1)
}

func unwrap<T0, T1, T2>(_ t0: T0?, _ t1: T1?, _ t2: T2?) -> (T0, T1, T2)? {
	guard let t0 = t0, let t1 = t1, let t2 = t2 else { return nil }
	return (t0, t1, t2)
}

struct ScrollAction<T: Hashable>: Equatable {
	let item: T
	let animated: Bool
	let anchor: UnitPoint
}

extension ScrollAction {
	init?(_ tuple: (T, Bool)?) {
		guard let tuple = tuple else { return nil }
		self.init(item: tuple.0, animated: tuple.1, anchor: .top)
	}

	init?(_ tuple: (T, Bool, UnitPoint)?) {
		guard let tuple = tuple else { return nil }
		self.init(item: tuple.0, animated: tuple.1, anchor: tuple.2)
	}
}
