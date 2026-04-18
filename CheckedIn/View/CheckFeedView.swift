// CheckFeedView.swift

import SwiftUI
import SwiftData

struct CheckFeedView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = CheckFeedViewModel()
    @State private var showCamera = false
    @State private var showRecheckSheet = false
    @State private var showSession = false
    @State private var recheckDestination: SafeCheck? = nil

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Color(.systemGroupedBackground)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {

                        headerSection
                            .padding(.horizontal, 20)
                            .padding(.top, 16)
                            .padding(.bottom, 24)

                        if viewModel.locationPermissionDenied {
                            locationDeniedBanner
                                .padding(.horizontal, 16)
                                .padding(.bottom, 16)
                        }

                        if !viewModel.checks.isEmpty {
                            sectionLabel("Recent Checks")
                                .padding(.horizontal, 16)
                                .padding(.bottom, 10)

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
                        } else {
                            emptyState
                                .padding(.horizontal, 16)
                        }

                        Spacer(minLength: 130)
                    }
                }

                bottomButtons
            }
            .navigationBarHidden(true)
            .fullScreenCover(isPresented: $showCamera) {
                CameraView { capturedData in
                    viewModel.saveCheck(photoData: capturedData)
                }
            }
            .fullScreenCover(isPresented: $showSession) {
                SessionView(locationService: LocationService())
            }
            .sheet(isPresented: $showRecheckSheet) {
                if let result = viewModel.recentCheckResult {
                    RecheckFrictionSheet(
                        result: result,
                        onViewLastCheck: {
                            recheckDestination = result.matchedCheck
                            showRecheckSheet = false
                            viewModel.clearRecentCheckResult()
                        },
                        onCheckAgain: {
                            showRecheckSheet = false
                            viewModel.clearRecentCheckResult()
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                                showCamera = true
                            }
                        },
                        onDismiss: {
                            showRecheckSheet = false
                            viewModel.clearRecentCheckResult()
                        }
                    )
                    .presentationDetents([.height(380)])
                    .presentationDragIndicator(.visible)
                    .presentationCornerRadius(24)
                }
            }
            .navigationDestination(item: $recheckDestination) { check in
                CheckDetailView(check: check)
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

    // MARK: — New Check tap handler

    private func handleNewCheckTap() {
        let hasDuplicate = viewModel.checkForRecentDuplicate()
        if hasDuplicate {
            showRecheckSheet = true
        } else {
            showCamera = true
        }
    }

    // MARK: — Header

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundStyle(Color.brand.teal)
                Text("CheckedIn")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundStyle(.primary)
            }
            Text(greetingText)
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
        }
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12:  return "Good morning. You're in control."
        case 12..<17: return "Good afternoon. You're in control."
        case 17..<21: return "Good evening. You're in control."
        default:      return "You're in control."
        }
    }

    // MARK: — Location banner

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

    // MARK: — Section label

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.secondary)
            .kerning(0.5)
    }

    // MARK: — Empty state

    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 60)

            ZStack {
                Circle()
                    .fill(Color.brand.teal.opacity(0.08))
                    .frame(width: 96, height: 96)
                Image(systemName: "checkmark.shield.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(Color.brand.teal)
            }

            VStack(spacing: 8) {
                Text("You haven't checked anything yet")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                Text("Take a photo of a stove, lock, or\nanything you want proof of checking.")
                    .font(.system(size: 15))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 40)
    }

    // MARK: — Bottom Buttons

    private var bottomButtons: some View {
        VStack(spacing: 10) {
            Button {
                showSession = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 16, weight: .semibold))
                    Text("I'm Leaving")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundStyle(Color.brand.teal)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.brand.teal.opacity(0.10))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.brand.teal.opacity(0.25), lineWidth: 1)
                    )
            }

            Button {
                handleNewCheckTap()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "camera.fill")
                        .font(.system(size: 17, weight: .semibold))
                    Text("New Check")
                        .font(.system(size: 17, weight: .semibold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.brand.teal)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .shadow(color: Color.brand.teal.opacity(0.3), radius: 12, x: 0, y: 4)
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 32)
        .background(
            LinearGradient(
                colors: [
                    Color(.systemGroupedBackground).opacity(0),
                    Color(.systemGroupedBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    // MARK: — Overlays

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
