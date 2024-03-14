//
//  FingersView.swift
//  Fingers
//
//  Created by Tom on 19/02/2024.
//

import SwiftUI

enum gameState {
    case Initial
    case Predict
    case Countdown
    case Result
}

struct PlayerView: Identifiable {
    let name: String
    let position: CGPoint?
    var id: String { name }
    @State var pressed: Bool = false
    
    func getButton(size: CGFloat) -> some View {
        return ZStack {
            Circle()
            Text(id.description)
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
        .position(self.position!)
        .onLongPressGesture(minimumDuration: .infinity) {
            //print("Finished")
        } onPressingChanged: { isPressing in
            if isPressing {
                pressed = true
                print(self.id)
            } else {
                pressed = false
                print("Finished")
            }
        }
    }
}

struct FingersView: View {
    //---------------------------------
    //----------- Properties ----------
    //---------------------------------
    
    @ObservedObject var fingersGame: FingersViewModel
    @State private var state = gameState.Initial
    @State private var selectedNumberIndex: Int? = nil
    @State private var counter = 3
    @State private var textToUpdate = ""
    
    let nr_players = 5
    let circleSize = 50
    
    //---------------------------------
    //---------- Content view ---------
    //---------------------------------
    
    var body: some View {
        GeometryReader { proxy in
            // Parameters
            let size = proxy.size
            let players = findPlayers(n: nr_players, bounds: size, circleSize: CGFloat(circleSize))

            // View of the screen
            VStack(content:{
                // ----------------------------------------------
                // -------- View of the game environment --------
                // ----------------------------------------------
                
                ZStack(content: {
                    // Big red circle
                    Circle()
                        .stroke(.red, lineWidth: 5)
                        .frame(width: size.width - 2 * CGFloat(circleSize), height: size.height)
                    
                    // Circle for each player
                    ForEach(players) { player in
                        player.getButton(size: CGFloat(circleSize))
                    }
                    
                    // Logic for countdown timer
                    if state == gameState.Countdown {
                        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                        Text(textToUpdate)
                            .font(.system(size: 48))
                            .onReceive(timer) { time in
                                if counter == 0 {
                                    state = gameState.Result
                                    timer.upstream.connect().cancel()
                                } else {
                                    textToUpdate = counter.description
                                    counter -= 1
                                }
                            }
                    }
                    if state == gameState.Result {
                        Text("Time!")
                            .font(.system(size: 48))
                    }
                    
                })
                .frame(width: size.width, height: size.height / 2)
                
                //---------------------------------
                //----------- View logic ----------
                //---------------------------------
                
                switch(state){
                    case .Initial:
                        Button("Predict") {
                            self.state = gameState.Predict
                        }
                        .position(x: size.width / 2, y: size.width / 2)
                    case .Predict:
                        PredictView(
                            buttons: generateNumberedButtons(numberOfPlayers: nr_players)
                        )
                        .padding()
                        .cornerRadius(20)
                        //.opacity(showPredictPopup ? 1 : 0)
                    case .Countdown:
                        let prediction = selectedNumberIndex!.description
                        Text("Player predicted \(prediction) fingers remaining")
                            .position(x: size.width / 2, y: size.width / 2)
                    case .Result:
                        Text("")
                }
            })
        }
    }

    //---------------------------------
    //----------- Functions -----------
    //---------------------------------
    
    // Find the coordinates for players in the view
    private func findPlayers(n: Int, bounds: CGSize, circleSize: CGFloat) -> [PlayerView] {
        let x = bounds.width / 2
        let y = bounds.height / 2
        var startAngle = Angle.degrees(-90)
        let angleInc = Angle.degrees(Double(360 / n))
        var players: [PlayerView] = []
        
        var path = Path()
        for id in 1...n {
            path.addArc(center: CGPoint(x: x, y: y), radius: x - circleSize, startAngle: startAngle, endAngle: startAngle + angleInc, clockwise: true)
            players.append(PlayerView(name: id.description, position: path.currentPoint))
            startAngle += angleInc
        }
        return players
    }
    
    // Generate numbered buttons for PredictView
    private func generateNumberedButtons(numberOfPlayers: Int) -> [NumberButton] {
        var buttons: [NumberButton] = []
        for index in 0..<numberOfPlayers+1 {
            let button = NumberButton(label: "\(index)", action: {
                print("Player predicted \(index) remaining")
                selectedNumberIndex = index
                state = gameState.Countdown
            })
            buttons.append(button)
        }
        return buttons
    }
    
    private func printPressed() {
        
    }
}

struct FingersView_Previews: PreviewProvider {
    static var previews: some View {
        let model = FingersViewModel()
        FingersView(fingersGame: model)
    }
}
