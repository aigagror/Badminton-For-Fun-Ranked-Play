//
//  SecondViewController.swift
//  Ranked Play
//
//  Created by Edward Huang on 2/8/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import UIKit
import MessageUI

class MatchesViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        // Watch for any changes to the context
        NotificationCenter.default.addObserver(self, selector: #selector(receivedContextChangedNotification), name: .NSManagedObjectContextDidSave, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: IBAction
    
    @IBAction func export(_ sender: Any) {
        if let mailVC = Exporter.getExportJournalMailComposerVC(delegate: self) {
            present(mailVC, animated: true)
        }
    }
    
    @IBAction func newMatch(_ sender: Any) {
        let activePlayers = PlayerRecorder.getAllPlayers(active: true)
        let count = activePlayers.count
        if let (playerOne, playerTwo) = PlayerRecorder.generateMatch() {
            
            guard let navVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "new_match_nav") as? UINavigationController else {
                fatalError()
            }
            guard let newMatchVC = navVC.topViewController as? EditMatchViewController else {
                fatalError()
            }
            
            
            newMatchVC.playerOne = playerOne
            newMatchVC.playerTwo = playerTwo
            
            present(navVC, animated: true)
        } else {
            // Present alert
            let notEnoughAlert = UIAlertController(title: "Not Enough Active Players", message: nil, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                notEnoughAlert.dismiss(animated: true)
            })
            notEnoughAlert.addAction(okAction)
            
            present(notEnoughAlert, animated: true)
        }
    }
    
    // MARK: Private Functions
    @objc
    private func receivedContextChangedNotification() {
        tableView.reloadData()
    }
}


extension MatchesViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let match = MatchRecorder.getMatch(forIndex: row)
        guard let navVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "new_match_nav") as? UINavigationController else {
            fatalError()
        }
        
        guard let editMatchVC = navVC.topViewController as? EditMatchViewController else {
            fatalError()
        }
        
        editMatchVC.match = match
        editMatchVC.playerOne = PlayerRecorder.getPlayer(withID: match.playerOneID!)
        editMatchVC.playerTwo = PlayerRecorder.getPlayer(withID: match.playerTwoID!)
        present(navVC, animated: true)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            let matches = MatchRecorder.getAllMatches()
            return matches.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "match_cell") as? MatchTableViewCell else {
            fatalError()
        }
        
        let matches = MatchRecorder.getAllMatches()
        let row = indexPath.row
        let match = matches[row]
        
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        
        var playerOne: Player?
        var playerTwo: Player?
        
        if let idOne = match.playerOneID {
            playerOne = PlayerRecorder.getPlayer(withID: idOne)
        }
        if let idTwo = match.playerTwoID {
            playerTwo = PlayerRecorder.getPlayer(withID: idTwo)
        }
        
        guard let date = match.date else {
            fatalError()
        }
        
        // Date
        cell.date.text = df.string(from: date)
        
        // Name
        if match.anonymousOne {
            cell.nameOne.text = "Anonymous"
        } else {
            cell.nameOne.text = playerOne?.name
        }
        if match.anonymousTwo {
            cell.nameTwo.text = "Anonymous"
        } else {
            cell.nameTwo.text = playerTwo?.name
        }
        
        // Score
        if match.optOutOne || match.optOutTwo {
            cell.scoreOne.text = "-"
            cell.scoreTwo.text = "-"
        } else {
            cell.scoreOne.text = "\(match.scoreOne)"
            cell.scoreTwo.text = "\(match.scoreTwo)"
            
            if match.scoreOne > match.scoreTwo {
                cell.scoreOne.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            } else {
                cell.scoreOne.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            }
            if match.scoreTwo > match.scoreOne {
                cell.scoreTwo.textColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
            } else {
                cell.scoreTwo.textColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
            }
        }
        
        // Opt Out && Anonymous
        setNameLabelColor(label: cell.nameOne, optOut: match.optOutOne, anonymous: match.anonymousOne)
        setNameLabelColor(label: cell.nameTwo, optOut: match.optOutTwo, anonymous: match.anonymousTwo)
        
        // Finished or not
        cell.finishedLabel.isHidden = match.finished
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        tableView.beginUpdates()
        MatchRecorder.deleteMatch(atIndex: row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    fileprivate func setNameLabelColor(label: UILabel, optOut: Bool, anonymous: Bool) {
        switch (optOut, anonymous) {
        case (true, true):
            label.textColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        case (true, false):
            label.textColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        case (false, true):
            label.textColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        case (false, false):
            label.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        }
    }
}

extension MatchesViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

