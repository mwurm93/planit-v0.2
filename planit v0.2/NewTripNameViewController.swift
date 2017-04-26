//
//  NewTripNameViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/17/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit
import ContactsUI
import Contacts
import JTAppleCalendar
import UIColor_FlatColors
import Cartography

private var numberOfCards: Int = 5

class NewTripNameViewController: UIViewController, UITextFieldDelegate, CNContactPickerDelegate, CNContactViewControllerDelegate, UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UIGestureRecognizerDelegate, UICollectionViewDelegateFlowLayout {
    
    fileprivate var dataSource: [UIImage] = {
        var array: [UIImage] = []
        for index in 0..<numberOfCards {
            array.append(UIImage(named: "Card_like_\(index + 1)")!)
        }
        
        return array
    }()
    
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
    
    //main VC vars
    fileprivate var addressBookStore: CNContactStore!
    fileprivate var menuArray: NSMutableArray?
    let picker = CNContactPickerViewController()
    var contacts: [CNContact]?
    var objects: [NSObject]?
    var contactIDs: [NSString]?
    var objectIDs: [NSString]?
    var objectPhoneNumbers = [NSString]()
    var contactPhoneNumbers = [NSString]()
    var NewOrAddedTripFromSegue: Int?
    var effect:UIVisualEffect!
    var countSwipes = 0
    
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
    @IBOutlet weak var groupMemberListTable: UITableView!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var addFromContactsButton: UIButton!
    @IBOutlet weak var addFromFacebookButton: UIButton!
    @IBOutlet weak var soloForNowButton: UIButton!
    @IBOutlet weak var ranOutOfSwipesLabel: UILabel!
    @IBOutlet weak var contactsCollectionView: UICollectionView!
    @IBOutlet weak var popupBlurView: UIVisualEffectView!
    @IBOutlet weak var addContactPlusIconMainVC: UIButton!
    @IBOutlet weak var timeOfDayTableView: UITableView!
    @IBOutlet weak var popupBackgroundView: UIView!
    @IBOutlet weak var calendarView: JTAppleCalendarView!
    @IBOutlet weak var popupBackgroundViewMainVC: UIView!
    @IBOutlet weak var swipingInstructionsView: UIView!
    @IBOutlet var popupSubview: UIView!
    @IBOutlet weak var subviewWhereButton: UIButton!
    @IBOutlet weak var subviewWhoButton: UIButton!
    @IBOutlet weak var subviewWhenButton: UIButton!
    @IBOutlet weak var underline: UIImageView!
    @IBOutlet weak var subviewDoneButton: UIButton!
    @IBOutlet weak var homeAirportTextField: UITextField!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var nextMonth: UIButton!
    @IBOutlet weak var previousMonth: UIButton!
    @IBOutlet weak var subviewNextButton: UIButton!
    @IBOutlet weak var month1: UIButton!
    @IBOutlet weak var month2: UIButton!
    @IBOutlet weak var month3: UIButton!
    @IBOutlet weak var month4: UIButton!
    @IBOutlet weak var specificDatesButton: UIButton!
    @IBOutlet weak var weekend: UIButton!
    @IBOutlet weak var oneWeek: UIButton!
    @IBOutlet weak var twoWeeks: UIButton!
    @IBOutlet weak var noSpecificDatesButton: UIButton!
    @IBOutlet weak var swipeableView: ZLSwipeableView!
    @IBOutlet weak var detailedCardView: UIScrollView!
    @IBOutlet weak var numberDestinationsSlider: UISlider!
    @IBOutlet weak var numberDestinationsStackView: UIStackView!
    @IBOutlet weak var tripNameLabel: UITextField!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        swipeableView.nextView = {
            return self.nextCardView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load the values from our shared data container singleton
        if NewOrAddedTripFromSegue != 1 {
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        //Install the value into the label.
        if tripNameValue != nil {
            self.tripNameLabel.text =  "\(tripNameValue!)"
        }
        }
        detailedCardView.isHidden = true
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(self.panRecognized(recognizer:)))
        panGestureRecognizer.delegate = self
        detailedCardView.addGestureRecognizer(panGestureRecognizer)
        detailedCardView.layer.cornerRadius = 15
        
        weekend.layer.cornerRadius = 15
        oneWeek.layer.cornerRadius = 15
        twoWeeks.layer.cornerRadius = 15
        month1.layer.cornerRadius = 15
        month2.layer.cornerRadius = 15
        month3.layer.cornerRadius = 15
        month4.layer.cornerRadius = 15
        
        weekend.backgroundColor = UIColor.darkGray
        oneWeek.backgroundColor = UIColor.darkGray
        twoWeeks.backgroundColor = UIColor.darkGray
        month1.backgroundColor = UIColor.darkGray
        month2.backgroundColor = UIColor.darkGray
        month3.backgroundColor = UIColor.darkGray
        month4.backgroundColor = UIColor.darkGray
        
        let monthDateFormatter = DateFormatter()
        monthDateFormatter.dateFormat = "MM"
        let currentMonth = monthDateFormatter.string(from: Date())
        let month1Numerical = Int(currentMonth)
        let month2Numerical = month1Numerical! + 1
        let month3Numerical = month1Numerical! + 2
        let month4Numerical = month1Numerical! + 3
        month1.setTitle("\(getMonth(Month: month1Numerical!))",for: .normal)
        month2.setTitle("\(getMonth(Month: month2Numerical))",for: .normal)
        month3.setTitle("\(getMonth(Month: month3Numerical))",for: .normal)
        month4.setTitle("\(getMonth(Month: month4Numerical))",for: .normal)
        month1.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        month2.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        month3.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        month4.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        weekend.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        oneWeek.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)
        twoWeeks.addTarget(self, action: #selector(self.buttonClicked(sender:)), for: UIControlEvents.touchUpInside)

        
        popupSubview.layer.cornerRadius = 10
        subviewDoneButton.isHidden = true
        
        //Calendar subview
        // Set up tap outside time of day table
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.dismissPopup(touch:)))
        tap.numberOfTapsRequired = 1
        tap.delegate = self
        popupBackgroundView.isHidden = true
        self.popupBackgroundView.addGestureRecognizer(tap)
        
        //Time of Day
        timeOfDayTableView.delegate = self
        timeOfDayTableView.dataSource = self
        timeOfDayTableView.layer.cornerRadius = 5
        timeOfDayTableView.layer.isHidden = true
        timeOfDayTableView.allowsMultipleSelection = true
        
        //Number Destinations Slider
        numberDestinationsSlider.isContinuous = false
        numberDestinationsSlider.isHidden = true
        numberDestinationsStackView.isHidden = true
        
        //Trip Name textField
        self.tripNameLabel.delegate = self
        
        //home airport textfield
        self.homeAirportTextField.delegate = self
        homeAirportTextField.layer.borderWidth = 1
        homeAirportTextField.layer.borderColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        homeAirportTextField.layer.masksToBounds = true
        homeAirportTextField.layer.cornerRadius = 5
        homeAirportTextField.text =  "\(homeAirportValue)"
        let homeAirportLabelPlaceholder = homeAirportTextField!.value(forKey: "placeholderLabel") as? UILabel
        homeAirportLabelPlaceholder?.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        // Calendar header setup
        calendarView.registerHeaderView(xibFileNames: ["monthHeaderView"])
        
        // Calendar setup delegate and datasource
        calendarView.dataSource = self
        calendarView.delegate = self
        calendarView.registerCellViewXib(file: "CellView")
        calendarView.allowsMultipleSelection  = true
        calendarView.rangeSelectionWillBeUsed = true
        calendarView.cellInset = CGPoint(x: 0, y: 2)
        calendarView.scrollingMode = .nonStopToSection(withResistance: 0.9)
        calendarView.direction = .horizontal
        
        // Load trip preferences and install
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let selectedDatesValue = SavedPreferencesForTrip["selected_dates"] as? [NSDate]
        if (selectedDatesValue?.count)! > 0 {
            self.calendarView.selectDates(selectedDatesValue! as [Date],triggerSelectionDelegate: false)
        }
        
        //Main VC
        
        let atap = UITapGestureRecognizer(target: self, action: #selector(self.dismissInstructions(touch:)))
        atap.numberOfTapsRequired = 1
        atap.delegate = self
        self.popupBackgroundViewMainVC.addGestureRecognizer(atap)
        popupBackgroundViewMainVC.isHidden = true
        swipingInstructionsView.isHidden = true
        swipingInstructionsView.layer.cornerRadius = 10

        effect = popupBlurView.effect
        popupBlurView.effect = nil
        
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        
        heartIcon.setImage(#imageLiteral(resourceName: "fullHeart"), for: .highlighted)
        rejectIcon.setImage(#imageLiteral(resourceName: "fullX"), for: .highlighted)
        ranOutOfSwipesLabel.isHidden = true
        
        view.autoresizingMask = .flexibleTopMargin
        view.sizeToFit()
        
//        self.hideKeyboardWhenTappedAround()
        addressBookStore = CNContactStore()
        
        if NewOrAddedTripFromSegue == 1 {
            nextButton.alpha =  0
            contactsCollectionView.alpha = 0
            addContactPlusIconMainVC.alpha = 0
            
            let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
            if existing_trips == nil {
                let when = DispatchTime.now() + 0.6
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.animateInstructionsIn()
                }
            }
        } else {
            retrieveContactsWithStore(store: addressBookStore)
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
                    self.countSwipes += 1
                    if self.countSwipes == 1 && self.NewOrAddedTripFromSegue == 1 {
                        self.animateInSubview()
                    }

                    let when = DispatchTime.now() + 0.8

            if direction == .Right {
                self.heartIcon.isHighlighted = true
                DispatchQueue.main.asyncAfter(deadline: when) {
                    self.heartIcon.isHighlighted = false
                }
            }

            
            if direction == .Left {
                    self.rejectIcon.isHighlighted = true
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        self.rejectIcon.isHighlighted = false
                    }
            }

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
            
            let contentView = Bundle.main.loadNibNamed("CardContentView", owner: self, options: nil)?.first! as! UIView
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
    
    func roundSlider() {
        //Update changed preferences
        let numberDestinationsValue = [NSNumber(value: (round(numberDestinationsSlider.value / sliderStep)))]
        numberDestinationsSlider.setValue(Float(numberDestinationsValue[0]), animated: true)
        
//        //Update trip preferences dictionary
//        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
//        SavedPreferencesForTrip["hotel_rooms"] = hotelRoomsValue
//        //Save updated trip preferences dictionary
//        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }

    
    //Dismissing detailed card view
    public func panRecognized(recognizer:UIPanGestureRecognizer) {
        let bounds = UIScreen.main.bounds
        let width = bounds.size.width
        let height = bounds.size.height
        let dismissTriggerOffset = height/3
        
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
                UIView.animate(withDuration: 0.6, animations: { () -> Void in
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
        
        let cardView = CardView(frame: swipeableView.bounds)
        cardView.backgroundColor = colorForName(colors[colorIndex])
        colorIndex += 1
        
        if loadCardsFromXib {
            let contentView = Bundle.main.loadNibNamed("CardContentView", owner: self, options: nil)?.first! as! UIView
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
    func dismissPopup(touch: UITapGestureRecognizer) {
        if timeOfDayTableView.indexPathsForSelectedRows != nil {
            dismissTimeOfDayTableOut()
            popupBackgroundView.isHidden = true
            
            let when = DispatchTime.now() + 0.6
            DispatchQueue.main.asyncAfter(deadline: when) {
                if self.leftDateTimeArrays.count == self.rightDateTimeArrays.count {
                }
            }
        }
    }
    
    func dismissInstructions(touch: UITapGestureRecognizer) {
        UIView.animate(withDuration: 0.3, animations: {
            self.swipingInstructionsView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.swipingInstructionsView.alpha = 0
            self.popupBackgroundViewMainVC.isHidden = true
            self.swipeableView.isUserInteractionEnabled = true
        }) { (Success:Bool) in
            self.swipingInstructionsView.layer.isHidden = true
        }
    }
    
    
    // MARK: - UICollectionViewDataSource
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
        
        retrieveContactsWithStore(store: addressBookStore)
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
        
        return contactsCell
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
        objectIDs = SavedPreferencesForTrip["contacts_in_group"] as? [NSString]
        
        picker.delegate = self
        picker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        if (objectIDs?.count)! > 0 {
            picker.predicateForEnablingContact = NSPredicate(format:"(phoneNumbers.@count > 0) AND NOT (identifier in %@)", objectIDs!)
        } else {
            picker.predicateForEnablingContact = NSPredicate(format:"(phoneNumbers.@count > 0)")
        }
        picker.predicateForSelectionOfContact = NSPredicate(format:"phoneNumbers.@count == 1")
        self.present(picker , animated: true, completion: nil)
    }
    
    func retrieveContactsWithStore(store: CNContactStore) {
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        objectIDs = SavedPreferencesForTrip["contacts_in_group"] as? [NSString]
        
        do {
            if (objectIDs?.count)! > 0 {
                let predicate = CNContact.predicateForContacts(withIdentifiers: objectIDs as! [String])
                let keysToFetch = [CNContactFormatter.descriptorForRequiredKeys(for: .fullName), CNContactPhoneNumbersKey, CNContactThumbnailImageDataKey, CNContactImageDataAvailableKey] as [Any]
                let contacts = try store.unifiedContacts(matching: predicate, keysToFetch: keysToFetch as! [CNKeyDescriptor])
                self.objects = contacts
                self.contacts = contacts
            } else {
                self.objects = nil
            }
            DispatchQueue.main.async (execute: { () -> Void in
                self.contactsCollectionView.reloadData()
            })
        } catch {
            print(error)
        }
    }
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
        
        if contactIDs != nil {
            contacts?.append(contactProperty.contact)
            objects?.append(contactProperty.contact as NSObject)
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
            
            let numberContactsInTable = contactsCollectionView.numberOfItems(inSection: 0)
            
            //Update trip preferences dictionary
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["contacts_in_group"] = contactIDs
            SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
            
            //Save updated trip preferences dictionary
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            let addedRowIndexPath = [NSIndexPath(row: numberContactsInTable, section: 0)]
            self.contactsCollectionView.insertItems(at: addedRowIndexPath as [IndexPath])
            self.contactsCollectionView.reloadData()
            groupMemberListTable.insertRows(at: addedRowIndexPath as [IndexPath], with: .left)
            groupMemberListTable.reloadData()
        }
        else {
            contacts = [contactProperty.contact]
            objects = [contactProperty.contact as NSObject]
            contactIDs = [contactProperty.contact.identifier as NSString]
            let allPhoneNumbersForContact = contactProperty.contact.phoneNumbers
            var indexForCorrectPhoneNumber: Int?
            for indexOfPhoneNumber in 0...(allPhoneNumbersForContact.count - 1) {
                if allPhoneNumbersForContact[indexOfPhoneNumber].value == contactProperty.value as! CNPhoneNumber {
                    indexForCorrectPhoneNumber = indexOfPhoneNumber
                }
            }
            let phoneNumberToAdd = contactProperty.contact.phoneNumbers[indexForCorrectPhoneNumber!].value.value(forKey: "digits") as! NSString
            contactPhoneNumbers.append(phoneNumberToAdd)
            
            //Update trip preferences dictionary
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["contacts_in_group"] = contactIDs
            SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
            
            //Save updated trip preferences dictionary
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            let addedRowIndexPath = [IndexPath(row: 0, section: 0)]
            self.contactsCollectionView.insertItems(at: addedRowIndexPath)
            self.contactsCollectionView.reloadData()
            groupMemberListTable.insertRows(at: addedRowIndexPath, with: .left)
            groupMemberListTable.reloadData()
        }
            addFromContactsButton.layer.frame = CGRect(x: 101, y: 140, width: 148, height: 22)
            addFromFacebookButton.layer.frame = CGRect(x: 95, y: 170, width: 160, height: 22)
            soloForNowButton.isHidden = true
            groupMemberListTable.isHidden = false
            groupMemberListTable.layer.frame = CGRect(x: 29, y: 200, width: 292, height: 221)
            subviewDoneButton.isHidden = false
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
        //Update changed preferences as variables
        if contactIDs != nil {
            contacts?.append(contact)
            objects?.append(contact as NSObject)
            contactIDs?.append(contact.identifier as NSString)
            let phoneNumberToAdd = contact.phoneNumbers[0].value.value(forKey: "digits") as! NSString
            contactPhoneNumbers.append(phoneNumberToAdd)
            
            let numberContactsInTable = contactsCollectionView.numberOfItems(inSection: 0)
            
            //Update trip preferences dictionary
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["contacts_in_group"] = contactIDs
            SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
            
            //Save updated trip preferences dictionary
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            let addedRowIndexPath = [IndexPath(row: numberContactsInTable, section: 0)]
            self.contactsCollectionView.insertItems(at: addedRowIndexPath)
            self.contactsCollectionView.reloadData()
            groupMemberListTable.insertRows(at: addedRowIndexPath as [IndexPath], with: .left)
            groupMemberListTable.reloadData()
        }
        else {
            contacts = [contact]
            objects = [contact as NSObject]
            contactIDs = [contact.identifier as NSString]
            let phoneNumberToAdd = contact.phoneNumbers[0].value.value(forKey: "digits") as! NSString
            contactPhoneNumbers.append(phoneNumberToAdd)
            
            //Update trip preferences dictionary
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["contacts_in_group"] = contactIDs
            SavedPreferencesForTrip["contact_phone_numbers"] = contactPhoneNumbers
            
            //Save updated trip preferences dictionary
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
            
            let addedRowIndexPath = [IndexPath(row: 0, section: 0)]
            self.contactsCollectionView.insertItems(at: addedRowIndexPath)
            self.contactsCollectionView.reloadData()
            groupMemberListTable.insertRows(at: addedRowIndexPath, with: .left)
            groupMemberListTable.reloadData()
        }
        
        addFromContactsButton.layer.frame = CGRect(x: 101, y: 140, width: 148, height: 22)
        addFromFacebookButton.layer.frame = CGRect(x: 95, y: 170, width: 160, height: 22)
        soloForNowButton.isHidden = true
        groupMemberListTable.isHidden = false
        groupMemberListTable.layer.frame = CGRect(x: 29, y: 200, width: 292, height: 221)
        subviewDoneButton.isHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField:  UITextField) -> Bool {
        // Hide the keyboard.
        homeAirportTextField.resignFirstResponder()
        tripNameLabel.resignFirstResponder()
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        let segmentLengthValue = SavedPreferencesForTrip["Availability_segment_lengths"] as! [NSNumber]
        if segmentLengthValue.count > 0 {
            var maxSegmentLength = 0
            for segmentIndex in 0...(segmentLengthValue.count-1) {
                if (Int(segmentLengthValue[segmentIndex])) > maxSegmentLength {
                    maxSegmentLength = (Int(segmentLengthValue[segmentIndex]))
                }
            }
            if maxSegmentLength >= 4 {
                numberDestinationsStackView.isHidden = false
                numberDestinationsSlider.isHidden = false
                homeAirportTextField.isHidden = true
                questionLabel.text = "How many destinations?"
                subviewNextButton.isHidden = false
            } else {
                subviewWho()
            }
        } else {
            subviewWho()
        }
        
        return true
    }
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    // MARK: UITableviewdelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 0
        
        if tableView == timeOfDayTableView {
            numberOfRows = 7
        }
        if tableView == groupMemberListTable {
            if contacts != nil {
                numberOfRows += contacts!.count
            }
        }
        return numberOfRows
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == timeOfDayTableView {
        let cell = tableView.dequeueReusableCell(withIdentifier: "timeOfDayPrototypeCell", for: indexPath) as! timeOfDayTableViewCell
        cell.timeOfDayTableLabel.text = timesOfDayArray[indexPath.row]
        return cell
        }
//        else if tableView == groupMemberListTable {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactsPrototypeCell", for: indexPath) as! contactsTableViewCell
        let contacts = objects as! [CNContact]?
        
        if contacts != nil {
        let contact = contacts?[indexPath.row]
        cell.nameLabel.text = (contact?.givenName)! + " " + (contact?.familyName)!
        
        if (contact?.imageDataAvailable)! {
            cell.thumbnailImage.image = UIImage(data: (contact?.thumbnailImageData!)!)
            cell.thumbnailImage.contentMode = .scaleToFill
            let reCenter = cell.thumbnailImage.center
            cell.thumbnailImage.layer.frame = CGRect(x: cell.thumbnailImage.layer.frame.minX
                , y: cell.thumbnailImage.layer.frame.minY, width: cell.thumbnailImage.layer.frame.width * 0.96, height: cell.thumbnailImage.layer.frame.height * 0.96)
            cell.thumbnailImage.center = reCenter
            cell.thumbnailImage.layer.cornerRadius = cell.thumbnailImage.frame.height / 2
            cell.thumbnailImage.layer.masksToBounds = true
            cell.initialsLabel.isHidden = true
        } else{
            cell.thumbnailImage.image = UIImage(named: "no_contact_image")!
            cell.initialsLabel.isHidden = false
            let firstInitial = contact?.givenName[0]
            let secondInitial = contact?.familyName[0]
            cell.initialsLabel.text = firstInitial! + secondInitial!
        }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == timeOfDayTableView {
        let topRows = [IndexPath(row:0, section: 0),IndexPath(row:1, section: 0),IndexPath(row:2, section: 0),IndexPath(row:3, section: 0),IndexPath(row:4, section: 0),IndexPath(row:5, section: 0)]
        if indexPath == IndexPath(row:6, section: 0) {
            for rowIndex in topRows {
                self.timeOfDayTableView.deselectRow(at: rowIndex, animated: false)
            }
        }
        if topRows.contains(indexPath) {
            self.timeOfDayTableView.deselectRow(at: IndexPath(row:6, section:0), animated: false)
        }
        
        let selectedTimesOfDay = timeOfDayTableView.indexPathsForSelectedRows
        var availableTimeOfDayInCell = [String]()
        for indexPath in selectedTimesOfDay! {
            let cell = timeOfDayTableView.cellForRow(at: indexPath) as! timeOfDayTableViewCell
            availableTimeOfDayInCell.append(cell.timeOfDayTableLabel.text!)
        }
        let timeOfDayToAddToArray = availableTimeOfDayInCell.joined(separator: ", ") as NSString
        
        let cell = calendarView.cellStatus(for: mostRecentSelectedCellDate as Date)
        if cell?.selectedPosition() == .full || cell?.selectedPosition() == .left {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy MM dd"
            let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
            leftDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
        }
        if cell?.selectedPosition() == .right {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy MM dd"
            let mostRecentSelectedCellDateAsNSString = formatter.string(from: mostRecentSelectedCellDate as Date)
            rightDateTimeArrays.setValue(timeOfDayToAddToArray as NSString, forKey: mostRecentSelectedCellDateAsNSString)
        }
        
        //Update trip preferences in dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["origin_departure_times"] = leftDateTimeArrays as NSDictionary
        SavedPreferencesForTrip["return_departure_times"] = rightDateTimeArrays as NSDictionary
        //Save
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    }

    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.delete) {
            objectPhoneNumbers = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contact_phone_numbers") as? [NSString] ?? [NSString]()
            
            objects?.remove(at: indexPath.row)
            objectIDs?.remove(at: indexPath.row)
            objectPhoneNumbers.remove(at: indexPath.row)
            contacts?.remove(at: indexPath.row)
            contactIDs?.remove(at: indexPath.row)
            contactPhoneNumbers.remove(at: indexPath.row)
            
            groupMemberListTable.deleteRows(at: [indexPath], with: .left)
            contactsCollectionView.deleteItems(at: [indexPath])
            
            if objects?.count == 0 || objects == nil || contacts?.count == 0 || contacts == nil{
                addFromContactsButton.layer.frame = CGRect(x: 101, y: 150, width: 148, height: 22)
                addFromFacebookButton.layer.frame = CGRect(x: 95, y: 199, width: 160, height: 22)
                soloForNowButton.isHidden = false
                soloForNowButton.layer.frame = CGRect(x: 101, y: 248, width: 148, height: 22)
                groupMemberListTable.isHidden = true
                subviewNextButton.isHidden = true
            }
            
            //Update trip preferences dictionary
            let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
            SavedPreferencesForTrip["contacts_in_group"] = objectIDs
            SavedPreferencesForTrip["contact_phone_numbers"] = objectPhoneNumbers
            //Save updated trip preferences dictionary
            saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Remove"
    }
    
    func animateInSubview(){
        //Animate In Subview
        self.view.addSubview(popupSubview)
        popupSubview.center = self.view.center
        popupSubview.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        popupSubview.alpha = 0
        UIView.animate(withDuration: 0.2) {
            self.popupBlurView.effect = self.effect
            self.popupSubview.alpha = 1
            self.popupSubview.transform = CGAffineTransform.identity
        }
        
        //Set to when
        underline.layer.frame = CGRect(x: 50, y: 30, width: 55, height: 51)
        subviewWhen()
        
        //Create trip name
        if tripNameLabel.text == "New Trip"{
        var tripNameValue = "Trip created \(Date().description.substring(to: 10))"
        //Check if trip name used already
        if DataContainerSingleton.sharedDataContainer.usertrippreferences != nil && DataContainerSingleton.sharedDataContainer.usertrippreferences?.count != 0 {
            var countTripsMadeToday = 0
            for trip in 0...((DataContainerSingleton.sharedDataContainer.usertrippreferences?.count)! - 1) {
                if (DataContainerSingleton.sharedDataContainer.usertrippreferences?[trip].object(forKey: "trip_name") as? String)!.substring(to: 23) == tripNameValue {
                    countTripsMadeToday += 1
                }
            }
            if countTripsMadeToday != 0 {
                tripNameValue = "Trip " + ("#\(countTripsMadeToday+1) ") + tripNameValue.substring(from: 5)
            }
        }
        
        tripNameLabel.text = tripNameValue
        
        //Update trip preferences in dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["trip_name"] = tripNameValue as NSString
        //Save
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
        }
    }
    
    func subviewWhere() {
        //Set to where
        questionLabel.text = "Where are you leaving from?"
        questionLabel.isHidden = false
        homeAirportTextField.isHidden = false
        homeAirportTextField.becomeFirstResponder()
        groupMemberListTable.isHidden = true
        addFromContactsButton.isHidden = true
        addFromFacebookButton.isHidden = true
        soloForNowButton.isHidden = true
        subviewNextButton.isHidden = true
        calendarView.isHidden = true
        nextMonth.isHidden = true
        previousMonth.isHidden = true
        popupBackgroundView.isHidden = true
        timeOfDayTableView.isHidden = true
        subviewDoneButton.isHidden = true
        month1.isHidden = true
        month2.isHidden = true
        month3.isHidden = true
        month4.isHidden = true
        weekend.isHidden = true
        oneWeek.isHidden = true
        twoWeeks.isHidden = true
        specificDatesButton.isHidden = true
        noSpecificDatesButton.isHidden = true
        numberDestinationsSlider.isHidden = true
        numberDestinationsStackView.isHidden = true
        UIView.animate(withDuration: 0.4) {
            self.underline.layer.frame = CGRect(x: 148, y: 30, width: 55, height: 51)
        }
    }

    func subviewWho(){
        subviewWhereButton.tintColor = UIColor.green
        questionLabel.text = "Do you have a group in mind?"
        questionLabel.isHidden = false
        homeAirportTextField.isHidden = true
        homeAirportTextField.resignFirstResponder()
        groupMemberListTable.isHidden = true
        addFromContactsButton.isHidden = false
        addFromFacebookButton.isHidden = false
        soloForNowButton.isHidden = false
        subviewNextButton.isHidden = true
        calendarView.isHidden = true
        nextMonth.isHidden = true
        previousMonth.isHidden = true
        popupBackgroundView.isHidden = true
        timeOfDayTableView.isHidden = true
        subviewDoneButton.isHidden = true
        month1.isHidden = true
        month2.isHidden = true
        month3.isHidden = true
        month4.isHidden = true
        weekend.isHidden = true
        oneWeek.isHidden = true
        twoWeeks.isHidden = true
        specificDatesButton.isHidden = true
        noSpecificDatesButton.isHidden = true
        numberDestinationsSlider.isHidden = true
        numberDestinationsStackView.isHidden = true
        
        if contacts != nil {
            addFromContactsButton.layer.frame = CGRect(x: 101, y: 140, width: 148, height: 22)
            addFromFacebookButton.layer.frame = CGRect(x: 95, y: 170, width: 160, height: 22)
            soloForNowButton.isHidden = true
            groupMemberListTable.isHidden = false
            groupMemberListTable.layer.frame = CGRect(x: 29, y: 200, width: 292, height: 221)
            subviewNextButton.isHidden = false
        } else {
            addFromContactsButton.layer.frame = CGRect(x: 101, y: 150, width: 148, height: 22)
            addFromFacebookButton.layer.frame = CGRect(x: 95, y: 199, width: 160, height: 22)
            soloForNowButton.isHidden = false
            soloForNowButton.layer.frame = CGRect(x: 101, y: 248, width: 148, height: 22)
            groupMemberListTable.isHidden = true
            subviewNextButton.isHidden = true
        }
        
        UIView.animate(withDuration: 0.4) {
            self.underline.layer.frame = CGRect(x: 241, y: 30, width: 55, height: 51)
        }
    }
    
    func subviewWhen() {
        questionLabel.text = "When are you thinking?"
        questionLabel.isHidden = false
        homeAirportTextField.isHidden = true
        homeAirportTextField.resignFirstResponder()
        groupMemberListTable.isHidden = true
        addFromContactsButton.isHidden = true
        addFromFacebookButton.isHidden = true
        soloForNowButton.isHidden = true
        calendarView.isHidden = true
        nextMonth.isHidden = true
        previousMonth.isHidden = true
        popupBackgroundView.isHidden = true
        timeOfDayTableView.isHidden = true
        subviewDoneButton.isHidden = true
        subviewNextButton.isHidden = true
        month1.isHidden = true
        month2.isHidden = true
        month3.isHidden = true
        month4.isHidden = true
        weekend.isHidden = true
        oneWeek.isHidden = true
        twoWeeks.isHidden = true
        specificDatesButton.isHidden = false
        noSpecificDatesButton.isHidden = false
        numberDestinationsSlider.isHidden = true
        numberDestinationsStackView.isHidden = true
    }

    func animateOutSubview() {
        UIView.animate(withDuration: 0.3, animations: {
            self.popupSubview.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.popupBlurView.effect = nil
            self.popupSubview.alpha = 0
            self.popupSubview.transform = CGAffineTransform.init(scaleX: 1, y: 1)
        }) { (Success:Bool) in
            self.popupSubview.removeFromSuperview()
        }
    }


    //MARK: Actions
    @IBAction func tripNameLabelEditingChanged(_ sender: Any) {
        let tripNameValue = tripNameLabel.text as! NSString
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["trip_name"] = tripNameValue
        //Save
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    @IBAction func numberDestinationsValueChanged(_ sender: Any) {
        roundSlider()
    }
    @IBAction func specificDatesButtonTouchedUpInside(_ sender: Any) {
        month1.isHidden = true
        month2.isHidden = true
        month3.isHidden = true
        month4.isHidden = true
        weekend.isHidden = true
        oneWeek.isHidden = true
        twoWeeks.isHidden = true
        nextMonth.isHidden = false
        previousMonth.isHidden = false
        specificDatesButton.isHidden = true
        noSpecificDatesButton.isHidden = true
        questionLabel.isHidden = true
        calendarView.isHidden = false
    }
    @IBAction func noSpecificDatesButtonTouchedUpInside(_ sender: Any) {
        month1.isHidden = false
        month2.isHidden = false
        month3.isHidden = false
        month4.isHidden = false
        weekend.isHidden = false
        oneWeek.isHidden = false
        twoWeeks.isHidden = false
        nextMonth.isHidden = true
        previousMonth.isHidden = true
        specificDatesButton.isHidden = true
        noSpecificDatesButton.isHidden = true
        questionLabel.isHidden = false
        calendarView.isHidden = true
    }
    @IBAction func weekendTouchedUpInside(_ sender: Any) {
        if weekend.backgroundColor == UIColor.darkGray {
            oneWeek.isSelected = false
            oneWeek.backgroundColor = UIColor.darkGray
            oneWeek.titleLabel?.textColor = UIColor.white
            twoWeeks.isSelected = false
            twoWeeks.backgroundColor = UIColor.darkGray
            twoWeeks.titleLabel?.textColor = UIColor.white
            if (month1.backgroundColor == UIColor.white || month2.backgroundColor == UIColor.white || month3.backgroundColor == UIColor.white || month4.backgroundColor == UIColor.white) {
                subviewNextButton.isHidden = false
            } else {
                subviewNextButton.isHidden = true
            }
        }
    }
    
    @IBAction func oneWeekTouchedUpInside(_ sender: Any) {
        if oneWeek.backgroundColor == UIColor.darkGray {
            weekend.isSelected = false
            weekend.backgroundColor = UIColor.darkGray
            weekend.titleLabel?.textColor = UIColor.white
            twoWeeks.isSelected = false
            twoWeeks.backgroundColor = UIColor.darkGray
            twoWeeks.titleLabel?.textColor = UIColor.white
            if (month1.backgroundColor == UIColor.white || month2.backgroundColor == UIColor.white || month3.backgroundColor == UIColor.white || month4.backgroundColor == UIColor.white) {
                subviewNextButton.isHidden = false
            } else {
                subviewNextButton.isHidden = true
            }
        }
    }
    @IBAction func twoWeeksTouchedUpInside(_ sender: Any) {
        if twoWeeks.backgroundColor == UIColor.darkGray {
            weekend.isSelected = false
            weekend.backgroundColor = UIColor.darkGray
            weekend.titleLabel?.textColor = UIColor.white
            oneWeek.isSelected = false
            oneWeek.backgroundColor = UIColor.darkGray
            oneWeek.titleLabel?.textColor = UIColor.white
            if (month1.backgroundColor == UIColor.white || month2.backgroundColor == UIColor.white || month3.backgroundColor == UIColor.white || month4.backgroundColor == UIColor.white) {
                subviewNextButton.isHidden = false
            } else {
                subviewNextButton.isHidden = true
            }
        }
    }
    @IBAction func month1TouchedUpInside(_ sender: Any) {
        if month1.backgroundColor == UIColor.darkGray {
            month2.isSelected = false
            month2.backgroundColor = UIColor.darkGray
            month2.titleLabel?.textColor = UIColor.white
            month3.isSelected = false
            month3.backgroundColor = UIColor.darkGray
            month3.titleLabel?.textColor = UIColor.white
            month4.isSelected = false
            month4.backgroundColor = UIColor.darkGray
            month4.titleLabel?.textColor = UIColor.white
            if (weekend.backgroundColor == UIColor.white || oneWeek.backgroundColor == UIColor.white || twoWeeks.backgroundColor == UIColor.white) {
                subviewNextButton.isHidden = false
            } else {
                subviewNextButton.isHidden = true
            }
        }
    }
    @IBAction func month2TouchedUpInside(_ sender: Any) {
        if month2.backgroundColor == UIColor.darkGray {
            month1.isSelected = false
            month1.backgroundColor = UIColor.darkGray
            month1.titleLabel?.textColor = UIColor.white
            month3.isSelected = false
            month3.backgroundColor = UIColor.darkGray
            month3.titleLabel?.textColor = UIColor.white
            month4.isSelected = false
            month4.backgroundColor = UIColor.darkGray
            month4.titleLabel?.textColor = UIColor.white
            if (weekend.backgroundColor == UIColor.white || oneWeek.backgroundColor == UIColor.white || twoWeeks.backgroundColor == UIColor.white) {
                subviewNextButton.isHidden = false
            } else {
                subviewNextButton.isHidden = true
            }
        }
    }
    @IBAction func month3TouchedUpInside(_ sender: Any) {
        if month3.backgroundColor == UIColor.darkGray {
            month1.isSelected = false
            month1.backgroundColor = UIColor.darkGray
            month1.titleLabel?.textColor = UIColor.white
            month2.isSelected = false
            month2.backgroundColor = UIColor.darkGray
            month2.titleLabel?.textColor = UIColor.white
            month4.isSelected = false
            month4.backgroundColor = UIColor.darkGray
            month4.titleLabel?.textColor = UIColor.white
            if (weekend.backgroundColor == UIColor.white || oneWeek.backgroundColor == UIColor.white || twoWeeks.backgroundColor == UIColor.white) {
                subviewNextButton.isHidden = false
            } else {
                subviewNextButton.isHidden = true
            }
        }
    }
    
    @IBAction func month4TouchedUpInside(_ sender: Any) {
        if month4.backgroundColor == UIColor.darkGray {
            month1.isSelected = false
            month1.backgroundColor = UIColor.darkGray
            month1.titleLabel?.textColor = UIColor.white
            month2.isSelected = false
            month2.backgroundColor = UIColor.darkGray
            month2.titleLabel?.textColor = UIColor.white
            month3.isSelected = false
            month3.backgroundColor = UIColor.darkGray
            month3.titleLabel?.textColor = UIColor.white
            if (weekend.backgroundColor == UIColor.white || oneWeek.backgroundColor == UIColor.white || twoWeeks.backgroundColor == UIColor.white) {
                subviewNextButton.isHidden = false
            } else {
                subviewNextButton.isHidden = true
            }
        }
    }
    @IBAction func homeAirportEditingChanged(_ sender: Any) {
        DataContainerSingleton.sharedDataContainer.homeAirport = homeAirportTextField.text
        
        //Replace with logic for matching airport database
        if (homeAirportTextField.text?.characters.count)! >= 3 {
        //Enter code here for if airport code is entered
        }
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
    
    @IBAction func subviewWhereButtonTouchedUpInside(_ sender: Any) {
        subviewWhere()
    }
    
    @IBAction func subviewWhoButtonTouchedUpInside(_ sender: Any) {
        subviewWho()
    }
    
    @IBAction func subviewNextButtonTouchedUpInside(_ sender: Any) {
        if numberDestinationsSlider.isHidden {
            subviewWhere()
        } else if !numberDestinationsSlider.isHidden  {
            subviewWho()
        }
    }
    @IBAction func subviewWhenButtonTouchedUpInside(_ sender: Any) {
        subviewWhen()
        UIView.animate(withDuration: 0.4) {
            self.underline.layer.frame = CGRect(x: 50, y: 30, width: 55, height: 51)
        }
    }
    
    @IBAction func subviewDoneButtonTouchedUpInside(_ sender: Any) {
        nextButton.alpha = 1
        contactsCollectionView.alpha = 1
        addContactPlusIconMainVC.alpha = 1
        animateOutSubview()
    }
    
    @IBAction func goingSoloButtonTouchedUpInside(_ sender: Any) {
        nextButton.alpha = 1
        contactsCollectionView.alpha = 1
        addContactPlusIconMainVC.alpha = 1
        animateOutSubview()
    }
    
    @IBAction func previousMonthTouchedUpInside(_ sender: Any) {
        calendarView.scrollToSegment(.previous)
    }
    @IBAction func nextMonthTouchedUpInside(_ sender: Any) {
        calendarView.scrollToSegment(.next)
    }
    
    
    
    func updateCompletionStatus(){
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["finished_entering_preferences_status"] = "Name_Contacts_Rooms" as NSString
        //Save
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
    }
    
    ////// ADD NEW TRIP VARS (NS ONLY) HERE ///////////////////////////////////////////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
    func fetchSavedPreferencesForTrip() -> NSMutableDictionary {
        //Determine if new or added trip
        let isNewOrAddedTrip = determineIfNewOrAddedTrip()

        //Init preference vars for if new or added trip
        //Trip status
        var bookingStatus = NSNumber(value: 0)
        var finishedEnteringPreferencesStatus = NSString()
        //New Trip VC
        var tripNameValue = NSString()
        var contacts = [NSString]()
        var contactPhoneNumbers =  [NSString]()
        var hotelRoomsValue =  [NSNumber]()
        //Calendar VC
        var segmentLengthValue = [NSNumber]()
        var selectedDates = [NSDate]()
        var leftDateTimeArrays = NSDictionary()
        var rightDateTimeArrays = NSDictionary()
        //Budget VC
        var budgetValue = NSString()
        var expectedRoundtripFare = NSString()
        var expectedNightlyRate = NSString()
        //Suggested Destination VC
        var decidedOnDestinationControlValue = NSString()
        var decidedOnDestinationValue = NSString()
        var suggestDestinationControlValue = NSString()
        var suggestedDestinationValue = NSString()
        //Activities VC
        var selectedActivities = [NSString]()
        //Ranking VC
        var topTrips = [NSString]()
        
        //Update preference vars if an existing trip
        if isNewOrAddedTrip == 0 {
        //Trip status
        bookingStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "booking_status") as? NSNumber ?? 0 as NSNumber
        finishedEnteringPreferencesStatus = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "finished_entering_preferences_status") as? NSString ?? NSString()
        //New Trip VC
            tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? NSString ?? NSString()

        contacts = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contacts_in_group") as? [NSString] ?? [NSString]()
        contactPhoneNumbers = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "contact_phone_numbers") as? [NSString] ?? [NSString]()
        hotelRoomsValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "hotel_rooms") as? [NSNumber] ?? [NSNumber]()
        //Calendar VC
        segmentLengthValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "Availability_segment_lengths") as? [NSNumber] ?? [NSNumber]()
        selectedDates = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_dates") as? [NSDate] ?? [NSDate]()
        leftDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "origin_departure_times") as? NSDictionary ?? NSDictionary()
        rightDateTimeArrays = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "return_departure_times") as? NSDictionary ?? NSDictionary()
        //Budget VC
        budgetValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "budget") as? NSString ?? NSString()
        expectedRoundtripFare = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_roundtrip_fare") as? NSString ?? NSString()
        expectedNightlyRate = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "expected_nightly_rate") as? NSString ?? NSString()
        //Suggested Destination VC
        decidedOnDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_control") as? NSString ?? NSString()
        decidedOnDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "decided_destination_value") as? NSString ?? NSString()
        suggestDestinationControlValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggest_destination_control") as? NSString ?? NSString()
        suggestedDestinationValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "suggested_destination") as? NSString ?? NSString()
        //Activities VC
        selectedActivities = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_activities") as? [NSString] ?? [NSString]()
        //Ranking VC
        topTrips = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "top_trips") as? [NSString] ?? [NSString]()
        }
        
        //SavedPreferences
        let fetchedSavedPreferencesForTrip = ["booking_status": bookingStatus,"finished_entering_preferences_status": finishedEnteringPreferencesStatus, "trip_name": tripNameValue, "contacts_in_group": contacts,"contact_phone_numbers": contactPhoneNumbers, "hotel_rooms": hotelRoomsValue, "Availability_segment_lengths": segmentLengthValue,"selected_dates": selectedDates, "origin_departure_times": leftDateTimeArrays, "return_departure_times": rightDateTimeArrays, "budget": budgetValue, "expected_roundtrip_fare":expectedRoundtripFare, "expected_nightly_rate": expectedNightlyRate,"decided_destination_control":decidedOnDestinationControlValue, "decided_destination_value":decidedOnDestinationValue, "suggest_destination_control": suggestDestinationControlValue,"suggested_destination":suggestedDestinationValue, "selected_activities":selectedActivities,"top_trips":topTrips] as NSMutableDictionary
        
        return fetchedSavedPreferencesForTrip
        
    }
    
    func determineIfNewOrAddedTrip() -> Int {
        let existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        var numberSavedTrips: Int?
        var isNewOrAddedTrip: Int?
        if existing_trips == nil {
            numberSavedTrips = 0
            isNewOrAddedTrip = 1
        }
        else {
            numberSavedTrips = (existing_trips?.count)! - 1
            if currentTripIndex <= numberSavedTrips! {
                isNewOrAddedTrip = 0
            } else {
                isNewOrAddedTrip = 1
            }
        }
        return isNewOrAddedTrip!
    }
    
    func saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: NSMutableDictionary) {
        var existing_trips = DataContainerSingleton.sharedDataContainer.usertrippreferences
        let currentTripIndex = DataContainerSingleton.sharedDataContainer.currenttrip!
        
        var numberSavedTrips: Int?
        if DataContainerSingleton.sharedDataContainer.usertrippreferences == nil {
            numberSavedTrips = 0
        }
        else {
            numberSavedTrips = (existing_trips?.count)! - 1
            
        }

        //Case: first trip
        if existing_trips == nil {
            let firstTrip = [SavedPreferencesForTrip as NSDictionary]
            DataContainerSingleton.sharedDataContainer.usertrippreferences = firstTrip
        }
            //Case: existing trip
        else if currentTripIndex <= numberSavedTrips!   {
            existing_trips?[currentTripIndex] = SavedPreferencesForTrip as NSDictionary
            DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
        }
            //Case: added trip, but not first trip
        else {
            existing_trips?.append(SavedPreferencesForTrip as NSDictionary)
            DataContainerSingleton.sharedDataContainer.usertrippreferences = existing_trips
        }
    }
}

extension String {
    var length: Int {
        return self.characters.count
    }
    subscript (i: Int) -> String {
        return self[Range(i ..< i + 1)]
    }
    func substring(from: Int) -> String {
        return self[Range(min(from, length) ..< length)]
    }
    func substring(to: Int) -> String {
        return self[Range(0 ..< max(0, to))]
    }
    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return self[Range(start ..< end)]
    }
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}



//// MARK: KolodaViewDelegate
//extension NewTripNameViewController: KolodaViewDelegate {
//    
//    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
//        ranOutOfSwipesLabel.isHidden = false
//        heartIcon.isHidden = true
//        rejectIcon.isHidden = true
//        
////        let when = DispatchTime.now() + 1
////        DispatchQueue.main.asyncAfter(deadline: when) {
////            self.performSegue(withIdentifier: "swipingVCtoRankingVC", sender: nil)
////        }
//        
//        //        let position = kolodaView.currentCardIndex
//        //        for i in 1...4 {
//        //            dataSource.append(UIImage(named: "Card_like_\(i)")!)
//        //        }
//        //        kolodaView.insertCardAtIndexRange(position..<position + 4, animated: true)
//    }
//    
//    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
//    }
//    
//    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
//        countSwipes += 1
//        if countSwipes == 1 {
//            self.animateInSubview()
//        }
//        
//    }
//
////    func koloda(_ koloda: KolodaView, shouldSwipeCardAt index: Int, in direction: SwipeResultDirection) -> Bool {
////        if direction == SwipeResultDirection.right || direction == SwipeResultDirection.topRight || direction == SwipeResultDirection.bottomRight {
////            countRightSwipes += 1
////            if countRightSwipes == 1 {
////                self.animateInHomeAirportSubview()
////                return false
////            }
////        }
////        return true
////    }
//    
//    func koloda(_ koloda: KolodaView, draggedCardWithPercentage finishPercentage: CGFloat, in direction: SwipeResultDirection) {
//        let when = DispatchTime.now() + 1
//        
//        if finishPercentage > 80 && (direction == SwipeResultDirection.bottomLeft || direction == SwipeResultDirection.left || direction == SwipeResultDirection.topLeft) && (direction != SwipeResultDirection.bottomRight || direction != SwipeResultDirection.right || direction != SwipeResultDirection.topRight) {
//            rejectIcon.isHighlighted = true
//            DispatchQueue.main.asyncAfter(deadline: when) {
//                self.rejectIcon.isHighlighted = false
//            }
//        }
//        if finishPercentage > 80 && (direction == SwipeResultDirection.bottomRight || direction == SwipeResultDirection.right || direction == SwipeResultDirection.topRight) && (direction != SwipeResultDirection.bottomLeft || direction != SwipeResultDirection.left || direction != SwipeResultDirection.topLeft){
//            heartIcon.isHighlighted = true
//            DispatchQueue.main.asyncAfter(deadline: when) {
//                self.heartIcon.isHighlighted = false
//            }
//        }
//    }
//    
//}
//
//// MARK: KolodaViewDataSource
//extension NewTripNameViewController: KolodaViewDataSource {
//    
//    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
//        return dataSource.count
//    }
//    
//    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
//        return UIImageView(image: dataSource[Int(index)])
//    }
//}

// MARK: JTCalendarView Extension
extension NewTripNameViewController: JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        
        let startDate = Date()
        let endDate = formatter.date(from: "2017 12 31")
        let parameters = ConfigurationParameters(
            startDate: startDate,
            endDate: endDate!,
            numberOfRows: 6, // Only 1, 2, 3, & 6 are allowed
            calendar: Calendar.current,
            generateInDates: .forAllMonths,
            generateOutDates: .tillEndOfGrid,
            firstDayOfWeek: .sunday)
        return parameters
    }
    
    func handleSelection(cell: JTAppleDayCellView?, cellState: CellState) {
        let myCustomCell = cell as? CellView
        
        switch cellState.selectedPosition() {
        case .full:
            myCustomCell?.selectedView.isHidden = false
            myCustomCell?.dayLabel.textColor = NewTripNameViewController.blackColor
            myCustomCell?.selectedView.layer.backgroundColor = NewTripNameViewController.whiteColor.cgColor
            myCustomCell?.selectedView.layer.cornerRadius =  ((myCustomCell?.selectedView.frame.height)!/2)
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.leftSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
        case .left:
            myCustomCell?.selectedView.isHidden = false
            myCustomCell?.dayLabel.textColor = NewTripNameViewController.blackColor
            myCustomCell?.selectedView.layer.backgroundColor = NewTripNameViewController.whiteColor.cgColor
            myCustomCell?.selectedView.layer.cornerRadius =  ((myCustomCell?.selectedView.frame.height)!/2)
            myCustomCell?.rightSideConnector.isHidden = false
            myCustomCell?.leftSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
            
        case .right:
            myCustomCell?.selectedView.isHidden = false
            myCustomCell?.dayLabel.textColor = NewTripNameViewController.blackColor
            myCustomCell?.selectedView.layer.backgroundColor = NewTripNameViewController.whiteColor.cgColor
            myCustomCell?.selectedView.layer.cornerRadius =  ((myCustomCell?.selectedView.frame.height)!/2)
            myCustomCell?.leftSideConnector.isHidden = false
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
            
        case .middle:
            myCustomCell?.selectedView.isHidden = true
            myCustomCell?.middleConnector.isHidden = false
            myCustomCell?.middleConnector.layer.backgroundColor = NewTripNameViewController.transparentWhiteColor
            myCustomCell?.dayLabel.textColor = NewTripNameViewController.whiteColor
            myCustomCell?.selectedView.layer.cornerRadius =  0
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.leftSideConnector.isHidden = true
        default:
            myCustomCell?.selectedView.isHidden = true
            myCustomCell?.selectedView.layer.backgroundColor = NewTripNameViewController.transparentColor
            myCustomCell?.leftSideConnector.isHidden = true
            myCustomCell?.rightSideConnector.isHidden = true
            myCustomCell?.middleConnector.isHidden = true
            myCustomCell?.dayLabel.textColor = NewTripNameViewController.whiteColor
        }
        if cellState.dateBelongsTo != .thisMonth {
            myCustomCell?.dayLabel.textColor = NewTripNameViewController.darkGrayColor
        }
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplayCell cell: JTAppleDayCellView, date: Date, cellState: CellState) {
        let myCustomCell = cell as! CellView
        myCustomCell.dayLabel.text = cellState.text
        
        handleSelection(cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        
        
        if cellState.dateBelongsTo == .previousMonthWithinBoundary {
            calendarView.scrollToSegment(.previous)
        }
        if cellState.dateBelongsTo == .followingMonthWithinBoundary {
            calendarView.scrollToSegment(.next)
        }
        
        //UNCOMMENT FOR TWO CLICK RANGE SELECTION
        if firstDate != nil && firstDate! < date {
            if calendarView.cellStatus(for: firstDate!)?.selectedPosition() == .full {
                calendarView.selectDates(from: firstDate!, to: date,  triggerSelectionDelegate: false, keepSelectionIfMultiSelectionAllowed: true)
                firstDate = nil
            }
        }
        else {
            firstDate = date
        }
        
        //Spawn time of day selection
        
        let cellRow = cellState.row()
        let cellCol = cellState.column()
        var timeOfDayTable_X = cellCol * 50 + 39
        let timeOfDayTable_Y = cellRow * 50 + 145 + 2 * (cellRow - 1)
        if cellCol == 0 {
            timeOfDayTable_X = (cellCol + 1) * 50 + 39
        }
        if cellCol == 6 {
            timeOfDayTable_X = (cellCol - 1) * 50 + 39
        }
        
        if cellState.selectedPosition() == .left || cellState.selectedPosition() == .full {
            
            timeOfDayTableView.center = CGPoint(x: timeOfDayTable_X, y: timeOfDayTable_Y)
            animateTimeOfDayTableIn()
            
        }
        if cellState.selectedPosition() == .right {
            
            timeOfDayTableView.center = CGPoint(x: timeOfDayTable_X, y: timeOfDayTable_Y)
            animateTimeOfDayTableIn()
        }
        
        handleSelection(cell: cell, cellState: cellState)
        
        // Create array of selected dates
        let selectedDates = calendarView.selectedDates as [NSDate]
        getLengthOfSelectedAvailabilities()
        
        //Update trip preferences in dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["selected_dates"] = selectedDates
        SavedPreferencesForTrip["Availability_segment_lengths"] = lengthOfAvailabilitySegmentsArray as [NSNumber]
        //Save
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
        mostRecentSelectedCellDate = date as NSDate
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date, cell: JTAppleDayCellView?, cellState: CellState) {
        handleSelection(cell: cell, cellState: cellState)
        
        if cellState.dateBelongsTo == .previousMonthWithinBoundary {
            calendarView.scrollToSegment(.previous)
        }
        if cellState.dateBelongsTo == .followingMonthWithinBoundary {
            calendarView.scrollToSegment(.next)
        }
        
        // Create array of selected dates
        let selectedDates = calendarView.selectedDates as [NSDate]
        getLengthOfSelectedAvailabilities()
        
        //Update trip preferences in dictionary
        let SavedPreferencesForTrip = fetchSavedPreferencesForTrip()
        SavedPreferencesForTrip["selected_dates"] = selectedDates as [NSDate]
        SavedPreferencesForTrip["Availability_segment_lengths"] = lengthOfAvailabilitySegmentsArray as [NSNumber]
        //Save
        saveTripBasedOnNewAddedOrExisting(SavedPreferencesForTrip: SavedPreferencesForTrip)
        
    }
    
    // MARK custom func to get length of selected availability segments
    func getLengthOfSelectedAvailabilities() {
        let selectedDates = calendarView.selectedDates as [NSDate]
        leftDates = []
        rightDates = []
        fullDates = []
        lengthOfAvailabilitySegmentsArray = []
        for date in selectedDates {
            if calendarView.cellStatus(for: date as Date)?.selectedPosition() == .left {
                leftDates.append(date as Date)
            }
        }
        for date in selectedDates {
            if calendarView.cellStatus(for: date as Date)?.selectedPosition() == .right {
                rightDates.append(date as Date)
            }
        }
        for date in selectedDates {
            if calendarView.cellStatus(for: date as Date)?.selectedPosition() == .full {
                fullDates.append(date as Date)
            }
        }
        if rightDates != [] {
            for segment in 0...rightDates.count - 1 {
                let segmentAvailability = rightDates[segment].timeIntervalSince(leftDates[segment]) / 86400 + 1
                lengthOfAvailabilitySegmentsArray.append(Int(segmentAvailability))
            }
        } else {
            lengthOfAvailabilitySegmentsArray = [1]
        }
    }
    
    // MARK: Calendar header functions
    // Sets the height of your header
    func calendar(_ calendar: JTAppleCalendarView, sectionHeaderSizeFor range: (start: Date, end: Date), belongingTo month: Int) -> CGSize {
        return CGSize(width: 349, height: 50)
    }
    // This setups the display of your header
    func calendar(_ calendar: JTAppleCalendarView, willDisplaySectionHeader header: JTAppleHeaderView, range: (start: Date, end: Date), identifier: String) {
        let headerCell = (header as! monthHeaderView)
        
        // Create Year String
        let yearDateFormatter = DateFormatter()
        yearDateFormatter.dateFormat = "yyyy"
        let YearHeader = yearDateFormatter.string(from: range.start)
        
        //Create Month String
        let monthDateFormatter = DateFormatter()
        monthDateFormatter.dateFormat = "MM"
        let MonthHeader = monthDateFormatter.string(from: range.start)
        
        // Update header
        if MonthHeader == "01" {
            headerCell.monthLabel.text = "January " + YearHeader
        } else if MonthHeader == "02" {
            headerCell.monthLabel.text = "February " + YearHeader
        } else if MonthHeader == "03" {
            headerCell.monthLabel.text = "March " + YearHeader
        } else if MonthHeader == "04" {
            headerCell.monthLabel.text = "April " + YearHeader
        } else if MonthHeader == "05" {
            headerCell.monthLabel.text = "May " + YearHeader
        } else if MonthHeader == "06" {
            headerCell.monthLabel.text = "June " + YearHeader
        } else if MonthHeader == "07" {
            headerCell.monthLabel.text = "July " + YearHeader
        } else if MonthHeader == "08" {
            headerCell.monthLabel.text = "August " + YearHeader
        } else if MonthHeader == "09" {
            headerCell.monthLabel.text = "September " + YearHeader
        } else if MonthHeader == "10" {
            headerCell.monthLabel.text = "October " + YearHeader
        } else if MonthHeader == "11" {
            headerCell.monthLabel.text = "November " + YearHeader
        } else if MonthHeader == "12" {
            headerCell.monthLabel.text = "December " + YearHeader
        }
    }
    
    func animateTimeOfDayTableIn(){
        timeOfDayTableView.isHidden = false
        timeOfDayTableView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
        timeOfDayTableView.alpha = 0
        
        UIView.animate(withDuration: 0.4) {
            self.popupBackgroundView.isHidden = false
            self.timeOfDayTableView.alpha = 1
            self.timeOfDayTableView.transform = CGAffineTransform.identity
        }
    }
    
    func dismissTimeOfDayTableOut() {
        UIView.animate(withDuration: 0.3, animations: {
            self.timeOfDayTableView.transform = CGAffineTransform.init(scaleX: 1.3, y: 1.3)
            self.timeOfDayTableView.alpha = 0
            let selectedRows = self.timeOfDayTableView.indexPathsForSelectedRows
            self.popupBackgroundView.isHidden = true
            for rowIndex in selectedRows! {
                self.timeOfDayTableView.deselectRow(at: rowIndex, animated: false)
            }
            if self.leftDates.count == self.rightDates.count && (self.leftDates.count != 0 || self.rightDates.count != 0) {
                self.subviewNextButton.isHidden = false
            }
        }) { (Success:Bool) in
            self.timeOfDayTableView.isHidden = true
        }
    }
}

extension UIColor {
    convenience init(colorWithHexValue value: Int, alpha:CGFloat = 1.0){
        self.init(
            red: CGFloat((value & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((value & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(value & 0x0000FF) / 255.0,
            alpha: alpha
        )
    }
}
