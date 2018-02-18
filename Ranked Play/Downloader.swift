//
//  Downloader.swift
//  Journal
//
//  Created by Edward Huang on 1/10/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import Foundation

class Downloader {
    class func load(URL: URL) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)
        var request = URLRequest(url: URL)
        request.httpMethod = "GET"
        let task = session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
            if (error == nil) {
                // Success
                let statusCode = (response as! HTTPURLResponse).statusCode
                print("Success: \(statusCode)")
                
                guard let data = data else {
                    fatalError("Data is nil")
                }
                
                // Get JSON object
                let JSON: [String: [[String: Any]]]
                do {
                    guard let json = try JSONSerialization.jsonObject(with: data) as? [String: [[String: Any]]] else {
                        fatalError("Could not parse JSON object")
                    }
                    
                    JSON = json
                } catch {
                    print(error)
                    fatalError("Could not parse JSON object")
                }
                
                // Wipe everything
                PersistentService.WIPE_EVERYTHING()
                
                let matchesJSON: [[String: Any]] = JSON["Matches"]!
                let playersJSON: [[String: Any]] = JSON["Player"]!
                
                for player in playersJSON {
                    
                    let firstName = player["firstName"] as? String
                    let lastName = player["lastName"] as? String
                    let nickname = player["nickname"] as? String
                    
                    // Necessary
                    let id = player["id"] as! String
                    let privateAccount = player["privateAcount"] as! Bool
                    
                    _ = PlayerRecorder.addPlayer(firstName: firstName, lastName: lastName, nickname: nickname, id: id, privateAccount: privateAccount)
                }
                
                for matchTuple in matchesJSON {
                    let df = DateFormatter.RFC3339DateFormatter
                    
                    let startDate = df.date(from: matchTuple["startDate"] as! String)
                    var endDate: Date?
                    if let endDateString = matchTuple["endDate"] as? String {
                        endDate = df.date(from: endDateString)
                    }
                    
                    let finished = matchTuple["finished"] as! Bool
                    
                    let playerOneID = matchTuple["playerOneID"] as! String
                    let playerTwoID = matchTuple["playerTwoID"] as! String
                    
                    // Optional
                    let playerThreeID = matchTuple["playerThreeID"] as? String
                    let playerFourID = matchTuple["playerFourID"] as? String
                    
                    let playerOne = PlayerRecorder.getPlayer(withID: playerOneID)
                    let playerTwo = PlayerRecorder.getPlayer(withID: playerTwoID)
                    var playerThree: Player?
                    if let p3ID = playerThreeID {
                        playerThree = PlayerRecorder.getPlayer(withID: p3ID)
                    }
                    var playerFour: Player?
                    if let p4ID = playerFourID {
                        playerFour = PlayerRecorder.getPlayer(withID: p4ID)
                    }
                    
                    let teamOneScore = matchTuple["teamOneScore"] as! Int
                    let teamTwoScore = matchTuple["teamTwoScore"] as! Int
                    
                    // Create the match
                    let match = MatchRecorder.createMatch(playerOne: playerOne, playerTwo: playerTwo, playerThree: playerThree, playerFour: playerFour)
                    MatchRecorder.editMatch(match: match, startDate: startDate, endDate: endDate, teamOneScore: teamOneScore, teamTwoScore: teamTwoScore, finished: finished)
                }
                PersistentService.saveContext()
            }
            else {
                // Failure
                print("Failure: %@", error?.localizedDescription ?? "");
            }
        })
        task.resume()
    }
}

