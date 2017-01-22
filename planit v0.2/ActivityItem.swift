//
//  ActivityItem.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 1/5/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import Foundation

class ActivityItem {
    
    var itemImage: String
    
    init(dataDictionary:Dictionary<String,String>) {
        itemImage = dataDictionary["itemImage"]!
    }
    
    class func newActivityItem(_ dataDictionary:Dictionary<String,String>) -> ActivityItem {
        return ActivityItem(dataDictionary: dataDictionary)
    }
}
