//
//  LoadDataFromSingleton.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 1/24/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import Foundation
import UIKit

struct PreferencesForTrip {
    
    //New Trip VC
    var tripNameValue: NSString
    var contacts: [NSString]
    var hotelRoomsValue: NSNumber
    
    //Calendar VC
    var segmentLengthValue: [NSNumber]
    var selectedDates: [NSDate]
    var leftDateTimeArrays: NSDictionary
    var rightDateTimeArrays: NSDictionary
    
    //Budget VC
    var budgetValue: NSString
    var expectedRoundtripFare: NSString
    var expectedNightlyRate: NSString
    
    //Suggested Destination VC
    var decidedOnDestinationControlValue: NSString
    var decidedOnDestinationValue: NSString
    var suggestDestinationControlValue: NSString
    var suggestedDestinationValue: NSString
    
    //Activities VC
    var selectedActivities: [NSString]
}
