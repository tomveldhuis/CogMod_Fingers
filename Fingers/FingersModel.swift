//
//  FingersModel.swift
//  Fingers
//
//  Created by Tom on 28/02/2024.
//

import Foundation

struct FingersModel {
    
    /// The ACT-R model
//    internal var model = Model()
    
    /// Function that loads in a text file that is interpreted as the model
    /// - Parameter filename: filename to be loaded (extension .actr is added by the function)
//    func loadModel(filename: String) {
//        model.loadModel(fileName: filename)
//    }
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
        self.isOnCup = true
        self.isPredicting = false
        self.score = 0
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
        self.isOnCup = true
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
