//
//  ExistingTripTableViewCell.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 11/28/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit

class ExistingTripTableViewCell: UITableViewCell {

    // MARK: Outlets
    @IBOutlet weak var existingTripTableViewLabel: UILabel!
    @IBOutlet weak var existingTripTableViewImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
