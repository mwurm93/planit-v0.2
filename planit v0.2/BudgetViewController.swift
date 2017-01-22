//
//  BudgetViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/17/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit
import Contacts

class BudgetViewController: UIViewController, UITextFieldDelegate {

    // MARK: Outlets
    @IBOutlet weak var budget: UITextField!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var whatDoYouCareAboutMoreLabel: UILabel!
    @IBOutlet weak var CareAboutMoreSegmentControl: UISegmentedControl!
    @IBOutlet weak var nightsTextField: UITextField!
    @IBOutlet weak var splitByTextField: UITextField!
    @IBOutlet weak var hotelTotalLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var roundTripTicketField: UITextField!
    @IBOutlet weak var nightlyRatePerRoomField: UITextField!
    
    var budgetValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "budget") as? String
    let segmentLengthValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "Availability_segment_lengths") as? [Int]
    let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
    let hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? Float
    var expectedRoundtripFare = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_roundtrip_fare") as? String
    var expectedNightlyRate = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_nightly_rate") as? String


    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.budget.delegate = self
        
        // Set appearance of textfield
        budget.layer.cornerRadius = 5
        budget.layer.borderWidth = 1
        budget.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        budget.layer.masksToBounds = true
        nightsTextField.layer.cornerRadius = 5
        nightsTextField.layer.borderWidth = 1
        nightsTextField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        nightsTextField.layer.masksToBounds = true
        splitByTextField.layer.cornerRadius = 5
        splitByTextField.layer.borderWidth = 1
        splitByTextField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        splitByTextField.layer.masksToBounds = true
        roundTripTicketField.layer.cornerRadius = 5
        roundTripTicketField.layer.borderWidth = 1
        roundTripTicketField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        roundTripTicketField.layer.masksToBounds = true
        nightlyRatePerRoomField.layer.cornerRadius = 5
        nightlyRatePerRoomField.layer.borderWidth = 1
        nightlyRatePerRoomField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        nightlyRatePerRoomField.layer.masksToBounds = true


        whatDoYouCareAboutMoreLabel.isHidden = true
        CareAboutMoreSegmentControl.isHidden = true
        
        let budgetLabelPlaceholder = budget!.value(forKey: "placeholderLabel") as? UILabel
        budgetLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        if segmentLengthValue != nil {
            var maxSegmentLength = 0
            for segmentIndex in 0...(segmentLengthValue?.count)!-1 {
                if (segmentLengthValue?[segmentIndex])! > maxSegmentLength {
                    maxSegmentLength = (segmentLengthValue?[segmentIndex])!
                }
            }
            nightsTextField.text = "\(maxSegmentLength-1)"
        }
        if contacts != nil && hotelRoomsValue != nil {
            let peoplePerRoom = Float((contacts?.count)! + 1)/hotelRoomsValue!
            let roundedPeoplePerRoom = Int(roundf(peoplePerRoom))
            
            splitByTextField.text = "\(roundedPeoplePerRoom)"
        } else {
            splitByTextField.text = "2"
        }
        
        if expectedRoundtripFare != nil {
            roundTripTicketField.text = expectedRoundtripFare
        } else {
            roundTripTicketField.text = "400"
        }
        if expectedNightlyRate != nil {
            nightlyRatePerRoomField.text = expectedNightlyRate
        } else {
            nightlyRatePerRoomField.text = "200"
        }
        
        //Update totals
        var hotelTotalValue = 200
        var totalValue = 600
        if nightsTextField.text != "" && splitByTextField.text != "" && nightlyRatePerRoomField.text != "" && nightsTextField.text != nil && splitByTextField.text != nil && nightlyRatePerRoomField.text != nil {
            hotelTotalValue = Int(nightlyRatePerRoomField.text!)! * Int(nightsTextField.text!)! / Int(splitByTextField.text!)!
            if roundTripTicketField.text != "" && roundTripTicketField != nil {
                totalValue = Int(roundTripTicketField.text!)! + hotelTotalValue
            }
        }
        
        hotelTotalLabel.text = "$\(hotelTotalValue)"
        totalLabel.text = "$\(totalValue)"
        
        //Load the values from our shared data container singleton
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        //Install the value into the label.
        if tripNameValue != nil {
            self.tripNameLabel.text =  "\(tripNameValue!)"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Install the value into the label and unhide
        if budgetValue != nil {
        self.budget.text =  "\(budgetValue!)"
        }
//        if budgetValue == nil {
//        whatDoYouCareAboutMoreLabel.isHidden = false
//        CareAboutMoreSegmentControl.isHidden = false
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
    // Hide the keyboard.
    budget.resignFirstResponder()
    return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    return true
    }
    
    func saveBudget() {
        budgetValue = budget.text
        expectedNightlyRate = nightlyRatePerRoomField.text
        expectedRoundtripFare = roundTripTicketField.text
        
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        let multipleDestionationsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "multiple_destinations") as? String
        let travelingInternationalValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "traveling_international") as? String
        let suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? String
        let suggestedDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggested_destination") as? String
        let selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [Date]
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
        let hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? Float
        let segmentLengthValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "Availability_segment_lengths") as? [Int]
        
        let updatedTripToBeSaved = ["trip_name": tripNameValue, "multiple_destinations": multipleDestionationsValue, "traveling_international": travelingInternationalValue, "suggest_destination_control": suggestDestinationControlValue, "suggested_destination": suggestedDestinationValue, "budget": budgetValue, "selected_dates":selectedDates, "contacts_in_group":contacts, "hotel_rooms":hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate] as [String : Any]
        existing_trips?[currentTripIndex] = updatedTripToBeSaved as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
    }
    
// If budget field is changed, updated and save trip array
    @IBAction func budgetEditingChanged(_ sender: Any) {
        saveBudget()
//        if budgetValue != nil {
//            whatDoYouCareAboutMoreLabel.isHidden = false
//            CareAboutMoreSegmentControl.isHidden = false
//        }
//        if budgetValue == nil {
//            whatDoYouCareAboutMoreLabel.isHidden = true
//            CareAboutMoreSegmentControl.isHidden = true
//        }
    }
    @IBAction func nightsEditingChanged(_ sender: Any) {
        var hotelTotalValue = 200
        var totalValue = 600
        if nightsTextField.text != "" && splitByTextField.text != "" && nightlyRatePerRoomField.text != "" && nightsTextField.text != nil && splitByTextField.text != nil && nightlyRatePerRoomField.text != nil {
            hotelTotalValue = Int(nightlyRatePerRoomField.text!)! * Int(nightsTextField.text!)! / Int(splitByTextField.text!)!
            if roundTripTicketField.text != "" && roundTripTicketField != nil {
                totalValue = Int(roundTripTicketField.text!)! + hotelTotalValue
            }
        }
        hotelTotalLabel.text = "$\(hotelTotalValue)"
        totalLabel.text = "$\(totalValue)"
    }
    @IBAction func splitByEditingChanged(_ sender: Any) {
        
        var hotelTotalValue = 200
        var totalValue = 600
        if nightsTextField.text != "" && splitByTextField.text != "" && nightlyRatePerRoomField.text != "" && nightsTextField.text != nil && splitByTextField.text != nil && nightlyRatePerRoomField.text != nil {
            hotelTotalValue = Int(nightlyRatePerRoomField.text!)! * Int(nightsTextField.text!)! / Int(splitByTextField.text!)!
            if roundTripTicketField.text != "" && roundTripTicketField != nil {
                totalValue = Int(roundTripTicketField.text!)! + hotelTotalValue
            }
        }
        hotelTotalLabel.text = "$\(hotelTotalValue)"
        totalLabel.text = "$\(totalValue)"
    }
    @IBAction func useCalcButtonPressed(_ sender: Any) {
        budget.text = totalLabel.text
        saveBudget()
    }
    @IBAction func expectedRoundtripFareEditingChanged(_ sender: Any) {
        saveBudget()
    }
    @IBAction func expectedNightlyRateEditingChanged(_ sender: Any) {
        saveBudget()
    }
    
}
