//
//  CalendarState.swift
//  Calendar
//
//  Created by Никита Кисляков on 03.11.2021.
//

import SwiftUI
import Combine

final class CalendarState: ObservableObject {
	@Published var currentYear: Int?
}
