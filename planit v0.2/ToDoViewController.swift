//
//  ToDoViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 4/26/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import ContactsUI
import Contacts
import JTAppleCalendar
import UIColor_FlatColors
import Cartography

class ToDoViewController: UIViewController, UITextFieldDelegate, CNContactPickerDelegate, CNContactViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout {
    
    //Slider
    let sliderStep: Float = 1
    
    //Cache colors
    static let transparentColor = UIColor(colorWithHexValue: 0xFFFFFF, alpha: 0).cgColor
    static let whiteColor = UIColor(colorWithHexValue: 0xFFFFFF, alpha: 1)
    static let transparentWhiteColor = UIColor(colorWithHexValue: 0xFFFFFF, alpha: 0.33).cgColor
    static let darkGrayColor = UIColor(colorWithHexValue: 0x656565, alpha: 1)
    static let blackColor = UIColor(colorWithHexValue: 0x000000, alpha: 1)
    
    //ZLSwipeableView
    var colors = ["Turquoise", "Green Sea", "Emerald", "Nephritis", "Peter River", "Belize Hole", "Amethyst", "Wisteria", "Wet Asphalt", "Midnight Blue", "Sun Flower", "Orange", "Carrot", "Pumpkin", "Alizarin", "Pomegranate", "Silver", "Concrete", "Asbestos"]
    var colorIndex = 0
    var loadCardsFromXib = false
    var isTrackingPanLocation = false
    var panGestureRecognizer = UIPanGestureRecognizer()
    
    //Contacts vars COPY
    fileprivate var addressBookStore: CNContactStore!
    let picker = CNContactPickerViewController()
    var contacts: [CNContact]?
    var contactIDs: [NSString]?
    var contactPhoneNumbers = [NSString]()
    var NewOrAddedTripFromSegue: Int?
    var editModeEnabled = false
    
    //subview vars
    var homeAirportValue = DataContainerSingleton.sharedDataContainer.homeAirport ?? ""
    var firstDate: Date?
    let timesOfDayArray = ["Early morning (before 8am)","Morning (8am-11am)","Midday (11am-2pm)","Afternoon (2pm-5pm)","Evening (5pm-9pm)","Night (after 9pm)","Anytime"]
    
    var leftDates = [Date]()
    var rightDates = [Date]()
    var fullDates = [Date]()
    var lengthOfAvailabilitySegmentsArray = [Int]()
    var leftDateTimeArrays = NSMutableDictionary()
    var rightDateTimeArrays = NSMutableDictionary()
    var mostRecentSelectedCellDate = NSDate()
    
    // MARK: Outlets
    
    @IBOutlet weak var rejectIcon: UIButton!
    @IBOutlet weak var heartIcon: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var ranOutOfSwipesLabel: UILabel!
    @IBOutlet weak var contactsCollectionView: UICollectionView!
    @IBOutlet weak var popupBlurView: UIVisualEffectView!
    @IBOutlet weak var addContactPlusIconMainVC: UIButton!
    @IBOutlet weak var popupBackgroundViewMainVC: UIVisualEffectView!
    @IBOutlet weak var swipeableView: ZLSwipeableView!
    @IBOutlet weak var detailedCardView: UIScrollView!
    @IBOutlet weak var tripNameLabel: UITextField!
    @IBOutlet weak var swipingInstructionsView: UIView!
    @IBOutlet weak var popupBackgroundViewDeleteContacts: UIVisualEffectView!
    @IBOutlet weak var popupBackgroundViewDeleteContactsWithinCollectionView: UIVisualEffectView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        swipeableView.nextView = {
            return self.nextCardView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideKeyboardWhenTappedAround()
        
        popupBlurView.isUserInteractionEnabled = true
        
        //Load the values from our shared data container singleton
            let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
            //Install the value into the label.
            if tripNameValue != nil {
                self.tripNameLabel.text =  "\(tripNameValue!)"
            }
        
        detailedCardView.isHidden = true
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panRecognized(recognizer:)))
        panGestureRecognizer.delegate = self
        detailedCardView.addGestureRecognizer(panGestureRecognizer)
        detailedCardView.layer.cornerRadius = 15
        
        //Trip Name textField
        self.tripNameLabel.delegate = self
        
        
        // Load trip preferences and install
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
                
        popupBlurView.alpha = 0
        
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        
        heartIcon.setImage(#imageLiteral(resourceName: "fullHeart"), for: .highlighted)
        rejectIcon.setImage(#imageLiteral(resourceName: "fullX"), for: .highlighted)
        ranOutOfSwipesLabel.isHidden = true
        
        //COPY FOR CONTACTS
        //        self.hideKeyboardWhenTappedAround()
        addressBookStore = CNContactStore()
        retrieveContactsWithStore(store: addressBookStore)
        
        let lpgr = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongPress(gestureReconizer:)))
        lpgr.minimumPressDuration = 0.5
        lpgr.delaysTouchesBegan = true
        lpgr.delegate = self
        self.contactsCollectionView.addGestureRecognizer(lpgr)
        //
        let atap = UITapGestureRecognizer(target: self, action: #selector(self.dismissInstructions(touch:)))
        atap.numberOfTapsRequired = 1
        atap.delegate = self
        self.popupBackgroundViewMainVC.addGestureRecognizer(atap)
        popupBackgroundViewMainVC.isHidden = true
        popupBackgroundViewMainVC.isUserInteractionEnabled = true
        swipingInstructionsView.isHidden = true
        swipingInstructionsView.layer.cornerRadius = 10
        //
        let tapOutsideContacts = UITapGestureRecognizer(target: self, action: #selector(self.leaveDeleteContactsMode(touch:)))
        tapOutsideContacts.numberOfTapsRequired = 1
        tapOutsideContacts.delegate = self
        self.popupBackgroundViewDeleteContacts.addGestureRecognizer(tapOutsideContacts)
        popupBackgroundViewDeleteContacts.isHidden = true
        popupBackgroundViewDeleteContacts.isUserInteractionEnabled = true
        //
        let tapOutsideContact = UITapGestureRecognizer(target: self, action: #selector(self.leaveDeleteContactsMode2(touch:)))
        tapOutsideContact.numberOfTapsRequired = 1
        tapOutsideContact.delegate = self
        self.popupBackgroundViewDeleteContactsWithinCollectionView.addGestureRecognizer(tapOutsideContact)
        popupBackgroundViewDeleteContactsWithinCollectionView.isHidden = true
        popupBackgroundViewDeleteContactsWithinCollectionView.isUserInteractionEnabled = true
        
        popupBlurView.alpha = 0
        
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        
        heartIcon.setImage(#imageLiteral(resourceName: "fullHeart"), for: .highlighted)
        rejectIcon.setImage(#imageLiteral(resourceName: "fullX"), for: .highlighted)
        ranOutOfSwipesLabel.isHidden = true
        
        view.autoresizingMask = .flexibleTopMargin
        view.sizeToFit()
        
        let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        if existing_trips?.count == 1 {
                let when = DispatchTime.now() + 0.6
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.animateInstructionsIn()
                    self.nextButton.alpha =  0
                    self.contactsCollectionView.alpha = 0
                    self.addContactPlusIconMainVC.alpha = 0

            }
        }
        
        //ZLSwipeableview
        swipeableView.allowedDirection = .Horizontal
        
        swipeableView.didStart = {view, location in
            print("Did start swiping view at location: \(location)")
        }
        swipeableView.swiping = {view, location, translation in
            print("Swiping at view location: \(location) translation: \(translation)")
        }
        swipeableView.didEnd = {view, location in
            print("Did end swiping view at location: \(location)")
        }
        swipeableView.didSwipe = {view, direction, vector in
        }
        swipeableView.didCancel = {view in
            print("Did cancel swiping view")
        }
        swipeableView.didTap = {view, location in
            self.detailedCardView.isHidden = false
            self.detailedCardView.alpha = 1
            self.detailedCardView.backgroundColor = self.swipeableView.topView()?.backgroundColor
            
            let bounds = UIScreen.main.bounds
            let width = bounds.size.width
            let height = bounds.size.height
            self.detailedCardView.frame = CGRect(x: 0, y: 0, width: width, height: height)
            
            let contentView = Bundle.main.loadNibNamed("ToDoCardContentView", owner: self, options: nil)?.first! as! UIView
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.backgroundColor = self.swipeableView.topView()?.backgroundColor
            contentView.layer.cornerRadius = 0
            contentView.layer.shadowOpacity = 0
            self.detailedCardView.addSubview(contentView)
            constrain(contentView, self.detailedCardView) { view1, view2 in
                view1.left == view2.left
                view1.top == view2.top + 70
                view1.width == self.detailedCardView.bounds.width
                view1.height == self.detailedCardView.bounds.height
            }
            self.swipeableView.isUserInteractionEnabled = false
        }
        swipeableView.didDisappear = { view in
            print("Did disappear swiping view")
        }
        
        constrain(swipeableView, view) { view1, view2 in
            view1.left == view2.left+30
            view1.right == view2.right-30
            view1.top == view2.top + 120
            view1.bottom == view2.bottom - 150
        }
        
        //Custom animation
        func toRadian(_ degree: CGFloat) -> CGFloat {
            return degree * CGFloat(Double.pi/180)
        }
        func rotateAndTranslateView(_ view: UIView, forDegree degree: CGFloat, translation: CGPoint, duration: TimeInterval, offsetFromCenter offset: CGPoint, swipeableView: ZLSwipeableView) {
            UIView.animate(withDuration: duration, delay: 0, options: .allowUserInteraction, animations: {
                view.center = swipeableView.convert(swipeableView.center, from: swipeableView.superview)
                var transform = CGAffineTransform(translationX: offset.x, y: offset.y)
                transform = transform.rotated(by: toRadian(degree))
                transform = transform.translatedBy(x: -offset.x, y: -offset.y)
                transform = transform.translatedBy(x: translation.x, y: translation.y)
                view.transform = transform
            }, completion: nil)
        }
        swipeableView.numberOfActiveView = 8
        swipeableView.animateView = {(view: UIView, index: Int, views: [UIView], swipeableView: ZLSwipeableView) in
            let degree = CGFloat(sin(0.5*Double(index)))
            let offset = CGPoint(x: 0, y: swipeableView.bounds.height*0.3)
            let translation = CGPoint(x: degree*10, y: CGFloat(-index*5))
            let duration = 0.4
            rotateAndTranslateView(view, forDegree: degree, translation: translation, duration: duration, offsetFromCenter: offset, swipeableView: swipeableView)
        }
        
        self.loadCardsFromXib = true
        self.colorIndex = 0
        self.swipeableView.discardViews()
        self.swipeableView.loadViews()
        
    }
    
    // COPY for Contacts
    func handleLongPress(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizerState.began {
            editModeEnabled = true
            popupBackgroundViewDeleteContacts.isHidden = false
            popupBackgroundViewDeleteContactsWithinCollectionView.isHidden = false
            
            for item in self.contactsCollectionView!.visibleCells as! [contactsCollectionViewCell] {
                let indexPath: IndexPath = self.contactsCollectionView!.indexPath(for: item as contactsCollectionViewCell)!
                let cell: contactsCollectionViewCell = self.contactsCollectionView!.cellForItem(at: indexPath) as! contactsCollectionViewCell!
                cell.deleteButton.isHidden = false
                cell.shakeIcons()
            }
        }
    }
    
    func leaveDeleteContactsMode(touch: UITapGestureRecognizer) {
        dismissDeleteContactsMode()
    }
    
    func leaveDeleteContactsMode2(touch: UITapGestureRecognizer) {
        dismissDeleteContactsMode()
    }
    
    func dismissDeleteContactsMode(){
        self.popupBackgroundViewDeleteContactsWithinCollectionView.isHidden = true
        self.popupBackgroundViewDeleteContacts.isHidden = true
        for item in self.contactsCollectionView!.visibleCells as! [contactsCollectionViewCell] {
            let indexPath: IndexPath = self.contactsCollectionView!.indexPath(for: item as contactsCollectionViewCell)!
            let cell: contactsCollectionViewCell = self.contactsCollectionView!.cellForItem(at: indexPath) as! contactsCollectionViewCell!
            cell.deleteButton.isHidden = true
            cell.stopShakingIcons()
        }
        editModeEnabled = false
    }
    
    //Dismissing detailed card view
    public func panRecognized(recognizer:UIPanGestureRecognizer) {
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width
        let height = bounds.size.height
        let dismissTriggerOffset = height/5
        
        if recognizer.state == .began && detailedCardView.contentOffset.y == 0 {
            recognizer.setTranslation(CGPoint.zero, in: detailedCardView)
            isTrackingPanLocation = true
        } else if recognizer.state == .cancelled || recognizer.state == .ended && isTrackingPanLocation {
            let panOffset = recognizer.translation(in: detailedCardView)
            if panOffset.y < dismissTriggerOffset {
                UIView.animate(withDuration: 0.4) {
                    self.detailedCardView.frame = CGRect(x: 0, y: 0, width: width, height: height)
                }
            }
            isTrackingPanLocation = false
        } else if recognizer.state != .ended && recognizer.state != .cancelled &&
            recognizer.state != .failed && isTrackingPanLocation {
            let panOffset = recognizer.translation(in: detailedCardView)
            if panOffset.y < 0 {
                isTrackingPanLocation = false
            } else if panOffset.y < dismissTriggerOffset {
                let panOffset = recognizer.translation(in: detailedCardView)
                self.detailedCardView.frame = CGRect(x: 0, y: panOffset.y, width: width, height: height)
            } else {
                recognizer.isEnabled = false
                recognizer.isEnabled = true
                swipeableView.isUserInteractionEnabled = true
                UIView.animate(withDuration: 0.3, animations: { () -> Void in
                    self.detailedCardView.frame = self.swipeableView.frame
                    self.detailedCardView.alpha = 0.6}, completion: { (finished: Bool) in
                        self.detailedCardView.alpha = 0.0}
                )
            }
        } else {
            isTrackingPanLocation = false
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith
        otherGestureRecognizer : UIGestureRecognizer)->Bool {
        return true
    }
    
    //ZLFunctions
    func leftButtonAction() {
        self.swipeableView.swipeTopView(inDirection: .Left)
    }
    
    func upButtonAction() {
        self.swipeableView.swipeTopView(inDirection: .Up)
    }
    
    func rightButtonAction() {
        self.swipeableView.swipeTopView(inDirection: .Right)
    }
    
    func downButtonAction() {
        self.swipeableView.swipeTopView(inDirection: .Down)
    }
    
    // MARK: ()
    func nextCardView() -> UIView? {
        if colorIndex >= colors.count {
            colorIndex = 0
        }
        
        let cardView = ToDoCardView(frame: swipeableView.bounds)
        cardView.backgroundColor = colorForName(colors[colorIndex])
        colorIndex += 1
        
        if loadCardsFromXib {
            let contentView = Bundle.main.loadNibNamed("ToDoCardContentView", owner: self, options: nil)?.first! as! UIView
            contentView.translatesAutoresizingMaskIntoConstraints = false
            contentView.backgroundColor = cardView.backgroundColor
            cardView.addSubview(contentView)
            
            // This is important:
            // https://github.com/zhxnlai/ZLSwipeableView/issues/9
            /*// Alternative:
             let metrics = ["width":cardView.bounds.width, "height": cardView.bounds.height]
             let views = ["contentView": contentView, "cardView": cardView]
             cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView(width)]", options: .AlignAllLeft, metrics: metrics, views: views))
             cardView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView(height)]", options: .AlignAllLeft, metrics: metrics, views: views))
             */
            constrain(contentView, cardView) { view1, view2 in
                view1.left == view2.left
                view1.top == view2.top
                view1.width == cardView.bounds.width
                view1.height == cardView.bounds.height
            }
        }
        return cardView
    }
    
    func colorForName(_ name: String) -> UIColor {
        let sanitizedName = name.replacingOccurrences(of: " ", with: "")
        let selector = "flat\(sanitizedName)Color"
        return UIColor.perform(Selector(selector)).takeUnretainedValue() as! UIColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    func animateInstructionsIn(){
        swipingInstructionsView.layer.isHidden = false
        swipingInstructionsView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        swipingInstructionsView.alpha = 0
        swipeableView.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.4) {
            self.popupBackgroundViewMainVC.isHidden = false
            self.swipingInstructionsView.alpha = 1
            self.swipingInstructionsView.transform = CGAffineTransform.identity
        }
    }
    
    func buttonClicked(sender:UIButton)
    {
        sender.isSelected = !sender.isSelected
        if sender.isSelected == true {
            sender.backgroundColor = UIColor.white
            sender.titleLabel?.textColor = UIColor.black
        } else {
            sender.backgroundColor = UIColor.darkGray
            sender.titleLabel?.textColor = UIColor.white
        }
    }
    
    func getMonth(Month: Int) -> String {
        var monthLongForm = ""
        // Update header
        if Month == 01 {
            monthLongForm = "January"
        } else if Month == 02 {
            monthLongForm = "February"
        } else if Month == 03 {
            monthLongForm = "March"
        } else if Month == 04 {
            monthLongForm = "April"
        } else if Month == 05 {
            monthLongForm = "May"
        } else if Month == 06 {
            monthLongForm = "June"
        } else if Month == 07 {
            monthLongForm = "July"
        } else if Month == 08 {
            monthLongForm = "August"
        } else if Month == 09 {
            monthLongForm = "September"
        } else if Month == 10 {
            monthLongForm = "October"
        } else if Month == 11 {
            monthLongForm = "November"
        } else if Month == 12 {
            monthLongForm = "December"
        }
        return monthLongForm
    }
    
    //UITapGestureRecognizer
    func dismissInstructions(touch: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.swipingInstructionsView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.swipingInstructionsView.alpha = 0
            self.popupBackgroundViewMainVC.isHidden = true
            self.swipeableView.isUserInteractionEnabled = true
            self.nextButton.alpha = 1
            self.contactsCollectionView.alpha = 1
            self.addContactPlusIconMainVC.alpha = 1
        }) { (Success:Bool) in
            self.swipingInstructionsView.layer.isHidden = true
        }
    }
    
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var numberOfContacts = 0
        if contacts != nil {
            numberOfContacts += contacts!.count
        }
        
        return numberOfContacts
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let contactsCell = contactsCollectionView.dequeueReusableCell(withReuseIdentifier: "contactsCollectionPrototypeCell", for: indexPath) as! contactsCollectionViewCell
        
        let contact = contacts?[indexPath.row]
        
        if (contact?.imageDataAvailable)! {
            contactsCell.thumbnailImage.image = UIImage(data: (contact?.thumbnailImageData!)!)
            contactsCell.thumbnailImage.contentMode = .scaleToFill
            let reCenter = contactsCell.thumbnailImage.center
            contactsCell.thumbnailImage.layer.frame = CGRect(x: contactsCell.thumbnailImage.layer.frame.minX
                , y: contactsCell.thumbnailImage.layer.frame.minY, width: contactsCell.thumbnailImage.layer.frame.width * 0.91, height: contactsCell.thumbnailImage.layer.frame.height * 0.91)
            contactsCell.thumbnailImage.center = reCenter
            contactsCell.thumbnailImage.layer.cornerRadius = contactsCell.thumbnailImage.frame.height / 2
            contactsCell.thumbnailImage.layer.masksToBounds = true
            contactsCell.initialsLabel.isHidden = true
            contactsCell.thumbnailImageFilter.isHidden = false
            contactsCell.thumbnailImageFilter.image = UIImage(named: "no_contact_image_selected")!
            contactsCell.thumbnailImageFilter.alpha = 0.5
        } else {
            contactsCell.thumbnailImage.image = UIImage(named: "no_contact_image")!
            contactsCell.thumbnailImageFilter.isHidden = true
            contactsCell.initialsLabel.isHidden = false
            let firstInitial = contact?.givenName[0]
            let secondInitial = contact?.familyName[0]
            contactsCell.initialsLabel.text = firstInitial! + secondInitial!
        }
        
        //Delete button
        contactsCell.deleteButton.isHidden = true
        // Give the delete button an index number
        contactsCell.deleteButton.layer.setValue(indexPath.row, forKey: "index")
        // Add an action function to the delete button
        contactsCell.deleteButton.addTarget(self, action: #selector(self.deleteContactButtonTouchedUpInside(sender:)), for: UIControlEvents.touchUpInside)
        
        return contactsCell
    }
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        let visibleCells = self.contactsCollectionView.visibleCells
        
        if editModeEnabled == true {
            for cell in visibleCells {
                let visibleCellIndexPath = contactsCollectionView.indexPath(for: cell)
                let visibleCell = contactsCollectionView.cellForItem(at: visibleCellIndexPath!) as! contactsCollectionViewCell
                // Shake all of the collection view cells
                visibleCell.shakeIcons()
            }
        }
    }    
    // This function is fired when the collection view stop scrolling
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let visibleCells = self.contactsCollectionView.visibleCells
        
        if editModeEnabled == true {
            for cell in visibleCells {
                let visibleCellIndexPath = contactsCollectionView.indexPath(for: cell)
                let visibleCell = contactsCollectionView.cellForItem(at: visibleCellIndexPath!) as! contactsCollectionViewCell
                // Shake all of the collection view cells
                visibleCell.shakeIcons()
            }
        }
    }

    
    // MARK: - UICollectionViewFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let picDimension = 55
        return CGSize(width: picDimension, height: picDimension)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    
    
    fileprivate func checkContactsAccess() {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        // Update our UI if the user has granted access to their Contacts
        case .authorized:
            self.showContactsPicker()
        // Prompt the user for access to Contacts if there is no definitive answer
        case .notDetermined :
            self.requestContactsAccess()
        // Display a message if the user has denied or restricted access to Contacts
        case .denied,
             .restricted:
            let alert = UIAlertController(title: "Privacy Warning!",
                                          message: "Please Enable permission! in settings!.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    fileprivate func requestContactsAccess() {
        addressBookStore.requestAccess(for: .contacts) {granted, error in
            if granted {
                DispatchQueue.main.async {
                    self.showContactsPicker()
                    return
                }
            }
        }
    }
    
    //Show Contact Picker
    fileprivate  func showContactsPicker() {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        contactIDs = SavedPreferencesForTrip["contacts_in_group"] as? [NSString]
        
        picker.delegate = self
        picker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        
        if (contactIDs?.count)! > 0 {
            picker.predicateForEnablingContact = NSPredicate(format:"(phoneNumbers.@count > 0) AND NOT (identifier in %@)", contactIDs!)
        } else {
            picker.predicateForEnablingContact = NSPredicate(format:"(phoneNumbers.@count > 0)")
        }
        picker.predicateForSelectionOfContact = NSPredicate(format:"phoneNumbers.@count == 1")
        self.present(picker , animated: true, completion: nil)
    }
    
    func retrieveContactsWithStore(store: CNContactStore) {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        contactIDs = SavedPreferencesForTrip["contacts_in_group"] as? [NSString]
        contactPhoneNumbers = (SavedPreferencesForTrip["contact_phone_numbers"] as? [NSString])!
        
        do {
            if (contactIDs?.count)! > 0 {
                let predicate = CNContact.predicateForContacts(withIdentifiers: contactIDs! as [String])
                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey, CNContactImageDataAvailableKey] as [Any]
                let updatedContacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                
                var reorderedUpdatedContacts = [CNContact]()
                for contactID in contactIDs! {
                    for updatedContact in updatedContacts {
                        if updatedContact.identifier as NSString == contactID {
                            reorderedUpdatedContacts.append(updatedContact)
                        }
                    }
                }
                self.contacts = reorderedUpdatedContacts
                
                //Update trip preferences dictionary
                let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
                SavedPreferencesForTrip["contacts_in_group"] = contactIDs
                SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
                
            } else {
                self.contacts = nil
            }
        } catch {
            print(error)
        }
    }
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        
        if (contactIDs?.count)! > 0 {
            contacts?.append(contactProperty.contact)
            contactIDs?.append(contactProperty.contact.identifier as NSString)
            let allPhoneNumbersForContact = contactProperty.contact.phoneNumbers
            var indexForCorrectPhoneNumber: Int?
            for indexOfPhoneNumber in 0...(allPhoneNumbersForContact.count - 1) {
                if allPhoneNumbersForContact[indexOfPhoneNumber].value == contactProperty.value as! CNPhoneNumber {
                    indexForCorrectPhoneNumber = indexOfPhoneNumber
                }
            }
            let phoneNumberToAdd = contactProperty.contact.phoneNumbers[indexForCorrectPhoneNumber!].value.value(forKey: "digits") as! NSString
            contactPhoneNumbers.append(phoneNumberToAdd)
            
            let numberContactsInTable = (contacts?.count)! - 1
            
            //Update trip preferences dictionary
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["contacts_in_group"] = contactIDs
            SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
            
            //Save updated trip preferences dictionary
            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            let addedRowIndexPath = [IndexPath(row: numberContactsInTable, section: 0)]
            
            contactsCollectionView.insertItems(at: addedRowIndexPath as [IndexPath])
        }
        else {
            contacts = [contactProperty.contact]
            contactIDs = [contactProperty.contact.identifier as NSString]
            let allPhoneNumbersForContact = contactProperty.contact.phoneNumbers
            var indexForCorrectPhoneNumber: Int?
            for indexOfPhoneNumber in 0...(allPhoneNumbersForContact.count - 1) {
                if allPhoneNumbersForContact[indexOfPhoneNumber].value == contactProperty.value as! CNPhoneNumber {
                    indexForCorrectPhoneNumber = indexOfPhoneNumber
                }
            }
            let phoneNumberToAdd = contactProperty.contact.phoneNumbers[indexForCorrectPhoneNumber!].value.value(forKey: "digits") as! NSString
            contactPhoneNumbers = [phoneNumberToAdd]
            
            //Update trip preferences dictionary
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["contacts_in_group"] = contactIDs
            SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
            
            //Save updated trip preferences dictionary
            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            let addedRowIndexPath = [IndexPath(row: 0, section: 0)]
            contactsCollectionView.insertItems(at: addedRowIndexPath)
        }
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
        //Update changed preferences as variables
        if (contactIDs?.count)! > 0 {
            contacts?.append(contact)
            contactIDs?.append(contact.identifier as NSString)
            let phoneNumberToAdd = contact.phoneNumbers[0].value.value(forKey: "digits") as! NSString
            contactPhoneNumbers.append(phoneNumberToAdd)
            
            let numberContactsInTable = (contacts?.count)! - 1
            
            //Update trip preferences dictionary
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["contacts_in_group"] = contactIDs
            SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
            
            //Save updated trip preferences dictionary
            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            let addedRowIndexPath = [IndexPath(row: numberContactsInTable, section: 0)]
            contactsCollectionView.insertItems(at: addedRowIndexPath)
        }
        else {
            contacts = [contact]
            contactIDs = [contact.identifier as NSString]
            let phoneNumberToAdd = contact.phoneNumbers[0].value.value(forKey: "digits") as! NSString
            contactPhoneNumbers = [phoneNumberToAdd]
            
            //Update trip preferences dictionary
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["contacts_in_group"] = contactIDs
            SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
            
            //Save updated trip preferences dictionary
            saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            let addedRowIndexPath = [IndexPath(row: 0, section: 0)]
            contactsCollectionView.insertItems(at: addedRowIndexPath)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
        tripNameLabel.resignFirstResponder()
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func deleteContact(indexPath: IndexPath) {
        contacts?.remove(at: indexPath.row)
        contactIDs?.remove(at: indexPath.row)
        contactPhoneNumbers.remove(at: indexPath.row)
        contactsCollectionView.deleteItems(at: [indexPath])
        
        let visibleContactsCells = contactsCollectionView.visibleCells as! [contactsCollectionViewCell]
        for visibleContactCell in visibleContactsCells {
            let newIndexPathForItem = contactsCollectionView.indexPath(for: visibleContactCell)
            visibleContactCell.deleteButton.layer.setValue(newIndexPathForItem?.row, forKey: "index")
        }
        
        if contacts?.count == 0 || contacts == nil {
            dismissDeleteContactsMode()
        }
        
        //Update trip preferences dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["contacts_in_group"] = contactIDs
        SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
        //Save updated trip preferences dictionary
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    //MARK: Actions
    func deleteContactButtonTouchedUpInside(sender:UIButton) {
        let i: Int = (sender.layer.value(forKey: "index")) as! Int
        deleteContact(indexPath: IndexPath(row:i, section: 0))
    }
    @IBAction func instructionsGotItTouchedUpInside(_ sender: Any) {
        UIView.animate(withDuration: 0.3, animations: {
            self.swipingInstructionsView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.swipingInstructionsView.alpha = 0
            self.popupBackgroundViewMainVC.isHidden = true
            self.swipeableView.isUserInteractionEnabled = true
            self.nextButton.alpha = 1
            self.contactsCollectionView.alpha = 1
            self.addContactPlusIconMainVC.alpha = 1
        }) { (Success:Bool) in
            self.swipingInstructionsView.layer.isHidden = true
        }
    }
    @IBAction func tripNameLabelEditingChanged(_ sender: Any) {
        let tripNameValue = tripNameLabel.text! as NSString
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["trip_name"] = tripNameValue
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    @IBAction func nextButtonTouchedUpInside(_ sender: Any) {
        updateCompletionStatus()
    }
    
    @IBAction func addContact(_ sender: Any) {
        checkContactsAccess()
    }
    @IBAction func addFromContacts(_ sender: Any) {
        checkContactsAccess()
    }
    
    @IBAction func rejectSelected(_ sender: Any) {
        leftButtonAction()
    }
    
    @IBAction func heartSelected(_ sender: Any) {
        rightButtonAction()
    }
    
    
    func updateCompletionStatus(){
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["To_Do_Finished"] = "Name_Contacts_Rooms" as NSString
        //Save
        saveUpdatedExistingTrip(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    ////// ADD NEW TRIP VARS (NS ONLY) HERE ///////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func fetchSavedPreferencesForTrip() -> NSMutableDictionary {
        //Update preference vars if an existing trip
        //Trip status
        let bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "booking_status") as? NSNumber ?? 0 as NSNumber
        let finishedEnteringPreferencesStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "finished_entering_preferences_status") as? NSString ?? NSString()
        //New Trip VC
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? NSString ?? NSString()
        let contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString] ?? [NSString]()
        let contactPhoneNumbers = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contact_phone_numbers") as? [NSString] ?? [NSString]()
        let hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? [NSNumber] ?? [NSNumber]()
        //Calendar VC
        let segmentLengthValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "Availability_segment_lengths") as? [NSNumber] ?? [NSNumber]()
        let selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [NSDate] ?? [NSDate]()
        let leftDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "origin_departure_times") as? NSDictionary ?? NSDictionary()
        let rightDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "return_departure_times") as? NSDictionary ?? NSDictionary()
        //Budget VC
        let budgetValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "budget") as? NSString ?? NSString()
        let expectedRoundtripFare = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_roundtrip_fare") as? NSString ?? NSString()
        let expectedNightlyRate = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_nightly_rate") as? NSString ?? NSString()
        //Suggested Destination VC
        let decidedOnDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_control") as? NSString ?? NSString()
        let decidedOnDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_value") as? NSString ?? NSString()
        let suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? NSString ?? NSString()
        let suggestedDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggested_destination") as? NSString ?? NSString()
        //Activities VC
        let selectedActivities = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_activities") as? [NSString] ?? [NSString]()
        //Ranking VC
        let topTrips = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "top_trips") as? [NSString] ?? [NSString]()
        
        //SavedPreferences
        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus, "finished_entering_preferences_status": finishedEnteringPreferencesStatus, "trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips] as NSMutableDictionary
        
        return fetchedSavedPreferencesForTrip
    }
    
    func saveUpdatedExistingTrip(SavedPreferencesForTrip: NSMutableDictionary) {
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        existing_trips?[currentTripIndex] = SavedPreferencesForTrip as NSDictionary
        DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
    }
}
