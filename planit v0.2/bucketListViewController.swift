//
//  bucketListViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 5/4/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import GoogleMaps

class bucketListViewController: UIViewController {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Google Maps API
        let camera = GMSCameraPosition.camera(withLatitude: 25.7617, longitude: -80.1918, zoom: 12.0)
        self.googleMap.camera = camera
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: 25.7617, longitude: -80.1918)
        marker.title = "Miami"
        marker.snippet = "Florida"
        marker.map = googleMap
    }

    
}
