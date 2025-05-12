//
//  HabitCompletion.swift
//  HabitTracker
//
//  Created by Vivianne Sonnerborg on 2025-05-05.
//
/*
Modellklass för att lagra information om avklarade vanor i HabitTracker.

Innehåller:
- date: Datum då vanan markerades som klar
- habit: Referens till vilken vana som avklarades (valfri, kan vara nil om vanan tagits bort)

Syfte:
- Används för att spara och hämta data om vilka vanor som slutförts
- Kopplas till statistikvyer för att visa användarens framsteg
- Viktig för funktioner som streaks, completion rates och aktivitetskalendrar

Används tillsammans med:
- Habit: Referens till huvudvanan
- SwiftData: För lokal datalagring av användarens aktiviteter
*/

import Foundation
import SwiftData

// Modellklass som representerar en registrerad avklarad vana
@Model
final class HabitCompletion {
    // Datum då vanan markerades som avklarad
    var date: Date
    
    // Den vana som blev avklarad (valfri eftersom vanan kan ha raderats)
    var habit: Habit?

    // Initierar ett nytt HabitCompletion-objekt med datum och eventuell kopplad vana
    init(date: Date, habit: Habit? = nil) {
        self.date = date
        self.habit = habit
    }
}
