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
    var objectPhoneNumbers: [NSString]?
    let sliderStep: Float = 1

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
        self.newTripNameTextField.delegate = self
        
        addressBookStore = CNContactStore()
        
        // Set appearance of textfield
        newTripNameTextField.layer.borderWidth = 1
        newTripNameTextField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        newTripNameTextField.layer.masksToBounds = true
        newTripNameTextField.layer.cornerRadius = 5
        let newTripNameLabelPlaceholder = newTripNameTextField!.value(forKey: "placeholderLabel") as? UILabel
        newTripNameLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        //Load the values from our shared data container singleton
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        var numberSavedTrips: Int?
        var tripNameValue: NSString?
        if DataContainerSingleton.sharedDataContainer.usertrippreferences == nil {
            numberSavedTrips = 0
        }
        else {
        let SavedTrips = DataContainerSingleton.sharedDataContainer.usertrippreferences
            numberSavedTrips = (SavedTrips?.count)! - 1
        }
        
        if currentTripIndex > numberSavedTrips! {
        }
        else {
            tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? NSString
            retrieveContactsWithStore(store: addressBookStore)
            
            let hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? Float
            if hotelRoomsValue != nil {
                numberHotelRoomsControl.setValue(hotelRoomsValue!, animated: false)
            }
            if objects == nil {
                numberHotelRoomsLabel.alpha = 0
                numberHotelRoomsControl.alpha = 0
                numberHotelRoomsStack.alpha = 0
            } else {
                numberHotelRoomsLabel.alpha = 1
                numberHotelRoomsControl.alpha = 1
                numberHotelRoomsStack.alpha = 1
            }
        }
        
        //Install the value into the label.
        if tripNameValue == nil {
            nextButton.alpha =  0
            groupMemberListTable.alpha = 0
            whoToTravelWithLabel.alpha = 0
            addFromContactsButton.alpha = 0
        }
        else {
        self.newTripNameTextField.text =  "\(tripNameValue!)"
            nextButton.alpha = 1
            groupMemberListTable.alpha = 1
            whoToTravelWithLabel.alpha = 1
            addFromContactsButton.alpha = 1
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
        picker.delegate = self
        picker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        objectIDs = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as! [NSString]?
        if objectIDs != nil {
        picker.predicateForEnablingContact = NSPredicate(format:"(phoneNumbers.@count > 0) AND NOT (identifier in %@)", objectIDs!)
        }
        picker.predicateForSelectionOfContact = NSPredicate(format:"phoneNumbers.@count == 1")
        self.present(picker , animated: true, completion: nil)
    }
    
    func retrieveContactsWithStore(store: CNContactStore) {
        objectIDs = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as! [NSString]?
        do {
            if objectIDs != nil {
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
            objectPhoneNumbers?.append(contactProperty.value(forKey: "digits") as! NSString)
            let numberContactsInTable = groupMemberListTable.numberOfRows(inSection: 0)
            let addedRowIndexPath = [IndexPath(row: numberContactsInTable, section: 0)]
            groupMemberListTable.insertRows(at: addedRowIndexPath, with: .left)
        }
        else {
            objects = [contactProperty.contact as NSObject]
            objectIDs?.append(contactProperty.contact.identifier as NSString)
            objectPhoneNumbers?.append(contactProperty.value(forKey: "digits") as! NSString)
            let addedRowIndexPath = [IndexPath(row: 0, section: 0)]
            groupMemberListTable.insertRows(at: addedRowIndexPath, with: .left)
        }
        groupMemberListTable.reloadData()
        groupMemberListTable.endUpdates()
        
        // Save trip name and contacts
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        var numberSavedTrips: Int?
        if DataContainerSingleton.sharedDataContainer.usertrippreferences == nil {
            numberSavedTrips = 0
        }
        else {
            let SavedTrips = DataContainerSingleton.sharedDataContainer.usertrippreferences
            numberSavedTrips = (SavedTrips?.count)! - 1
        }
        
        if existing_trips == nil {
            let newTrip = ["trip_name": newTripNameTextField.text! as NSString,"contacts_in_group": objectIDs ?? [NSString](), "group_phone_numbers":objectPhoneNumbers ?? [NSString]()] as NSDictionary
            let user_trip = [newTrip]
            DataContainerSingleton.sharedDataContainer.usertrippreferences = user_trip as [NSDictionary]?
        }
        else if currentTripIndex <= numberSavedTrips!   {
            let updatedTripToBeSaved = ["trip_name": newTripNameTextField.text as NSString!,"contacts_in_group": objectIDs ?? [NSString](), "group_phone_numbers":objectPhoneNumbers ?? [NSString]()] as NSDictionary
            existing_trips?[currentTripIndex] = updatedTripToBeSaved as NSDictionary
            DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
        }
        else {
            let newTripToBeAppended = ["trip_name": newTripNameTextField.text as NSString!,"contacts_in_group": objectIDs ?? [NSString](), "group_phone_numbers":objectPhoneNumbers ?? [NSString]()] as NSDictionary
            existing_trips?.append(newTripToBeAppended as NSDictionary)
            DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
        }
        // activate hotels room
        if objects != nil {
            numberHotelRoomsLabel.alpha = 1
            numberHotelRoomsControl.alpha = 1
            numberHotelRoomsStack.alpha = 1
            
            var roundedValue = roundf(Float((objects?.count)! + 1)/2)
            if roundedValue > 4 {
                roundedValue = 4
            }
            if roundedValue < 1 {
                roundedValue = 1
            }
            numberHotelRoomsControl.setValue(roundedValue, animated: false)
            //Save
            var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
            let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
            let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? NSString
            let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString]
            let updatedTripToBeSaved = ["trip_name": tripNameValue!, "contacts_in_group": contacts!, "hotel_rooms": roundedValue as NSNumber, "group_phone_numbers":objectPhoneNumbers ?? [NSString]()] as NSDictionary
            existing_trips?[currentTripIndex] = updatedTripToBeSaved as NSDictionary
            DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
            
        }
        if objects == nil {
            numberHotelRoomsLabel.alpha = 0
            numberHotelRoomsControl.alpha = 0
            numberHotelRoomsStack.alpha = 0
        }
    }
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        groupMemberListTable.beginUpdates()
        if objects != nil {
            objects?.append(contact as NSObject)
            objectIDs?.append(contact.identifier as NSString)
            objectPhoneNumbers?.append(contact.phoneNumbers[0].value(forKey: "digits") as! NSString)
            let numberContactsInTable = groupMemberListTable.numberOfRows(inSection: 0)
            let addedRowIndexPath = [IndexPath(row: numberContactsInTable, section: 0)]
            groupMemberListTable.insertRows(at: addedRowIndexPath, with: .left)
        }
        else {
            objects = [contact as NSObject]
            objectIDs?.append(contact.identifier as NSString)
            objectPhoneNumbers?.append(contact.phoneNumbers[0].value(forKey: "digits") as! NSString)
            let addedRowIndexPath = [IndexPath(row: 0, section: 0)]
            groupMemberListTable.insertRows(at: addedRowIndexPath, with: .left)
        }
        groupMemberListTable.reloadData()
        groupMemberListTable.endUpdates()
        
        // Save trip name and contacts
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        var numberSavedTrips: Int?
        if DataContainerSingleton.sharedDataContainer.usertrippreferences == nil {
            numberSavedTrips = 0
        }
        else {
            let SavedTrips = DataContainerSingleton.sharedDataContainer.usertrippreferences
            numberSavedTrips = (SavedTrips?.count)! - 1
        }
        
        if existing_trips == nil {
            let newTrip = ["trip_name": newTripNameTextField.text! as NSString,"contacts_in_group": objectIDs ?? [NSString](), "group_phone_numbers":objectPhoneNumbers ?? [NSString]()] as NSDictionary
            let user_trip = [newTrip]
            DataContainerSingleton.sharedDataContainer.usertrippreferences = user_trip as [NSDictionary]?
        }
        else if currentTripIndex <= numberSavedTrips!   {
            let updatedTripToBeSaved = ["trip_name": newTripNameTextField.text as NSString!,"contacts_in_group": objectIDs ?? [NSString](), "group_phone_numbers":objectPhoneNumbers ?? [NSString]()] as NSDictionary
            existing_trips?[currentTripIndex] = updatedTripToBeSaved as NSDictionary
            DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
        }
        else {
            let newTripToBeAppended = ["trip_name": newTripNameTextField.text as NSString!,"contacts_in_group": objectIDs ?? [NSString](), "group_phone_numbers":objectPhoneNumbers ?? [NSString]()] as NSDictionary
            existing_trips?.append(newTripToBeAppended as NSDictionary)
            DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
        }
        // activate hotels room
        if objects != nil {
            numberHotelRoomsLabel.alpha = 1
            numberHotelRoomsControl.alpha = 1
            numberHotelRoomsStack.alpha = 1
            
            var roundedValue = roundf(Float((objects?.count)! + 1)/2)
            if roundedValue > 4 {
                roundedValue = 4
            }
            if roundedValue < 1 {
                roundedValue = 1
            }
            numberHotelRoomsControl.setValue(roundedValue, animated: false)
            //Save
            var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
            let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
            let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? NSString
            let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString]
            let updatedTripToBeSaved = ["trip_name": tripNameValue!, "contacts_in_group": contacts!, "hotel_rooms": roundedValue as NSNumber, "group_phone_numbers":objectPhoneNumbers ?? [NSString]()] as NSDictionary
            existing_trips?[currentTripIndex] = updatedTripToBeSaved as NSDictionary
            DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips

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
            objects?.remove(at: indexPath.row)
            objectIDs?.remove(at: indexPath.row)
            objectPhoneNumbers?.remove(at: indexPath.row)
            groupMemberListTable.deleteRows(at: [indexPath], with: .fade)
            
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
            
            //Save
            var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
            let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
            let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? NSString
            let updatedTripToBeSaved = ["trip_name": tripNameValue!, "contacts_in_group": objectIDs ?? [NSString](), "hotel_rooms": roundedValue as NSNumber, "group_phone_numbers":objectPhoneNumbers ?? [NSString]()] as NSDictionary
            existing_trips?[currentTripIndex] = updatedTripToBeSaved as NSDictionary
            DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips

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
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        var numberSavedTrips: Int?
        if DataContainerSingleton.sharedDataContainer.usertrippreferences == nil {
            numberSavedTrips = 0
        }
        else {
            let SavedTrips = DataContainerSingleton.sharedDataContainer.usertrippreferences
            numberSavedTrips = (SavedTrips?.count)! - 1
        }
        
        if existing_trips == nil {
            let newTrip = ["trip_name": newTripNameTextField.text! as NSString,"contacts_in_group": objectIDs ?? [NSString](), "group_phone_numbers":objectPhoneNumbers ?? [NSString]()] as NSDictionary
            let user_trip = [newTrip]
            DataContainerSingleton.sharedDataContainer.usertrippreferences = user_trip as [NSDictionary]?
        }
        else if currentTripIndex <= numberSavedTrips!   {
            let updatedTripToBeSaved = ["trip_name": newTripNameTextField.text as NSString!,"contacts_in_group": objectIDs ?? [NSString](), "group_phone_numbers":objectPhoneNumbers ?? [NSString]()] as NSDictionary
            existing_trips?[currentTripIndex] = updatedTripToBeSaved as NSDictionary
            DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
        }
        else {
            let newTripToBeAppended = ["trip_name": newTripNameTextField.text as NSString!,"contacts_in_group": objectIDs ?? [NSString](), "group_phone_numbers":objectPhoneNumbers ?? [NSString]()] as NSDictionary
            existing_trips?.append(newTripToBeAppended as NSDictionary)
            DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
        }

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
        }
    }
    @IBAction func sliderValueChanged(_ sender: Any) {
        let roundedValue = round(numberHotelRoomsControl.value / sliderStep)
        numberHotelRoomsControl.setValue(roundedValue, animated: true)
        
        //Save
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? NSString
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString]

        let updatedTripToBeSaved = ["trip_name": tripNameValue!, "contacts_in_group": contacts!, "hotel_rooms": roundedValue as NSNumber, "group_phone_numbers":objectPhoneNumbers ?? [NSString]()] as NSDictionary
        existing_trips?[currentTripIndex] = updatedTripToBeSaved as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
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
