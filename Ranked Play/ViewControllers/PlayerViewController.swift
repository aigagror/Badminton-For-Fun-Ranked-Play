//
//  FirstViewController.swift
//  Ranked Play
//
//  Created by Edward Huang on 2/8/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import UIKit

class PlayerViewController: UIViewController {

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

    // MARK: IBAction
    
    @IBAction func addPlayer(_ sender: Any) {
        let newPlayerAlertController = UIAlertController(title: "New Player", message: nil, preferredStyle: .alert)
        
        newPlayerAlertController.addTextField { (textField) in
            textField.placeholder = "ID (NetID Or Some Unique Name)"
        }
        newPlayerAlertController.addTextField { (textField) in
            textField.placeholder = "First Name"
            textField.autocapitalizationType = .words
        }
        newPlayerAlertController.addTextField { (textField) in
            textField.placeholder = "Last Name"
            textField.autocapitalizationType = .words
        }
        newPlayerAlertController.addTextField { (textField) in
            textField.placeholder = "Nickname"
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
            if PlayerRecorder.addPlayer(firstName: firstName, lastName: lastName, nickname: nickName, id: id, secret: false) {
                newPlayerAlertController.dismiss(animated: true)
                guard let editPlayerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "edit_player") as? EditPlayerViewController else {
                    fatalError()
                }
                editPlayerVC.originalID = id
                self.present(editPlayerVC, animated: true)
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

extension PlayerViewController: UITableViewDelegate, UITableViewDataSource {
    
    // MARK: Delegate
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? PlayerTableViewCell else {
            fatalError()
        }
        
        guard let id = cell.id.text else {
            fatalError()
        }
        tableView.beginUpdates()
        PlayerRecorder.deletePlayer(withID: id)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? PlayerTableViewCell else {
            fatalError()
        }
        
        let id = cell.id.text
        
        guard let editPlayerVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "edit_player") as? EditPlayerViewController else {
            fatalError()
        }
        editPlayerVC.originalID = id
        present(editPlayerVC, animated: true)
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
        
        cell.name.text = player.name
        cell.id.text = player.id
        if !player.secret {
            cell.total.text = "\(player.totalGames)"
            cell.wins.text = "\(player.wins)"
            cell.fears.text = "\(player.feared)"
        } else {
            cell.total.text = "-"
            cell.wins.text = "-"
            cell.fears.text = "-"
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

