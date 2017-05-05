//
//  SchedulesViewController.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 10/21/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit

class SchedulesViewController: UITableViewController {
  
  @IBOutlet weak var scheduleVariationSegmentControl: UISegmentedControl!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setUpLargeTitleNavigationBar(enabled: true)
    
    Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateTableView), userInfo: nil, repeats: true)
    
    if !AppDelegate.hasData(with: "CyWoodsApp.Schedules.ViewedInfo") {
      let infoButton = UIButton(type: .infoLight)
      infoButton.addTarget(self, action: #selector(self.displayScheduleInfo), for: .touchUpInside)
      let infoBarButtonItem = UIBarButtonItem(customView: infoButton)
      navigationItem.rightBarButtonItem = infoBarButtonItem
    }
    
    if AppDelegate.hasData(with: "CyWoodsApp.Schedules.Lunch") {
      self.scheduleVariationSegmentControl.selectedSegmentIndex = AppDelegate.loadData(with: "CyWoodsApp.Schedules.Lunch") as! Int
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    SchedulesManager.fetchSchedules {
      self.tableView.reloadData()
    }
  }
  
  @IBAction func variationSegmentControlValueChanged(_ sender: Any) {
    AppDelegate.saveData(with: self.scheduleVariationSegmentControl.selectedSegmentIndex, key: "CyWoodsApp.Schedules.Lunch")
    self.tableView.reloadData()
  }
  
  @objc func displayScheduleInfo() {
    self.showSimpleAlertController(title: "Bell Schedule Info", message: "Schedules will automatically change depending on the schedule for that day.")
    
    self.navigationItem.rightBarButtonItem = nil
    AppDelegate.saveData(with: true, key: "CyWoodsApp.Schedules.ViewedInfo")
  }
  
  func nameForSelectedSegmentIndex() -> String {
    return self.scheduleVariationSegmentControl.titleForSegment(at: self.scheduleVariationSegmentControl.selectedSegmentIndex)!
  }
  
  @objc func updateTableView() {
    self.tableView.reloadData()
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return SchedulesManager.getTodaysSchedule() == nil ? 0 : 1
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return SchedulesManager.todaysSchedule!
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return SchedulesManager.getTodaysSchedule()?.bellScheduleVariations[self.nameForSelectedSegmentIndex()]?.bellScheduleItems.count ?? 0
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "BellScheduleCell") as! BellSchedulesTableViewCell
    
    let bellScheduleItem = SchedulesManager.getTodaysSchedule()!.bellScheduleVariations[self.nameForSelectedSegmentIndex()]!.bellScheduleItems[indexPath.row]
    cell.titleLabel.text = bellScheduleItem.itemName
    cell.subTitleLabel.text = "\(bellScheduleItem.getStartTime()) - \(bellScheduleItem.getEndTime()) (\(bellScheduleItem.getLength()) min.)"
    
    if bellScheduleItem.currentTimeIsInRange() {
      if AppDelegate.loadData(with: "CyWoodsApp.Settings.ShowSecondsInSchedules") as! Bool {
        cell.subTitleLabel.text! += " (\(bellScheduleItem.getCurrentTime().numberOfMinutes(until: bellScheduleItem.endTime)) min. \(bellScheduleItem.getCurrentTime().numberOfSeconds(until: bellScheduleItem.endTime) % 60) sec."
      } else {
        cell.subTitleLabel.text! += " (\(bellScheduleItem.getCurrentTime().numberOfMinutes(until: bellScheduleItem.endTime) + 1) min."
      }
      cell.subTitleLabel.text! += " left)"
    }
    
    cell.titleLabel.textColor = ThemeManager.tableViewCellTitleLabelColor
    cell.subTitleLabel.textColor = ThemeManager.tableViewCellDetailLabelColor
    cell.backgroundColor = bellScheduleItem.currentTimeIsInRange() ? ThemeManager.viewControllerNavigationBarButtonColor.withAlphaComponent(ThemeManager.overallDark ? 0.25 : 0.5) : ThemeManager.tableViewCellBackgroundColor
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 50.0
  }
  
}
