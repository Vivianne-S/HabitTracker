//
//  Extensions.swift
//  HabitTracker
//
//  Created by Vivianne Sonnerborg on 2025-04-30.
//
/*
Extension för att möjliggöra färginitiering från hex-kod i SwiftUI.

Innehåll:
- Color(hex:) — en initialiserare för SwiftUI's Color som accepterar en hex-sträng

Stödda format:
- 3 tecken (RGB, 12-bit), t.ex. "F80"
- 6 tecken (RGB, 24-bit), t.ex. "FF8800"
- 8 tecken (ARGB, 32-bit), t.ex. "FFFF8800" (för färg med alfa)

Användning:
Color(hex: "FF7043") returnerar en Color med färgen #FF7043

Funktionalitet:
- Tar bort icke-alfanumeriska tecken från hex-strängen
- Konverterar till RGB- eller ARGB-värden
- Returnerar motsvarande SwiftUI-färg

Används i:
- AddHabitView (för färgväljaren)
- Visuell stil i habit-listor, cirklar och indikatorer

Viktig för:
- Möjliggör designanpassning med hex-färgkoder
- Gör färghantering mer intuitiv och återanvändbar i hela appen
*/

import SwiftUI

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
