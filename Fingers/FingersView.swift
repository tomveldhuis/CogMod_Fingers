//
//  FingersView.swift
//  Fingers
//
//  Created by Tom on 19/02/2024.
//

import SwiftUI

struct FingersView: View {
    @ObservedObject var fingersGame: FingersViewModel
    
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
    
    // The ContentView
    var body: some View {
        GeometryReader { proxy in
            // Parameters
            let circleSize = 50
            let nr_players = 8
            
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
    }
}

struct FingersView_Previews: PreviewProvider {
    static var previews: some View {
        let model = FingersViewModel()
        FingersView(fingersGame: model)
    }
}
