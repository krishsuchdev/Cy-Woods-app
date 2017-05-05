//
//  GameViewController.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 11/29/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {
  
  @IBOutlet weak var progressView: UIProgressView!
  @IBOutlet weak var tapMeButton: UIButton!
  
  var tapped = 0
  var totalTime = 30
  var timeLeft = -1
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.updateScore()
    
    self.timeLeft = self.totalTime + 1
    self.updateProgressView()
    Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.updateProgressView), userInfo: nil, repeats: true)
  }
  
  @IBAction func moveButtonToRandomPlace(_ sender: Any) {
    let randomPosition = CGPoint(x: CGFloat(arc4random()).truncatingRemainder(dividingBy: self.view!.frame.height - self.tabBarController!.view.frame.height) + self.navigationController!.navigationBar.frame.size.height + 20.0, y: CGFloat(arc4random()).truncatingRemainder(dividingBy: self.view!.frame.width))
    self.tapMeButton.frame = CGRect(x: randomPosition.x, y: randomPosition.y, width: self.tapMeButton.frame.size.width, height: self.tapMeButton.frame.size.height)
    self.tapped += 1
    self.updateScore()
  }
  
  func updateScore() {
    self.navigationItem.title = "Score: \(self.tapped * 10)"
  }
  
  @objc func updateProgressView() {
    self.timeLeft -= 1
    self.progressView.progress = Float(self.timeLeft) / Float(self.totalTime)
    if self.timeLeft == 0 {
      self.navigationController!.popToRootViewController(animated: true)
      self.showSimpleAlertController(title: "Game Results", message: "Score: \(self.tapped * 10)")
    }
  }
  
  override func updateTheme() {
    super.updateTheme()
    
    self.view.backgroundColor = ThemeManager.tableViewCellBackgroundColor
    
    self.tapMeButton.backgroundColor = ThemeManager.secondaryColor
    self.progressView.progressTintColor = ThemeManager.primaryColor
  }
  
}
