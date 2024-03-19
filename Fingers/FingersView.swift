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
    var id: String { player.name }
    
    @State var player: Player
    @State var pressed: Bool = false
    let position: CGPoint?
    
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
                //gameobj.model.game.outputOnCup()
                print(self.id)
            } else {
                self.player.isOnCup = false
                //gameobj.model.game.outputOnCup()
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
    
    @StateObject var fingersGame: FingersViewModel
    @State private var state = gameState.Initial
    @State private var currentPlayerName = ""
    @State private var currentPlayerType = playerType.Human
    @State private var textToUpdate = ""
    
    @State private var countDownCounter = 3
    @State private var botPredictionCounter = 2;
    @State private var resultCounter = 3
    
    private let MAX_COUNTDOWN_TIME = 3 //seconds
    private let MAX_BOT_PREDICTION_TIME = 2 //seconds
    private let MAX_RESULT_TIME = 3 //seconds
    private let circleSize = 50
    
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    //---------------------------------
    //---------- Content view ---------
    //---------------------------------
    
    var body: some View {
        let players = fingersGame.getPlayers()
        
        GeometryReader { proxy in
            // Parameters
            let size = proxy.size
            let playerViews = createPlayerViews(players: players, bounds: size, circleSize: CGFloat(circleSize))

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
                    ForEach(playerViews) { player in
                        player.getButton(size: CGFloat(circleSize), gameobj: fingersGame, checkCup: false)
                    }
                    
                    // View logic
                    switch(state){
                        case .Countdown:
                            countDownTimerView()
                        case .Result:
                            ForEach(playerViews) { player in
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
                        ZStack {
                            generatePredictView(
                                playerName: currentPlayerName,
                                playerType: currentPlayerType
                            )
                        }
                        .onAppear(
                            perform: {
                                currentPlayerName = fingersGame.currentPlayer().name
                                currentPlayerType = fingersGame.currentPlayer().playerType
                            }
                        )
                        .onReceive(fingersGame.model.game.$currentPlayerIdx) { newIdx in
                            currentPlayerName = fingersGame.currentPlayer().name
                            currentPlayerType = fingersGame.currentPlayer().playerType
                        }
                    case .Countdown:
                        Text("")
                    case .Result:
                        resultView(playerViews: playerViews)
                }
            })
        }
    }

    //---------------------------------
    //----------- Functions -----------
    //---------------------------------
    
    // Find the coordinates for players in the view
    private func createPlayerViews(players: [Player], bounds: CGSize, circleSize: CGFloat) -> [PlayerView] {
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
    
    private func generateNumberedButtons() -> [NumberButton] {
        var buttons: [NumberButton] = []
        for index in 0..<fingersGame.getPlayerCount()+1 {
            let button = NumberButton(label: "\(index)", action: {
                let currentPlayer = fingersGame.currentPlayer()
                print("Player \(currentPlayer.name) predicts \(index.description)")
                currentPlayer.makePrediction(prediction: index)
                
                if fingersGame.nextPlayer() {
                    state = gameState.Countdown
                }
            })
            buttons.append(button)
        }
        return buttons
    }
    
    //------------ Subviews -------------
    
    private func generatePredictView(playerName: String, playerType: playerType) -> some View {
        if playerType == .Human {
            return AnyView(PredictView(
                    game: fingersGame,
                    buttons: generateNumberedButtons()
                )
                .padding()
                .cornerRadius(20))
        }
        return AnyView(botPredictionTimerView())
    }
    
    private func countDownTimerView() -> some View {
        return Text(textToUpdate)
            .font(.system(size: 48))
            .onReceive(timer) { time in
                if countDownCounter == 0 {
                    countDownCounter = MAX_COUNTDOWN_TIME
                    textToUpdate = ""
                    state = gameState.Result
                } else {
                    textToUpdate = countDownCounter.description
                    countDownCounter -= 1
                }
            }
    }
    
    private func botPredictionTimerView() -> some View {
        return Text("Bot \(currentPlayerName) is predicting...")
            .font(.system(size: 30))
            .onReceive(timer) { time in
                if botPredictionCounter == 0 {
                    botPredictionCounter = MAX_BOT_PREDICTION_TIME
                    print("Timer finished!")
                    
                    if fingersGame.nextPlayer() {
                        state = gameState.Countdown
                    }
                } else {
                    botPredictionCounter -= 1
                }
            }
    }
    
    private func resultView(playerViews: [PlayerView]) -> some View {
        // Update scores after the round has ended
        self.fingersGame.updateScores()
        
        // Check if the game is done by checking for the max score
        if self.fingersGame.checkIfGameIsOver() == true {
            print("Game over!")
            // TODO: return game-over view!
        }
        
        return VStack {
            Text("Total fingers: \(fingersGame.getOutputOnCup().description)\n\nPredictions:")
            ForEach(playerViews) { player in
                let playerName = player.player.name
                if player.player.prediction == nil {
                    Text("Player \(playerName) has no prediction")
                } else {
                    let playerPrediction = player.player.prediction!.description
                    Text("Player \(playerName) predicted \(playerPrediction)")
                }
            }
            Text("\nWinners: \(fingersGame.getWinnersString())")
        }
        .onReceive(timer) { time in
            if resultCounter == 0 {
                state = gameState.Initial
                resultCounter = MAX_RESULT_TIME
            } else {
                resultCounter -= 1
            }
        }
    }
}

struct FingersView_Previews: PreviewProvider {
    static var previews: some View {
        let model = FingersViewModel(n_humans: 1, n_bots: 3)
        FingersView(fingersGame: model)
    }
}
