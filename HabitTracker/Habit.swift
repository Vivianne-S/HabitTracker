//
//  Habit.swift
//  HabitTracker
//
//  Created by Vivianne Sonnerborg on 2025-04-30.
//

import Foundation
import SwiftData

@Model
final class Habit {
    var name: String
    var emoji: String
    var streak: Int
    var lastCompleted: Date?
    var creationDate: Date
    var reminderTime: Date?
    var color: String
    
    @Relationship(deleteRule: .cascade, inverse: \HabitCompletion.habit)
    var completions: [HabitCompletion] = []
    
    init(name: String, emoji: String, streak: Int = 0, lastCompleted: Date? = nil, color: String = "2A4D69") {
        self.name = name
        self.emoji = emoji
        self.streak = streak
        self.lastCompleted = lastCompleted
        self.creationDate = Date()
        self.color = color
    }
    
    var isCompletedToday: Bool {
        guard let lastCompleted = lastCompleted else { return false }
        return Calendar.current.isDateInToday(lastCompleted)
    }
}

