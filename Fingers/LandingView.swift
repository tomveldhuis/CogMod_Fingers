//
//  LandingView.swift
//  Fingers
//
//  Created by UsabilityLab on 3/7/24.
//

import SwiftUI

struct LandingView: View {
    @Binding var showLandingView: Bool
    
    private let MAX_PLAYERS: Int = 10;
    
    @State private var humanPlayerCount: Int = 1;
    @State private var botPlayerCount: Int = 3;
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                let allPlayerCount = humanPlayerCount + botPlayerCount;
                
                Text("How many human players?")
                    .font(.title)
                    .padding()
                editPlayers(currPlayerCount: $humanPlayerCount, minPlayerCount: 1, allPlayerCount: allPlayerCount)
                
                Divider()
                
                Text("How many bot players?")
                    .font(.title)
                    .padding()
                editPlayers(currPlayerCount: $botPlayerCount, minPlayerCount: 0, allPlayerCount: allPlayerCount)
                
                Spacer()
                    .frame(height: 30)
                
                Button(action: {
                    self.showLandingView = false
                }) {
                    Text("Start")
                        .frame(width: geometry.size.width * 0.6)
                        .padding()
                        .background(.blue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .background(Color.white)
            .cornerRadius(20)
        }
    }
    
    @ViewBuilder
    private func editPlayers(currPlayerCount: Binding<Int>, minPlayerCount: Int, allPlayerCount: Int) -> some View {
        HStack {
            // Minus button
            Button(action: {
                currPlayerCount.wrappedValue -= 1;
            }) {
                Image(systemName: "minus.circle")
                    .font(.largeTitle)
            }
            .opacity(currPlayerCount.wrappedValue > minPlayerCount ? 1 : 0)
            
            // Current amount
            Text("\(currPlayerCount.wrappedValue)")
                .font(.title)
            
            // Plus button
            Button(action: {
                currPlayerCount.wrappedValue += 1;
            }) {
                Image(systemName: "plus.circle")
                    .font(.largeTitle)
            }
            .opacity(allPlayerCount < MAX_PLAYERS ? 1 : 0)
        }
    }
}
