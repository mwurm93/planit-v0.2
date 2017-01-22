//
//  ActivitiesCollectionViewCell.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 1/5/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class ActivitiesCollectionViewCell: UICollectionViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var activityImage: UIImageView!
    @IBOutlet weak var activityLabel: UILabel!
    
    func setActivityItem(_ item:ActivityItem) {
        activityImage.image = UIImage(named: item.itemImage)
        activityLabel.text = item.itemImage
    }
}
