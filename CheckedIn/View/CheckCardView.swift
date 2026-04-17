//
//  CheckCardView.swift
//  CheckedIn
//
//  Created by sushant tiwari on 12/04/26.
//
// CheckCardView.swift

import SwiftUI

struct CheckCardView: View {
    let check: SafeCheck

    var body: some View {
        HStack(spacing: 14) {
            thumbnail
            cardBody
            Spacer(minLength: 0)
            trailingArea
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(Color(.secondarySystemGroupedBackground))
        .contentShape(Rectangle())
    }

    // MARK: - Thumbnail

    private var thumbnail: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(thumbnailBackground)
                .frame(width: 48, height: 48)
            Image(systemName: itemIcon)
                .font(.system(size: 22))
                .foregroundStyle(thumbnailIconColor)
        }
    }

    // MARK: - Card Body

    private var cardBody: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(check.aiLabel)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.primary)

            Text(verdictText)
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(verdictColor)

            Text(metaText)
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Trailing

    private var trailingArea: some View {
        HStack(spacing: 8) {
            if check.isVerified {
                Circle()
                    .fill(Color.brand.teal)
                    .frame(width: 8, height: 8)
            }
            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color(.tertiaryLabel))
        }
    }

    // MARK: - Computed Properties

    private var verdictText: String {
        let state = check.aiState.uppercased()
        switch check.aiLabel {
        case "Stove", "Iron", "Light", "Tap", "Gas Valve":
            if state.contains("OFF") || state.contains("CLOSED") { return "Off" }
            if state.contains("ON") { return "Needs checking" }
        case "Lock", "Door":
            if state.contains("LOCKED") { return "Locked" }
            if state.contains("UNLOCKED") { return "Needs checking" }
        case "Window":
            if state.contains("CLOSED") { return "Closed" }
            if state.contains("OPEN") { return "Needs checking" }
        default:
            break
        }
        if state.contains("CHECK") { return "Needs checking" }
        if state.contains("CHECKED") { return "Checked" }
        return check.aiState
    }

    private var verdictColor: Color {
        let state = check.aiState.uppercased()
        if state.contains("CHECK THIS") || state.contains("UNLOCKED") || state.contains("OPEN") || state.contains("ON —") {
            return Color.brand.warning
        }
        return Color.brand.teal
    }

    private var metaText: String {
        let time = check.timestamp.formatted(date: .omitted, time: .shortened)
        let day = Calendar.current.isDateInToday(check.timestamp) ? "Today" :
                  Calendar.current.isDateInYesterday(check.timestamp) ? "Yesterday" :
                  check.timestamp.formatted(.dateTime.weekday(.wide))
        let location = check.locationName.isEmpty ? "" : " · \(check.locationName)"
        return "\(day) · \(time)\(location)"
    }

    private var itemIcon: String {
        switch check.aiLabel {
        case "Stove":      return "flame"
        case "Lock":       return "lock.fill"
        case "Door":       return "door.left.hand.closed"
        case "Window":     return "window.casement"
        case "Light":      return "lightbulb.fill"
        case "Iron":       return "humidity.fill"
        case "Tap":        return "drop.fill"
        case "Gas Valve":  return "gauge.with.dots.needle.bottom.50percent"
        default:           return "checkmark.circle.fill"
        }
    }

    private var thumbnailBackground: Color {
        switch check.aiLabel {
        case "Stove":      return Color(red: 1.0,  green: 0.95, blue: 0.90)
        case "Lock",
             "Door":       return Color(red: 0.91, green: 0.97, blue: 0.96)
        case "Window":     return Color(red: 0.90, green: 0.94, blue: 1.0)
        case "Light":      return Color(red: 1.0,  green: 0.97, blue: 0.88)
        case "Iron":       return Color(red: 0.93, green: 0.90, blue: 1.0)
        case "Tap":        return Color(red: 0.88, green: 0.95, blue: 1.0)
        case "Gas Valve":  return Color(red: 1.0,  green: 0.92, blue: 0.90)
        default:           return Color(.systemGray5)
        }
    }

    private var thumbnailIconColor: Color {
        switch check.aiLabel {
        case "Stove":      return Color(red: 0.85, green: 0.45, blue: 0.20)
        case "Lock",
             "Door":       return Color.brand.teal
        case "Window":     return Color(red: 0.25, green: 0.50, blue: 0.90)
        case "Light":      return Color(red: 0.85, green: 0.65, blue: 0.10)
        case "Iron":       return Color(red: 0.50, green: 0.35, blue: 0.90)
        case "Tap":        return Color(red: 0.20, green: 0.55, blue: 0.90)
        case "Gas Valve":  return Color.brand.danger
        default:           return Color(.secondaryLabel)
        }
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
