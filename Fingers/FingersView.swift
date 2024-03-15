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
    @State var player: Player
    let position: CGPoint?
    var id: String { player.name }
    @State var pressed: Bool = false
    
    func getButton(size: CGFloat, gameobj: FingersViewModel, checkCup: Bool) -> some View {
        var color = Color.black
        if checkCup {
            if player.isOnCup {
                color = Color.green
            } else {
                color = Color.red
            }
        }
        return ZStack {
            Circle()
                .foregroundColor(color)
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
                self.player.isOnCup = true
                gameobj.model.game.outputOnCup()
                print(self.id)
            } else {
                self.player.isOnCup = false
                gameobj.model.game.outputOnCup()
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
    @State private var botPredictionCounter = 5;
    
    private let MAX_BOT_PREDICTION_TIME = 5; //seconds
    
    let circleSize = 50
    
    var predictPlayers = ["1", "3", "4"]
    
    //---------------------------------
    //---------- Content view ---------
    //---------------------------------
    
    var body: some View {
        GeometryReader { proxy in
            // Parameters
            let size = proxy.size
            let players = createPlayerViews(players: fingersGame.getPlayers(), bounds: size, circleSize: CGFloat(circleSize))

            // View of the screen
            VStack(content:{
                //--------------------------------
                //--- View of the upper screen ---
                //--------------------------------
                
                ZStack(content: {
                    // Big red circle
                    Circle()
                        .stroke(.blue, lineWidth: 5)
                        .frame(width: size.width - 2 * CGFloat(circleSize), height: size.height)
                    
                    // Circle for each player
                    ForEach(players) { player in
                        player.getButton(size: CGFloat(circleSize), gameobj: fingersGame, checkCup: false)
                    }
                    
                    // View logic
                    switch(state){
                        case .Countdown:
                            countDownTimerView()
                        case .Result:
                            ForEach(players) { player in
                                player.getButton(size: CGFloat(circleSize), gameobj: fingersGame, checkCup: true)
                            }
                        
                            Text("Time!")
                                .font(.system(size: 48))
                        default:
                            Text("")
                    }
                })
                .frame(width: size.width, height: size.height / 2)
                
                //---------------------------------
                //--- View of the bottom screen ---
                //---------------------------------
                
                switch(state){
                    case .Initial:
                        Button("Predict") {
                            self.state = gameState.Predict
                        }
                        .position(x: size.width / 2, y: size.width / 2)
                    case .Predict:
                        // if player[currPlayerIndex] == player
                    
                    var players = fingersGame.getPlayers()
                    if players[fingersGame.model.game.currPlayerIndex] is Human {
                        PredictView(
                            playerID: "1",
                            buttons: generateNumberedButtons(numberOfPlayers: fingersGame.getPlayers().count)
                        )
                        .padding()
                        .cornerRadius(20)
                    } else {
                        let botPredictionTimer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                        Text("Bot is predicting...")
                            .font(.system(size: 48))
                            .onReceive(botPredictionTimer) { time in
                                if botPredictionCounter == 0 {
                                    state = gameState.Result
                                    botPredictionCounter = MAX_BOT_PREDICTION_TIME
                                    botPredictionTimer.upstream.connect().cancel()
                                } else {
                                    botPredictionCounter -= 1
                                }
                            }
                    }
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
    private func createPlayerViews(players: [Player], bounds: CGSize, circleSize: CGFloat) -> [PlayerView] {
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
    
    private func countDownTimerView() -> some View {
        let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        return Text(textToUpdate)
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
    
    private func generatePredictViews(players: [String]) -> some View {
        return Text("")
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
    
    private func generateNumberedButtons2(numberOfPlayers: Int, predictPlayers: [String]) -> [NumberButton] {
        var buttons: [NumberButton] = []
        for index in 0..<numberOfPlayers+1 {
            let button = NumberButton(label: "\(index)", action: {
                print("Player predicted \(index) remaining")
                selectedNumberIndex = index
            })
            buttons.append(button)
        }
        return buttons
    }
}

struct FingersView_Previews: PreviewProvider {
    static var previews: some View {
        let model = FingersViewModel(n_humans: 1, n_bots: 3)
        FingersView(fingersGame: model)
    }
}
