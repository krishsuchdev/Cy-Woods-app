//
//  AthleticsTableViewCell.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 11/12/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit

class AthleticsTableViewCell: UITableViewCell {
  
  @IBOutlet weak var sideLabel: UILabel!
  @IBOutlet weak var opponentBackground: UIView!
  @IBOutlet weak var opponentLabel: UILabel!
  @IBOutlet weak var scoreLabel: UILabel!
  @IBOutlet weak var outcomeLabel: UILabel!
  
  var athleticsViewController: AthleticsViewController!
  @IBOutlet weak var typeSegmentControl: UISegmentedControl!
  
  @IBOutlet weak var refreshControl: UIActivityIndicatorView!
  
  @IBAction func typeSegmentChanged(_ sender: Any) {
    athleticsViewController.typeSegmentIndex = typeSegmentControl.selectedSegmentIndex
    athleticsViewController.tableView.reloadData()
    athleticsViewController.reloadAthleticGames()
  }
  
}
