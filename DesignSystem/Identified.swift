//
//  Identified.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 01.09.2021.
//

import Foundation

@dynamicMemberLookup
struct Identified<T>: Identifiable {
	let id: UUID
	var value: T

	subscript<V>(dynamicMember keyPath: WritableKeyPath<T, V>) -> V {
		get { value[keyPath: keyPath] }
		set { value[keyPath: keyPath] = newValue }
	}
}
