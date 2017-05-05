//
//  GradesTableViewCell.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 6/3/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit

class GradesTableViewCell: UITableViewCell {

  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subTitleLabel: UILabel!
  @IBOutlet weak var gradeLabel: UILabel!
  @IBOutlet weak var descriptionLabel: UILabel!
  @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
  
  @IBOutlet weak var firstNineWeeksLabel: UILabel!
  @IBOutlet weak var firstNineWeeksDataLabel: UILabel!
  @IBOutlet weak var secondNineWeeksLabel: UILabel!
  @IBOutlet weak var secondNineWeeksDataLabel: UILabel!
  @IBOutlet weak var finalExamLabel: UILabel!
  @IBOutlet weak var finalExamDataLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  func letterGrade(grade: String) -> String {
    if let gradeDouble = Double(grade) {
      return gradeDouble >= 89.5 ? "A" : gradeDouble >= 79.5 ? "B" : gradeDouble >= 69.5 ? "C" : gradeDouble >= 64.5 ? "D" : "F"
    } else {
      return ""
    }
  }
  
  func colorLetter(letterGrade: String, alpha: Double) -> UIColor {
    return ["A" : UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0), "B" : UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 1.0), "C" : UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0), "D" : UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0), "F" : UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0), "" : UIColor.white][letterGrade]!.withAlphaComponent(CGFloat(alpha))
  }

}
