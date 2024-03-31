//
//  FingersModel.swift
//  Fingers
//
//  Created by Tom on 28/02/2024.
//

import Foundation

enum playerType {
    case Human
    case Bot
}

class FingersModel {
    var nr_humans: Int
    var nr_bots: Int
    var game: Game
    
    init(n_humans: Int, n_bots: Int){
        self.nr_humans = n_humans
        self.nr_bots = n_bots
        self.game = Game(nr_humans: nr_humans, nr_bots: nr_bots)
    }
    /// The ACT-R model
//    internal var model = Model()
    
    /// Function that loads in a text file that is interpreted as the model
    /// - Parameter filename: filename to be loaded (extension .actr is added by the function)
//    func loadModel(filename: String) {
//        model.loadModel(fileName: filename)
//    }
}

class Game: ObservableObject {
    var nr_humans: Int
    var nr_bots: Int
    var playerCount: Int
    var round: Int
    
    var players: [Player]
    @Published var currentPlayerIdx: Int
    var currentPlayerType: playerType
    
    init(nr_humans: Int, nr_bots: Int){
        self.nr_humans = nr_humans
        self.nr_bots = nr_bots
        self.round = 1
        
        var localPlayers: [Player] = []
        let localPlayerCount = nr_humans + nr_bots
        
        for i in 0..<localPlayerCount{
            if i < self.nr_bots {
                localPlayers.append(Bot(id: i, name: "B\(i+1)", playerCount: localPlayerCount))
            } else {
                localPlayers.append(Human(id: i, name: "H\(i+1-nr_bots)"))
            }
        }
        localPlayers.shuffle()
        
        let currentPlayerIdx = 0
        self.playerCount = localPlayerCount
        self.currentPlayerIdx = currentPlayerIdx
        self.currentPlayerType = localPlayers[currentPlayerIdx].playerType
        self.players = localPlayers
        print(self.players)
    }
    
    // Returns the total number of fingers on the cup
    func outputOnCup() -> Int {
        var i = 0
        for player in self.players {
            if player.decision == true{
                i += 1
            }
        }
        //print("N on cup: \(i)")
        return i
    }
    
    func updateScores() -> Void {
        if currentPlayer().prediction! == outputOnCup() {
            self.players[self.currentPlayerIdx].score += 1
        }
    }
    
    // Returns current player
    func currentPlayer() -> Player {
        return self.players[self.currentPlayerIdx]
    }
    
    // Goes to the next player
    func nextPlayer() {
        self.round += 1
        self.currentPlayerIdx += 1
        if self.currentPlayerIdx == self.playerCount {
            self.currentPlayerIdx = 0
        }
    }
    
    func getBotPlayers() -> [Player] {
        var botPlayers: [Player] = []
        for player in players {
            if player.playerType == .Bot {
                botPlayers.append(player)
            }
        }
        return botPlayers
    }
}

protocol Player {
    // Name of player
    var id: Int { get }
    var name: String { get }
    var playerType: playerType { get }
    // Current score of the player
    var score: Int { get set }
    
    // Current prediction of the player
    var prediction: Int? { get set }
    // Current decision of the player
    // -> finger on cup / finger not on cup
    var decision: Bool? { get set }
    
    // Make a prediction about how many fingers will stay on the cup
    func makePrediction(prediction: Int)
    //
    func resetPrediction()
    // Make a decision about whether to put your finger on the cup
    func makeDecision(decision: Bool)
    
    func runModel(isActive: Bool)
    func updateModel(isActive: Bool, outputOnCup: Int, currentPrediction: Int)
}

class Human: Player {
    var id: Int
    var name: String
    var playerType: playerType
    var score: Int
    
    var prediction: Int?
    var decision: Bool?
    
    // Whether the human player has currently
    // their finger on the cup
    var isOnCup: Bool
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
        self.playerType = .Human
        self.score = 0
        
        self.prediction = nil
        self.decision = false
        
        self.isOnCup = false
    }
    
    func makePrediction(prediction: Int) {
        self.prediction = prediction
    }
    
    func resetPrediction() {
        self.prediction = nil
    }
    
    func makeDecision(decision: Bool) {
        self.decision = decision
    }
    
    func runModel(isActive: Bool) {
        
    }
    
    func updateModel(isActive: Bool, outputOnCup: Int, currentPrediction: Int) {
        
    }
}

class Bot: Player {
    var id: Int
    var name: String
    var playerType: playerType
    var score: Int
    
    var prediction: Int?
    var decision: Bool?
    
    var model: BotModel_Tom
    
    init(id: Int, name: String, playerCount: Int) {
        self.id = id
        self.name = name
        self.playerType = .Bot
        self.score = 0
        
        self.prediction = nil
        self.decision = nil
        
        self.model = BotModel_Tom(name: name, playerCount: playerCount)
    }
    
    func resetPrediction() {
        self.prediction = nil
    }
    
    func makeDecision(decision: Bool) {
        self.decision = decision
    }
    func makePrediction(prediction: Int) {
        self.prediction = prediction
    }
    
    func runModel(isActive: Bool) {
        self.model.run(isActive: isActive)
        
        // Check for action chunks
        if self.model.model.actionChunk() {
            let actionType = self.model.model.lastAction(slot: "isa")!
            if actionType == "decision_prediction" {
                // Add prediction
                let predictionAction = self.model.model.lastAction(slot: "prediction")!
                makePrediction(prediction: Int(Double(predictionAction)!))
            }
            if actionType == "decision" || actionType == "decision_prediction" {
                // Add decision
                let decisionAction = self.model.model.lastAction(slot: "decision")!
                if decisionAction == "stay" {
                    makeDecision(decision: true)
                }
                if decisionAction == "pull" {
                    makeDecision(decision: false)
                }
            }
        }
    }
    
    func updateModel(isActive: Bool, outputOnCup: Int, currentPrediction: Int) {
        if self.model.model.actionChunk() {
            model.updateActionChunk(outputOnCup: outputOnCup, currentPrediction: currentPrediction)
        }
        self.model.run(isActive: isActive)
    }
}
