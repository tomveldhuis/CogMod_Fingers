//
//  FingersApp.swift
//  Fingers
//
//  Created by Tom on 19/02/2024.
//

import SwiftUI

@main
struct FingersApp: App {
    let game = FingersViewModel()
    var body: some Scene {
        WindowGroup {
            FingersView(fingersGame: game)
        }
    }
}
