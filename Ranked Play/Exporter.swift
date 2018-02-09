//
//  Exporter.swift
//  Journal
//
//  Created by Edward Huang on 1/13/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import Foundation
import MessageUI

class Exporter {
    static func getExportJournalMailComposerVC(delegate: MFMailComposeViewControllerDelegate) -> MFMailComposeViewController? {
        //Check to see the device can send email.
        if( MFMailComposeViewController.canSendMail() ) {
            print("Can send email.")
            
            let mailComposer = MFMailComposeViewController()
            mailComposer.mailComposeDelegate = delegate
            
            mailComposer.setToRecipients(["b4f.uiuc@gmail.com"])
            mailComposer.setSubject("Ranked Play Update")
            
            // Create JSON object
            var json = [String: [[String: Any]]]()
            
            let allPlayers = PlayerRecorder.getAllPlayers()
            var playersJSON = [[String : Any]]()
            for player in allPlayers {
                var playerTuple = [String : Any]()
                playerTuple["active"] = player.active
                playerTuple["id"] = player.id
                playerTuple["firstName"] = player.firstName
                playerTuple["lastName"] = player.lastName
                playerTuple["nickname"] = player.nickname
                playerTuple["secret"] = player.secret
                
                playersJSON.append(playerTuple)
            }
            json["Players"] = playersJSON
            
            let allMatches = MatchRecorder.getAllMatches()
            var matchesJSON = [[String : Any]]()
            for match in allMatches {
                var matchTuple = [String : Any]()
                matchTuple["anonymousOne"] = match.anonymousOne
                matchTuple["anonymouTwo"] = match.anonymousTwo
                let rfcDF = DateFormatter.RFC3339DateFormatter
                matchTuple["Date"] = rfcDF.string(from: match.date!)
                matchTuple["optOutOne"] = match.optOutOne
                matchTuple["optOutTwo"] = match.optOutTwo
                matchTuple["playerOneID"] = match.playerOneID
                matchTuple["playerTwoID"] = match.playerTwoID
                matchTuple["scoreOne"] = match.scoreOne
                matchTuple["scoreTwo"] = match.scoreTwo
                
                matchesJSON.append(matchTuple)
            }
            json["Matches"] = matchesJSON
            
            guard JSONSerialization.isValidJSONObject(json) else {
                fatalError("Invalid JSON object")
            }
            
            let jsonData: Data
            do {
                jsonData = try JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)
            } catch {
                print(error)
                fatalError("Could not serialize json")
            }
            
            
            mailComposer.addAttachmentData(jsonData, mimeType: "text/plain", fileName: "journalJSON")
            
            return mailComposer
        }
        return nil
    }
}
