//
//  contactsTableViewCell.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 1/11/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class contactsTableViewCell: UITableViewCell {
    
    // MARK: Outlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var initialsLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
