//
//  messageComposer.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 1/23/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import Foundation
import MessageUI
import Contacts


class MessageComposer: NSObject, MFMessageComposeViewControllerDelegate {
    let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [CNContact]
    var contactPhoneNumbers = [String]()
    
    // A wrapper function to indicate whether or not a text message can be sent from the user's device
    func canSendText() -> Bool {
        return MFMessageComposeViewController.canSendText()
    }
    
    // Configures and returns a MFMessageComposeViewController instance
    func configuredMessageComposeViewController() -> MFMessageComposeViewController {
        if contacts != nil {
            for contact in contacts! {
                let phoneNumber = contact.phoneNumbers[0].value.value(forKey: "digits") as! String
                contactPhoneNumbers.append(phoneNumber)
            }
        }
        
        let messageComposeVC = MFMessageComposeViewController()
        messageComposeVC.messageComposeDelegate = self  //  Make sure to set this property to self, so that the controller can be dismissed!
        messageComposeVC.recipients = contactPhoneNumbers
        messageComposeVC.body =  "What’s up team? I just started planning a trip for us. When you add your preferences, the folks at PLANiT will create a handful of unique itineraries for us to choose from...you’re up!"
        return messageComposeVC
    }
    
    // MFMessageComposeViewControllerDelegate callback - dismisses the view controller when the user is finished with it
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        controller.dismiss(animated: true, completion: nil)
    }
}
