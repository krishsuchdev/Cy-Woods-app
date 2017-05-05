//
//  MoreTableViewCell.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 11/18/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit

class MoreTableViewCell: UITableViewCell {
  
  @IBOutlet weak var label: UILabel!
  @IBOutlet weak var `switch`: UISwitch!
  
  var moreVC: MoreViewController!
  
  var key: String?
  
  @IBAction func switchValueChanged(_ sender: Any) {
    if let key = self.key {
      AppDelegate.saveData(with: self.switch.isOn, key: "CyWoodsApp.Settings.\(key)")
    } else if self.label.text == "Dark Theme" {
      self.moreVC.selectTheme(themeIndex: self.switch.isOn ? 2 : 0)
    }
  }
  
}
