//
//  Collection+binarySearch.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 06.09.2021.
//

import Foundation

extension Collection where Element: Comparable, Index == Int {
	func binarySearchFirstIndex(of value: Element) -> Int? {
		var lowerIndex = 0
		var upperIndex = count - 1
		while true {
			let currentIndex = (lowerIndex + upperIndex) / 2
			if self[currentIndex] == value {
				return currentIndex
			} else if lowerIndex > upperIndex {
				return nil
			} else {
				if self[currentIndex] > value {
					upperIndex = currentIndex - 1
				} else {
					lowerIndex = currentIndex + 1
				}
			}
		}
	}
}

extension Collection where Index == Int {
	func binarySearchFirstIndex(where compare: (Element) -> ComparisonResult) -> Int? {
		var lowerIndex = 0
		var upperIndex = count - 1
		while true {
			let currentIndex = (lowerIndex + upperIndex) / 2
			if compare(self[currentIndex]) == .orderedSame {
				return currentIndex
			} else if lowerIndex > upperIndex {
				return nil
			} else {
				let result = compare(self[currentIndex])
				if result == .orderedDescending {
					upperIndex = currentIndex - 1
				} else if result == .orderedAscending {
					lowerIndex = currentIndex + 1
				}
			}
		}
	}
}
