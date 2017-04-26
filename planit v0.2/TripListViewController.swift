//
//  TripList.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/11/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit

class TripListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var existingTripsTable: UITableView!
    @IBOutlet weak var createTripButton: UIButton!
    @IBOutlet weak var addAnotherTripButton: UIButton!
    @IBOutlet weak var myTripsTitleLabel: UILabel!
    @IBOutlet weak var createTripArrow: UIButton!
    @IBOutlet weak var greyMap: UIImageView!
    
    // Outlets for instructions
    @IBOutlet weak var instructionsTitleLabel: UILabel!
    @IBOutlet weak var destinationDecidedControlView: UIView!
    @IBOutlet weak var destinationDecidedControl: UISegmentedControl!
    @IBOutlet weak var popupBackgroundView: UIView!
    @IBOutlet weak var tbdColorView: UIView!
    @IBOutlet weak var tbdLabel: UILabel!
    @IBOutlet weak var bucketListColorView: UIView!
    @IBOutlet weak var bucketListLabel: UILabel!
    @IBOutlet weak var beenThereColorView: UIView!
    @IBOutlet weak var beenThereLabel: UILabel!
    
    let sectionTitles = ["Still in the works...", "Booked"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set up tap outside time of day table
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissPopup(touch:)))
        tap.numberOfTapsRequired = 1
        tap.delegate = self
        popupBackgroundView.isHidden = true
        self.popupBackgroundView.addGestureRecognizer(tap)
        
        //Rotate segmented control view
        destinationDecidedControl.transform =  CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        for segment in self.destinationDecidedControl.subviews {
            for segmentSubview in segment.subviews {
                if segmentSubview is UILabel {
                    (segmentSubview as! UILabel).transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
                }
            }
        }
        destinationDecidedControl.frame = CGRect(x: 23, y: 59, width: 150, height: 65)
        destinationDecidedControlView.frame = CGRect(x: 167, y: 430, width: 196, height: 135)

        destinationDecidedControlView.isHidden = true
        destinationDecidedControlView.layer.cornerRadius = 10
        
        view.autoresizingMask = .flexibleTopMargin
        view.sizeToFit()
        
        if DataContainerSingleton.sharedDataContainer.usertrippreferences == nil || DataContainerSingleton.sharedDataContainer.usertrippreferences?.count == 0 {
            
            DataContainerSingleton.sharedDataContainer.currenttrip = 0
            
            myTripsTitleLabel.isHidden = true
            existingTripsTable.isHidden = true
            addAnotherTripButton.isHidden = true
            
            createTripButton.isHidden = false
            createTripArrow.isHidden = false
            instructionsTitleLabel.isHidden = false
            greyMap.isHidden = false
            tbdLabel.isHidden = false
            tbdColorView.isHidden = false
            bucketListLabel.isHidden = false
            bucketListColorView.isHidden = false
            beenThereLabel.isHidden = false
            beenThereColorView.isHidden = false
            }
        else {
            existingTripsTable.isHidden = false
            existingTripsTable.tableFooterView = UIView()
            existingTripsTable.layer.cornerRadius = 5
            addAnotherTripButton.isHidden = false
            
            createTripButton.isHidden = true
            createTripArrow.isHidden = true
            instructionsTitleLabel.isHidden = true
            greyMap.isHidden = true
            tbdLabel.isHidden = true
            tbdColorView.isHidden = true
            bucketListLabel.isHidden = true
            bucketListColorView.isHidden = true
            beenThereLabel.isHidden = true
            beenThereColorView.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func dismissPopup(touch: UITapGestureRecognizer) {
            popupBackgroundView.isHidden = true
            destinationDecidedControlView.isHidden = true
    }

    
    // MARK: Actions
    @IBAction func addTrip(_ sender: Any) {
        DataContainerSingleton.sharedDataContainer.currenttrip = DataContainerSingleton.sharedDataContainer.currenttrip! + 1

        popupBackgroundView.isHidden = false
        destinationDecidedControlView.isHidden = false
        destinationDecidedControlView.frame = CGRect(x: 167, y: 71, width: 196, height: 135)
    }
    
    @IBAction func createTripButtonTouchDown(_ sender: Any) {
        createTripArrow.isHighlighted = true
    }
 
    @IBAction func createFirstTripButtonTouchedUpInside(_ sender: Any) {
        DataContainerSingleton.sharedDataContainer.currenttrip = 0
        
        createTripArrow.isHighlighted = false
        popupBackgroundView.isHidden = false
        destinationDecidedControlView.isHidden = false
        destinationDecidedControlView.frame = CGRect(x: 167, y: 430, width: 196, height: 135)
    }
    @IBAction func createFirstTripArrowTouchedUpInside(_ sender: Any) {
        destinationDecidedControlView.isHidden = false
        destinationDecidedControlView.frame = CGRect(x: 167, y: 430, width: 196, height: 135)
    }
    
    @IBAction func destinationDecidedControlValueChanged(_ sender: Any) {
        if destinationDecidedControl.selectedSegmentIndex == 0 {
            self.performSegue(withIdentifier: "addTripDestinationUndecided", sender: self)
        }
    }
    
    // # sections in table
    func numberOfSections(in tableView: UITableView) -> Int {
        let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        if existing_trips == nil {
            return 0
        }
        else {
        return 2
        }
    }
    
    // Section Header
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var bookingStatuses: [Int] = []
        
        if (DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! > 0 {
            for index in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
                let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[index].object(forKey: "booking_status") as? Int
                if bookingStatus != nil {
                    bookingStatuses.append(bookingStatus!)
                }
            }
            
            var countTripsBooked = 0
            var countTripsUnbooked = 0
            var countTripsTotal = 0
            
            if bookingStatuses != [] {
                for index in 0...(bookingStatuses.count - 1) {
                    countTripsBooked += bookingStatuses[index]
                }
            }
            
            if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && section == 1 && countTripsBooked > 0 {
                if countTripsBooked > 0 {
                    return sectionTitles[section]
                }
            }
            if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && section == 0 && bookingStatuses != [] {

                countTripsTotal = (DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)!
                
                countTripsUnbooked = countTripsTotal - countTripsBooked
                
                if countTripsUnbooked > 0 {
                    return sectionTitles[section]
                }
            }
        }
        return ""
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: existingTripsTable.bounds.size.width, height: 30))
        header.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        header.layer.cornerRadius = 5

        let title = UILabel()
        title.frame = header.frame
        title.textAlignment = .left
        title.font = UIFont.boldSystemFont(ofSize: 20)
        title.textColor = UIColor.white
        title.text = sectionTitles[section]
        header.addSubview(title)

        return header
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! > 0 {

            var bookingStatuses: [Int] = []
            for index in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
                let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[index].object(forKey: "booking_status") as? Int
                if bookingStatus != nil {
                    bookingStatuses.append(bookingStatus!)
                }
            }
            
            var countTripsBooked = 0
            var countTripsUnbooked = 0
            var countTripsTotal = 0
            
            if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && section == 1 && bookingStatuses != [] {
                for index in 0...(bookingStatuses.count - 1) {
                    countTripsBooked += bookingStatuses[index]
                }
                return countTripsBooked
            }
            // else if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && section == 0 {
            if bookingStatuses != [] {
                for index in 0...(bookingStatuses.count - 1) {
                    countTripsBooked += bookingStatuses[index]
                }
            }
            countTripsTotal = (DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)!
            countTripsUnbooked = countTripsTotal - countTripsBooked
            
            return countTripsUnbooked
        
        }
        
        return 0
    }
    
    var lastUnbookedStatusIndexAddedToTable: Int?
    var lastBookedStatusIndexAddedToTable: Int?
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if lastUnbookedStatusIndexAddedToTable == nil {
            lastUnbookedStatusIndexAddedToTable = -1
        }
        if lastBookedStatusIndexAddedToTable == nil {
            lastBookedStatusIndexAddedToTable = -1
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "existingTripViewPrototypeCell", for: indexPath) as! ExistingTripTableViewCell
        
        var bookingStatuses: [Int] = []
        for index in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
            
            let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[index].object(forKey: "booking_status") as? Int
            if bookingStatus != nil {
            bookingStatuses.append(bookingStatus!)
            }
        }
        
        if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && indexPath.section == 0 && bookingStatuses != [] {
            for unbookedIndex in 0...(bookingStatuses.count - 1)  {
                if bookingStatuses[unbookedIndex] == 0 && unbookedIndex > lastUnbookedStatusIndexAddedToTable! {
                    let addedRowInUnbookedSection = unbookedIndex
                    cell.layer.cornerRadius = 10
                    cell.layer.borderWidth = 3
                    cell.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:1).cgColor
                    cell.layer.masksToBounds = true

//                    cell.existingTripTableViewImage.image = #imageLiteral(resourceName: "NYE")
                    cell.existingTripTableViewLabel.text = DataContainerSingleton.sharedDataContainer.usertrippreferences?[addedRowInUnbookedSection].object(forKey: "trip_name") as? String
                    existingTripsTable.isHidden = false
                    lastUnbookedStatusIndexAddedToTable = unbookedIndex
                    
                    return cell
                }
            }
        }
        else if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && indexPath.section == 1 && bookingStatuses != [] {
            for bookedIndex in 0...(bookingStatuses.count - 1)  {
                if bookingStatuses[bookedIndex] == 1 && bookedIndex > lastBookedStatusIndexAddedToTable!{
                    let addedRowInBookedSection = bookedIndex
                    cell.layer.cornerRadius = 5
                    cell.existingTripTableViewImage.image = #imageLiteral(resourceName: "NYE")
                    cell.existingTripTableViewLabel.text = DataContainerSingleton.sharedDataContainer.usertrippreferences?[addedRowInBookedSection].object(forKey: "trip_name") as? String
                    existingTripsTable.isHidden = false
                    lastBookedStatusIndexAddedToTable = bookedIndex
                    
                    return cell
                }
            }
        }
        // if  == nil {
            existingTripsTable.isHidden = true
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath as IndexPath) as! ExistingTripTableViewCell
        let searchForTitle = cell.existingTripTableViewLabel.text

        for trip in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
            if DataContainerSingleton.sharedDataContainer.usertrippreferences?[trip].object(forKey: "trip_name") as? String == searchForTitle {
                DataContainerSingleton.sharedDataContainer.currenttrip = trip
            }
        }
        
        let finishedEnteringPreferencesStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "finished_entering_preferences_status") as? NSString ?? NSString()
        let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "booking_status") as? NSNumber ?? NSNumber()

//        if finishedEnteringPreferencesStatus == "Name_Contacts_Rooms" && bookingStatus == 0 {
//            self.performSegue(withIdentifier: "unfinishedExistingTripsToCalendar", sender: self)
//        } else if finishedEnteringPreferencesStatus == "Calendar"  && bookingStatus == 0 {
//            self.performSegue(withIdentifier: "unfinishedExistingTripsToDestination", sender: self)
//        } else if finishedEnteringPreferencesStatus == "Destination"  && bookingStatus == 0 {
//            self.performSegue(withIdentifier: "unfinishedExistingTripsToBudget", sender: self)
//        } else if finishedEnteringPreferencesStatus == "Budget"  && bookingStatus == 0 {
//            self.performSegue(withIdentifier: "unfinishedExistingTripsToActivities", sender: self)
//        } else if (finishedEnteringPreferencesStatus == "Activities" || finishedEnteringPreferencesStatus == "Swiping" || finishedEnteringPreferencesStatus == "Ranking")  && bookingStatus == 0 {
//            self.performSegue(withIdentifier: "FinishedExistingTripsToUnbookedSummary", sender: self)
//        } else {
            self.performSegue(withIdentifier: "unfinishedExistingTripsToSwiping", sender: self)
//        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "addTripDestinationUndecided" {
            let destination = segue.destination as? NewTripNameViewController
            
            var NewOrAddedTripForSegue = Int()
            
            let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
            let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
            var numberSavedTrips: Int?
            if existing_trips == nil {
                numberSavedTrips = 0
                NewOrAddedTripForSegue = 1
            } else {
                numberSavedTrips = (existing_trips?.count)! - 1
                if currentTripIndex <= numberSavedTrips! {
                    NewOrAddedTripForSegue = 0
                } else {
                    NewOrAddedTripForSegue = 1
                }
            }
            destination?.NewOrAddedTripFromSegue = NewOrAddedTripForSegue
        }
    }

    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }

    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            self.existingTripsTable.rowHeight = 90


            let cell = tableView.cellForRow(at: indexPath as IndexPath) as! ExistingTripTableViewCell
            let searchForTitle = cell.existingTripTableViewLabel.text
            
            for trip in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
                if DataContainerSingleton.sharedDataContainer.usertrippreferences?[trip].object(forKey: "trip_name") as? String == searchForTitle {
                    
                    //Remove from data model
                    DataContainerSingleton.sharedDataContainer.usertrippreferences?.remove(at: trip)
                    
                    //Remove from table
                    existingTripsTable.beginUpdates()
                    existingTripsTable.deleteRows(at: [indexPath], with: .left)
            
                    if existingTripsTable.numberOfRows(inSection: 0) == 0 && existingTripsTable.numberOfRows(inSection: 1) != 0{
                    //delete header
                    }
                    if existingTripsTable.numberOfRows(inSection: 0) != 0 && existingTripsTable.numberOfRows(inSection: 1) == 0{
                    //delete header
                    }
                    existingTripsTable.endUpdates()

                    if (DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! == 0 {
                        myTripsTitleLabel.isHidden = true
                        existingTripsTable.isHidden = true
                        addAnotherTripButton.isHidden = true
                        
                        createTripButton.isHidden = false
                        createTripArrow.isHidden = false
                        instructionsTitleLabel.isHidden = false
                        greyMap.isHidden = false
                        tbdLabel.isHidden = false
                        tbdColorView.isHidden = false
                        bucketListLabel.isHidden = false
                        bucketListColorView.isHidden = false
                        beenThereLabel.isHidden = false
                        beenThereColorView.isHidden = false
                    }
                    //Return if delete cell trip name found
                    return
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }

}
