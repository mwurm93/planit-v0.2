//
//  rankingViewController.swift
//  PLANiT
//
//  Created by MICHAEL WURM on 12/17/16.
//  Copyright © 2016 MICHAEL WURM. All rights reserved.
//

import UIKit

class RankingViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Class properties
    var sectionTitles = ["Top trip", "Alternatives"]
    
    // MARK: Outlets
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var recommendationRankingTableView: UITableView!
    @IBOutlet weak var readyToBookButton: UIButton!
    @IBOutlet weak var returnToSwipingButton: UIButton!
    
    // viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Set up table
        recommendationRankingTableView.layer.cornerRadius = 5
        recommendationRankingTableView.tableFooterView = UIView()
        recommendationRankingTableView.isEditing = true
        recommendationRankingTableView.allowsSelectionDuringEditing = true
        let selectFirstRow = IndexPath(row: 0, section: 0)
        recommendationRankingTableView.selectRow(at: selectFirstRow, animated: false, scrollPosition: UITableViewScrollPosition.none)
        recommendationRankingTableView.cellForRow(at: IndexPath(row: 0, section: 0))?.layer.backgroundColor = UIColor.blue.cgColor
        
        //Load the values from our shared data container singleton
        let tripNameValue = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "trip_name") as? String
        //Install the value into the label.
        if tripNameValue != nil {
            self.tripNameLabel.text =  "\(tripNameValue!)"
        }
    }
    
    // didReceiveMemoryWarning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    // UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        // if section == 1
        return 4
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let selectedActivities = DataContainerSingleton.sharedDataContainer.usertrippreferences?[DataContainerSingleton.sharedDataContainer.currenttrip!].object(forKey: "selected_activities") as? [String]
        
        var addedRow = indexPath.row
        let destinationsLabelsArray = ["Miami", "San Diego", "Marina del Rey (LA)", "Panama City Beach", "Ft. Lauderdale"]
        let pricesArray = ["$1,000","$950","$1,100","$1,000","$975"]
        let percentagesSwipedRightArray = ["100","75","50","25","25"]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "rankedRecommendationsPrototypeCell", for: indexPath) as! rankedRecommendationsTableViewCell
        
        if indexPath.section == 1 {
            addedRow += 1
        }
        
        cell.rankLabel.text = "#\(addedRow + 1)"
        cell.destinationLabel.text = destinationsLabelsArray[addedRow]
        cell.tripPrice.text = pricesArray[addedRow]
        cell.percentSwipedRight.text = "\(percentagesSwipedRightArray[addedRow])% swiped right"
        if selectedActivities != nil {
            cell.preferredActivitiesPossibleAtDestination.text = "\(selectedActivities!)"
        }
        cell.layer.cornerRadius = 10
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "destinationChosenSegue" {
            let destination = segue.destination as? ReviewAndBookViewController
            
            let path = recommendationRankingTableView.indexPathForSelectedRow! as IndexPath
            let cell = recommendationRankingTableView.cellForRow(at: path) as! rankedRecommendationsTableViewCell
            destination?.destinationLabelViaSegue = cell.destinationLabel.text!
            destination?.tripPriceViaSegue = cell.tripPrice.text!
        }
    }
    
    // MARK: moving rows
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        //Alt trip moved into top section but below top trip
        if destinationIndexPath.section == 0 && destinationIndexPath.row != 0 {
            // NEED TO FIX
            self.recommendationRankingTableView.reloadData()
        }
        
        // Alternative trip moved above top trip
    if destinationIndexPath.section == 0  && sourceIndexPath.section != 0 && destinationIndexPath.row == 0 {
        // Spawn alert
        let alertController = UIAlertController(title: "You are changing your group's top trip", message: "Make sure everyone in your group is okay with this!", preferredStyle: UIAlertControllerStyle.alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
            (result : UIAlertAction) -> Void in
            
            self.recommendationRankingTableView.moveRow(at: destinationIndexPath, to: sourceIndexPath)
            self.recommendationRankingTableView.cellForRow(at: sourceIndexPath)?.layer.backgroundColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
        }
        
        let continueAction = UIAlertAction(title: "Continue", style: UIAlertActionStyle.default) {
            (result : UIAlertAction) -> Void in
            
            let visibleItems = self.recommendationRankingTableView.indexPathsForVisibleRows
            
            if destinationIndexPath == IndexPath(row: 0, section: 0) && sourceIndexPath.section == 1 {
                
                self.recommendationRankingTableView.moveRow(at: (visibleItems?[1])!, to: (visibleItems?[2])!)
                self.recommendationRankingTableView.cellForRow(at: IndexPath(row: 0, section: 1))?.layer.backgroundColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
                self.recommendationRankingTableView.selectRow(at: IndexPath(row: 0, section: 0)
                    , animated: true, scrollPosition: UITableViewScrollPosition.top)
                self.recommendationRankingTableView.cellForRow(at: IndexPath(row: 0, section: 0))?.layer.backgroundColor = UIColor.blue.cgColor
            }
            
//            self.recommendationRankingTableView.selectRow(at: IndexPath(row: 0, section: 0)
//                , animated: true, scrollPosition: UITableViewScrollPosition.top)
//            self.recommendationRankingTableView.cellForRow(at: IndexPath(row: 0, section: 0))?.layer.backgroundColor = UIColor.blue.cgColor
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(continueAction)
        self.present(alertController, animated: true, completion: nil)
        }
        
        // Top trip moved down
//        if sourceIndexPath.section == 0 && destinationIndexPath.section != 0 {
//
//            // Spawn alert
//            let alertController2 = UIAlertController(title: "You are changing your group's top trip", message: "Make sure everyone in your group is okay with this!", preferredStyle: UIAlertControllerStyle.alert)
//            
//            
//            let cancelAction2 = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.destructive) {
//                (result : UIAlertAction) -> Void in
//                
//                self.recommendationRankingTableView.moveRow(at: destinationIndexPath, to: sourceIndexPath)
//                self.recommendationRankingTableView.cellForRow(at: sourceIndexPath)?.layer.backgroundColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
//            }
//            
//            let continueAction2 = UIAlertAction(title: "Continue", style: UIAlertActionStyle.default) {
//                (result : UIAlertAction) -> Void in
//                
//                let visibleItems = self.recommendationRankingTableView.indexPathsForVisibleRows
//                self.recommendationRankingTableView.moveRow(at: (visibleItems?[1])!, to: IndexPath(row:0,section:0))
//                self.recommendationRankingTableView.cellForRow(at: (visibleItems?[0])!)?.layer.backgroundColor = UIColor(red:1,green:1,blue:1,alpha:0.25).cgColor
//            }
//            
//            //present alert
//            alertController2.addAction(cancelAction2)
//            alertController2.addAction(continueAction2)
//            self.present(alertController2, animated: true, completion: nil)
//        }

    }


    // MARK: Table Section Headers
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
                return sectionTitles[section]
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: recommendationRankingTableView.bounds.size.width, height: 30))
        header.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        header.layer.cornerRadius = 5
        
        let title = UILabel()
        title.frame = header.frame
        title.textAlignment = .left
        title.font = UIFont.boldSystemFont(ofSize: 20)
        title.textColor = UIColor.white
        title.text = sectionTitles[section]
        header.addSubview(title)
        
        return header
    }
    
        
    // MARK: Actions
    @IBAction func readyToBookButtonPressed(_ sender: Any) {

        self.performSegue(withIdentifier: "destinationChosenSegue", sender: self)

    }
    
    

}
