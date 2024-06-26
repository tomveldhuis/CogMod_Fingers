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
                Text("Finger   \n   Spoof")
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
                    .frame(height: 60)
                
                
                let allPlayerCount = humanPlayerCount + botPlayerCount;
                
                Text("Human players:")
                    .font(.custom("BDSupperRegular", size: 20))
                    .padding()
                editPlayers(currPlayerCount: $humanPlayerCount, minPlayerCount: 1, allPlayerCount: allPlayerCount)
                
                Divider()
                
                Text("AI players:")
                   .font(.custom("BDSupperRegular", size: 20))
                    .padding()
                editPlayers(currPlayerCount: $botPlayerCount, minPlayerCount: 0, allPlayerCount: allPlayerCount)
                
                Spacer()
                    .frame(height: 40)
                
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
                    Spacer()
                        .frame(height: 10)
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
                    Spacer()
                        .frame(height:30)
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
                            .font(Font.custom("Keep on Truckin'", size: 46))
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
                        .frame(height: 30)
                    
                    ScrollView {
                        Text("Goal of the game:\nget the highest score!")
                            .fontWeight(.bold)
                            .font(.custom("BDSupperRegular", size: 18))
                            .multilineTextAlignment(.center)
                        
                        Spacer()
                            .frame(height: 40)
                        
                        HStack {
                            GifImage("compressed_cropped_final")
                                .frame( width:250, height: 250)
                        }
                        
                        
                        
                        Spacer()
                            .frame(height: 40)
                        
                        HStack {
                            
                            VStack {
                                Text("1)")
                                    .font(.custom("BDSupperRegular", size: 20))
                                Spacer()
                                    .frame(height: 40)
                                Text("2)")
                                    .font(.custom("BDSupperRegular", size: 20))
                                Spacer()
                                    .frame(height: 125)
                                Text("3)")
                                    .font(.custom("BDSupperRegular", size: 20))
                                Spacer()
                                    .frame(height: 40)
                                Text("4)")
                                    .font(.custom("BDSupperRegular", size: 20))
                                Spacer()
                                    .frame(height: 10)
                            }
                            
                            VStack {
                                VStack {
                                    Text("Players take turns, counting down\nfrom 3 to 0")
                                        .font(.custom("BDSupperRegular", size: 18))
                                    
                                }
                                
                                Spacer()
                                    .frame(height: 20)
                                
                                VStack {
                                    Text("When the countdown reaches 0,\neveryone decides to:")
                                        .font(.custom("BDSupperRegular", size: 18))
                                    Spacer()
                                        .frame(height: 10)
                                    Text("Stay - keep your finger on your\nplayer button")
                                        .font(.custom("BDSupperRegular", size: 18))
                                    Spacer()
                                        .frame(height: 5)
                                    Text("Pull - pull your finger away from\nyour button")
                                        .font(.custom("BDSupperRegular", size: 18))
                                }
                                
                                Spacer()
                                    .frame(height: 20)
                                
                                VStack {
                                    Text("In your turn, you must try to predict\nhow many fingers remain")
                                        .font(.custom("BDSupperRegular", size: 18))
                                }
                                
                                Spacer()
                                    .frame(height: 20)
                                
                                VStack {
                                    Text("Got it right? Then you've earned a point!")
                                        .font(.custom("BDSupperRegular", size: 18))
                                }
                                
                            }
                        }
                        
                    }
                    .frame(width:330)
                    .multilineTextAlignment(.leading)
                    
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
