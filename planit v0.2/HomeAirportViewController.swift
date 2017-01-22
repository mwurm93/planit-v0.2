//
//  HomeAirportViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 12/28/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit

class HomeAiportViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var homeAirport: UITextField!
    @IBOutlet weak var tripNameLabel: UILabel!
    
    let timesOfDayArray = ["Early Morning","Late morning","Afternoon","Night","All"]

    override func viewDidLoad() {
        super.viewDidLoad()

        
        self.homeAirport.delegate = self
        homeAirport.layer.borderWidth = 1
        homeAirport.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        homeAirport.layer.masksToBounds = true
        homeAirport.layer.cornerRadius = 5
        let homeAirportLabelPlaceholder = homeAirport!.value(forKey: "placeholderLabel") as? UILabel
        homeAirportLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)

        
        //Load the values from our shared data container singleton
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        //Install the value into the label.
        if tripNameValue != nil {
            self.tripNameLabel.text =  "\(tripNameValue!)"
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        //Load the values from our shared data container singleton
        let homeAirportValue = DataContainerSingleton.sharedDataContainer.homeAirport ?? ""
        
        //Install the value into the text field.
        self.homeAirport.text =  "\(homeAirportValue)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
        homeAirport.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        DataContainerSingleton.sharedDataContainer.homeAirport = homeAirport.text
        return true
    }
}
