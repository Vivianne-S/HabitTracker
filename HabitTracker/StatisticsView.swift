//
//  StatisticsView.swift
//  HabitTracker
//
//  Created by Vivianne Sonnerborg on 2025-05-05.
//

import SwiftUI
import SwiftData

struct StatisticsView: View {
    @Query private var completions: [HabitCompletion]
    let habits: [Habit]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    StreakSummaryView(habits: habits)
                    CompletionRateView(habits: habits, completions: completions)
                    HabitPerformanceGrid(habits: habits, completions: completions)
                }
                .padding()
            }
            .navigationTitle("Your Stats")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct StreakSummaryView: View {
    let habits: [Habit]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🔥 Current Streaks")
                .font(.headline)
            
            Text("Shows how many consecutive days you've completed each habit without missing.")
                .font(.caption)
                .foregroundColor(.gray)
            
            ForEach(habits) { habit in
                HStack {
                    Text(habit.emoji)
                    Text(habit.name)
                    Spacer()
                    Text("\(habit.streak) days")
                        .bold()
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}
struct CompletionRateView: View {
    let habits: [Habit]
    let completions: [HabitCompletion]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("📊 Completion Rates")
                .font(.headline)
            
            Text("Your consistency for each habit over the past 7 days, shown as a percentage.")
                .font(.caption)
                .foregroundColor(.gray)
            
            ForEach(habits) { habit in
                let recentDates = last7Days()
                
             
                let daysCompleted = recentDates.filter { date in
                    completions.contains { completion in
                        completion.habit == habit && Calendar.current.isDate(completion.date, inSameDayAs: date)
                    }
                }.count
                
                let rate = Double(daysCompleted) / 7.0 * 100
                
                HStack {
                    Text("\(habit.emoji) \(habit.name)")
                    Spacer()
                    Text("\(Int(rate))%")
                        .bold()
                }
                .padding(.vertical, 2)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
    
    private func last7Days() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).map { calendar.date(byAdding: .day, value: -$0, to: today)! }
    }
}

struct HabitPerformanceGrid: View {
    let habits: [Habit]
    let completions: [HabitCompletion]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("🗓️ Recent Activity")
                .font(.headline)
            
            Text("Visual overview of which days each habit was completed during the past week. Blue ring marks today.")
                .font(.caption)
                .foregroundColor(.gray)
            
            ForEach(habits) { habit in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(habit.emoji) \(habit.name)")
                        .font(.subheadline)
                        .bold()
                    
                    HStack(spacing: 8) {
                        ForEach(last7Days(), id: \.self) { day in
                            let didComplete = completions.contains {
                                $0.habit == habit && Calendar.current.isDate($0.date, inSameDayAs: day)
                            }
                            let isToday = Calendar.current.isDateInToday(day)
                            let circleColor = didComplete ? Color(hex: habit.color) : Color.gray.opacity(0.3)
                            
                            ZStack {
                                Circle()
                                    .fill(circleColor)
                                    .frame(width: 20, height: 20)
                                
                                Text(shortDayName(for: day))
                                    .font(.caption2)
                                    .foregroundColor(.white)
                                
                                if isToday {
                                    Circle()
                                        .stroke(Color.blue, lineWidth: 2)
                                        .frame(width: 24, height: 24)
                                }
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
    
    private func last7Days() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return (0..<7).map { calendar.date(byAdding: .day, value: -$0, to: today)! }.reversed()
    }
    

    private func shortDayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1)).uppercased()
    }
}

