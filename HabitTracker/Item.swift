//
//  Item.swift
//  HabitTracker
//
//  Created by Vivianne Sonnerborg on 2025-04-30.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
