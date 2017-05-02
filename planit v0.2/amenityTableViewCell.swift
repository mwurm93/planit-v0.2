//
//  amenityTableViewCell.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 5/2/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class amenityTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var amenityLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
