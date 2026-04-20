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
    @Environment(\.scenePhase) private var scenePhase
    @State private var modelContainer: ModelContainer = {
        try! ModelContainer(for: SafeCheck.self)
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .active {
                        ExpiryService.shared.purgeExpired(
                            from: modelContainer.mainContext
                        )
                    }
                }
        }
        .modelContainer(modelContainer)
    }
}
