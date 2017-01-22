//
//  ActivitiesViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/17/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit
import Contacts

class ActivitiesViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    //MARK: Outlets
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var activitiesSearchBar: UISearchBar!
    @IBOutlet weak var tripRecommendationsLabel: UILabel!
    @IBOutlet weak var rightArrowButton: UIButton!
    @IBOutlet weak var buttonBeneathLabel: UIButton!
    @IBOutlet weak var contactsCollectionView: UICollectionView!
    @IBOutlet weak var activitiesCollectionView: UICollectionView!
    
    var activityItems: [ActivityItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tripRecommendationsLabel.text = "Skip to recommendations"
        
        // Call collection initializer
        initActivityItems()
        activitiesCollectionView.reloadData()
        activitiesCollectionView.allowsMultipleSelection = true

        //update aesthetics
        activitiesCollectionView.layer.cornerRadius = 5
        activitiesCollectionView.layer.backgroundColor = UIColor(red: 225/255, green: 225/255, blue: 225/255, alpha: 0).cgColor
        
        // Set appearance of search bar
        activitiesSearchBar.layer.cornerRadius = 5
        let textFieldInsideSearchBar = activitiesSearchBar.value(forKey: "searchField") as? UITextField
        textFieldInsideSearchBar?.textColor = UIColor.white
        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
        textFieldInsideSearchBarLabel?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        let clearButton = textFieldInsideSearchBar?.value(forKey: "clearButton") as! UIButton
        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        clearButton.tintColor = UIColor.white
        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
        glassIconView?.tintColor = UIColor.white
        
        //Load the values from our shared data container singleton
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        //Install the value into the label.
        if tripNameValue != nil {
            self.tripNameLabel.text =  "\(tripNameValue!)"
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        // Update cell border color to blue if saved as a selected activity
        let selectedActivities = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_activities") as? [String]
        
        let visibleCellIndices = self.activitiesCollectionView.indexPathsForVisibleItems
        for visibleCellIndex in visibleCellIndices {
            let visibleCell = activitiesCollectionView.cellForItem(at: visibleCellIndex) as! ActivitiesCollectionViewCell
            if selectedActivities != nil {
            if (selectedActivities?.contains(visibleCell.activityLabel.text!))! {
                visibleCell.layer.borderColor = UIColor.blue.cgColor
                activitiesCollectionView.selectItem(at: visibleCellIndex, animated: true, scrollPosition: .top)
            }
            else {
                visibleCell.layer.borderColor = UIColor(red: 25/255, green: 135/255, blue: 255/255, alpha: 0).cgColor
                activitiesCollectionView.deselectItem(at: visibleCellIndex, animated: true)
            }
            }
            else {
                visibleCell.layer.borderColor = UIColor(red: 25/255, green: 135/255, blue: 255/255, alpha: 0).cgColor
                activitiesCollectionView.deselectItem(at: visibleCellIndex, animated: true)
            }
        }
        
        // Change label for continuing
        if selectedActivities != nil {
            if (selectedActivities?.count)! > 0 {
            tripRecommendationsLabel.text = "Recommendations"
            }
        }
    }
    
    // MARK: Activities collection View item init
    fileprivate func initActivityItems() {
        
        var items = [ActivityItem]()
        let inputFile = Bundle.main.path(forResource: "items", ofType: "plist")
        
        let inputDataArray = NSArray(contentsOfFile: inputFile!)
        
        for inputItem in inputDataArray as! [Dictionary<String, String>] {
            let activityItem = ActivityItem(dataDictionary: inputItem)
            items.append(activityItem)
        }
        activityItems = items
    }
    
    // MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == activitiesCollectionView {
            return activityItems.count
        }
        // if collectionView == contactsCollectionView
            let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
        if contacts != nil {
            return (contacts?.count)!
        }
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == activitiesCollectionView {
            activitiesCollectionView.allowsMultipleSelection = true
            let cell = activitiesCollectionView.dequeueReusableCell(withReuseIdentifier: "activitiesViewPrototypeCell", for: indexPath) as! ActivitiesCollectionViewCell
            cell.setActivityItem(activityItems[indexPath.row])
            cell.layer.borderWidth = 3.5
            cell.layer.borderColor = UIColor(red: 25/255, green: 135/255, blue: 255/255, alpha: 0).cgColor
            cell.layer.cornerRadius = 10
            return cell
        }
        // if collectionView == contactsCollectionView
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
    
    // MARK: - UICollectionViewDelegate
    // Item DEselected: update border color and save data when
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if collectionView == contactsCollectionView {
            
            // Create activity lists and color array
            let sampleContactActivityList_1 = ["Scuba", "Surf"]
            let sampleContactActivityList_2 = ["Sun", "Ski", "Theater"]
            let sampleContactActivityList_3 = ["Ski", "Theater"]
            let sampleContactActivityList_4 = ["Sun", "Museum", "Theater"]
            let sampleContactActivityList_5 = ["Drink"]
            let sampleContactActivityList_6 = ["Shop"]
            let sampleContactActivityList_7 = ["Fine dining"]
            let sampleContactActivityLists = [sampleContactActivityList_1, sampleContactActivityList_2, sampleContactActivityList_3, sampleContactActivityList_4, sampleContactActivityList_5, sampleContactActivityList_6, sampleContactActivityList_7]
            let colors = [UIColor.purple, UIColor.gray, UIColor.red, UIColor.green, UIColor.orange, UIColor.yellow, UIColor.brown, UIColor.black]
            
            // Change color of thumbnail image
            let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
            let contact = contacts?[indexPath.row]
            let SelectedContact = contactsCollectionView.cellForItem(at: indexPath) as! contactsCollectionViewCell
            
            if (contact?.imageDataAvailable)! {
                SelectedContact.thumbnailImageFilter.alpha = 0
            } else {
                SelectedContact.thumbnailImage.image = UIImage(named: "no_contact_image_selected")!
                SelectedContact.initialsLabel.textColor = colors[indexPath.row]
            }
            

            // Select activities on highlight
            let visibleCellIndices = self.activitiesCollectionView.indexPathsForVisibleItems
            for visibleCellIndex in visibleCellIndices {
                let visibleCell = activitiesCollectionView.cellForItem(at: visibleCellIndex) as! ActivitiesCollectionViewCell
                if sampleContactActivityLists[indexPath.row] != nil {
                    if (sampleContactActivityLists[indexPath.row].contains(visibleCell.activityLabel.text!)) {
                        visibleCell.layer.borderColor = colors[indexPath.row].cgColor
                        activitiesCollectionView.selectItem(at: visibleCellIndex, animated: true, scrollPosition: .top)
                    }
                    else {
                        visibleCell.layer.borderColor = UIColor(red: 25/255, green: 135/255, blue: 255/255, alpha: 0).cgColor
                        activitiesCollectionView.deselectItem(at: visibleCellIndex, animated: true)
                    }
                }
                else {
                    visibleCell.layer.borderColor = UIColor(red: 25/255, green: 135/255, blue: 255/255, alpha: 0).cgColor
                    activitiesCollectionView.deselectItem(at: visibleCellIndex, animated: true)
                }
            }

        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if collectionView == contactsCollectionView {
            let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
            let contact = contacts?[indexPath.row]
            
            let DeSelectedContact = contactsCollectionView.cellForItem(at: indexPath) as! contactsCollectionViewCell
            
            if (contact?.imageDataAvailable)! {
                DeSelectedContact.thumbnailImageFilter.alpha = 0.35
            } else {
                DeSelectedContact.thumbnailImage.image = UIImage(named: "no_contact_image")!
                DeSelectedContact.initialsLabel.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
                
            }
            
            // Update cell border color to blue if saved as a selected activity
            let selectedActivities = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_activities") as? [String]
            
            let visibleCellIndices = self.activitiesCollectionView.indexPathsForVisibleItems
            for visibleCellIndex in visibleCellIndices {
                let visibleCell = activitiesCollectionView.cellForItem(at: visibleCellIndex) as! ActivitiesCollectionViewCell
                if selectedActivities != nil {
                    if (selectedActivities?.contains(visibleCell.activityLabel.text!))! {
                        visibleCell.layer.borderColor = UIColor.blue.cgColor
                        activitiesCollectionView.selectItem(at: visibleCellIndex, animated: true, scrollPosition: .top)
                    }
                    else {
                        visibleCell.layer.borderColor = UIColor(red: 25/255, green: 135/255, blue: 255/255, alpha: 0).cgColor
                        activitiesCollectionView.deselectItem(at: visibleCellIndex, animated: true)
                    }
                }
                else {
                    visibleCell.layer.borderColor = UIColor(red: 25/255, green: 135/255, blue: 255/255, alpha: 0).cgColor
                    activitiesCollectionView.deselectItem(at: visibleCellIndex, animated: true)
                }
            }
            
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if collectionView == activitiesCollectionView {

        // Change border color to grey
        let deSelectedCell = collectionView.cellForItem(at: indexPath)
        deSelectedCell!.layer.borderColor = UIColor(red: 25/255, green: 135/255, blue: 255/255, alpha: 0).cgColor
        
        // Create array of selected activities
        var selectedActivities = [String?]()
        let indexPaths = self.activitiesCollectionView!.indexPathsForSelectedItems
        for indexItem in indexPaths! {
            let currentCell = activitiesCollectionView.cellForItem(at: indexItem)! as! ActivitiesCollectionViewCell
            let selectedActivity = currentCell.activityLabel.text
            selectedActivities.append(selectedActivity)
        }
        
        // Save array of selected activities to trip data model
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        let multipleDestionationsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "multiple_destinations") as? String
        let travelingInternationalValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "traveling_international") as? String
        let suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? String
        let suggestedDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggested_destination") as? String
        let budgetValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "budget") as? String
        let selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [Date]
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]

        let updatedTripToBeSaved = ["trip_name": tripNameValue, "multiple_destinations": multipleDestionationsValue, "traveling_international": travelingInternationalValue, "suggest_destination_control": suggestDestinationControlValue, "suggested_destination": suggestedDestinationValue, "budget": budgetValue, "selected_activities": selectedActivities, "selected_dates": selectedDates, "contacts_in_group": contacts] as [String : Any]
        existing_trips?[currentTripIndex] = updatedTripToBeSaved as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
        
        // Change label for continuing
        if selectedActivities.count > 0 {
            tripRecommendationsLabel.text = "Recommendations"
        }
        if selectedActivities.count == 0 {
            tripRecommendationsLabel.text = "Skip to recommendations"
        }
    }
       
    }
    
    // Item SELECTED: update border color and save data when
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == activitiesCollectionView {

        // Change border color to grey
        let SelectedCell = activitiesCollectionView.cellForItem(at: indexPath)
        SelectedCell!.layer.borderColor = UIColor.blue.cgColor
        
        // Create array of selected activities
        var selectedActivities = [String?]()
        let indexPaths = self.activitiesCollectionView!.indexPathsForSelectedItems
        for indexItem in indexPaths! {
            let currentCell = collectionView.cellForItem(at: indexItem)! as! ActivitiesCollectionViewCell
            let selectedActivity = currentCell.activityLabel.text
            selectedActivities.append(selectedActivity)
        }
        
        // Save array of selected activities to trip data model
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        let multipleDestionationsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "multiple_destinations") as? String
        let travelingInternationalValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "traveling_international") as? String
        let suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? String
        let suggestedDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggested_destination") as? String
        let budgetValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "budget") as? String
        let selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [Date]
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]

        let updatedTripToBeSaved = ["trip_name": tripNameValue, "multiple_destinations": multipleDestionationsValue, "traveling_international": travelingInternationalValue, "suggest_destination_control": suggestDestinationControlValue, "suggested_destination": suggestedDestinationValue, "budget": budgetValue, "selected_activities": selectedActivities, "selected_dates": selectedDates, "contacts_in_group": contacts] as [String : Any]
        existing_trips?[currentTripIndex] = updatedTripToBeSaved as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
        
        // Change label for continuing
        if selectedActivities.count > 0 {
            tripRecommendationsLabel.text = "Recommendations"
        }
        if selectedActivities.count == 0 {
            tripRecommendationsLabel.text = "Skip to recommendations"
        }
    }
    }
    
    // MARK: - UICollectionViewFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == activitiesCollectionView {
            let picDimension = self.view.frame.size.width / 4.2
            return CGSize(width: picDimension, height: picDimension)
        }
        // if collectionView == contactsCollectionView
            let picDimension = 55
            return CGSize(width: picDimension, height: picDimension)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView == activitiesCollectionView {
            let leftRightInset = self.view.frame.size.width / 18.0
            return UIEdgeInsetsMake(0, leftRightInset, 0, leftRightInset)
        }
        // if collectionView == contactsCollectionView
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
}
