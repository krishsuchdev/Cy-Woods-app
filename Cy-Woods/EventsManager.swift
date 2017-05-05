//
//  EventsManager.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 10/22/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit
import Firebase

class EventsManager: NSObject {
  
  static var firebaseReference = Database.database().reference()
  
  static var eventsItems = [EventsItem]()
  
  static func fetchEventItems(completionHandler: @escaping () -> Void) {
    firebaseReference.child("Home Tab").child("Events").observe(.value, with: { (snapshot) in
      var eventsItems = [EventsItem]()
      if let eventInfoDictionary = snapshot.value as? NSDictionary {
        for (_, eventInfo) in eventInfoDictionary {
          let title = (eventInfo as! NSDictionary)["Title"] as! String
          let date = (eventInfo as! NSDictionary)["Date"] as! String
          let color = (eventInfo as! NSDictionary)["Color"] as! String
          let priority = (eventInfo as! NSDictionary)["Priority"] as! Int
          eventsItems.append(EventsItem(title: title, date: date, color: color, priority: priority))
        }
      }
      eventsItems.sort()
      self.eventsItems = eventsItems
      completionHandler()
    })
  }
  
  static func getEventColor(from text: String) -> UIColor {
    switch text {
    case "Red":
      return UIColor(red: 0.5, green: 0.0, blue: 0.0, alpha: 1.0)
    case "Blue":
      return UIColor(red: 0.0, green: 0.0, blue: 0.5, alpha: 1.0)
    case "Green":
      return UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0)
    case "Yellow":
      return UIColor(red: 0.5, green: 0.5, blue: 0.0, alpha: 1.0)
    case "Orange":
      return UIColor(red: 0.5, green: 0.25, blue: 0.0, alpha: 1.0)
    case "Purple":
      return UIColor(red: 0.25, green: 0.0, blue: 0.5, alpha: 1.0)
    case "Cyan":
      return UIColor(red: 0.0, green: 0.5, blue: 0.5, alpha: 1.0)
    case "Gray":
      return UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
    default:
      return UIColor.black
    }
  }
  
}

struct EventsItem: Comparable {
  
  var title: String!
  var date: String
  var color: String
  var priority: Int!
  
  init(title: String, date: String, color: String, priority: Int) {
    self.title = title
    self.date = date
    self.color = color
    self.priority = priority
  }
  
  static func == (lhs: EventsItem, rhs: EventsItem) -> Bool {
    return lhs.priority == rhs.priority
  }
  
  static func < (lhs: EventsItem, rhs: EventsItem) -> Bool {
    return lhs.priority <= rhs.priority
  }
  
}
