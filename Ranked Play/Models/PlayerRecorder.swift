//
//  Player.swift
//  Ranked Play
//
//  Created by Edward Huang on 2/8/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import Foundation
import CoreData
import GameplayKit

class PlayerRecorder {
    
    static func generateMatch() -> (Player, Player)? {
        let activePlayers = getAllPlayers(active: true)
        
        let n = activePlayers.count
        
        if n < 2 {
            return nil
        }
        
        let randomIndex = Int(arc4random_uniform(UInt32(n)))
        var skewedRandomIndex: Int!
        
        // Find a pair that's usually close to p1.
        // Assume that active players are sorted by rank,
        // so we simply skew the chance closer to 'random'
        let randomSource = GKRandomSource()
        let distribution = GKGaussianDistribution(randomSource: randomSource, mean: Float(randomIndex), deviation: Float(n/3 == 0 ? 1 : n/3))
        
        repeat {
            skewedRandomIndex = distribution.nextInt()
        } while skewedRandomIndex < 0 || skewedRandomIndex >= n || skewedRandomIndex == randomIndex
        
        let p1 = activePlayers[randomIndex]
        let p2 = activePlayers[skewedRandomIndex]
        
        guard p1 !== p2 else {
            fatalError()
        }
        
        return (p1, p2)
    }
    
    /// Returns whether or not we have successfully added a player
    static func addPlayer(firstName: String? = nil, lastName: String? = nil, nickname: String? = nil, id: String, secret: Bool) -> Bool {
        // Check that no other player has the same id
        let exists = playerExists(withID: id)
        if exists {
            return false
        }
        
        let context = PersistentService.context
        
        let newPlayer = Player(context: context)
        newPlayer.firstName = firstName
        newPlayer.lastName = lastName
        newPlayer.nickname = nickname
        if nickname == "" {
            newPlayer.nickname = nil
        }
        newPlayer.id = id
        newPlayer.active = false
        newPlayer.secret = secret
        
        PersistentService.saveContext()
    
        return true
    }
    
    static func deletePlayer(withID id: String) {
        let context = PersistentService.context
        let fetchRequest = NSFetchRequest<Player>(entityName: Player.description())
        
        let activePredicate = NSPredicate(format: "id like '\(id)'")
        fetchRequest.predicate = activePredicate
        do {
            let searchResults = try context.fetch(fetchRequest)
            guard let playerToDelete = searchResults.first else {
                fatalError()
            }
            
            // Delete the player
            context.delete(playerToDelete)
            
            return
        } catch {
            print("Error: \(error)")
        }
        fatalError()
    }
    
    static func getPlayer(withID id: String) -> Player {
        let context = PersistentService.context
        
        let fetchRequest = NSFetchRequest<Player>(entityName: Player.description())
        
        let activePredicate = NSPredicate(format: "id like '\(id)'")
        fetchRequest.predicate = activePredicate
        do {
            let searchResults = try context.fetch(fetchRequest)
            guard let player = searchResults.first else {
                fatalError()
            }
            return player
        } catch {
            print("Error: \(error)")
        }
        fatalError()
    }
    
    static func editPlayer(originalID: String, newID: String? = nil, active: Bool? = nil, secret: Bool? = nil, nickname: String? = nil, firstName: String? = nil, lastName: String? = nil) -> Bool {
        if let newID = newID, newID != originalID {
            if playerExists(withID: newID) {
                return false
            }
        }
        
        let player = getPlayer(withID: originalID)
        if let newID = newID {
            player.id = newID
        }
        if let secret = secret {
            player.secret = secret
        }
        if let active = active {
            player.active = active
        }
        if let nickname = nickname {
            player.nickname = nickname
            if nickname == "" {
                player.nickname = nil
            }
        }
        if let firstName = firstName {
            player.firstName = firstName
        }
        if let lastName = lastName {
            player.lastName = lastName
        }
        
        PersistentService.saveContext()
        
        return true
    }
    
    static func playerExists(withID id: String) -> Bool {
        let context = PersistentService.context
        
        let fetchRequest = NSFetchRequest<Player>(entityName: Player.description())
        let IDPredicate = NSPredicate(format: "id like '\(id)'")
        fetchRequest.predicate = IDPredicate
        do {
            let searchResults = try context.fetch(fetchRequest)
            
            if searchResults.isEmpty {
                return false
            }
            return true
        } catch {
            print("Error: \(error)")
        }
        
        fatalError()
    }
    
    static func getAllPlayers(active: Bool? = nil) -> [Player] {
        let context = PersistentService.context
        
        let fetchRequest = NSFetchRequest<Player>(entityName: Player.description())
        
        if let active = active {
            let activePredicate = NSPredicate(format: "active == %@", argumentArray: [active])
            fetchRequest.predicate = activePredicate
        }
        
        let level = NSSortDescriptor(key: "level", ascending: false)
        let idSort = NSSortDescriptor(key: "id", ascending: true)
        
        fetchRequest.sortDescriptors = [level, idSort]
        
        do {
            let searchResults = try context.fetch(fetchRequest)
            
            return searchResults
        } catch {
            print("Error: \(error)")
        }
        fatalError()
    }
    
    static func deactivateAll() {
        let allPlayers = getAllPlayers()
        for player in allPlayers {
            player.active = false
        }
        
        PersistentService.saveContext()
    }
    
    static func getPlayer(forIndex i: Int, active: Bool? = nil) -> Player {
        let players = getAllPlayers(active: active)
        return players[i]
    }
}
