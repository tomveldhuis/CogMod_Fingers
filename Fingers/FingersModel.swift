//
//  FingersModel.swift
//  Fingers
//
//  Created by Tom on 28/02/2024.
//

import Foundation
import GameplayKit

class FingersModel: ObservableObject {
    var nr_humans: Int
    var nr_bots: Int
    var playerCount: Int
    var round: Int
    
    var players: [Player]
    @Published var currentPlayerIdx: Int
    var currentPlayerType: playerType
    
    init(nr_humans: Int, nr_bots: Int){
        self.nr_humans = nr_humans
        self.nr_bots = nr_bots
        self.round = 1
        
        var localPlayers: [Player] = []
        let localPlayerCount = nr_humans + nr_bots
        
        let dist = GKGaussianDistribution(lowestValue: 0, highestValue: 10000)
        
        for i in 0..<localPlayerCount{
            // Determine break tendency
            var breakTendency = dist.nextUniform() / 2
            if dist.nextBool() {
                breakTendency += 0.5
            }
            
            // Add new Player to list of players
            if i < self.nr_bots {
                localPlayers.append(Bot(
                    id: i,
                    name: "B\(i+1)",
                    playerCount: localPlayerCount,
                    breakTendency: Double(breakTendency)
                ))
            } else {
                localPlayers.append(Human(
                    id: i,
                    name: "H\(i+1-nr_bots)"
                ))
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
        //print("N on cup: \(i)")
        return i
    }
    
    func updateScores() -> Void {
        if currentPlayer().prediction! == outputOnCup() {
            self.players[self.currentPlayerIdx].score += 1
        }
    }
    
    // Returns current player
    func currentPlayer() -> Player {
        return self.players[self.currentPlayerIdx]
    }
    
    // Goes to the next round
    func nextRound() {
        self.round += 1
        self.currentPlayerIdx += 1
        if self.currentPlayerIdx == self.playerCount {
            self.currentPlayerIdx = 0
        }
    }
    
    func getHumanPlayers() -> [Player] {
        var humanPlayers: [Player] = []
        for player in players {
            if player.playerType == .Human {
                humanPlayers.append(player)
            }
        }
        return humanPlayers
    }
    
    func getBotPlayers() -> [Player] {
        var botPlayers: [Player] = []
        for player in players {
            if player.playerType == .Bot {
                botPlayers.append(player)
            }
        }
        return botPlayers
    }
}
