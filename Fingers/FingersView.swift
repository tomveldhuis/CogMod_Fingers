//
//  FingersView.swift
//  Fingers
//
//  Created by Tom on 19/02/2024.
//

import SwiftUI

struct FingersView: View {
    @ObservedObject var fingersGame: FingersViewModel
    
    private struct Player: Identifiable {
        let name: String
        let position: CGPoint?
        var id: String { name }
    }
    
    private func findPlayers(n: Int) -> [Player] {
        let x = UIScreen.main.bounds.width / 2
        let y = UIScreen.main.bounds.height / 2
        var startAngle = Angle.degrees(-90)
        let angleInc = Angle.degrees(Double(360 / n))
        var players: [Player] = []

        var path = Path()
        for id in 1...n {
            path.addArc(center: CGPoint(x: x, y: y), radius: x - 50, startAngle: startAngle, endAngle: startAngle + angleInc, clockwise: true)
            players.append(Player(name: id.description, position: path.currentPoint))
            startAngle += angleInc
        }
        return players
    }
    
    var body: some View {
        let players = findPlayers(n: 5)
        
        return ZStack(content: {
            ForEach(players) { player in
                Circle()
                    .frame(width: 50, height: 50)
                    .position(player.position!)
            }
        })
    }
}

struct FingersView_Previews: PreviewProvider {
    static var previews: some View {
        let model = FingersViewModel()
        FingersView(fingersGame: model)
    }
}
