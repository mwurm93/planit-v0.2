//
//  SettingsViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/14/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UITextFieldDelegate {

    // MARK: Outlets
    @IBOutlet weak var nameHeaderForSettings: UILabel!
    @IBOutlet weak var emailAddressSettingsField: UITextField!
    @IBOutlet weak var passwordSettingsField: UITextField!
    @IBOutlet weak var firstNameSettingsField: UITextField!
    @IBOutlet weak var lastNameSettingsField: UITextField!
    @IBOutlet weak var genderSettingsField: UITextField!
    @IBOutlet weak var phoneSettingsField: UITextField!
    @IBOutlet weak var homeAirportSettingsField: UITextField!
    @IBOutlet weak var passportNumberSettingsField: UITextField!
    @IBOutlet weak var knownTravelerNumberSettingsField: UITextField!
    @IBOutlet weak var redressNumberSettingsField: UITextField!
    @IBOutlet weak var birthdateSettingsField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailAddressSettingsField.delegate = self
        self.passwordSettingsField.delegate = self
        self.firstNameSettingsField.delegate = self
        self.lastNameSettingsField.delegate = self
        self.genderSettingsField.delegate = self
        self.phoneSettingsField.delegate = self
        self.homeAirportSettingsField.delegate = self
        self.passportNumberSettingsField.delegate = self
        self.knownTravelerNumberSettingsField.delegate = self
        self.redressNumberSettingsField.delegate = self
        self.birthdateSettingsField.delegate = self
    
        // Set appearance of textfield
        firstNameSettingsField.layer.borderWidth = 1
        firstNameSettingsField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        firstNameSettingsField.layer.masksToBounds = true
        firstNameSettingsField.layer.cornerRadius = 5
        let firstNameSettingsFieldLabelPlaceholder = firstNameSettingsField!.value(forKey: "placeholderLabel") as? UILabel
        firstNameSettingsFieldLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        lastNameSettingsField.layer.borderWidth = 1
        lastNameSettingsField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        lastNameSettingsField.layer.masksToBounds = true
        lastNameSettingsField.layer.cornerRadius = 5
        let lastNameLabelPlaceholder = lastNameSettingsField!.value(forKey: "placeholderLabel") as? UILabel
        lastNameLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        emailAddressSettingsField.layer.borderWidth = 1
        emailAddressSettingsField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        emailAddressSettingsField.layer.masksToBounds = true
        emailAddressSettingsField.layer.cornerRadius = 5
        let emailAddressLabelPlaceholder = emailAddressSettingsField!.value(forKey: "placeholderLabel") as? UILabel
        emailAddressLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)

        passwordSettingsField.layer.borderWidth = 1
        passwordSettingsField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        passwordSettingsField.layer.masksToBounds = true
        passwordSettingsField.layer.cornerRadius = 5
        let passwordSettingsFieldLabelPlaceholder = passwordSettingsField!.value(forKey: "placeholderLabel") as? UILabel
        passwordSettingsFieldLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        genderSettingsField.layer.borderWidth = 1
        genderSettingsField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        genderSettingsField.layer.masksToBounds = true
        genderSettingsField.layer.cornerRadius = 5
        let genderSettingsFieldLabelPlaceholder = genderSettingsField!.value(forKey: "placeholderLabel") as? UILabel
        genderSettingsFieldLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        phoneSettingsField.layer.borderWidth = 1
        phoneSettingsField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        phoneSettingsField.layer.masksToBounds = true
        phoneSettingsField.layer.cornerRadius = 5
        let phoneSettingsFieldLabelPlaceholder = phoneSettingsField!.value(forKey: "placeholderLabel") as? UILabel
        phoneSettingsFieldLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        homeAirportSettingsField.layer.borderWidth = 1
        homeAirportSettingsField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        homeAirportSettingsField.layer.masksToBounds = true
        homeAirportSettingsField.layer.cornerRadius = 5
        let homeAirportSettingsFieldLabelPlaceholder = homeAirportSettingsField!.value(forKey: "placeholderLabel") as? UILabel
        homeAirportSettingsFieldLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        passportNumberSettingsField.layer.borderWidth = 1
        passportNumberSettingsField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        passportNumberSettingsField.layer.masksToBounds = true
        passportNumberSettingsField.layer.cornerRadius = 5
        let passportNumberSettingsFieldLabelPlaceholder = passportNumberSettingsField!.value(forKey: "placeholderLabel") as? UILabel
        passportNumberSettingsFieldLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        knownTravelerNumberSettingsField.layer.borderWidth = 1
        knownTravelerNumberSettingsField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        knownTravelerNumberSettingsField.layer.masksToBounds = true
        knownTravelerNumberSettingsField.layer.cornerRadius = 5
        let knownTravelerNumberSettingsFieldLabelPlaceholder = knownTravelerNumberSettingsField!.value(forKey: "placeholderLabel") as? UILabel
        knownTravelerNumberSettingsFieldLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        redressNumberSettingsField.layer.borderWidth = 1
        redressNumberSettingsField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        redressNumberSettingsField.layer.masksToBounds = true
        redressNumberSettingsField.layer.cornerRadius = 5
        let redressNumberSettingsFieldLabelPlaceholder = redressNumberSettingsField!.value(forKey: "placeholderLabel") as? UILabel
        redressNumberSettingsFieldLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        birthdateSettingsField.layer.borderWidth = 1
        birthdateSettingsField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        birthdateSettingsField.layer.masksToBounds = true
        birthdateSettingsField.layer.cornerRadius = 5
        let birthdateSettingsFieldLabelPlaceholder = birthdateSettingsField!.value(forKey: "placeholderLabel") as? UILabel
        birthdateSettingsFieldLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        //Load the values from our shared data container singleton
        let firstNameValue = DataContainerSingleton.sharedDataContainer.firstName ?? ""
        let lastNameValue = DataContainerSingleton.sharedDataContainer.lastName ?? ""
        let emailAddressValue = DataContainerSingleton.sharedDataContainer.emailAddress ?? ""
        let passwordValue = DataContainerSingleton.sharedDataContainer.password ?? ""
        let genderValue = DataContainerSingleton.sharedDataContainer.gender ?? ""
        let phoneValue = DataContainerSingleton.sharedDataContainer.phone ?? ""
        let homeAirportValue = DataContainerSingleton.sharedDataContainer.homeAirport ?? ""
        let passportNumberValue = DataContainerSingleton.sharedDataContainer.passportNumber ?? ""
        let knownTravelerNumberValue = DataContainerSingleton.sharedDataContainer.knownTravelerNumber ?? ""
        let redressNumberValue = DataContainerSingleton.sharedDataContainer.redressNumber ?? ""
        let birthdateValue = DataContainerSingleton.sharedDataContainer.birthdate ?? ""
        
        //Install the value into the text field.
        
        if firstNameValue == "" {
            self.nameHeaderForSettings.text =  "Profile"
        }
        else {
        self.nameHeaderForSettings.text =  "\(firstNameValue)'s Profile"
        }
        self.firstNameSettingsField.text =  "\(firstNameValue)"

        self.lastNameSettingsField.text =  "\(lastNameValue)"
        self.emailAddressSettingsField.text =  "\(emailAddressValue)"
        self.passwordSettingsField.text =  "\(passwordValue)"
        self.genderSettingsField.text =  "\(genderValue)"
        self.phoneSettingsField.text =  "\(phoneValue)"
        self.homeAirportSettingsField.text =  "\(homeAirportValue)"
        self.passportNumberSettingsField.text =  "\(passportNumberValue)"
        self.knownTravelerNumberSettingsField.text =  "\(knownTravelerNumberValue)"
        self.redressNumberSettingsField.text =  "\(redressNumberValue)"
        self.birthdateSettingsField.text =  "\(birthdateValue)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
        firstNameSettingsField.resignFirstResponder()
        lastNameSettingsField.resignFirstResponder()
        emailAddressSettingsField.resignFirstResponder()
        passwordSettingsField.resignFirstResponder()
        genderSettingsField.resignFirstResponder()
        phoneSettingsField.resignFirstResponder()
        homeAirportSettingsField.resignFirstResponder()
        passportNumberSettingsField.resignFirstResponder()
        knownTravelerNumberSettingsField.resignFirstResponder()
        redressNumberSettingsField.resignFirstResponder()
        birthdateSettingsField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        DataContainerSingleton.sharedDataContainer.firstName = firstNameSettingsField.text
        DataContainerSingleton.sharedDataContainer.lastName = lastNameSettingsField.text
        DataContainerSingleton.sharedDataContainer.emailAddress = emailAddressSettingsField.text
        DataContainerSingleton.sharedDataContainer.password = passwordSettingsField.text
        DataContainerSingleton.sharedDataContainer.gender = genderSettingsField.text
        DataContainerSingleton.sharedDataContainer.phone = phoneSettingsField.text
        DataContainerSingleton.sharedDataContainer.homeAirport = homeAirportSettingsField.text
        DataContainerSingleton.sharedDataContainer.passportNumber = passportNumberSettingsField.text
        DataContainerSingleton.sharedDataContainer.knownTravelerNumber = knownTravelerNumberSettingsField.text
        DataContainerSingleton.sharedDataContainer.redressNumber = redressNumberSettingsField.text
        DataContainerSingleton.sharedDataContainer.birthdate = birthdateSettingsField.text
        return true
    }

}
