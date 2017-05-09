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
    
    //MARK: Outlets
    @IBOutlet weak var googleMap: GMSMapView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //MARK: Google Maps API
        let camera = GMSCameraPosition.camera(withLatitude: 25.7617, longitude: -80.1918, zoom: 1.0)
        googleMap.setMinZoom(googleMap.minZoom, maxZoom: 3)
        
        do {
            // Set the map style by passing the URL of the local file.
            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
                googleMap.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
            } else {
                NSLog("Unable to find style.json")
            }
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }

        self.googleMap.camera = camera
    }

    var styleJSON: [AnyObject] = [[
    {
        "featureType": "administrative.land_parcel",
        "stylers": [
        {
        "visibility": "off"
        }
        ]
        },
    {
        "featureType": "administrative.neighborhood",
        "stylers": [
        {
        "visibility": "off"
        }
        ]
        },
    {
        "featureType": "poi",
        "elementType": "labels.text",
        "stylers": [
        {
        "visibility": "off"
        }
        ]
        },
    {
        "featureType": "poi.business",
        "stylers": [
        {
        "visibility": "off"
        }
        ]
        },
    {
        "featureType": "road",
        "stylers": [
        {
        "visibility": "off"
        }
        ]
        },
    {
        "featureType": "road",
        "elementType": "labels",
        "stylers": [
        {
        "visibility": "off"
        }
        ]
        },
    {
        "featureType": "road",
        "elementType": "labels.icon",
        "stylers": [
        {
        "visibility": "off"
        }
        ]
        },
    {
        "featureType": "transit",
        "stylers": [
        {
        "visibility": "off"
        }
        ]
        },
    {
        "featureType": "water",
        "stylers": [
        {
        "color": "#ffeb3b"
        },
        {
        "visibility": "off"
        }
        ]
        },
    {
        "featureType": "water",
        "elementType": "labels.text",
        "stylers": [
        {
        "visibility": "off"
        }
        ]
        }
    ]]
    
    //MARK: Custom functions
    func JSONStringify(value: AnyObject,prettyPrinted:Bool = false) -> String{
        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
        if JSONSerialization.isValidJSONObject(value) {
            do{
                let data = try JSONSerialization.data(withJSONObject: value, options: options)
                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
                    return string as String
                }
            } catch {
                print("error")
                //Access error here
            }
        }
        return ""
    }
}
