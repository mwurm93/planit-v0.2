//
//  ViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/6/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit
import Apollo

class PasswordViewController: UIViewController, UITextFieldDelegate {

    // *** Add code to update whether existingUser = true
    var existingUser = false

    // MARK: Outlets
    @IBOutlet weak var Password: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var createPasswordLabel: UILabel!
    @IBOutlet weak var enterPasswordLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.Password.delegate = self
        
        Password.layer.borderWidth = 1
        Password.layer.cornerRadius = 5
        Password.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        Password.layer.masksToBounds = true
        let passwordLabelPlaceholder = Password!.value(forKey: "placeholderLabel") as? UILabel
        passwordLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)

        createAccountButton.isHidden = true
        createAccountButton.isEnabled = false
        loginButton.isHidden = true
        loginButton.isEnabled = false
        
        if existingUser == true {
            createPasswordLabel.isHidden = true
            enterPasswordLabel.isHidden = false
        }
        else {
            createPasswordLabel.isHidden = false
            enterPasswordLabel.isHidden = true
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate for firstName
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
        Password.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    @IBAction func passwordFieldEditingChanged(_ sender: Any) {
        if (Password.text?.characters.count)! >= 6 {
            DataContainerSingleton.sharedDataContainer.password = Password.text
            if existingUser == true {
                createAccountButton.isHidden = true
                createAccountButton.isEnabled = false
                loginButton.isHidden = false
                loginButton.isEnabled = true
            }
            else if existingUser == false {
                createAccountButton.isHidden = false
                createAccountButton.isEnabled = true
                loginButton.isHidden = true
                loginButton.isEnabled = false
            }
        }
        if (Password.text?.characters.count)! < 6 {
            createAccountButton.isHidden = true
            createAccountButton.isEnabled = false
            loginButton.isHidden = true
            loginButton.isEnabled = false
        }
    }
    // MARK: Actions
    @IBAction func createAccountButtonPressed(_ sender: Any) {
        DataContainerSingleton.sharedDataContainer.password = Password.text
        apollo.perform(mutation: CreateAUserMutation(newUser: CreateUserInput(username: DataContainerSingleton.sharedDataContainer.emailAddress!,password: DataContainerSingleton.sharedDataContainer.password!))) { (result, error) in
            }
    }
    
}
