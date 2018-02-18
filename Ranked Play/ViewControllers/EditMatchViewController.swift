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
    
    @IBOutlet weak var startDate: UIDatePicker!
    @IBOutlet weak var endDate: UIDatePicker!
    @IBOutlet weak var endDateSwitch: UISwitch!
    
    @IBOutlet weak var optOutOne: UISwitch!
    @IBOutlet weak var optOutTwo: UISwitch!
    @IBOutlet weak var optOutThree: UISwitch!
    @IBOutlet weak var optOutFour: UISwitch!
    @IBOutlet weak var nameOne: UILabel!
    @IBOutlet weak var nameTwo: UILabel!
    @IBOutlet weak var nameThree: UILabel!
    @IBOutlet weak var nameFour: UILabel!
    @IBOutlet weak var idOne: UILabel!
    @IBOutlet weak var idTwo: UILabel!
    @IBOutlet weak var idThree: UILabel!
    @IBOutlet weak var idFour: UILabel!
    @IBOutlet weak var teamOneScore: UIPickerView!
    @IBOutlet weak var teamTwoScore: UIPickerView!
    @IBOutlet weak var stepScoreOne: UIStepper!
    @IBOutlet weak var stepScoreTwo: UIStepper!
    
    @IBOutlet weak var playerThreeContainer: UIStackView!
    @IBOutlet weak var playerFourContainer: UIStackView!
    
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let playerOne = PlayerRecorder.getPlayer(withID: match.playerOneID!)
        let playerTwo = PlayerRecorder.getPlayer(withID: match.playerTwoID!)
        
        if let playerThreeID = match.playerThreeID, let playerFourID = match.playerFourID {
            let playerThree = PlayerRecorder.getPlayer(withID: playerThreeID)
            let playerFour = PlayerRecorder.getPlayer(withID: playerFourID)
            playerThreeContainer.isHidden = false
            playerFourContainer.isHidden = false
            nameThree.text = playerThree.name
            nameFour.text = playerFour.name
            idThree.text = playerThree.id
            idFour.text = playerFour.id
            optOutThree.setOn(match.optOutThree, animated: false)
            optOutFour.setOn(match.optOutFour, animated: false)
        } else {
            playerThreeContainer.isHidden = true
            playerFourContainer.isHidden = true
        }
        
        let o1 = match.optOutOne
        let o2 = match.optOutTwo
        
        optOutOne.setOn(o1, animated: false)
        optOutTwo.setOn(o2, animated: false)
        
        nameOne.text = playerOne.name
        nameTwo.text = playerTwo.name
        idOne.text = playerOne.id
        idTwo.text = playerTwo.id
        let s1 = match.teamOneScore
        let s2 = match.teamTwoScore
        teamOneScore.selectRow(Int(s1), inComponent: 0, animated: false)
        teamTwoScore.selectRow(Int(s2), inComponent: 0, animated: false)
        
        // Date
        startDate.setDate(match.startDate!, animated: false)
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
            changePlayerVC.match = match
        }
    }
 
    
    // MARK: IBAction
    @IBAction func stepScoreOne(_ sender: UIStepper) {
        let score = Int(sender.value)
        teamOneScore.selectRow(score, inComponent: 0, animated: true)
    }
    
    @IBAction func stepScoreTwo(_ sender: UIStepper) {
        let score = Int(sender.value)
        teamTwoScore.selectRow(score, inComponent: 0, animated: true)
    }
    
    @IBAction func trash(_ sender: Any) {
        let confirmAlert = UIAlertController(title: "Are you sure you want to delete this match?", message: nil, preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            MatchRecorder.deleteMatch(self.match)
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in
            confirmAlert.dismiss(animated: true)
        }
        
        confirmAlert.addAction(cancelAction)
        confirmAlert.addAction(confirmAction)
        present(confirmAlert, animated: true)
    }
    
    
    @IBAction func save(_ sender: Any) {
        let s1 = teamOneScore.selectedRow(inComponent: 0)
        let s2 = teamTwoScore.selectedRow(inComponent: 0)
        
        let o1 = optOutOne.isOn
        let o2 = optOutTwo.isOn
        let o3 = optOutThree.isOn
        let o4 = optOutFour.isOn
        
        if o1 || o2 || o3 || o4 {
            MatchRecorder.editMatch(match: match, optOutOne: o1, optOutTwo: o2, optOutThree: o3, optOutFour: o4, finished: true)
            navigationController?.popViewController(animated: true)
            return
        }
        
        let finished = finishedScore(s1, s2)
        
        let sd = startDate.date
        var ed: Date? = nil
        if endDateSwitch.isOn {
            ed = endDate.date
        }
        
        if finished {
            if ed == nil {
                ed = Date()
            }
            MatchRecorder.editMatch(match: match, startDate: sd, endDate: ed, optOutOne: o1, optOutTwo: o2, optOutThree: o3, optOutFour: o4, teamOneScore: s1, teamTwoScore: s2, finished: finished)
            navigationController?.popViewController(animated: true)
            return
        } else {
            MatchRecorder.editMatch(match: match, startDate: sd, endDate: ed, optOutOne: o1, optOutTwo: o2, optOutThree: o3, optOutFour: o4, teamOneScore: s1, teamTwoScore: s2, finished: false)
            navigationController?.popViewController(animated: true)
            return
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        if newMatch {
            MatchRecorder.deleteMatch(match)
        }
        navigationController?.popViewController(animated: true)
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
