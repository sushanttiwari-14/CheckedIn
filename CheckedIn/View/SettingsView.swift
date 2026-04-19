//
//  SettingsView.swift
//  CheckedIn
//
//  Created by sushant tiwari on 19/04/26.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel = SettingsViewModel()

    var body: some View {
        NavigationStack {
            List {

                voiceSection
                privacySection
                dataSection
                aboutSection

            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                        .foregroundStyle(Color.brand.teal)
                }
            }
            .alert("Clear All Checks?", isPresented: $viewModel.showClearConfirmation) {
                Button("Clear All", role: .destructive) {
                    viewModel.clearAllChecks()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all your saved checks. This cannot be undone.")
            }
            .alert("All Checks Cleared", isPresented: $viewModel.didClearChecks) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your check history has been cleared.")
            }
        }
        .onAppear {
            viewModel.setup(context: modelContext)
        }
    }

    // MARK: — Voice Section

    private var voiceSection: some View {
        Section {
            HStack {
                labelIcon(symbol: "speaker.wave.2.fill", color: Color.brand.teal)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Voice Confirmation")
                        .font(.system(size: 15))
                        .foregroundStyle(.primary)
                    Text("Speaks the verdict after each check")
                        .font(.system(size: 13))
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Toggle("", isOn: $viewModel.voiceConfirmationEnabled)
                    .labelsHidden()
                    .tint(Color.brand.teal)
            }
            .padding(.vertical, 4)
        } header: {
            Text("Behaviour")
        }
    }

    // MARK: — Privacy Section

    private var privacySection: some View {
        Section {
            VStack(alignment: .leading, spacing: 12) {
                privacyRow(
                    symbol: "iphone",
                    color: Color.brand.teal,
                    title: "Everything stays on your device",
                    detail: "Photos, locations, and AI results are stored only on this iPhone. Nothing is sent to any server."
                )

                Divider()

                privacyRow(
                    symbol: "cpu",
                    color: Color.brand.teal,
                    title: "AI runs on-device",
                    detail: "Analysis uses Apple's Vision framework. No internet connection is needed or used."
                )

                Divider()

                privacyRow(
                    symbol: "clock.arrow.circlepath",
                    color: Color.brand.teal,
                    title: "Checks expire after 24 hours",
                    detail: "Saved checks are automatically deleted the next day. Nothing accumulates over time."
                )
            }
            .padding(.vertical, 6)
        } header: {
            Text("Privacy")
        }
    }

    // MARK: — Data Section

    private var dataSection: some View {
        Section {
            Button {
                viewModel.showClearConfirmation = true
            } label: {
                HStack {
                    labelIcon(symbol: "trash.fill", color: .red)

                    Text("Clear All Checks")
                        .font(.system(size: 15))
                        .foregroundStyle(.red)

                    Spacer()
                }
                .padding(.vertical, 4)
            }
        } header: {
            Text("Data")
        } footer: {
            Text("Checks already expire automatically after 24 hours. Use this only if you want to clear everything immediately.")
                .font(.system(size: 12))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: — About Section

    private var aboutSection: some View {
        Section {
            HStack {
                labelIcon(symbol: "checkmark.shield.fill", color: Color.brand.teal)
                Text("CheckedIn")
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
                Spacer()
                Text("1.0")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)

            HStack {
                labelIcon(symbol: "heart.fill", color: .pink)
                Text("Built for peace of mind")
                    .font(.system(size: 15))
                    .foregroundStyle(.primary)
                Spacer()
            }
            .padding(.vertical, 4)

        } header: {
            Text("About")
        }
    }

    // MARK: — Helpers

    private func labelIcon(symbol: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 7)
                .fill(color)
                .frame(width: 30, height: 30)
            Image(systemName: symbol)
                .font(.system(size: 14))
                .foregroundStyle(.white)
        }
        .padding(.trailing, 6)
    }

    private func privacyRow(symbol: String, color: Color, title: String, detail: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 7)
                    .fill(color.opacity(0.12))
                    .frame(width: 30, height: 30)
                Image(systemName: symbol)
                    .font(.system(size: 14))
                    .foregroundStyle(color)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundStyle(.primary)
                Text(detail)
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineSpacing(2)
            }
        }
    }
}

#Preview {
    SettingsView()
}
