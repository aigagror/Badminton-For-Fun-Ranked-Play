//
//  EditPlayerViewController.swift
//  Ranked Play
//
//  Created by Edward Huang on 2/8/18.
//  Copyright © 2018 Eddie Huang. All rights reserved.
//

import UIKit

class EditPlayerViewController: UIViewController {

    // MARK: Properties
    var playerToEdit: Player!
    
    @IBOutlet weak var active: UISwitch!
    @IBOutlet weak var privateAccount: UISwitch!
    @IBOutlet weak var nickname: UITextField!
    @IBOutlet weak var firstName: UITextField!
    @IBOutlet weak var lastName: UITextField!
    @IBOutlet weak var id: UITextField!
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // Text Field Delegation
        nickname.delegate = self
        firstName.delegate = self
        lastName.delegate = self
        id.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        active.isOn = playerToEdit.active
        privateAccount.isOn = playerToEdit.privateAccount
        nickname.text = playerToEdit.nickname
        firstName.text = playerToEdit.firstName
        lastName.text = playerToEdit.lastName
        id.text = playerToEdit.id
    }
    
    // MARK: IBActions
    @IBAction func save(_ sender: Any) {
        if PlayerRecorder.editPlayer(player: playerToEdit, newID: id.text, active: active.isOn, privateAccount: privateAccount.isOn, nickname: nickname.text, firstName: firstName.text, lastName: lastName.text) {
            dismiss(animated: true)
        }
    }
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension EditPlayerViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
