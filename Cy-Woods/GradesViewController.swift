//
//  GradesViewController.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 6/3/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit
import CoreData
import DropDown
import SwiftRandom

class GradesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  // Login
  @IBOutlet weak var loginView: UIView!
  @IBOutlet weak var gradesLabel: UILabel!
  @IBOutlet weak var usernameField: UITextField!
  @IBOutlet weak var passwordField: UITextField!
  @IBOutlet weak var loginButton: UIButton!
  @IBOutlet weak var loginActivityIndicator: UIActivityIndicatorView!
  
  // Grades View
  @IBOutlet weak var gradesView: UIView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var gradePeriodSegmentControl: UISegmentedControl!
  var expandedSemesterIndexes = [IndexPath]()
  var refreshControl = UIRefreshControl()
  var usersDropDown = DropDown()
  var refreshTimer: Timer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    GradesManager.gradesViewController = self
    self.setUpLargeTitleNavigationBar(enabled: true)
    
    self.refreshControl = UIRefreshControl()
    self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to Refresh")
    self.refreshControl.addTarget(self, action: #selector(self.refreshGrades), for: .valueChanged)
    self.tableView.addSubview(self.refreshControl)
    
    self.refreshTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { (timer) in
      let loggedIn = GradesManager.currentUser != nil
      if loggedIn {
        self.tableView.reloadRows(at: [IndexPath(row: self.tableView.numberOfRows(inSection: 0) - 1, section: 0)], with: .none)
      }
    }
    
    let loggedIn = GradesManager.currentUser != nil
    if loggedIn {
      self.showView(showLoginView: false, animate: false)
      self.refreshGrades()
    } else {
      self.showView(showLoginView: true, animate: false)
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if let selectedIndexPath = self.tableView.indexPathForSelectedRow {
      self.tableView.reloadData()
      self.tableView.selectRow(at: selectedIndexPath, animated: true, scrollPosition: .none)
      self.tableView.deselectRow(at: selectedIndexPath, animated: true)
    } else {
      self.tableView.reloadData()
    }
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    if self.tableView != nil { self.tableView.reloadData() }
  }
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    
    self.usernameField.resignFirstResponder()
    self.passwordField.resignFirstResponder()
  }
  
  func showView(showLoginView: Bool, animate: Bool) {
    (showLoginView ? self.loginView : self.gradesView)!.alpha = 0.0
    self.navigationItem.titleView!.alpha = showLoginView ? 1.0 : 0.0
    self.view.bringSubview(toFront: showLoginView ? self.loginView : self.gradesView)
    UIView.animate(withDuration: animate ? 1.0 : 0.0, animations: {
      (showLoginView ? self.loginView : self.gradesView)!.alpha = 1.0
      self.navigationItem.titleView!.alpha = showLoginView ? 0.0 : 1.0
    }) { (success) in
      self.usernameField.text = ""
      self.passwordField.text = ""
    }
  }
  
  @IBAction func gradePeriodSegmentControlValueChanged(_ sender: Any) {
    if self.gradePeriodSegmentControl.selectedSegmentIndex == 1 && !AppDelegate.hasData(with: "CyWoodsApp.Grades.ViewedCategoryGradeInfo") {
      let infoButton = UIButton(type: .infoLight)
      infoButton.addTarget(self, action: #selector(self.displaySemesterGradeInfo), for: .touchUpInside)
      let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
      navigationItem.rightBarButtonItem = infoBarButtonItem
    } else {
      navigationItem.rightBarButtonItem = nil
    }
    if self.gradePeriodSegmentControl.selectedSegmentIndex == 1 {
      self.refreshGrades()
    }
    self.tableView.reloadData()
  }
  
  @IBAction func loginFieldWasTapped(_ sender: Any) {
    self.usernameField.textColor = UIColor.black
    self.passwordField.textColor = UIColor.black
  }
  
  @IBAction func login(_ sender: Any) {
    self.touchesBegan(Set<UITouch>(), with: nil)
    
    self.loginActivityIndicator.startAnimating()
    
    GradesManager.addUser(username: usernameField.text!, password: passwordField.text!, successCompletionHandler: { (newUser) in
      self.loginActivityIndicator.stopAnimating()
      self.showView(showLoginView: false, animate: true)
      
      self.tableView.reloadData()
    }) { (error) in
      self.loginActivityIndicator.stopAnimating()
      self.showSimpleAlertController(title: "Unable to Login", message: error)
    }
  }
  
  @objc func refreshGrades() {
    let loggedIn = GradesManager.currentUser != nil
    if loggedIn {
      if self.gradePeriodSegmentControl.selectedSegmentIndex == 0 {
        GradesManager.fetchNineWeeksGrades(user: GradesManager.currentUser!, successCompletionHandler: { (classes) in
          GradesManager.fetchAbsences(user: GradesManager.currentUser!, successCompletionHandler: { (absences) in
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
          }, failureCompletionHandler: { (error) in
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.showSimpleAlertController(title: "Unable to Login", message: error)
          })
        }, failureCompletionHandler: { (error) in
          self.tableView.reloadData()
          self.refreshControl.endRefreshing()
          self.showSimpleAlertController(title: "Unable to Login", message: error)
        })
      } else {
        GradesManager.fetchSemesterGrades(user: GradesManager.currentUser!, successCompletionHandler: { (semesterClasses) in
          self.tableView.reloadData()
          self.refreshControl.endRefreshing()
        }, failureCompletionHandler: { (error) in
          self.tableView.reloadData()
          self.refreshControl.endRefreshing()
          self.showSimpleAlertController(title: "Unable to Login", message: error)
        })
      }
    }
  }
  
  @objc func displaySemesterGradeInfo() {
    self.showSimpleAlertController(title: "Semester Grade Info", message: "Tap on any class to see calculations on what grade you need to make on the final.")
    
    self.navigationItem.rightBarButtonItem = nil
    AppDelegate.saveData(with: true, key: "CyWoodsApp.Grades.ViewedSemesterGradeInfo")
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    if self.gradePeriodSegmentControl.selectedSegmentIndex == 0 {
      return GradesManager.currentUser == nil ? 0 : 1
    } else {
      return 1
    }
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return (GradesManager.getClasses(for: GradesManager.currentUser!)?.count ?? 0) + 2
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 {
      if indexPath.row == 0 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UsernameCell") as! GradesTableViewCell
        
        cell.titleLabel.text = GradesManager.currentUser!["name"] as? String
        
        let selectedView = UIView(frame: cell.frame)
        selectedView.backgroundColor = UIColor.gray.withAlphaComponent(ThemeManager.overallDark ? 0.3 : 0.15)
        cell.selectedBackgroundView = selectedView
        
        cell.titleLabel.textColor = ThemeManager.primaryColor
        cell.backgroundColor = ThemeManager.tableViewCellBackgroundColor
        
        return cell
      } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RefreshCell") as! GradesTableViewCell
        
        let readTimeFormatter = DateFormatter()
        readTimeFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss z"
        let refreshDate = readTimeFormatter.date(from: AppDelegate.loadData(with: "CyWoodsApp.Grades.\(GradesManager.currentUser!["username"] as! String).\(self.gradePeriodSegmentControl.selectedSegmentIndex == 0 ? "NineWeeksGrades" : "SemesterGrades").LastUpdated") as! String)!
        
        let minutes = refreshDate.numberOfMinutes(until: Date())
        let hours = refreshDate.numberOfHours(until: Date())
        let days = refreshDate.numberOfDays(until: Date())
        
        var refreshTime = "\(days) day\(days == 1 ? "" : "s") ago"
        if minutes == 0 {
          refreshTime = "Just Now"
        } else if minutes < 60 {
          refreshTime = "\(minutes) min\(minutes == 1 ? "" : "s"). ago"
        } else if hours < 20 {
          refreshTime = "\(hours) hr\(hours == 1 ? "" : "s"). ago"
        }
        
        cell.titleLabel.text = "Last Updated: \(refreshTime)"
        
        if GradesManager.isFetching {
          cell.activityIndicator.isHidden = false
          cell.subTitleLabel.isHidden = true
        } else {
          cell.activityIndicator.isHidden = true
          cell.subTitleLabel.isHidden = false
        }
        if GradesManager.isFetching != cell.activityIndicator.isAnimating {
          if GradesManager.isFetching {
            cell.activityIndicator.startAnimating()
          } else {
            cell.activityIndicator.stopAnimating()
          }
        }
        
        let selectedView = UIView(frame: cell.frame)
        selectedView.backgroundColor = UIColor.gray.withAlphaComponent(ThemeManager.overallDark ? 0.3 : 0.15)
        cell.selectedBackgroundView = selectedView
        
        cell.titleLabel.textColor = ThemeManager.tableViewCellDetailLabelColor
        cell.subTitleLabel.textColor = ThemeManager.tableViewCellMinorLabelColor
        cell.activityIndicator.activityIndicatorViewStyle = ThemeManager.overallDark ? .white : .gray
        cell.backgroundColor = ThemeManager.tableViewCellBackgroundColor
        
        return cell
      } else {
        if self.gradePeriodSegmentControl.selectedSegmentIndex == 0 {
          let course = GradesManager.getClasses(for: GradesManager.currentUser!)![indexPath.row - 1]
          
          let cellID = "Grade\(course["new assignments count"] as! Int > 0 ? "Notification" : "")Cell"
          let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! GradesTableViewCell
          
          let className = course["name"] as! String
          let teacherName = ((course["teacher"] as! [String : Any])["name"] as! String).capitalized
          let classGrade = /*!(AppDelegate.loadData(with: "CyWoodsApp.Settings.ShowSecondsInSchedules") as! Bool) ? ["", "95.76", "100.00", "99.02", "89.28", "96.79", "100.00", "100.00"][indexPath.row] : */course["grade"] as! String
          let letterColor = cell.colorLetter(letterGrade: cell.letterGrade(grade: classGrade), alpha: 1.0)
          
          if cellID.contains("Notification") {
            let newAssignmentsCount = course["new assignments count"] as! Int
            cell.descriptionLabel.text = "\(newAssignmentsCount) New Grade\(newAssignmentsCount == 1 ? "" : "s")"
            cell.descriptionLabel.textColor = ThemeManager.primaryColor
          }
          
          for subview in cell.subviews { if subview.tag == 1 { subview.removeFromSuperview() } }
          if !AppDelegate.hasData(with: "CyWoodsApp.Settings.EnableColorCodesInGrades") || AppDelegate.loadData(with: "CyWoodsApp.Settings.EnableColorCodesInGrades") as! Bool {
            let gradientView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: cell.frame.size.height))
            gradientView.applyGradient(horizontal: true, colors: [letterColor.withAlphaComponent(0.02), letterColor.withAlphaComponent(0.3)], locations: [0.6, 1.0])
            if #available(iOS 11.0, *) { gradientView.accessibilityIgnoresInvertColors = true }
            gradientView.tag = 1
            cell.addSubview(gradientView)
            cell.sendSubview(toBack: gradientView)
          }
          
          let highlightView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: cell.frame.size.height))
          highlightView.applyGradient(horizontal: true, colors: [UIColor.black.withAlphaComponent(0.1), letterColor.withAlphaComponent(0.3)], locations: [0.6, 1.0])
          cell.selectedBackgroundView = highlightView
          
          cell.titleLabel.text = className
          cell.subTitleLabel.text = teacherName
          cell.gradeLabel.text = classGrade
          
          cell.titleLabel.textColor = ThemeManager.tableViewCellTitleLabelColor
          cell.subTitleLabel.textColor = ThemeManager.tableViewCellDetailLabelColor
          cell.gradeLabel.textColor = ThemeManager.tableViewCellTitleLabelColor
          cell.backgroundColor = ThemeManager.tableViewCellBackgroundColor
          
          return cell
        } else {
          let cell = tableView.dequeueReusableCell(withIdentifier: "SemesterGradeCell") as! GradesTableViewCell
          
          let className = GradesManager.getClass(for: GradesManager.currentUser!, classIndex: indexPath.row - 1)!["name"] as! String
          let semesterGradeData = GradesManager.getSemesterClass(for: GradesManager.currentUser!, className: className) ?? ["semesterGrade" : "", "firstNineWeeksGrade" : "", "secondNineWeeksGrade" : "", "finalExamGrade" : ""]
          let classGrade = semesterGradeData["semesterGrade"] as! String
          let letterColor = cell.colorLetter(letterGrade: cell.letterGrade(grade: classGrade), alpha: 1.0)
          
          for subview in cell.subviews { if subview.tag == 1 { subview.removeFromSuperview() } }
          if !AppDelegate.hasData(with: "CyWoodsApp.Settings.EnableColorCodesInGrades") || AppDelegate.loadData(with: "CyWoodsApp.Settings.EnableColorCodesInGrades") as! Bool {
            let gradientView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 130.0))
            gradientView.applyGradient(horizontal: true, colors: [letterColor.withAlphaComponent(0.02), letterColor.withAlphaComponent(0.3)], locations: [0.6, 1.0])
            if #available(iOS 11.0, *) { gradientView.accessibilityIgnoresInvertColors = true }
            gradientView.tag = 1
            cell.addSubview(gradientView)
            cell.sendSubview(toBack: gradientView)
          }
          
          cell.titleLabel.text = className
          cell.firstNineWeeksDataLabel.text = semesterGradeData["firstNineWeeksGrade"] as? String
          cell.secondNineWeeksDataLabel.text = semesterGradeData["secondNineWeeksGrade"] as? String
          cell.finalExamDataLabel.text = semesterGradeData["finalExamGrade"] as? String
          cell.gradeLabel.text = classGrade
          
          if var singleClassSemesterGrade = Double(classGrade) {
            singleClassSemesterGrade = round(singleClassSemesterGrade) / 10.0
            
            let useGradeToNext = semesterGradeData["finalExamGradeToNext"] != nil
            let gradeGet = useGradeToNext ? semesterGradeData["finalExamGradeToNext"] as! String : semesterGradeData["finalExamGradeToKeep"] as! String
            if useGradeToNext { singleClassSemesterGrade += 1.0 }
            
            let letterGet = singleClassSemesterGrade >= 9 ? "A" : singleClassSemesterGrade >= 8 ? "B" : singleClassSemesterGrade >= 7 ? "C" : singleClassSemesterGrade >= 6.5 ? "C-" : "F"
            
            cell.descriptionLabel.text = "Get a\(gradeGet.starts(with: "8") ? "n" : "") \(gradeGet) on the final exam to \(useGradeToNext ? "get" : "keep") a\("AF".contains(letterGet) ? "n" : "") \(letterGet) in the class."
          } else {
            cell.descriptionLabel.text = "- -"
          }
          
          let selectedView = UIView(frame: cell.frame)
          selectedView.backgroundColor = UIColor.gray.withAlphaComponent(ThemeManager.overallDark ? 0.3 : 0.15)
          cell.selectedBackgroundView = selectedView
          
          cell.titleLabel.textColor = ThemeManager.tableViewCellTitleLabelColor
          cell.gradeLabel.textColor = ThemeManager.tableViewCellTitleLabelColor
          cell.firstNineWeeksLabel.textColor = ThemeManager.tableViewCellDetailLabelColor
          cell.firstNineWeeksDataLabel.textColor = ThemeManager.tableViewCellTitleLabelColor
          cell.secondNineWeeksLabel.textColor = ThemeManager.tableViewCellDetailLabelColor
          cell.secondNineWeeksDataLabel.textColor = ThemeManager.tableViewCellTitleLabelColor
          cell.finalExamLabel.textColor = ThemeManager.tableViewCellDetailLabelColor
          cell.finalExamDataLabel.textColor = ThemeManager.tableViewCellTitleLabelColor
          cell.descriptionLabel.textColor = ThemeManager.tableViewCellDetailLabelColor
          cell.backgroundColor = ThemeManager.tableViewCellBackgroundColor
          
          return cell
        }
      }
    } else  {
      return UITableViewCell()
    }
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)!
    if indexPath.section == 0 {
      if indexPath.row == 0 {
        self.usersDropDown.anchorView =  cell.contentView
        self.usersDropDown.bottomOffset = CGPoint(x: 0, y:(self.usersDropDown.anchorView?.plainView.bounds.height)!)
        self.usersDropDown.cornerRadius = 5
        self.usersDropDown.textColor = ThemeManager.tableViewCellTitleLabelColor
        self.usersDropDown.backgroundColor = ThemeManager.tableViewCellBackgroundColor.withAlphaComponent(0.9)
        self.usersDropDown.selectionBackgroundColor = ThemeManager.overallDark ? UIColor.white.withAlphaComponent(0.2) : UIColor.black.withAlphaComponent(0.2)
        
        var usernames = [String]()
        for user in GradesManager.users { usernames.append("\(/*Utility.decode(*/user["name"] as! String/*)*/) (\(Utility.decode(user["username"] as! String)!))") }
        usernames.append("＋ Add Account")
        usernames.append("←  Log Out")
        self.usersDropDown.dataSource = usernames
        
        self.usersDropDown.show()
        UIView.animate(withDuration: 0.25, animations: {
          self.view.alpha = 0.75
        })
        
        func deselection() {
          UIView.animate(withDuration: 0.25, animations: {
            self.view.alpha = 1.0
          })
          tableView.deselectRow(at: indexPath, animated: true)
        }
        
        self.usersDropDown.cancelAction = { deselection() }
        self.usersDropDown.selectionAction = { (index: Int, item: String) in
          deselection()
          if item.starts(with: "＋ ") {
            let alert = UIAlertController(title: "Add New User", message: "Enter Username and Password:", preferredStyle: UIAlertControllerStyle.alert)
            alert.addTextField(configurationHandler: {(textField: UITextField!) in
              textField.placeholder = "Username"
            })
            alert.addTextField(configurationHandler: {(textField: UITextField!) in
              textField.placeholder = "Password"
              textField.isSecureTextEntry = true
            })
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (_) -> Void in
            }))
            alert.addAction(UIAlertAction(title: "Add User", style: UIAlertActionStyle.default, handler: { (_) -> Void in
              let loadingAlert = UIAlertController(title: "Loading", message: "Adding user...", preferredStyle: UIAlertControllerStyle.alert)
              self.present(loadingAlert, animated: true, completion: nil)
              GradesManager.addUser(username: alert.textFields![0].text!, password: alert.textFields![1].text!, successCompletionHandler: { (newUser) in
                self.tableView.reloadData()
                loadingAlert.dismiss(animated: true, completion: nil)
              }, failureCompletionHandler: { (error) in
                loadingAlert.dismiss(animated: true, completion: {
                  self.showSimpleAlertController(title: "Unable to Add User", message: error)
                })
              })
            }))
            self.present(alert, animated: true, completion: nil)
          } else if item.starts(with: "← ") {
            let alert = UIAlertController(title: "Log Out", message: "Do you want to log out of all signed in accounts?", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "This Account", style: UIAlertActionStyle.default, handler: { (_) -> Void in
              GradesManager.removeCurrentUser()
              self.tableView.reloadData()
              if GradesManager.currentUser == nil {
                self.showView(showLoginView: true, animate: false)
              }
            }))
            alert.addAction(UIAlertAction(title: "All Accounts", style: UIAlertActionStyle.destructive, handler: { (_) -> Void in
              GradesManager.removeAllUsers()
              self.tableView.reloadData()
              self.showView(showLoginView: true, animate: false)
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (_) -> Void in
            }))
            self.present(alert, animated: true, completion: nil)
          } else {
            GradesManager.currentUser = GradesManager.users[index]
            self.tableView.reloadData()
            if self.gradePeriodSegmentControl.selectedSegmentIndex == 0 {
              self.refreshGrades()
            }
          }
        }
      } else if indexPath.row == self.tableView.numberOfRows(inSection: 0) - 1 {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if !GradesManager.isFetching {
          UIImpactFeedbackGenerator().impactOccurred()
          self.refreshGrades()
        }
      } else if self.gradePeriodSegmentControl.selectedSegmentIndex == 1 {
        if self.expandedSemesterIndexes.contains(indexPath) {
          self.expandedSemesterIndexes.remove(at: self.expandedSemesterIndexes.index(of: indexPath)!)
        } else {
          self.expandedSemesterIndexes.append(indexPath)
        }
        self.tableView.reloadRows(at: [indexPath], with: .fade)
      }
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return indexPath.row == 0 ? 44.0 : indexPath.row == ((GradesManager.getClasses(for: GradesManager.currentUser!)?.count ?? 0) + 1) ? 56.0 : self.gradePeriodSegmentControl.selectedSegmentIndex == 0 ? 56.0 : self.expandedSemesterIndexes.contains(indexPath) ? 110.0 : 74.0
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    if (segue.destination is GradesDetailViewController) {
      let viewController = segue.destination as! GradesDetailViewController
      viewController.classIndex = (self.tableView.indexPathForSelectedRow ?? self.tableView.indexPath(for: sender as! UITableViewCell)!).row - 1
    }
  }
  
  override func updateTheme() {
    super.updateTheme()
    
    self.view.backgroundColor = ThemeManager.viewControllerBackgroundColor
    
    self.loginView.backgroundColor = ThemeManager.tableViewCellBackgroundColor
    for subview in self.loginView.subviews { subview.backgroundColor = ThemeManager.tableViewCellBackgroundColor }
    self.gradesLabel.textColor = ThemeManager.tableViewCellTitleLabelColor
    self.usernameField.textColor = ThemeManager.tableViewCellTitleLabelColor
    self.usernameField.tintColor = ThemeManager.primaryColor
    self.usernameField.attributedPlaceholder = NSAttributedString(string: self.usernameField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : ThemeManager.tableViewCellMinorLabelColor])
    self.passwordField.textColor = ThemeManager.tableViewCellTitleLabelColor
    self.passwordField.tintColor = ThemeManager.primaryColor
    self.passwordField.attributedPlaceholder = NSAttributedString(string: self.passwordField.placeholder!, attributes: [NSAttributedStringKey.foregroundColor : ThemeManager.tableViewCellMinorLabelColor])
    self.loginActivityIndicator.activityIndicatorViewStyle = ThemeManager.overallDark ? .white : .gray
    self.loginButton.backgroundColor = ThemeManager.primaryColor
    
    self.tableView.backgroundColor = ThemeManager.viewControllerBackgroundColor
    
    self.tableView.reloadData()
  }
  
}
