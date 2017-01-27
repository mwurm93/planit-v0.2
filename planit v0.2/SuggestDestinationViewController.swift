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
    
    // Set up vars for Contacts - COPY
    var contacts: [CNContact]?
    var contactIDs: [NSString]?
    fileprivate var addressBookStore: CNContactStore!
    
    var homeAirportValue = DataContainerSingleton.sharedDataContainer.homeAirport ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()

        // Initialize address book - COPY
        addressBookStore = CNContactStore()
        
        //Set up appearance of VC
        suggestDestinationField.alpha = 0
        wantToSuggestDestination.alpha = 0
        wantToSuggestLabel.alpha = 0
        self.suggestDestinationField.delegate = self
        suggestDestinationField.layer.borderWidth = 1
        suggestDestinationField.layer.cornerRadius = 5
        suggestDestinationField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        suggestDestinationField.layer.masksToBounds = true
        self.decidedOnDestinationTextField.delegate = self
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
        
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let tripNameValue = SavedPreferencesForTrip["trip_name"] as! NSString
        let decidedOnDestinationControlValue = SavedPreferencesForTrip["decided_destination_control"] as! NSString
        let decidedOnDestinationValue = SavedPreferencesForTrip["decided_destination_value"] as! NSString
        let suggestDestinationControlValue = SavedPreferencesForTrip["suggest_destination_control"] as! NSString
        let suggestedDestinationValue = SavedPreferencesForTrip["suggested_destination"] as! NSString

        //Load the values from our shared data container singleton
        //Install the value into the label.
        if tripNameValue != "" {
            self.tripNameLabel.text =  "\(tripNameValue)"
        }
        if homeAirport.text == "" {
            decidedOnDestinationControl.alpha = 0
            decidedOnDestinationLabel.alpha = 0
        } else {
            decidedOnDestinationControl.alpha = 1
            decidedOnDestinationLabel.alpha = 1
            
            if decidedOnDestinationControlValue == "Yes" {
                decidedOnDestinationControl.selectedSegmentIndex = 0
                decidedOnDestinationTextField.alpha = 1
                if decidedOnDestinationValue != "" {
                    self.decidedOnDestinationTextField.text = "\(decidedOnDestinationValue)"
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
                    if suggestedDestinationValue != "" {
                        self.suggestDestinationField.text =  "\(suggestedDestinationValue)"
                    }
                }
                else if suggestDestinationControlValue == "No" {
                    wantToSuggestDestination.selectedSegmentIndex = 1
                    suggestDestinationField.alpha = 0
                }
                
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
        if textField == suggestDestinationField {
        suggestDestinationField.resignFirstResponder()
            return true
        }
        if textField == homeAirport {
        homeAirport.resignFirstResponder()
            return true
        }
        if textField == decidedOnDestinationTextField {
        decidedOnDestinationTextField.resignFirstResponder()
            return true
        }
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    ///////////////////////////////////COLLECTION VIEW/////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////
    // Fetch Contacts
    func retrieveContactsWithStore(store: CNContactStore) {
        let contactIDs = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString]
        do {
            if (contactIDs?.count)! > 0 {
                let predicate = CNContact.predicateForContacts(withIdentifiers: contactIDs as! [String])
                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey, CNContactImageDataAvailableKey] as [Any]
                contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
            } else {
                contacts = nil
            }
            DispatchQueue.main.async (execute: { () -> Void in
            })
        } catch {
            print(error)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let contactIDs = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString]
        if (contactIDs?.count)! > 0 {
            return (contactIDs?.count)!
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let contactsCell = contactsCollectionView.dequeueReusableCell(withReuseIdentifier: "contactsCollectionPrototypeCell", for: indexPath) as! contactsCollectionViewCell
        
        retrieveContactsWithStore(store: addressBookStore)
        let contact = contacts?[indexPath.row]
        if (contact?.imageDataAvailable)! {
            contactsCell.thumbnailImage.image = UIImage(data: (contact?.thumbnailImageData!)!)
            contactsCell.thumbnailImage.contentMode = .scaleToFill
            let reCenter = contactsCell.thumbnailImage.center
            contactsCell.thumbnailImage.layer.frame = CGRect(x: contactsCell.thumbnailImage.layer.frame.minX
                , y: contactsCell.thumbnailImage.layer.frame.minY, width: contactsCell.thumbnailImage.layer.frame.width * 0.91, height: contactsCell.thumbnailImage.layer.frame.height * 0.91)
            contactsCell.thumbnailImage.center = reCenter
            contactsCell.thumbnailImage.layer.cornerRadius = contactsCell.thumbnailImage.frame.height / 2
            contactsCell.thumbnailImage.layer.masksToBounds = true
            contactsCell.initialsLabel.isHidden = true
            contactsCell.thumbnailImageFilter.isHidden = false
            contactsCell.thumbnailImageFilter.image = UIImage(named: "no_contact_image_selected")!
            contactsCell.thumbnailImageFilter.alpha = 0.5
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
            retrieveContactsWithStore(store: addressBookStore)
            
            //  Create budget list and color array
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
            retrieveContactsWithStore(store: addressBookStore)
            
            let contact = contacts?[indexPath.row]
            let DeSelectedContact = contactsCollectionView.cellForItem(at: indexPath) as! contactsCollectionViewCell
            
            if (contact?.imageDataAvailable)! {
                DeSelectedContact.thumbnailImageFilter.alpha = 0.5
            } else {
                DeSelectedContact.thumbnailImage.image = UIImage(named: "no_contact_image")!
                DeSelectedContact.initialsLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            }
            
            let homeAirportValue = DataContainerSingleton.sharedDataContainer.homeAirport ?? ""
            if homeAirportValue != "" {
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
        //COPY
        let contactIDs = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString]
        
        let spacing = 10
        if (contactIDs?.count)! > 0 {
            var leftRightInset = (self.contactsCollectionView.frame.size.width / 2.0) - CGFloat((contactIDs?.count)!) * 27.5 - CGFloat(spacing / 2 * ((contactIDs?.count)! - 1))
            if (contactIDs?.count)! > 4 {
                leftRightInset = 30
            }
            return UIEdgeInsetsMake(0, leftRightInset, 0, 0)
        }
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    ////// ADD NEW TRIP VARS (NS ONLY) HERE ///////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func fetchSavedPreferencesForTrip() -> NSMutableDictionary {
        //Update preference vars if an existing trip
        //Trip status
        let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "booking_status") as? NSNumber ?? 0 as NSNumber
        //New Trip VC
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? NSString ?? NSString()
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString] ?? [NSString]()
        let contactPhoneNumbers = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contact_phone_numbers") as? [NSString] ?? [NSString]()
        let hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? [NSNumber] ?? [NSNumber]()
        //Calendar VC
        let segmentLengthValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "Availability_segment_lengths") as? [NSNumber] ?? [NSNumber]()
        let selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [NSDate] ?? [NSDate]()
        let leftDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "origin_departure_times") as? NSDictionary ?? NSDictionary()
        let rightDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "return_departure_times") as? NSDictionary ?? NSDictionary()
        //Budget VC
        let budgetValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "budget") as? NSString ?? NSString()
        let expectedRoundtripFare = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_roundtrip_fare") as? NSString ?? NSString()
        let expectedNightlyRate = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_nightly_rate") as? NSString ?? NSString()
        //Suggested Destination VC
        let decidedOnDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_control") as? NSString ?? NSString()
        let decidedOnDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_value") as? NSString ?? NSString()
        let suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? NSString ?? NSString()
        let suggestedDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggested_destination") as? NSString ?? NSString()
        //Activities VC
        let selectedActivities = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_activities") as? [NSString] ?? [NSString]()
        
        //SavedPreferences
        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus, "trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities] as NSMutableDictionary
        
        return fetchedSavedPreferencesForTrip
    }
    func saveUpdatedExistingTrip(SavedPreferencesForTrip: NSMutableDictionary) {
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        existing_trips?[currentTripIndex] = SavedPreferencesForTrip as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
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
            
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            let decidedOnDestinationControlValue = SavedPreferencesForTrip["decided_destination_control"] as! NSString
            let decidedOnDestinationValue = SavedPreferencesForTrip["decided_destination_value"] as! NSString
            let suggestDestinationControlValue = SavedPreferencesForTrip["suggest_destination_control"] as! NSString
            let suggestedDestinationValue = SavedPreferencesForTrip["suggested_destination"] as! NSString

            if decidedOnDestinationControlValue == "Yes" {
                decidedOnDestinationControl.selectedSegmentIndex = 0
                UIView.animate(withDuration: 0.7) {
                    self.decidedOnDestinationTextField.alpha = 1
                }
                if decidedOnDestinationValue != "" {
                    self.decidedOnDestinationTextField.text = "\(decidedOnDestinationValue)"
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
                    if suggestedDestinationValue != "" {
                        self.suggestDestinationField.text =  "\(suggestedDestinationValue)"
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
        var decidedOnDestinationControlValue = NSString()
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
        
        //Update trip preferences in dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["decided_destination_control"] = decidedOnDestinationControlValue as NSString
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    @IBAction func decidedDestinationEditingChanged(_ sender: Any) {
        
        var decidedOnDestinationValue = NSString()
        if decidedOnDestinationTextField.text != nil {
            decidedOnDestinationValue = decidedOnDestinationTextField.text! as NSString
        }
        //Update trip preferences in dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["decided_destination_value"] = decidedOnDestinationValue as NSString
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    @IBAction func suggestDestinationControlValueChanged(_ sender: Any) {
        var suggestDestinationControlValue = NSString()
        if wantToSuggestDestination.selectedSegmentIndex == 0 {
            suggestDestinationControlValue = "Yes"
        }
        else {
            suggestDestinationControlValue = "No"
        }
        
        //Update trip preferences in dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["suggest_destination_control"] = suggestDestinationControlValue as NSString
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    @IBAction func wantToSuggestDestinationValueYes(_ sender: Any) {
        if wantToSuggestDestination.selectedSegmentIndex == 0 && decidedOnDestinationControl.selectedSegmentIndex == 1{
            UIView.animate(withDuration: 0.7) {
                self.suggestDestinationField.alpha = 1
            }
        }
        else if wantToSuggestDestination.selectedSegmentIndex == 1 {
                self.suggestDestinationField.alpha = 0
        }
    }
    @IBAction func suggestedDestinationValueChanged(_ sender: Any) {
        var suggestedDestinationValue = NSString()
        if suggestDestinationField.text != nil {
            suggestedDestinationValue = suggestDestinationField.text! as NSString
        }
        //Update trip preferences in dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["suggested_destination"] = suggestedDestinationValue as NSString
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
}
