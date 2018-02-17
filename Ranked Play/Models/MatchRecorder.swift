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
    
    static func getNumberOfSections() -> Int {
        let context = PersistentService.context
        
        let fetchRequest = NSFetchRequest<Match>(entityName: Match.description())
        
        let dateSort = NSSortDescriptor(key: "startDate", ascending: true)
        fetchRequest.sortDescriptors = [dateSort]
        fetchRequest.fetchLimit = 1
        do {
            let searchResults = try context.fetch(fetchRequest)
            
            if let first = searchResults.first {
                guard let oldestDate = first.startDate else {
                    fatalError()
                }
                let currentDate = Date()
                
                let duration = currentDate.timeIntervalSince(oldestDate)
                
                return Int((duration/Date.numberOfSecondsInADay).rounded(.up))
            }
            
            return 0
        } catch {
            print("Error: \(error)")
        }
        fatalError()
    }
    
    static func getAllMatches() -> [Match] {
        let context = PersistentService.context
        
        let fetchRequest = NSFetchRequest<Match>(entityName: Match.description())
        
        let dateSort = NSSortDescriptor(key: "startDate", ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        do {
            let searchResults = try context.fetch(fetchRequest)
            
            return searchResults
        } catch {
            print("Error: \(error)")
        }
        fatalError()
    }
    
    static func getAllMatches(forSection section: Int) -> [Match] {
        let (startDate, endDate) = computeStartAndEndDates(section: section)
        
        let context = PersistentService.context
        
        let fetchRequest = NSFetchRequest<Match>(entityName: Match.description())
        let datePredicate = NSPredicate(format: "startDate >= %@ AND startDate < %@", startDate as NSDate, endDate as NSDate)
        fetchRequest.predicate = datePredicate
        let dateSort = NSSortDescriptor(key: "startDate", ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        do {
            let matches = try context.fetch(fetchRequest)
            
            return matches
        } catch {
            print("Error: \(error)")
        }
        fatalError()
    }
    
    static func getMatch(forIndexPath indexPath: IndexPath) -> Match {
        let matches = getAllMatches(forSection: indexPath.section)
        return matches[indexPath.row]
    }
    
    static func createMatch(playerOne: Player, playerTwo: Player, playerThreeID: String? = nil, playerFourID: String? = nil) -> Match {
        let context = PersistentService.context
        let newMatch = Match(context: context)
        
        newMatch.startDate = Date()
        
        newMatch.playerOneID = playerOne.id!
        newMatch.playerTwoID = playerTwo.id!
        newMatch.playerThreeID = playerThreeID
        newMatch.playerFourID = playerFourID
        
        newMatch.optOutOne = false
        newMatch.optOutTwo = false
        newMatch.optOutThree = false
        newMatch.optOutFour = false
        newMatch.finished = false
        
        PersistentService.saveContext()
        
        return newMatch
    }
    
    static func finishMatch(match: Match, teamOneScore: Int, teamTwoScore: Int) -> Bool {
        if teamOneScore < 21 && teamTwoScore < 21 {
            return false
        }
        
        if abs(teamTwoScore - teamOneScore) < 2 {
            return false
        }
        match.teamOneScore = Int16(teamOneScore)
        match.teamTwoScore = Int16(teamTwoScore)
        PersistentService.saveContext()
        return true
    }
    
    static func isInAGame(player: Player) -> Bool {
        let context = PersistentService.context
        
        let fetchRequest = NSFetchRequest<Match>(entityName: Match.description())
        guard let playerID = player.id else {
            fatalError()
        }
        let playerPredicate = NSPredicate(format: "(playerOneID like %@ OR playerTwoID like %@) AND finished == FALSE", argumentArray: [playerID, playerID])
        fetchRequest.predicate = playerPredicate
        let dateSort = NSSortDescriptor(key: "startDate", ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        do {
            let searchResults = try context.fetch(fetchRequest)
            
            return !searchResults.isEmpty
        } catch {
            print("Error: \(error)")
        }
        fatalError()
    }
    
    static func editMatch(match: Match, playerOneID: String? = nil, playerTwoID: String? = nil, playerThreeID: String? = nil, playerFourID: String? = nil, startDate: Date? = nil, endDate: Date? = nil, optOutOne: Bool? = nil, optOutTwo: Bool? = nil, optOutThree: Bool? = nil, optOutFour: Bool? = nil, teamOneScore: Int? = nil, teamTwoScore: Int? = nil, finished: Bool? = nil) {
        
        if let playerOneID = playerOneID {
            match.playerOneID = playerOneID
        }
        if let playerTwoID = playerTwoID {
            match.playerTwoID = playerTwoID
        }
        if let playerThreeID = playerThreeID {
            match.playerThreeID = playerThreeID
        }
        if let playerFourID = playerFourID {
            match.playerFourID = playerFourID
        }
        if let startDate = startDate {
            match.startDate = startDate
        }
        if let endDate = endDate {
            match.endDate = endDate
        }
        if let optOutOne = optOutOne {
            match.optOutOne = optOutOne
        }
        if let optOutTwo = optOutTwo {
            match.optOutTwo = optOutTwo
        }
        if let optOutThree = optOutThree {
            match.optOutThree = optOutThree
        }
        if let optOutFour = optOutFour {
            match.optOutFour = optOutFour
        }
        if let teamOneScore = teamOneScore {
            match.teamOneScore = Int16(teamOneScore)
        }
        if let teamTwoScore = teamTwoScore {
            match.teamTwoScore = Int16(teamTwoScore)
        }
        if let finished = finished {
            match.finished = finished
        }
        
        PersistentService.saveContext()
    }
    
    static func deleteMatch(_ match: Match) {
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
        let playerPredicate = NSPredicate(format: "(playerOneID LIKE %@ OR playerTwoID LIKE %@ OR playerThreeID LIKE %@ OR playerFourID LIKE %@) AND optOutOne == FALSE AND optOutTwo == FALSE AND optOutThree == FALSE AND optOutFour == FALSE", argumentArray: [playerID, playerID, playerID, playerID])
        fetchRequest.predicate = playerPredicate
        let dateSort = NSSortDescriptor(key: "startDate", ascending: false)
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
        let wonPredicate = NSPredicate(format: "((playerOneID LIKE %@ OR playerThreeID LIKE %@) AND teamOneScore > teamTwoScore) OR ((playerTwoID LIKE %@ OR playerFourID LIKE %@) AND teamTwoScore > teamOneScore)", argumentArray: [playerID, playerID, playerID, playerID])
        fetchRequest.predicate = wonPredicate
        let dateSort = NSSortDescriptor(key: "startDate", ascending: false)
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
        // TODO: Fix
        let fearedPredicate = NSPredicate(format: "(playerOneID like %@ AND optOutOne == FALSE AND optOutTwo == TRUE) OR (playerTwoID like %@ AND optOutOne == TRUE AND optOutTwo == FALSE)", argumentArray: [playerID, playerID])
        fetchRequest.predicate = fearedPredicate
        let dateSort = NSSortDescriptor(key: "startDate", ascending: false)
        fetchRequest.sortDescriptors = [dateSort]
        do {
            let searchResults = try context.fetch(fetchRequest)
            
            return searchResults
        } catch {
            print("Error: \(error)")
        }
        fatalError()
    }
    
    // MARK: Private functions
    static private func computeStartAndEndDates(section: Int) -> (startDate: Date, endDate: Date) {
        let currentDate = Date()
        let offSetDate = currentDate.addingTimeInterval(-Date.numberOfSecondsInADay * TimeInterval(section))
        let dayAfterOffSetDate = offSetDate.addingTimeInterval(Date.numberOfSecondsInADay)
        
        let calendar = Calendar.current
        let startDate = calendar.startOfDay(for: offSetDate)
        let endDate = calendar.startOfDay(for: dayAfterOffSetDate)
        
        return (startDate, endDate)
    }
}
