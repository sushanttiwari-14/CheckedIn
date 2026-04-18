//
//  SessionItem.swift
//  CheckedIn
//
//  Created by sushant tiwari on 19/04/26.
//

import Foundation

struct SessionItem: Identifiable {
    let id: UUID = UUID()
    let label: String
    let icon: String
    let prompt: String

    static let defaultItems: [SessionItem] = [
        SessionItem(
            label: "Stove",
            icon: "flame.fill",
            prompt: "Point at your stove or hob"
        ),
        SessionItem(
            label: "Door",
            icon: "door.left.hand.closed",
            prompt: "Point at your front door"
        ),
        SessionItem(
            label: "Iron",
            icon: "iron.fill",
            prompt: "Point at your iron"
        ),
        SessionItem(
            label: "Window",
            icon: "window.casement",
            prompt: "Point at your window"
        ),
        SessionItem(
            label: "Tap",
            icon: "drop.fill",
            prompt: "Point at your tap or faucet"
        )
    ]
}
