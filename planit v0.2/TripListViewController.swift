//
//  TripList.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/11/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit

class TripListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Outlets
    @IBOutlet weak var existingTripsTable: UITableView!
    @IBOutlet weak var createTripButton: UIButton!
    @IBOutlet weak var addAnotherTripButton: UIButton!
    @IBOutlet weak var myTripsTitleLabel: UILabel!
    @IBOutlet weak var createTripArrow: UIButton!
    
    // Outlets for instructions
    @IBOutlet weak var instructionsTitleLabel: UILabel!
    @IBOutlet weak var instruct1Label: UILabel!
    @IBOutlet weak var instruct2Label: UILabel!
    @IBOutlet weak var instruct3Label: UILabel!
    @IBOutlet weak var instruct4Label: UILabel!
    @IBOutlet weak var instruct5Label: UILabel!
    @IBOutlet weak var instruct1image: UIImageView!
    @IBOutlet weak var instruct2image: UIImageView!
    @IBOutlet weak var instruct3image: UIImageView!
    @IBOutlet weak var instruct4image: UIImageView!
    
    @IBOutlet weak var instruct5image: UIImageView!
    let sectionTitles = ["Still in the works...", "Booked and ticketed"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if DataContainerSingleton.sharedDataContainer.usertrippreferences == nil {
            
            DataContainerSingleton.sharedDataContainer.currenttrip = 0
            
            myTripsTitleLabel.isHidden = true
            existingTripsTable.isHidden = true
            addAnotherTripButton.isHidden = true
            
            createTripButton.isHidden = false
            createTripArrow.isHidden = false
            instructionsTitleLabel.isHidden = false
            instruct1image.isHidden = false
            instruct1Label.isHidden = false
            instruct2image.isHidden = false
            instruct2Label.isHidden = false
            instruct3image.isHidden = false
            instruct3Label.isHidden = false
            instruct4image.isHidden = false
            instruct4Label.isHidden = false
            instruct5image.isHidden = false
            instruct5Label.isHidden = false

            }
        else {
            existingTripsTable.isHidden = false
            existingTripsTable.tableFooterView = UIView()
            existingTripsTable.layer.cornerRadius = 5
            addAnotherTripButton.isHidden = false
            
            createTripButton.isHidden = true
            createTripArrow.isHidden = true
            instructionsTitleLabel.isHidden = true
            instruct1image.isHidden = true
            instruct1Label.isHidden = true
            instruct2image.isHidden = true
            instruct2Label.isHidden = true
            instruct3image.isHidden = true
            instruct3Label.isHidden = true
            instruct4image.isHidden = true
            instruct4Label.isHidden = true
            instruct5image.isHidden = true
            instruct5Label.isHidden = true

        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: Actions
    @IBAction func addTrip(_ sender: Any) {
        let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        if existing_trips == nil {
            DataContainerSingleton.sharedDataContainer.currenttrip = 0
        }
        else {
            DataContainerSingleton.sharedDataContainer.currenttrip = DataContainerSingleton.sharedDataContainer.currenttrip! + 1
        }
    }
    @IBAction func createTripButtonTouchDown(_ sender: Any) {
        createTripArrow.isHighlighted = true
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
            if countTripsBooked > 0 {
                return sectionTitles[section]
            }
        }
        if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && section == 0 && bookingStatuses != [] {
        for index in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
            countTripsBooked += bookingStatuses[index]
        }
        countTripsTotal = (DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)!
        countTripsUnbooked = countTripsTotal - countTripsBooked

        if countTripsUnbooked > 0 {
                return sectionTitles[section]
        }
        }
        return ""
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
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
        
        if DataContainerSingleton.sharedDataContainer.usertrippreferences == nil {
            return 0
        }
        else if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && section == 1 && bookingStatuses != [] {
            for index in 0...(bookingStatuses.count - 1) {
            countTripsBooked += bookingStatuses[index]
            }
            return countTripsBooked
        }
       // else if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && section == 0 {
        if bookingStatuses != [] {
        for index in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
            countTripsBooked += bookingStatuses[index]
        }
        }
        countTripsTotal = (DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)!
        countTripsUnbooked = countTripsTotal - countTripsBooked
        return countTripsUnbooked
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
                    cell.layer.cornerRadius = 5
                    cell.existingTripTableViewImage.image = #imageLiteral(resourceName: "NYE")
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
        // if DataContainerSingleton.sharedDataContainer.usertrippreferences == nil {
            existingTripsTable.isHidden = true
            return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath as IndexPath) as! ExistingTripTableViewCell
        let searchForTitle = cell.existingTripTableViewLabel.text

        for trip in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
            if DataContainerSingleton.sharedDataContainer.usertrippreferences?[trip].object(forKey: "trip_name") as? String == searchForTitle {
                DataContainerSingleton.sharedDataContainer.currenttrip = trip
            }
        }
        self.performSegue(withIdentifier: "existingTripsToAddContacts", sender: self)
    }
}
