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

class CalendarViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    //MARK: Outlets
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var multipleDestinations: UISegmentedControl!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var multipleDestinationsQuestionLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var timeOfDayTableView: UITableView!
    @IBOutlet weak var popupBackgroundView: UIView!
    
    var firstDate: Date?
    let timesOfDayArray = ["Early morning (12am-5am)","Morning (5am-11am)","Midday (11pm-5pm)","Night (5pm-12am)","Anytime"]
    var leftDates = [Date]()
    var rightDates = [Date]()
    var fullDates = [Date]()
    var lengthOfAvailabilitySegmentsArray = [Int]()
    
    //Load the values from our shared data container singleton: Multiple Destination Picker
    var multipleDestinationsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "multiple_destinations") as? String
    
    // Variable for asking question regarding multiple destinations
    var minimumConsecutiveDaysForMultipleDestinations = 5
    
       override func viewDidLoad() {
        super.viewDidLoad()
        
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
        nextButton.isHidden = true
        nextButton.isUserInteractionEnabled = false
        popupBackgroundView.isHidden = true
        
        // Disable multiple destinations control by default
        multipleDestinations.isHidden = true
        multipleDestinations.isUserInteractionEnabled = false
        multipleDestinationsQuestionLabel.isHidden = true
        
        // Calendar header setup
        calendarView.registerHeaderView(xibFileNames: ["monthHeaderView"])
        
        // Calendar setup delegate and datasource
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.registerCellViewXib(file: "CellView")
        calendarView.allowsMultipleSelection  = true
        calendarView.rangeSelectionWillBeUsed = true
        calendarView.cellInset = CGPoint(x: 0, y: 2)
        calendarView.scrollingMode = .nonStopToSection(withResistance: 0.5)
        calendarView.direction = .horizontal
        
        // Load Calendar dates and install
        let selectedDatesValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [Date]
        if selectedDatesValue != nil {
            self.calendarView.selectDates(selectedDatesValue!,triggerSelectionDelegate: false)
            nextButton.isHidden = false
            nextButton.isUserInteractionEnabled = true
        }

        //Load the values from our shared data container singleton: Trip Name
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        
        //Install the value into the label.
        if tripNameValue != nil {
        self.tripNameLabel.text =  "\(tripNameValue!)"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Install the value into the label.
        if multipleDestinationsValue == "Yes" {
            multipleDestinations.selectedSegmentIndex = 0
        }
        else if multipleDestinationsValue == "No" {
            multipleDestinations.selectedSegmentIndex = 1
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //UITapGestureRecognizer
    func dismissPopup(touch: UITapGestureRecognizer) {
        if timeOfDayTableView.indexPathsForSelectedRows != nil {
        dismissTimeOfDayTableOut()
        }
    }
    
    // Table for time of day
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "timeOfDayPrototypeCell", for: indexPath) as! timeOfDayTableViewCell
        cell.timeOfDayTableLabel.text = timesOfDayArray[indexPath.row]
        
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let topRows = [IndexPath(row:0, section: 0),IndexPath(row:1, section: 0),IndexPath(row:2, section: 0),IndexPath(row:3, section: 0)]
        if indexPath == IndexPath(row:4, section: 0) {
            for rowIndex in topRows {
                self.timeOfDayTableView.deselectRow(at: rowIndex, animated: false)
            }
        }
        if topRows.contains(indexPath) {
            self.timeOfDayTableView.deselectRow(at: IndexPath(row:4, section:0), animated: false)
        }
    }
    
    // MARK: Actions
    @IBAction func multipleDestinationsValueChanged(_ sender: Any) {
        if multipleDestinations.selectedSegmentIndex == 0 {
            multipleDestinationsValue = "Yes"
        }
        else {
            multipleDestinationsValue = "No"
        }
        
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
        let selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [Date]
        let hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? Float
        let lengthOfAvailabilitySegmentsArray = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "Availability_segment_lengths") as? [Int]

        let updatedTripToBeSaved = ["trip_name": tripNameValue, "multiple_destinations": multipleDestinationsValue, "selected_dates": selectedDates, "contacts_in_group": contacts,"hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": lengthOfAvailabilitySegmentsArray] as [String : Any]
        existing_trips?[currentTripIndex] = updatedTripToBeSaved as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
    }
    
    @IBAction func previousMonthPressed(_ sender: Any) {
        calendarView.scrollToSegment(.previous)
    }
    
    @IBAction func nextMonthPressed(_ sender: Any) {
        calendarView.scrollToSegment(.next)
    }
    
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

//        // Enable Multiple Destinations Question if more than 3 middles (Total)
//        if  >= minimumConsecutiveDaysForMultipleDestinations {
//            multipleDestinations.isHidden = false
//            multipleDestinations.isUserInteractionEnabled = true
//            multipleDestinationsQuestionLabel.isHidden = false
//        }
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
        let selectedDates = calendarView.selectedDates
        
        getLengthOfSelectedAvailabilities()
        
        // Save array of selected activities to trip data model
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
        let multipleDestionationsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "multiple_destinations") as? String
        let hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? Float
        
        let updatedTripToBeSaved = ["trip_name": tripNameValue, "multiple_destinations": multipleDestionationsValue, "selected_dates": selectedDates, "contacts_in_group": contacts, "Availability_segment_lengths": lengthOfAvailabilitySegmentsArray, "hotel_rooms": hotelRoomsValue] as [String : Any]
        existing_trips?[currentTripIndex] = updatedTripToBeSaved as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
        
        if selectedDates.count > 0 {
            nextButton.isHidden = false
            nextButton.isUserInteractionEnabled = true
        }
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
        let selectedDates = calendarView.selectedDates
        
        getLengthOfSelectedAvailabilities()
        
        // Save array of selected activities to trip data model
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
        let multipleDestionationsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "multiple_destinations") as? String
        let hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? Float

        
        let updatedTripToBeSaved = ["trip_name": tripNameValue, "multiple_destinations": multipleDestionationsValue, "selected_dates": selectedDates, "contacts_in_group": contacts, "Availability_segment_lengths": lengthOfAvailabilitySegmentsArray,"hotel_rooms": hotelRoomsValue] as [String : Any]
        existing_trips?[currentTripIndex] = updatedTripToBeSaved as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
        
        if selectedDates.count == 0 {
            nextButton.isHidden = true
            nextButton.isUserInteractionEnabled = false
        }
    }
    
    // MARK custom func to get length of selected availability segments
    func getLengthOfSelectedAvailabilities() {
        let selectedDates = calendarView.selectedDates
        leftDates = []
        rightDates = []
        fullDates = []
        lengthOfAvailabilitySegmentsArray = []
        for date in selectedDates {
            if calendarView.cellStatus(for: date)?.selectedPosition() == .left {
                leftDates.append(date)
            }
        }
        for date in selectedDates {
            if calendarView.cellStatus(for: date)?.selectedPosition() == .right {
                rightDates.append(date)
            }
        }
        for date in selectedDates {
            if calendarView.cellStatus(for: date)?.selectedPosition() == .full {
                fullDates.append(date)
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
