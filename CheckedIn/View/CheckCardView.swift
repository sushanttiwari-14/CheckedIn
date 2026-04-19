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

    private var verdict: VerdictFormatter.Verdict {
        VerdictFormatter.verdict(for: check)
    }

    var body: some View {
        HStack(spacing: 14) {
            thumbnail
            content
            Spacer(minLength: 8)
            chevron
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
        .contentShape(Rectangle())
    }

    // MARK: — Thumbnail

    private var thumbnail: some View {
        Group {
            if let data = check.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.brand.tealSubtle)
                    Image(systemName: "photo")
                        .font(.system(size: 20))
                        .foregroundStyle(Color.brand.teal.opacity(0.5))
                }
                .frame(width: 52, height: 52)
            }
        }
    }

    // MARK: — Content

    private var content: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: verdict.symbol)
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(verdict.symbolColor)

                Text(verdict.headline)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
            }

            Text(formattedTime)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            if !check.locationName.isEmpty && check.locationName != "Unknown Location" {
                HStack(spacing: 3) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(Color(.tertiaryLabel))
                    Text(check.locationName)
                        .font(.system(size: 12))
                        .foregroundStyle(Color(.tertiaryLabel))
                        .lineLimit(1)
                }
            }
        }
    }

    // MARK: — Chevron

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(Color(.tertiaryLabel))
    }

    // MARK: — Time formatting

    private var formattedTime: String {
        let cal = Calendar.current
        let formatter = DateFormatter()

        if cal.isDateInToday(check.timestamp) {
            formatter.dateFormat = "h:mm a"
        } else if cal.isDateInYesterday(check.timestamp) {
            formatter.dateFormat = "'Yesterday' h:mm a"
        } else {
            formatter.dateFormat = "EEE h:mm a"
        }

        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter.string(from: check.timestamp)
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
