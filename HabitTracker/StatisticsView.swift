//
//  StatisticsView.swift
//  HabitTracker
//
//  Created by Vivianne Sonnerborg on 2025-05-05.
//
/*
Statistikvy för HabitTracker som visar:
- Fyra huvudsektioner med statistik:
  1. 🔥 Streak Summary - Nuvarande streaks för alla vanor
  2. 📊 Completion Rates - Genomförandegrad senaste 30 dagarna
  3. 🗓️ Weekly Activity - Veckovis översikt av vanor
  4. 📅 Monthly Calendar - Månadskalender med slutförda vanor

Innehåller följande komponenter:
- StreakSummaryCard: Visar streaker med cirkeldiagram
- CompletionRateCard: Progress bars för slutförandegrad
- WeeklyHabitActivity: Grid med veckans dagar
- MonthlyHabitCalendar: Hel månadskalender med aktivitet
- HeaderView: Återanvändbar rubrikkomponent
- CardStyle: Visuell stil för alla statistik-kort

Använder SwiftData för:
- Hämtning av habits och completions
- Beräkning av statistik över tid

Inkluderar datum för:
- Senaste 7 dagar
- Senaste 30 dagar
- Aktuell månads datum
*/

import SwiftUI
import SwiftData

// Huvudvyn för att visa statistik kring vanor.
struct StatisticsView: View {
    @Query private var completions: [HabitCompletion] // Hämtar alla vanors slutföranden från databasen 
    let habits: [Habit] // Lista över alla vanor
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 🔥 Visar nuvarande streaks för alla vanor
                    StreakSummaryCard(habits: habits, completions: completions)
                    
                    // 📊 Visar genomförandegrad för varje vana de senaste 30 dagarna
                    CompletionRateCard(habits: habits, completions: completions)
                    
                    // 🗓️ Visar om vanorna fullföljts varje dag under senaste veckan
                    WeeklyHabitActivity(habits: habits, completions: completions)
                    
                    // 📅 Kalender med färgade prickar för vanor som slutförts under månaden
                    MonthlyHabitCalendar(habits: habits, completions: completions)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Your Habits")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color(.systemGroupedBackground)) // Systembakgrund för enhetlig stil
        }
    }
}

// Kort som visar användarens pågående streaks (antal dagar i rad)
private struct StreakSummaryCard: View {
    let habits: [Habit]
    let completions: [HabitCompletion]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HeaderView(title: "🔥 Current Streaks", subtitle: "Your active habit streaks")
            
            // Loopar igenom varje vana och visar aktuell streak
            ForEach(habits) { habit in
                HabitStreakRow(habit: habit, streak: calculateStreak(for: habit))
            }
        }
        .cardStyle()
    }
    
    // Räknar ut hur många dagar i rad en vana har slutförts
    private func calculateStreak(for habit: Habit) -> Int {
        let calendar = Calendar.current
        let sortedCompletions = completions
            .filter { $0.habit == habit }
            .map { calendar.startOfDay(for: $0.date) }
            .sorted(by: >)
        
        guard !sortedCompletions.isEmpty else { return 0 }
        
        var streak = 1
        var currentDate = calendar.startOfDay(for: Date())
        
        // Loopar bakåt från idag och ökar streak om dagarna är i följd
        for i in 1..<sortedCompletions.count {
            let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
            if calendar.isDate(sortedCompletions[i], inSameDayAs: previousDate) {
                streak += 1
                currentDate = previousDate
            } else {
                break
            }
        }
        
        return streak
    }
    
    // Visar en rad med info om streaken för en vana
    private struct HabitStreakRow: View {
        let habit: Habit
        let streak: Int
        
        var body: some View {
            HStack(spacing: 12) {
                // Emoji-symbol med färgad cirkel i bakgrunden
                ZStack {
                    Circle()
                        .fill(Color(hex: habit.color))
                        .frame(width: 40, height: 40)
                    
                    Text(habit.emoji)
                        .font(.title2)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(habit.name)
                        .font(.subheadline)
                        .bold()
                    
                    Text("\(streak) day streak")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // Cirkeldiagram som visar streakens längd visuellt
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray5), lineWidth: 3)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(min(streak, 30)) / 30)
                        .stroke(streakColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(streak)")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(streakColor)
                }
                .frame(width: 30, height: 30)
            }
            .padding(.vertical, 8)
        }
        
        // Färgskala beroende på streakens längd
        private var streakColor: Color {
            switch streak {
            case 0..<3: return .gray
            case 3..<7: return .blue
            case 7..<14: return .green
            case 14..<21: return .orange
            default: return .red
            }
        }
    }
}

// Kort som visar procent av slutförda dagar de senaste 30 dagarna
private struct CompletionRateCard: View {
    let habits: [Habit]
    let completions: [HabitCompletion]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HeaderView(title: "📊 Completion Rates", subtitle: "Last 30 days performance")
            
            ForEach(habits) { habit in
                HabitCompletionRow(habit: habit, rate: completionRate(for: habit))
            }
        }
        .cardStyle()
    }
    
    // Räknar ut hur många dagar av 30 en vana har slutförts
    private func completionRate(for habit: Habit) -> Double {
        let last30Days = Date().last30Days
        let completedDays = completions
            .filter { $0.habit == habit && last30Days.contains($0.date.startOfDay) }
            .count
        
        return min(Double(completedDays) / 30.0, 1.0)
    }
    
    // Visar rad med emoji, namn, progress bar och procent
    private struct HabitCompletionRow: View {
        let habit: Habit
        let rate: Double
        
        var body: some View {
            HStack(spacing: 12) {
                // Emoji-symbol i cirkel med bakgrundsfärg
                Text(habit.emoji)
                    .font(.title2)
                    .padding(8)
                    .background(Color(hex: habit.color).opacity(0.2))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.name)
                        .font(.subheadline)
                        .bold()
                    
                    ProgressView(value: rate, total: 1.0)
                        .tint(Color(hex: habit.color))
                        .scaleEffect(x: 1, y: 1.5, anchor: .leading)
                }
                
                Spacer()
                
                Text("\(Int(rate * 100))%")
                    .font(.subheadline)
                    .bold()
                    .foregroundColor(Color(hex: habit.color))
            }
            .padding(.vertical, 8)
        }
    }
}

// Veckovis aktivitet i grid format som visar vilka dagar vanan slutförts
private struct WeeklyHabitActivity: View {
    let habits: [Habit]
    let completions: [HabitCompletion]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HeaderView(title: "🗓️ This Week", subtitle: "Daily completion overview")
            
            ForEach(habits) { habit in
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        Text(habit.emoji)
                            .font(.title2)
                        
                        Text(habit.name)
                            .font(.subheadline)
                            .bold()
                        
                        Spacer()
                    }
                    
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(Date().last7Days, id: \.self) { date in
                            DayIndicator(
                                date: date,
                                isCompleted: isCompleted(habit: habit, date: date),
                                color: Color(hex: habit.color)
                            )
                        }
                    }
                }
                .padding(.vertical, 8)
            }
        }
        .cardStyle()
    }
    
    // Kollar om en vana är slutförd för ett visst datum
    private func isCompleted(habit: Habit, date: Date) -> Bool {
        completions.contains {
            $0.habit == habit && Calendar.current.isDate($0.date, inSameDayAs: date)
        }
    }
    
    // Visar cirkel för varje dag: färgad om slutförd, grå annars
    private struct DayIndicator: View {
        let date: Date
        let isCompleted: Bool
        let color: Color
        
        var body: some View {
            VStack(spacing: 2) {
                Text(date.weekdayInitial)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                ZStack {
                    Circle()
                        .fill(isCompleted ? color : Color(.systemGray5))
                        .frame(width: 24, height: 24)
                    
                    if isToday {
                        Circle()
                            .stroke(Color.accentColor, lineWidth: 2)
                            .frame(width: 28, height: 28)
                    }
                }
            }
            .frame(height: 40)
        }
        
        // Markerar dagens datum
        private var isToday: Bool {
            Calendar.current.isDateInToday(date)
        }
    }
}

// Kalender som visar habit-aktivitet för hela månaden
private struct MonthlyHabitCalendar: View {
    let habits: [Habit]
    let completions: [HabitCompletion]
    private let columns = Array(repeating: GridItem(.flexible()), count: 7)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HeaderView(title: "📅 Monthly Overview", subtitle: "Your habit completion this month")
            
            LazyVGrid(columns: columns, spacing: 8) {
                ForEach(Date().currentMonthDates, id: \.self) { date in
                    CalendarDayCell(date: date, habits: habits, completions: completions)
                }
            }
        }
        .cardStyle()
    }
    
    // Visar varje dag med eventuella "dots" för habits som slutförts
    private struct CalendarDayCell: View {
        let date: Date
        let habits: [Habit]
        let completions: [HabitCompletion]
        
        var body: some View {
            VStack(spacing: 2) {
                Text("\(date.day)")
                    .font(.caption2)
                    .foregroundColor(textColor)
                    .frame(width: 24, height: 24)
                    .background(isToday ? Color.accentColor : Color.clear)
                    .clipShape(Circle())
                
                // Visar upp till 5 färgade prickar för slutförda habits per dag
                HStack(spacing: 2) {
                    ForEach(completedHabits.prefix(5)) { habit in
                        Circle()
                            .fill(Color(hex: habit.color))
                            .frame(width: 4, height: 4)
                    }
                }
                
                // Om fler än 5, visa "+ fler antal habits"
                if completedHabits.count > 5 {
                    Text("+\(completedHabits.count - 3)")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .frame(height: 50)
            .opacity(isInCurrentMonth ? 1.0 : 0.3)
        }
        
        private var completedHabits: [Habit] {
            habits.filter { habit in
                completions.contains {
                    $0.habit == habit && Calendar.current.isDate($0.date, inSameDayAs: date)
                }
            }
        }
        
        private var isToday: Bool {
            Calendar.current.isDateInToday(date)
        }
        
        private var isInCurrentMonth: Bool {
            Calendar.current.isDate(date, equalTo: Date(), toGranularity: .month)
        }
        
        private var textColor: Color {
            if isToday {
                return .white
            } else if Calendar.current.isDateInWeekend(date) {
                return .secondary
            } else {
                return .primary
            }
        }
    }
}

// Återanvändbar rubrik med titel och undertitel
private struct HeaderView: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// Modifierare för kortdesign med padding, bakgrund och rundade hörn
extension View {
    func cardStyle() -> some View {
        self
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
    }
}

// Datum förlängningar för att enkelt få t.ex. senaste 7 dagar, aktuell månad etc.
private extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    var last7Days: [Date] {
        (0..<7).map {
            Calendar.current.date(byAdding: .day, value: -$0, to: startOfDay)!
        }.reversed()
    }
    
    var last30Days: [Date] {
        (0..<30).map {
            Calendar.current.date(byAdding: .day, value: -$0, to: startOfDay)!
        }.reversed()
    }
    
    var currentMonthDates: [Date] {
        let calendar = Calendar.current
        let currentMonth = calendar.component(.month, from: self)
        let currentYear = calendar.component(.year, from: self)
        
        var dateComponents = DateComponents(year: currentYear, month: currentMonth, day: 1)
        guard let firstOfMonth = calendar.date(from: dateComponents) else { return [] }
        
        let range = calendar.range(of: .day, in: .month, for: firstOfMonth)!
        let days = range.map { day -> Date in
            dateComponents.day = day
            return calendar.date(from: dateComponents)!
        }
        
        let weekdayOfFirst = calendar.component(.weekday, from: firstOfMonth)
        let padding = (weekdayOfFirst - calendar.firstWeekday + 7) % 7
        let paddingDates = (0..<padding).map {
            calendar.date(byAdding: .day, value: -($0 + 1), to: firstOfMonth)!
        }.reversed()
        
        return paddingDates + days
    }
    
    var weekdayInitial: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: self).prefix(1)).uppercased()
    }
    
    var day: Int {
        Calendar.current.component(.day, from: self)
    }
}
