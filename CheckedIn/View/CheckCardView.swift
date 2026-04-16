//
//  CheckCardView.swift
//  CheckedIn
//
//  Created by sushant tiwari on 12/04/26.
//

import SwiftUI

struct CheckCardView: View {
    let check: SafeCheck

    var body: some View {
        HStack(spacing: 14) {
            photoThumbnail
            cardInfo
            Spacer()
            trailingInfo
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(Color(.secondarySystemGroupedBackground))
        .contentShape(Rectangle())
    }

    private var photoThumbnail: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(.tertiarySystemGroupedBackground))
                .frame(width: 56, height: 56)
            if let data = check.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 56, height: 56)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                Image(systemName: iconForLabel(check.aiLabel))
                    .font(.system(size: 24, weight: .medium))
                    .foregroundStyle(Color.brand.teal)
            }
        }
    }

    private var cardInfo: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(check.aiLabel)
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.primary)
            Label(check.locationName, systemImage: "location.fill")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .lineLimit(1)
            stateBadge
                .padding(.top, 2)
        }
    }

    private var stateBadge: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(badgeColor)
                .frame(width: 7, height: 7)
            Text(badgeText)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(badgeColor)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 4)
        .background(badgeColor.opacity(0.1))
        .clipShape(Capsule())
    }

    private var badgeText: String {
        switch check.aiState {
        case "OFF":     return "Turned off"
        case "LOCKED":  return "Locked"
        case "CLOSED":  return "Closed"
        case "CHECKED": return "Looks safe"
        default:        return "Please check now"
        }
    }

    private var badgeColor: Color {
        switch check.aiState {
        case "OFF", "LOCKED", "CLOSED", "CHECKED":
            return Color.brand.safeGreen
        default:
            return Color.brand.danger
        }
    }

    private var trailingInfo: some View {
        VStack(alignment: .trailing, spacing: 6) {
            Image(systemName: check.isVerified ? "checkmark.seal.fill" : "exclamationmark.circle.fill")
                .font(.system(size: 24))
                .foregroundStyle(check.isVerified ? Color.brand.teal : Color.brand.danger)
            Text(timeAgo)
                .font(.system(size: 12))
                .foregroundStyle(.tertiary)
        }
    }

    private func iconForLabel(_ label: String) -> String {
        switch label.lowercased() {
        case "stove", "oven":   return "flame.fill"
        case "lock", "door":    return "lock.fill"
        case "window":          return "rectangle.inset.filled"
        case "light":           return "lightbulb.fill"
        case "tap":             return "drop.fill"
        case "gas valve":       return "gauge.medium"
        case "iron":            return "iron.fill"
        default:                return "shield.fill"
        }
    }

    private var timeAgo: String {
        let f = RelativeDateTimeFormatter()
        f.unitsStyle = .abbreviated
        return f.localizedString(for: check.timestamp, relativeTo: Date())
    }
}

#Preview("Verified — Stove") {
    CheckCardView(check: SafeCheck(
        timestamp: Date(),
        locationName: "Kitchen — Home",
        aiLabel: "Stove",
        aiState: "OFF",
        confidenceScore: 0.92,
        isVerified: true
    ))
    .background(Color(.secondarySystemGroupedBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .padding()
    .background(Color(.systemGroupedBackground))
}

#Preview("Needs Attention — Door") {
    CheckCardView(check: SafeCheck(
        timestamp: Date().addingTimeInterval(-7200),
        locationName: "Garage — Home",
        aiLabel: "Door",
        aiState: "ON — CHECK THIS",
        confidenceScore: 0.61,
        isVerified: false
    ))
    .background(Color(.secondarySystemGroupedBackground))
    .clipShape(RoundedRectangle(cornerRadius: 12))
    .padding()
    .background(Color(.systemGroupedBackground))
}
