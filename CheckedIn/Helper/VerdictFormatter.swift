//
//  VerdictFormatter.swift
//  CheckedIn
//
//  Created by sushant tiwari on 18/04/26.
//

import SwiftUI

struct VerdictFormatter {

    struct Verdict {
        let headline: String        // "Front door is locked"
        let symbol: String          // SF Symbol name
        let symbolColor: Color      // semantic color
        let isConfirmed: Bool       // drives green vs amber tint
    }

    static func verdict(for check: SafeCheck) -> Verdict {
        let state = check.aiState.uppercased()
        let label = check.aiLabel

        let isUncertain = state.contains("CHECK THIS") || state.contains("CHECKING") || check.aiState == "Please wait" || check.aiState == "Analysing..."

        if isUncertain {
            return Verdict(
                headline: "Analysing your \(label.lowercased())…",
                symbol: "clock.fill",
                symbolColor: .secondary,
                isConfirmed: false
            )
        }

        let headline = humanHeadline(label: label, state: state)
        let isPositive = isPositiveState(state: state)

        return Verdict(
            headline: headline,
            symbol: isPositive ? "checkmark.circle.fill" : "exclamationmark.triangle.fill",
            symbolColor: isPositive ? Color(red: 0.322, green: 0.718, blue: 0.533) : Color(red: 0.914, green: 0.769, blue: 0.408),
            isConfirmed: isPositive
        )
    }

    private static func isPositiveState(state: String) -> Bool {
        let positive = ["OFF", "LOCKED", "CLOSED", "CHECKED"]
        return positive.contains(where: { state.hasPrefix($0) })
    }

    private static func humanHeadline(label: String, state: String) -> String {
        switch label {
        case "Stove":
            return state.hasPrefix("OFF") ? "Stove is off" : "Stove may be on"
        case "Iron":
            return state.hasPrefix("OFF") ? "Iron is off" : "Iron may still be on"
        case "Light":
            return state.hasPrefix("OFF") ? "Light is off" : "Light may still be on"
        case "Lock":
            return state.hasPrefix("LOCKED") ? "Lock is locked" : "Lock may be open"
        case "Door":
            return state.hasPrefix("LOCKED") ? "Door is locked" : "Door may be unlocked"
        case "Window":
            return state.hasPrefix("CLOSED") ? "Window is closed" : "Window may be open"
        case "Tap":
            return state.hasPrefix("OFF") ? "Tap is off" : "Tap may still be running"
        case "Gas Valve":
            return state.hasPrefix("CLOSED") ? "Gas valve is closed" : "Gas valve may be open"
        default:
            return state.hasPrefix("CHECKED") ? "Item is checked" : "Item needs checking"
        }
    }
}
