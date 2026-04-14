//
//  CheckFeedView.swift
//  CheckedIn
//
//  Created by sushant tiwari on 12/04/26.
//

import SwiftUI
import SwiftData

struct CheckFeedView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = CheckFeedViewModel()
    @State private var showCamera = false

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        summaryStrip
                            .padding(.horizontal, 16)
                            .padding(.top, 8)
                            .padding(.bottom, 20)

                        sectionLabel("Recent Checks")
                            .padding(.horizontal, 16)
                            .padding(.bottom, 10)

                        if viewModel.checks.isEmpty {
                            emptyState
                                .padding(.horizontal, 16)
                        } else {
                            LazyVStack(spacing: 1) {
                                ForEach(viewModel.checks, id: \.id) { check in
                                    CheckCardView(check: check)
                                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                            Button(role: .destructive) {
                                                viewModel.deleteCheck(check)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                }
                            }
                            .background(Color(.secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.horizontal, 16)
                        }

                        Spacer(minLength: 110)
                    }
                }

                newCheckButton
            }
            .navigationTitle("CheckedIn")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    verifiedCounter
                }
            }
            .fullScreenCover(isPresented: $showCamera) {
                CameraView { capturedData in
                    viewModel.saveCheck(photoData: capturedData)
                }
            }
            .onAppear {
                viewModel.setup(context: modelContext)
            }
            .overlay {
                if viewModel.isSaving {
                    savingOverlay
                }
            }
        }
    }

    private var summaryStrip: some View {
        HStack(spacing: 12) {
            SummaryTile(
                value: "\(viewModel.checks.filter { $0.isVerified }.count)",
                label: "Verified",
                color: Color.brand.safeGreen
            )
            SummaryTile(
                value: "\(viewModel.checks.filter { !$0.isVerified }.count)",
                label: "Needs Review",
                color: Color.brand.warning
            )
            SummaryTile(
                value: "\(viewModel.checks.count)",
                label: "Total",
                color: Color.brand.teal
            )
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.secondary)
            .kerning(0.5)
    }

    private var verifiedCounter: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.seal.fill")
                .foregroundStyle(Color.brand.teal)
                .font(.system(size: 16))
            Text("\(viewModel.checks.filter { $0.isVerified }.count)")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(Color.brand.teal)
        }
    }
    private var emptyState: some View {
        VStack(spacing: 16) {
            Spacer(minLength: 80)
            Image(systemName: "checkmark.shield.fill")
                .font(.system(size: 56))
                .foregroundStyle(Color.brand.teal)
            VStack(spacing: 6) {
                Text("No checks yet")
                    .font(.system(size: 20, weight: .semibold))
                Text("Tap New Check to take your first\nsafety photo and build peace of mind.")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    private var newCheckButton: some View {
        Button {
            showCamera = true
        } label: {
            Label("New Check", systemImage: "camera.fill")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.brand.teal)
                .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 32)
    }

    private var savingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            VStack(spacing: 14) {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.2)
                Text("Saving check...")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
            }
            .padding(28)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}
struct SummaryTile: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundStyle(color)
            Text(label)
                .font(.system(size: 13))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 14)
        .padding(.horizontal, 14)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    CheckFeedView()
}
