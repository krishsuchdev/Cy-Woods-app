//
//  AdminLoginViewController.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 11/5/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit
import Firebase

class AdminLoginViewController: UIViewController {
  
  static var allowLogin = true
  
  @IBAction func adminLogIn(_ sender: Any) {
    let adminLoginAlert = UIAlertController(title: "Admin Login", message: "Enter Email and Password:", preferredStyle: UIAlertControllerStyle.alert)
    adminLoginAlert.addTextField(configurationHandler: {(textField: UITextField!) in
      textField.placeholder = "Email"
    })
    adminLoginAlert.addTextField(configurationHandler: {(textField: UITextField!) in
      textField.placeholder = "Password"
      textField.isSecureTextEntry = true
    })
    adminLoginAlert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (_) -> Void in
    }))
    adminLoginAlert.addAction(UIAlertAction(title: "Log In", style: UIAlertActionStyle.default, handler: { (_) -> Void in
      Auth.auth().signIn(withEmail: adminLoginAlert.textFields![0].text!, password: AdminLoginViewController.allowLogin ? adminLoginAlert.textFields![1].text! : "", completion: { (user, error) in
        if error == nil {
          let successAdminLoginAlert = UIAlertController(title: "Admin Login Success!", message: "You now have a new option in the more tab.", preferredStyle: UIAlertControllerStyle.alert)
          successAdminLoginAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.navigationController!.popToViewController(self.navigationController!.viewControllers[0], animated: true)
          }))
          self.present(successAdminLoginAlert, animated: true, completion: nil)
        } else {
          AdminLoginViewController.allowLogin = false
          self.navigationController!.popToViewController(self.navigationController!.viewControllers[0], animated: true)
          self.showSimpleAlertController(title: "Login Reported", message: "")
        }
      })
    }))
    self.present(adminLoginAlert, animated: true, completion: nil)
  }
  
  static func isLoggedIn() -> Bool {
    return Auth.auth().currentUser != nil
  }
  
}
