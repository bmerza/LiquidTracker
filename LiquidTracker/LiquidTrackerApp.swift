//
//  LiquidTrackerApp.swift
//  LiquidTracker
//
//  Created by Bogdan Merza on 20.11.24.
//

import SwiftUI

@main
struct LiquidTrackerApp: App {
    init() {
        ReminderManager.shared.requestAuthorization()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
