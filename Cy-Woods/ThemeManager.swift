//
//  ThemeManager.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 11/25/17.
//  Copyright © 2017 Nish Suchdev. All rights reserved.
//

import UIKit

class ThemeManager: NSObject {
  
  static var theme: Int!
  
  static var primaryColor: UIColor!
  static var secondaryColor: UIColor!
  static var overallDark: Bool!
  
  static var viewControllerNavigationBarColor: UIColor!
  static var viewControllerNavigationBarTitleColor: UIColor!
  static var viewControllerNavigationBarItemColor: UIColor!
  static var viewControllerNavigationBarButtonColor: UIColor!
  
  static var viewControllerTabBarColor: UIColor!
  static var viewControllerTabBarItemColor: UIColor!
  
  static var viewControllerBackgroundColor: UIColor!
  
  static var tableViewCellBackgroundColor: UIColor!
  static var tableViewCellTitleLabelColor: UIColor!
  static var tableViewCellDetailLabelColor: UIColor!
  static var tableViewCellMinorLabelColor: UIColor!
  static var tableViewCellImageBackgroundColor: UIColor!
  
  static func applyTheme(value: Int) {
    self.theme = value
    
    AppDelegate.saveData(with: self.theme, key: "CyWoodsApp.Theme")
    
    if value == 0 { // Light Theme #1 (Default)
      self.primaryColor = UIColor.crimsonRed
      self.secondaryColor = UIColor.gold
      self.overallDark = false
      
      self.viewControllerNavigationBarColor = UIColor.crimsonRed
      self.viewControllerNavigationBarTitleColor = UIColor.white
      self.viewControllerNavigationBarItemColor = UIColor.white
      self.viewControllerNavigationBarButtonColor = UIColor.yellow
      
      self.viewControllerTabBarColor = UIColor.white
      self.viewControllerTabBarItemColor = UIColor.crimsonRed
      
      self.viewControllerBackgroundColor = UIColor.blueGray
      
      self.tableViewCellBackgroundColor = UIColor.white
      self.tableViewCellTitleLabelColor = UIColor.black
      self.tableViewCellDetailLabelColor = UIColor.darkGray
      self.tableViewCellMinorLabelColor = UIColor.lightGray
      self.tableViewCellImageBackgroundColor = UIColor.blueGray
    } else if value == 1 { // Light Theme #2
      self.primaryColor = UIColor.crimsonRed
      self.secondaryColor = UIColor.gold
      self.overallDark = false
      
      self.viewControllerNavigationBarColor = UIColor.white
      self.viewControllerNavigationBarTitleColor = UIColor.black
      self.viewControllerNavigationBarItemColor = UIColor.crimsonRed
      self.viewControllerNavigationBarButtonColor = UIColor.crimsonRed
      
      self.viewControllerTabBarColor = UIColor.white
      self.viewControllerTabBarItemColor = UIColor.crimsonRed
      
      self.viewControllerBackgroundColor = UIColor.blueGray
      
      self.tableViewCellBackgroundColor = UIColor.white
      self.tableViewCellTitleLabelColor = UIColor.black
      self.tableViewCellDetailLabelColor = UIColor.darkGray
      self.tableViewCellMinorLabelColor = UIColor.lightGray
      self.tableViewCellImageBackgroundColor = UIColor.blueGray
    } else if value == 2 { // Dark Theme #1
      self.primaryColor = UIColor.crimsonRed
      self.secondaryColor = UIColor.gold
      self.overallDark = true
      
      self.viewControllerNavigationBarColor = UIColor.crimsonRed
      self.viewControllerNavigationBarTitleColor = UIColor.white
      self.viewControllerNavigationBarItemColor = UIColor.white
      self.viewControllerNavigationBarButtonColor = UIColor.yellow
      
      self.viewControllerTabBarColor = UIColor(red: 5.0/255.0, green: 5.0/255.0, blue: 5.0/255.0, alpha: 1.0)
      self.viewControllerTabBarItemColor = UIColor.crimsonRed
      
      self.viewControllerBackgroundColor = UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 22.0/255.0, alpha: 1.0)
      
      self.tableViewCellBackgroundColor = UIColor.black
      self.tableViewCellTitleLabelColor = UIColor.white
      self.tableViewCellDetailLabelColor = UIColor.lightGray
      self.tableViewCellMinorLabelColor = UIColor.darkGray
      self.tableViewCellImageBackgroundColor = UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 32.0/255.0, alpha: 1.0)
    } else if value == 3 { // Dark Theme #2
      self.primaryColor = UIColor.crimsonRed
      self.secondaryColor = UIColor.gold
      self.overallDark = true
      
      self.viewControllerNavigationBarColor = UIColor.black
      self.viewControllerNavigationBarTitleColor = UIColor.white
      self.viewControllerNavigationBarItemColor = UIColor.red
      self.viewControllerNavigationBarButtonColor = UIColor.yellow
      
      self.viewControllerTabBarColor = UIColor(red: 5.0/255.0, green: 5.0/255.0, blue: 5.0/255.0, alpha: 1.0)
      self.viewControllerTabBarItemColor = UIColor.crimsonRed
      
      self.viewControllerBackgroundColor = UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 22.0/255.0, alpha: 1.0)
      
      self.tableViewCellBackgroundColor = UIColor.black
      self.tableViewCellTitleLabelColor = UIColor.white
      self.tableViewCellDetailLabelColor = UIColor.lightGray
      self.tableViewCellMinorLabelColor = UIColor.darkGray
      self.tableViewCellImageBackgroundColor = UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 32.0/255.0, alpha: 1.0)
    } else if value == 4 { // Hypercolor Theme
      self.primaryColor = UIColor.crimsonRed
      self.secondaryColor = UIColor.yellow
      self.primaryColor = UIColor.crimsonRed
      self.overallDark = false
      
      self.viewControllerNavigationBarColor = UIColor.crimsonRed
      self.viewControllerNavigationBarTitleColor = UIColor.yellow
      self.viewControllerNavigationBarItemColor = UIColor.yellow
      self.viewControllerNavigationBarButtonColor = UIColor.yellow
      
      self.viewControllerTabBarColor = UIColor.white
      self.viewControllerTabBarItemColor = UIColor.crimsonRed
      
      self.viewControllerBackgroundColor = UIColor.blueGray
      
      self.tableViewCellBackgroundColor = UIColor.white
      self.tableViewCellTitleLabelColor = UIColor.crimsonRed
      self.tableViewCellDetailLabelColor = UIColor.gold
      self.tableViewCellMinorLabelColor = UIColor.gray
      self.tableViewCellImageBackgroundColor = UIColor.blueGray
    } else if value == 5 { // Terminal Theme
      self.primaryColor = UIColor.green
      self.secondaryColor = UIColor.green
      self.overallDark = true
      
      self.viewControllerNavigationBarColor = UIColor.black
      self.viewControllerNavigationBarTitleColor = UIColor.green
      self.viewControllerNavigationBarItemColor = UIColor.green
      self.viewControllerNavigationBarButtonColor = UIColor.green
      
      self.viewControllerTabBarColor = UIColor.black
      self.viewControllerTabBarItemColor = UIColor.green
      
      self.viewControllerBackgroundColor = UIColor.black
      
      self.tableViewCellBackgroundColor = UIColor.black
      self.tableViewCellTitleLabelColor = UIColor.green
      self.tableViewCellDetailLabelColor = UIColor.green
      self.tableViewCellMinorLabelColor = UIColor.green
      self.tableViewCellImageBackgroundColor = UIColor.black
    } else if value == 6 { // Gold Dark Theme
      self.primaryColor = UIColor.gold
      self.secondaryColor = UIColor.crimsonRed
      self.overallDark = true
      
      self.viewControllerNavigationBarColor = UIColor.gold
      self.viewControllerNavigationBarTitleColor = UIColor.black
      self.viewControllerNavigationBarItemColor = UIColor.black
      self.viewControllerNavigationBarButtonColor = UIColor.black
      
      self.viewControllerTabBarColor = UIColor(red: 5.0/255.0, green: 5.0/255.0, blue: 5.0/255.0, alpha: 1.0)
      self.viewControllerTabBarItemColor = UIColor.gold
      
      self.viewControllerBackgroundColor = UIColor(red: 20.0/255.0, green: 20.0/255.0, blue: 22.0/255.0, alpha: 1.0)
      
      self.tableViewCellBackgroundColor = UIColor.black
      self.tableViewCellTitleLabelColor = UIColor.white
      self.tableViewCellDetailLabelColor = UIColor.lightGray
      self.tableViewCellMinorLabelColor = UIColor.darkGray
      self.tableViewCellImageBackgroundColor = UIColor(red: 30.0/255.0, green: 30.0/255.0, blue: 32.0/255.0, alpha: 1.0)
    } else if value == 7 { // Bright Theme
      self.primaryColor = UIColor.blue
      self.secondaryColor = UIColor.red
      self.overallDark = false
      
      self.viewControllerNavigationBarColor = UIColor.blue
      self.viewControllerNavigationBarTitleColor = UIColor.red
      self.viewControllerNavigationBarItemColor = UIColor.red
      self.viewControllerNavigationBarButtonColor = UIColor.red
      
      self.viewControllerTabBarColor = UIColor.blue
      self.viewControllerTabBarItemColor = UIColor.red
      
      self.viewControllerBackgroundColor = UIColor.blue
      
      self.tableViewCellBackgroundColor = UIColor.red
      self.tableViewCellTitleLabelColor = UIColor.blue
      self.tableViewCellDetailLabelColor = UIColor.blue
      self.tableViewCellMinorLabelColor = UIColor.blue
      self.tableViewCellImageBackgroundColor = UIColor.red
    }
    
    UIApplication.shared.statusBarStyle = self.viewControllerNavigationBarColor == UIColor.white ? .default : .lightContent
    if #available(iOS 11.0, *) {
      UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor : ThemeManager.viewControllerNavigationBarTitleColor]
    }
    UINavigationBar.appearance().titleTextAttributes = [NSAttributedStringKey.foregroundColor : ThemeManager.viewControllerNavigationBarTitleColor]
  }
  
}
