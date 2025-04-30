//
//  Habit.swift
//  HabitTracker
//
//  Created by Vivianne Sonnerborg on 2025-04-30.
//

import Foundation
import SwiftData

@Model
class Habit {
    var name: String
    var emoji: String
    var streak: Int
    var lastCompleted: Date?

    init(name: String, emoji: String, streak: Int = 0, lastCompleted: Date? = nil) {
        self.name = name
        self.emoji = emoji
        self.streak = streak
        self.lastCompleted = lastCompleted
    }
}
