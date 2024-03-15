//
//  FingersViewModel.swift
//  Fingers
//
//  Created by Tom on 28/02/2024.
//

import SwiftUI

class FingersViewModel: ObservableObject {
    var nr_humans: Int
    var nr_bots: Int
    var model: FingersModel
    
    init(n_humans: Int, n_bots: Int) {
        self.nr_humans = n_humans
        self.nr_bots = n_bots
        self.model = FingersModel(n_humans: self.nr_humans, n_bots: self.nr_bots)
    }
    
    func getPlayers() -> [Player] {
        return self.model.game.players
    }
    
    func nextPlayer() {
        if (model.game.currPlayerIndex < model.game.maxPlayers) {
            model.game.currPlayerIndex += 1;
        } else {
            model.game.currPlayerIndex = 0;
        }
    }
    
    func setPlayerScores(){
        
    }
}
