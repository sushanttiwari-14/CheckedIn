//
//  VisionService.swift
//  CheckedIn
//
//  Created by sushant tiwari on 14/04/26.
//
//
//  VisionService.swift
//  CheckedIn
//

import Vision
import UIKit

final class VisionService {

    private let queue = DispatchQueue(label: "vision.queue", qos: .userInitiated)
    private var isProcessing = false

    func analyse(imageData: Data,
                 completion: @escaping (String, String, Double) -> Void) {

        queue.async { [weak self] in
            guard let self else { return }

            // Prevent overlapping requests
            guard !self.isProcessing else { return }
            self.isProcessing = true

            defer { self.isProcessing = false }

            // Decode image safely
            guard let rawImage = UIImage(data: imageData) else {
                self.finish("Item", "CHECK THIS", 0.0, completion)
                return
            }

            // Downscale (critical for memory stability)
            let image = self.resizeImage(rawImage)

            guard let cgImage = image.cgImage else {
                self.finish("Item", "CHECK THIS", 0.0, completion)
                return
            }

            let request = VNClassifyImageRequest()

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

            do {
                try handler.perform([request])
            } catch {
                print("Vision handler error:", error.localizedDescription)
                self.finish("Item", "CHECK THIS", 0.0, completion)
                return
            }

            guard let results = request.results,
                  let top = results.first(where: { $0.confidence > 0.1 }) else {
                self.finish("Item", "CHECK THIS", 0.0, completion)
                return
            }

            let label = Self.mapLabel(top.identifier)
            let confidence = Double(top.confidence)
            let state = Self.inferState(label: label, confidence: confidence)

            self.finish(label, state, confidence, completion)
        }
    }
    // MARK: - Helpers

    private func finish(_ label: String,
                        _ state: String,
                        _ confidence: Double,
                        _ completion: @escaping (String, String, Double) -> Void) {

        DispatchQueue.main.async {
            completion(label, state, confidence)
        }
    }

    private func resizeImage(_ image: UIImage) -> UIImage {
        let maxDimension: CGFloat = 512

        let aspectRatio = image.size.width / image.size.height
        let newSize: CGSize

        if aspectRatio > 1 {
            newSize = CGSize(width: maxDimension,
                             height: maxDimension / aspectRatio)
        } else {
            newSize = CGSize(width: maxDimension * aspectRatio,
                             height: maxDimension)
        }

        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
    // MARK: - Mapping

    private static func mapLabel(_ identifier: String) -> String {
        let id = identifier.lowercased()

        if id.contains("stove") || id.contains("oven") || id.contains("range") ||
           id.contains("burner") || id.contains("cooktop") {
            return "Stove"
        }
        if id.contains("lock") || id.contains("padlock") || id.contains("deadbolt") {
            return "Lock"
        }
        if id.contains("door") || id.contains("gate") {
            return "Door"
        }
        if id.contains("window") || id.contains("blind") || id.contains("curtain") {
            return "Window"
        }
        if id.contains("light") || id.contains("lamp") || id.contains("bulb") ||
           id.contains("switch") {
            return "Light"
        }
        if id.contains("iron") || id.contains("press") {
            return "Iron"
        }
        if id.contains("tap") || id.contains("faucet") || id.contains("sink") {
            return "Tap"
        }
        if id.contains("gas") || id.contains("valve") {
            return "Gas Valve"
        }

        return "Item"
    }

    private static func inferState(label: String, confidence: Double) -> String {
        switch label {
        case "Stove", "Iron", "Light":
            return confidence >= 0.75 ? "OFF" : "ON — CHECK THIS"
        case "Lock", "Door", "Gate":
            return confidence >= 0.75 ? "LOCKED" : "UNLOCKED — CHECK THIS"
        case "Window":
            return confidence >= 0.75 ? "CLOSED" : "OPEN — CHECK THIS"
        case "Tap":
            return confidence >= 0.75 ? "OFF" : "ON — CHECK THIS"
        case "Gas Valve":
            return confidence >= 0.75 ? "CLOSED" : "OPEN — CHECK THIS"
        default:
            return confidence >= 0.75 ? "CHECKED" : "CHECK THIS"
        }
    }
}
