//
//  FingersViewModel.swift
//  Fingers
//
//  Created by Tom on 28/02/2024.
//

import SwiftUI

class FingersViewModel: ObservableObject {
    @Published var model: FingersModel
    
    var nr_humans: Int
    var nr_bots: Int
    
    init(n_humans: Int, n_bots: Int) {
        self.nr_humans = n_humans
        self.nr_bots = n_bots
        self.model = FingersModel(n_humans: self.nr_humans, n_bots: self.nr_bots)
    }
    
    func getPlayers() -> [Player] {
        return self.model.game.players
    }
    
    func getBotPlayers() -> [Player] {
        return self.model.game.getBotPlayers()
    }
    
    func getPlayerCount() -> Int {
        return self.model.game.playerCount
    }
    
    func getOutputOnCup() -> Int {
        return self.model.game.outputOnCup()
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
        return self.model.game.currentPlayer()
    }
    
    func resetCurrentPrediction() {
        currentPlayer().resetPrediction()
    }
    
    func nextPlayer() {
        self.model.game.nextPlayer()
    }
    
    func updateScores() -> Void {
        self.model.game.updateScores()
    }
    
    func checkIfGameIsOver() -> Bool {
        var isGameOver = false
        for player in self.getPlayers() {
            if player.score == 10 {
                isGameOver = true
            }
        }
        return isGameOver
    }
}
