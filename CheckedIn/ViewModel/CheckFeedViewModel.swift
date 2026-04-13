//
//  CheckFeedViewModel.swift
//  CheckedIn
//
//  Created by sushant tiwari on 12/04/26.
//

import Foundation
import SwiftData
import Observation

@Observable
class CheckFeedViewModel {
    var pendingPhotoData: Data? = nil
    var checks: [SafeCheck] = [
        SafeCheck(
            timestamp: Date(),
            locationName: "Kitchen — Home",
            aiLabel: "Stove",
            aiState: "OFF",
            confidenceScore: 0.92,
            isVerified: true
        ),
        SafeCheck(
            timestamp: Date().addingTimeInterval(-3600),
            locationName: "Front Door — Home",
            aiLabel: "Lock",
            aiState: "LOCKED",
            confidenceScore: 0.88,
            isVerified: true
        ),
        SafeCheck(
            timestamp: Date().addingTimeInterval(-7200),
            locationName: "Garage — Home",
            aiLabel: "Door",
            aiState: "ON — CHECK THIS",
            confidenceScore: 0.61,
            isVerified: false
        )
    ]
}
