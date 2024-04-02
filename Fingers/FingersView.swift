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
    let position: CGPoint?
    
    func getButton(size: CGFloat, gameobj: FingersViewModel, isCurrentPlayer: Bool, currentState: gameState) -> some View {
        var color = Color.black
        var text = id
        
        if currentState == .Result {
            color = (player.decision!) ? Color.green : Color.red
            text = player.score.description
        }
        
        var strokeColor = color
        if isCurrentPlayer {
            strokeColor = Color.blue
        }
        
        return ZStack {
            Circle()
                .strokeBorder(strokeColor, lineWidth: 5)
                .background(Circle().fill(color))
            Text(text)
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
        .position(self.position!)
        .onLongPressGesture(minimumDuration: .infinity) {
            //pressed = true
        } onPressingChanged: { isPressing in
            if self.player.playerType == .Human && currentState != .Result {
                if isPressing {
                    player.makeDecision(decision: true)
                    print("-> \(self.id) stays")
                } else {
                    player.makeDecision(decision: false)
                    print("-> \(self.id) pulls")
                }
            }
        }
    }
}


struct FingersView: View {
    //---------------------------------
    //----------- Properties ----------
    //---------------------------------
    
    @StateObject var fingersGame: FingersViewModel
    @Binding var resetGame: Bool
    
    @State private var state = gameState.Initial
    @State private var currentPlayerName = ""
    @State private var currentPlayerType = playerType.Human
    @State private var textToUpdate = ""
    
    @State private var countDownCounter = 3
    @State private var botPredictionCounter = 2;
    
    @State private var showResetGameAlert = false
    @State private var updateScores = false
    
    private let MAX_COUNTDOWN_TIME = 3 //seconds
    private let MAX_BOT_PREDICTION_TIME = 2 //seconds
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
                    // Reset game button
                    VStack {
                        HStack {
                            Spacer()
                            Button(action: {
                                self.showResetGameAlert = true
                            }) {
                                Image(systemName: "arrow.counterclockwise")
                                    .foregroundColor(.blue)
                                    .imageScale(.large)
                            }
                            .padding()
                        }
                        Spacer()
                            .frame(height: size.height / 2 - 25)
                    }
                    
                    // Big red circle
                    Circle()
                        .stroke(.blue, lineWidth: 5)
                        .frame(width: size.width - 2 * CGFloat(circleSize), height: size.height)
                    
                    // Circle for each player
                    ForEach(playerViews) { player in
                        player.getButton(
                            size: CGFloat(circleSize),
                            gameobj: fingersGame,
                            isCurrentPlayer: (player.player.id == fingersGame.currentPlayer().id) ? true : false,
                            currentState: state
                        )
                    }
                    
                    // View logic
                    switch(state){
                        case .Countdown:
                            countDownTimerView(playerViews: playerViews)
                        case .Result:
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
                        self.updateScores = true
                        print("----- Round \(fingersGame.getRound().description) -----")
                    }
                    .position(x: size.width / 2, y: size.width / 2)
                case .Predict:
                    generatePredictView()
                case .Countdown:
                    Text("")
                case .Result:
                    resultView(playerViews: playerViews)
                }
            })
        }
        .alert(isPresented: $showResetGameAlert) {
            Alert(
                title: Text("Reset game"),
                message: Text("Are you sure you want to reset the game?"),
                primaryButton: .default(Text("Yes")) {
                    print("Reset game")
                    self.resetGame = true
                },
                secondaryButton: .cancel(Text("No")))
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
        for playerD in self.fingersGame.getPlayers() {
            path.addArc(center: CGPoint(x: x, y: y), radius: x - circleSize, startAngle: startAngle, endAngle: startAngle + angleInc, clockwise: true)
            playerViews.append(PlayerView(player: playerD, position: path.currentPoint))
            startAngle += angleInc
        }
        return playerViews
    }
    
    // Generate numbered buttons for the PredictView
    private func generateNumberedButtons() -> [NumberButton] {
        var buttons: [NumberButton] = []
        for index in 0..<fingersGame.getPlayerCount()+1 {
            let button = NumberButton(label: "\(index)", action: {
                let currentPlayer = fingersGame.currentPlayer()
                print("Player \(currentPlayer.name) predicts \(index.description)")
                
                // Make prediction for current human player
                currentPlayer.makePrediction(prediction: index)
                // Make decisions for bot players
                fingersGame.runBotModels()
                
                state = gameState.Countdown
            })
            buttons.append(button)
        }
        return buttons
    }
    
    //------------ Subviews -------------
    
    // Generates a PredictView or a botPredictionTimerView,
    // depending on whether the current player is a Human or a Bot
    private func generatePredictView() -> some View {
        print("Generate PredictView")
        if fingersGame.currentPlayer().playerType == .Human {
            return AnyView(PredictView(
                    model: fingersGame,
                    buttons: generateNumberedButtons()
                )
                .padding()
                .cornerRadius(20))
        }
        return AnyView(botPredictionTimerView())
    }
    
    // Generates a countDownTimerView
    private func countDownTimerView(playerViews: [PlayerView]) -> some View {
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
    
    // Generates a botPredictionTimerView
    private func botPredictionTimerView() -> some View {
        // Make decisions and prediction for the current bot player
        fingersGame.runBotModels()
        
        return VStack {
            Spacer()
                .frame(height: 128)
            Text("Bot \(fingersGame.currentPlayer().name) is predicting...")
                .font(.system(size: 30))
                .onReceive(timer) { time in
                    if botPredictionCounter == 0 {
                        botPredictionCounter = MAX_BOT_PREDICTION_TIME
                        print("Timer finished!")
                        
                        state = gameState.Countdown
                    } else {
                        botPredictionCounter -= 1
                    }
                }
        }
    }
    
    // Generates a resultView
    private func resultView(playerViews: [PlayerView]) -> some View {
        if self.updateScores {
            // Update scores after the round has ended
            self.fingersGame.updateScores()
            
            // Update bot models with knowledge about results from current round
            self.fingersGame.updateBotModels()
            
            // Check if the game is done by checking for the max score
//            if self.fingersGame.checkIfGameIsOver() == true {
//                print("Game over!")
//                // TODO: return game-over view!
//            }
        }
        
        return VStack {
            Spacer()
                .frame(height: 48)
            Text("Total fingers:")
                .font(.system(size: 20))
            Text(fingersGame.getOutputOnCup().description)
                .font(.system(size: 30))
            Text("Player \(self.fingersGame.currentPlayer().name) predicted:")
                .font(.system(size: 20))
            Text(fingersGame.currentPlayer().prediction!.description)
                .font(.system(size: 30))
            Text("Player \(self.fingersGame.currentPlayer().name)'s new score is:")
                .font(.system(size: 20))
            Text(fingersGame.currentPlayer().score.description)
                .font(.system(size: 30))
            Spacer()
                .frame(height: 32)
            Button(action: {
                state = gameState.Initial
                fingersGame.resetCurrentPrediction()
                fingersGame.nextRound()
            }) {
                Image(systemName: "play.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.white)
                    .padding(12)
                    .background(Color.blue)
                    .clipShape(Circle())
            }
        }
        .onAppear {
            self.updateScores = false
        }
    }
}
