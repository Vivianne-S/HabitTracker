//
//  HabitCompletion.swift
//  HabitTracker
//
//  Created by Vivianne Sonnerborg on 2025-05-05.
//

import Foundation
import SwiftData

@Model
final class HabitCompletion {
    var date: Date
    var habit: Habit?

    init(date: Date, habit: Habit? = nil) {
        self.date = date
        self.habit = habit
    }
}
