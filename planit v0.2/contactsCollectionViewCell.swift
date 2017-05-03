//
//  contactsCollectionViewCell.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 1/12/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class contactsCollectionViewCell: UICollectionViewCell {
    
    var shakeEnabled = false
    
    // MARK: Outlets
    @IBOutlet weak var initialsLabel: UILabel!
    @IBOutlet weak var thumbnailImageFilter: UIImageView!
    @IBOutlet weak var thumbnailImage: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    func shakeIcons() {
        let shakeAnim = CABasicAnimation(keyPath: "transform.rotation")
        shakeAnim.duration = 0.05
        shakeAnim.repeatCount = 2
        shakeAnim.autoreverses = true
        let startAngle: Float = (-2) * 3.14159/180
        var stopAngle = -startAngle
        shakeAnim.fromValue = NSNumber(value: startAngle)
        shakeAnim.toValue = NSNumber(value: 3 * stopAngle)
        shakeAnim.autoreverses = true
        shakeAnim.duration = 0.2
        shakeAnim.repeatCount = 10000
        shakeAnim.timeOffset = 290 * drand48()
        
        //Create layer, then add animation to the element's layer
        let layer: CALayer = self.layer
        layer.add(shakeAnim, forKey:"shaking")
        shakeEnabled = true
    }
    
    // This function stop shaking the collection view cells
    func stopShakingIcons() {
        let layer: CALayer = self.layer
        layer.removeAnimation(forKey: "shaking")
        self.deleteButton.isHidden = true
        shakeEnabled = false
    }

}
