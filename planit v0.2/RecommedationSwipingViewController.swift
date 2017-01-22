//
//  RecommendationsVoting.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 10/14/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit
import Koloda

private var numberOfCards: Int = 5

class RecommendationSwipingViewController: UIViewController {

    // MARK: Outlets
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var heartIcon: UIButton!
    @IBOutlet weak var rejectIcon: UIButton!
    @IBOutlet weak var kolodaView: KolodaView!
    @IBOutlet weak var ranOutOfSwipesLabel: UILabel!
    
    
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
    
    
    // didReceiveMemoryWarning
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
