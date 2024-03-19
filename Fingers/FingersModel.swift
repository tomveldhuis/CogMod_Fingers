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
    
    var players: [Player]
    @Published var currentPlayerIdx: Int
    var currentPlayerType: playerType
    
    init(nr_humans: Int, nr_bots: Int){
        self.nr_humans = nr_humans
        self.nr_bots = nr_bots
        
        var localPlayers: [Player] = []
        let localPlayerCount = nr_humans + nr_bots
        
        for i in 0..<localPlayerCount{
            if i < self.nr_bots {
                localPlayers.append(Bot(id: i, name: "B\(i+1)"))
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
        print("N on cup: \(i)")
        return i
    }
    
    func determineWinners() -> [Player] {
        var winners: [Player] = []
        let output = outputOnCup()
        for player in self.players {
            if player.prediction == output {
                winners.append(player)
            }
        }
        return winners
    }
    
    func updateScores() -> Void {
        for player in self.determineWinners() {
            var player = player
            print("Player \(player.name) had \(player.score)")
            player.score += 1
            print("and now \(player.name) has \(player.score)")
        }
    }
    
    // Returns current player
    func currentPlayer() -> Player {
        return self.players[self.currentPlayerIdx]
    }
    
    // Goes to the next player
    func nextPlayer() {
        // Returns true if all players have been checked
        self.currentPlayerIdx += 1
        if self.currentPlayerIdx == self.playerCount {
            print("\(self.players[self.currentPlayerIdx-1].name) -> \(self.players[0].name)")
            self.currentPlayerIdx = 0
        } else {
            print("\(self.players[self.currentPlayerIdx-1].name) -> \(self.players[self.currentPlayerIdx].name)")
        }
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
    // Make a decision about whether to put your finger on the cup
    func makeDecision(decision: Bool)
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
    
    func makeDecision(decision: Bool) {
        self.decision = decision
    }
}

class Bot: Player {
    var id: Int
    var name: String
    var playerType: playerType
    var score: Int
    
    var prediction: Int?
    var decision: Bool?
    
    var model: BotModel
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
        self.playerType = .Bot
        self.score = 0
        
        self.prediction = nil
        self.decision = nil
        
        self.model = BotModel()
    }
    
    func makePrediction() {
        // TODO: add prediction making from model
        self.prediction = 0 //For now, assume that bots always predict 0
    }
    
    func makeDecision() {
        // TODO: add decision making from model
        self.decision = true //For now, assume that bots always stay
    }
    
    // Overloaded functions for bot predictions/decisions
    func makeDecision(decision: Bool) {
        makeDecision()
    }
    func makePrediction(prediction: Int) {
        makePrediction()
    }
    
    
    
//  When a round ends, append it to memory (using some tactic)
    func commitMemory(){}
    func pullHistory(){}
    func decidePullOrStay(){}
    func predictFingers(){}
}
