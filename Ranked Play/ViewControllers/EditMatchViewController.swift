//
//  NewMatchViewController.swift
//  Ranked Play
//
//  Created by Edward Huang on 2/9/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import UIKit

class EditMatchViewController: UIViewController {
    
    var newMatch: Bool!
    
    var match: Match!
    var startDate: Date!
    
    @IBOutlet weak var optOutOne: UISwitch!
    @IBOutlet weak var optOutTwo: UISwitch!
    @IBOutlet weak var nameOne: UILabel!
    @IBOutlet weak var nameTwo: UILabel!
    @IBOutlet weak var idOne: UILabel!
    @IBOutlet weak var idTwo: UILabel!
    @IBOutlet weak var teamOneScore: UIPickerView!
    @IBOutlet weak var teamTwoScore: UIPickerView!
    @IBOutlet weak var stepScoreOne: UIStepper!
    @IBOutlet weak var stepScoreTwo: UIStepper!
    
    fileprivate var showChoices = true
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Picker Data Source and Delegation
        teamOneScore.delegate = self
        teamTwoScore.delegate = self
        teamOneScore.dataSource = self
        teamTwoScore.dataSource = self
        
        // Record the start time of the match
        startDate = Date()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let playerOne = PlayerRecorder.getPlayer(withID: match.playerOneID!)
        let playerTwo = PlayerRecorder.getPlayer(withID: match.playerTwoID!)
        
        nameOne.text = playerOne.name
        nameTwo.text = playerTwo.name
        idOne.text = playerOne.id
        idTwo.text = playerTwo.id
        if let match = match {
            let s1 = match.teamOneScore
            let s2 = match.teamTwoScore
            teamOneScore.selectRow(Int(s1), inComponent: 0, animated: false)
            teamTwoScore.selectRow(Int(s2), inComponent: 0, animated: false)
        }
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let changePlayerVC = segue.destination as? ChangePlayerTableViewController {
            switch segue.identifier ?? "" {
            case "change_player_one":
                changePlayerVC.playerNumber = .one
            case "change_player_two":
                changePlayerVC.playerNumber = .two
            case "change_player_three":
                changePlayerVC.playerNumber = .three
            case "change_player_four":
                changePlayerVC.playerNumber = .four
            default:
                fatalError()
            }
        }
    }
 
    
    // MARK: IBAction
    @IBAction func unwindFromChangePlayerVC(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func toggleChoices(_ sender: Any) {
        showChoices = !showChoices
        
        if showChoices {
            optOutOne.isHidden = false
            optOutTwo.isHidden = false
        } else {
            optOutOne.isHidden = true
            optOutTwo.isHidden = true
        }
    }
    
    @IBAction func stepScoreOne(_ sender: UIStepper) {
        let score = Int(sender.value)
        teamOneScore.selectRow(score, inComponent: 0, animated: true)
    }
    
    @IBAction func stepScoreTwo(_ sender: UIStepper) {
        let score = Int(sender.value)
        teamTwoScore.selectRow(score, inComponent: 0, animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        let s1 = teamOneScore.selectedRow(inComponent: 0)
        let s2 = teamTwoScore.selectedRow(inComponent: 0)
        
        let o1 = optOutOne.isOn
        let o2 = optOutTwo.isOn
        
        if o1 || o2 {
            MatchRecorder.editMatch(match: match, optOutOne: o1, optOutTwo: o2, finished: true)
            dismiss(animated: true)
            return
        }
        
        let finished = finishedScore(s1, s2)
        if finished {
            let endDate = Date()
            MatchRecorder.editMatch(match: match, endDate: endDate, optOutOne: o1, optOutTwo: o2, teamOneScore: s1, teamTwoScore: s2, finished: finished)
            dismiss(animated: true)
            return
        } else {
            MatchRecorder.editMatch(match: match, optOutOne: o1, optOutTwo: o2, teamOneScore: s1, teamTwoScore: s2, finished: false)
            dismiss(animated: true)
            return
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        if newMatch {
            MatchRecorder.deleteMatch(match)
        }
        dismiss(animated: true)
    }
    
    // MARK: Private Functions
    fileprivate func finishedScore(_ s1: Int, _ s2: Int) -> Bool {
        return (s1 >= 21 || s2 >= 21) && (abs(s1 - s2) >= 2)
    }
}

extension EditMatchViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 100
        }
        return 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(row)"
        }
        return nil
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            if pickerView === teamOneScore {
                stepScoreOne.value = Double(row)
            } else {
                stepScoreTwo.value = Double(row)
            }
        }
    }
}
