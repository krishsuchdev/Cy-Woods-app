//
//  FacultyViewController.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 6/14/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit
import SafariServices

class FacultyViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var segmentedControl: UISegmentedControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setUpLargeTitleNavigationBar(enabled: true)
    
    FacultyManager.fetchTeachers {
      self.tableView.reloadData()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
      self.tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
  }
  
  @IBAction func segmentedControlValueChanged(_ sender: Any) {
    self.tableView.reloadData()
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    if self.segmentedControl.selectedSegmentIndex == 0 {
      return 1
    } else {
      return FacultyManager.getFacultyLetters().count
    }
  }
  
  func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    return self.segmentedControl.selectedSegmentIndex == 0 ? nil : FacultyManager.getFacultyLetters()
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if self.segmentedControl.selectedSegmentIndex == 0 {
      return nil
    } else {
      return FacultyManager.getFacultyLetters()[section]
    }
  }
  
  func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
    return index
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if self.segmentedControl.selectedSegmentIndex == 0 {
      return FacultyManager.departments.count
    } else {
      return FacultyManager.getFacultyForLetter(letter: FacultyManager.getFacultyLetters()[section]).count
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "FacultyCell")!
    
    if self.segmentedControl.selectedSegmentIndex == 0 {
      cell.textLabel!.text = FacultyManager.departments[indexPath.row].name
      cell.textLabel!.textColor = ThemeManager.tableViewCellTitleLabelColor
    } else {
      let facultyName = FacultyManager.getFacultyForLetter(letter: FacultyManager.getFacultyLetters()[indexPath.section])[indexPath.row].name
      let attributedFacultyName = NSMutableAttributedString(string: facultyName, attributes: [kCTFontAttributeName as NSAttributedStringKey : UIFont.systemFont(ofSize: 17.0)])
      let endOfLastName = (facultyName as NSString).range(of: ", ").location
      attributedFacultyName.addAttributes([kCTFontAttributeName as NSAttributedStringKey : UIFont.boldSystemFont(ofSize: 17.0)], range: NSRange(location: 0, length: endOfLastName))
      attributedFacultyName.addAttributes([NSAttributedStringKey.foregroundColor : ThemeManager.tableViewCellTitleLabelColor], range: NSRange(location: 0, length: facultyName.count))
      
      cell.textLabel!.attributedText = attributedFacultyName
    }
    
    let selectedView = UIView(frame: cell.frame)
    selectedView.backgroundColor = UIColor.gray.withAlphaComponent(ThemeManager.overallDark ? 0.3 : 0.15)
    cell.selectedBackgroundView = selectedView
    
    cell.backgroundColor = ThemeManager.tableViewCellBackgroundColor
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if self.segmentedControl.selectedSegmentIndex == 0 {
      self.performSegue(withIdentifier: "ToFacultyDetailViewController", sender: self)
    } else {
      if let website = FacultyManager.getFacultyForLetter(letter: FacultyManager.getFacultyLetters()[indexPath.section])[indexPath.row].website {
        let safariWebView = SFSafariViewController(url: URL(string: website)!)
        safariWebView.preferredBarTintColor = ThemeManager.viewControllerNavigationBarColor
        safariWebView.preferredControlTintColor = ThemeManager.viewControllerNavigationBarButtonColor
        self.present(safariWebView, animated: true, completion: nil)
      } else {
        self.showSimpleAlertController(title: "Unable to Open Website", message: "This teacher does not have a valid webpage.")
      }
    }
  }
  
  override func updateTheme() {
    super.updateTheme()
    
    self.tableView.sectionIndexColor = ThemeManager.primaryColor
    self.tableView.backgroundColor = ThemeManager.viewControllerBackgroundColor
    
    self.tableView.reloadData()
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    if segue.destination is FacultyDetailViewController {
      let viewController = segue.destination as! FacultyDetailViewController
      viewController.departmentIndex = self.tableView.indexPathForSelectedRow!.row
    }
  }
  
}
