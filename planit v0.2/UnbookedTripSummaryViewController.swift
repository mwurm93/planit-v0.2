//
//  UnbookedTripSummaryViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 1/29/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class UnbookedTripSummaryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CNContactPickerDelegate, CNContactViewControllerDelegate, UITextFieldDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var contactsCollectionView: UICollectionView!
    @IBOutlet weak var numberHotelRoomsControl: UISlider!
    @IBOutlet weak var numberHotelRoomsStack: UIStackView!
    @IBOutlet weak var budget: UITextField!
    @IBOutlet weak var homeAirport: UITextField!
    @IBOutlet weak var topDestination: UILabel!
    @IBOutlet weak var averageGroupBudget: UILabel!
    
    // Set up vars for Contacts - COPY
    var contacts: [CNContact]?
    var contactIDs: [NSString]?
    fileprivate var addressBookStore: CNContactStore!
    let picker = CNContactPickerViewController()
    var objects: [NSObject]?
//    var objectIDs: [NSString]?
    var contactPhoneNumbers = [NSString]()
    let sliderStep: Float = 1
    var homeAirportValue = DataContainerSingleton.sharedDataContainer.homeAirport ?? ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        // Initialize address book - COPY
        addressBookStore = CNContactStore()
        retrieveContactsWithStore(store: addressBookStore)
        
        self.budget.delegate = self

        // Set appearance of textfield
        budget.layer.cornerRadius = 5
        budget.layer.borderWidth = 1
        budget.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        budget.layer.masksToBounds = true
        let budgetLabelPlaceholder = budget!.value(forKey: "placeholderLabel") as? UILabel
        budgetLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        homeAirport.layer.cornerRadius = 5
        homeAirport.layer.borderWidth = 1
        homeAirport.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        homeAirport.layer.masksToBounds = true
        let homeAirportLabelPlaceholder = homeAirport!.value(forKey: "placeholderLabel") as? UILabel
        homeAirportLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        homeAirport.text =  "\(homeAirportValue)"
        
        // Set average group budget label
        averageGroupBudget.text = "Avg. budget of your group is $XYZ"
        

        // Load trip preferences
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()

        // Install top destination
        let decidedOnDestinationControlValue = SavedPreferencesForTrip["decided_destination_control"] as! NSString
        let decidedOnDestinationValue = SavedPreferencesForTrip["decided_destination_value"] as! NSString
        let finishedEnteringPreferencesStatus = SavedPreferencesForTrip["finished_entering_preferences_status"] as! NSString
        if decidedOnDestinationValue != "" && decidedOnDestinationControlValue == "Yes" {
            topDestination.text = decidedOnDestinationValue as String
        }
        else if finishedEnteringPreferencesStatus == "Ranking" {
            topDestination.text = "[top destination]"
        } else {
            topDestination.text = "TBD, tap for options"
        }
        
        // Install  trip name
        let tripNameValue = SavedPreferencesForTrip["trip_name"] as? NSString
        if tripNameValue != "" {
            self.tripNameLabel.text =  "\(tripNameValue!)"
        }
        
        // Install  hotel rooms value
        let hotelRoomsValue = SavedPreferencesForTrip["hotel_rooms"] as! [NSNumber]
        if hotelRoomsValue.count > 0 {
            self.numberHotelRoomsControl.setValue(Float(hotelRoomsValue[0]), animated: false)
        }
        
        // Install  budget value
        let budgetValue = SavedPreferencesForTrip["budget"] as! NSString
        if budgetValue != "" {
            budget.text =  "\(budgetValue)"
        }
        
    }
    
    // TEXT FIELDS
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
        if textField == budget {
            budget.resignFirstResponder()
            return true
        }
        if textField == homeAirport {
            homeAirport.resignFirstResponder()
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
    
    // MARK: - UICollectionViewFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let picDimension = 55
        return CGSize(width: picDimension, height: picDimension)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        //COPY
        let contactIDs = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString]
        
//        let spacing = 10
//        if (contactIDs?.count)! > 0 {
//            var leftRightInset = (self.contactsCollectionView.frame.size.width / 2.0) - CGFloat((contactIDs?.count)!) * 27.5 - CGFloat(spacing / 2 * ((contactIDs?.count)! - 1))
//            if (contactIDs?.count)! > 4 {
//                leftRightInset = 30
//            }
//            return UIEdgeInsetsMake(0, 0, 0, 0)
//        }
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    
    /////////Contacts picker//////////
    fileprivate func checkContactsAccess() {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        // Update our UI if the user has granted access to their Contacts
        case .authorized:
            self.showContactsPicker()
        // Prompt the user for access to Contacts if there is no definitive answer
        case .notDetermined :
            self.requestContactsAccess()
        // Display a message if the user has denied or restricted access to Contacts
        case .denied,
             .restricted:
            let alert = UIAlertController(title: "Privacy Warning!",
                                          message: "Please Enable permission! in settings!.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func requestContactsAccess() {
        addressBookStore.requestAccess(for: .contacts) {granted, error in
            if granted {
                DispatchQueue.main.async {
                    self.showContactsPicker()
                    return
                }
            }
        }
    }
    
    //Show Contact Picker
    fileprivate  func showContactsPicker() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        contactIDs = SavedPreferencesForTrip["contacts_in_group"] as? [NSString]
        
        picker.delegate = self
        picker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        if (contactIDs?.count)! > 0 {
            picker.predicateForEnablingContact = NSPredicate(format:"(phoneNumbers.@count > 0) AND NOT (identifier in %@)", contactIDs!)
        } else {
            picker.predicateForEnablingContact = NSPredicate(format:"(phoneNumbers.@count > 0)")
        }
        picker.predicateForSelectionOfContact = NSPredicate(format:"phoneNumbers.@count == 1")
        self.present(picker , animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        var contactIDs = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString]
        
        if contactIDs != nil {
            objects?.append(contactProperty.contact as NSObject)
            contactIDs?.append(contactProperty.contact.identifier as NSString)
            let allPhoneNumbersForContact = contactProperty.contact.phoneNumbers
            var indexForCorrectPhoneNumber: Int?
            for indexOfPhoneNumber in 0...(allPhoneNumbersForContact.count - 1) {
                if allPhoneNumbersForContact[indexOfPhoneNumber].value == contactProperty.value as! CNPhoneNumber {
                    indexForCorrectPhoneNumber = indexOfPhoneNumber
                }
            }
            let phoneNumberToAdd = contactProperty.contact.phoneNumbers[indexForCorrectPhoneNumber!].value.value(forKey: "digits") as! NSString
            contactPhoneNumbers.append(phoneNumberToAdd)
            
            let numberContactsInTable = contactsCollectionView.numberOfItems(inSection: 0)
            
            //Update trip preferences dictionary
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["contacts_in_group"] = contactIDs
            SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
            
            //Save updated trip preferences dictionary
            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            let addedRowIndexPath = [NSIndexPath(row: numberContactsInTable, section: 0)]
            self.contactsCollectionView.insertItems(at: addedRowIndexPath as [IndexPath])
            self.contactsCollectionView.reloadData()
        }
        else {
            objects = [contactProperty.contact as NSObject]
            contactIDs?.append(contactProperty.contact.identifier as NSString)
            let allPhoneNumbersForContact = contactProperty.contact.phoneNumbers
            var indexForCorrectPhoneNumber: Int?
            for indexOfPhoneNumber in 0...(allPhoneNumbersForContact.count - 1) {
                if allPhoneNumbersForContact[indexOfPhoneNumber].value == contactProperty.value as! CNPhoneNumber {
                    indexForCorrectPhoneNumber = indexOfPhoneNumber
                }
            }
            let phoneNumberToAdd = contactProperty.contact.phoneNumbers[indexForCorrectPhoneNumber!].value.value(forKey: "digits") as! NSString
            contactPhoneNumbers.append(phoneNumberToAdd)
            
            //Update trip preferences dictionary
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["contacts_in_group"] = contactIDs
            SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
            
            //Save updated trip preferences dictionary
            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            let addedRowIndexPath = [IndexPath(row: 0, section: 0)]
            self.contactsCollectionView.insertItems(at: addedRowIndexPath)
            self.contactsCollectionView.reloadData()
        }
        
        // activate hotels room
        if objects != nil {
            var roundedValue = roundf(Float((objects?.count)! + 1)/2)
            if roundedValue > 4 {
                roundedValue = 4
            }
            if roundedValue < 1 {
                roundedValue = 1
            }
            numberHotelRoomsControl.setValue(roundedValue, animated: false)
            
            //Update changed preferences as variables
            let hotelRoomsValue = [NSNumber(value: roundedValue)]
            //Update trip preferences dictionary
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["hotel_rooms"] = hotelRoomsValue
            //Save updated trip preferences dictionary
            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        }
    }
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        var contactIDs = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString]
        
        //Update changed preferences as variables
        if contactIDs != nil {
            objects?.append(contact as NSObject)
            contactIDs?.append(contact.identifier as NSString)
            let phoneNumberToAdd = contact.phoneNumbers[0].value.value(forKey: "digits") as! NSString
            contactPhoneNumbers.append(phoneNumberToAdd)
            
            let numberContactsInTable = contactsCollectionView.numberOfItems(inSection: 0)
            
            //Update trip preferences dictionary
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["contacts_in_group"] = contactIDs
            SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
            
            //Save updated trip preferences dictionary
            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)

            let addedRowIndexPath = [IndexPath(row: numberContactsInTable, section: 0)]
            self.contactsCollectionView.insertItems(at: addedRowIndexPath)
            self.contactsCollectionView.reloadData()
        }
        else {
            objects = [contact as NSObject]
            contactIDs?.append(contact.identifier as NSString)
            let phoneNumberToAdd = contact.phoneNumbers[0].value.value(forKey: "digits") as! NSString
            contactPhoneNumbers.append(phoneNumberToAdd)
            
            //Update trip preferences dictionary
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["contacts_in_group"] = contactIDs
            SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
            
            //Save updated trip preferences dictionary
            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            let addedRowIndexPath = [IndexPath(row: 0, section: 0)]
            self.contactsCollectionView.insertItems(at: addedRowIndexPath)
            self.contactsCollectionView.reloadData()
        }
        
        // activate hotels room
        if objects != nil {
            var roundedValue = roundf(Float((objects?.count)! + 1)/2)
            if roundedValue > 4 {
                roundedValue = 4
            }
            if roundedValue < 1 {
                roundedValue = 1
            }
            numberHotelRoomsControl.setValue(roundedValue, animated: true)
            
            //Update changed preferences as variables
            let hotelRoomsValue = [NSNumber(value: roundedValue)]
            //Update trip preferences dictionary
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["hotel_rooms"] = hotelRoomsValue
            //Save updated trip preferences dictionary
            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        }
    }
    
    
    // MARK: Actions
    @IBAction func addContact(_ sender: Any) {
        checkContactsAccess()
    }
    func roundSlider() {
        //Update changed preferences
        let hotelRoomsValue = [NSNumber(value: (round(numberHotelRoomsControl.value / sliderStep)))]
        numberHotelRoomsControl.setValue(Float(hotelRoomsValue[0]), animated: true)
        
        //Update trip preferences dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["hotel_rooms"] = hotelRoomsValue
        //Save updated trip preferences dictionary
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    @IBAction func SliderTouchDragExit(_ sender: Any) {
        roundSlider()
    }
    @IBAction func SliderEditingChanged(_ sender: Any) {
        roundSlider()
    }
    @IBAction func SliderValueChanged(_ sender: Any) {
        roundSlider()
    }
    @IBAction func budgetEditingChanged(_ sender: Any) {
        var budgetValue = String()
        if budget.text != nil {
            budgetValue = budget.text!
        }
        //Update trip preferences in dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["budget"] = budgetValue as NSString
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    @IBAction func homeAirportEditingChanged(_ sender: Any) {
        DataContainerSingleton.sharedDataContainer.homeAirport = homeAirport.text
    }
    
    ////// ADD NEW TRIP VARS (NS ONLY) HERE ///////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func fetchSavedPreferencesForTrip() -> NSMutableDictionary {
        
        //Update preference vars if an existing trip
        //Trip status
        let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "booking_status") as? NSNumber ?? 0 as NSNumber
        let finishedEnteringPreferencesStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "finished_entering_preferences_status") as? NSString ?? NSString()
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
        //Ranking VC
        topTrips = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "top_trips") as? [NSString] ?? [NSString]()

        //SavedPreferences
        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus, "finished_entering_preferences_status": finishedEnteringPreferencesStatus,"trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips] as NSMutableDictionary
        
        return fetchedSavedPreferencesForTrip
    }
    func saveUpdatedExistingTrip(SavedPreferencesForTrip: NSMutableDictionary) {
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        existing_trips?[currentTripIndex] = SavedPreferencesForTrip as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if budget.isEditing {
            
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                if self.view.frame.origin.y == 0{
                    self.view.frame.origin.y -= keyboardSize.height
                }
            }
        }
        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0{
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
}
