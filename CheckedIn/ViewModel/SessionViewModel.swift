//
//  SessionViewModel.swift
//  CheckedIn
//
//  Created by sushant tiwari on 19/04/26.
//

import Foundation
import Observation
import SwiftData
import UIKit
import SwiftUI
import CoreLocation

@Observable
class SessionViewModel {
    var sessionChecks: [SessionCheck]
    var currentIndex: Int = 0
    var isAnalysing: Bool = false
    var sessionComplete: Bool = false

    private var modelContext: ModelContext?
    private let visionService = VisionService()
    private let locationService: LocationService
    private let speechService = SpeechService.shared

    var currentSessionCheck: SessionCheck? {
        guard currentIndex < sessionChecks.count else { return nil }
        return sessionChecks[currentIndex]
    }

    var currentItem: SessionItem? {
        currentSessionCheck?.item
    }

    var progress: Double {
        guard !sessionChecks.isEmpty else { return 0 }
        let completed = sessionChecks.filter { $0.isComplete }.count
        return Double(completed) / Double(sessionChecks.count)
    }

    var allVerified: Bool {
        sessionChecks.allSatisfy { $0.verdict?.isConfirmed == true }
    }

    var completedChecks: [SessionCheck] {
        sessionChecks.filter { $0.isComplete }
    }

    init(items: [SessionItem] = SessionItem.defaultItems, locationService: LocationService) {
        self.sessionChecks = items.map { SessionCheck(item: $0) }
        self.locationService = locationService
    }

    func setup(context: ModelContext) {
        self.modelContext = context
    }

    func submitPhoto(_ photoData: Data, for index: Int) {
        guard index < sessionChecks.count else { return }
        isAnalysing = true

        sessionChecks[index].photoData = photoData
        let compressed = compressPhoto(photoData)

        visionService.analyse(imageData: compressed) { [weak self] label, state, confidence in
            guard let self else { return }

            let tempCheck = self.makeTempCheck(label: label, state: state, confidence: confidence)
            let formatted = VerdictFormatter.verdict(for: tempCheck)

            let verdict = VerdictFormatter.Verdict(
                headline: formatted.headline,
                symbol: confidence >= 0.75
                    ? "checkmark.circle.fill"
                    : "exclamationmark.triangle.fill",
                symbolColor: confidence >= 0.75
                    ? Color(red: 0.322, green: 0.718, blue: 0.533)
                    : Color(red: 0.914, green: 0.769, blue: 0.408),
                isConfirmed: confidence >= 0.75
            )

            self.sessionChecks[index].verdict = verdict
            self.saveCheckToFeed(
                photoData: compressed,
                label: label,
                state: state,
                confidence: confidence,
                index: index
            )
            self.isAnalysing = false

            if verdict.isConfirmed {
                self.speechService.speak(verdict.headline)
            }
        }
    }

    func advanceToNext() {
        if currentIndex < sessionChecks.count - 1 {
            currentIndex += 1
        } else {
            sessionComplete = true
            speakClosureLine()
        }
    }

    func skipCurrent() {
        advanceToNext()
    }

    private func speakClosureLine() {
        let line = allVerified
            ? "Everything is checked. You can leave now."
            : "Session complete. You can leave now."
        speechService.speak(line)
    }

    private func saveCheckToFeed(
        photoData: Data,
        label: String,
        state: String,
        confidence: Double,
        index: Int
    ) {
        guard let context = modelContext else { return }

        let location = locationService.currentLocation
        let locationName = locationService.currentLocationName

        let check = SafeCheck(
            photoData: photoData,
            timestamp: Date(),
            locationName: locationName.isEmpty ? "Unknown Location" : locationName,
            latitude: location?.coordinate.latitude ?? 0.0,
            longitude: location?.coordinate.longitude ?? 0.0,
            aiLabel: label,
            aiState: state,
            confidenceScore: confidence,
            isVerified: confidence >= 0.75
        )

        context.insert(check)

        do {
            try context.save()
            sessionChecks[index].savedCheck = check
        } catch {
            print("Session save error: \(error)")
        }
    }

    private func makeTempCheck(label: String, state: String, confidence: Double) -> SafeCheck {
        SafeCheck(
            aiLabel: label,
            aiState: state,
            confidenceScore: confidence
        )
    }

    private func compressPhoto(_ data: Data) -> Data {
        guard let image = UIImage(data: data) else { return data }
        return image.jpegData(compressionQuality: 0.6) ?? data
    }
}
