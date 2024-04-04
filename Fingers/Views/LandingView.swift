//
//  LandingView.swift
//  Fingers
//
//  Created by UsabilityLab on 3/7/24.
//

import SwiftUI
import WebKit // Allows gif views

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
                
                Text("Human players:")
                    .font(.title)
                    .padding()
                editPlayers(currPlayerCount: $humanPlayerCount, minPlayerCount: 1, allPlayerCount: allPlayerCount)
                
                Divider()
                
                Text("AI players:")
//                    .font(.title)
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
                        .background(Color("PrimaryColor"))
                        .foregroundColor(Color("SecondaryColor"))
                        .cornerRadius(20)
                }
                
                VStack {
                    Spacer()
                        .frame(height: 64)
                    
//                    Button("How to play") {
//                        self.showExplainView = true
//                    }
                    Button(action: {
                        self.showExplainView = true
                    }) {
                        Text("How to play")
                            .foregroundColor(Color("SecondaryColor"))
                    }
                }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .background(Color("BackgroundColor"))
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
                    .foregroundColor(Color("PrimaryColor"))
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
                    .foregroundColor(Color("PrimaryColor"))
            }
            .opacity(allPlayerCount < MAX_PLAYERS ? 1 : 0)
        }
    }
}
/// --------------------------------------
///             Tutorial View
/// --------------------------------------

struct ExplainView: View {
    @Binding var showExplainView: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Exit button
                VStack {
                    HStack {
                        Button(action: {
                            self.showExplainView = false
                        }) {
                            Image(systemName: "xmark")
                                .foregroundColor(Color("PrimaryColor"))
                                .imageScale(.large)
                        }
                        .padding()
                        
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
                    Spacer()
                        .frame(height: 20)
                    
                    VStack {
                        Text("Goal of the game: get the highest score!")
                        
                        Spacer()
                            .frame(height: 10)
                        
                        Text("Before the countdown ends during each round,")
                        Text("each player has to decide whether to:")
                        
                        Spacer()
                            .frame(height: 10)
                        
                        VStack {
                            Text("'stay'")
                            Text("(keep your finger on your player button)")
                            Spacer()
                                .frame(height: 10)
                            Text("or")
                            Spacer()
                                .frame(height: 10)
                            Text("'pull'")
                            Text("(leave your finger from your player button)")
                        }
                        
                        Spacer()
                            .frame(height: 10)
                        
                        VStack {
                            Text("At the same time, the current player")
                            Text("(the button with the white border)")
                            Text("has to predict how many fingers will be left")
                            Text("after the countdown.")
                            
                            Spacer()
                                .frame(height: 10)
                            
                            Text("After the countdown, if the amount on")
                            Text("'stayed' fingers is equal to the prediction ")
                            Text("of the current player,")
                            Text("the current player's score increases by 1.")
                        }
                    }
                    
                    GifImage("compressed_cropped_final")
                        .frame(height: 800)
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
