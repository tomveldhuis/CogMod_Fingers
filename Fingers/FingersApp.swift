//
//  FingersApp.swift
//  Fingers
//
//  Created by Tom on 19/02/2024.
//

import SwiftUI
import StoreKit

@main
struct FingersApp: App {
    @State private var showLandingView = true
    @State private var showExplainView = false
    @State private var nr_humans: Int = 1
    @State private var nr_bots: Int = 3
    
    var body: some Scene {
        WindowGroup {
            if self.showExplainView {
                ExplainView(showExplainView: $showExplainView)
                    .transition(.slide)
                    .background(Color("BackgroundColor"))
                    .environment(\.font, Font.custom("BDSupperRegular", size: 14))
            }
            else if self.showLandingView {
                LandingView(
                    showLandingView: $showLandingView,
                    showExplainView: $showExplainView,
                    humanPlayerCount: $nr_humans,
                    botPlayerCount: $nr_bots
                )
                .transition(.slide)
                .background(Color("BackgroundColor"))
                .environment(\.font, Font.custom("BDSupperRegular", size: 14))
            }
            else {
                let game = FingersViewModel(n_humans: nr_humans, n_bots: nr_bots)
                FingersView(fingersGame: game, resetGame: $showLandingView)
                    .transition(.slide)
                    .background(Color("BackgroundColor"))
                    .environment(\.font, Font.custom("BDSupperRegular", size: 14))
            }
        }
    }
}
