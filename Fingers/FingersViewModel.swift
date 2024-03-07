//
//  FingersViewModel.swift
//  Fingers
//
//  Created by Tom on 28/02/2024.
//

import SwiftUI

class FingersViewModel: ObservableObject {
    var model: FingersModel
    
    init() {
        model = FingersModel()
    }
    
    func getPlayers() -> [Player] {
        return self.model.game.players
    }
    
    func setPlayerScores(){
        
    }
}
