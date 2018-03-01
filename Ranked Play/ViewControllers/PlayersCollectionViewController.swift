//
//  PlayerCollectionViewController.swift
//  Ranked Play
//
//  Created by Edward Huang on 2/18/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import UIKit
import MessageUI

private let reuseIdentifier = "player_cell"

class PlayersCollectionViewController: UICollectionViewController {
    
    var activateAll = true

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        
        // Watch for any changes to the context
        NotificationCenter.default.addObserver(self, selector: #selector(receivedContextChangedNotification), name: .NSManagedObjectContextDidSave, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
        if segue.identifier == "edit_player" {
            
            guard let indexPath = collectionView?.indexPathsForSelectedItems?.first else {
                fatalError()
            }
            guard let cell = collectionView?.cellForItem(at: indexPath) as? PlayerCollectionViewCell else {
                fatalError()
            }
            
            guard let editPlayerVC = segue.destination as? EditPlayerViewController else {
                fatalError()
            }
            editPlayerVC.player = cell.player
        }
    }
 
    
    // MARK: IBActions
    
    @IBAction func presentActions(_ sender: Any) {
        
        let actionSheet = UIAlertController(title: "Actions", message: nil, preferredStyle: .actionSheet)
        
        let mailAction = UIAlertAction(title: "Export", style: .default) { (action) in
            if let mailVC = Exporter.getExportJournalMailComposerVC(delegate: self) {
                self.present(mailVC, animated: true)
                actionSheet.dismiss(animated: true)
            }
        }
        
        let resetDataAction = UIAlertAction(title: "Load", style: .destructive) { (action) in
            // Load option
            let loadInitialActionController = UIAlertController(title: "Load the initial data?", message: "This will reset everything back to the data from February 10th?", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (action) in
                JSON.readJson()
                loadInitialActionController.dismiss(animated: true)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
                loadInitialActionController.dismiss(animated: true)
            }
            loadInitialActionController.addAction(cancelAction)
            loadInitialActionController.addAction(confirmAction)
            
            self.present(loadInitialActionController, animated: true)
            actionSheet.dismiss(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            actionSheet.dismiss(animated: true)
        }
        
        actionSheet.addAction(mailAction)
        actionSheet.addAction(resetDataAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true)
    }
    
    @IBAction func load(_ sender: Any) {
        let urlLoader = UIAlertController(title: "Enter the URL of JSON file", message: nil, preferredStyle: .alert)
        urlLoader.addTextField { (textfield) in
            textfield.returnKeyType = .done
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            urlLoader.dismiss(animated: true, completion: nil)
        }
        let submitAction = UIAlertAction(title: "Submit", style: .default) { (action) in
            if let text = urlLoader.textFields?.first?.text {
                if let url = URL(string: text) {
                    Downloader.load(URL: url)
                }
            }
            
            urlLoader.dismiss(animated: true, completion: nil)
        }
        
        urlLoader.addAction(cancelAction)
        urlLoader.addAction(submitAction)
        
        present(urlLoader, animated: true, completion: nil)
    }
    
    @IBAction func toggleActivityOfEveryone(_ sender: UIBarButtonItem) {
        if activateAll {
            PlayerRecorder.activateAll()
        } else {
            PlayerRecorder.deactivateAll()
        }
        activateAll = !activateAll
        
        if (activateAll) {
            sender.title = "Activate"
        } else {
            sender.title = "Deactivate"
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
        DispatchQueue.main.async {
            self.collectionView?.reloadData()
        }
    }
    
    
    // MARK: UICollectionViewDataSource
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "player_header", for: indexPath) as? PlayerHeaderCollectionReusableView else {
            fatalError()
        }
        
        if indexPath.section == 0 {
            headerView.activeLabel.text = "Active"
        } else {
            headerView.activeLabel.text = "Inactive"
        }
        
        return headerView
    }

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        let active = section == 0
        let players = PlayerRecorder.getAllPlayers(active: active)
        
        return players.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? PlayerCollectionViewCell else {
            fatalError()
        }
    
        // Configure the cell
        let player = PlayerRecorder.getPlayer(forIndexPath: indexPath)
        cell.player = player
        
        let wonMatches = MatchRecorder.getAllWonMatches(fromPlayer: player)
        let allMatches = MatchRecorder.getAllMatches(fromPlayer: player)
        
        cell.id.text = player.id
        cell.name.text = player.name
        cell.wins.text = "\(wonMatches.count)"
        cell.total.text = "\(allMatches.count)"
        cell.level.text = "\(player.level)"
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

extension PlayersCollectionViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
