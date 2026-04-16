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

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                photoSection
                verdictBanner
                detailsSection
                footerNote
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color(.systemGroupedBackground))
        .overlay(alignment: .topLeading) { closeButton }
    }

    private var photoSection: some View {
        ZStack(alignment: .bottom) {
            if let data = check.photoData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 380)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color(.systemGray4))
                    .frame(height: 380)
                    .overlay {
                        Image(systemName: iconForLabel(check.aiLabel))
                            .font(.system(size: 64))
                            .foregroundStyle(Color.brand.teal)
                    }
            }

            LinearGradient(
                colors: [.clear, .black.opacity(0.55)],
                startPoint: .center,
                endPoint: .bottom
            )
            .frame(height: 380)

            VStack(alignment: .leading, spacing: 4) {
                Text(check.aiLabel)
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.white)
                HStack(spacing: 4) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 12))
                    Text(check.locationName)
                        .font(.system(size: 14))
                }
                .foregroundStyle(.white.opacity(0.85))
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 20)
            .padding(.bottom, 24)
        }
    }

    private var verdictBanner: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(verdictColor.opacity(0.15))
                    .frame(width: 64, height: 64)
                Image(systemName: verdictIcon)
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(verdictColor)
            }

            VStack(alignment: .leading, spacing: 6) {
                Text(verdictHeadline)
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(verdictColor)
                Text(verdictMessage)
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .padding(20)
        .background(Color(.secondarySystemGroupedBackground))
    }

    private var detailsSection: some View {
        VStack(spacing: 1) {
            detailRow(
                icon: "clock.fill",
                label: "Checked at",
                value: formattedDate
            )
            detailRow(
                icon: "location.fill",
                label: "Location",
                value: check.locationName
            )
            detailRow(
                icon: "cpu.fill",
                label: "Analysed by",
                value: "On-Device AI"
            )
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
        .padding(.top, 20)
    }

    private func detailRow(
        icon: String,
        label: String,
        value: String,
        valueColor: Color = .primary
    ) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundStyle(Color.brand.teal)
                .frame(width: 20)
            Text(label)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(valueColor)
                .multilineTextAlignment(.trailing)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .background(Color(.secondarySystemGroupedBackground))
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(Color(.systemGray5))
                .frame(height: 0.5)
                .padding(.leading, 50)
        }
    }

    private var footerNote: some View {
        VStack(spacing: 8) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 24))
                .foregroundStyle(Color.brand.teal.opacity(0.5))
            Text("Stored privately on your device.\nYour photos never leave your phone.")
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(24)
        .padding(.bottom, 16)
    }

    private var closeButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 32, height: 32)
                .background(.black.opacity(0.4))
                .clipShape(Circle())
        }
        .padding(.top, 56)
        .padding(.leading, 20)
    }

    private var verdictHeadline: String {
        switch check.aiState {
        case "OFF":     return "\(check.aiLabel) is OFF"
        case "LOCKED":  return "\(check.aiLabel) is LOCKED"
        case "CLOSED":  return "\(check.aiLabel) is CLOSED"
        case "CHECKED": return "\(check.aiLabel) looks safe"
        default:        return "Couldn't confirm"
        }
    }

    private var verdictColor: Color {
        switch check.aiState {
        case "OFF", "LOCKED", "CLOSED", "CHECKED":
            return Color.brand.safeGreen
        default:
            return Color.brand.danger
        }
    }

    private var verdictIcon: String {
        switch check.aiState {
        case "OFF", "LOCKED", "CLOSED", "CHECKED":
            return "checkmark.shield.fill"
        default:
            return "exclamationmark.triangle.fill"
        }
    }

    private var verdictMessage: String {
        switch check.aiState {
        case "OFF":     return "This was off when you checked."
        case "LOCKED":  return "This was locked when you checked."
        case "CLOSED":  return "This was closed when you checked."
        case "CHECKED": return "This looked safe when you checked."
        default:        return "Couldn't confirm — please go back and check now."
        }
    }

    private var formattedDate: String {
        let f = DateFormatter()
        f.dateStyle = .medium
        f.timeStyle = .short
        return f.string(from: check.timestamp)
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
