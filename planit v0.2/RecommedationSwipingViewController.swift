//
//  RecommendationsVoting.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/14/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit
import Koloda
import MessageUI

private var numberOfCards: Int = 5

class RecommendationSwipingViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var heartIcon: UIButton!
    @IBOutlet weak var rejectIcon: UIButton!
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var ranOutOfSwipesLabel: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    
    let messageComposer = MessageComposer()
    
    fileprivate var dataSource: [UIImage] = {
        var array: [UIImage] = []
        for index in 0..<numberOfCards {
            array.append(UIImage(named: "Card_like_\(index + 1)")!)
        }
        
        return array
    }()
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        //add shadow to button
        chatButton.layer.shadowColor = UIColor.black.cgColor
        chatButton.layer.shadowOffset = CGSize(width: 2, height: 2)
        chatButton.layer.shadowRadius = 2
        chatButton.layer.shadowOpacity = 0.5
        
        //Set Koloda delegate and View Controller
        kolodaView.dataSource = self
        kolodaView.delegate = self
        self.modalTransitionStyle = UIModalTransitionStyle.flipHorizontal
        
        heartIcon.setImage(#imageLiteral(resourceName: "fullHeart"), for: .highlighted)
        rejectIcon.setImage(#imageLiteral(resourceName: "fullX"), for: .highlighted)
        ranOutOfSwipesLabel.isHidden = true
        
        //Load the values from our shared data container singleton
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        //Install the value into the label.
        if tripNameValue != nil {
            self.tripNameLabel.text =  "\(tripNameValue!)"
        }
    }
    
    @IBAction func chatButtonPressed(_ sender: Any) {
        // Make sure the device can send text messages
        if (messageComposer.canSendText()) {
            // Obtain a configured MFMessageComposeViewController
            let messageComposeVC = messageComposer.configuredMessageComposeViewController()
            
            // Present the configured MFMessageComposeViewController instance
            present(messageComposeVC, animated: true, completion: nil)
        } else {
            // Let the user know if his/her device isn't able to send text messages
            let errorAlert = UIAlertController(title: "Cannot Send Text Message", message: "Your device is not able to send text messages.", preferredStyle: UIAlertControllerStyle.alert)
            let cancelAction = UIAlertAction(title: "Okay", style: UIAlertActionStyle.destructive) {
                (result : UIAlertAction) -> Void in
            }
        
        errorAlert.addAction(cancelAction)
        self.present(errorAlert, animated: true, completion: nil)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    @IBAction func rejectSelected(_ sender: Any) {
        kolodaView?.swipe(.left)
    }
    
    @IBAction func heartSelected(_ sender: Any) {
        kolodaView?.swipe(.right)
    }
}

// MARK: KolodaViewDelegate

extension RecommendationSwipingViewController: KolodaViewDelegate {
    
    func kolodaDidRunOutOfCards(_ koloda: KolodaView) {
        ranOutOfSwipesLabel.isHidden = false
        heartIcon.isHidden = true
        rejectIcon.isHidden = true
        
//        let position = kolodaView.currentCardIndex
//        for i in 1...4 {
//            dataSource.append(UIImage(named: "Card_like_\(i)")!)
//        }
//        kolodaView.insertCardAtIndexRange(position..<position + 4, animated: true)
    }
    
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
    }
    func koloda(_ koloda: KolodaView, draggedCardWithPercentage finishPercentage: CGFloat, in direction: SwipeResultDirection) {
        let when = DispatchTime.now() + 1
        
        if finishPercentage > 80 && (direction == SwipeResultDirection.bottomLeft || direction == SwipeResultDirection.left || direction == SwipeResultDirection.topLeft) && (direction != SwipeResultDirection.bottomRight || direction != SwipeResultDirection.right || direction != SwipeResultDirection.topRight) {
            rejectIcon.isHighlighted = true
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.rejectIcon.isHighlighted = false
            }
        }
        if finishPercentage > 80 && (direction == SwipeResultDirection.bottomRight || direction == SwipeResultDirection.right || direction == SwipeResultDirection.topRight) && (direction != SwipeResultDirection.bottomLeft || direction != SwipeResultDirection.left || direction != SwipeResultDirection.topLeft){
            heartIcon.isHighlighted = true
            DispatchQueue.main.asyncAfter(deadline: when) {
                self.heartIcon.isHighlighted = false
            }
        }
    }
}

// MARK: KolodaViewDataSource

extension RecommendationSwipingViewController: KolodaViewDataSource {
    
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return dataSource.count
    }
    
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {
        return UIImageView(image: dataSource[Int(index)])
    }
}
