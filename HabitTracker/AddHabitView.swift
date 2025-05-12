//
//  AddHabitView.swift
//  HabitTracker
//
//  Created by Vivianne Sonnerborg on 2025-04-30.
//
/*
Vy för att skapa en ny vana i HabitTracker.

Huvudfunktioner:
- Låter användaren skriva in ett namn och välja en emoji som representerar vanan
- Ger möjlighet att välja en färg som används för visuell representation i appen
- Möjlighet att aktivera påminnelser och välja tid för notifikation
- Sparar ny vana till SwiftData-modellen och schemalägger notis vid behov

Tillstånd:
- name: Namn på den nya vanan
- emoji: Symbol för vanan (väljs från en emoji-lista)
- selectedColor: Färgkod i hex för visuell stil
- reminderEnabled: Bool som styr om påminnelse är aktiv
- reminderTime: Tidpunkt för påminnelse (används om reminderEnabled är true)

Komponenter:
- Form med tre sektioner: Habit Details, Color och Reminder
- EmojiPicker: En horisontell scrollvy med valbara emojis
- ColorPicker: Scrollbar färgväljare med förhandsvisning
- DatePicker: Tidväljarfält för påminnelser (visas om toggle är aktiv)
- Toolbar: Cancel- och Save-knappar

Funktionalitet:
- requestNotificationPermission(): Begär tillstånd för att skicka notiser
- scheduleNotification(for:): Skapar återkommande påminnelser via UNNotificationCenter
- saveHabit(): Skapar och sparar en Habit-instans samt schemalägger eventuell notis

Viktig för:
- Onboarding av nya vanor
- Säkerställande av att användaren får notiser vid rätt tidpunkt
- En tydlig, visuell och motiverande start för varje ny vana
*/

import SwiftUI
import SwiftData
import UserNotifications

struct AddHabitView: View {
    // Hämtar kontexten för att använda modellen och för att stänga vyn
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    // Tillstånd för nya habit detaljer
    @State private var name: String = ""
    @State private var emoji: String = "⭐️"
    @State private var showingEmojiPicker = false
    @State private var selectedColor: String = "2A4D69"
    @State private var reminderEnabled: Bool = false
    @State private var reminderTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    @State private var showReminderAlert: Bool = false
    
    // Färg alternativen för ny habit
    let colors = ["2A4D69", "4B86B4", "63B76C", "FFA630", "E15554", "7768AE", "009688", "8BC34A", "F06292", "FF7043", "BA68C8", "FFD54F", "90A4AE", "00ACC1", "6D4C41", "AED581", "F48FB1", "DCE775", "FF8A65", "4DD0E1"]
    
    // emojis som representerar olika habits
    let emojis = ["🏃‍♂️","💪", "🧘","📖", "✍️", "🎨", "🍎", "🍽️", "💻", "📈", "🦮", "🛌", "🛁", "🎶", "🪴", "⚽️", "🏀", "🏈", "🎾", "🏓", "🏒"]
    
    var body: some View {
        NavigationStack {
            Form {
                habitDetailsSection  // Sektion för habit detaljerna
                colorSelectionSection // Sektion för färgval
                reminderSection      // Sektion för påminnelseinställningar
            }
            .navigationTitle("New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveHabit() }
                        .disabled(name.isEmpty)
                }
            }
            .alert("Reminder Set", isPresented: $showReminderAlert) {
                Button("OK") { }
            } message: {
                Text("You'll be reminded at \(reminderTime.formatted(date: .omitted, time: .shortened)) to \(name)")
            }
        }
    }
    
    // Vyn för att lägga till ny habit med namn
    private var habitDetailsSection: some View {
        Section(header: Text("Habit Details")) {
            TextField("Name", text: $name)
                .autocapitalization(.words)
            emojiSelectionView
        }
    }
    
    // Vyn för lägga till emoji till nya habiten
    private var emojiSelectionView: some View {
        Group {
            HStack {
                Text("Emoji")
                Spacer()
                Text(emoji)
                    .font(.title)
                    .padding(8)
                    .background(Color(.systemGray5))
                    .cornerRadius(8)
                    .onTapGesture { showingEmojiPicker.toggle() }
            }
            
            if showingEmojiPicker {
                // Emoji väljare som scrollar horisontellt
                ScrollView(.horizontal, showsIndicators: true) {
                    LazyHStack(spacing: 12) {
                        ForEach(emojis, id: \.self) { emojiOption in
                            Text(emojiOption)
                                .font(.title)
                                .padding(10)
                                .background(
                                    emoji == emojiOption ? Color(.systemGray4) : Color(.systemBackground)
                                )
                                .cornerRadius(8)
                                .onTapGesture {
                                    emoji = emojiOption // Välj emoji
                                    showingEmojiPicker = false // Stäng väljaren
                                }
                        }
                    }
                    .padding(.vertical, 8)
                    .frame(height: 50)
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
        }
    }
    
    // Vyn för att lägga till färg till ny habit som sen blir bakgrunden för cirkeln runt habiten som visas i ContentView
    private var colorSelectionSection: some View {
        Section(header: Text("Color")) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(colors, id: \.self) { color in
                        Circle()
                            .fill(Color(hex: color))
                            .frame(width: 30, height: 30)
                            .overlay(
                                Circle()
                                    .stroke(selectedColor == color ? Color.primary : Color.clear, lineWidth: 2)
                            )
                            .onTapGesture { selectedColor = color }
                    }
                }
                .padding(.vertical, 8)
            }
        }
    }
    
    // Vyn för att lägga till tid för en ny vana för att få en notis
    private var reminderSection: some View {
        Section(header: Text("Reminder")) {
            Toggle("Enable Reminder", isOn: $reminderEnabled)
                .onChange(of: reminderEnabled) { oldValue, newValue in
                    if newValue {
                        requestNotificationPermission() // Be om notifikationsrättigheter
                    }
                }
            
            if reminderEnabled {
                DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                    .onChange(of: reminderTime) { oldValue, newValue in
                        if reminderEnabled {
                            showReminderAlert = true
                        }
                    }
            }
        }
    }
    
    // Begär tillstånd för att visa notifikationer
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // Schemalägg en notis för habit om den angavs vid skapande av ny habit
    private func scheduleNotification(for habit: Habit) {
        guard let reminderTime = habit.reminderTime else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Habit Reminder"
        content.body = "Time to \(habit.name) \(habit.emoji)"
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Notification scheduled for \(habit.name) at \(reminderTime)")
            }
        }
    }
    
    // Funktion för att spara ny habit
    private func saveHabit() {
        let newHabit = Habit(
            name: name,
            emoji: emoji,
            color: selectedColor
        )
        
        if reminderEnabled {
            newHabit.reminderTime = reminderTime
            scheduleNotification(for: newHabit) // Schemalägg notifikation om påminnelse är aktiverad
        }
        
        context.insert(newHabit) // Spara habit i modellen
        dismiss() // Stänger ny habit vyn
    }
}

