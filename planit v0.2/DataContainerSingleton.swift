//
//  DataContainerSingleton.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/18/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import Foundation
import UIKit

struct DefaultKeys {
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let emailAddress = "emailAddress"
        static let password = "password"
        static let gender = "gender"
        static let phone = "phone"
        static let homeAirport = "homeAirport"
        static let passportNumber = "passportNumber"
        static let knownTravelerNumber = "knownTravelerNumber"
        static let redressNumber = "redressNumber"
        static let birthdate = "birthdate"
        static let usertrippreferences = "usertrippreferences"
        static let currenttrip = "currenttrip"
    }

class DataContainerSingleton {
    
    static let sharedDataContainer = DataContainerSingleton()
    
    var firstName: String?
    var lastName: String?
    var emailAddress: String?
    var password: String?
    var gender: String?
    var phone: String?
    var homeAirport: String?
    var passportNumber: String?
    var knownTravelerNumber: String?
    var redressNumber: String?
    var birthdate: String?
    var usertrippreferences: [NSDictionary]?
    var currenttrip: Int?
    
    var goToBackgroundObserver: AnyObject?
    
    init() {
        let defaults = UserDefaults.standard
        //-----------------------------------------------------------------------------
        //This code reads the singleton's properties from NSUserDefaults.
        //edit this code to load your custom properties
        firstName = defaults.object(forKey: DefaultKeys.firstName) as! String?
        lastName = defaults.object(forKey: DefaultKeys.lastName) as! String?
        emailAddress = defaults.object(forKey: DefaultKeys.emailAddress) as! String?
        password = defaults.object(forKey: DefaultKeys.password) as! String?
        gender = defaults.object(forKey: DefaultKeys.gender) as! String?
        phone = defaults.object(forKey: DefaultKeys.phone) as! String?
        homeAirport = defaults.object(forKey: DefaultKeys.homeAirport) as! String?
        passportNumber = defaults.object(forKey: DefaultKeys.passportNumber) as! String?
        knownTravelerNumber = defaults.object(forKey: DefaultKeys.knownTravelerNumber) as! String?
        redressNumber = defaults.object(forKey: DefaultKeys.redressNumber) as! String?
        birthdate = defaults.object(forKey: DefaultKeys.birthdate) as! String?
        usertrippreferences = defaults.object(forKey: DefaultKeys.usertrippreferences) as! [NSDictionary]?
        currenttrip = defaults.object(forKey: DefaultKeys.currenttrip) as! Int?
        
        //-----------------------------------------------------------------------------
        
        //Add an obsever for the UIApplicationDidEnterBackgroundNotification.
        //When the app goes to the background, the code block saves our properties to NSUserDefaults.
        goToBackgroundObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name.UIApplicationDidEnterBackground,
            object: nil,
            queue: nil)
        {
            (note: Notification!) -> Void in
            let defaults = UserDefaults.standard
            //-----------------------------------------------------------------------------
            //This code saves the singleton's properties to NSUserDefaults.
            //edit this code to save your custom properties
            defaults.set( self.firstName, forKey: DefaultKeys.firstName)
            defaults.set( self.lastName, forKey: DefaultKeys.lastName)
            defaults.set( self.emailAddress, forKey: DefaultKeys.emailAddress)
            defaults.set( self.password, forKey: DefaultKeys.password)
            defaults.set( self.phone, forKey: DefaultKeys.phone)
            defaults.set( self.homeAirport, forKey: DefaultKeys.homeAirport)
            defaults.set( self.passportNumber, forKey: DefaultKeys.passportNumber)
            defaults.set( self.knownTravelerNumber, forKey: DefaultKeys.knownTravelerNumber)
            defaults.set( self.redressNumber, forKey: DefaultKeys.redressNumber)
            defaults.set( self.birthdate, forKey: DefaultKeys.birthdate)
            defaults.set( self.usertrippreferences, forKey: DefaultKeys.usertrippreferences)
            defaults.set( self.currenttrip, forKey: DefaultKeys.currenttrip)

            //-----------------------------------------------------------------------------
            //Tell NSUserDefaults to save to disk now.
            defaults.synchronize()
        }
    }
}
