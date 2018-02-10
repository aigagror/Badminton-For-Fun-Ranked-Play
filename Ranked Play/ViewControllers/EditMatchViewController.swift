//
//  NewMatchViewController.swift
//  Ranked Play
//
//  Created by Edward Huang on 2/9/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import UIKit

class EditMatchViewController: UIViewController {
    
    var match: Match?
    
    var playerOne: Player!
    var playerTwo: Player!
    
    @IBOutlet weak var optOutOne: UISwitch!
    @IBOutlet weak var optOutTwo: UISwitch!
    
    @IBOutlet weak var anonymousOne: UISwitch!
    @IBOutlet weak var anonymousTwo: UISwitch!
    
    @IBOutlet weak var nameOne: UILabel!
    @IBOutlet weak var nameTwo: UILabel!
    @IBOutlet weak var idOne: UILabel!
    @IBOutlet weak var idTwo: UILabel!
    @IBOutlet weak var scoreOne: UIPickerView!
    @IBOutlet weak var scoreTwo: UIPickerView!
    @IBOutlet weak var stepScoreOne: UIStepper!
    @IBOutlet weak var stepScoreTwo: UIStepper!
    
    fileprivate var showChoices = true
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Picker Data Source and Delegation
        scoreOne.delegate = self
        scoreTwo.delegate = self
        scoreOne.dataSource = self
        scoreTwo.dataSource = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        nameOne.text = playerOne.name
        nameTwo.text = playerTwo.name
        idOne.text = playerOne.id
        idTwo.text = playerTwo.id
        if let match = match {
            let s1 = match.scoreOne
            let s2 = match.scoreTwo
            scoreOne.selectRow(Int(s1), inComponent: 0, animated: false)
            scoreTwo.selectRow(Int(s2), inComponent: 0, animated: false)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: IBAction
    
    @IBAction func toggleChoices(_ sender: Any) {
        showChoices = !showChoices
        
        if showChoices {
            optOutOne.isHidden = false
            optOutTwo.isHidden = false
            anonymousOne.isHidden = false
            anonymousTwo.isHidden = false
        } else {
            optOutOne.isHidden = true
            optOutTwo.isHidden = true
            anonymousOne.isHidden = true
            anonymousTwo.isHidden = true
        }
    }
    
    @IBAction func stepScoreOne(_ sender: UIStepper) {
        let score = Int(sender.value)
        scoreOne.selectRow(score, inComponent: 0, animated: true)
    }
    
    @IBAction func stepScoreTwo(_ sender: UIStepper) {
        let score = Int(sender.value)
        scoreTwo.selectRow(score, inComponent: 0, animated: true)
    }
    
    @IBAction func save(_ sender: Any) {
        let s1 = scoreOne.selectedRow(inComponent: 0)
        let s2 = scoreTwo.selectedRow(inComponent: 0)
        
        let o1 = optOutOne.isOn
        let o2 = optOutTwo.isOn
        
        let a1 = anonymousOne.isOn
        let a2 = anonymousTwo.isOn
        
        guard let idOne = playerOne.id else {
            fatalError()
        }
        guard let idTwo = playerTwo.id else {
            fatalError()
        }
        
        if let match = match {
            MatchRecorder.editMatch(match: match, optOutOne: o1, optOutTwo: o2, anonymousOne: a1, anonymousTwo: a2, scoreOne: s1, scoreTwo: s2)
            dismiss(animated: true)
            return
        }
        
        if o1 || o2 {
            MatchRecorder.createMatch(playerOneID: idOne, playerTwoID: idTwo, optOutOne: o1, optOutTwo: o2, anonymousOne: a1, anonymousTwo: a2, scoreOne: s1, scoreTwo: s2)
            dismiss(animated: true)
        }
        
        if s1 >= 21 || s2 >= 21 {
            if abs(s1 - s2) >= 2 {
                MatchRecorder.createMatch(playerOneID: idOne, playerTwoID: idTwo, optOutOne: o1, optOutTwo: o2, anonymousOne: a1, anonymousTwo: a2, scoreOne: s1, scoreTwo: s2)
                dismiss(animated: true)
            }
        }
        
        
    }
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    // MARK: Private Functions
    
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
            if pickerView === scoreOne {
                stepScoreOne.value = Double(row)
            } else {
                stepScoreTwo.value = Double(row)
            }
        }
    }
}
