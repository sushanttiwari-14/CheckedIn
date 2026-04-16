//
//  VisionService.swift
//  CheckedIn
//
//  Created by sushant tiwari on 14/04/26.
//

import Vision
import UIKit

class VisionService {

    func analyse(imageData: Data, completion: @escaping (String, String, Double) -> Void) {

        guard let image = UIImage(data: imageData),
              let cgImage = image.cgImage else {
            completion("Item", "CHECK THIS", 0.0)
            return
        }

        let request = VNClassifyImageRequest { request, error in

            if let error {
                print("Vision error: \(error.localizedDescription)")
                completion("Item", "CHECK THIS", 0.0)
                return
            }

            guard let results = request.results as? [VNClassificationObservation],
                  let top = results.first(where: { $0.confidence > 0.1 }) else {
                completion("Item", "CHECK THIS", 0.0)
                return
            }

            let label = Self.mapLabel(top.identifier)
            let confidence = Double(top.confidence)
            let state = Self.inferState(label: label, confidence: confidence)

            DispatchQueue.main.async {
                completion(label, state, confidence)
            }
        }

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])

        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                print("Handler error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion("Item", "CHECK THIS", 0.0)
                }
            }
        }
    }

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
