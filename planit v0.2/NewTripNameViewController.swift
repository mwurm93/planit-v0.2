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
import Koloda
import JTAppleCalendar

private var numberOfCards: Int = 5

class NewTripNameViewController: UIViewController, UITextFieldDelegate, CNContactPickerDelegate, CNContactViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate {
    
    fileprivate var dataSource: [UIImage] = {
        var array: [UIImage] = []
        for index in 0..<numberOfCards {
            array.append(UIImage(named: "Card_like_\(index + 1)")!)
        }
        
        return array
    }()
    
    //main VC vars
    fileprivate var addressBookStore: CNContactStore!
    fileprivate var menuArray: NSMutableArray?
    let picker = CNContactPickerViewController()
    var contacts: [CNContact]?
    var objects: [NSObject]?
    var contactIDs: [NSString]?
    var objectIDs: [NSString]?
    var objectPhoneNumbers = [NSString]()
    var contactPhoneNumbers = [NSString]()
    var NewOrAddedTripFromSegue: Int?
    var effect:UIVisualEffect!
    
    //calendar subview vars
    var firstDate: Date?
    let timesOfDayArray = ["Early morning (before 8am)","Morning (8am-11am)","Midday (11am-2pm)","Afternoon (2pm-5pm)","Evening (5pm-9pm)","Night (after 9pm)","Anytime"]
        
    var leftDates = [Date]()
    var rightDates = [Date]()
    var fullDates = [Date]()
    var lengthOfAvailabilitySegmentsArray = [Int]()
    var leftDateTimeArrays = NSMutableDictionary()
    var rightDateTimeArrays = NSMutableDictionary()
    var mostRecentSelectedCellDate = NSDate()

// MARK: Outlets
    
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var rejectIcon: UIButton!
    @IBOutlet weak var heartIcon: UIButton!
    @IBOutlet weak var groupMemberListTable: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var addFromContactsButton: UIButton!
    @IBOutlet weak var addFromFacebookButton: UIButton!
    @IBOutlet weak var soloForNowButton: UIButton!
    @IBOutlet weak var ranOutOfSwipesLabel: UILabel!
    @IBOutlet weak var contactsCollectionView: UICollectionView!
    @IBOutlet var homeAirportSubview: UIView!
    @IBOutlet var addContactsSubview: UIView!
    @IBOutlet var calendarSubview: UIView!
    @IBOutlet weak var popupBlurView: UIVisualEffectView!
    @IBOutlet weak var addContactPlusIconMainVC: UIButton!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var timeOfDayTableView: UITableView!
    @IBOutlet weak var popupBackgroundView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        homeAirportSubview.layer.cornerRadius = 5
        addContactsSubview.layer.cornerRadius = 5
        calendarSubview.layer.cornerRadius = 5
        
        //Calendar subview
        // Set up tap outside time of day table
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissPopup(touch:)))
        tap.numberOfTapsRequired = 1
        tap.delegate = self
        popupBackgroundView.addGestureRecognizer(tap)
        popupBackgroundView.isHidden = true
        
        //Time of Day
        timeOfDayTableView.delegate = self
        timeOfDayTableView.dataSource = self
        timeOfDayTableView.layer.cornerRadius = 5
        timeOfDayTableView.layer.isHidden = true
        timeOfDayTableView.allowsMultipleSelection = true
        
        // Calendar header setup
        calendarView.registerHeaderView(xibFileNames: ["monthHeaderView"])
        
        // Calendar setup delegate and datasource
        calendarView.dataSource = self as JTAppleCalendarViewDataSource
        calendarView.delegate = self as JTAppleCalendarViewDelegate
        calendarView.registerCellViewXib(file: "CellView")
        calendarView.allowsMultipleSelection  = true
        calendarView.rangeSelectionWillBeUsed = true
        calendarView.cellInset = CGPoint(x: 0, y: 2)
        calendarView.scrollingMode = .nonStopToSection(withResistance: 0.9)
        calendarView.direction = .horizontal
        
        //        //Multiple selection
        //        let panGensture = UILongPressGestureRecognizer(target: self, action: #selector(didStartRangeSelecting(gesture:)))
        //        panGensture.minimumPressDuration = 0.5
        //        calendarView.addGestureRecognizer(panGensture)
        
        
        // Load trip preferences and install
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let selectedDatesValue = SavedPreferencesForTrip["selected_dates"] as? [NSDate]
        if (selectedDatesValue?.count)! > 0 {
            self.calendarView.selectDates(selectedDatesValue! as [Date],triggerSelectionDelegate: false)
            //            nextButton.isHidden = false
            //            nextButton.isUserInteractionEnabled = true

        }
        //Main VC
        
        effect = popupBlurView.effect
        popupBlurView.effect = nil
        
        //Set Koloda delegate and View Controller
        kolodaView.dataSource = self as KolodaViewDataSource
        kolodaView.delegate = self as KolodaViewDelegate
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        
        heartIcon.setImage(#imageLiteral(resourceName: "fullHeart"), for: .highlighted)
        rejectIcon.setImage(#imageLiteral(resourceName: "fullX"), for: .highlighted)
        ranOutOfSwipesLabel.isHidden = true

//        if NewOrAddedTripFromSegue == 1 {
//            DataContainerSingleton.sharedDataContainer.currenttrip! += 1
//        }
//        //Update changed preferences as variables
//        NewOrAddedTripFromSegue = 0
        
//        let tripNameValue = Date().description as NSString
//        //Update trip preferences in dictionary
//        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
//        SavedPreferencesForTrip["trip_name"] = tripNameValue
//        //Save
//        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
        
        view.autoresizingMask = .flexibleTopMargin
        view.sizeToFit()
        
        self.hideKeyboardWhenTappedAround()
        addressBookStore = CNContactStore()
        
        // Set appearance of textfield
        
        if NewOrAddedTripFromSegue == 1 {
            DataContainerSingleton.sharedDataContainer.currenttrip! -= 1
            nextButton.alpha =  0
            contactsCollectionView.alpha = 0
            addContactPlusIconMainVC.alpha = 0
            
            let when = DispatchTime.now() + 1.5
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.animateInHomeAirportSubview()
            }
        } else {
            retrieveContactsWithStore(store: addressBookStore)

            //load trip preferences dictionary
//            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
//            let contactIDs = SavedPreferencesForTrip["contacts_in_group"] as! [NSString]

//            if contactIDs.count > 0  {
//            }
////
//        //Install the value into the label.
//        let tripNameValue = SavedPreferencesForTrip["trip_name"] as! NSString
//            
//        if tripNameValue == "" {
//                nextButton.alpha =  0
//            groupMemberListTable.alpha = 0
//            addFromContactsButton.alpha = 0
//        }
//        else {
//            nextButton.alpha = 1
//            groupMemberListTable.alpha = 1
//            addFromContactsButton.alpha = 1
//        }
            }
    }


    override func viewWillAppear(_ animated: Bool) {
    }
    
    //UITapGestureRecognizer
    func dismissPopup(touch: UITapGestureRecognizer) {
        if timeOfDayTableView.indexPathsForSelectedRows != nil {
            dismissTimeOfDayTableOut()
            
            let when = DispatchTime.now() + 0.6
            DispatchQueue.main.asyncAfter(deadline: when) {
                if self.leftDateTimeArrays.count == self.rightDateTimeArrays.count {
                    self.performSegue(withIdentifier: "calendarVCtoHomeairportVC", sender: nil)
                }
            }
        }
    }
    
//    func retrieveContactsWithStore(store: CNContactStore) {
//        let contactIDs = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString]
//        do {
//            if (contactIDs?.count)! > 0 {
//                let predicate = CNContact.predicateForContacts(withIdentifiers: contactIDs as! [String])
//                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey, CNContactImageDataAvailableKey] as [Any]
//                contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
//            } else {
//                contacts = nil
//            }
//            DispatchQueue.main.async (execute: { () -> Void in
//            })
//        } catch {
//            print(error)
//        }
//    }

    
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
//        var contactIDs = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString]
        
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
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            let addedRowIndexPath = [NSIndexPath(row: numberContactsInTable, section: 0)]
            self.contactsCollectionView.insertItems(at: addedRowIndexPath as [IndexPath])
            self.contactsCollectionView.reloadData()
            groupMemberListTable.insertRows(at: addedRowIndexPath as [IndexPath], with: .left)
            groupMemberListTable.reloadData()
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
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            let addedRowIndexPath = [IndexPath(row: 0, section: 0)]
            self.contactsCollectionView.insertItems(at: addedRowIndexPath)
            self.contactsCollectionView.reloadData()
            groupMemberListTable.insertRows(at: addedRowIndexPath, with: .left)
            groupMemberListTable.reloadData()
        }
        addFromContactsButton.layer.frame = CGRect(x: 101, y: 21, width: 148, height: 22)
        addFromFacebookButton.layer.frame = CGRect(x: 95, y: 61, width: 160, height: 22)
        soloForNowButton.alpha = 0
        groupMemberListTable.alpha = 1
        groupMemberListTable.layer.frame = CGRect(x: 29, y: 116, width: 292, height: 221)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
//        var contactIDs = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString]
        
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
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            let addedRowIndexPath = [IndexPath(row: numberContactsInTable, section: 0)]
            self.contactsCollectionView.insertItems(at: addedRowIndexPath)
            self.contactsCollectionView.reloadData()
            groupMemberListTable.insertRows(at: addedRowIndexPath as [IndexPath], with: .left)
            groupMemberListTable.reloadData()
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
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            let addedRowIndexPath = [IndexPath(row: 0, section: 0)]
            self.contactsCollectionView.insertItems(at: addedRowIndexPath)
            self.contactsCollectionView.reloadData()
            groupMemberListTable.insertRows(at: addedRowIndexPath, with: .left)
            groupMemberListTable.reloadData()
        }
        
        addFromContactsButton.layer.frame = CGRect(x: 101, y: 21, width: 148, height: 22)
        addFromFacebookButton.layer.frame = CGRect(x: 95, y: 61, width: 160, height: 22)
        soloForNowButton.alpha = 0
        groupMemberListTable.alpha = 1
        groupMemberListTable.layer.frame = CGRect(x: 29, y: 116, width: 292, height: 221)
    }
    
//saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
//        newTripNameTextField.resignFirstResponder()
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    // MARK: UITableviewdelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        
        if tableView == timeOfDayTableView {
            var numberOfRows = 7
        }
        if tableView == groupMemberListTable {
            if contacts != nil {
                numberOfRows += contacts!.count
            }
        }
        return numberOfRows
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == timeOfDayTableView {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timeOfDayPrototypeCell", for: indexPath) as! timeOfDayTableViewCell
        cell.timeOfDayTableLabel.text = timesOfDayArray[indexPath.row]
        return cell
        }
//        else if tableView == groupMemberListTable {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactsPrototypeCell", for: indexPath) as! contactsTableViewCell
        let contacts = objects as! [CNContact]?
        
        if contacts != nil {
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
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == timeOfDayTableView {
        let topRows = [IndexPath(row:0, section: 0),IndexPath(row:1, section: 0),IndexPath(row:2, section: 0),IndexPath(row:3, section: 0),IndexPath(row:4, section: 0),IndexPath(row:5, section: 0)]
        if indexPath == IndexPath(row:6, section: 0) {
            for rowIndex in topRows {
                self.timeOfDayTableView.deselectRow(at: rowIndex, animated: false)
            }
        }
        if topRows.contains(indexPath) {
            self.timeOfDayTableView.deselectRow(at: IndexPath(row:6, section:0), animated: false)
        }
        
        let selectedTimesOfDay = timeOfDayTableView.indexPathsForSelectedRows
        var availableTimeOfDayInCell = [String]()
        for indexPath in selectedTimesOfDay! {
            let cell = timeOfDayTableView.cellForRow(at: indexPath) as! timeOfDayTableViewCell
            availableTimeOfDayInCell.append(cell.timeOfDayTableLabel.text!)
        }
        let timeOfDayToAddToArray = availableTimeOfDayInCell.joined(separator: ", ") as NSString
        
        let cell = calendarView.cellStatus(for: mostRecentSelectedCellDate as Date)
        if cell?.selectedPosition() == .full || cell?.selectedPosition() == .left {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy MM dd"
            let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
            leftDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
        }
        if cell?.selectedPosition() == .right {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy MM dd"
            let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
            rightDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
        }
        
        //Update trip preferences in dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["origin_departure_times"] = leftDateTimeArrays as NSDictionary
        SavedPreferencesForTrip["return_departure_times"] = rightDateTimeArrays as NSDictionary
        //Save
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
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
            contacts?.remove(at: indexPath.row)
            contactIDs?.remove(at: indexPath.row)
            contactPhoneNumbers.remove(at: indexPath.row)
            
            groupMemberListTable.deleteRows(at: [indexPath], with: .left)
            contactsCollectionView.deleteItems(at: [indexPath])
            
            if objects?.count == 0 || objects == nil || contacts?.count == 0 || contacts == nil{
                addFromContactsButton.layer.frame = CGRect(x: 101, y: 150, width: 148, height: 22)
                addFromFacebookButton.layer.frame = CGRect(x: 95, y: 199, width: 160, height: 22)
                soloForNowButton.alpha = 1
                soloForNowButton.layer.frame = CGRect(x: 101, y: 248, width: 148, height: 22)
                groupMemberListTable.alpha = 0
            }
            
            //Update trip preferences dictionary
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["contacts_in_group"] = objectIDs
            SavedPreferencesForTrip["contact_phone_numbers"] = objectPhoneNumbers
            //Save updated trip preferences dictionary
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }
    
    func animateInHomeAirportSubview(){
        self.view.addSubview(homeAirportSubview)
        homeAirportSubview.center = self.view.center
        homeAirportSubview.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        homeAirportSubview.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.popupBlurView.effect = self.effect
            self.homeAirportSubview.alpha = 1
            self.homeAirportSubview.transform = CGAffineTransform.identity
        }
    }

    func HomeAirportSubViewToAddContactsSubview() {
        self.view.addSubview(addContactsSubview)
        addContactsSubview.center = self.view.center
        self.addContactsSubview.alpha = 1
        if contacts != nil {
            addFromContactsButton.layer.frame = CGRect(x: 101, y: 21, width: 148, height: 22)
            addFromFacebookButton.layer.frame = CGRect(x: 95, y: 61, width: 160, height: 22)
            soloForNowButton.alpha = 0
            groupMemberListTable.alpha = 1
            groupMemberListTable.layer.frame = CGRect(x: 29, y: 116, width: 292, height: 221)
        } else {
            addFromContactsButton.layer.frame = CGRect(x: 101, y: 150, width: 148, height: 22)
            addFromFacebookButton.layer.frame = CGRect(x: 95, y: 199, width: 160, height: 22)
            soloForNowButton.alpha = 1
            soloForNowButton.layer.frame = CGRect(x: 101, y: 248, width: 148, height: 22)
            groupMemberListTable.alpha = 0
        }
        
        self.homeAirportSubview.alpha = 0
        self.homeAirportSubview.removeFromSuperview()
    }

    func AddContactsSubViewToHomeAirportSubview() {
        self.view.addSubview(homeAirportSubview)
        homeAirportSubview.center = self.view.center
        self.homeAirportSubview.alpha = 1
        
        self.addContactsSubview.alpha = 0
        self.addContactsSubview.removeFromSuperview()
    }
    
    func AddContactsSubViewToCalendarSubview() {
        self.view.addSubview(calendarSubview)
        calendarSubview.center = self.view.center
        self.calendarSubview.alpha = 1
        
        self.addContactsSubview.alpha = 0
        self.addContactsSubview.removeFromSuperview()
    }
    
    func CalendarSubViewToAddContactsSubview() {
        self.view.addSubview(addContactsSubview)
        addContactsSubview.center = self.view.center
        self.addContactsSubview.alpha = 1
        if contacts != nil {
            addFromContactsButton.layer.frame = CGRect(x: 101, y: 21, width: 148, height: 22)
            addFromFacebookButton.layer.frame = CGRect(x: 95, y: 61, width: 160, height: 22)
            soloForNowButton.alpha = 0
            groupMemberListTable.alpha = 1
            groupMemberListTable.layer.frame = CGRect(x: 29, y: 116, width: 292, height: 221)
        } else {
            addFromContactsButton.layer.frame = CGRect(x: 101, y: 150, width: 148, height: 22)
            addFromFacebookButton.layer.frame = CGRect(x: 95, y: 199, width: 160, height: 22)
            soloForNowButton.alpha = 1
            soloForNowButton.layer.frame = CGRect(x: 101, y: 248, width: 148, height: 22)
            groupMemberListTable.alpha = 0
        }

        self.calendarSubview.alpha = 0
        self.calendarSubview.removeFromSuperview()
    }


    func animateOutCalendarSubview() {
        UIView.animate(withDuration: 0.3, animations: {
            self.calendarSubview.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.popupBlurView.effect = nil
            self.calendarSubview.alpha = 0
        }) { (Success:Bool) in
            self.calendarSubview.removeFromSuperview()
        }
    }


    //MARK: Actions
    @IBAction func nextButtonTouchedUpInside(_ sender: Any) {
        updateCompletionStatus()
    }

    @IBAction func addContact(_ sender: Any) {
        checkContactsAccess()
    }
    @IBAction func addFromContacts(_ sender: Any) {
        checkContactsAccess()
    }
    
    @IBAction func rejectSelected(_ sender: Any) {
        kolodaView?.swipe(.left)
    }
    
    @IBAction func heartSelected(_ sender: Any) {
        kolodaView?.swipe(.right)
    }
    @IBAction func homeAiportSubviewNextButtonTouchedUpInside(_ sender: Any) {
        HomeAirportSubViewToAddContactsSubview()
        if NewOrAddedTripFromSegue == 1 {
            DataContainerSingleton.sharedDataContainer.currenttrip! += 1
        }
        //Update changed preferences as variables
        NewOrAddedTripFromSegue = 0
        
        let tripNameValue = "Trip created \(Date().description.substring(to: 10) as NSString)" as NSString
        //Update trip preferences in dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["trip_name"] = tripNameValue
        //Save
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)

    }
    @IBAction func addContactsSubviewNextButtonTouchedUpInside(_ sender: Any) {
        AddContactsSubViewToCalendarSubview()
    }
    @IBAction func calendarSubviewNextButtonTouchedUpInside(_ sender: Any) {
        nextButton.alpha = 1
        contactsCollectionView.alpha = 1
        addContactPlusIconMainVC.alpha = 1
        animateOutCalendarSubview()
    }
    @IBAction func addContactsSubviewBackButtonTouchedUpInside(_ sender: Any) {
        AddContactsSubViewToHomeAirportSubview()
    }
    @IBAction func calendarSubviewBackButtonTouchedUpInside(_ sender: Any) {
        CalendarSubViewToAddContactsSubview()
    }
    @IBAction func goingSoloButtonTouchedUpInside(_ sender: Any) {
        AddContactsSubViewToCalendarSubview()
    }
    
    @IBAction func previousMonthTouchedUpInside(_ sender: Any) {
        calendarView.scrollToSegment(.previous)
    }
    @IBAction func nextMonthTouchedUpInside(_ sender: Any) {
        calendarView.scrollToSegment(.next)
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


// MARK: KolodaViewDelegate
extension NewTripNameViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        ranOutOfSwipesLabel.isHidden = false
        heartIcon.isHidden = true
        rejectIcon.isHidden = true
        
//        let when = DispatchTime.now() + 1
//        DispatchQueue.main.asyncAfter(deadline: when) {
//            self.performSegue(withIdentifier: "swipingVCtoRankingVC", sender: nil)
//        }
        
        //        let position = kolodaView.currentCardIndex
        //        for i in 1...4 {
        //            dataSource.append(UIImage(named: "Card_like_\(i)")!)
        //        }
        //        kolodaView.insertCardAtIndexRange(position..<position + 4, animated: true)
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
    }
    func koloda(_ koloda: KolodaView, draggedCardWithPercentage finishPercentage: CGFloat, in direction: SwipeResultDirection) {
        let when = DispatchTime.now() + 1
        
        if finishPercentage > 80 && (direction == SwipeResultDirection.bottomLeft || direction == SwipeResultDirection.left || direction == SwipeResultDirection.topLeft) && (direction != SwipeResultDirection.bottomRight || direction != SwipeResultDirection.right || direction != SwipeResultDirection.topRight) {
            rejectIcon.isHighlighted = true
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.rejectIcon.isHighlighted = false
            }
        }
        if finishPercentage > 80 && (direction == SwipeResultDirection.bottomRight || direction == SwipeResultDirection.right || direction == SwipeResultDirection.topRight) && (direction != SwipeResultDirection.bottomLeft || direction != SwipeResultDirection.left || direction != SwipeResultDirection.topLeft){
            heartIcon.isHighlighted = true
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.heartIcon.isHighlighted = false
            }
        }
    }
}

// MARK: KolodaViewDataSource
extension NewTripNameViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return dataSource.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        return UIImageView(image: dataSource[Int(index)])
    }
}

// MARK: JTCalendarView Extension
extension NewTripNameViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let startDate = Date()
        let endDate = formatter.date(from: "2017 12 31")
        let parameters = ConfigurationParameters(
            startDate: startDate,
            endDate: endDate!,
            numberOfRows: 6, // Only 1, 2, 3, & 6 are allowed
            calendar: Calendar.current,
            generateInDates: .forAllMonths,
            generateOutDates: .tillEndOfGrid,
            firstDayOfWeek: .sunday)
        return parameters
    }
    
    func handleSelection(cell: JTAppleDayCellView?, cellState: CellState) {
        let myCustomCell = cell as? CellView
        
        switch cellState.selectedPosition() {
        case .full:
            myCustomCell?.selectedView.isHidden = false
            myCustomCell?.dayLabel.textColor = UIColor(colorWithHexValue: 0x000000, alpha: 1)
            myCustomCell?.selectedView.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
            myCustomCell?.selectedView.layer.cornerRadius =  ((myCustomCell?.selectedView.frame.height)!/2)
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.leftSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
        case .left:
            myCustomCell?.selectedView.isHidden = false
            myCustomCell?.dayLabel.textColor = UIColor(colorWithHexValue: 0x000000, alpha: 1)
            myCustomCell?.selectedView.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
            myCustomCell?.selectedView.layer.cornerRadius =  ((myCustomCell?.selectedView.frame.height)!/2)
            myCustomCell?.rightSideConnector.isHidden = false
            myCustomCell?.leftSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
            
        case .right:
            myCustomCell?.selectedView.isHidden = false
            myCustomCell?.dayLabel.textColor = UIColor(colorWithHexValue: 0x000000, alpha: 1)
            myCustomCell?.selectedView.layer.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1).cgColor
            myCustomCell?.selectedView.layer.cornerRadius =  ((myCustomCell?.selectedView.frame.height)!/2)
            myCustomCell?.leftSideConnector.isHidden = false
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
            
        case .middle:
            myCustomCell?.selectedView.isHidden = true
            myCustomCell?.middleConnector.isHidden = false
            myCustomCell?.middleConnector.layer.backgroundColor = UIColor(colorWithHexValue: 0xFFFFFF, alpha: 0.33).cgColor
            myCustomCell?.dayLabel.textColor = UIColor(colorWithHexValue: 0xFFFFFF, alpha: 1)
            myCustomCell?.selectedView.layer.cornerRadius =  0
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.leftSideConnector.isHidden = true
        default:
            myCustomCell?.selectedView.isHidden = true
            myCustomCell?.selectedView.layer.backgroundColor = UIColor(colorWithHexValue: 0xFFFFFF, alpha: 0).cgColor
            myCustomCell?.leftSideConnector.isHidden = true
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
            myCustomCell?.dayLabel.textColor = UIColor(colorWithHexValue: 0xFFFFFF, alpha: 1)
        }
        if cellState.dateBelongsTo != .thisMonth {
            myCustomCell?.dayLabel.textColor = UIColor(colorWithHexValue: 0x656565, alpha: 1)
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        let myCustomCell = cell as! CellView
        myCustomCell.dayLabel.text = cellState.text
        
        handleSelection(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        if cellState.dateBelongsTo == .previousMonthWithinBoundary {
            calendarView.scrollToSegment(.previous)
        }
        if cellState.dateBelongsTo == .followingMonthWithinBoundary {
            calendarView.scrollToSegment(.next)
        }
        
        //UNCOMMENT FOR TWO CLICK RANGE SELECTION
        if firstDate != nil && firstDate! < date {
            if calendarView.cellStatus(for: firstDate!)?.selectedPosition() == .full {
                calendarView.selectDates(from: firstDate!, to: date,  triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
                firstDate = nil
            }
        }
        else {
            firstDate = date
        }
        
        //Spawn time of day selection
        
        let cellRow = cellState.row()
        let cellCol = cellState.column()
        var timeOfDayTable_X = cellCol * 50 + 39
        let timeOfDayTable_Y = cellRow * 50 + 145 + 2 * (cellRow - 1)
        if cellCol == 0 {
            timeOfDayTable_X = (cellCol + 1) * 50 + 39
        }
        if cellCol == 6 {
            timeOfDayTable_X = (cellCol - 1) * 50 + 39
        }
        
        if cellState.selectedPosition() == .left || cellState.selectedPosition() == .full {
            
            timeOfDayTableView.center = CGPoint(x: timeOfDayTable_X, y: timeOfDayTable_Y)
            animateTimeOfDayTableIn()
            
        }
        if cellState.selectedPosition() == .right {
            
            timeOfDayTableView.center = CGPoint(x: timeOfDayTable_X, y: timeOfDayTable_Y)
            animateTimeOfDayTableIn()
        }
        
        handleSelection(cell: cell, cellState: cellState)
        
        // Create array of selected dates
        let selectedDates = calendarView.selectedDates as [NSDate]
        getLengthOfSelectedAvailabilities()
        
        //Update trip preferences in dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["selected_dates"] = selectedDates
        SavedPreferencesForTrip["Availability_segment_lengths"] = lengthOfAvailabilitySegmentsArray as [NSNumber]
        //Save
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
        if selectedDates.count > 0 {
            //            nextButton.isHidden = false
            //            nextButton.isUserInteractionEnabled = true
        }
        
        mostRecentSelectedCellDate = date as NSDate
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleSelection(cell: cell, cellState: cellState)
        
        if cellState.dateBelongsTo == .previousMonthWithinBoundary {
            calendarView.scrollToSegment(.previous)
        }
        if cellState.dateBelongsTo == .followingMonthWithinBoundary {
            calendarView.scrollToSegment(.next)
        }
        
        // Create array of selected dates
        let selectedDates = calendarView.selectedDates as [NSDate]
        getLengthOfSelectedAvailabilities()
        
        //Update trip preferences in dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["selected_dates"] = selectedDates as [NSDate]
        SavedPreferencesForTrip["Availability_segment_lengths"] = lengthOfAvailabilitySegmentsArray as [NSNumber]
        //Save
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
        if selectedDates.count == 0 {
            //            nextButton.isHidden = true
            //            nextButton.isUserInteractionEnabled = false
        }
    }
    
    // MARK custom func to get length of selected availability segments
    func getLengthOfSelectedAvailabilities() {
        let selectedDates = calendarView.selectedDates as [NSDate]
        leftDates = []
        rightDates = []
        fullDates = []
        lengthOfAvailabilitySegmentsArray = []
        for date in selectedDates {
            if calendarView.cellStatus(for: date as Date)?.selectedPosition() == .left {
                leftDates.append(date as Date)
            }
        }
        for date in selectedDates {
            if calendarView.cellStatus(for: date as Date)?.selectedPosition() == .right {
                rightDates.append(date as Date)
            }
        }
        for date in selectedDates {
            if calendarView.cellStatus(for: date as Date)?.selectedPosition() == .full {
                fullDates.append(date as Date)
            }
        }
        if rightDates != [] {
            for segment in 0...rightDates.count - 1 {
                let segmentAvailability = rightDates[segment].timeIntervalSince(leftDates[segment]) / 86400 + 1
                lengthOfAvailabilitySegmentsArray.append(Int(segmentAvailability))
            }
        } else {
            lengthOfAvailabilitySegmentsArray = [1]
        }
    }
    
    // MARK: Calendar header functions
    // Sets the height of your header
    func calendar(_ calendar: JTAppleCalendarView, sectionHeaderSizeFor range: (start: Date, end: Date), belongingTo month: Int) -> CGSize {
        return CGSize(width: 349, height: 50)
    }
    // This setups the display of your header
    func calendar(_ calendar: JTAppleCalendarView, willDisplaySectionHeader header: JTAppleHeaderView, range: (start: Date, end: Date), identifier: String) {
        let headerCell = (header as! monthHeaderView)
        
        // Create Year String
        let yearDateFormatter = DateFormatter()
        yearDateFormatter.dateFormat = "yyyy"
        let YearHeader = yearDateFormatter.string(from: range.start)
        
        //C reate Month String
        let monthDateFormatter = DateFormatter()
        monthDateFormatter.dateFormat = "MM"
        let MonthHeader = monthDateFormatter.string(from: range.start)
        
        // Update header
        if MonthHeader == "01" {
            headerCell.monthLabel.text = "January " + YearHeader
        } else if MonthHeader == "02" {
            headerCell.monthLabel.text = "February " + YearHeader
        } else if MonthHeader == "03" {
            headerCell.monthLabel.text = "March " + YearHeader
        } else if MonthHeader == "04" {
            headerCell.monthLabel.text = "April " + YearHeader
        } else if MonthHeader == "05" {
            headerCell.monthLabel.text = "May " + YearHeader
        } else if MonthHeader == "06" {
            headerCell.monthLabel.text = "June " + YearHeader
        } else if MonthHeader == "07" {
            headerCell.monthLabel.text = "July " + YearHeader
        } else if MonthHeader == "08" {
            headerCell.monthLabel.text = "August " + YearHeader
        } else if MonthHeader == "09" {
            headerCell.monthLabel.text = "September " + YearHeader
        } else if MonthHeader == "10" {
            headerCell.monthLabel.text = "October " + YearHeader
        } else if MonthHeader == "11" {
            headerCell.monthLabel.text = "November " + YearHeader
        } else if MonthHeader == "12" {
            headerCell.monthLabel.text = "December " + YearHeader
        }
    }
    
    func animateTimeOfDayTableIn(){
        timeOfDayTableView.layer.isHidden = false
        timeOfDayTableView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        timeOfDayTableView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.popupBackgroundView.isHidden = false
            self.timeOfDayTableView.alpha = 1
            self.timeOfDayTableView.transform = CGAffineTransform.identity
        }
    }
    
    func dismissTimeOfDayTableOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.timeOfDayTableView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.timeOfDayTableView.alpha = 0
            let selectedRows = self.timeOfDayTableView.indexPathsForSelectedRows
            self.popupBackgroundView.isHidden = true
            for rowIndex in selectedRows! {
                self.timeOfDayTableView.deselectRow(at: rowIndex, animated: false)
            }
        }) { (Success:Bool) in
            self.timeOfDayTableView.layer.isHidden = true
        }
    }
}

extension UIColor {
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0){
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
