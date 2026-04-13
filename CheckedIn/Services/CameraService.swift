//
//  CameraService.swift
//  CheckedIn
//
//  Created by sushant tiwari on 14/04/26.
//


import AVFoundation
import Observation

@Observable
class CameraService: NSObject {
    var capturedPhotoData: Data? = nil
    var isSessionRunning = false
    var permissionDenied = false

    let session = AVCaptureSession()

    private let photoOutput = AVCapturePhotoOutput()
    private var photoDelegate: PhotoCaptureDelegate?

    func checkPermissionAndSetup() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupSession()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    self?.setupSession()
                } else {
                    self?.permissionDenied = true
                }
            }
        default:
            permissionDenied = true
        }
    }

    private func setupSession() {
        session.beginConfiguration()
        session.sessionPreset = .photo

        guard let device = AVCaptureDevice.default(
            .builtInWideAngleCamera,
            for: .video,
            position: .back
        ) else {
            print("No camera found")
            session.commitConfiguration()
            return
        }

        do {
            let input = try AVCaptureDeviceInput(device: device)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            if session.canAddOutput(photoOutput) {
                session.addOutput(photoOutput)
            }
        } catch {
            print("Camera setup error: \(error.localizedDescription)")
        }

        session.commitConfiguration()
        startSession()
    }

    func startSession() {
        guard !session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.startRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = true
            }
        }
    }

    func stopSession() {
        guard session.isRunning else { return }
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            self?.session.stopRunning()
            DispatchQueue.main.async {
                self?.isSessionRunning = false
            }
        }
    }

    func capturePhoto() {
        let settings = AVCapturePhotoSettings()
        photoDelegate = PhotoCaptureDelegate { [weak self] data in
            DispatchQueue.main.async {
                self?.capturedPhotoData = data
            }
        }
        photoOutput.capturePhoto(with: settings, delegate: photoDelegate!)
    }
}