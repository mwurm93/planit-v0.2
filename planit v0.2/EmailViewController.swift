//
//  SignUpViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/10/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit

class EmailViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var emailAddress: UITextField!
    @IBOutlet weak var pleaseEnterEmail: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.emailAddress.delegate = self
        // apollo.fetch(query: GetTripQuery(id: "VHJpcDox")) { (result, error) in
        //    guard let data = result?.data else { return }
        //    self.emailAddress.text = data.getTrip?.name;
        // }
        
        nextButton.isHidden = true
        nextButton.isEnabled = false
        
        emailAddress.layer.borderWidth = 1
        emailAddress.layer.cornerRadius = 5
        emailAddress.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        emailAddress.layer.masksToBounds = true
        let emailAddressLabelPlaceholder = emailAddress!.value(forKey: "placeholderLabel") as? UILabel
        emailAddressLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
//        let clearButton = emailAddress?.value(forKey: "clearButton") as! UIButton
//        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
//        clearButton.tintColor = UIColor.white
//        clearButton.alpha = 1
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Load the values from our shared data container singleton
        let emailAddressValue = DataContainerSingleton.sharedDataContainer.emailAddress ?? ""
        
        //Install the value into the text field.
        self.emailAddress.text =  "\(emailAddressValue)"
        if (emailAddress.text?.contains("@"))! {
            nextButton.isHidden = false
            nextButton.isEnabled = true
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITextFieldDelegate for firstName
    
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
        emailAddress.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    @IBAction func EmailFieldEditingChanged(_ sender: Any) {
        
        if (emailAddress.text?.contains("@"))! {
            DataContainerSingleton.sharedDataContainer.emailAddress = emailAddress.text
        
            nextButton.isHidden = false
            nextButton.isEnabled = true
        }
        else if (emailAddress.text?.contains("@"))! == false {
                nextButton.isHidden = true
                nextButton.isEnabled = false
        }
    }
    
}
