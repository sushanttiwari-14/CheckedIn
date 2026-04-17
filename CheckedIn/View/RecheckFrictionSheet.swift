//
//  RecheckFrictionSheet.swift
//  CheckedIn
//
//  Created by sushant tiwari on 18/04/26.
//

import SwiftUI

struct RecheckFrictionSheet: View {
    let result: RecentCheckResult
    let onViewLastCheck: () -> Void
    let onCheckAgain: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            header
            content
            actions
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: — Header

    private var header: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.brand.teal.opacity(0.10))
                    .frame(width: 64, height: 64)
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 30))
                    .foregroundStyle(Color.brand.teal)
            }
            .padding(.top, 28)

            Text("Already checked")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.primary)

            Text("You checked your \(result.label.lowercased()) \(timeDescription) ago.")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: — Proof preview

    private var content: some View {
        HStack(spacing: 12) {
            if let data = result.matchedCheck.photoData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(VerdictFormatter.verdict(for: result.matchedCheck).headline)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                Text(formattedTime)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }

    // MARK: — Actions

    private var actions: some View {
        VStack(spacing: 10) {
            Button(action: onViewLastCheck) {
                Text("View Last Check")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color.brand.teal)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }

            Button(action: onCheckAgain) {
                Text("Check Again Anyway")
                    .font(.system(size: 17))
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color(.secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        .padding(.bottom, 28)
    }

    // MARK: — Formatting

    private var timeDescription: String {
        if result.minutesAgo < 1 { return "just now" }
        if result.minutesAgo == 1 { return "1 minute" }
        return "\(result.minutesAgo) minutes"
    }

    private var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter.string(from: result.matchedCheck.timestamp)
    }
}

private let mockResult = RecentCheckResult(
    matchedCheck: SafeCheck(
        timestamp: Date().addingTimeInterval(-300),
        locationName: "Back Door — Home",
        aiLabel: "Door",
        aiState: "LOCKED",
        confidenceScore: 0.95,
        isVerified: true
    ),
    label: "Door",
    minutesAgo: 5
)

#Preview("Recheck Friction Sheet") {
    RecheckFrictionSheet(
        result: mockResult,
        onViewLastCheck: {},
        onCheckAgain: {},
        onDismiss: {}
    )
}
