//
//  SettingsViewModel.swift
//  CheckedIn
//
//  Created by sushant tiwari on 19/04/26.
//

import Foundation
import Observation
import SwiftData

@Observable
class SettingsViewModel {

    var voiceConfirmationEnabled: Bool {
        didSet {
            UserDefaults.standard.set(voiceConfirmationEnabled, forKey: Keys.voiceEnabled)
        }
    }

    var showClearConfirmation: Bool = false
    var didClearChecks: Bool = false

    private var modelContext: ModelContext?

    private enum Keys {
        static let voiceEnabled = "checkedin.voiceEnabled"
    }

    init() {
        let stored = UserDefaults.standard.object(forKey: Keys.voiceEnabled)
        self.voiceConfirmationEnabled = stored as? Bool ?? true
    }

    func setup(context: ModelContext) {
        self.modelContext = context
    }

    func clearAllChecks() {
        guard let context = modelContext else { return }

        let descriptor = FetchDescriptor<SafeCheck>()
        do {
            let all = try context.fetch(descriptor)
            for check in all {
                context.delete(check)
            }
            try context.save()
            didClearChecks = true
        } catch {
            print("Clear error: \(error)")
        }
    }
}
