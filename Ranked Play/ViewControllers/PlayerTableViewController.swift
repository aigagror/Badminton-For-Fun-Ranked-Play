//
//  FirstViewController.swift
//  Ranked Play
//
//  Created by Edward Huang on 2/8/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import UIKit
import MessageUI

class PlayerTableViewController: UIViewController {

    // MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Delegation and Data Source
        tableView.dataSource = self
        tableView.delegate = self
        
        // Watch for any changes to the context
        NotificationCenter.default.addObserver(self, selector: #selector(receivedContextChangedNotification), name: .NSManagedObjectContextDidSave, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "edit_player" {
            guard let indexPath = tableView.indexPathForSelectedRow else {
                fatalError()
            }
            guard let cell = tableView.cellForRow(at: indexPath) as? PlayerTableViewCell else {
                fatalError()
            }
            
            guard let editPlayerVC = segue.destination as? EditPlayerViewController else {
                fatalError()
            }
            editPlayerVC.playerToEdit = cell.player
        }
    }

    // MARK: IBAction
    @IBAction func deactivateAll(_ sender: Any) {
        PlayerRecorder.deactivateAll()
    }
    
    @IBAction func export(_ sender: Any) {
        if let mailVC = Exporter.getExportJournalMailComposerVC(delegate: self) {
            present(mailVC, animated: true)
        }
    }
    @IBAction func addPlayer(_ sender: Any) {
        let newPlayerAlertController = UIAlertController(title: "New Player", message: nil, preferredStyle: .alert)
        
        newPlayerAlertController.addTextField { (textField) in
            textField.placeholder = "ID (NetID Or Some Unique Name)"
            textField.returnKeyType = .next
        }
        newPlayerAlertController.addTextField { (textField) in
            textField.placeholder = "First Name"
            textField.autocapitalizationType = .words
            textField.returnKeyType = .next
        }
        newPlayerAlertController.addTextField { (textField) in
            textField.placeholder = "Last Name"
            textField.autocapitalizationType = .words
            textField.returnKeyType = .next
        }
        newPlayerAlertController.addTextField { (textField) in
            textField.placeholder = "Nickname (optional)"
            textField.autocapitalizationType = .words
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            newPlayerAlertController.dismiss(animated: true)
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (action) in
            guard let id = newPlayerAlertController.textFields?[0].text, id != "" else {
                // This cannot be empty
                return
            }
            let firstName = newPlayerAlertController.textFields?[1].text
            let lastName = newPlayerAlertController.textFields?[2].text
            let nickName = newPlayerAlertController.textFields?[3].text
            if PlayerRecorder.addPlayer(firstName: firstName, lastName: lastName, nickname: nickName, id: id, privateAccount: false) {
            }
        }
        
        newPlayerAlertController.addAction(cancelAction)
        newPlayerAlertController.addAction(addAction)
        
        present(newPlayerAlertController, animated: true)
    }
    
    // MARK: Private Functions
    @objc
    private func receivedContextChangedNotification() {
        tableView.reloadData()
    }
}

extension PlayerTableViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Delegate
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? PlayerTableViewCell else {
            fatalError()
        }
        
        let player = cell.player!
        tableView.beginUpdates()
        let matchesWithPlayer = MatchRecorder.getAllGames(fromPlayer: player)
        for match in matchesWithPlayer {
            MatchRecorder.deleteMatch(match)
        }
        PlayerRecorder.deletePlayer(player)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let oldActive = sourceIndexPath.section == 0
        let newActive = destinationIndexPath.section == 0

        let row = sourceIndexPath.row
        
        let player = PlayerRecorder.getPlayer(forIndex: row, active: oldActive)
        player.active = newActive
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    // MARK: Data Source
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let active = indexPath.section == 0
        let players = PlayerRecorder.getAllPlayers(active: active)
        let row = indexPath.row
        let player = players[row]
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "player_cell") as? PlayerTableViewCell else {
            fatalError()
        }
        
        cell.player = player
        
        cell.name.text = player.name
        cell.id.text = player.id
        if !player.privateAccount {
            let totalGames = MatchRecorder.getAllGames(fromPlayer: player)
            let wonGames = MatchRecorder.getAllWonMatches(fromPlayer: player)
            let fearedGames = MatchRecorder.getAllFearedMatches(fromPlayer: player)
            cell.total.text = "\(totalGames.count)"
            cell.wins.text = "\(wonGames.count)"
            cell.fears.text = "\(fearedGames.count)"
            cell.level.text = "\(player.level)"
        } else {
            cell.total.text = "-"
            cell.wins.text = "-"
            cell.fears.text = "-"
            cell.level.text = "-"
        }
        
        
        if player.active {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var players: [Player] = []
        if section == 0 {
            players = PlayerRecorder.getAllPlayers(active: true)
        } else if section == 1 {
            players = PlayerRecorder.getAllPlayers(active: false)
        }
        
        return players.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Active"
        } else if section == 1 {
            return "Inactive"
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
}

extension PlayerTableViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
