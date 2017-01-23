//
//  SuggestDestinationViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 12/28/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit
import Contacts

class SuggestDestinationViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    //MARK: Outlets
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var wantToSuggestDestination: UISegmentedControl!
    @IBOutlet weak var suggestDestinationField: UITextField!
    @IBOutlet weak var wantToSuggestLabel: UILabel!
    @IBOutlet weak var decidedOnDestinationLabel: UILabel!
    @IBOutlet weak var decidedOnDestinationControl: UISegmentedControl!
    @IBOutlet weak var decidedOnDestinationTextField: UITextField!
    @IBOutlet weak var homeAirport: UITextField!
    @IBOutlet weak var contactsCollectionView: UICollectionView!
    
    var suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? String
    var suggestedDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggested_destination") as? String
    var decidedOnDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_control") as? String
    var decidedOnDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_value") as? String
    var homeAirportValue = DataContainerSingleton.sharedDataContainer.homeAirport ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        suggestDestinationField.alpha = 0
        wantToSuggestDestination.alpha = 0
        wantToSuggestLabel.alpha = 0
        suggestDestinationField.layer.borderWidth = 1
        suggestDestinationField.layer.cornerRadius = 5
        suggestDestinationField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        suggestDestinationField.layer.masksToBounds = true
        decidedOnDestinationTextField.alpha = 0
        decidedOnDestinationTextField.layer.borderWidth = 1
        decidedOnDestinationTextField.layer.cornerRadius = 5
        decidedOnDestinationTextField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        decidedOnDestinationTextField.layer.masksToBounds = true
        self.homeAirport.delegate = self
        homeAirport.layer.borderWidth = 1
        homeAirport.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        homeAirport.layer.masksToBounds = true
        homeAirport.layer.cornerRadius = 5
        homeAirport.text =  "\(homeAirportValue)"
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
        if homeAirport.text == "" {
            decidedOnDestinationControl.alpha = 0
            decidedOnDestinationLabel.alpha = 0
        } else {
            decidedOnDestinationControl.alpha = 1
            decidedOnDestinationLabel.alpha = 1
            
            if decidedOnDestinationControlValue == "Yes" {
                decidedOnDestinationControl.selectedSegmentIndex = 0
                decidedOnDestinationTextField.alpha = 1
                if decidedOnDestinationValue != nil {
                    self.decidedOnDestinationTextField.text = "\(decidedOnDestinationValue!)"
                }
            }
            else if decidedOnDestinationControlValue == "No" {
                decidedOnDestinationControl.selectedSegmentIndex = 1
                decidedOnDestinationTextField.alpha = 0
                wantToSuggestLabel.alpha = 1
                wantToSuggestDestination.alpha = 1
                
                if suggestDestinationControlValue == "Yes" {
                    wantToSuggestDestination.selectedSegmentIndex = 0
                    suggestDestinationField.alpha = 1
                    if suggestedDestinationValue != nil {
                        self.suggestDestinationField.text =  "\(suggestedDestinationValue!)"
                    }
                }
                else if suggestDestinationControlValue == "No" {
                    wantToSuggestDestination.selectedSegmentIndex = 1
                    suggestDestinationField.alpha = 0
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
    
    ///////////////////////////////////COLLECTION VIEW/////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
        if contacts != nil {
            return (contacts?.count)!
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let contactsCell = contactsCollectionView.dequeueReusableCell(withReuseIdentifier: "contactsCollectionPrototypeCell", for: indexPath) as! contactsCollectionViewCell
        
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
        
        let contact = contacts?[indexPath.row]
        
        if (contact?.imageDataAvailable)! {
            contactsCell.thumbnailImage.image = UIImage(data: (contact?.thumbnailImageData!)!)
            contactsCell.initialsLabel.isHidden = true
            contactsCell.thumbnailImageFilter.isHidden = false
            contactsCell.thumbnailImageFilter.image = UIImage(named: "no_contact_image")!
            contactsCell.thumbnailImageFilter.alpha = 0.35
        } else {
            contactsCell.thumbnailImage.image = UIImage(named: "no_contact_image")!
            contactsCell.thumbnailImageFilter.isHidden = true
            contactsCell.initialsLabel.isHidden = false
            let firstInitial = contact?.givenName[0]
            let secondInitial = contact?.familyName[0]
            contactsCell.initialsLabel.text = firstInitial! + secondInitial!
        }
        
        return contactsCell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if collectionView == contactsCollectionView {
            // Create date lists and color array
            let sampleAirport_1 = "JFK"
            let sampleAirport_2 = "SFO"
            let sampleAirport_3 = "ORF"
            let sampleAirport_4 = "BOS"
            let sampleAirport_5 = "DEN"
            let sampleAirport_6 = "MIA"
            let sampleAirport_7 = "MCO"
            let sampleAirports = [sampleAirport_1, sampleAirport_2,sampleAirport_3,sampleAirport_4,sampleAirport_5,sampleAirport_6,sampleAirport_7]
            
            let colors = [UIColor.purple, UIColor.gray, UIColor.red, UIColor.green, UIColor.orange, UIColor.yellow, UIColor.brown, UIColor.black]
            
            // Change color of thumbnail image
            let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
            let contact = contacts?[indexPath.row]
            let SelectedContact = contactsCollectionView.cellForItem(at: indexPath) as! contactsCollectionViewCell
            
            if (contact?.imageDataAvailable)! {
                SelectedContact.thumbnailImageFilter.alpha = 0
            } else {
                SelectedContact.thumbnailImage.image = UIImage(named: "no_contact_image_selected")!
                //                SelectedContact.initialsLabel.textColor = UIColor(red: 132/255, green: 137/255, blue: 147/255, alpha: 1)
                SelectedContact.initialsLabel.textColor = colors[indexPath.row]
            }
            
            homeAirport.text = sampleAirports[indexPath.row]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if collectionView == contactsCollectionView {
            // Create date lists and color array
            let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
            let contact = contacts?[indexPath.row]
            
            let DeSelectedContact = contactsCollectionView.cellForItem(at: indexPath) as! contactsCollectionViewCell
            
            if (contact?.imageDataAvailable)! {
                DeSelectedContact.thumbnailImageFilter.alpha = 0.35
            } else {
                DeSelectedContact.thumbnailImage.image = UIImage(named: "no_contact_image")!
                DeSelectedContact.initialsLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            }
            
            let homeAirportValue = DataContainerSingleton.sharedDataContainer.homeAirport ?? ""
            if homeAirportValue != nil {
                homeAirport.text = homeAirportValue
            } else {
                homeAirport.text = ""
            }
        }
    }
    
    // MARK: - UICollectionViewFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let picDimension = 55
        return CGSize(width: picDimension, height: picDimension)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
        
        let spacing = 10
        if contacts != nil {
            var leftRightInset = (self.contactsCollectionView.frame.size.width / 2.0) - CGFloat((contacts?.count)!) * 27.5 - CGFloat(spacing / 2 * ((contacts?.count)! - 1))
            if (contacts?.count)! > 4 {
                leftRightInset = 30
            }
            return UIEdgeInsetsMake(0, leftRightInset, 0, 0)
        }
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }

    
    // MARK: Actions
    @IBAction func homeAirportFieldEditingChanged(_ sender: Any) {
        DataContainerSingleton.sharedDataContainer.homeAirport = homeAirport.text
        
        if homeAirport.text == "" {
            decidedOnDestinationControl.alpha = 0
            decidedOnDestinationLabel.alpha = 0
            decidedOnDestinationTextField.alpha = 0
            suggestDestinationField.alpha = 0
            wantToSuggestDestination.alpha = 0
            wantToSuggestLabel.alpha = 0
        } else {
            UIView.animate(withDuration: 0.7) {
                self.decidedOnDestinationControl.alpha = 1
                self.decidedOnDestinationLabel.alpha = 1
            }
            
            if decidedOnDestinationControlValue == "Yes" {
                decidedOnDestinationControl.selectedSegmentIndex = 0
                UIView.animate(withDuration: 0.7) {
                    self.decidedOnDestinationTextField.alpha = 1
                }
                if decidedOnDestinationValue != nil {
                    self.decidedOnDestinationTextField.text = "\(decidedOnDestinationValue!)"
                }
            }
            else if decidedOnDestinationControlValue == "No" {
                decidedOnDestinationControl.selectedSegmentIndex = 1
                self.decidedOnDestinationTextField.alpha = 0
                UIView.animate(withDuration: 0.7) {
                    self.wantToSuggestLabel.alpha = 1
                    self.wantToSuggestDestination.alpha = 1
                }
                
                if suggestDestinationControlValue == "Yes" {
                    wantToSuggestDestination.selectedSegmentIndex = 0
                    UIView.animate(withDuration: 0.7) {
                        self.suggestDestinationField.alpha = 1
                    }
                    if suggestedDestinationValue != nil {
                        self.suggestDestinationField.text =  "\(suggestedDestinationValue!)"
                    }
                }
                else if suggestDestinationControlValue == "No" {
                    wantToSuggestDestination.selectedSegmentIndex = 1
                    self.suggestDestinationField.alpha = 0
                }
                
            }
        }
    }
    
    @IBAction func decidedOnDestinationControlValueChanged(_ sender: Any) {
        if decidedOnDestinationControl.selectedSegmentIndex == 0 {
            decidedOnDestinationControlValue = "Yes"
            self.wantToSuggestLabel.alpha = 0
            self.wantToSuggestDestination.alpha = 0
            self.suggestDestinationField.alpha = 0

            UIView.animate(withDuration: 0.7) {
                self.decidedOnDestinationTextField.alpha = 1
            }
        }
        else {
            decidedOnDestinationControlValue = "No"
            self.decidedOnDestinationTextField.alpha = 0
            UIView.animate(withDuration: 0.7) {
                self.wantToSuggestLabel.alpha = 1
                self.wantToSuggestDestination.alpha = 1
            }
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
        let leftDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "origin_departure_times") as? [NSDictionary]
        let rightDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "return_departure_times") as? [NSDictionary]
        
        
        let updatedTripToBeSaved = ["trip_name": tripNameValue, "multiple_destinations": multipleDestionationsValue, "traveling_international": travelingInternationalValue, "suggest_destination_control": suggestDestinationControlValue,"selected_dates": selectedDates, "contacts_in_group": contacts, "decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value": decidedOnDestinationValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays] as [String : Any]
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
        let leftDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "origin_departure_times") as? [NSDictionary]
        let rightDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "return_departure_times") as? [NSDictionary]
        
        let updatedTripToBeSaved = ["trip_name": tripNameValue, "multiple_destinations": multipleDestionationsValue, "traveling_international": travelingInternationalValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination": suggestedDestinationValue, "selected_dates": selectedDates, "contacts_in_group": contacts, "decided_destination_control": decidedOnDestinationControlValue, "decided_destination_value": decidedOnDestinationValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays] as [String : Any]
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
        let leftDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "origin_departure_times") as? [NSDictionary]
        let rightDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "return_departure_times") as? [NSDictionary]
        
        let updatedTripToBeSaved = ["trip_name": tripNameValue, "multiple_destinations": multipleDestionationsValue, "traveling_international": travelingInternationalValue, "suggest_destination_control": suggestDestinationControlValue,"selected_dates": selectedDates, "contacts_in_group": contacts, "decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays] as [String : Any]
        existing_trips?[currentTripIndex] = updatedTripToBeSaved as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
    }
    
    @IBAction func wantToSuggestDestinationValueYes(_ sender: Any) {
        if wantToSuggestDestination.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.7) {
                self.suggestDestinationField.alpha = 1
            }
        }
        else if wantToSuggestDestination.selectedSegmentIndex == 1 {
                self.suggestDestinationField.alpha = 0
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
        let leftDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "origin_departure_times") as? [NSDictionary]
        let rightDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "return_departure_times") as? [NSDictionary]
        
        let updatedTripToBeSaved = ["trip_name": tripNameValue, "multiple_destinations": multipleDestionationsValue, "traveling_international": travelingInternationalValue, "suggest_destination_control": suggestDestinationControlValue, "suggested_destination": suggestedDestinationValue,"selected_dates": selectedDates, "contacts_in_group": contacts,  "decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays] as [String : Any]
        existing_trips?[currentTripIndex] = updatedTripToBeSaved as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
    }
}
