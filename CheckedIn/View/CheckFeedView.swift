// CheckFeedView.swift

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

                scrollContent

                newCheckButton
            }
            .navigationBarHidden(true)
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
                    processingOverlay(text: "Saving check…")
                } else if viewModel.isAnalysing {
                    processingOverlay(text: "Analysing photo…")
                }
            }
        }
    }

    // MARK: - Scroll Content

    private var scrollContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {

                header
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 28)

                if viewModel.locationPermissionDenied {
                    locationBanner
                        .padding(.horizontal, 16)
                        .padding(.bottom, 16)
                }

                if viewModel.checks.isEmpty {
                    emptyState
                        .padding(.horizontal, 16)
                } else {
                    feedSection
                }

                Spacer(minLength: 110)
            }
        }
    }

    // MARK: - Header

    private var header: some View {
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

    // MARK: - Feed Section

    private var feedSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            sectionLabel("Recent Checks")
                .padding(.horizontal, 16)
                .padding(.bottom, 10)

            LazyVStack(spacing: 0) {
                ForEach(viewModel.checks, id: \.id) { check in
                    NavigationLink(destination: CheckDetailView(check: check)) {
                        CheckCardView(check: check)
                    }
                    .buttonStyle(.plain)

                    if check.id != viewModel.checks.last?.id {
                        Divider()
                            .padding(.leading, 78)
                    }
                }
            }
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(.horizontal, 16)
        }
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text.uppercased())
            .font(.system(size: 13, weight: .semibold))
            .foregroundStyle(.secondary)
            .kerning(0.3)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 0) {
            Spacer(minLength: 72)

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.brand.teal.opacity(0.08))
                        .frame(width: 88, height: 88)
                    Image(systemName: "checkmark.shield.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.brand.teal)
                }

                VStack(spacing: 6) {
                    Text("Nothing checked yet")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundStyle(.primary)
                        .multilineTextAlignment(.center)

                    Text("Take a photo of a lock, stove, or anything\nyou want proof of checking.")
                        .font(.system(size: 15))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Location Banner

    private var locationBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "location.slash.fill")
                .font(.system(size: 17))
                .foregroundStyle(Color.brand.warning)

            VStack(alignment: .leading, spacing: 2) {
                Text("Location access off")
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
        .background(Color.brand.warning.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.brand.warning.opacity(0.25), lineWidth: 0.5)
        )
    }

    // MARK: - New Check Button

    private var newCheckButton: some View {
        Button { showCamera = true } label: {
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
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 32)
    }

    // MARK: - Processing Overlay

    private func processingOverlay(text: String) -> some View {
        ZStack {
            Color.black.opacity(0.25).ignoresSafeArea()
            VStack(spacing: 14) {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(1.2)
                Text(text)
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
