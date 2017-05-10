//
//  bucketListViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 5/4/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import GoogleMaps
import WhirlyGlobe

class bucketListViewController: UIViewController {
    
    //MARK: Outlets
//    @IBOutlet weak var googleMap: GMSMapView!
    private var theViewC: MaplyBaseViewController?
    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        // Create an empty globe and add it to the view
//        theViewC = WhirlyGlobeViewController()
//        self.view.addSubview(theViewC!.view)
//        theViewC!.view.frame = self.view.bounds
//        addChildViewController(theViewC!)
//
//        let globeViewC = theViewC as? WhirlyGlobeViewController
//
//        // we want a black background for a globe
//        theViewC!.clearColor = UIColor.clear
//        
//        // and thirty fps if we can get it ­ change this to 3 if you find your app is struggling
//        theViewC!.frameInterval = 2
//        
//        // set up the data source
//        if let tileSource = MaplyMBTileSource(mbTiles: "geography-class_medres"), let coordSystem = MaplyCoordinateSystem(), let layer = MaplyQuadImageTilesLayer(coordSystem: coordSystem, tileSource: tileSource) {
//            layer.handleEdges = (globeViewC != nil)
//            layer.coverPoles = (globeViewC != nil)
//            layer.requireElev = false
//            layer.waitLoad = false
//            layer.drawPriority = 0
//            layer.singleLevelLoading = false
//            theViewC!.addLayer(layer)
//        }
//        
//        // start up over Madrid, center of the old-world
//        if let globeViewC = globeViewC {
//            globeViewC.height = 0.8
//            globeViewC.animate(toPosition: MaplyCoordinateMakeWithDegrees(-3.6704803, 40.5023056), time: 1.0)
//        }

    
    var useLocalTiles = false
    // we'll need this layer in a second
    var layer: MaplyQuadImageTilesLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "World Clock"
        // Do any additional setup after loading the view.
        theViewC = WhirlyGlobeViewController()
        
        let globeViewC = theViewC as? WhirlyGlobeViewController
        let mapViewC = theViewC as? MaplyViewController
        
        // we want a black background for a globe, a white background for a map.
        theViewC!.clearColor = (globeViewC != nil) ? UIColor.black : UIColor.white
        // and thirty fps if we can get it ­ change this to 3 if you find your app is struggling
        theViewC!.frameInterval = 3
        // set up the data source
        
        
        if useLocalTiles {
            guard let tileSource = MaplyMBTileSource(mbTiles: "geography-class_medres") else {
                // can't load local tile set
                return
            }
            layer = MaplyQuadImageTilesLayer()
            layer?.tileSource = tileSource
            
        }
        else {
            // Because this is a remote tile set, we'll want a cache directory
            let baseCacheDir = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
            let aerialTilesCacheDir = "\(baseCacheDir)/osmtiles/"
            let maxZoom = Int32(18)
            
            // MapQuest Open Aerial Tiles, Courtesy Of Mapquest
            // Portions Courtesy NASA/JPL­Caltech and U.S. Depart. of Agriculture, Farm Service Agency
            guard let tileSource = MaplyRemoteTileSource(
                baseURL: "http://otile1.mqcdn.com/tiles/1.0.0/sat/",
                ext: "png",
                minZoom: 0,
                maxZoom: maxZoom) else {
                    // can't create remote tile source
                    return
            }
            tileSource.cacheDir = aerialTilesCacheDir
            layer = MaplyQuadImageTilesLayer()
            layer?.tileSource = tileSource
        }
        
        
        
        // start up over Madrid, center of the old-world
        if let globeViewC = globeViewC {
            globeViewC.height = 0.8
            globeViewC.animate(toPosition: MaplyCoordinateMakeWithDegrees(-3.6704803, 40.5023056), time: 1.0)
        }
        else if let mapViewC = mapViewC {
            mapViewC.height = 1.0
            mapViewC.animate(toPosition: MaplyCoordinateMakeWithDegrees(-3.6704803, 40.5023056), time: 1.0)
        }
        self.view.addSubview(theViewC!.view)
        theViewC!.view.frame = self.view.bounds
        addChildViewController(theViewC!)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

        
//        //MARK: Google Maps API
//        let camera = GMSCameraPosition.camera(withLatitude: 25.7617, longitude: -80.1918, zoom: 1.0)
//        googleMap.setMinZoom(googleMap.minZoom, maxZoom: 3)
//        
//        do {
//            // Set the map style by passing the URL of the local file.
//            if let styleURL = Bundle.main.url(forResource: "style", withExtension: "json") {
//                googleMap.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
//            } else {
//                NSLog("Unable to find style.json")
//            }
//        } catch {
//            NSLog("One or more of the map styles failed to load. \(error)")
//        }
//
//        self.googleMap.camera = camera
    }

//    var styleJSON: [AnyObject] = [[
//    {
//        "featureType": "administrative.land_parcel",
//        "stylers": [
//        {
//        "visibility": "off"
//        }
//        ]
//        },
//    {
//        "featureType": "administrative.neighborhood",
//        "stylers": [
//        {
//        "visibility": "off"
//        }
//        ]
//        },
//    {
//        "featureType": "poi",
//        "elementType": "labels.text",
//        "stylers": [
//        {
//        "visibility": "off"
//        }
//        ]
//        },
//    {
//        "featureType": "poi.business",
//        "stylers": [
//        {
//        "visibility": "off"
//        }
//        ]
//        },
//    {
//        "featureType": "road",
//        "stylers": [
//        {
//        "visibility": "off"
//        }
//        ]
//        },
//    {
//        "featureType": "road",
//        "elementType": "labels",
//        "stylers": [
//        {
//        "visibility": "off"
//        }
//        ]
//        },
//    {
//        "featureType": "road",
//        "elementType": "labels.icon",
//        "stylers": [
//        {
//        "visibility": "off"
//        }
//        ]
//        },
//    {
//        "featureType": "transit",
//        "stylers": [
//        {
//        "visibility": "off"
//        }
//        ]
//        },
//    {
//        "featureType": "water",
//        "stylers": [
//        {
//        "color": "#ffeb3b"
//        },
//        {
//        "visibility": "off"
//        }
//        ]
//        },
//    {
//        "featureType": "water",
//        "elementType": "labels.text",
//        "stylers": [
//        {
//        "visibility": "off"
//        }
//        ]
//        }
//    ]]
    
    //MARK: Custom functions
//    func JSONStringify(value: AnyObject,prettyPrinted:Bool = false) -> String{
//        let options = prettyPrinted ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization.WritingOptions(rawValue: 0)
//        if JSONSerialization.isValidJSONObject(value) {
//            do{
//                let data = try JSONSerialization.data(withJSONObject: value, options: options)
//                if let string = NSString(data: data, encoding: String.Encoding.utf8.rawValue) {
//                    return string as String
//                }
//            } catch {
//                print("error")
//                //Access error here
//            }
//        }
//        return ""
//    }
