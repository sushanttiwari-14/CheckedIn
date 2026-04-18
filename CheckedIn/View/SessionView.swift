//
//  SessionView.swift
//  CheckedIn
//
//  Created by sushant tiwari on 19/04/26.
//

import SwiftUI
import SwiftData

struct SessionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SessionViewModel
    @State private var showCamera = false

    init(locationService: LocationService) {
        _viewModel = State(
            initialValue: SessionViewModel(locationService: locationService)
        )
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGroupedBackground).ignoresSafeArea()

                if viewModel.sessionComplete {
                    SessionClosureView(
                        viewModel: viewModel,
                        onDone: { dismiss() }
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.97)))
                } else {
                    sessionStepView
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.3), value: viewModel.sessionComplete)
            .animation(.easeInOut(duration: 0.25), value: viewModel.currentIndex)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.secondary)
                }
                ToolbarItem(placement: .principal) {
                    Text("Leaving Home")
                        .font(.system(size: 17, weight: .semibold))
                }
            }
        }
        .onAppear {
            viewModel.setup(context: modelContext)
        }
        .fullScreenCover(isPresented: $showCamera) {
            if let index = sessionChecks_currentIndex() {
                CameraView { photoData in
                    viewModel.submitPhoto(photoData, for: index)
                }
            }
        }
    }

    // MARK: — Step View

    private var sessionStepView: some View {
        VStack(spacing: 0) {
            progressBar
                .padding(.horizontal, 16)
                .padding(.top, 8)
                .padding(.bottom, 24)

            if let check = viewModel.currentSessionCheck,
               let item = viewModel.currentItem {
                VStack(spacing: 24) {
                    itemHeader(item: item)

                    if viewModel.isAnalysing {
                        analysingCard
                    } else if let verdict = check.verdict {
                        verdictCard(verdict: verdict, item: item)
                    } else {
                        cameraPromptCard(item: item)
                    }

                    actionButtons(check: check)
                }
                .padding(.horizontal, 16)
            }

            Spacer()
        }
    }

    // MARK: — Progress Bar

    private var progressBar: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(.systemFill))
                        .frame(height: 4)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(red: 0.165, green: 0.616, blue: 0.561))
                        .frame(
                            width: geo.size.width * viewModel.progress,
                            height: 4
                        )
                        .animation(.spring(duration: 0.4), value: viewModel.progress)
                }
            }
            .frame(height: 4)

            HStack {
                Text("\(viewModel.completedChecks.count) of \(viewModel.sessionChecks.count) checked")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
                Spacer()
            }
        }
    }

    // MARK: — Item Header

    private func itemHeader(item: SessionItem) -> some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color(red: 0.165, green: 0.616, blue: 0.561).opacity(0.10))
                    .frame(width: 72, height: 72)
                Image(systemName: item.icon)
                    .font(.system(size: 32))
                    .foregroundStyle(Color(red: 0.165, green: 0.616, blue: 0.561))
            }

            Text(item.label)
                .font(.system(size: 26, weight: .bold))
                .foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: — Camera Prompt Card

    private func cameraPromptCard(item: SessionItem) -> some View {
        Button {
            showCamera = true
        } label: {
            VStack(spacing: 16) {
                Image(systemName: "camera.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(Color(red: 0.165, green: 0.616, blue: 0.561))

                VStack(spacing: 4) {
                    Text("Take Photo")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.primary)
                    Text(item.prompt)
                        .font(.system(size: 14))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 36)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        Color(red: 0.165, green: 0.616, blue: 0.561).opacity(0.25),
                        style: StrokeStyle(lineWidth: 1.5, dash: [6, 4])
                    )
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: — Analysing Card

    private var analysingCard: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(Color(red: 0.165, green: 0.616, blue: 0.561))
            Text("Analysing photo…")
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: — Verdict Card

    private func verdictCard(verdict: VerdictFormatter.Verdict, item: SessionItem) -> some View {
        HStack(spacing: 16) {
            if let check = viewModel.currentSessionCheck,
               let data = check.photoData,
               let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(verdict.headline)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.primary)
                Text("Confirmed by photo")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: verdict.symbol)
                .font(.system(size: 26))
                .foregroundStyle(verdict.symbolColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: — Action Buttons

    private func actionButtons(check: SessionCheck) -> some View {
        VStack(spacing: 10) {
            if check.isComplete {
                Button(action: { viewModel.advanceToNext() }) {
                    Text(isLastItem ? "Finish" : "Next")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(red: 0.165, green: 0.616, blue: 0.561))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            } else {
                Button(action: { showCamera = true }) {
                    Text("Take Photo")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(red: 0.165, green: 0.616, blue: 0.561))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                Button(action: { viewModel.skipCurrent() }) {
                    Text("Skip")
                        .font(.system(size: 17))
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
        }
    }

    // MARK: — Helpers

    private var isLastItem: Bool {
        viewModel.currentIndex == viewModel.sessionChecks.count - 1
    }

    private func sessionChecks_currentIndex() -> Int? {
        viewModel.currentIndex < viewModel.sessionChecks.count ? viewModel.currentIndex : nil
    }
}

// MARK: — Closure Screen

struct SessionClosureView: View {
    let viewModel: SessionViewModel
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                closureSymbol
                closureText
                summaryList
            }
            .padding(.horizontal, 16)

            Spacer()

            doneButton
                .padding(.horizontal, 16)
                .padding(.bottom, 40)
        }
    }

    // MARK: — Symbol

    private var closureSymbol: some View {
        ZStack {
            Circle()
                .fill(Color(red: 0.322, green: 0.718, blue: 0.533).opacity(0.12))
                .frame(width: 88, height: 88)
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 44))
                .foregroundStyle(Color(red: 0.322, green: 0.718, blue: 0.533))
        }
    }

    // MARK: — Text

    private var closureText: some View {
        VStack(spacing: 8) {
            Text(viewModel.allVerified ? "Everything is checked" : "Session complete")
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.center)

            Text("You can leave now.")
                .font(.system(size: 17))
                .foregroundStyle(.secondary)
        }
    }

    // MARK: — Summary List

    private var summaryList: some View {
        VStack(spacing: 1) {
            ForEach(viewModel.sessionChecks) { check in
                summaryRow(check: check)
                if check.id != viewModel.sessionChecks.last?.id {
                    Divider().padding(.leading, 52)
                }
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func summaryRow(check: SessionCheck) -> some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(rowIconColor(check: check).opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: check.isComplete
                      ? (check.verdict?.symbol ?? "checkmark.circle.fill")
                      : "minus.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(rowIconColor(check: check))
            }

            Text(check.item.label)
                .font(.system(size: 15))
                .foregroundStyle(.primary)

            Spacer()

            Text(check.isComplete
                 ? (check.verdict?.headline ?? "Checked")
                 : "Skipped")
                .font(.system(size: 14))
                .foregroundStyle(check.isComplete ? .secondary : Color(.tertiaryLabel))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    private func rowIconColor(check: SessionCheck) -> Color {
        if !check.isComplete {
            return Color(.tertiaryLabel)
        }
        return check.verdict?.isConfirmed == true
            ? Color(red: 0.322, green: 0.718, blue: 0.533)
            : Color(red: 0.914, green: 0.769, blue: 0.408)
    }

    // MARK: — Done Button

    private var doneButton: some View {
        Button(action: onDone) {
            Text("Done")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(red: 0.165, green: 0.616, blue: 0.561))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(
                    color: Color(red: 0.165, green: 0.616, blue: 0.561).opacity(0.3),
                    radius: 12, x: 0, y: 4
                )
        }
    }
}
#Preview("Step Screen") {
    SessionView(locationService: LocationService())
}

#Preview("Closure Screen") {
    let vm = SessionViewModel(locationService: LocationService())
    vm.sessionComplete = true
    return SessionClosureView(viewModel: vm, onDone: {})
}
