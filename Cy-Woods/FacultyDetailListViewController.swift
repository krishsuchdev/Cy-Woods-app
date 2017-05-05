//
//  FacultyListViewController.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 6/15/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit
import SafariServices

class FacultyDetailListViewController: UITableViewController {
  
  var departmentIndex: Int!
  var subjectIndex: Int!
  var faculty = [Faculty]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setUpLargeTitleNavigationBar(enabled: true)
    
    let subject = FacultyManager.departments[departmentIndex].getSubjects()[subjectIndex]
    
    self.faculty = subject.getFaculty()
    self.navigationItem.title = subject.name
    self.tableView.reloadData()
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.faculty.count
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "FacultyCell")!
    
    let facultyName = self.faculty[indexPath.row].name
    let attributedFacultyName = NSMutableAttributedString(string: facultyName, attributes: [kCTFontAttributeName as NSAttributedStringKey : UIFont.systemFont(ofSize: 17.0)])
    let endOfLastName = (facultyName as NSString).range(of: ", ").location
    attributedFacultyName.addAttributes([kCTFontAttributeName as NSAttributedStringKey : UIFont.boldSystemFont(ofSize: 17.0)], range: NSRange(location: 0, length: endOfLastName))
    attributedFacultyName.addAttributes([NSAttributedStringKey.foregroundColor : ThemeManager.tableViewCellTitleLabelColor], range: NSRange(location: 0, length: facultyName.count))
    
    cell.textLabel!.attributedText = attributedFacultyName
    
    let selectedView = UIView(frame: cell.frame)
    selectedView.backgroundColor = UIColor.gray.withAlphaComponent(ThemeManager.overallDark ? 0.3 : 0.15)
    cell.selectedBackgroundView = selectedView
    
    cell.backgroundColor = ThemeManager.tableViewCellBackgroundColor
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if let website = self.faculty[indexPath.row].website {
      let safariWebView = SFSafariViewController(url: URL(string: website)!)
      safariWebView.preferredBarTintColor = ThemeManager.viewControllerNavigationBarColor
      safariWebView.preferredControlTintColor = ThemeManager.viewControllerNavigationBarButtonColor
      self.present(safariWebView, animated: true, completion: nil)
    } else {
      self.showSimpleAlertController(title: "Unable to Open Website", message: "This teacher does not have a valid webpage.")
    }
  }
  
  override func updateTheme() {
    super.updateTheme()
    
    self.tableView.backgroundColor = ThemeManager.viewControllerBackgroundColor
    
    self.tableView.reloadData()
  }
  
}
