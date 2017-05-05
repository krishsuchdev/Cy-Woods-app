//
//  GradesDetailViewController.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 6/13/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit
import SafariServices
import Firebase

class GradesDetailViewController: UITableViewController {
  
  var classIndex: Int!
  var newAssignmentIndexes: [Int]!
  
  @IBOutlet weak var classInfoSegmentControl: UISegmentedControl!
  var expandedCategories = [IndexPath]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setUpLargeTitleNavigationBar(enabled: true)
    self.navigationItem.title = GradesManager.getClass(for: GradesManager.currentUser!, classIndex: self.classIndex)!["name"] as? String
    
    self.newAssignmentIndexes = [Int]()
    let course = GradesManager.getAssignments(for: GradesManager.currentUser!, classIndex: self.classIndex)!
    for assignmentIndex in 0..<course.count {
      let assignment = course[assignmentIndex]
      if assignment["new"] as! Bool {
        self.newAssignmentIndexes.append(assignmentIndex)
      }
    }
    GradesManager.setNewForAssignmentsInClass(for: GradesManager.currentUser!, classIndex: self.classIndex, new: false)
    
    self.classInfoSegmentControlValueChanged(self)
  }
  
  @IBAction func classInfoSegmentControlValueChanged(_ sender: Any) {
    if self.classInfoSegmentControl.selectedSegmentIndex == 1 && !AppDelegate.hasData(with: "CyWoodsApp.Grades.ViewedCategoryGradeInfo") {
      let infoButton = UIButton(type: .infoLight)
      infoButton.addTarget(self, action: #selector(self.displayCategoryGradeInfo), for: .touchUpInside)
      let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
      navigationItem.rightBarButtonItem = infoBarButtonItem
    } else {
      navigationItem.rightBarButtonItem = nil
    }
    self.tableView.reloadData()
  }
  
  @objc func displayCategoryGradeInfo() {
    self.showSimpleAlertController(title: "Category Grade Info", message: "Tap on any category to see calculations on what grade you need to make on the next assignment.")
    
    self.navigationItem.rightBarButtonItem = nil
    AppDelegate.saveData(with: true, key: "CyWoodsApp.Grades.ViewedCategoryGradeInfo")
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return [3, 2][self.classInfoSegmentControl.selectedSegmentIndex]
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if self.classInfoSegmentControl.selectedSegmentIndex == 0 {
      return [3, 2, 2][section]
    } else {
      if section == 0 {
        return GradesManager.getCategories(for: GradesManager.currentUser!, classIndex: self.classIndex)?.count ?? 0
      } else if section == 1 {
        return GradesManager.getAssignments(for: GradesManager.currentUser!, classIndex: self.classIndex)?.count ?? 0
      } else {
        return 0
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if self.classInfoSegmentControl.selectedSegmentIndex == 0 {
      let cell = tableView.dequeueReusableCell(withIdentifier: "ClassInfoCell")!
      
      let course = GradesManager.getClass(for: GradesManager.currentUser!, classIndex: self.classIndex)!
      
      cell.textLabel!.text = [["Class", "Grade", "Assignments"],["Teacher", "Email"],["Absences", "Tardies"]][indexPath.section][indexPath.row]
      cell.textLabel!.text = "\(cell.textLabel!.text!):"
      cell.detailTextLabel!.text = [[course["name"] as? String, course["grade"] as? String, "\(GradesManager.getAssignments(for: GradesManager.currentUser!, classIndex: self.classIndex)!.count)"],[(course["teacher"] as! [String : String])["name"]?.capitalized, (course["teacher"] as! [String : String])["email"]],["\(GradesManager.getUnexcused(for: GradesManager.currentUser!, classPeriod: self.classIndex + 1) ?? 0)", "\(GradesManager.getTardies(for: GradesManager.currentUser!, classPeriod: self.classIndex + 1) ?? 0)"]][indexPath.section][indexPath.row]
      
      if cell.textLabel!.text!.starts(with: "Teacher") && cell.detailTextLabel!.text!.contains(", ") {
        let teacherSplit = cell.detailTextLabel!.text!.replacingOccurrences(of: ",", with: "").components(separatedBy: " ")
        cell.detailTextLabel!.text = teacherSplit[1] + " " + teacherSplit[0]
      }
      
      let indexPathsSelected = [IndexPath(row: 2, section: 0), IndexPath(row: 0, section: 1), IndexPath(row: 1, section: 1)]
      cell.selectionStyle = indexPathsSelected.contains(indexPath) ? .blue : .none
      cell.accessoryType = indexPathsSelected.contains(indexPath) ? .disclosureIndicator : .none
      
      let selectedView = UIView(frame: cell.frame)
      selectedView.backgroundColor = UIColor.gray.withAlphaComponent(ThemeManager.overallDark ? 0.3 : 0.15)
      cell.selectedBackgroundView = selectedView
      
      cell.textLabel!.textColor = ThemeManager.tableViewCellTitleLabelColor
      cell.detailTextLabel!.textColor = ThemeManager.tableViewCellDetailLabelColor
      cell.backgroundColor = ThemeManager.tableViewCellBackgroundColor
      
      return cell
    } else {
      if indexPath.section == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryCell") as! GradesTableViewCell
        
        let category = GradesManager.getCategory(for: GradesManager.currentUser!, classIndex: self.classIndex, categoryIndex: indexPath.row)!
        let categoryName = category["name"] as! String
        let categoryWeight = category["weight"] as! String
        let categoryAverage = category["average"] as! String
        
        let letterColor = cell.colorLetter(letterGrade: cell.letterGrade(grade: categoryAverage), alpha: 1.0)
        
        for subview in cell.subviews { if subview.tag == 1 { subview.removeFromSuperview() } }
        let gradientView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 70.0))
        gradientView.applyGradient(horizontal: true, colors: [letterColor.withAlphaComponent(0.02), letterColor.withAlphaComponent(0.3)], locations: [0.7, 1.0])
        if #available(iOS 11.0, *) { gradientView.accessibilityIgnoresInvertColors = true }
        gradientView.tag = 1
        cell.addSubview(gradientView)
        cell.sendSubview(toBack: gradientView)
        
        cell.titleLabel.text = categoryName
        cell.subTitleLabel.text = categoryWeight
        cell.gradeLabel.text = categoryAverage
        
        let classGrade = GradesManager.getClass(for: GradesManager.currentUser!, classIndex: self.classIndex)!["grade"] as! String
        if var singleClassGrade = Double(classGrade) {
          singleClassGrade = round(singleClassGrade) / 10.0
          
          let useGradeToNext = category["gradeToNext"] != nil
          let gradeGet = useGradeToNext ? category["gradeToNext"] as! String : category["gradeToKeep"] as! String
          if useGradeToNext { singleClassGrade += 1.0 }
          
          let letterGet = singleClassGrade >= 9 ? "A" : singleClassGrade >= 8 ? "B" : singleClassGrade >= 7 ? "C" : singleClassGrade >= 6.5 ? "C-" : "F"
          
          cell.descriptionLabel.text = "Get a\(gradeGet.starts(with: "8") ? "n" : "") \(gradeGet) on the next \("\(categoryName) ".replacingOccurrences(of: "s ", with: "").trimmingCharacters(in: CharacterSet.whitespaces).replacingOccurrences(of: "ing ", with: " ")) to \(useGradeToNext ? "get" : "keep") a\("AF".contains(letterGet) ? "n" : "") \(letterGet) in the class."
        } else {
          cell.descriptionLabel.text = "- -"
        }
        
        let selectedView = UIView(frame: cell.frame)
        selectedView.backgroundColor = UIColor.gray.withAlphaComponent(ThemeManager.overallDark ? 0.3 : 0.15)
        cell.selectedBackgroundView = selectedView
        
        cell.titleLabel.textColor = ThemeManager.tableViewCellTitleLabelColor
        cell.subTitleLabel.textColor = ThemeManager.tableViewCellDetailLabelColor
        cell.gradeLabel.textColor = ThemeManager.tableViewCellTitleLabelColor
        cell.descriptionLabel.textColor = ThemeManager.tableViewCellMinorLabelColor
        cell.backgroundColor = ThemeManager.tableViewCellBackgroundColor
        
        return cell
      } else if indexPath.section == 1 {
        let assignment = GradesManager.getAssignment(for: GradesManager.currentUser!, classIndex: self.classIndex, assignmentIndex: indexPath.row)!
        
        let cellID = "Grade\(self.newAssignmentIndexes.contains(indexPath.row) ? "Notification" : "")Cell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! GradesTableViewCell
        
        let assignmentName = assignment["name"] as! String
        var categoryName = assignment["type"] as! String
        let assignmentGrade = assignment["grade"] as! String
        let letterColor = cell.colorLetter(letterGrade: cell.letterGrade(grade: assignmentGrade), alpha: 1.0)
        
        if cellID.contains("Notification") {
          cell.descriptionLabel.textColor = ThemeManager.primaryColor
        }
        
        for subview in cell.subviews { if subview.tag == 1 { subview.removeFromSuperview() } }
        if !AppDelegate.hasData(with: "CyWoodsApp.Settings.EnableColorCodesInGrades") || AppDelegate.loadData(with: "CyWoodsApp.Settings.EnableColorCodesInGrades") as! Bool {
          let gradientView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: cell.frame.size.height))
          gradientView.applyGradient(horizontal: true, colors: [letterColor.withAlphaComponent(0.02), letterColor.withAlphaComponent(0.2)], locations: [0.6, 1.0])
          if #available(iOS 11.0, *) { gradientView.accessibilityIgnoresInvertColors = true }
          gradientView.tag = 1
          cell.addSubview(gradientView)
          cell.sendSubview(toBack: gradientView)
        }
        
        categoryName = categoryName.replacingOccurrences(of: "s ", with: "").trimmingCharacters(in: CharacterSet.whitespaces).replacingOccurrences(of: "ing ", with: " ")
        
        cell.titleLabel.text = assignmentName
        cell.subTitleLabel.text = categoryName
        cell.gradeLabel.text = assignmentGrade
        
        let selectedView = UIView(frame: cell.frame)
        selectedView.backgroundColor = UIColor.gray.withAlphaComponent(ThemeManager.overallDark ? 0.3 : 0.15)
        cell.selectedBackgroundView = selectedView
        
        cell.titleLabel.textColor = ThemeManager.tableViewCellTitleLabelColor
        cell.subTitleLabel.textColor = ThemeManager.tableViewCellDetailLabelColor
        cell.gradeLabel.textColor = ThemeManager.tableViewCellTitleLabelColor
        cell.backgroundColor = ThemeManager.tableViewCellBackgroundColor
        
        if (assignment["extra"] as! [String : Any]).keys.contains("strikeThrough") && (assignment["extra"] as! [String : Any])["strikeThrough"] as! Bool {
          let attributedGrade = NSMutableAttributedString(string: cell.gradeLabel.text!)
          attributedGrade.addAttribute(NSAttributedStringKey.strikethroughStyle, value: 2, range: NSMakeRange(0, attributedGrade.length))
          cell.gradeLabel.attributedText = attributedGrade
        }
        
        return cell
      } else {
        return UITableViewCell()
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if self.classInfoSegmentControl.selectedSegmentIndex == 0 {
      if indexPath.section == 0 && indexPath.row == 2 {
        self.classInfoSegmentControl.selectedSegmentIndex = 1
        self.classInfoSegmentControlValueChanged(self)
      } else if indexPath.section == 1 {
        let cell = tableView.cellForRow(at: indexPath)!
        if indexPath.row == 0 {
          let teacherSplit = cell.detailTextLabel!.text!.components(separatedBy: " ")
          var teacherID = "\(teacherSplit[1])\(teacherSplit[0])".lowercased()
          teacherID += "\(teacherID.count)"
          
          let reference = Database.database().reference()
          reference.child("Faculty Tab").child("Faculty").child(teacherID).observeSingleEvent(of: .value, with: { (snapshot) in
            if let teacherDictionary = snapshot.value as? NSDictionary {
              let safariWebView = SFSafariViewController(url: URL(string: teacherDictionary["Website"] as! String)!)
              safariWebView.preferredBarTintColor = ThemeManager.viewControllerNavigationBarColor
              safariWebView.preferredControlTintColor = ThemeManager.viewControllerNavigationBarButtonColor
              self.present(safariWebView, animated: true, completion: nil)
            } else {
              self.showSimpleAlertController(title: "Unable to Display Website", message: "No website for this teacher has been found.")
            }
          })
        } else if indexPath.row == 1 {
          UIApplication.shared.open(URL(string: "mailto:\(cell.detailTextLabel!.text!)")!, options: [String : Any](), completionHandler: { (success) in
            self.tableView.deselectRow(at: indexPath, animated: true)
          })
        }
      }
    } else {
      if indexPath.section == 0 {
        if self.expandedCategories.contains(indexPath) {
          self.expandedCategories.remove(at: self.expandedCategories.index(of: indexPath)!)
        } else {
          self.expandedCategories.append(indexPath)
        }
        self.tableView.reloadRows(at: [indexPath], with: .fade)
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return [[44.0, 44.0, 44.0], [self.expandedCategories.contains(indexPath) ? 70.0 : 38.0, 50.0]][self.classInfoSegmentControl.selectedSegmentIndex][indexPath.section]
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    if (segue.destination is GradesAssignmentDetailViewController) {
      let viewController = segue.destination as! GradesAssignmentDetailViewController
      viewController.classIndex = self.classIndex
      viewController.assignmentIndex = (self.tableView.indexPathForSelectedRow ?? self.tableView.indexPath(for: sender as! UITableViewCell)!).row
    }
  }
  
  override func updateTheme() {
    super.updateTheme()
    
    self.tableView.backgroundColor = ThemeManager.viewControllerBackgroundColor
    
    self.tableView.reloadData()
  }
  
}
