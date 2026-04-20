//
//  CheckDetailView.swift
//  CheckedIn
//
//  Created by sushant tiwari on 16/04/26.
//

import SwiftUI

struct CheckDetailView: View {
    let check: SafeCheck

    @Environment(\.dismiss) private var dismiss
    @State private var didFireHaptic = false

    private var verdict: VerdictFormatter.Verdict {
        VerdictFormatter.verdict(for: check)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                photoSection
                proofSection
            }
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Proof")
                    .font(.system(size: 17, weight: .semibold))
            }
        }
        .onAppear {
            guard !didFireHaptic else { return }
            if verdict.isConfirmed {
                HapticService.success()
                didFireHaptic = true
            }
        }
    }

    // MARK: — Photo

    private var photoSection: some View {
        Group {
            if let data = check.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .clipped()
            } else {
                ZStack {
                    Color(.secondarySystemGroupedBackground)
                    Image(systemName: "photo")
                        .font(.system(size: 36))
                        .foregroundStyle(Color(.tertiaryLabel))
                }
                .frame(height: 300)
            }
        }
    }

    // MARK: — Proof Block

    private var proofSection: some View {
        VStack(spacing: 0) {
            verdictCard
                .padding(.horizontal, 16)
                .padding(.top, 20)

            metaCard
                .padding(.horizontal, 16)
                .padding(.top, 12)

            closureNote
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 48)
        }
    }

    // MARK: — Verdict Card

    private var verdictCard: some View {
        VStack(spacing: 20) {
            symbolBadge
            verdictText
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 28)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var symbolBadge: some View {
        ZStack {
            Circle()
                .fill(verdict.symbolColor.opacity(0.12))
                .frame(width: 72, height: 72)
            Image(systemName: verdict.symbol)
                .font(.system(size: 36))
                .foregroundStyle(verdict.symbolColor)
        }
    }

    private var verdictText: some View {
        VStack(spacing: 8) {
            Text(verdict.headline)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)

            if verdict.isConfirmed {
                Text("Confirmed by photo")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            } else if check.aiState == "Analysing..." || check.aiState == "Please wait" {
                Text("Analysis in progress")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            } else {
                Text("Check the photo above")
                    .font(.system(size: 15))
                    .foregroundStyle(Color.brand.warning)
            }
        }
    }

    // MARK: — Meta Card

    private var metaCard: some View {
        VStack(spacing: 0) {
            metaRow(
                icon: "clock.fill",
                iconColor: Color.brand.teal,
                label: "Checked at",
                value: formattedTime
            )

            Divider()
                .padding(.leading, 52)

            metaRow(
                icon: "location.fill",
                iconColor: Color.brand.teal,
                label: "Location",
                value: check.locationName.isEmpty ? "Unknown location" : check.locationName
            )
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func metaRow(icon: String, iconColor: Color, label: String, value: String) -> some View {
        HStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(iconColor)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Text(value)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.primary)
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // MARK: — Closure Note

    private var closureNote: some View {
        HStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 15))
                .foregroundStyle(Color.brand.teal)

            Text("This photo is your proof. You can trust it.")
                .font(.system(size: 14))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(Color.brand.tealSubtle)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.brand.tealBorder, lineWidth: 0.5)
        )
    }

    // MARK: — Time formatting

    private var formattedTime: String {
        let cal = Calendar.current
        let formatter = DateFormatter()

        if cal.isDateInToday(check.timestamp) {
            formatter.dateFormat = "'Today at' h:mm a"
        } else if cal.isDateInYesterday(check.timestamp) {
            formatter.dateFormat = "'Yesterday at' h:mm a"
        } else {
            formatter.dateFormat = "EEEE 'at' h:mm a"
        }

        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter.string(from: check.timestamp)
    }
}
#Preview("Safe Check") {
    CheckDetailView(check: SafeCheck(
        timestamp: Date(),
        locationName: "Kitchen — Home",
        latitude: 30.7046,
        longitude: 76.7179,
        aiLabel: "Stove",
        aiState: "OFF",
        confidenceScore: 0.89,
        isVerified: true
    ))
}

#Preview("Needs Attention") {
    CheckDetailView(check: SafeCheck(
        timestamp: Date(),
        locationName: "Garage — Home",
        latitude: 30.7046,
        longitude: 76.7179,
        aiLabel: "Door",
        aiState: "ON — CHECK THIS",
        confidenceScore: 0.54,
        isVerified: false
    ))
}
