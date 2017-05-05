//
//  AboutViewController.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 11/26/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit
import SafariServices
import Firebase

class AboutViewController: UIViewController {
  
  @IBOutlet weak var appLabel: UILabel!
  @IBOutlet weak var versionLabel: UILabel!
  @IBOutlet weak var privacyPolicyButton: UIButton!
  
  var longPressed = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.appLabel.text = "Cy-Woods App"
    self.versionLabel.text = "(v. \(Bundle.main.infoDictionary!["CFBundleShortVersionString"]!))"
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    self.longPressed = false
  }
  
  @IBAction func viewPrivacyPolicy(_ sender: Any) {
    Database.database().reference().child("About Tab").child("Privacy Policy URL").observeSingleEvent(of: .value, with: { (snapshot) in
      if let url = snapshot.value as? String {
        let safariWebView = SFSafariViewController(url: URL(string: url)!)
        safariWebView.preferredBarTintColor = ThemeManager.viewControllerNavigationBarColor
        safariWebView.preferredControlTintColor = ThemeManager.viewControllerNavigationBarButtonColor
        self.present(safariWebView, animated: true, completion: nil)
      }
    })
  }
  
  @IBAction func longPressToGame(_ sender: Any) {
    if !self.longPressed {
      self.longPressed = true
      self.performSegue(withIdentifier: "ToGame", sender: self)
    }
  }
  
  override func updateTheme() {
    super.updateTheme()
    
    self.view.backgroundColor = ThemeManager.viewControllerBackgroundColor
    
    self.appLabel.textColor = ThemeManager.primaryColor
    self.appLabel.backgroundColor = ThemeManager.tableViewCellBackgroundColor
    self.versionLabel.textColor = ThemeManager.tableViewCellDetailLabelColor
    self.versionLabel.backgroundColor = ThemeManager.tableViewCellBackgroundColor
    self.privacyPolicyButton.setTitleColor(ThemeManager.primaryColor, for: .normal)
  }
  
}
