//
//  NewTripNameViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/17/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit
import ContactsUI
import Contacts

class HotelPreferencesViewController: UIViewController, UITextFieldDelegate, CNContactPickerDelegate, CNContactViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate,UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //Contacts vars
    fileprivate var addressBookStore: CNContactStore!
    fileprivate var menuArray: NSMutableArray?
    let picker = CNContactPickerViewController()
    var contacts: [CNContact]?
    var objects: [NSObject]?
    var contactIDs: [NSString]?
    var objectIDs: [NSString]?
    var objectPhoneNumbers = [NSString]()
    var contactPhoneNumbers = [NSString]()
    let sliderStep: Float = 1
    let amenitiesList = ["Free WiFi", "Non-Smoking", "Free Parking", "Fitness center", "Breakfast included", "Pool"]
    
    // MARK: Outlets
    @IBOutlet weak var newTripNameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var numberHotelRoomsLabel: UILabel!
    @IBOutlet weak var numberHotelRoomsControl: UISlider!
    @IBOutlet weak var numberHotelRoomsStack: UIStackView!
    @IBOutlet weak var addContactPlusIconMainVC: UIButton!
    @IBOutlet weak var contactsCollectionView: UICollectionView!
    @IBOutlet weak var amenitiesTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.autoresizingMask = .flexibleTopMargin
        view.sizeToFit()
        
        //Set up amenities table
        amenitiesTableView.layer.cornerRadius = 5
        amenitiesTableView.allowsMultipleSelection = true
        let FirstRow = IndexPath(row: 0, section: 0)
        let SecondRow = IndexPath(row: 1, section: 0)
        amenitiesTableView.selectRow(at: FirstRow, animated: false, scrollPosition: UITableViewScrollPosition.none)
        amenitiesTableView.selectRow(at: SecondRow, animated: false, scrollPosition: UITableViewScrollPosition.none)
        amenitiesTableView.cellForRow(at: FirstRow)?.layer.backgroundColor = UIColor.blue.cgColor
        amenitiesTableView.cellForRow(at: SecondRow)?.layer.backgroundColor = UIColor.blue.cgColor
        
        self.hideKeyboardWhenTappedAround()
        addressBookStore = CNContactStore()
        retrieveContactsWithStore(store: addressBookStore)
        
        self.newTripNameTextField.delegate = self
        
        //load trip preferences dictionary and install
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        
        let hotelRoomsValue = SavedPreferencesForTrip["hotel_rooms"] as! [NSNumber]
        if hotelRoomsValue.count > 0 {
            self.numberHotelRoomsControl.setValue(Float(hotelRoomsValue[0]), animated: false)
        }
        let contactIDs = SavedPreferencesForTrip["contacts_in_group"] as! [NSString]
        if contactIDs.count == 0 {
            numberHotelRoomsControl.setValue(Float(hotelRoomsValue[0]), animated: false)
        }
        
        let tripNameValue = SavedPreferencesForTrip["trip_name"] as! NSString
        if tripNameValue != "" {
            self.newTripNameTextField.text =  "\(tripNameValue)"
        }
    }

    // MARK: Custom functions
    func roundSlider() {
        let hotelRoomsValue = [NSNumber(value: (round(numberHotelRoomsControl.value / sliderStep)))]
        numberHotelRoomsControl.setValue(Float(hotelRoomsValue[0]), animated: true)
        
        //Update trip preferences dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["hotel_rooms"] = hotelRoomsValue
        //Save updated trip preferences dictionary
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }    
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfContacts = 0
        if contacts != nil {
            numberOfContacts += contacts!.count
        }
        
        return numberOfContacts
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
        
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    // MARK: Contacts
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
    fileprivate  func showContactsPicker() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        objectIDs = SavedPreferencesForTrip["contacts_in_group"] as? [NSString]
        
        picker.delegate = self
        picker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        if (objectIDs?.count)! > 0 {
            picker.predicateForEnablingContact = NSPredicate(format:"(phoneNumbers.@count > 0) AND NOT (identifier in %@)", objectIDs!)
        } else {
            picker.predicateForEnablingContact = NSPredicate(format:"(phoneNumbers.@count > 0)")
        }
        picker.predicateForSelectionOfContact = NSPredicate(format:"phoneNumbers.@count == 1")
        self.present(picker , animated: true, completion: nil)
    }
    
        func retrieveContactsWithStore(store: CNContactStore) {
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            objectIDs = SavedPreferencesForTrip["contacts_in_group"] as? [NSString]
            
            do {
                if (objectIDs?.count)! > 0 {
                    let predicate = CNContact.predicateForContacts(withIdentifiers: objectIDs as! [String])
                    let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey, CNContactImageDataAvailableKey] as [Any]
                    let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                    self.objects = contacts
                    self.contacts = contacts
                } else {
                    self.objects = nil
                }
                DispatchQueue.main.async (execute: { () -> Void in
                    self.contactsCollectionView.reloadData()
                })
            } catch {
                print(error)
            }
        }
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
            
            if contactIDs != nil {
                contacts?.append(contactProperty.contact)
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
                contacts = [contactProperty.contact]
                objects = [contactProperty.contact as NSObject]
                contactIDs = [contactProperty.contact.identifier as NSString]
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
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            
            //Update changed preferences as variables
            if contactIDs != nil {
                contacts?.append(contact)
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
                contacts = [contact]
                objects = [contact as NSObject]
                contactIDs = [contact.identifier as NSString]
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
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
        newTripNameTextField.resignFirstResponder()
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    // MARK: UITableviewdelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = amenitiesList.count
        return numberOfRows
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "amenityPrototypeCell", for: indexPath) as! amenityTableViewCell
        var addedRow = indexPath.row
        
        if indexPath.section == 1 {
            addedRow += 1
        }
        
        cell.amenityLabel.text = amenitiesList[addedRow]
        cell.layer.cornerRadius = 10

        return cell
    }
    
    //MARK: Actions
    @IBAction func numberHotelRoomsValueChanged(_ sender: Any) {
        roundSlider()
    }
    
    @IBAction func addContactToTrip(_ sender: Any) {
        checkContactsAccess()
    }
    
    @IBAction func tripNameEditingChanged(_ sender: Any) {
        let tripNameValue = newTripNameTextField.text as! NSString
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["trip_name"] = tripNameValue
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    @IBAction func nextButtonPressed(_ sender: Any) {
        // Change preferences finished status
        updateCompletionStatus()
    }
    
    func updateCompletionStatus(){
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["finished_entering_preferences_status"] = "Name_Contacts_Rooms" as NSString
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
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
        let topTrips = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "top_trips") as? [NSString] ?? [NSString]()
        
        //SavedPreferences
        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus, "finished_entering_preferences_status": finishedEnteringPreferencesStatus, "trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips] as NSMutableDictionary
        
        return fetchedSavedPreferencesForTrip
    }
    
        func saveUpdatedExistingTrip(SavedPreferencesForTrip: NSMutableDictionary) {
            var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
            let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
            existing_trips?[currentTripIndex] = SavedPreferencesForTrip as NSDictionary
            DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
        }
}
