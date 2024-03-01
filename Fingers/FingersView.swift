//
//  FingersView.swift
//  Fingers
//
//  Created by Tom on 19/02/2024.
//

import SwiftUI

struct FingersView: View {
    @ObservedObject var fingersGame: FingersViewModel
    @State private var showPredictPopup = false
    @State private var selectedNumberIndex: Int? = nil
    
    // Represents a player in the view
    private struct Player: Identifiable {
        let name: String
        let position: CGPoint?
        var id: String { name }
    }
    
    // Find the coordinates for players in the view
    private func findPlayers(n: Int, bounds: CGSize, circleSize: CGFloat) -> [Player] {
        let x = bounds.width / 2
        let y = bounds.height / 2
        var startAngle = Angle.degrees(-90)
        let angleInc = Angle.degrees(Double(360 / n))
        var players: [Player] = []
        
        var path = Path()
        for id in 1...n {
            path.addArc(center: CGPoint(x: x, y: y), radius: x - circleSize, startAngle: startAngle, endAngle: startAngle + angleInc, clockwise: true)
            players.append(Player(name: id.description, position: path.currentPoint))
            startAngle += angleInc
        }
        return players
    }
    
    private func generateNumberedButtons(numberOfPlayers: Int) -> [NumberButton] {
        var buttons: [NumberButton] = []
        for index in 0..<numberOfPlayers+1 {
            let button = NumberButton(label: "\(index)", action: {
                print("Player predicted \(index) remaining")
                selectedNumberIndex = index
                showPredictPopup = false
            })
            buttons.append(button)
        }
        return buttons
    }
    
    // The ContentView
    var body: some View {
        
        let nr_players = 8
        
        GeometryReader { proxy in
            // Parameters
            let circleSize = 50
            
            let size = proxy.size
            let players = findPlayers(n: nr_players, bounds: size, circleSize: CGFloat(circleSize))
            
            ZStack(content: {
                Circle()
                    .stroke(.red, lineWidth: 5)
                    .frame(width: size.width - 2 * CGFloat(circleSize), height: size.height - 2 * CGFloat(circleSize))
                ForEach(players) { player in
                    Circle()
                        .frame(width: CGFloat(circleSize), height: CGFloat(circleSize))
                        .position(player.position!)
                }
            })
        }
        
        // Prediction overlay
        ZStack {
            VStack {
                if showPredictPopup {
                    PredictView(
                        buttons: generateNumberedButtons(numberOfPlayers: nr_players)
                    )
                    .padding()
                    .cornerRadius(20)
                    //.opacity(showPredictPopup ? 1 : 0)
                }
                else if let prediction = selectedNumberIndex {
                    Text("Player predicted \(prediction) fingers remaining")
                }
                else {
                    Button("Predict") {
                        self.showPredictPopup.toggle()
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.clear)
    }
}

struct FingersView_Previews: PreviewProvider {
    static var previews: some View {
        let model = FingersViewModel()
        FingersView(fingersGame: model)
    }
}
