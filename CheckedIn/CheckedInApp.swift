//
//  CheckedInApp.swift
//  CheckedIn
//
//  Created by sushant tiwari on 11/04/26.
//

import SwiftUI
import SwiftData

@main
struct CheckedInApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: SafeCheck.self)
    }
}
