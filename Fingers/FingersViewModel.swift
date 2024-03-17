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
    
    func getPlayerCount() -> Int {
        return self.model.game.playerCount
    }
    
    func getOutputOnCup() -> Int {
        return self.model.game.outputOnCup()
    }
    
    func getWinners() -> [Player] {
        return self.model.game.winners()
    }
    
    func getWinnersString() -> String {
        let winners = getWinners()
        var output = ""
        for idx in 0..<winners.count {
            output += winners[idx].name
            if idx != winners.count - 1 {
                output += ", "
            }
        }
        return output
    }
    
    func currentPlayer() -> Player {
        return self.model.game.currentPlayer()
    }
    
    func nextPlayer() -> Bool {
        return self.model.game.nextPlayer()
    }
    
    func setPlayerScores(){
        
    }
}
