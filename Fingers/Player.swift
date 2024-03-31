//
//  Player.swift
//  Fingers
//
//  Created by Tom on 31/03/2024.
//

import Foundation

enum playerType {
    case Human
    case Bot
}

protocol Player {
    // Name of player
    var id: Int { get }
    var name: String { get }
    // Type of player: Human or Bot
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
    // Reset the prediction of the player
    func resetPrediction()
    // Make a decision about whether to put your finger on the cup
    func makeDecision(decision: Bool)
    
    // ONLY FOR BOTS
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
        // Empty function
    }
    
    func updateModel(isActive: Bool, outputOnCup: Int, currentPrediction: Int) {
        // Empty function
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

