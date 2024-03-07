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
    
    let game = FingersViewModel()
    var body: some Scene {
        WindowGroup {
            if self.showLandingView {
                LandingView(showLandingView: $showLandingView)
                    .transition(.slide)
            }
            else {
                FingersView(fingersGame: game)
                    .transition(.slide)
            }
        }
    }
}
