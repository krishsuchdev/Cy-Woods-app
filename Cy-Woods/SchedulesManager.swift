//
//  SchedulesManager.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 10/21/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit
import Firebase

class SchedulesManager: NSObject {
  
  static var firebaseReference = Database.database().reference()
  
  static var bellSchedules = [String : BellScheduleSet]()
  
  static var todaysSchedule: String?
  
  static func fetchSchedules(completionHandler: @escaping () -> Void) {
    self.firebaseReference.child("Schedules Tab").child("Bell Schedules").observeSingleEvent(of: .value, with: { (snapshot) in
      SchedulesManager.fetchTodaysSchedule(completionHandler: { (schedule) in
        SchedulesManager.todaysSchedule = schedule
        
        for (scheduleName, scheduleData) in snapshot.value! as! NSDictionary {
          var bellScheduleSet = BellScheduleSet()
          
          for (variationName, variationInfo) in scheduleData as! NSDictionary  {
            var variationBellSchedule = BellSchedule()
            
            for (itemName, itemInfo) in variationInfo as! NSDictionary {
              variationBellSchedule.bellScheduleItems.append(BellScheduleItem(itemName: itemName as! String, className: nil, startTime: (itemInfo as! NSDictionary)["Start"] as! String, endTime: (itemInfo as! NSDictionary)["End"] as! String))
            }
            variationBellSchedule.bellScheduleItems = variationBellSchedule.bellScheduleItems.sorted()
            
            bellScheduleSet.bellScheduleVariations.updateValue(variationBellSchedule, forKey: variationName as! String)
          }
          
          SchedulesManager.bellSchedules.updateValue(bellScheduleSet, forKey: scheduleName as! String)
        }
        completionHandler()
      })
    })
  }
  
  static func fetchTodaysSchedule(completionHandler: @escaping (String) -> Void) {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM d"
    self.firebaseReference.child("Schedules Tab").child("Days").child("\(dateFormatter.string(from: Date()))").observe(.value, with: { (snapshot) in
      var schedule = "Regular Bell Schedule"
      if let scheduleName = snapshot.value as? String {
        schedule = scheduleName
      }
      completionHandler(schedule)
    })
  }
  
  static func getTodaysSchedule() -> BellScheduleSet? {
    return SchedulesManager.bellSchedules[SchedulesManager.todaysSchedule ?? ""]
  }
  
}

struct BellScheduleSet {
  var bellScheduleVariations = [String : BellSchedule]()
}

struct BellSchedule {
  var bellScheduleItems = [BellScheduleItem]()
}

struct BellScheduleItem: Comparable {
  
  var itemName: String! // Period 1, Period 2, etc.
  var className: String! // Obtained from Grades. Can be nil if not logged in.
  var startTime: Date!
  var endTime: Date!
  
  var readTimeFormatter: DateFormatter!
  
  init(itemName: String, className: String?, startTime: String, endTime: String) {
    self.itemName = itemName
    self.className = className
    
    self.readTimeFormatter = DateFormatter()
    self.readTimeFormatter.locale = Locale(identifier: "en_US_POSIX")
    self.readTimeFormatter.timeStyle = .short
    self.readTimeFormatter.dateStyle = .none
    
    self.startTime = self.readTimeFormatter.date(from: startTime)
    self.endTime = self.readTimeFormatter.date(from: endTime)
  }
  
  func getStartTime() -> String {
    return self.readTimeFormatter.string(from: self.startTime)
  }
  
  func getEndTime() -> String {
    return self.readTimeFormatter.string(from: self.endTime)
  }
  
  func getLength() -> Int {
    return self.startTime.numberOfMinutes(until: self.endTime)
  }
  
  func getCurrentTime() -> Date {
    let readTimeFormatter = DateFormatter()
    readTimeFormatter.locale = Locale(identifier: "en_US_POSIX")
    readTimeFormatter.timeStyle = .medium
    readTimeFormatter.dateStyle = .none
    
    let writeTimeFormatter = DateFormatter()
    writeTimeFormatter.locale = Locale(identifier: "en_US_POSIX")
    writeTimeFormatter.timeStyle = .medium
    writeTimeFormatter.dateStyle = .long
    
    let date = writeTimeFormatter.date(from: "January 1, 2000 at " + readTimeFormatter.string(from: Date()))!
    return date
  }
  
  func timeStringIsInRange(_ timeString: String) -> Bool {
    let time = self.readTimeFormatter.date(from: timeString)!
    return self.timeIsInRange(time)
  }
  
  func timeIsInRange(_ time: Date) -> Bool {
    return (time.compare(self.startTime) == .orderedSame || time.compare(self.startTime) == .orderedDescending) && time.compare(self.endTime) == .orderedAscending
  }
  
  func currentTimeIsInRange() -> Bool {
    return self.timeIsInRange(self.getCurrentTime())
  }
  
  static func == (lhs: BellScheduleItem, rhs: BellScheduleItem) -> Bool {
    return lhs.startTime == rhs.startTime
  }
  
  static func < (lhs: BellScheduleItem, rhs: BellScheduleItem) -> Bool {
    return lhs.startTime <= rhs.startTime
  }
  
}
