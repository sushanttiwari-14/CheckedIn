//
//  ExpiryService.swift
//  CheckedIn
//
//  Created by sushant tiwari on 19/04/26.
//

import Foundation
import SwiftData

class ExpiryService {

    static let shared = ExpiryService()

    private init() {}

    private let expiryInterval: TimeInterval = 24 * 60 * 60 // 24 hours

    func purgeExpired(from context: ModelContext) {
        let cutoff = Date().addingTimeInterval(-expiryInterval)

        let descriptor = FetchDescriptor<SafeCheck>(
            predicate: #Predicate { check in
                check.timestamp < cutoff
            }
        )

        do {
            let expired = try context.fetch(descriptor)
            for check in expired {
                context.delete(check)
            }
            if !expired.isEmpty {
                try context.save()
                print("ExpiryService: purged \(expired.count) expired check(s)")
            }
        } catch {
            print("ExpiryService purge error: \(error)")
        }
    }
}
