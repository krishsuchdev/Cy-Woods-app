//
//  NewsManager.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 5/5/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit
import Firebase

class NewsManager: NSObject {
  
  static var firebaseReference = Database.database().reference()
  
  static var news = [NewsItem]()
  
  static func fetchNews(completionHandler: @escaping () -> Void) {
    self.firebaseReference.child("Home Tab").child("News").observe(.value, with: { (snapshot) in
      news = [NewsItem]()
      if let dictionary = snapshot.value as? NSDictionary {
        for (_, newsInfo) in dictionary {
          let source = (newsInfo as! NSDictionary)["Source"] as! String
          let title = (newsInfo as! NSDictionary)["Title"] as! String
          let date = (newsInfo as! NSDictionary)["Date"] as! String
          let url = (newsInfo as! NSDictionary)["URL"] as? String
          let priority = (newsInfo as! NSDictionary)["Priority"] as! Int
          news.append(NewsItem(source: source, title: title, date: date, url: url, priority: priority))
        }
      } else {
        return
      }
      news.sort()
      completionHandler()
    })
  }
  
}

struct NewsItem: Comparable {
  var source: String!
  
  var title: String!
  var date: String!
  
  var url: String?
  
  var priority: Int!
  
  init(source: String, title: String, date: String, url: String?, priority: Int) {
    self.source = source
    self.title = title
    self.date = date
    self.url = url
    self.priority = priority
    
    let readFormatter = DateFormatter()
    readFormatter.dateFormat = "MMM d, yyyy"
    if let readDate = readFormatter.date(from: self.date) {
      let writeFormatter = DateFormatter()
      writeFormatter.dateFormat = "EEEE, MMMM d, yyyy"
      let writeDate = writeFormatter.string(from: readDate)
      if readDate.compare(Date()) == .orderedAscending {
        self.date = "\(writeDate) (\(readDate.numberOfDays(until: Date()))d ago)"
      } else {
        self.date = "\(writeDate) (in \(Date().numberOfDays(until: readDate))d)"
      }
    }
  }
  
  static func == (lhs: NewsItem, rhs: NewsItem) -> Bool {
    return lhs.priority == rhs.priority
  }
  
  static func < (lhs: NewsItem, rhs: NewsItem) -> Bool {
    return lhs.priority <= rhs.priority
  }
}
