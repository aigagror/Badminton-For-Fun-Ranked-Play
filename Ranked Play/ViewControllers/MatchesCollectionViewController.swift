//
//  MatchesCollectionViewController.swift
//  Ranked Play
//
//  Created by Edward Huang on 2/16/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import UIKit

private let reuseIdentifier = "match_cell"

class MatchesCollectionViewController: UICollectionViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(contextChanged), name: .NSManagedObjectContextDidSave, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    // MARK: - Navigation

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "edit_match" {
            return true
        }
        return PlayerRecorder.generateSinglesMatch() != nil
    }
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "new_match" {
            guard let editMatchVC = segue.destination as? EditMatchViewController else {
                fatalError()
            }
            
            guard let (playerOne, playerTwo) = PlayerRecorder.generateSinglesMatch() else {
                fatalError()
            }
            
            let match = MatchRecorder.createMatch(playerOne: playerOne, playerTwo: playerTwo)
            editMatchVC.match = match
            editMatchVC.newMatch = true
        } else if segue.identifier == "edit_match" {
            guard let editMatchVC = segue.destination as? EditMatchViewController else {
                fatalError()
            }
            guard let indexPath = collectionView?.indexPathsForSelectedItems?.first else {
                fatalError()
            }
            
            guard let cell = collectionView?.cellForItem(at: indexPath) as? MatchCollectionViewCell else {
                fatalError()
            }
            
            let match = cell.match
            editMatchVC.match = match
            editMatchVC.newMatch = false
        }
    }
    
    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return MatchRecorder.getNumberOfSections()
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let matches = MatchRecorder.getAllMatches(forSection: section)
        return matches.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MatchCollectionViewCell else {
            fatalError()
        }
        
    
        // Configure the cell
        let match = MatchRecorder.getMatch(forIndexPath: indexPath)
        cell.match = match
    
        
        guard let startDate = match.startDate else {
            fatalError()
        }
        
        let df = DateFormatter()
        df.dateStyle = .none
        df.timeStyle = .short
        
        cell.startDate.text = df.string(from: startDate)
        if let endDate = match.endDate {
            let duration = endDate.timeIntervalSince(startDate)
            cell.duration.text = duration.formatString()
        } else {
            cell.duration.text = "00:00"
        }
        cell.inProgressIndicator.isHidden = match.finished
        
        cell.teamOneScore.text = "\(match.teamOneScore)"
        cell.teamTwoScore.text = "\(match.teamTwoScore)"
        
        let playerOne = PlayerRecorder.getPlayer(withID: match.playerOneID!)
        let playerTwo = PlayerRecorder.getPlayer(withID: match.playerTwoID!)
        
        cell.playerOneName.text = playerOne.name
        cell.playerTwoName.text = playerTwo.name
        
        if let playerThreeID = match.playerThreeID, let playerFourID = match.playerFourID {
            cell.playerThreeName.isHidden = false
            cell.playerFourName.isHidden = false
            
            let playerThree = PlayerRecorder.getPlayer(withID: playerThreeID)
            let playerFour = PlayerRecorder.getPlayer(withID: playerFourID)
            
            cell.playerThreeName.text = playerThree.name
            cell.playerFourName.text = playerFour.name
        } else {
            cell.playerThreeName.isHidden = true
            cell.playerFourName.isHidden = true
        }
        
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
    
    
    // MARK: Private Functions
    @objc
    private func contextChanged() {
        collectionView?.reloadData()
    }
}
