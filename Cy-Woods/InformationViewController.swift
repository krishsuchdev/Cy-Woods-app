//
//  InformationViewController.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 11/11/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit
import SafariServices

class InformationViewController: UIViewController {
  
  @IBOutlet weak var adminTapView: UIView!
  
  @IBOutlet weak var schoolTitle: UILabel!
  @IBOutlet weak var addressButton: UIButton!
  @IBOutlet weak var phoneButton: UIButton!
  @IBOutlet weak var websiteButton: UIButton!
  @IBOutlet weak var calendarButton: UIButton!
  @IBOutlet weak var songButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.schoolTitle.textColor = ThemeManager.primaryColor
    let buttons: [UIButton] = [self.addressButton, self.phoneButton, self.websiteButton, self.calendarButton, self.songButton]
    for button in buttons {
      if button.backgroundColor == UIColor.white {
        button.layer.borderWidth = 2.5 + (button == self.websiteButton ? 0.5 : 0.0)
        button.layer.borderColor = ThemeManager.primaryColor.cgColor
        button.setTitleColor(ThemeManager.primaryColor, for: .normal)
      } else {
        button.setTitleColor(ThemeManager.tableViewCellDetailLabelColor, for: .normal)
      }
    }
  }
  
  @IBAction func addressButtonTapped(_ sender: Any) {
    let openAlert = UIAlertController(title: "Open in Maps", message: "Allow application to open address in Maps?", preferredStyle: .alert)
    openAlert.addAction(UIAlertAction(title: "Allow", style: .default, handler: { (action) in
      UIApplication.shared.open(URL(string: "http://maps.apple.com/?q=Cypress+Woods+High+School")!, options: [String : Any](), completionHandler: nil)
    }))
    openAlert.addAction(UIAlertAction(title: "Don\'t Allow", style: .default, handler: { (action) in
    }))
    self.present(openAlert, animated: true, completion: nil)
  }
  
  @IBAction func phoneButtonTapped(_ sender: Any) {
    UIApplication.shared.open(URL(string: "tel:12812131800")!, options: [String : Any](), completionHandler: nil)
  }
  
  @IBAction func websiteButtonTapped(_ sender: Any) {
    let safariWebView = SFSafariViewController(url: URL(string: "http://cywoods.cfisd.net/en/")!)
    safariWebView.preferredBarTintColor = ThemeManager.viewControllerNavigationBarColor
    safariWebView.preferredControlTintColor = ThemeManager.viewControllerNavigationBarButtonColor
    self.present(safariWebView, animated: true, completion: nil)
  }
  
  @IBAction func calendarButtonTapped(_ sender: Any) {
    let safariWebView = SFSafariViewController(url: URL(string: "https://www.cfisd.net/download_file/19721/")!)
    safariWebView.preferredBarTintColor = ThemeManager.viewControllerNavigationBarColor
    safariWebView.preferredControlTintColor = ThemeManager.viewControllerNavigationBarButtonColor
    self.present(safariWebView, animated: true, completion: nil)
  }
  
  override func updateTheme() {
    super.updateTheme()
    
    self.view.backgroundColor = ThemeManager.viewControllerBackgroundColor
    self.adminTapView.backgroundColor = ThemeManager.viewControllerBackgroundColor
    
    self.websiteButton.backgroundColor = ThemeManager.tableViewCellBackgroundColor
    self.calendarButton.backgroundColor = ThemeManager.tableViewCellBackgroundColor
    self.songButton.backgroundColor = ThemeManager.tableViewCellBackgroundColor
  }
  
}
