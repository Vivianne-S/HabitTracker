//
//  AddHabitView.swift
//  HabitTracker
//
//  Created by Vivianne Sonnerborg on 2025-04-30.
//

import SwiftUI
import SwiftData

struct AddHabitView: View {
    @Environment(\.modelContext) private var context
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String = ""
    @State private var emoji: String = "⭐️"
    @State private var showingEmojiPicker = false
    @State private var selectedColor: String = "2A4D69"
    @State private var reminderEnabled: Bool = false
    @State private var reminderTime: Date = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date()) ?? Date()
    
    let colors = ["2A4D69",
                  "4B86B4",
                  "63B76C",
                  "FFA630",
                  "E15554",
                  "7768AE",
                  "009688",
                  "8BC34A",
                  "F06292",
                  "FF7043",
                  "BA68C8",
                  "FFD54F",
                  "90A4AE",
                  "00ACC1",
                  "6D4C41",
                  "AED581",
                  "F48FB1",
                  "DCE775",
                  "FF8A65",
                  "4DD0E1"
    ]
    let emojis = ["🏃‍♂️", "💧", "📖", "🧘", "🍎", "🛌", "✍️", "🚭", "🧠", "❤️", "🥳","🦷", "💪", "💅", "🎶", "🪴", "✈️", "🚘", "🎨", "⚽️", "🏀", "🏈", "🎾", "🏓", "🏒", "🏕️", "🔑", "💻", "📈", "🦮", "🍄‍🟫", "🍽️"]
    
    var body: some View {
        NavigationStack {
            Form {
                habitDetailsSection
                colorSelectionSection
                reminderSection
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
        }
    }
    
    
    private var habitDetailsSection: some View {
        Section(header: Text("Habit Details")) {
            TextField("Name", text: $name)
                .autocapitalization(.words)
            
            emojiSelectionView
        }
    }
    
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
                                    emoji = emojiOption
                                    showingEmojiPicker = false
                                }
                        }
                    }
                    .padding(.vertical, 8)
                    .frame(height: 50) // Fast höjd för bättre layout
                }
                .frame(maxWidth: .infinity)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
        }
    }
    
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
    
    private var reminderSection: some View {
        Section(header: Text("Reminder")) {
            Toggle("Enable Reminder", isOn: $reminderEnabled)
            
            if reminderEnabled {
                DatePicker("Time", selection: $reminderTime, displayedComponents: .hourAndMinute)
            }
        }
    }
    
    
    private func saveHabit() {
        let newHabit = Habit(
            name: name,
            emoji: emoji,
            color: selectedColor
        )
        
        if reminderEnabled {
            newHabit.reminderTime = reminderTime
            // Schedule notification (implementation needed)
        }
        
        context.insert(newHabit)
        dismiss()
    }
}
