//
//  FingersViewModel.swift
//  Fingers
//
//  Created by Tom on 28/02/2024.
//

import SwiftUI

class FingersViewModel: ObservableObject {
    @Published var model: FingersModel
    @Published var pressedNumber: Int
    
    var nr_humans: Int
    var nr_bots: Int
    
    init(n_humans: Int, n_bots: Int) {
        self.nr_humans = n_humans
        self.nr_bots = n_bots
        self.model = FingersModel(nr_humans: self.nr_humans, nr_bots: self.nr_bots)
        self.pressedNumber = 0
    }
    
    func getPlayers() -> [Player] {
        return self.model.players
    }
    
    func getHumanPlayers() -> [Player] {
        return self.model.getHumanPlayers()
    }
    
    func getBotPlayers() -> [Player] {
        return self.model.getBotPlayers()
    }
    
    func getPlayerCount() -> Int {
        return self.model.playerCount
    }
    
    func getOutputOnCup() -> Int {
        return self.model.outputOnCup()
    }
    
    func runBotModels() {
        for player in getBotPlayers() {
            if player.id == currentPlayer().id {
                player.runModel(isActive: true)
            } else {
                player.runModel(isActive: false)
            }
        }
    }
    
    func updateBotModels() {
        print("Output: \(getOutputOnCup())")
        for player in getBotPlayers() {
            if player.id == currentPlayer().id {
                player.updateModel(
                    isActive: true,
                    outputOnCup: getOutputOnCup(),
                    currentPrediction: currentPlayer().prediction!
                )
            } else {
                player.updateModel(
                    isActive: false,
                    outputOnCup: getOutputOnCup(),
                    currentPrediction: currentPlayer().prediction!
                )
            }
        }
    }
    
    func currentPlayer() -> Player {
        return self.model.currentPlayer()
    }
    
    func resetCurrentPrediction() {
        currentPlayer().resetPrediction()
    }
    
    func nextRound() {
        self.model.nextRound()
    }
    
    func updateScores() -> Void {
        self.model.updateScores()
    }
    
    func getRound() -> Int {
        return self.model.round
    }
    
    func updatePressedNumber() {
        var newNumber = 0
        for player in getHumanPlayers() {
            if player.decision == true {
                newNumber += 1
            }
        }
        self.pressedNumber = newNumber
    }
    
    func resetPressedNumber() {
        self.pressedNumber = 0
    }
}
