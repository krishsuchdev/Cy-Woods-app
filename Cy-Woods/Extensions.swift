//
//  Extensions.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 6/9/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit
import SafariServices

extension String {
  func capitalizingFirstLetter() -> String {
    return "\(String(characters.prefix(1)).capitalized)\(String(characters.dropFirst()))"
  }
  
  func removeOccurances(of: String) -> String {
    return self.replacingOccurrences(of: of, with: "")
  }
  
  func toDictionary() -> [String : Any]? {
    if let data = self.data(using: .utf8) {
      do {
        return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
      } catch {
        print(error.localizedDescription)
      }
    }
    return nil
  }
}

extension Date {
  func numberOfSeconds(until time: Date) -> Int {
    return Calendar.current.dateComponents([.second], from: self, to: time).second ?? 0
  }
  func numberOfMinutes(until time: Date) -> Int {
    return Calendar.current.dateComponents([.minute], from: self, to: time).minute ?? 0
  }
  func numberOfHours(until time: Date) -> Int {
    return Calendar.current.dateComponents([.hour], from: self, to: time).hour ?? 0
  }
  func numberOfDays(until time: Date) -> Int {
    return Calendar.current.dateComponents([.day], from: self, to: time).day ?? 0
  }
}

extension NSSet {
  func toArray() -> [Any] {
    return Array(self)
  }
}

extension UIColor {
  static var crimsonRed: UIColor { return UIColor(red: 209.0/255.0, green: 0.0/255.0, blue: 2.0/255.0, alpha: 1.0) }
  static var gold: UIColor { return UIColor(red: 200.0/255.0, green: 174.0/255.0, blue: 63.0/255.0, alpha: 1.0) }
  
  static var blueGray: UIColor { return UIColor(red: 235.0/255.0, green: 235.0/255.0, blue: 241.0/255.0, alpha: 1.0) }
  
  func lighter(amount: CGFloat) -> UIColor {
    return self.hueColorWithBrightnessAmount(amount: 1 + amount)
  }
  
  func darker(amount: CGFloat) -> UIColor {
    return self.hueColorWithBrightnessAmount(amount: 1 - amount)
  }
  
  private func hueColorWithBrightnessAmount(amount: CGFloat) -> UIColor {
    var hue: CGFloat = 0.0,  saturation: CGFloat = 0.0, brightness: CGFloat = 0.0, alpha: CGFloat = 0.0
    
    if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
      return UIColor(hue: hue, saturation: saturation, brightness: brightness * amount, alpha: alpha )
    } else {
      return self
    }
  }
}

extension UIView {
  func applyGradient(horizontal: Bool, colors: [UIColor], locations: [Double]) -> Void {
    let gradient = CAGradientLayer()
    gradient.frame = self.bounds
    gradient.colors = colors.map { $0.cgColor }
    gradient.locations = locations as [NSNumber]
    if horizontal {
      gradient.startPoint = CGPoint(x: 0.0, y: 0.5);
      gradient.endPoint = CGPoint(x: 1.0, y: 0.5);
    }
    self.layer.insertSublayer(gradient, at: 0)
  }
}

extension UIViewController {
  
  @objc func newViewWillAppear(_ animated: Bool) {
    self.newViewWillAppear(animated)
    
    self.updateTheme()
  }
  
  static func swizzleViewWillAppear() {
    if self != UIViewController.self {
      return
    }
    let _: () = {
      let originalSelector = #selector(UIViewController.viewWillAppear(_:))
      let swizzledSelector = #selector(UIViewController.newViewWillAppear(_:))
      let originalMethod = class_getInstanceMethod(self, originalSelector)
      let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
      method_exchangeImplementations(originalMethod!, swizzledMethod!);
    }()
  }
  
  func setUpLargeTitleNavigationBar(enabled: Bool) {
    if #available(iOS 11.0, *), self.navigationController != nil {
      self.navigationController!.navigationBar.prefersLargeTitles = false
      self.navigationController!.navigationBar.prefersLargeTitles = enabled
    }
  }
  
  func showSimpleAlertController(title: String, message: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    self.present(alert, animated: true, completion: nil)
  }
  
  @objc func updateTheme() {
    self.navigationController?.navigationBar.barTintColor = ThemeManager.viewControllerNavigationBarColor
    self.navigationController?.navigationBar.tintColor = ThemeManager.viewControllerNavigationBarButtonColor
    
    for subview in self.navigationItem.titleView?.subviews ?? [UIView]() {
      subview.tintColor = ThemeManager.viewControllerNavigationBarItemColor
    }
    
    if self is UITableViewController && (!self.navigationItem.title!.contains("Admin") && !self.navigationItem.title!.contains("Control")) { self.view.backgroundColor = ThemeManager.viewControllerBackgroundColor }
  }
}
