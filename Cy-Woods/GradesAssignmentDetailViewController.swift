//
//  GradesAssignmentDetailViewController.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 11/13/17.
//  Copyright © 2017 Nish Suchdev. All rights reserved.
//

import UIKit

class GradesAssignmentDetailViewController: UITableViewController {
  
  var classIndex: Int!
  var assignmentIndex: Int!
  
  var details = [["Name", "Type", "Grade"]]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = GradesManager.getAssignment(for: GradesManager.currentUser!, classIndex: self.classIndex, assignmentIndex: self.assignmentIndex)!["name"] as? String
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return self.details.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.details[section].count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "AssignmentInfoCell")!
    
    cell.textLabel!.text = "\(self.details[indexPath.section][indexPath.row]):"
    cell.detailTextLabel!.text = GradesManager.getAssignment(for: GradesManager.currentUser!, classIndex: self.classIndex, assignmentIndex: self.assignmentIndex)![self.details[indexPath.section][indexPath.row].lowercased()] as? String
    
    cell.textLabel!.textColor = ThemeManager.tableViewCellTitleLabelColor
    cell.detailTextLabel!.textColor = ThemeManager.tableViewCellDetailLabelColor
    cell.backgroundColor = ThemeManager.tableViewCellBackgroundColor
    
    return cell
  }
  
  @IBAction func showStarWarsQuote(_ sender: Any) {
    let quotes = ["It's a Trap!", "I got a bad feeling about this...", "I find your lack of faith disturbing", "The Force will be with you, always", "Never tell me the odds!", "Do. Or do not. There is no try.", "No. I am your father.", "Now, young Skywalker, you will die.", "There’s always a bigger fish.", "Fear is the path to the dark side.", "Fear leads to anger; anger leads to hate; hate leads to suffering.", "Well, if droids could think, there’d be none of us here, would there?", "I’m just a simple man trying to make my way in the universe.", "Power! Unlimited power!", "The dark side of the Force is a pathway to many abilities some consider to be unnatural."]
    self.showSimpleAlertController(title: "Star Wars Quote", message: "\"\(quotes[Int(arc4random_uniform(UInt32(quotes.count)))])\"")
  }
  
}
