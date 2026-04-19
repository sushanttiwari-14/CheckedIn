//
//  AppColors.swift
//  CheckedIn
//
//  Created by sushant tiwari on 12/04/26.
//

import SwiftUI

extension Color {
    struct brand {
        static let teal = Color(red: 0.165, green: 0.616, blue: 0.561)
        static let safeGreen = Color(red: 0.322, green: 0.718, blue: 0.533)
        static let warning = Color(red: 0.914, green: 0.769, blue: 0.408)
        static let danger = Color(red: 0.906, green: 0.435, blue: 0.318)

        // Adaptive surfaces  correct in both modes
        static let cardBackground = Color(.secondarySystemGroupedBackground)
        static let screenBackground = Color(.systemGroupedBackground)

        // Teal at reduced opacity  adapts automatically
        static let tealSubtle = Color(red: 0.165, green: 0.616, blue: 0.561).opacity(0.12)
        static let tealBorder = Color(red: 0.165, green: 0.616, blue: 0.561).opacity(0.25)
    }
}
