//
//  exploreHotelsViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 5/4/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit
import GoogleMaps

class exploreHotelsViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let hotelsList = ["Ramada Inn", "VRBO house", "W", "Courtyard Marriott", "Holiday Inn", "Homeaway apartment"]
    
    //MARK: Outlets
    @IBOutlet weak var hotelsTableView: UITableView!
    @IBOutlet weak var googleMap: GMSMapView!

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
        
        //Preselect first hotel
        let FirstRow = IndexPath(row: 0, section: 0)
        hotelsTableView.selectRow(at: FirstRow, animated: false, scrollPosition: UITableViewScrollPosition.none)
        let firstCell = hotelsTableView.cellForRow(at: FirstRow) as! hotelTableViewCell
        firstCell.hotelName.frame = CGRect(x: 10, y: 0, width: 127, height: 40)
        firstCell.hotelName.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        firstCell.hotelName.font = UIFont.boldSystemFont(ofSize: 19)
    }
    
    //MARK: TableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfRows = hotelsList.count
        return numberOfRows
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "hotelPrototypeCell", for: indexPath) as! hotelTableViewCell
        var addedRow = indexPath.row
        
        if indexPath.section == 1 {
            addedRow += 1
        }
        
        cell.hotelName.text = hotelsList[addedRow]
        cell.hotelName.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        cell.hotelName.frame = CGRect(x: 25, y: 0, width: 127, height: 40)

        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath) as! hotelTableViewCell
        selectedCell.hotelName.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        selectedCell.hotelName.frame = CGRect(x: 10, y: 0, width: 127, height: 40)
        selectedCell.hotelName.font = UIFont.boldSystemFont(ofSize: 19)

        let visibleCells = tableView.visibleCells as! [hotelTableViewCell]
        for visibleCell in visibleCells {
            if tableView.indexPath(for: visibleCell) != indexPath {
                visibleCell.hotelName.textColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
                visibleCell.hotelName.frame = CGRect(x: 25, y: 0, width: 127, height: 40)
                visibleCell.hotelName.font = UIFont.systemFont(ofSize: 17)
                
            }
        }
    }
}
