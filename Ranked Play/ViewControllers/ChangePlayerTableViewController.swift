//
//  ChangePlayerTableViewController.swift
//  Ranked Play
//
//  Created by Edward Huang on 2/9/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import UIKit

class ChangePlayerTableViewController: UITableViewController {

    var playerNumber: PlayerNumber!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let player = PlayerRecorder.getAllPlayers(active: true)
        return player.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basic_player_cell", for: indexPath)

        // Configure the cell...
        let row = indexPath.row
        let allPlayers = PlayerRecorder.getAllPlayers(active: true)
        let player = allPlayers[row]
        
        cell.textLabel?.text = player.name
        cell.detailTextLabel?.text = player.id

        return cell
    }
 

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let editMatchVC = segue.destination as? EditMatchViewController {
            if let selectedRow = tableView.indexPathForSelectedRow?.row {
                let player = PlayerRecorder.getPlayer(forIndex: selectedRow, active: true)
                let playerID = player.id!
                let match = editMatchVC.match!
                switch playerNumber! {
                case .one:
                    MatchRecorder.editMatch(match: match, playerOneID: playerID)
                case .two:
                    MatchRecorder.editMatch(match: match, playerTwoID: playerID)
                case .three:
                    MatchRecorder.editMatch(match: match, playerThreeID: playerID)
                case .four:
                    MatchRecorder.editMatch(match: match, playerFourID: playerID)
                }
            }
        }
    }
 
    // MARK: IBActions
}
