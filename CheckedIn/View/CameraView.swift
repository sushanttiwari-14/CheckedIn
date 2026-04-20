//
//  CameraView.swift
//  CheckedIn
//
//  Created by sushant tiwari on 14/04/26.
//

import SwiftUI
import AVFoundation

struct CameraView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var service = CameraService()
    var onPhotoCaptured: (Data) -> Void

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if service.permissionDenied {
                permissionDeniedView
            } else {
                cameraPreview
                overlay
            }
        }
        .onAppear { service.checkPermissionAndSetup() }
        .onDisappear { service.stopSession() }
        .onChange(of: service.capturedPhotoData) { _, newData in
            if let data = newData {
                onPhotoCaptured(data)
                dismiss()
            }
        }
    }

    private var cameraPreview: some View {
        CameraPreviewLayer(session: service.session).ignoresSafeArea()
    }

    private var overlay: some View {
        VStack {
            topBar
            Spacer()
            bottomBar
        }
    }

    private var topBar: some View {
        HStack {
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(.ultraThinMaterial)
                    .clipShape(Circle())
            }
            Spacer()
            Text("New Check")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(.white)
            Spacer()
            Color.clear.frame(width: 44, height: 44)
        }
        .padding(.horizontal, 20)
        .padding(.top, 60)
    }

    private var bottomBar: some View {
        VStack(spacing: 24) {
            Text("Point at the appliance or lock")
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.8))
            captureButton
        }
        .padding(.bottom, 60)
    }

    private var captureButton: some View {
        Button {
            HapticService.impact(.medium)
            service.capturePhoto()
        } label: {
            ZStack {
                Circle()
                    .fill(.white)
                    .frame(width: 72, height: 72)
                Circle()
                    .stroke(.white.opacity(0.4), lineWidth: 4)
                    .frame(width: 88, height: 88)
            }
        }
        .disabled(!service.isSessionRunning)
    }

    private var permissionDeniedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.slash.fill")
                .font(.system(size: 52))
                .foregroundStyle(.white.opacity(0.6))
            Text("Camera Access Required")
                .font(.system(size: 20, weight: .semibold))
                .foregroundStyle(.white)
            Text("Please allow camera access in\nSettings to use CheckedIn.")
                .font(.system(size: 15))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .font(.system(size: 17, weight: .semibold))
            .foregroundStyle(Color.brand.teal)
            .padding(.top, 8)
        }
        .padding(32)
    }
}

struct CameraPreviewLayer: UIViewRepresentable {
    let session: AVCaptureSession
    func makeUIView(context: Context) -> PreviewUIView {
        let view = PreviewUIView()
        view.previewLayer.session = session
        view.previewLayer.videoGravity = .resizeAspectFill
        return view
    }
    func updateUIView(_ uiView: PreviewUIView, context: Context) {}
}

class PreviewUIView: UIView {
    override class var layerClass: AnyClass { AVCaptureVideoPreviewLayer.self }
    var previewLayer: AVCaptureVideoPreviewLayer { layer as! AVCaptureVideoPreviewLayer }
}
#Preview {
    CameraView { _ in
    }
}
