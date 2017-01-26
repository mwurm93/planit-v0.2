//
//  OptionalPreferencesViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/17/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit
import Contacts

class InternationalViewController: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var travelingInternationalControl: UISegmentedControl!
    
    var travelingInternationalValue = NSString()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load the values from our shared data container singleton
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        
        //Install the value into the label.
        if tripNameValue != nil {
            self.tripNameLabel.text =  "\(tripNameValue!)"
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Install the value into the label.
        if travelingInternationalValue == "Yes" {
            travelingInternationalControl.selectedSegmentIndex = 0
        }
        else if travelingInternationalValue == "No" {
            travelingInternationalControl.selectedSegmentIndex = 1
        }
    }
    
    // MARK: Actions
    @IBAction func travelingInternationalValueChanged(_ sender: Any) {
        if travelingInternationalControl.selectedSegmentIndex == 0 {
            travelingInternationalValue = "Yes"
        }
        else {
            travelingInternationalValue = "No"
        }
    }
}
