//
//  BudgetViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/17/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit
import Contacts

class BudgetViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK: Outlets
    @IBOutlet weak var budget: UITextField!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var whatDoYouCareAboutMoreLabel: UILabel!
    @IBOutlet weak var CareAboutMoreSegmentControl: UISegmentedControl!
    @IBOutlet weak var nightsTextField: UITextField!
    @IBOutlet weak var splitByTextField: UITextField!
    @IBOutlet weak var hotelTotalLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    @IBOutlet weak var roundTripTicketField: UITextField!
    @IBOutlet weak var nightlyRatePerRoomField: UITextField!
    @IBOutlet weak var contactsCollectionView: UICollectionView!
    @IBOutlet weak var expandCollapseButton: UIButton!
    @IBOutlet weak var flightLabel: UILabel!
    @IBOutlet weak var roundTripFareLabel: UILabel!
    @IBOutlet weak var HotelLabel: UILabel!
    @IBOutlet weak var NightlyRatePerRoomLabel: UILabel!
    @IBOutlet weak var dollarSignLabel: UILabel!
    @IBOutlet weak var dollarSignLabel_1: UILabel!
    @IBOutlet weak var NightsLabel: UILabel!
    @IBOutlet weak var splitWithLabel: UILabel!
    @IBOutlet weak var total: UILabel!
    @IBOutlet weak var useThisButton: UIButton!
    @IBOutlet weak var nightsIcon: UIImageView!
    @IBOutlet weak var peopleIcon: UIImageView!
    @IBOutlet weak var hotelTotalDescLabel: UILabel!
    
    var budgetValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "budget") as? String
    let segmentLengthValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "Availability_segment_lengths") as? [Int]
    let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
    let hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? Float
    var expectedRoundtripFare = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_roundtrip_fare") as? String
    var expectedNightlyRate = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_nightly_rate") as? String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.budget.delegate = self
        
        expandCollapseButton.imageView?.image = #imageLiteral(resourceName: "expand")
        flightLabel.alpha = 0
        roundTripFareLabel.alpha = 0
        dollarSignLabel.alpha = 0
        dollarSignLabel_1.alpha = 0
        roundTripTicketField.alpha = 0
        HotelLabel.alpha = 0
        hotelTotalLabel.alpha = 0
        nightlyRatePerRoomField.alpha = 0
        NightlyRatePerRoomLabel.alpha = 0
        nightsTextField.alpha = 0
        nightsIcon.alpha = 0
        peopleIcon.alpha = 0
        useThisButton.alpha = 0
        total.alpha = 0
        totalLabel.alpha = 0
        splitWithLabel.alpha = 0
        splitByTextField.alpha = 0
        NightsLabel.alpha = 0
        hotelTotalDescLabel.alpha = 0
        
        // Set appearance of textfield
        budget.layer.cornerRadius = 5
        budget.layer.borderWidth = 1
        budget.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        budget.layer.masksToBounds = true
        nightsTextField.layer.cornerRadius = 5
        nightsTextField.layer.borderWidth = 1
        nightsTextField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        nightsTextField.layer.masksToBounds = true
        splitByTextField.layer.cornerRadius = 5
        splitByTextField.layer.borderWidth = 1
        splitByTextField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        splitByTextField.layer.masksToBounds = true
        roundTripTicketField.layer.cornerRadius = 5
        roundTripTicketField.layer.borderWidth = 1
        roundTripTicketField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        roundTripTicketField.layer.masksToBounds = true
        nightlyRatePerRoomField.layer.cornerRadius = 5
        nightlyRatePerRoomField.layer.borderWidth = 1
        nightlyRatePerRoomField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        nightlyRatePerRoomField.layer.masksToBounds = true


        whatDoYouCareAboutMoreLabel.isHidden = true
        CareAboutMoreSegmentControl.isHidden = true
        
        let budgetLabelPlaceholder = budget!.value(forKey: "placeholderLabel") as? UILabel
        budgetLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        if segmentLengthValue != nil {
            var maxSegmentLength = 0
            for segmentIndex in 0...(segmentLengthValue?.count)!-1 {
                if (segmentLengthValue?[segmentIndex])! > maxSegmentLength {
                    maxSegmentLength = (segmentLengthValue?[segmentIndex])!
                }
            }
            nightsTextField.text = "\(maxSegmentLength-1)"
        }
        if contacts != nil && hotelRoomsValue != nil {
            let peoplePerRoom = Float((contacts?.count)! + 1)/hotelRoomsValue!
            let roundedPeoplePerRoom = Int(roundf(peoplePerRoom))
            
            splitByTextField.text = "\(roundedPeoplePerRoom)"
        } else {
            splitByTextField.text = "2"
        }
        
        if expectedRoundtripFare != nil {
            roundTripTicketField.text = expectedRoundtripFare
        } else {
            roundTripTicketField.text = "400"
        }
        if expectedNightlyRate != nil {
            nightlyRatePerRoomField.text = expectedNightlyRate
        } else {
            nightlyRatePerRoomField.text = "200"
        }
        
        //Update totals
        var hotelTotalValue = 200
        var totalValue = 600
        if nightsTextField.text != "" && splitByTextField.text != "" && nightlyRatePerRoomField.text != "" && nightsTextField.text != nil && splitByTextField.text != nil && nightlyRatePerRoomField.text != nil {
            hotelTotalValue = Int(nightlyRatePerRoomField.text!)! * Int(nightsTextField.text!)! / Int(splitByTextField.text!)!
            if roundTripTicketField.text != "" && roundTripTicketField != nil {
                totalValue = Int(roundTripTicketField.text!)! + hotelTotalValue
            }
        }
        
        hotelTotalLabel.text = "$\(hotelTotalValue)"
        totalLabel.text = "$\(totalValue)"
        
        //Load the values from our shared data container singleton
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        //Install the value into the label.
        if tripNameValue != nil {
            self.tripNameLabel.text =  "\(tripNameValue!)"
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Install the value into the label and unhide
        if budgetValue != nil {
        self.budget.text =  "\(budgetValue!)"
        }
//        if budgetValue == nil {
//        whatDoYouCareAboutMoreLabel.isHidden = false
//        CareAboutMoreSegmentControl.isHidden = false
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
    // Hide the keyboard.
    budget.resignFirstResponder()
    roundTripTicketField.resignFirstResponder()
    nightlyRatePerRoomField.resignFirstResponder()
    nightsTextField.resignFirstResponder()
    splitByTextField.resignFirstResponder()
    return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
    return true
    }
    
    func saveBudget() {
        budgetValue = budget.text
        expectedNightlyRate = nightlyRatePerRoomField.text
        expectedRoundtripFare = roundTripTicketField.text
        
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        let multipleDestionationsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "multiple_destinations") as? String
        let travelingInternationalValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "traveling_international") as? String
        let suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? String
        let suggestedDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggested_destination") as? String
        let selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [NSDate]
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
        let hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? Float
        let segmentLengthValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "Availability_segment_lengths") as? [Int]
        let leftDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "origin_departure_times") as? [NSDictionary]
        let rightDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "return_departure_times") as? [NSDictionary]
        
        let updatedTripToBeSaved = ["trip_name": tripNameValue, "multiple_destinations": multipleDestionationsValue, "traveling_international": travelingInternationalValue, "suggest_destination_control": suggestDestinationControlValue, "suggested_destination": suggestedDestinationValue, "budget": budgetValue, "selected_dates":selectedDates, "contacts_in_group":contacts, "hotel_rooms":hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays] as [String : Any]
        existing_trips?[currentTripIndex] = updatedTripToBeSaved as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
    }
    
    ///////////////////////////////////COLLECTION VIEW/////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
        if contacts != nil {
            return (contacts?.count)!
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let contactsCell = contactsCollectionView.dequeueReusableCell(withReuseIdentifier: "contactsCollectionPrototypeCell", for: indexPath) as! contactsCollectionViewCell
        
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
        
        let contact = contacts?[indexPath.row]
        
        if (contact?.imageDataAvailable)! {
            contactsCell.thumbnailImage.image = UIImage(data: (contact?.thumbnailImageData!)!)
            contactsCell.initialsLabel.isHidden = true
            contactsCell.thumbnailImageFilter.isHidden = false
            contactsCell.thumbnailImageFilter.image = UIImage(named: "no_contact_image")!
            contactsCell.thumbnailImageFilter.alpha = 0.35
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
            // Create date lists and color array
            let sampleBudget_1 = "$1000"
            let sampleBudget_2 = "$1200"
            let sampleBudget_3 = "$900"
            let sampleBudget_4 = "$700"
            let sampleBudget_5 = "$1600"
            let sampleBudget_6 = "$1300"
            let sampleBudget_7 = "$900"
            let sampleBudgets = [sampleBudget_1, sampleBudget_2,sampleBudget_3,sampleBudget_4,sampleBudget_5,sampleBudget_6,sampleBudget_7]
            
            let colors = [UIColor.purple, UIColor.gray, UIColor.red, UIColor.green, UIColor.orange, UIColor.yellow, UIColor.brown, UIColor.black]
            
            // Change color of thumbnail image
            let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
            let contact = contacts?[indexPath.row]
            let SelectedContact = contactsCollectionView.cellForItem(at: indexPath) as! contactsCollectionViewCell
            
            if (contact?.imageDataAvailable)! {
                SelectedContact.thumbnailImageFilter.alpha = 0
            } else {
                SelectedContact.thumbnailImage.image = UIImage(named: "no_contact_image_selected")!
                //                SelectedContact.initialsLabel.textColor = UIColor(red: 132/255, green: 137/255, blue: 147/255, alpha: 1)
                SelectedContact.initialsLabel.textColor = colors[indexPath.row]
            }
            
            budget.text = sampleBudgets[indexPath.row]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if collectionView == contactsCollectionView {
            // Create date lists and color array
            let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
            let contact = contacts?[indexPath.row]
            
            let DeSelectedContact = contactsCollectionView.cellForItem(at: indexPath) as! contactsCollectionViewCell
            
            if (contact?.imageDataAvailable)! {
                DeSelectedContact.thumbnailImageFilter.alpha = 0.35
            } else {
                DeSelectedContact.thumbnailImage.image = UIImage(named: "no_contact_image")!
                DeSelectedContact.initialsLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
            }
            
            let budgetValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "budget") as? String
            if budgetValue != nil {
                budget.text = budgetValue
            } else {
                budget.text = ""
            }
        }
    }
    
    // MARK: - UICollectionViewFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let picDimension = 55
        return CGSize(width: picDimension, height: picDimension)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
        
        let spacing = 10
        if contacts != nil {
            var leftRightInset = (self.contactsCollectionView.frame.size.width / 2.0) - CGFloat((contacts?.count)!) * 27.5 - CGFloat(spacing / 2 * ((contacts?.count)! - 1))
            if (contacts?.count)! > 4 {
                leftRightInset = 30
            }
            return UIEdgeInsetsMake(0, leftRightInset, 0, 0)
        }
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }

    
    @IBAction func budgetEditingChanged(_ sender: Any) {
        saveBudget()
//        if budgetValue != nil {
//            whatDoYouCareAboutMoreLabel.isHidden = false
//            CareAboutMoreSegmentControl.isHidden = false
//        }
//        if budgetValue == nil {
//            whatDoYouCareAboutMoreLabel.isHidden = true
//            CareAboutMoreSegmentControl.isHidden = true
//        }
    }
    @IBAction func nightsEditingChanged(_ sender: Any) {
        var hotelTotalValue = 200
        var totalValue = 600
        if nightsTextField.text != "" && splitByTextField.text != "" && nightlyRatePerRoomField.text != "" && nightsTextField.text != nil && splitByTextField.text != nil && nightlyRatePerRoomField.text != nil {
            hotelTotalValue = Int(nightlyRatePerRoomField.text!)! * Int(nightsTextField.text!)! / Int(splitByTextField.text!)!
            if roundTripTicketField.text != "" && roundTripTicketField != nil {
                totalValue = Int(roundTripTicketField.text!)! + hotelTotalValue
            }
        }
        hotelTotalLabel.text = "$\(hotelTotalValue)"
        totalLabel.text = "$\(totalValue)"
    }
    @IBAction func splitByEditingChanged(_ sender: Any) {
        
        var hotelTotalValue = 200
        var totalValue = 600
        if nightsTextField.text != "" && splitByTextField.text != "" && nightlyRatePerRoomField.text != "" && nightsTextField.text != nil && splitByTextField.text != nil && nightlyRatePerRoomField.text != nil {
            hotelTotalValue = Int(nightlyRatePerRoomField.text!)! * Int(nightsTextField.text!)! / Int(splitByTextField.text!)!
            if roundTripTicketField.text != "" && roundTripTicketField != nil {
                totalValue = Int(roundTripTicketField.text!)! + hotelTotalValue
            }
        }
        hotelTotalLabel.text = "$\(hotelTotalValue)"
        totalLabel.text = "$\(totalValue)"
    }
    @IBAction func useCalcButtonPressed(_ sender: Any) {
        budget.text = totalLabel.text
        saveBudget()
    }
    @IBAction func expectedRoundtripFareEditingChanged(_ sender: Any) {
        saveBudget()
    }
    @IBAction func expectedNightlyRateEditingChanged(_ sender: Any) {
        saveBudget()
    }
    @IBAction func expandCollapseButtonPressed(_ sender: Any) {
        if expandCollapseButton.imageView?.image == #imageLiteral(resourceName: "expand") {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                self.flightLabel.alpha = 1
                self.roundTripFareLabel.alpha = 1
                self.dollarSignLabel.alpha = 1
                self.dollarSignLabel_1.alpha = 1
                self.roundTripTicketField.alpha = 1
                self.HotelLabel.alpha = 1
                self.hotelTotalLabel.alpha = 1
                self.nightlyRatePerRoomField.alpha = 1
                self.NightlyRatePerRoomLabel.alpha = 1
                self.nightsTextField.alpha = 1
                self.nightsIcon.alpha = 1
                self.peopleIcon.alpha = 1
                self.useThisButton.alpha = 1
                self.total.alpha = 1
                self.totalLabel.alpha = 1
                self.splitWithLabel.alpha = 1
                self.splitByTextField.alpha = 1
                self.NightsLabel.alpha = 1
                self.hotelTotalDescLabel.alpha = 1
                self.expandCollapseButton.setImage(#imageLiteral(resourceName: "collapse"), for: UIControlState.normal)
            }, completion: nil)

            return
        }
        
        if expandCollapseButton.imageView?.image == #imageLiteral(resourceName: "collapse") {
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [], animations: {
                self.flightLabel.alpha = 0
                self.roundTripFareLabel.alpha = 0
                self.dollarSignLabel.alpha = 0
                self.dollarSignLabel_1.alpha = 0
                self.roundTripTicketField.alpha = 0
                self.HotelLabel.alpha = 0
                self.hotelTotalLabel.alpha = 0
                self.nightlyRatePerRoomField.alpha = 0
                self.NightlyRatePerRoomLabel.alpha = 0
                self.nightsTextField.alpha = 0
                self.nightsIcon.alpha = 0
                self.peopleIcon.alpha = 0
                self.useThisButton.alpha = 0
                self.total.alpha = 0
                self.totalLabel.alpha = 0
                self.splitWithLabel.alpha = 0
                self.splitByTextField.alpha = 0
                self.NightsLabel.alpha = 0
                self.hotelTotalDescLabel.alpha = 0
                self.expandCollapseButton.setImage(#imageLiteral(resourceName: "expand"), for: UIControlState.normal)
            }, completion: nil)
        }
    }
}
