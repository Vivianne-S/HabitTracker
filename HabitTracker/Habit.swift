//
//  Habit.swift
//  HabitTracker
//
//  Created by Vivianne Sonnerborg on 2025-04-30.
//
/*
Modellklass för en vana i HabitTracker. Representerar en aktivitet som användaren vill följa dagligen.

Egenskaper:
- name: Namn på vanan (t.ex. "Träna", "Läsa")
- emoji: En visuell symbol för vanan
- streak: Antal dagar i rad som vanan följts
- lastCompleted: Datum då vanan senast markerades som klar
- creationDate: Datum då vanan skapades
- reminderTime: Tidpunkt då användaren vill bli påmind om vanan
- color: Färgkod i hex för att ge vanan ett unikt visuellt tema
- completions: Lista över tillfällen då vanan har slutförts (med deleteRule: .cascade)

Funktionalitet:
- isCompletedToday: Bool som kontrollerar om vanan markerats som klar idag

Användning:
- Visas i HomeView för att följa upp vanor
- Används i statistik (t.ex. streaks, kalender)
- Kopplas till notiser via reminderTime
- Har relation till HabitCompletion för loggning av aktivitet

Datamodell:
- SwiftData-modell (@Model) som kan sparas och hämtas automatiskt
- Använder en-till-många-relation till HabitCompletion

Viktig för:
- Daglig vanespårning
- Visualisering av streaks och historik
- Påminnelser och statistik i appen
*/

import Foundation
import SwiftData

// Modellklass som representerar en vana som användaren vill följa
@Model
final class Habit {
    // Namn på vanan (t.ex. "Träna", "Meditera")
    var name: String
    
    // En emoji som symboliserar vanan
    var emoji: String
    
    // Antal dagar i rad som vanan har följts
    var streak: Int
    
    // Datum då vanan senast markerades som klar
    var lastCompleted: Date?
    
    // Datum då vanan skapades
    var creationDate: Date
    
    // Tidpunkt på dagen då användaren vill bli påmind
    var reminderTime: Date?
    
    // Färgkod (hex) som används för att visa vanan i appen
    var color: String
    
    // Lista över alla tillfällen då vanan har markerats som klar
    // Om en vana tas bort, tas även dess completion-poster bort (cascade)
    @Relationship(deleteRule: .cascade, inverse: \HabitCompletion.habit)
    var completions: [HabitCompletion] = []
    
    // Initierar en ny habit med obligatoriskt namn och emoji
    init(name: String, emoji: String, streak: Int = 0, lastCompleted: Date? = nil, color: String = "2A4D69") {
        self.name = name
        self.emoji = emoji
        self.streak = streak
        self.lastCompleted = lastCompleted
        self.creationDate = Date()
        self.color = color
    }
    
    // Returnerar true om habiten är markerad som klar idag
    var isCompletedToday: Bool {
        guard let lastCompleted = lastCompleted else { return false }
        return Calendar.current.isDateInToday(lastCompleted)
    }
}
