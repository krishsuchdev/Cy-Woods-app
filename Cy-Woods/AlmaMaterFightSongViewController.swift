//
//  AlmaMaterFightSongViewController.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 11/11/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit

class AlmaMaterFightSongViewController: UIViewController {
  
  @IBOutlet weak var segmentControl: UISegmentedControl!
  @IBOutlet weak var textView: UITextView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.segmentControlValueChanged(segmentControl)
  }
  
  @IBAction func segmentControlValueChanged(_ sender: Any) {
    if segmentControl.selectedSegmentIndex == 0 {
      self.textView.font = UIFont.italicSystemFont(ofSize: 17.0)
      self.textView.text = "To Cypress Woods we pledge our hearts and minds \n Within her walls vast knowledge we will find \n Along with friends and pride for all to see \n That Wildcats forever we will be \n \n We wear the crimson and we wear the gold \n Our future lives beginning to unfold \n Fond memories to hold within our hearts \n Of Cypress Woods we'll always be a part"
    } else {
      self.textView.font = UIFont.italicSystemFont(ofSize: 18.0)
      self.textView.text = "Wildcats Wildcats \n We're coming out tonight \n Showing them all \n Our Might \n So get on the field \n We're not gonna yield \n C-Dub HS Yell \n Fight Fight Fight \n If you're wanting more, \n We'll bring up the score \n Wildcats will do it right \n No doubt about it \n We're gonna shout it \n Wildcats will win tonight, \n Power of the red and gold \n Wildcats, Wildcats \n Chew'Em, Eat'Em \n Stomp'Em, Beat'Em \n Go Cats, Go!"
    }
    
    self.textView.textColor = ThemeManager.tableViewCellDetailLabelColor
  }
  
  override func updateTheme() {
    super.updateTheme()
    
    self.view.backgroundColor = ThemeManager.viewControllerBackgroundColor
  }
  
}
