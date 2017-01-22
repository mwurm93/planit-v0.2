//
//  itemizedItineraryTableViewCell.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 1/8/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class itemizedItineraryTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var TravelLabel: UILabel!
    @IBOutlet weak var destinationLabel: UILabel!
    @IBOutlet weak var accomodationLabel: UILabel!
    @IBOutlet weak var totalPriceLabel: UILabel!
    @IBOutlet weak var travelPriceLabel: UILabel!
    @IBOutlet weak var accomodationPriceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
