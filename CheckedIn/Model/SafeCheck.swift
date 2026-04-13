//
//  SafeCheck.swift
//  CheckedIn
//
//  Created by sushant tiwari on 12/04/26.
//

import Foundation
import SwiftData

@Model
class SafeCheck {
    var id: UUID
    var photoData: Data?
    var timestamp: Date
    var locationName: String
    var latitude: Double
    var longitude: Double
    var aiLabel: String
    var aiState: String
    var confidenceScore: Double
    var isVerified: Bool

    init(
        id: UUID = UUID(),
        photoData: Data? = nil,
        timestamp: Date = Date(),
        locationName: String = "Unknown Location",
        latitude: Double = 0.0,
        longitude: Double = 0.0,
        aiLabel: String = "Unknown",
        aiState: String = "Checking...",
        confidenceScore: Double = 0.0,
        isVerified: Bool = false
    ) {
        self.id = id
        self.photoData = photoData
        self.timestamp = timestamp
        self.locationName = locationName
        self.latitude = latitude
        self.longitude = longitude
        self.aiLabel = aiLabel
        self.aiState = aiState
        self.confidenceScore = confidenceScore
        self.isVerified = isVerified
    }
}
