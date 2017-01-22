//
//  SuggestDestinationViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 12/28/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit
import Contacts

class SuggestDestinationViewController: UIViewController, UITextFieldDelegate {
    //MARK: Outlets
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var wantToSuggestDestination: UISegmentedControl!
    @IBOutlet weak var suggestDestinationField: UITextField!
    @IBOutlet weak var wantToSuggestLabel: UILabel!
    @IBOutlet weak var decidedOnDestinationLabel: UILabel!
    @IBOutlet weak var decidedOnDestinationControl: UISegmentedControl!
    @IBOutlet weak var decidedOnDestinationTextField: UITextField!
    @IBOutlet weak var homeAirport: UITextField!
    
    var suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? String
    var suggestedDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggested_destination") as? String
    var decidedOnDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_control") as? String
    var decidedOnDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_value") as? String
    var homeAirportValue = DataContainerSingleton.sharedDataContainer.homeAirport ?? ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        suggestDestinationField.isHidden = true
        wantToSuggestDestination.isHidden = true
        wantToSuggestLabel.isHidden = true
        suggestDestinationField.layer.borderWidth = 1
        suggestDestinationField.layer.cornerRadius = 5
        suggestDestinationField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        suggestDestinationField.layer.masksToBounds = true
        decidedOnDestinationTextField.isHidden = true
        decidedOnDestinationTextField.layer.borderWidth = 1
        decidedOnDestinationTextField.layer.cornerRadius = 5
        decidedOnDestinationTextField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        decidedOnDestinationTextField.layer.masksToBounds = true
        self.homeAirport.delegate = self
        homeAirport.layer.borderWidth = 1
        homeAirport.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        homeAirport.layer.masksToBounds = true
        homeAirport.layer.cornerRadius = 5
        let homeAirportLabelPlaceholder = homeAirport!.value(forKey: "placeholderLabel") as? UILabel
        homeAirportLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)


        let suggestDestinationLabelPlaceholder = suggestDestinationField!.value(forKey: "placeholderLabel") as? UILabel
        suggestDestinationLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        let decidedOnDestinationTextFieldPlaceholder = decidedOnDestinationTextField!.value(forKey: "placeholderLabel") as? UILabel
        decidedOnDestinationTextFieldPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        //Load the values from our shared data container singleton
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        //Install the value into the label.
        if tripNameValue != nil {
            self.tripNameLabel.text =  "\(tripNameValue!)"
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        self.homeAirport.text =  "\(homeAirportValue)"
        if homeAirport.text == "" {
            decidedOnDestinationControl.isHidden = true
            decidedOnDestinationLabel.isHidden = true
        } else {
            decidedOnDestinationControl.isHidden = false
            decidedOnDestinationLabel.isHidden = false
      
            if decidedOnDestinationControlValue == "Yes" {
                decidedOnDestinationControl.selectedSegmentIndex = 0
                decidedOnDestinationTextField.isHidden = false
                if decidedOnDestinationValue != nil {
                    self.decidedOnDestinationTextField.text = "\(decidedOnDestinationValue!)"
                }
            }
            else if decidedOnDestinationControlValue == "No" {
                decidedOnDestinationControl.selectedSegmentIndex = 1
                decidedOnDestinationTextField.isHidden = true
                wantToSuggestLabel.isHidden = false
                wantToSuggestDestination.isHidden = false
                
                if suggestDestinationControlValue == "Yes" {
                    wantToSuggestDestination.selectedSegmentIndex = 0
                    suggestDestinationField.isHidden = false
                    if suggestedDestinationValue != nil {
                        self.suggestDestinationField.text =  "\(suggestedDestinationValue!)"
                    }
                }
                else if suggestDestinationControlValue == "No" {
                    wantToSuggestDestination.selectedSegmentIndex = 1
                    suggestDestinationField.isHidden = true
                }
                
            }
        }
    }
    
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
        suggestDestinationField.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    // MARK: Actions
    @IBAction func homeAirportFieldEditingChanged(_ sender: Any) {
        DataContainerSingleton.sharedDataContainer.homeAirport = homeAirport.text
        if homeAirport.text == "" {
            decidedOnDestinationControl.isHidden = true
            decidedOnDestinationLabel.isHidden = true
        } else {
            decidedOnDestinationControl.isHidden = false
            decidedOnDestinationLabel.isHidden = false
            
            if decidedOnDestinationControlValue == "Yes" {
                decidedOnDestinationControl.selectedSegmentIndex = 0
                decidedOnDestinationTextField.isHidden = false
                if decidedOnDestinationValue != nil {
                    self.decidedOnDestinationTextField.text = "\(decidedOnDestinationValue!)"
                }
            }
            else if decidedOnDestinationControlValue == "No" {
                decidedOnDestinationControl.selectedSegmentIndex = 1
                decidedOnDestinationTextField.isHidden = true
                wantToSuggestLabel.isHidden = false
                wantToSuggestDestination.isHidden = false
                
                if suggestDestinationControlValue == "Yes" {
                    wantToSuggestDestination.selectedSegmentIndex = 0
                    suggestDestinationField.isHidden = false
                    if suggestedDestinationValue != nil {
                        self.suggestDestinationField.text =  "\(suggestedDestinationValue!)"
                    }
                }
                else if suggestDestinationControlValue == "No" {
                    wantToSuggestDestination.selectedSegmentIndex = 1
                    suggestDestinationField.isHidden = true
                }
                
            }
        }
    }
    
    @IBAction func decidedOnDestinationControlValueChanged(_ sender: Any) {
        if decidedOnDestinationControl.selectedSegmentIndex == 0 {
            decidedOnDestinationControlValue = "Yes"
            decidedOnDestinationTextField.isHidden = false
            wantToSuggestLabel.isHidden = true
            wantToSuggestDestination.isHidden = true
        }
        else {
            decidedOnDestinationControlValue = "No"
            decidedOnDestinationTextField.isHidden = true
            wantToSuggestLabel.isHidden = false
            wantToSuggestDestination.isHidden = false
        }
        
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        let multipleDestionationsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "multiple_destinations") as? String
        let travelingInternationalValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "traveling_international") as? String
        let selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [Date]
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
        var expectedRoundtripFare = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_roundtrip_fare") as? String
        var expectedNightlyRate = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_nightly_rate") as? String
        var suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? String
        var suggestedDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggested_destination") as? String
        var decidedOnDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_value") as? String

        
        let updatedTripToBeSaved = ["trip_name": tripNameValue, "multiple_destinations": multipleDestionationsValue, "traveling_international": travelingInternationalValue, "suggest_destination_control": suggestDestinationControlValue,"selected_dates": selectedDates, "contacts_in_group": contacts, "decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value": decidedOnDestinationValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate] as [String : Any]
        existing_trips?[currentTripIndex] = updatedTripToBeSaved as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips

    }
    @IBAction func decidedDestinationEditingChanged(_ sender: Any) {
        decidedOnDestinationValue = decidedOnDestinationTextField.text
        
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        let multipleDestionationsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "multiple_destinations") as? String
        let travelingInternationalValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "traveling_international") as? String
        let selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [Date]
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
        var expectedRoundtripFare = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_roundtrip_fare") as? String
        var expectedNightlyRate = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_nightly_rate") as? String
        var suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? String
        var suggestedDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_value") as? String
        var decidedOnDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_control") as? String
        
        let updatedTripToBeSaved = ["trip_name": tripNameValue, "multiple_destinations": multipleDestionationsValue, "traveling_international": travelingInternationalValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination": suggestedDestinationValue, "selected_dates": selectedDates, "contacts_in_group": contacts, "decided_destination_control": decidedOnDestinationControlValue, "decided_destination_value": decidedOnDestinationValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate] as [String : Any]
        existing_trips?[currentTripIndex] = updatedTripToBeSaved as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
        
    }

    @IBAction func suggestDestinationControlValueChanged(_ sender: Any) {
    if wantToSuggestDestination.selectedSegmentIndex == 0 {
            suggestDestinationControlValue = "Yes"
        }
        else {
            suggestDestinationControlValue = "No"
        }
        
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        let multipleDestionationsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "multiple_destinations") as? String
        let travelingInternationalValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "traveling_international") as? String
        let selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [Date]
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
        var expectedRoundtripFare = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_roundtrip_fare") as? String
        var expectedNightlyRate = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_nightly_rate") as? String
        var decidedOnDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_control") as? String
        var decidedOnDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_value") as? String

        let updatedTripToBeSaved = ["trip_name": tripNameValue, "multiple_destinations": multipleDestionationsValue, "traveling_international": travelingInternationalValue, "suggest_destination_control": suggestDestinationControlValue,"selected_dates": selectedDates, "contacts_in_group": contacts, "decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate] as [String : Any]
        existing_trips?[currentTripIndex] = updatedTripToBeSaved as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
    }

    @IBAction func wantToSuggestDestinationValueYes(_ sender: Any) {
        if wantToSuggestDestination.selectedSegmentIndex == 0 {
            suggestDestinationField.isHidden = false
        }
        else if wantToSuggestDestination.selectedSegmentIndex == 1 {
            suggestDestinationField.isHidden = true
        }
    }
    
    @IBAction func suggestedDestinationValueChanged(_ sender: Any) {
        suggestedDestinationValue = suggestDestinationField.text
        
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        let multipleDestionationsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "multiple_destinations") as? String
        let travelingInternationalValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "traveling_international") as? String
        let suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? String
        let selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [Date]
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
        var expectedRoundtripFare = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_roundtrip_fare") as? String
        var expectedNightlyRate = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_nightly_rate") as? String
        var decidedOnDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_control") as? String
        var decidedOnDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_value") as? String
        
        let updatedTripToBeSaved = ["trip_name": tripNameValue, "multiple_destinations": multipleDestionationsValue, "traveling_international": travelingInternationalValue, "suggest_destination_control": suggestDestinationControlValue, "suggested_destination": suggestedDestinationValue,"selected_dates": selectedDates, "contacts_in_group": contacts,  "decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate] as [String : Any]
        existing_trips?[currentTripIndex] = updatedTripToBeSaved as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
    }
}
