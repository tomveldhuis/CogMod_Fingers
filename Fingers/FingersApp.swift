//
//  FingersApp.swift
//  Fingers
//
//  Created by Tom on 19/02/2024.
//

import SwiftUI

@main
struct FingersApp: App {
    @State private var showLandingView = true
    @State private var nr_humans: Int = 1
    @State private var nr_bots: Int = 3
    
    var body: some Scene {
        WindowGroup {
            if self.showLandingView {
                LandingView(showLandingView: $showLandingView, humanPlayerCount: $nr_humans, botPlayerCount: $nr_bots)
                    .transition(.slide)
            }
            else {
                let game = FingersViewModel(n_humans: nr_humans, n_bots: nr_bots)
                FingersView(fingersGame: game)
                    .transition(.slide)
            }
        }
    }
}
