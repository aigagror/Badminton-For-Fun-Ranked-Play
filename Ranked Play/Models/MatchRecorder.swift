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
        // TODO: Implement
    }
    
    static func deleteMatch(atIndex i: Int) {
        let matches = getAllMatches()
        let match = matches[i]
        let context = PersistentService.context
        context.delete(match)
        PersistentService.saveContext()
    }
    
    static func getAllMatches(fromPlayer player: Player) -> [Match] {
        return []
    }
    
    static func getAllWonMatches(fromPlayer player: Player) -> [Match] {
        return []
    }
    
    static func getAllFearedMatches(fromPlayer player: Player) -> [Match] {
        return []
    }
}
