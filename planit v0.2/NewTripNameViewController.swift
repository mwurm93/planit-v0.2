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

class NewTripNameViewController: UIViewController, UITextFieldDelegate, CNContactPickerDelegate, CNContactViewControllerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    fileprivate var addressBookStore: CNContactStore!
    fileprivate var menuArray: NSMutableArray?
    let picker = CNContactPickerViewController()
    var objects: [NSObject]?
    var objectIDs: [NSString]?
    var objectPhoneNumbers = [NSString]()
    let sliderStep: Float = 1
    var NewOrAddedTripFromSegue: Int?

// MARK: Outlets
    
    @IBOutlet weak var newTripNameTextField: UITextField!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var groupMemberListTable: UITableView!
    @IBOutlet weak var whoToTravelWithLabel: UILabel!
    @IBOutlet weak var addFromContactsButton: UIButton!
    @IBOutlet weak var numberHotelRoomsLabel: UILabel!
    @IBOutlet weak var numberHotelRoomsControl: UISlider!
    @IBOutlet weak var numberHotelRoomsStack: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.autoresizingMask = .flexibleTopMargin
        view.sizeToFit()
        
        self.hideKeyboardWhenTappedAround()
        addressBookStore = CNContactStore()
        
        // Set appearance of textfield
        newTripNameTextField.layer.borderWidth = 1
        newTripNameTextField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        newTripNameTextField.layer.masksToBounds = true
        newTripNameTextField.layer.cornerRadius = 5
        let newTripNameLabelPlaceholder = newTripNameTextField!.value(forKey: "placeholderLabel") as? UILabel
        newTripNameLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        self.newTripNameTextField.delegate = self
        
        if NewOrAddedTripFromSegue == 1 {
            numberHotelRoomsLabel.alpha = 0
            numberHotelRoomsControl.alpha = 0
            numberHotelRoomsStack.alpha = 0
            DataContainerSingleton.sharedDataContainer.currenttrip! -= 1
            nextButton.alpha =  0
            groupMemberListTable.alpha = 0
            whoToTravelWithLabel.alpha = 0
            addFromContactsButton.alpha = 0
            newTripNameTextField.becomeFirstResponder()
        } else {
            //load trip preferences dictionary
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()

            retrieveContactsWithStore(store: addressBookStore)
            
            let hotelRoomsValue = SavedPreferencesForTrip["hotel_rooms"] as! [NSNumber]
            if hotelRoomsValue.count > 0 {
                self.numberHotelRoomsControl.setValue(Float(hotelRoomsValue[0]), animated: false)
            }
            let contactIDs = SavedPreferencesForTrip["contacts_in_group"] as! [NSString]

            if contactIDs.count > 0  {
                numberHotelRoomsLabel.alpha = 1
                numberHotelRoomsControl.alpha = 1
                numberHotelRoomsStack.alpha = 1
            }
        
        //Install the value into the label.
        let tripNameValue = SavedPreferencesForTrip["trip_name"] as! NSString
            
        if tripNameValue == "" {
                nextButton.alpha =  0
            groupMemberListTable.alpha = 0
            whoToTravelWithLabel.alpha = 0
            addFromContactsButton.alpha = 0
        }
        else {
        self.newTripNameTextField.text =  "\(tripNameValue)"
            nextButton.alpha = 1
            groupMemberListTable.alpha = 1
            whoToTravelWithLabel.alpha = 1
            addFromContactsButton.alpha = 1
        }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
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
            } else {
                self.objects = nil
            }
            DispatchQueue.main.async (execute: { () -> Void in
                self.groupMemberListTable.reloadData()
            })
        } catch {
            print(error)
        }
    }
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        groupMemberListTable.beginUpdates()
        if objects != nil {
            objects?.append(contactProperty.contact as NSObject)
            objectIDs?.append(contactProperty.contact.identifier as NSString)
            let allPhoneNumbersForContact = contactProperty.contact.phoneNumbers
            var indexForCorrectPhoneNumber: Int?
            for indexOfPhoneNumber in 0...(allPhoneNumbersForContact.count - 1) {
                if allPhoneNumbersForContact[indexOfPhoneNumber].value == contactProperty.value as! CNPhoneNumber {
                    indexForCorrectPhoneNumber = indexOfPhoneNumber
                }
            }
            let phoneNumberToAdd = contactProperty.contact.phoneNumbers[indexForCorrectPhoneNumber!].value.value(forKey: "digits") as! NSString
            objectPhoneNumbers.append(phoneNumberToAdd)
            
            let numberContactsInTable = groupMemberListTable.numberOfRows(inSection: 0)
            let addedRowIndexPath = [IndexPath(row: numberContactsInTable, section: 0)]
            groupMemberListTable.insertRows(at: addedRowIndexPath, with: .left)
        }
        else {
            objects = [contactProperty.contact as NSObject]
            objectIDs?.append(contactProperty.contact.identifier as NSString)
            let allPhoneNumbersForContact = contactProperty.contact.phoneNumbers
            var indexForCorrectPhoneNumber: Int?
            for indexOfPhoneNumber in 0...(allPhoneNumbersForContact.count - 1) {
                if allPhoneNumbersForContact[indexOfPhoneNumber].value == contactProperty.value as! CNPhoneNumber {
                    indexForCorrectPhoneNumber = indexOfPhoneNumber
                }
            }
            let phoneNumberToAdd = contactProperty.contact.phoneNumbers[indexForCorrectPhoneNumber!].value.value(forKey: "digits") as! NSString
            objectPhoneNumbers.append(phoneNumberToAdd)
            
            let addedRowIndexPath = [IndexPath(row: 0, section: 0)]
            groupMemberListTable.insertRows(at: addedRowIndexPath, with: .left)
        }
        groupMemberListTable.reloadData()
        groupMemberListTable.endUpdates()
        
        //Update trip preferences dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["contacts_in_group"] = objectIDs
        SavedPreferencesForTrip["contact_phone_numbers"] = objectPhoneNumbers
        //Save updated trip preferences dictionary
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
        // activate hotels room
        if objects != nil {
            numberHotelRoomsLabel.alpha = 1
            numberHotelRoomsControl.alpha = 1
            numberHotelRoomsStack.alpha = 1
            
            let numberContactsInTable = objectPhoneNumbers.count
            if numberContactsInTable < 5 {
                numberHotelRoomsLabel.frame = CGRect(x: 67, y: 253 + numberContactsInTable * 55, width: 236, height: 48)
                numberHotelRoomsControl.frame = CGRect(x: 91, y: 306 + numberContactsInTable * 55, width: 192, height: 31)
                numberHotelRoomsStack.frame = CGRect(x: 102, y: 339 + numberContactsInTable * 55, width: 170, height: 21)
                groupMemberListTable.frame = CGRect(x: 34, y: 233, width: 307, height: numberContactsInTable * 60)
            }
            else {
            numberHotelRoomsLabel.frame = CGRect(x: 67, y: 481, width: 236, height: 48)
            numberHotelRoomsControl.frame = CGRect(x: 91, y: 534, width: 192, height: 31)
            numberHotelRoomsStack.frame = CGRect(x: 102, y: 567, width: 170, height: 21)
                groupMemberListTable.frame = CGRect(x: 34, y: 233, width: 307, height: 237)
            }
            
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
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
        }
        if objects == nil {
            numberHotelRoomsLabel.alpha = 0
            numberHotelRoomsControl.alpha = 0
            numberHotelRoomsStack.alpha = 0
        }
    }
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        //Update changed preferences as variables
        groupMemberListTable.beginUpdates()
        if objects != nil {
            objects?.append(contact as NSObject)
            objectIDs?.append(contact.identifier as NSString)
            let phoneNumberToAdd = contact.phoneNumbers[0].value.value(forKey: "digits") as! NSString
            objectPhoneNumbers.append(phoneNumberToAdd)
            
            let numberContactsInTable = groupMemberListTable.numberOfRows(inSection: 0)
            let addedRowIndexPath = [IndexPath(row: numberContactsInTable, section: 0)]
            groupMemberListTable.insertRows(at: addedRowIndexPath, with: .left)
        }
        else {
            objects = [contact as NSObject]
            objectIDs?.append(contact.identifier as NSString)
            let phoneNumberToAdd = contact.phoneNumbers[0].value.value(forKey: "digits") as! NSString
            objectPhoneNumbers.append(phoneNumberToAdd)
            
            let addedRowIndexPath = [IndexPath(row: 0, section: 0)]
            groupMemberListTable.insertRows(at: addedRowIndexPath, with: .left)
        }
        groupMemberListTable.reloadData()
        groupMemberListTable.endUpdates()
        
        //Update trip preferences dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["contacts_in_group"] = objectIDs
        SavedPreferencesForTrip["contact_phone_numbers"] = objectPhoneNumbers
        //Save updated trip preferences dictionary
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)

        // activate hotels room
        if objects != nil {
            numberHotelRoomsLabel.alpha = 1
            numberHotelRoomsControl.alpha = 1
            numberHotelRoomsStack.alpha = 1
            
            let numberContactsInTable = objectPhoneNumbers.count
            if numberContactsInTable < 5 {
                numberHotelRoomsLabel.frame = CGRect(x: 67, y: 253 + numberContactsInTable * 55, width: 236, height: 48)
                numberHotelRoomsControl.frame = CGRect(x: 91, y: 306 + numberContactsInTable * 55, width: 192, height: 31)
                numberHotelRoomsStack.frame = CGRect(x: 102, y: 339 + numberContactsInTable * 55, width: 170, height: 21)
                groupMemberListTable.frame = CGRect(x: 34, y: 233, width: 307, height: numberContactsInTable * 60)
            }
            else {
                numberHotelRoomsLabel.frame = CGRect(x: 67, y: 481, width: 236, height: 48)
                numberHotelRoomsControl.frame = CGRect(x: 91, y: 534, width: 192, height: 31)
                numberHotelRoomsStack.frame = CGRect(x: 102, y: 567, width: 170, height: 21)
                groupMemberListTable.frame = CGRect(x: 34, y: 233, width: 307, height: 237)
            }
            
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
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
        }
        if objects == nil {
            numberHotelRoomsLabel.alpha = 0
            numberHotelRoomsControl.alpha = 0
            numberHotelRoomsStack.alpha = 0
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
        var numberOfRows = 0
        if objects != nil {
            numberOfRows += objects!.count
        }
        
        return numberOfRows
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactsPrototypeCell", for: indexPath) as! contactsTableViewCell
        let contacts = objects as! [CNContact]?
        
        let contact = contacts?[indexPath.row]
        cell.nameLabel.text = (contact?.givenName)! + " " + (contact?.familyName)!
        
        if (contact?.imageDataAvailable)! {
            cell.thumbnailImage.image = UIImage(data: (contact?.thumbnailImageData!)!)
            cell.thumbnailImage.contentMode = .scaleToFill
            let reCenter = cell.thumbnailImage.center
            cell.thumbnailImage.layer.frame = CGRect(x: cell.thumbnailImage.layer.frame.minX
                , y: cell.thumbnailImage.layer.frame.minY, width: cell.thumbnailImage.layer.frame.width * 0.96, height: cell.thumbnailImage.layer.frame.height * 0.96)
            cell.thumbnailImage.center = reCenter
            cell.thumbnailImage.layer.cornerRadius = cell.thumbnailImage.frame.height / 2
            cell.thumbnailImage.layer.masksToBounds = true
            cell.initialsLabel.isHidden = true
        } else{
            cell.thumbnailImage.image = UIImage(named: "no_contact_image")!
            cell.initialsLabel.isHidden = false
            let firstInitial = contact?.givenName[0]
            let secondInitial = contact?.familyName[0]
            cell.initialsLabel.text = firstInitial! + secondInitial!
        }
        return (cell)
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            objectPhoneNumbers = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contact_phone_numbers") as? [NSString] ?? [NSString]()
            
            objects?.remove(at: indexPath.row)
            objectIDs?.remove(at: indexPath.row)
            objectPhoneNumbers.remove(at: indexPath.row)
            groupMemberListTable.deleteRows(at: [indexPath], with: .left)
            
            //update hotel room slider
            var roundedValue = Float()
            if objects != nil {
                roundedValue = roundf(Float((objects?.count)! + 1)/2)
                if roundedValue > 4 {
                    roundedValue = 4
                }
                if roundedValue < 1 {
                    roundedValue = 1
                }
                numberHotelRoomsControl.setValue(roundedValue, animated: true)
            }
            
            //Update changed preferences as variables
            let hotelRoomsValue = NSNumber(value: roundedValue)
            //Update trip preferences dictionary
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["hotel_rooms"] = hotelRoomsValue
            SavedPreferencesForTrip["contacts_in_group"] = objectIDs
            SavedPreferencesForTrip["contact_phone_numbers"] = objectPhoneNumbers
            //Save updated trip preferences dictionary
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }

    //MARK: Actions
    @IBAction func addContactToTrip(_ sender: Any) {
        checkContactsAccess()
    }
    
    @IBAction func TripNameEditingChanged(_ sender: Any) {
        if NewOrAddedTripFromSegue == 1 {
            DataContainerSingleton.sharedDataContainer.currenttrip! += 1
        }
        //Update changed preferences as variables
            NewOrAddedTripFromSegue = 0
        
            let tripNameValue = newTripNameTextField.text! as NSString
            //Update trip preferences in dictionary
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["trip_name"] = tripNameValue
            //Save
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            //Activate next button
            if newTripNameTextField.text != nil {
                UIView.animate(withDuration: 1) {
                    self.nextButton.alpha = 1
                    self.groupMemberListTable.alpha = 1
                    self.whoToTravelWithLabel.alpha = 1
                    self.addFromContactsButton.alpha = 1
                }
            }
            if newTripNameTextField.text == "" {
                nextButton.alpha = 0
                groupMemberListTable.alpha = 0
                whoToTravelWithLabel.alpha = 0
                addFromContactsButton.alpha = 0
            }
    }
    
    func roundSlider() {
        //Update changed preferences
        let hotelRoomsValue = [NSNumber(value: (round(numberHotelRoomsControl.value / sliderStep)))]
        numberHotelRoomsControl.setValue(Float(hotelRoomsValue[0]), animated: true)
        
        //Update trip preferences dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["hotel_rooms"] = hotelRoomsValue
        //Save updated trip preferences dictionary
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    @IBAction func SliderTouchDragExit(_ sender: Any) {
        roundSlider()
        updateCompletionStatus()
        let when = DispatchTime.now() + 0.3
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.performSegue(withIdentifier: "tripNameVCToCalendarVC", sender: nil)
        }
    }
    @IBAction func sliderEditingChanged(_ sender: Any) {
        roundSlider()
        updateCompletionStatus()
        let when = DispatchTime.now() + 0.3
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.performSegue(withIdentifier: "tripNameVCToCalendarVC", sender: nil)
        }
    }
    @IBAction func sliderValueChanged(_ sender: Any) {
        roundSlider()
        updateCompletionStatus()
        let when = DispatchTime.now() + 0.3
        DispatchQueue.main.asyncAfter(deadline: when) {
            self.performSegue(withIdentifier: "tripNameVCToCalendarVC", sender: nil)
        }
    }
    @IBAction func nextButtonPressed(_ sender: Any) {
        // Change preferences finished status
        updateCompletionStatus()
    }
    
    func updateCompletionStatus(){
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["finished_entering_preferences_status"] = "Name_Contacts_Rooms" as NSString
        //Save
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    ////// ADD NEW TRIP VARS (NS ONLY) HERE ///////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func fetchSavedPreferencesForTrip() -> NSMutableDictionary {
        //Determine if new or added trip
        let isNewOrAddedTrip = determineIfNewOrAddedTrip()
        //Init preference vars for if new or added trip
        //Trip status
        var bookingStatus = NSNumber(value: 0)
        var finishedEnteringPreferencesStatus = NSString()
        //New Trip VC
        var tripNameValue = NSString()
        var contacts = [NSString]()
        var contactPhoneNumbers =  [NSString]()
        var hotelRoomsValue =  [NSNumber]()
        //Calendar VC
        var segmentLengthValue = [NSNumber]()
        var selectedDates = [NSDate]()
        var leftDateTimeArrays = NSDictionary()
        var rightDateTimeArrays = NSDictionary()
        //Budget VC
        var budgetValue = NSString()
        var expectedRoundtripFare = NSString()
        var expectedNightlyRate = NSString()
        //Suggested Destination VC
        var decidedOnDestinationControlValue = NSString()
        var decidedOnDestinationValue = NSString()
        var suggestDestinationControlValue = NSString()
        var suggestedDestinationValue = NSString()
        //Activities VC
        var selectedActivities = [NSString]()
        //Ranking VC
        var topTrips = [NSString]()
        
        //Update preference vars if an existing trip
        if isNewOrAddedTrip == 0 {
        //Trip status
        bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "booking_status") as? NSNumber ?? 0 as NSNumber
        finishedEnteringPreferencesStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "finished_entering_preferences_status") as? NSString ?? NSString()
        //New Trip VC
        tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? NSString ?? NSString()
        contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString] ?? [NSString]()
        contactPhoneNumbers = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contact_phone_numbers") as? [NSString] ?? [NSString]()
        hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? [NSNumber] ?? [NSNumber]()
        //Calendar VC
        segmentLengthValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "Availability_segment_lengths") as? [NSNumber] ?? [NSNumber]()
        selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [NSDate] ?? [NSDate]()
        leftDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "origin_departure_times") as? NSDictionary ?? NSDictionary()
        rightDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "return_departure_times") as? NSDictionary ?? NSDictionary()
        //Budget VC
        budgetValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "budget") as? NSString ?? NSString()
        expectedRoundtripFare = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_roundtrip_fare") as? NSString ?? NSString()
        expectedNightlyRate = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_nightly_rate") as? NSString ?? NSString()
        //Suggested Destination VC
        decidedOnDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_control") as? NSString ?? NSString()
        decidedOnDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_value") as? NSString ?? NSString()
        suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? NSString ?? NSString()
        suggestedDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggested_destination") as? NSString ?? NSString()
        //Activities VC
        selectedActivities = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_activities") as? [NSString] ?? [NSString]()
        //Ranking VC
        topTrips = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "top_trips") as? [NSString] ?? [NSString]()
        }
        
        //SavedPreferences
        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus,"finished_entering_preferences_status": finishedEnteringPreferencesStatus, "trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips] as NSMutableDictionary
        
        return fetchedSavedPreferencesForTrip
        
    }
    
    func determineIfNewOrAddedTrip() -> Int {
        let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        var numberSavedTrips: Int?
        var isNewOrAddedTrip: Int?
        if existing_trips == nil {
            numberSavedTrips = 0
            isNewOrAddedTrip = 1
        }
        else {
            numberSavedTrips = (existing_trips?.count)! - 1
            if currentTripIndex <= numberSavedTrips! {
                isNewOrAddedTrip = 0
            } else {
                isNewOrAddedTrip = 1
            }
        }
        return isNewOrAddedTrip!
    }
    
    func saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: NSMutableDictionary) {
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        
        var numberSavedTrips: Int?
        if DataContainerSingleton.sharedDataContainer.usertrippreferences == nil {
            numberSavedTrips = 0
        }
        else {
            numberSavedTrips = (existing_trips?.count)! - 1
            
        }

        //Case: first trip
        if existing_trips == nil {
            let firstTrip = [SavedPreferencesForTrip as NSDictionary]
            DataContainerSingleton.sharedDataContainer.usertrippreferences = firstTrip
        }
            //Case: existing trip
        else if currentTripIndex <= numberSavedTrips!   {
            existing_trips?[currentTripIndex] = SavedPreferencesForTrip as NSDictionary
            DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
        }
            //Case: added trip, but not first trip
        else {
            existing_trips?.append(SavedPreferencesForTrip as NSDictionary)
            DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
        }
    }
}

extension String {
    var length: Int {
        return self.characters.count
    }
    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    func substring(from: Int) -> String {
        return self[Range(min(from, length) ..< length)]
    }
    func substring(to: Int) -> String {
        return self[Range(0 ..< max(0, to))]
    }
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return self[Range(start ..< end)]
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
