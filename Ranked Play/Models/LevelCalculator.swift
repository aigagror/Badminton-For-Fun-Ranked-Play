//
//  LevelCalculator.swift
//  Ranked Play
//
//  Created by Edward Huang on 2/10/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import Foundation

class LevelCalculator {
    
    static let maxGain: Int32 = 12
    static let maxLoss: Int32 = 8
    
    static func updateLevels(playerOne p1: Player, playerTwo p2: Player, playerOneWon: Bool) {
        if playerOneWon {
            p1.level += maxGain
            p2.level = (p2.level - maxLoss) < 0 ? 0 : (p2.level - maxLoss)
        } else {
            p2.level += maxGain
            p1.level = (p1.level - maxLoss) < 0 ? 0 : (p1.level - maxLoss)
        }
        PersistentService.saveContext()
    }
}
