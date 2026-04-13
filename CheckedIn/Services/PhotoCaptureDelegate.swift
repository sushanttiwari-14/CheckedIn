//
//  PhotoCaptureDelegate.swift
//  CheckedIn
//
//  Created by sushant tiwari on 14/04/26.
//

import AVFoundation

class PhotoCaptureDelegate: NSObject, AVCapturePhotoCaptureDelegate {
    private let completion: (Data?) -> Void

    init(completion: @escaping (Data?) -> Void) {
        self.completion = completion
    }

    func photoOutput(
        _ output: AVCapturePhotoOutput,
        didFinishProcessingPhoto photo: AVCapturePhoto,
        error: Error?
    ) {
        if let error {
            print("Photo capture error: \(error.localizedDescription)")
            completion(nil)
            return
        }
        completion(photo.fileDataRepresentation())
    }
}
