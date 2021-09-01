//
//  Month.swift
//  DesignSystem
//
//  Created by Nikita Kislyakov1 on 30.08.2021.
//

import Foundation

enum DayOfWeek: Int, CaseIterable {
	case sunday = 1
	case monday
	case tuesday
	case wednesday
	case thursday
	case friday
	case saturday
}

enum Month: Int, CaseIterable {
	case january = 1
	case february
	case march
	case april
	case may
	case june
	case july
	case august
	case september
	case october
	case november
	case december
}

struct Day {
	let number: Int
	let dayOfWeek: DayOfWeek
	let month: Month
	let year: Int
}
