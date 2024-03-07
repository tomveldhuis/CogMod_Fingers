//
//  FingersView.swift
//  Fingers
//
//  Created by Tom on 19/02/2024.
//

import SwiftUI

struct PlayerView: Identifiable {
    @State var player: Player
    let position: CGPoint?
    var id: String { player.name }
    
    func getButton(size: CGFloat, gameobj: FingersViewModel) -> some View {
        return Circle()
            .frame(width: size, height: size)
            .position(self.position!)
            .onLongPressGesture(minimumDuration: .infinity) {
                //print("Finished")
            } onPressingChanged: { isPressing in
                if isPressing {
                    self.player.isOnCup = true
                    gameobj.model.game.outputOnCup()
                    print(self.id)
                } else {
                    self.player.isOnCup = false
                    gameobj.model.game.outputOnCup()
                }
            }
    }
}


struct FingersView: View {
    @ObservedObject var fingersGame: FingersViewModel
    @State private var showPredictPopup = false
    @State private var selectedNumberIndex: Int? = nil
//    private var centerView: any View
    
    // Find the coordinates for players in the view
    private func createPlayerViews(players: [Player], bounds: CGSize, circleSize: CGFloat) -> [PlayerView] {
        print("in create player views")
//        var playersD: [Binding<Player>] = self.fingersGame.model.game.players
        let x = bounds.width / 2
        let y = bounds.height / 2
        var startAngle = Angle.degrees(-90)
        let angleInc = Angle.degrees(Double(360 / players.count))
        var playerViews: [PlayerView] = []
        
        var path = Path()
        for playerD in self.fingersGame.model.game.players {
            path.addArc(center: CGPoint(x: x, y: y), radius: x - circleSize, startAngle: startAngle, endAngle: startAngle + angleInc, clockwise: true)
            playerViews.append(PlayerView(player: playerD, position: path.currentPoint))
            startAngle += angleInc
        }
        return playerViews
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
        var players: [Player] = self.fingersGame.getPlayers()
        let nr_players = players.count
        
        GeometryReader { proxy in
            // Parameters
            let circleSize = 50
            
            let size = proxy.size
            let playerViews = createPlayerViews(players: players, bounds: size, circleSize: CGFloat(circleSize))
            
            ZStack(content: {
                // Big red circle
                Circle()
                    .stroke(.red, lineWidth: 5)
                    .frame(width: size.width - 2 * CGFloat(circleSize), height: size.height - 2 * CGFloat(circleSize))
                
                ForEach(playerViews) { playerView in
                    // Circle for each player
                    playerView.getButton(size: CGFloat(circleSize), gameobj: fingersGame)
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
