//
//  FacultyDetailViewController.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 6/15/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit

class FacultyDetailViewController: UITableViewController {
  
  var departmentIndex: Int!
  var subjects = [Subject]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setUpLargeTitleNavigationBar(enabled: true)
    
    let department = FacultyManager.departments[departmentIndex]
    
    self.subjects = department.getSubjects()
    self.navigationItem.title = department.name
    self.tableView.reloadData()
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.subjects.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "FacultyCell")!
    
    cell.textLabel!.text = self.subjects[indexPath.row].name
    cell.textLabel!.textColor = ThemeManager.tableViewCellTitleLabelColor
    cell.detailTextLabel!.text = "\(self.subjects[indexPath.row].faculty.count)"
    cell.detailTextLabel!.textColor = ThemeManager.tableViewCellDetailLabelColor
    
    let selectedView = UIView(frame: cell.frame)
    selectedView.backgroundColor = UIColor.gray.withAlphaComponent(ThemeManager.overallDark ? 0.3 : 0.15)
    cell.selectedBackgroundView = selectedView
    
    cell.backgroundColor = ThemeManager.tableViewCellBackgroundColor
    
    return cell
  }
  
  override func updateTheme() {
    super.updateTheme()
    
    self.tableView.backgroundColor = ThemeManager.viewControllerBackgroundColor
    
    self.tableView.reloadData()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    if segue.destination is FacultyDetailListViewController {
      let viewController = segue.destination as! FacultyDetailListViewController
      viewController.departmentIndex = self.departmentIndex
      viewController.subjectIndex = self.tableView.indexPathForSelectedRow?.row
    }
  }
  
}
