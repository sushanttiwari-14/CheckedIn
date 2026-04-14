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

    private var modelContext: ModelContext?
    private let locationService = LocationService()

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
            aiLabel: "Item",
            aiState: "Checking...",
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
