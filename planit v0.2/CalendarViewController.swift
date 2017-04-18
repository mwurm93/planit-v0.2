//
//  CalendarViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/17/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit
import JTAppleCalendar
import Contacts

class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    //MARK: Outlets
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var timeOfDayTableView: UITableView!
    @IBOutlet weak var popupBackgroundView: UIView!
    @IBOutlet weak var contactsCollectionView: UICollectionView!
    
    var firstDate: Date?
    let timesOfDayArray = ["Early morning (before 8am)","Morning (8am-11am)","Midday (11am-2pm)","Afternoon (2pm-5pm)","Evening (5pm-9pm)","Night (after 9pm)","Anytime"]
    
    // Set up vars for Contacts - COPY
    var contacts: [CNContact]?
    var contactIDs: [NSString]?
    fileprivate var addressBookStore: CNContactStore!
    
    var leftDates = [Date]()
    var rightDates = [Date]()
    var fullDates = [Date]()
    var lengthOfAvailabilitySegmentsArray = [Int]()
    var leftDateTimeArrays = NSMutableDictionary()
    var rightDateTimeArrays = NSMutableDictionary()
    var mostRecentSelectedCellDate = NSDate()
    
       override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize address book - COPY
        addressBookStore = CNContactStore()

        // Set up tap outside time of day table
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissPopup(touch:)))
        tap.numberOfTapsRequired = 1
        tap.delegate = self
        popupBackgroundView.addGestureRecognizer(tap)
        
        //Time of Day
        timeOfDayTableView.delegate = self
        timeOfDayTableView.dataSource = self
        timeOfDayTableView.layer.cornerRadius = 5
        timeOfDayTableView.layer.isHidden = true
        timeOfDayTableView.allowsMultipleSelection = true
        
        //Hide next button
//        nextButton.isHidden = true
//        nextButton.isUserInteractionEnabled = false
        popupBackgroundView.isHidden = true
        
        // Calendar header setup
        calendarView.registerHeaderView(xibFileNames: ["monthHeaderView"])
        
        // Calendar setup delegate and datasource
        calendarView.dataSource = self
        calendarView.delegate = self
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
        let tripNameValue = SavedPreferencesForTrip["trip_name"] as? NSString
        //Install the value into the label.
        if tripNameValue != "" {
            self.tripNameLabel.text =  "\(tripNameValue!)"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    // Table for time of day
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "timeOfDayPrototypeCell", for: indexPath) as! timeOfDayTableViewCell
        cell.timeOfDayTableLabel.text = timesOfDayArray[indexPath.row]
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    // MARK: Actions
    @IBAction func previousMonthPressed(_ sender: Any) {
        calendarView.scrollToSegment(.previous)
    }
    
    @IBAction func nextMonthPressed(_ sender: Any) {
        calendarView.scrollToSegment(.next)
    }
    @IBAction func nextButtonPressed(_ sender: Any) {
        // Change preferences finished status
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["finished_entering_preferences_status"] = "Calendar" as NSString
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    ///////////////////////////////////COLLECTION VIEW/////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////
    // Fetch Contacts
    func retrieveContactsWithStore(store: CNContactStore) {
        contactIDs = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString]
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
            
            // Create date lists and color array
            let sampleContactDateList_1 = calendarView.visibleDates().monthDates
            let sampleContactDateList_2 = calendarView.visibleDates().monthDates
            let sampleContactDateList_3 = calendarView.visibleDates().monthDates
            let sampleContactDateList_4 = calendarView.visibleDates().monthDates
            let sampleContactDateList_5 = calendarView.visibleDates().monthDates
            let sampleContactDateList_6 = calendarView.visibleDates().monthDates
            let sampleContactDateList_7 = calendarView.visibleDates().monthDates
            let sampleContactDateLists = [sampleContactDateList_1, sampleContactDateList_2,sampleContactDateList_3,sampleContactDateList_4,sampleContactDateList_5,sampleContactDateList_6,sampleContactDateList_7]

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

            calendarView.deselectAllDates(triggerSelectionDelegate: false)
            calendarView.selectDates(sampleContactDateLists[indexPath.row],triggerSelectionDelegate: false)
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
            
            calendarView.deselectAllDates(triggerSelectionDelegate: false)
            let selectedDatesValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [NSDate]
            if selectedDatesValue != nil {
                self.calendarView.selectDates(selectedDatesValue! as [Date],triggerSelectionDelegate: false)
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
        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus,"finished_entering_preferences_status": finishedEnteringPreferencesStatus, "trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips] as NSMutableDictionary
        
        return fetchedSavedPreferencesForTrip
    }
    func saveUpdatedExistingTrip(SavedPreferencesForTrip: NSMutableDictionary) {
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        existing_trips?[currentTripIndex] = SavedPreferencesForTrip as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
    }
//UNCOMMENT FOR MULTIPLE SELECTION DATE PICKER
//    var rangeSelectedDates: [Date] = []
//    func didStartRangeSelecting(gesture: UILongPressGestureRecognizer) {
//        let point = gesture.location(in: gesture.view!)
////        rangeSelectedDates = calendarView.selectedDates
//        if let cellState = calendarView.cellStatus(at: point) {
//            let date = cellState.date
//            if !rangeSelectedDates.contains(date) {
//                if firstDate != nil && firstDate! < date {
//                    let dateRange = calendarView.generateDateRange(from: firstDate ?? date, to: date)
//                    for aDate in dateRange {
//                        if !rangeSelectedDates.contains(aDate) {
//                            rangeSelectedDates.append(aDate)
//                        }
//                    }
//                } else {
//                    firstDate = date
//                }
//                
//                calendarView.selectDates(from: firstDate!, to: date, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
//            } else {
//                let indexOfNewlySelectedDate = rangeSelectedDates.index(of: date)! + 1
//                let lastIndex = rangeSelectedDates.endIndex
//                let testCalendar = Calendar.current
//                let followingDay = testCalendar.date(byAdding: .day, value: 1, to: date)!
//                calendarView.selectDates(from: followingDay, to: rangeSelectedDates.last!, triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: false)
//                rangeSelectedDates.removeSubrange(indexOfNewlySelectedDate..<lastIndex)
//            }
//
////            handleSelection(cell: cell, cellState: cellState)
//            
//            // Create array of selected dates
//            let selectedDates = calendarView.selectedDates as [NSDate]
//            getLengthOfSelectedAvailabilities()
//            
//            //Update trip preferences in dictionary
//            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
//            SavedPreferencesForTrip["selected_dates"] = selectedDates
//            SavedPreferencesForTrip["Availability_segment_lengths"] = lengthOfAvailabilitySegmentsArray as [NSNumber]
//            //Save
//            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
//            
//            if selectedDates.count > 0 {
//                nextButton.isHidden = false
//                nextButton.isUserInteractionEnabled = true
//            }
//        }
//        
//        if gesture.state == .ended {
//            //Get times to travel
//            for date in rangeSelectedDates {
//                let cellState = calendarView.cellStatus(for: date)
//                if cellState?.selectedPosition() == .left {
//                    let cellRow = cellState?.row()
//                    let cellCol = cellState?.column()
//                    var timeOfDayTable_X = cellCol! * 50 + 39
//                    let timeOfDayTable_Y = cellRow! * 50 + 145 + 2 * (cellRow! - 1)
//                    if cellCol == 0 {
//                        timeOfDayTable_X = (cellCol! + 1) * 50 + 39
//                    }
//                    if cellCol == 6 {
//                        timeOfDayTable_X = (cellCol! - 1) * 50 + 39
//                    }
//                    timeOfDayTableView.center = CGPoint(x: timeOfDayTable_X, y: timeOfDayTable_Y)
//                    animateTimeOfDayTableIn()
//                }
//            }
//            for date in rangeSelectedDates {
//                let cellState = calendarView.cellStatus(for: date)
//                if cellState?.selectedPosition() == .left {
//                    let cellRow = cellState?.row()
//                    let cellCol = cellState?.column()
//                    var timeOfDayTable_X = cellCol! * 50 + 39
//                    let timeOfDayTable_Y = cellRow! * 50 + 145 + 2 * (cellRow! - 1)
//                    if cellCol == 0 {
//                        timeOfDayTable_X = (cellCol! + 1) * 50 + 39
//                    }
//                    if cellCol == 6 {
//                        timeOfDayTable_X = (cellCol! - 1) * 50 + 39
//                    }
//                    timeOfDayTableView.center = CGPoint(x: timeOfDayTable_X, y: timeOfDayTable_Y)
//                    animateTimeOfDayTableIn()
//                }
//            }
//            //Reset segment range and first date vars
//            rangeSelectedDates.removeAll()
//            firstDate = nil
//
//        }
//    }
}

// MARK: JTCalendarView Extension
extension CalendarViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {

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
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
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
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
                
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
