//
//  ContactsViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 12/28/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//
//
//import UIKit
//import Contacts
//import ContactsUI
//
//class ContactsViewController: UIViewController, CNContactPickerDelegate, CNContactViewControllerDelegate  {
//    
//    // MARK: Outlets
//    fileprivate var addressBookStore: CNContactStore!
//    fileprivate var menuArray: NSMutableArray?
//    let picker = CNContactPickerViewController()
//
//    
//    // Contacts stuff
////    let keysToFetch = [CNContactEmailAddressesKey, CNContactPhoneNumbersKey, CNContactFormatter.descriptorForRequiredKeys(for: .fullName)]
////    let predicate: NSPredicate = CNContact.predicateForContacts(matchingName: "")
////    let store = CNContactStore()
////    let contacts = try store.unifiedContactsMatchingPredicate(CNContact.predicateForContactsMatchingName("Appleseed"), keysToFetch:[CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey])
//    
//    // MARK: ViewDidLoad
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        addressBookStore = CNContactStore()
//        checkContactsAccess();
//        
//        groupMemberListTable.layer.cornerRadius = 5
//        
//        // Set appearance of search bar
//        contactsSearchBar.layer.cornerRadius = 5
//        let textFieldInsideSearchBar = contactsSearchBar.value(forKey: "searchField") as? UITextField
//        textFieldInsideSearchBar?.textColor = UIColor.white
//        let textFieldInsideSearchBarLabel = textFieldInsideSearchBar!.value(forKey: "placeholderLabel") as? UILabel
//        textFieldInsideSearchBarLabel?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
//        let clearButton = textFieldInsideSearchBar?.value(forKey: "clearButton") as! UIButton
//        clearButton.setImage(clearButton.imageView?.image?.withRenderingMode(.alwaysTemplate), for: .normal)
//        clearButton.tintColor = UIColor.white
//        let glassIconView = textFieldInsideSearchBar?.leftView as? UIImageView
//        glassIconView?.image = glassIconView?.image?.withRenderingMode(.alwaysTemplate)
//        glassIconView?.tintColor = UIColor.white
//        
//    }
//    
//    fileprivate func checkContactsAccess() {
//        switch CNContactStore.authorizationStatus(for: .contacts) {
//        // Update our UI if the user has granted access to their Contacts
//        case .authorized:
//            self.showContactsPicker()
//            
//        // Prompt the user for access to Contacts if there is no definitive answer
//        case .notDetermined :
//            self.requestContactsAccess()
//            
//        // Display a message if the user has denied or restricted access to Contacts
//        case .denied,
//             .restricted:
//            let alert = UIAlertController(title: "Privacy Warning!",
//                                          message: "Please Enable permission! in settings!.",
//                                          preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//    
//    fileprivate func requestContactsAccess() {
//        
//        addressBookStore.requestAccess(for: .contacts) {granted, error in
//            if granted {
//                DispatchQueue.main.async {
//                    self.showContactsPicker()
//                    return
//                }
//            }
//        }
//    }
//    
//    //Show Contact Picker
//    fileprivate  func showContactsPicker() {
//        
//        picker.delegate = self
//        self.present(picker , animated: true, completion: nil)
//        
//    }
//    
//    
//    //    optional public func contactPicker(picker: CNContactPickerViewController, didSelectContact contact: CNContact)
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//
//}
