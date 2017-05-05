//
//  AthleticGameViewController.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 11/23/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit

class AthleticGameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  @IBOutlet weak var tableView: UITableView!
  
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var homeLabel: UILabel!
  @IBOutlet weak var homeBackground: UIView!
  @IBOutlet weak var awayBackground: UIView!
  @IBOutlet weak var awayLabel: UILabel!
  
  var game: AthleticGame!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.navigationItem.title = "Game \(self.game.gameNumber + 1)"
    
    self.scoreLabel.attributedText = self.game.score
    if self.game.home {
      self.homeLabel.text = self.game.opponent
      self.homeLabel.textColor = self.game.opponentSecondaryColor
      self.homeBackground.backgroundColor = self.game.opponentPrimaryColor
      self.awayLabel.text = "Cy-Woods"
      self.awayLabel.textColor = UIColor.yellow
      self.awayBackground.backgroundColor = UIColor.crimsonRed
    } else {
      self.homeLabel.text = "Cy-Woods"
      self.homeLabel.textColor = UIColor.yellow
      self.homeBackground.backgroundColor = UIColor.crimsonRed
      self.awayLabel.text = self.game.opponent
      self.awayLabel.textColor = self.game.opponentSecondaryColor
      self.awayBackground.backgroundColor = self.game.opponentPrimaryColor
    }
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 2
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return [3, 1][section]
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "GameDetailsCell")!
    
    if indexPath.section == 0 {
      cell.textLabel!.text = ["Location", "Date", "Time"][indexPath.row]
      cell.detailTextLabel!.text = [self.game.location, self.game.date, self.game.time][indexPath.row]
    } else if indexPath.section == 1 {
      cell.textLabel!.text = ["Result"][indexPath.row]
      cell.detailTextLabel!.text = [self.game.result][indexPath.row]
    }
    cell.textLabel!.text = "\(cell.textLabel!.text!):"
    
    cell.textLabel!.textColor = ThemeManager.tableViewCellTitleLabelColor
    cell.detailTextLabel!.textColor = ThemeManager.tableViewCellDetailLabelColor
    cell.backgroundColor = ThemeManager.tableViewCellBackgroundColor
    
    return cell
  }
  
  override func updateTheme() {
    super.updateTheme()
    
    self.tableView.backgroundColor = ThemeManager.viewControllerBackgroundColor
    
    self.tableView.reloadData()
  }
  
}
