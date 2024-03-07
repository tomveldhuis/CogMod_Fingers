//
//  FingersModel.swift
//  Fingers
//
//  Created by Tom on 28/02/2024.
//

import Foundation

struct FingersModel {
    var game = Game(n_humans: 1, n_bots: 2)
    /// The ACT-R model
//    internal var model = Model()
    
    /// Function that loads in a text file that is interpreted as the model
    /// - Parameter filename: filename to be loaded (extension .actr is added by the function)
//    func loadModel(filename: String) {
//        model.loadModel(fileName: filename)
//    }
}

class Game {
    var players: [Player] = []
    
    init(n_humans: Int, n_bots: Int){
//        var players: [Player] = []
        var n_humans = n_humans
        var n_bots = n_bots
        var j = 0
        
        for i in 1...n_bots{
            self.players.append(Bot(name:"Bot \(i)", number:j))
            j += 1
        }
        for i in 1...n_humans{
            self.players.append(Human(name:"Human \(i)", number:j))
            j += 1
        }
        
        self.players.shuffle()
        print(self.players)
    } // end of init
    
    func outputOnCup(){
        var i = 0
        for player in self.players {
            if player.isOnCup == true{
                i += 1
            }
        }
        print("N on cup: \(i)")
    }
}


protocol Player {
    var name: String { get }
    var number: Int { get set }
    var score: Int { get set }
    var isOnCup: Bool { get set }
    var isPredicting: Bool { get set }
    
}

class Human: Player {
    var name: String
    var number: Int
    var score: Int
    
    var isOnCup: Bool
    var isPredicting: Bool
    
    init(name: String, number: Int) {
        self.name = name
        self.number = number
        self.isOnCup = false
        self.isPredicting = false
        self.score = 0
    }
    
    func printStatus(){
        print("Human \(self.name) is on cup?: \(self.isOnCup)")
    }
}

class Bot: Player {
    var name: String
    var number: Int
    var score: Int
    
    var isOnCup: Bool
    var isPredicting: Bool
    
    var model: Model
    
    init(name: String, number: Int) {
        self.name = name
        self.number = number
        self.isOnCup = false
        self.isPredicting = false
        self.score = 0
        
        self.model = Model()
    }
    
//  When a round ends, append it to memory (using some tactic)
    func commitMemory(){}

    func pullHistory(){}
    func decidePullOrStay(){}
    func predictFingers(){}
}
