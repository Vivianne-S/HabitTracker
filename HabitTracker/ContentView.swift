//
//  ContentView.swift
//  HabitTracker
//
//  Created by Vivianne Sonnerborg on 2025-04-30.
//
/*
Huvudvy för HabitTracker som visar:
- En lista över alla vanor (habits) med streaker och kompletteringsstatus
 
- "No Habits"-vy när inga vanor finns registrerade
 
- Navigering till:
  - Lägg till ny vana (via +-knapp)
  - Statistikvy (via diagram ikonen)
 
- Funktioner för:
  - Markera vanor som klara för dagen
  - Radera vanor
  - Hantera streaker
  - Schemalägga påminnelser
  - Validera streaker vid appstart
 
- Innehåller även undervyer för:
  - EmptyHabitsView - Visas när inga vanor finns
  - HabitListView - Listan över vanor
  - HabitRowView - Enstaka rad i vanelistan
*/

import SwiftUI
import SwiftData
import UserNotifications

// Visas när inga vanor ännu har lagts till
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

struct ContentView: View {
    @Environment(\.modelContext) private var context // Tillgång till databaskontexten
    @Query private var habits: [Habit] // Hämta alla vanor från databasen
    @State private var showingStats = false // Styr om statistikvyn visas

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                // Visa vy beroende på om det finns några vanor
                if habits.isEmpty {
                    EmptyHabitsView()
                } else {
                    HabitListView(habits: habits)
                }
            }
            .navigationTitle("Habit Tracker")
            .toolbar {
                // Statistik-knapp till vänster
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showingStats.toggle() }) {
                        Image(systemName: "chart.bar")
                    }
                }
                // Plus-knapp till höger för att lägga till vana
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: AddHabitView()) {
                        Image(systemName: "plus")
                    }
                }
            }
            // Visa statistik som sheet
            .sheet(isPresented: $showingStats) {
                StatisticsView(habits: habits)
            }
            // Kör vid uppstart
            .onAppear {
                requestNotificationPermission()
                validateStreaks(for: habits, context: context)
                scheduleDailyReminderNotifications(for: habits)
            }
        }
    }

    // Schemalägg dagliga påminelser för varje vana
    func scheduleDailyReminderNotifications(for habits: [Habit]) {
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests() // Ta bort gamla notiser

        for habit in habits {
            // Skicka ingen notis om vanan redan är markerad som gjord idag
                if habit.isCompletedToday {
                    print("Skipping notification for \(habit.name) – already completed today.")
                    continue
                }
            let content = UNMutableNotificationContent()
            content.title = "⏰ \(habit.name) Reminder"
            content.body = "Your \(habit.streak)-day streak is about to break! Complete it today. 🔥"
            content.sound = .default

            // Schemalägg till kl 23:00 varje dag
            var dateComponents = DateComponents()
            dateComponents.hour = 23
            dateComponents.minute = 00

            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

            let request = UNNotificationRequest(
                identifier: "\(habit.id)_daily_reminder",
                content: content,
                trigger: trigger
            )

            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error scheduling daily reminder for \(habit.name): \(error.localizedDescription)")
                } else {
                    print("Successfully scheduled daily reminder for \(habit.name)")
                }
            }
        }
    }

    /// Begär tillstånd att skicka notiser
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }

    // Kontrollerar och uppdaterar streaks
    func validateStreaks(for habits: [Habit], context: ModelContext) {
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!

        for habit in habits {
            if let last = habit.lastCompleted {
                if Calendar.current.isDate(last, inSameDayAs: today) {
                    continue // redan markerad idag
                } else if Calendar.current.isDate(last, inSameDayAs: yesterday) {
                    continue // streak kan behållas om man klarar idag
                } else {
                    // streaken har brutits
                    habit.streak = 0
                    sendNotification(for: habit, message: "Your streak has been broken!")
                }
            }
        }

        try? context.save()
    }

    //  Skicka en notis
    func sendNotification(for habit: Habit, message: String) {
        let content = UNMutableNotificationContent()
        content.title = habit.name
        content.body = message
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled successfully")
            }
        }
    }
}

// Lista över alla vanor
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

// En rad i listan för varje vana
struct HabitRowView: View {
    @Environment(\.modelContext) private var context // Databaskontext
    let habit: Habit
    @State private var showingDeleteConfirmation = false // Visar varning innan borttagning

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

            HStack(spacing: 12) {
                // Knapp för att markera vanan som klar idag
                Button(action: { markHabitDone(habit) }) {
                    Image(systemName: habit.isCompletedToday ? "checkmark.circle.fill" : "circle")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .foregroundColor(habit.isCompletedToday ? .green : .gray)
                }
                .buttonStyle(BorderlessButtonStyle())

                // Papperskorg för att radera vanan
                Button(action: { showingDeleteConfirmation = true }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
                .alert("Delete Habit", isPresented: $showingDeleteConfirmation) {
                    Button("Delete", role: .destructive) {
                        context.delete(habit)
                        try? context.save()
                    }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Are you sure you want to delete \(habit.name)?")
                }
            }
        }
        .padding(.vertical, 8)
    }

    // Markera en vana som genomförd idag
    private func markHabitDone(_ habit: Habit) {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if habit.isCompletedToday {
            return // redan markerad
        }

        // Om man klarade vanan igår, öka streak, annars börja om
        if let last = habit.lastCompleted,
           let yesterday = calendar.date(byAdding: .day, value: -1, to: today),
           calendar.isDate(last, inSameDayAs: yesterday) {
            habit.streak += 1
        } else {
            habit.streak = 1
        }

        habit.lastCompleted = today

        let newCompletion = HabitCompletion(date: today, habit: habit)
        habit.completions.append(newCompletion)

        try? context.save()
    }
}
