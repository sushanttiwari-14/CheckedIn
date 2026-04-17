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

                        // Show this banner only when location is denied
                        if viewModel.locationPermissionDenied {
                            locationDeniedBanner
                                .padding(.horizontal, 16)
                                .padding(.top, 12)
                                .padding(.bottom, 4)
                        }

                        sectionLabel("Recent Checks")
                            .padding(.horizontal, 16)
                            .padding(.top, 16)
                            .padding(.bottom, 10)

                        if viewModel.checks.isEmpty {
                            emptyState
                                .padding(.horizontal, 16)
                        } else {
                            LazyVStack(spacing: 1) {
                                ForEach(viewModel.checks, id: \.id) { check in
                                    NavigationLink(
                                        destination: CheckDetailView(check: check)
                                    ) {
                                        CheckCardView(check: check)
                                    }
                                    .buttonStyle(.plain)
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
            .navigationTitle("My Checks")
            .navigationBarTitleDisplayMode(.large)
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
                } else if viewModel.isAnalysing {
                    analysingOverlay
                }
            }
        }
    }

    // MARK: - Location Denied Banner

    private var locationDeniedBanner: some View {
        HStack(spacing: 12) {

            Image(systemName: "location.slash.fill")
                .font(.system(size: 18))
                .foregroundStyle(Color.brand.warning)

            VStack(alignment: .leading, spacing: 2) {
                Text("Location Access Off")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.primary)
                Text("Checks won't include your location.")
                    .font(.system(size: 13))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Button("Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(Color.brand.teal)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.brand.warning.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.brand.warning.opacity(0.3), lineWidth: 1)
        )
    }

    // MARK: - Section Label

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.secondary)
            .kerning(0.5)
    }

    // MARK: - Empty State

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

    // MARK: - New Check Button

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

    // MARK: - Overlays

    private var savingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            VStack(spacing: 14) {
                ProgressView().tint(.white).scaleEffect(1.2)
                Text("Saving check...")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
            }
            .padding(28)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var analysingOverlay: some View {
        ZStack {
            Color.black.opacity(0.3).ignoresSafeArea()
            VStack(spacing: 14) {
                ProgressView().tint(.white).scaleEffect(1.2)
                Text("Analysing photo...")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundStyle(.white)
            }
            .padding(28)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }
}

#Preview {
    CheckFeedView()
}
