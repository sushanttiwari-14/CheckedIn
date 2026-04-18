//
//  CheckFeedViewModel.swift
//  CheckedIn
//
//  Created by sushant tiwari on 12/04/26.
//

import Foundation
import Observation
import SwiftData
import UIKit
import CoreLocation

@Observable
class CheckFeedViewModel {
    var checks: [SafeCheck] = []
    var pendingPhotoData: Data? = nil
    var isSaving: Bool = false
    var isAnalysing: Bool = false
    var recentCheckResult: RecentCheckResult? = nil

    var locationPermissionDenied: Bool {
        locationService.permissionDenied
    }

    private var modelContext: ModelContext?
    private let locationService = LocationService()
    private let visionService = VisionService()
    private let speechService = SpeechService.shared

    private let recheckWindowMinutes: Int = 30

    func setup(context: ModelContext) {
        self.modelContext = context
        locationService.requestPermissionAndStart()
        fetchChecks()
    }

    func fetchChecks() {
        guard let context = modelContext else { return }
        let descriptor = FetchDescriptor<SafeCheck>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        do {
            checks = try context.fetch(descriptor)
        } catch {
            print("Fetch error: \(error)")
        }
    }

    func checkForRecentDuplicate() -> Bool {
        let windowStart = Date().addingTimeInterval(-Double(recheckWindowMinutes * 60))

        let recentChecks = checks.filter {
            $0.timestamp > windowStart &&
            !$0.aiLabel.isEmpty &&
            $0.aiLabel != "Analysing..." &&
            $0.aiLabel != "Item"
        }

        guard let mostRecent = recentChecks.first else { return false }

        let minutesAgo = Int(Date().timeIntervalSince(mostRecent.timestamp) / 60)

        recentCheckResult = RecentCheckResult(
            matchedCheck: mostRecent,
            label: mostRecent.aiLabel,
            minutesAgo: minutesAgo
        )
        return true
    }

    func clearRecentCheckResult() {
        recentCheckResult = nil
    }

    func saveCheck(photoData: Data) {
        guard let context = modelContext else { return }
        isSaving = true

        let compressedData = compressPhoto(photoData)
        let location = locationService.currentLocation
        let locationName = locationService.currentLocationName

        let check = SafeCheck(
            photoData: compressedData,
            timestamp: Date(),
            locationName: locationName.isEmpty ? "Unknown Location" : locationName,
            latitude: location?.coordinate.latitude ?? 0.0,
            longitude: location?.coordinate.longitude ?? 0.0,
            aiLabel: "Analysing...",
            aiState: "Please wait",
            confidenceScore: 0.0,
            isVerified: false
        )

        context.insert(check)

        do {
            try context.save()
            fetchChecks()
        } catch {
            print("Save error: \(error)")
        }

        isSaving = false
        runAnalysis(on: check, photoData: compressedData, context: context)
    }

    private func runAnalysis(on check: SafeCheck, photoData: Data, context: ModelContext) {
        isAnalysing = true

        visionService.analyse(imageData: photoData) { [weak self] label, state, confidence in
            guard let self else { return }

            check.aiLabel = label
            check.aiState = state
            check.confidenceScore = confidence
            check.isVerified = confidence >= 0.75

            do {
                try context.save()
                self.fetchChecks()
            } catch {
                print("Analysis save error: \(error)")
            }

            self.isAnalysing = false

            if check.isVerified {
                let verdict = VerdictFormatter.verdict(for: check)
                self.speechService.speak(verdict.headline)
            }
        }
    }

    func deleteCheck(_ check: SafeCheck) {
        guard let context = modelContext else { return }
        context.delete(check)
        do {
            try context.save()
            fetchChecks()
        } catch {
            print("Delete error: \(error)")
        }
    }

    private func compressPhoto(_ data: Data) -> Data {
        guard let image = UIImage(data: data) else { return data }
        return image.jpegData(compressionQuality: 0.6) ?? data
    }
}
