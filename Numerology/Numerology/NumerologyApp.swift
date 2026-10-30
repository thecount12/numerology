//
//  NumerologyApp.swift
//  Numerology
//
//  Created by William Gunnells on 10/20/26.
//

import SwiftUI
import SwiftData

@main
struct NumerologyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // this injects persistent sqlite engine
        .modelContainer(for: UserProfile.self)
    }
}
