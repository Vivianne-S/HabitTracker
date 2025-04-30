//
//  ContentView.swift
//  HabitTracker
//
//  Created by Vivianne Sonnerborg on 2025-04-30.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query private var habits: [Habit]

    var body: some View {
        NavigationStack {
            List {
                ForEach(habits) { habit in
                    HStack {
                        Text("\(habit.emoji) \(habit.name)")
                        Spacer()
                        Text("🔥 \(habit.streak)")
                        Button("✅") {
                            markHabitDone(habit)
                        }
                        .buttonStyle(BorderlessButtonStyle())
                    }
                }
            }
            .navigationTitle("My Habits")
            .toolbar {
                NavigationLink("➕ Add Habit", destination: AddHabitView())
            }
        }
    }

    func markHabitDone(_ habit: Habit) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if let last = habit.lastCompleted,
           calendar.isDate(last, inSameDayAs: today) {
            return 
        }

        if let last = habit.lastCompleted,
           let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           calendar.isDate(last, inSameDayAs: yesterday) {
            habit.streak += 1
        } else {
            habit.streak = 1
        }

        habit.lastCompleted = today
        try? context.save()
    }
}
