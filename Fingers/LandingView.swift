//
//  LandingView.swift
//  Fingers
//
//  Created by UsabilityLab on 3/7/24.
//

import SwiftUI

struct LandingView: View {
    @Binding var showLandingView: Bool
    @Binding var showExplainView: Bool
    
    private let MAX_PLAYERS: Int = 10;
    
    @Binding var humanPlayerCount: Int;
    @Binding var botPlayerCount: Int;
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Text("Fingers")
                    .font(Font.custom("Keep on Truckin'", size: 64))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .yellow],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .glowBorder(color: .black, lineWidth: 5)
                Spacer()
                    .frame(height: 48)
                
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
                
                VStack {
                    Spacer()
                        .frame(height: 64)
                    
                    Button("How to play") {
                        self.showExplainView = true
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .background(Color.yellow)
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
            .opacity(
                (currPlayerCount.wrappedValue > minPlayerCount && allPlayerCount > 2) ? 1 : 0
            )
            
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

struct ExplainView: View {
    @Binding var showExplainView: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                VStack {
                    Text("How to play")
                        .font(Font.custom("Keep on Truckin'", size: 48))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .yellow],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .glowBorder(color: .black, lineWidth: 5)
                    Spacer()
                }
                
                // Exit button
                VStack {
                    HStack {
                        Button(action: {
                            self.showExplainView = false
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(.blue)
                                .imageScale(.large)
                        }
                        .padding()
                        Spacer()
                    }
                    Spacer()
                        .frame(height: geometry.size.height / 2 - 25)
                }
            }
            
            
        }
    }
}

struct GlowBorder: ViewModifier {
    var color: Color
    var lineWidth: Int
    
    func body(content: Content) -> some View {
        applyShadow(content: AnyView(content), lineWidth: lineWidth)
    }
    
    func applyShadow(content: AnyView, lineWidth: Int) -> AnyView {
        if lineWidth == 0 {
            return content
        } else {
            return applyShadow(content: AnyView(content.shadow(color: color, radius: 1)), lineWidth: lineWidth - 1)
        }
    }
}

extension View {
    func glowBorder(color: Color, lineWidth: Int) -> some View {
        self.modifier(GlowBorder(color: color, lineWidth: lineWidth))
    }
}
