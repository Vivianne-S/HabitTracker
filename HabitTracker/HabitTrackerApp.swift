//
//  HabitTrackerApp.swift
//  HabitTracker
//
//  Created by Vivianne Sonnerborg on 2025-04-30.
//
/*
Huvudfilen för HabitTracker-appen som ansvarar för att:
- Starta appen och visa ContentView som huvudvy
- Initiera datamodeller med SwiftData (Habit och HabitCompletion)
- Begära tillstånd för push-notiser
- Tillgängliggöra NotificationManager som miljöobjekt i hela appen

Innehåller:
1. @main HabitTrackerApp:
   - Konfigurerar appens fönstergrupp och miljö
   - Använder .modelContainer för att koppla SwiftData-modeller
   - Använder .environmentObject för att dela NotificationManager
   - Anropar requestAuthorization() när appen startar

2. NotificationManager:
   - En ObservableObject som hanterar:
     - Begäran om notistillstånd (alert, ljud, badge)
     - Visning av notiser även när appen är aktiv (banner + ljud)
   - Används för att planera och hantera notiser i hela appen

Användning:
- Gör det möjligt att skicka dagliga påminnelser för vanor
- Säkerställer att användaren får visuell och auditiv feedback från notiser

Viktig för:
- Påminnelsefunktion i AddHabitView
- Helhetsupplevelsen av appen med hjälp av notifikationer
*/


import SwiftUI
import SwiftData
import UserNotifications

@main
struct HabitTrackerApp: App {
    // Skapar en instans av NotificationManager som hanterar notiser
    @StateObject private var notificationManager = NotificationManager()
    
    var body: some Scene {
        WindowGroup {
            // Startar appen med ContentView som huvudvy
            ContentView()
                // Skapar datamodellen för Habit och HabitCompletion
                .modelContainer(for: [Habit.self, HabitCompletion.self])
                // Gör notificationManager tillgänglig i hela appen
                .environmentObject(notificationManager)
                // Begär notis tillstånd när appen startar
                .onAppear {
                    notificationManager.requestAuthorization()
                }
        }
    }
}

// Klass för att hantera notis tillstånd och beteende
class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    
    // Begär tillstånd att skicka notiser
    func requestAuthorization() {
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                print("Notification permission granted")
            }
        }
    }
    
    // Visa notiser som banner + ljud även när appen är öppen
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                 willPresent notification: UNNotification,
                                 withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
