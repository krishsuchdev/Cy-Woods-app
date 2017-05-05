//
//  AthleticsViewController.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 11/11/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit
import SafariServices

class AthleticsViewController: UITableViewController {
  
  @IBOutlet weak var sportSegmentControl: UISegmentedControl!
  var typeSegmentIndex: Int?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.setUpLargeTitleNavigationBar(enabled: true)
    if self.traitCollection.horizontalSizeClass == .compact {
      self.sportSegmentControl.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.systemFont(ofSize: 12.0)], for: .normal)
    }
    
    self.variationSegmentControlValueChanged(self.sportSegmentControl)
  }
  
  @IBAction func variationSegmentControlValueChanged(_ sender: Any) {
    self.typeSegmentIndex = self.selectedSportHasTypes() ? 0 : nil
    self.reloadAthleticGames()
  }
  
  @IBAction func viewAllAthleticScores(_ sender: Any) {
    let safariWebView = SFSafariViewController(url: URL(string: "https://www.rankonesport.com/Schedules/View_Schedule_All.aspx?D=5e3c64f6-eabb-401d-8901-2da09a8500c8&S=1017")!)
    safariWebView.preferredBarTintColor = ThemeManager.viewControllerNavigationBarColor
    safariWebView.preferredControlTintColor = ThemeManager.viewControllerNavigationBarButtonColor
    self.present(safariWebView, animated: true, completion: nil)
  }
  
  func reloadAthleticGames() {
    self.tableView.reloadData()
    if self.getSelectedAthleticGames() == nil && (self.typeSegmentIndex != nil) == self.selectedSportHasTypes() {
      AthleticsManager.fetchAthleticGames(sport: self.getSelectedSport(withType: true), type: self.typeSegmentIndex) {
        self.tableView.reloadData()
      }
    }
  }
  
  func getSelectedSport(withType: Bool) -> String {
    var sport = self.sportSegmentControl.titleForSegment(at: self.sportSegmentControl.selectedSegmentIndex)!
    if withType {
      sport = AthleticsManager.getSportName(selectedSport: sport, typeIndex: self.typeSegmentIndex)
    }
    return sport
  }
  
  func selectedSportHasTypes() -> Bool {
    return AthleticsManager.sportHasTypes(sport: self.getSelectedSport(withType: false))
  }
  
  func getSelectedAthleticGames() -> [AthleticGame]? {
    return AthleticsManager.athleticGames[self.getSelectedSport(withType: true)]
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    let games = self.getSelectedAthleticGames()?.count ?? 0
    return (games == 0 ? 1 : games) + (self.selectedSportHasTypes() ? 1 : 0)
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    if AthleticsManager.isFetching || (section == 0 && self.selectedSportHasTypes()) || self.getSelectedAthleticGames()?.count ?? 0 == 0 { return nil }
    return "Game \(section + (self.selectedSportHasTypes() ? 0 : 1))"
  }
  
  override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
    view.tintColor = ThemeManager.viewControllerBackgroundColor
    let header = view as! UITableViewHeaderFooterView
    header.textLabel?.textColor = ThemeManager.tableViewCellTitleLabelColor
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 0 && self.selectedSportHasTypes() {
      let cell = tableView.dequeueReusableCell(withIdentifier: "SelectTypeCell") as! AthleticsTableViewCell
      
      if self.typeSegmentIndex == nil {
        self.typeSegmentIndex = 0
        cell.typeSegmentControl.selectedSegmentIndex = 0
      }
      
      cell.selectionStyle = .none
      
      cell.athleticsViewController = self
      
      return cell
    } else if indexPath.section <= 1 && self.getSelectedAthleticGames()?.count ?? 0 == 0 {
      let cellID = AthleticsManager.isFetching ? "RefreshCell" : "NoScheduleCell"
      let cell = tableView.dequeueReusableCell(withIdentifier: cellID) as! AthleticsTableViewCell
      
      if AthleticsManager.isFetching {
        cell.refreshControl.startAnimating()
      }
      
      cell.refreshControl.activityIndicatorViewStyle = ThemeManager.overallDark ? .white : .gray
      cell.backgroundColor = ThemeManager.tableViewCellBackgroundColor
      
      return cell
    } else {
      let cell = tableView.dequeueReusableCell(withIdentifier: "ScoreCell") as! AthleticsTableViewCell
      
      let game = self.getSelectedAthleticGames()![indexPath.section - (self.selectedSportHasTypes() ? 1 : 0)]
      cell.sideLabel.text = game.home ? "vs" : "at"
      cell.opponentBackground.backgroundColor = game.opponentPrimaryColor
      cell.opponentLabel.textColor = game.opponentSecondaryColor
      cell.opponentLabel.text = game.opponent
      cell.scoreLabel.attributedText = game.score
      cell.outcomeLabel.text = game.result == "Win" ? "W" : game.result == "Lose" ? "L" : game.result == "Tie" ? "T" : ""
      cell.outcomeLabel.textColor = game.result == "Win" ? UIColor.green.darker(amount: 0.1) : UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0)
      
      if #available(iOS 11.0, *) {
        cell.opponentBackground.accessibilityIgnoresInvertColors = true
        cell.opponentLabel.accessibilityIgnoresInvertColors = true
        cell.outcomeLabel.accessibilityIgnoresInvertColors = true
      }
      
      for subview in cell.subviews { if subview.tag == 1 { subview.removeFromSuperview() } }
      if game.result == "Win" {
        let gradientView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        gradientView.applyGradient(horizontal: true, colors: [UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.01), UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.2)], locations: [0.8, 1.0])
        if #available(iOS 11.0, *) { gradientView.accessibilityIgnoresInvertColors = true }
        gradientView.tag = 1
        cell.addSubview(gradientView)
        cell.sendSubview(toBack: gradientView)
      }
      
      let selectedView = UIView(frame: cell.frame)
      selectedView.backgroundColor = game.opponentPrimaryColor.withAlphaComponent(0.15)
      cell.selectedBackgroundView = selectedView
      
      cell.scoreLabel.textColor = ThemeManager.tableViewCellDetailLabelColor
      if !ThemeManager.overallDark { cell.scoreLabel.attributedText = game.score }
      cell.sideLabel.textColor = ThemeManager.tableViewCellMinorLabelColor
      cell.backgroundColor = ThemeManager.tableViewCellBackgroundColor
      
      return cell
    }
  }
  
  override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
    if indexPath.section >= (self.selectedSportHasTypes() ? 1 : 0) {
      let cell = tableView.cellForRow(at: indexPath) as! AthleticsTableViewCell
      
      let game = self.getSelectedAthleticGames()![indexPath.section - (self.selectedSportHasTypes() ? 1 : 0)]
      cell.opponentBackground.backgroundColor = game.opponentPrimaryColor
      cell.opponentLabel.textColor = game.opponentSecondaryColor
      
      if #available(iOS 11.0, *) {
        cell.opponentBackground.accessibilityIgnoresInvertColors = true
        cell.opponentLabel.accessibilityIgnoresInvertColors = true
        cell.outcomeLabel.accessibilityIgnoresInvertColors = true
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.tableView(tableView, didHighlightRowAt: indexPath)
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return indexPath.section == 0 ? 44.0 : 50.0
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    if (segue.destination is AthleticGameViewController) {
      let viewController = segue.destination as! AthleticGameViewController
      viewController.game = self.getSelectedAthleticGames()![(self.tableView.indexPathForSelectedRow ?? self.tableView.indexPath(for: sender as! UITableViewCell)!).section - (self.selectedSportHasTypes() ? 1 : 0)]
    }
  }
  
  override func updateTheme() {
    super.updateTheme()
    
    self.tableView.backgroundColor = ThemeManager.viewControllerBackgroundColor
    
    self.tableView.reloadData()
  }
}
