//
//  SessionCheck.swift
//  CheckedIn
//
//  Created by sushant tiwari on 19/04/26.
//

import Foundation

struct SessionCheck: Identifiable {
    let id: UUID = UUID()
    let item: SessionItem
    var photoData: Data?
    var verdict: VerdictFormatter.Verdict?
    var savedCheck: SafeCheck?
    var isComplete: Bool { savedCheck != nil }
}
