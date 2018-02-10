//
//  MatchRecorder.swift
//  Ranked Play
//
//  Created by Edward Huang on 2/9/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import Foundation
import CoreData

class MatchRecorder {
    static func getAllMatches() -> [Match] {
        let context = PersistentService.context
        
        let fetchRequest = NSFetchRequest<Match>(entityName: Match.description())
        
        let dateSort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        do {
            let searchResults = try context.fetch(fetchRequest)
            
            return searchResults
        } catch {
            print("Error: \(error)")
        }
        fatalError()
    }
    
    static func createMatch(playerOneID: String, playerTwoID: String, date: Date? = nil, optOutOne: Bool, optOutTwo: Bool, anonymousOne: Bool, anonymousTwo: Bool, scoreOne: Int, scoreTwo: Int) {
        let context = PersistentService.context
        let newMatch = Match(context: context)
        if let date = date {
            newMatch.date = date
        } else {
            newMatch.date = Date()
        }
        
        newMatch.playerOneID = playerOneID
        newMatch.playerTwoID = playerTwoID
        
        newMatch.anonymousOne = anonymousOne
        newMatch.anonymousTwo = anonymousTwo
        
        newMatch.optOutOne = optOutOne
        newMatch.optOutTwo = optOutTwo
        
        newMatch.scoreOne = Int16(scoreOne)
        newMatch.scoreTwo = Int16(scoreTwo)
        
        PersistentService.saveContext()
    }
    
    static func editMatch(match: Match, playerOneID: String? = nil, playerTwoID: String? = nil, date: Date? = nil, optOutOne: Bool? = nil, optOutTwo: Bool? = nil, anonymousOne: Bool? = nil, anonymousTwo: Bool? = nil, scoreOne: Int? = nil, scoreTwo: Int? = nil) {
        
        if let playerOneID = playerOneID {
            match.playerOneID = playerOneID
        }
        if let playerTwoID = playerTwoID {
            match.playerTwoID = playerTwoID
        }
        if let date = date {
            match.date = date
        }
        if let optOutOne = optOutOne {
            match.optOutOne = optOutOne
        }
        if let optOutTwo = optOutTwo {
            match.optOutTwo = optOutTwo
        }
        if let anonymousOne = anonymousOne {
            match.anonymousOne = anonymousOne
        }
        if let anonymousTwo = anonymousTwo {
            match.anonymousTwo = anonymousTwo
        }
        if let scoreOne = scoreOne {
            match.scoreOne = Int16(scoreOne)
        }
        if let scoreTwo = scoreTwo {
            match.scoreTwo = Int16(scoreTwo)
        }
        
        PersistentService.saveContext()
    }
    
    static func deleteMatch(atIndex i: Int) {
        let matches = getAllMatches()
        let match = matches[i]
        let context = PersistentService.context
        context.delete(match)
        PersistentService.saveContext()
    }
    
    static func getMatch(forIndex i: Int) -> Match {
        let matches = getAllMatches()
        return matches[i]
    }
    
    
    /// Finds all non-opted games (actually played games)
    ///
    /// - Parameter player: player involved
    /// - Returns: list of all non-opted games
    static func getAllGames(fromPlayer player: Player) -> [Match] {
        let context = PersistentService.context
        
        let fetchRequest = NSFetchRequest<Match>(entityName: Match.description())
        guard let playerID = player.id else {
            fatalError()
        }
        let playerPredicate = NSPredicate(format: "(playerOneID like %@ OR playerTwoID like %@) AND optOutOne == FALSE AND optOutTwo == FALSE", argumentArray: [playerID, playerID])
        fetchRequest.predicate = playerPredicate
        let dateSort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        do {
            let searchResults = try context.fetch(fetchRequest)
            
            return searchResults
        } catch {
            print("Error: \(error)")
        }
        fatalError()
    }
    
    static func getAllWonMatches(fromPlayer player: Player) -> [Match] {
        let context = PersistentService.context
        
        let fetchRequest = NSFetchRequest<Match>(entityName: Match.description())
        guard let playerID = player.id else {
            fatalError()
        }
        let wonPredicate = NSPredicate(format: "(playerOneID like %@ AND scoreOne > scoreTwo) OR (playerTwoID like %@ AND scoreTwo > scoreOne)", argumentArray: [playerID, playerID])
        fetchRequest.predicate = wonPredicate
        let dateSort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        do {
            let searchResults = try context.fetch(fetchRequest)
            
            return searchResults
        } catch {
            print("Error: \(error)")
        }
        fatalError()
    }
    
    static func getAllFearedMatches(fromPlayer player: Player) -> [Match] {
        let context = PersistentService.context
        
        let fetchRequest = NSFetchRequest<Match>(entityName: Match.description())
        guard let playerID = player.id else {
            fatalError()
        }
        let fearedPredicate = NSPredicate(format: "(playerOneID like %@ AND optOutOne == FALSE AND optOutTwo == TRUE) OR (playerTwoID like %@ AND optOutOne == TRUE AND optOutTwo == FALSE)", argumentArray: [playerID, playerID])
        fetchRequest.predicate = fearedPredicate
        let dateSort = NSSortDescriptor(key: "date", ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        do {
            let searchResults = try context.fetch(fetchRequest)
            
            return searchResults
        } catch {
            print("Error: \(error)")
        }
        fatalError()
    }
}
