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
                behaviourSection
                privacySection
                dataSection
                aboutSection
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
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
            .alert("Checks Cleared", isPresented: $viewModel.didClearChecks) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Your check history has been cleared.")
            }
        }
        .onAppear {
            viewModel.setup(context: modelContext)
        }
    }

    // MARK: — Behaviour

    private var behaviourSection: some View {
        Section {
            Toggle(isOn: $viewModel.voiceConfirmationEnabled) {
                Label {
                    Text("Voice Confirmation")
                } icon: {
                    settingsIcon(symbol: "speaker.wave.2.fill", color: Color.brand.teal)
                }
            }
            .tint(Color.brand.teal)

            if viewModel.voiceConfirmationEnabled {
                Button {
                    SpeechService.shared.speak("Stove is off.")
                } label: {
                    Label {
                        Text("Test Voice")
                            .foregroundStyle(.primary)
                    } icon: {
                        settingsIcon(symbol: "play.fill", color: .indigo)
                    }
                }
            }
        } header: {
            Text("Behaviour")
        } footer: {
            Text("Speaks the verdict aloud after each successful check.")
        }
    }

    // MARK: — Privacy

    private var privacySection: some View {
        Section {
            privacyRow(
                symbol: "iphone",
                color: Color.brand.teal,
                title: "Stays on your device",
                subtitle: "Photos and AI results are never sent anywhere."
            )
            privacyRow(
                symbol: "cpu",
                color: .indigo,
                title: "AI runs on-device",
                subtitle: "Apple Vision analyses photos with no internet."
            )
            privacyRow(
                symbol: "clock.arrow.circlepath",
                color: .orange,
                title: "Auto-expires after 24 hours",
                subtitle: "Checks delete themselves. Nothing accumulates."
            )
        } header: {
            Text("Privacy")
        }
    }

    // MARK: — Data

    private var dataSection: some View {
        Section {
            Button(role: .destructive) {
                viewModel.showClearConfirmation = true
            } label: {
                Label {
                    Text("Clear All Checks")
                } icon: {
                    settingsIcon(symbol: "trash.fill", color: .red)
                }
            }
        } header: {
            Text("Data")
        } footer: {
            Text("Checks expire automatically after 24 hours. Use this only to clear everything immediately.")
        }
    }

    // MARK: — About

    private var aboutSection: some View {
        Section {
            LabeledContent {
                Text("1.0")
                    .foregroundStyle(.secondary)
            } label: {
                Label {
                    Text("CheckedIn")
                } icon: {
                    settingsIcon(symbol: "checkmark.shield.fill", color: Color.brand.teal)
                }
            }

            Label {
                Text("Built for peace of mind")
                    .foregroundStyle(.primary)
            } icon: {
                settingsIcon(symbol: "heart.fill", color: .pink)
            }
        } header: {
            Text("About")
        }
    }

    // MARK: — Reusable icon

    private func settingsIcon(symbol: String, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6.5)
                .fill(color)
                .frame(width: 29, height: 29)
            Image(systemName: symbol)
                .font(.system(size: 15, weight: .medium))
                .foregroundStyle(.white)
                .symbolRenderingMode(.hierarchical)
        }
    }

    // MARK: — Privacy row

    private func privacyRow(symbol: String, color: Color, title: String, subtitle: String) -> some View {
        Label {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.vertical, 2)
        } icon: {
            settingsIcon(symbol: symbol, color: color)
        }
    }
}
#Preview {
    SettingsView()
}
