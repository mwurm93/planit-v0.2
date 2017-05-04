//
//  exploreHotelsViewController.swift
//  planit v0.2
//
//  Created by MICHAEL WURM on 5/4/17.
//  Copyright © 2017 MICHAEL WURM. All rights reserved.
//

import UIKit

class exploreHotelsViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    let hotelsList = ["Ramada Inn", "VRBO house", "W", "Courtyard Marriott", "Holiday Inn", "Homeaway apartment"]
    
    //MARK: Outlets
    @IBOutlet weak var hotelsTableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()
        hotelsTableView.layer.cornerRadius = 5
        let FirstRow = IndexPath(row: 0, section: 0)
        hotelsTableView.selectRow(at: FirstRow, animated: false, scrollPosition: UITableViewScrollPosition.none)
        hotelsTableView.cellForRow(at: FirstRow)?.contentView.backgroundColor = UIColor.blue

    
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
        cell.layer.cornerRadius = 10
        cell.contentView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedCell = tableView.cellForRow(at: indexPath)
        selectedCell?.contentView.backgroundColor = UIColor.blue
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let deSelectedCell = tableView.cellForRow(at: indexPath)
        deSelectedCell?.contentView.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.25)
    }

}
