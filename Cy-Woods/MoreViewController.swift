//
//  MoreViewController.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 6/10/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit
import RAMAnimatedTabBarController

class MoreViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!
  
  var moreItems = ["School", "Faculty", "About"]
  var moreImages = [#imageLiteral(resourceName: "Info"),#imageLiteral(resourceName: "Faculty"),#imageLiteral(resourceName: "Settings")]
  
  var settingSwitches = ["Enable Color Codes in Grades", "Show Seconds in Schedules", "Dark Theme"]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if #available(iOS 11.0, *) {
      self.navigationController!.navigationBar.prefersLargeTitles = false
      self.navigationController!.navigationBar.prefersLargeTitles = true
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if AdminLoginViewController.isLoggedIn() && !self.moreItems.contains("Admin") {
      self.moreItems.append("Admin")
      self.moreImages.append(#imageLiteral(resourceName: "Admin"))
      self.collectionView.reloadData()
    }
    if self.moreItems.count > 3 {
      self.collectionViewHeightConstraint.constant = 200
    }
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.moreItems.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MoreCollectionViewCell
    
    let cellTint = (indexPath.row % 2 == 0 ? ThemeManager.primaryColor : ThemeManager.secondaryColor)!
    
    cell.label.text = self.moreItems[indexPath.row]
    
    cell.icon.image = self.moreImages[indexPath.row]
    cell.icon.image = cell.icon.image!.withRenderingMode(.alwaysTemplate)
    cell.icon.tintColor = cellTint
    
    cell.layer.borderColor = cellTint.cgColor
    
    cell.label.textColor = ThemeManager.tableViewCellTitleLabelColor
    cell.backgroundColor = ThemeManager.tableViewCellBackgroundColor
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let title = self.moreItems[indexPath.row]
    if title == "School" {
      self.performSegue(withIdentifier: "ToSchoolInformation", sender: self)
    } else if title == "Faculty" {
      self.performSegue(withIdentifier: "ToFaculty", sender: self)
    } else if title == "About" {
      self.performSegue(withIdentifier: "ToAbout", sender: self)
    } else if title == "Admin" {
      self.performSegue(withIdentifier: "ToAdminAccess", sender: self)
    }
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    let cellSize = min(100.0, (collectionView.frame.width - 70.0) / 3.0)
    return CGSize(width: cellSize, height: cellSize)
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return "Settings"
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return self.settingSwitches.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell") as! MoreTableViewCell
    
    cell.label.text = self.settingSwitches[indexPath.row]
    cell.switch.onTintColor = ThemeManager.primaryColor
    
    if cell.label.text != "Dark Theme" {
      cell.key = cell.label.text!.capitalized.replacingOccurrences(of: " ", with: "")
      if AppDelegate.hasData(with: "CyWoodsApp.Settings.\(cell.key!)") {
        cell.switch.setOn(AppDelegate.loadData(with: "CyWoodsApp.Settings.\(cell.key!)") as! Bool, animated: false)
      } else {
        cell.switch.setOn(false, animated: false)
      }
    } else {
      cell.moreVC = self
      if AppDelegate.loadData(with: "CyWoodsApp.Theme") as! Int == 0 {
        cell.switch.setOn(false, animated: false)
      } else {
        cell.switch.setOn(true, animated: false)
      }
    }
    
    let selectedView = UIView(frame: cell.frame)
    selectedView.backgroundColor = UIColor.gray.withAlphaComponent(ThemeManager.overallDark ? 0.3 : 0.15)
    cell.selectedBackgroundView = selectedView
    
    cell.label.textColor = ThemeManager.tableViewCellTitleLabelColor
    cell.backgroundColor = ThemeManager.tableViewCellBackgroundColor
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath) as! MoreTableViewCell
    
    cell.switch.setOn(!cell.switch.isOn, animated: true)
    cell.switchValueChanged(self)
    
    self.tableView.deselectRow(at: indexPath, animated: false)
  }
  
  @IBAction func showThemeSelector(_ sender: Any) {
    let themeAlert = UIAlertController(title: "Select a Theme", message: nil, preferredStyle: .actionSheet)
    let availableThemes = ["Light Theme #1", "Light Theme #2", "Dark Theme #1", "Dark Theme #2", "Hypercolor Theme", "Terminal Theme", "Gold Dark Theme", "Bright Theme"]
    for themeIndex in 0..<availableThemes.count {
      let theme = availableThemes[themeIndex]
      themeAlert.addAction(UIAlertAction(title: theme, style: .destructive, handler: { (action) in
        self.selectTheme(themeIndex: themeIndex)
      }))
    }
    themeAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
    }))
    self.present(themeAlert, animated: true, completion: nil)
  }
  
  func selectTheme(themeIndex: Int) {
    ThemeManager.applyTheme(value: themeIndex)
    if #available(iOS 11.0, *) {
      self.navigationController?.navigationBar.largeTitleTextAttributes = UINavigationBar.appearance().largeTitleTextAttributes
    }
    self.navigationController?.navigationBar.titleTextAttributes = UINavigationBar.appearance().titleTextAttributes
    self.tabBarController?.tabBar.barTintColor = ThemeManager.viewControllerTabBarColor
    if let tabBar = self.tabBarController as? RAMAnimatedTabBarController {
      tabBar.changeSelectedColor(ThemeManager.viewControllerTabBarItemColor, iconSelectedColor: ThemeManager.viewControllerTabBarItemColor)
    }
    self.updateTheme()
  }
  
  @objc override func updateTheme() {
    super.updateTheme()
    
    self.view.backgroundColor = ThemeManager.viewControllerBackgroundColor
    self.collectionView.backgroundColor = ThemeManager.viewControllerBackgroundColor
    self.tableView.backgroundColor = ThemeManager.viewControllerBackgroundColor
    
    self.tableView.reloadData()
    self.collectionView.reloadData()
  }
  
}
