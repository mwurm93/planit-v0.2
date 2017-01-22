//
//  Birthday&HomeAirportViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/17/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit

class BirthdayGenderViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var gender: UISegmentedControl!
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var birthdayPickerView: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Change the color of the text in date picker to white
        for subview in self.birthdayPickerView.subviews {
            if subview.frame.height <= 5 {
                subview.backgroundColor = UIColor.white
                subview.tintColor = UIColor.white
                subview.layer.borderColor = UIColor.white.cgColor
                subview.layer.borderWidth = 0.5
            }
            if let pickerView = self.birthdayPickerView.subviews.first {
                for subview in pickerView.subviews {
                    if subview.frame.height <= 5 {
                        subview.backgroundColor = UIColor.white
                        subview.tintColor = UIColor.white
                        subview.layer.borderColor = UIColor.white.cgColor
                        subview.layer.borderWidth = 0.5
                    }
                }
            }
                birthdayPickerView.setValue(UIColor.white, forKey: "textColor")
            }
        
        //Load the values from our shared data container singleton
        if DataContainerSingleton.sharedDataContainer.birthdate == nil {
        }
        else {
        var savedDateString = DataContainerSingleton.sharedDataContainer.birthdate
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let dateObj = dateFormatter.date(from: savedDateString!)
            birthdayPickerView.date = dateObj!
        }
        
        
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        //Install the value into the label.
        if tripNameValue != nil {
            self.tripNameLabel.text =  "\(tripNameValue!)"
        }
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        //Load the values from our shared data container singleton
        if DataContainerSingleton.sharedDataContainer.gender == "Male" {
            gender.selectedSegmentIndex = 0
        }
        else if DataContainerSingleton.sharedDataContainer.gender == "Female" {
            gender.selectedSegmentIndex = 1
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func GenderChanged(_ sender: UISegmentedControl) {
        if gender.selectedSegmentIndex == 0 {
            DataContainerSingleton.sharedDataContainer.gender = "Male"
        }
            else {
                DataContainerSingleton.sharedDataContainer.gender = "Female"
            }
        }
    
    @IBAction func BirthdayValueChanged(_ sender: Any) {
        birthdayPickerView.datePickerMode = UIDatePickerMode.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        var selectedDate = dateFormatter.string(from: birthdayPickerView.date)
        DataContainerSingleton.sharedDataContainer.birthdate = selectedDate
    }
   
}
