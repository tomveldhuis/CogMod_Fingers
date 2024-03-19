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
            if player.isOnCup == true{
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
    func nextPlayer() -> Bool {
        // Returns true if all players have been checked
        self.currentPlayerIdx += 1
        if self.currentPlayerIdx == self.playerCount {
            print("\(self.players[self.currentPlayerIdx-1].name) -> \(self.players[0].name)")
            self.currentPlayerIdx = 0
            return true
        } else {
            print("\(self.players[self.currentPlayerIdx-1].name) -> \(self.players[self.currentPlayerIdx].name)")
        }
        return false
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
    // Whether the players has the finger on the cup
    
    var isOnCup: Bool { get set }
    //var isPredicting: Bool { get set }
    
    func makePrediction(prediction: Int)
}

class Human: Player {
    var id: Int
    var name: String
    var playerType: playerType
    var score: Int
    
    var prediction: Int?
    var isOnCup: Bool
    //var isPredicting: Bool
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
        self.playerType = .Human
        self.score = 0
        
        self.prediction = nil
        self.isOnCup = true
        //self.isPredicting = false
    }
    
    func makePrediction(prediction: Int) {
        self.prediction = prediction
    }
    
//    func printStatus(){
//        print("Human \(self.name) is on cup?: \(self.isOnCup)")
//    }
}

class Bot: Player {
    var id: Int
    var name: String
    var playerType: playerType
    var score: Int
    
    var prediction: Int?
    var isOnCup: Bool
    //var isPredicting: Bool
    
    var model: Model
    
    init(id: Int, name: String) {
        self.id = id
        self.name = name
        self.playerType = .Bot
        self.score = 0
        
        self.prediction = nil
        self.isOnCup = true
        //self.isPredicting = false
        
        self.model = Model()
    }
    
    func makePrediction() {
        
    }
    
    // Overloaded function
    func makePrediction(prediction: Int) {
        makePrediction()
    }
    
//  When a round ends, append it to memory (using some tactic)
    func commitMemory(){}
    func pullHistory(){}
    func decidePullOrStay(){}
    func predictFingers(){}
}
