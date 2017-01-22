//
//  rankedRecommendationsTableViewCell.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 1/8/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class rankedRecommendationsTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var tripPrice: UILabel!
    @IBOutlet weak var percentSwipedRight: UILabel!
    @IBOutlet weak var preferredActivitiesPossibleAtDestination: UILabel!
    @IBOutlet weak var rankLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
        // Configure the view for the selected state
    }
    
}
