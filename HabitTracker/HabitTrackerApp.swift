//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Created by Vivianne Sonnerborg on 2025-04-30.
//

import SwiftUI
import SwiftData

@main
struct HabitTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [Habit.self, HabitCompletion.self])
        }
    }
}
