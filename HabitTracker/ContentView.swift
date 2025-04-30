//
//  ContentView.swift
//  HabitTracker
//
//  Created by Vivianne Sonnerborg on 2025-04-30.

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query private var habits: [Habit]
    @State private var showingStats = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()
                
                if habits.isEmpty {
                    EmptyHabitsView()
                } else {
                    HabitListView(habits: habits)
                }
            }
            .navigationTitle("Habit Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingStats.toggle() }) {
                        Image(systemName: "chart.bar")
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddHabitView()) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingStats) {
                // StatisticsView(habits: habits)
                Text("Statistics View Placeholder")
            }
        }
    }
}

struct HabitListView: View {
    let habits: [Habit]
    
    var body: some View {
        List {
            ForEach(habits) { habit in
                HabitRowView(habit: habit)
                    .listRowBackground(Color(.systemBackground))
            }
        }
        .scrollContentBackground(.hidden)
    }
}

struct HabitRowView: View {
    @Environment(\.modelContext) private var context
    let habit: Habit
    
    var body: some View {
        HStack(spacing: 16) {
            Circle()
                .fill(Color(hex: habit.color))
                .frame(width: 40, height: 40)
                .overlay(
                    Text(habit.emoji)
                        .font(.system(size: 20))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.headline)
                
                Text("\(habit.streak) day streak")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { markHabitDone(habit) }) {
                Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .foregroundColor(habit.isCompletedToday ? .green : .gray)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .padding(.vertical, 8)
    }
    
    private func markHabitDone(_ habit: Habit) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        if habit.isCompletedToday {
            return
        }
        
        if let last = habit.lastCompleted,
           let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           calendar.isDate(last, inSameDayAs: yesterday) {
            habit.streak += 1
        } else if !calendar.isDateInToday(habit.lastCompleted ?? Date.distantPast) {
            habit.streak = 1
        }
        
        habit.lastCompleted = today
        try? context.save()
    }
}

struct EmptyHabitsView: View {
    var body: some View {
        VStack {
            Text("No Habits Yet")
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.bottom, 8)
            
            Text("Tap the + button to add your first habit")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }
}
