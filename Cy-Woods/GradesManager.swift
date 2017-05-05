//
//  GradesManager.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 6/4/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit
import Alamofire

class GradesManager: NSObject {
  
  static var gradesViewController: GradesViewController!
  static var isFetching = false
  
  static var currentUser: [String : Any]? {
    get {
      return AppDelegate.loadData(with: "CyWoodsApp.Grades.CurrentUser") as? [String : Any]
    }
    set(newCurrentUser) {
      if newCurrentUser == nil {
        AppDelegate.removeData(key: "CyWoodsApp.Grades.CurrentUser")
      } else {
        AppDelegate.saveData(with: newCurrentUser, key: "CyWoodsApp.Grades.CurrentUser")
      }
    }
  }
  static var users: [[String : Any]] {
    get {
      return AppDelegate.loadData(with: "CyWoodsApp.Grades.Users") as! [[String : Any]]
    }
    set(newUsers) {
      AppDelegate.saveData(with: newUsers, key: "CyWoodsApp.Grades.Users")
    }
  }
  
  static func getClasses(for user: [String : Any]) -> [[String : Any]]? {
    return AppDelegate.loadData(with: "CyWoodsApp.Grades.\(user["username"] as! String).NineWeeksGrades") as? [[String : Any]]
  }
  
  static func getClass(for user: [String : Any], classIndex: Int) -> [String : Any]? {
    return GradesManager.getClasses(for: user)?[classIndex]
  }
  
  static func getCategories(for user: [String : Any], classIndex: Int) -> [[String : Any]]? {
    return GradesManager.getClass(for: user, classIndex: classIndex)?["categories"] as? [[String : Any]]
  }
  
  static func getCategory(for user: [String : Any], classIndex: Int, categoryIndex: Int) -> [String : Any]? {
    return GradesManager.getCategories(for: user, classIndex: classIndex)?[categoryIndex]
  }
  
  static func getAssignments(for user: [String : Any], classIndex: Int) -> [[String : Any]]? {
    return GradesManager.getClass(for: user, classIndex: classIndex)?["assignments"] as? [[String : Any]]
  }
  
  static func getAssignment(for user: [String : Any], classIndex: Int, assignmentIndex: Int) -> [String : Any]? {
    return GradesManager.getAssignments(for: user, classIndex: classIndex)?[assignmentIndex]
  }
  
  static func setNewForAssignmentsInClass(for user: [String : Any], classIndex: Int, new: Bool) {
    var classes = GradesManager.getClasses(for: user)!
    var assignments = classes[classIndex]["assignments"] as! [[String : Any]]
    for assignmentIndex in 0..<assignments.count {
      assignments[assignmentIndex].updateValue(new, forKey: "new")
    }
    classes[classIndex].updateValue(assignments, forKey: "assignments")
    classes[classIndex].updateValue(0, forKey: "new assignments count")
    AppDelegate.saveData(with: classes, key: "CyWoodsApp.Grades.\(user["username"] as! String).NineWeeksGrades")
  }
  
  static func getAbsences(for user: [String : Any]) -> [String : [String : Int]]? {
    return AppDelegate.loadData(with: "CyWoodsApp.Grades.\(user["username"] as! String).Absences") as? [String : [String : Int]]
  }
  
  static func getUnexcused(for user: [String : Any]) -> [String : Int]? {
    return GradesManager.getAbsences(for: user)!["unexcused"]
  }
  
  static func getUnexcused(for user: [String : Any], classPeriod: Int) -> Int? {
    return GradesManager.getUnexcused(for: user)?["\(classPeriod)"]
  }
  
  static func getTardies(for user: [String : Any]) -> [String : Int]? {
    return GradesManager.getAbsences(for: user)!["tardies"]
  }
  
  static func getTardies(for user: [String : Any], classPeriod: Int) -> Int? {
    return GradesManager.getTardies(for: user)?["\(classPeriod)"]
  }
  
  static func getSemesterClasses(for user: [String : Any]) -> [String : [String : Any]]? {
    return AppDelegate.loadData(with: "CyWoodsApp.Grades.\(user["username"] as! String).SemesterGrades") as? [String : [String : Any]]
  }
  
  static func getSemesterClass(for user: [String : Any], className: String) -> [String : Any]? {
    return GradesManager.getSemesterClasses(for: user)?[className]
  }
  
  static func addUser(username: String, password: String, successCompletionHandler: @escaping ([String : Any]) -> Void, failureCompletionHandler: @escaping (String) -> Void) {
    let encodedUsername = Utility.encode(username)!
    let encodedPassword = Utility.encode(password)!
    var newUser = ["username" : encodedUsername, "password" : encodedPassword] as [String : Any]
    
    if GradesManager.users.count == 5 {
      failureCompletionHandler("Only up to 5 users are supported at this time")
      return
    }
    for user in GradesManager.users {
      if Utility.decode(user["username"] as! String) == username {
        failureCompletionHandler("This user is already added")
        return
      }
    }
    
    self.fetchNineWeeksGrades(user: newUser, successCompletionHandler: { (userData) in
      self.fetchAbsences(user: newUser, successCompletionHandler: { (absenceData) in
        self.fetchSemesterGrades(user: newUser, successCompletionHandler: { (semesterData) in
          newUser.updateValue(userData["name"] as! String, forKey: "name")
          users.append(newUser)
          
          currentUser = newUser
          successCompletionHandler(newUser)
        }, failureCompletionHandler: { (error) in
          failureCompletionHandler(error)
        })
      }, failureCompletionHandler: { (error) in
        failureCompletionHandler(error)
      })
    }) { (error) in
      failureCompletionHandler(error)
    }
  }
  
  static func removeCurrentUser() {
    self.users.remove(at: self.users.index(where: { (user) -> Bool in
      return self.currentUser!["username"] as! String == user["username"] as! String
    })!)
    self.currentUser = self.users.isEmpty ? nil : self.users[0]
  }
  
  static func removeAllUsers() {
    while self.currentUser != nil {
      GradesManager.removeCurrentUser()
    }
  }
  
  static func fetchNineWeeksGrades(user: [String : Any], successCompletionHandler: @escaping ([String : Any]) -> Void, failureCompletionHandler: @escaping (String) -> Void) {
    GradesManager.isFetching = true
    if GradesManager.gradesViewController != nil && GradesManager.currentUser != nil {
      let indexPath = IndexPath(row: GradesManager.gradesViewController.tableView.numberOfRows(inSection: 0) - 1, section: 0)
      let doSelectAnimation = GradesManager.gradesViewController.tableView.indexPathForSelectedRow == indexPath
      GradesManager.gradesViewController.tableView.reloadRows(at: [indexPath], with: .none)
      if doSelectAnimation {
        GradesManager.gradesViewController.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        GradesManager.gradesViewController.tableView.deselectRow(at: indexPath, animated: true)
      }
    }
    var doRefresh: Bool!
    
    func refresh() {
      if !doRefresh {
        let classes = GradesManager.getClasses(for: user)!
        let name = user["name"] as! String
        GradesManager.isFetching = false
        successCompletionHandler(["new assignments" : [[String : Any]](), "nine weeks grades" : classes, "name" : name])
      } else {
        var name = ""
        if let userName = user["name"] as? String { name = userName }
        Alamofire.request("https://2-dot-cy-woods-app.appspot.com", method: .get, parameters: ["Action" : "GGP", "Init" : name, "Key" : Utility.getAuthKey(), "Username" : user["username"] as! String, "Password" : user["password"] as! String])
          .responseString { response in
            if let dictionary = response.result.value?.toDictionary() {
              let name = dictionary["name"] as! String
              
              let lastUpdated = dictionary["last updated"] as! String
              AppDelegate.saveData(with: lastUpdated, key: "CyWoodsApp.Grades.\(user["username"] as! String).NineWeeksGrades.LastUpdated")
              
              var classes = dictionary["nine weeks grades"] as! [[String : Any]]
              if classes.count == 0 {
                GradesManager.isFetching = false
                failureCompletionHandler("Could not find any grades. If the password is outdated, log out of this user then log back in with the correct password.")
              } else {
                var newUser: Bool
                var newAssignments = [[String : Any]]()
                let oldClasses: [[String : Any]]
                if AppDelegate.hasData(with: "CyWoodsApp.Grades.\(user["username"] as! String).NineWeeksGrades") {
                  newUser = false
                  oldClasses = AppDelegate.loadData(with: "CyWoodsApp.Grades.\(user["username"] as! String).NineWeeksGrades") as! [[String : Any]]
                } else {
                  newUser = true
                  oldClasses = [[String : Any]]()
                }
                var replaceClasses = [[String : Any]]()
                for classIndex in 0..<classes.count {
                  var currentClass = classes[classIndex]
                  var replaceAssignments = [[String : Any]]()
                  var newAssignmentsCountForClass = 0
                  for assignmentIndex in 0..<(currentClass["assignments"] as! [[String : Any]]).count {
                    var currentAssignment = (currentClass["assignments"] as! [[String : Any]])[assignmentIndex]
                    currentAssignment.updateValue(false, forKey: "new")
                    if !newUser && Double(currentAssignment["grade"] as! String) != nil && !oldClasses.contains(where: { (_) -> Bool in
                      for oldClass in oldClasses {
                        if oldClass["name"] as! String == currentClass["name"] as! String {
                          for oldAssignment in oldClass["assignments"] as! [[String : Any]] {
                            if oldAssignment["name"] as! String == currentAssignment["name"] as! String {
                              return oldAssignment["grade"] as! String == currentAssignment["grade"] as! String
                            }
                          }
                        }
                      }
                      return false
                    }) {
                      currentAssignment.updateValue(true, forKey: "new")
                      var newAssignment = currentAssignment
                      newAssignment.updateValue(currentClass["name"] as! String, forKey: "class name")
                      newAssignments.append(newAssignment)
                      newAssignmentsCountForClass += 1
                    }
                    replaceAssignments.append(currentAssignment)
                  }
                  currentClass.updateValue(replaceAssignments, forKey: "assignments")
                  currentClass.updateValue(newAssignmentsCountForClass, forKey: "new assignments count")
                  replaceClasses.append(currentClass)
                }
                classes = replaceClasses
                
                AppDelegate.saveData(with: classes, key: "CyWoodsApp.Grades.\(user["username"] as! String).NineWeeksGrades")
                
                GradesManager.isFetching = false
                
                if dictionary["alert"] != nil && GradesManager.gradesViewController != nil {
                  GradesManager.gradesViewController.showSimpleAlertController(title: "Alert", message: dictionary["alert"] as! String)
                }
                successCompletionHandler(["new assignments" : newAssignments, "nine weeks grades" : classes, "name" : name])
              }
            } else {
              GradesManager.isFetching = false
              failureCompletionHandler("Internal error")
            }
        }
      }
    }
    
    doRefresh = !AppDelegate.hasData(with: "CyWoodsApp.Grades.\(user["username"] as! String).NineWeeksGrades.LastUpdated")
    if !doRefresh {
      let readTimeFormatter = DateFormatter()
      readTimeFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss z"
      let refreshDate = readTimeFormatter.date(from: AppDelegate.loadData(with: "CyWoodsApp.Grades.\(user["username"] as! String).NineWeeksGrades.LastUpdated") as! String)!
      doRefresh = refreshDate.numberOfMinutes(until: Date()) >= 10
      Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (timer) in
        refresh()
      })
    } else {
      refresh()
    }
  }
  
  static func fetchAbsences(user: [String : Any], successCompletionHandler: @escaping ([String : Any]) -> Void, failureCompletionHandler: @escaping (String) -> Void) {
    GradesManager.isFetching = true
    var doRefresh: Bool!
    
    func refresh() {
      if !doRefresh {
        let absences = GradesManager.getAbsences(for: user)!
        GradesManager.isFetching = false
        successCompletionHandler(["absences" : absences])
      } else {
        var name = ""
        if let userName = user["name"] as? String { name = userName }
        Alamofire.request("https://cy-woods-app.appspot.com", method: .get, parameters: ["Action" : "GAT", "Init" : name, "Key" : Utility.getAuthKey(), "Username" : user["username"] as! String, "Password" : user["password"] as! String])
          .responseString { response in
            if let dictionary = response.result.value?.toDictionary() {
              let absences = dictionary["absences"] as! [String : [String : Int]]
              
              let lastUpdated = dictionary["last updated"] as! String
              AppDelegate.saveData(with: lastUpdated, key: "CyWoodsApp.Grades.\(user["username"] as! String).Absences.LastUpdated")
              
              AppDelegate.saveData(with: absences, key: "CyWoodsApp.Grades.\(user["username"] as! String).Absences")
              
              GradesManager.isFetching = false
              successCompletionHandler(["absences" : absences])
            } else {
              GradesManager.isFetching = false
              failureCompletionHandler("Internal error")
            }
        }
      }
    }
    
    doRefresh = !AppDelegate.hasData(with: "CyWoodsApp.Grades.\(user["username"] as! String).Absences.LastUpdated")
    if !doRefresh {
      let readTimeFormatter = DateFormatter()
      readTimeFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss z"
      let refreshDate = readTimeFormatter.date(from: AppDelegate.loadData(with: "CyWoodsApp.Grades.\(user["username"] as! String).Absences.LastUpdated") as! String)!
      doRefresh = refreshDate.numberOfHours(until: Date()) >= 10
      Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { (timer) in
        refresh()
      })
    } else {
      refresh()
    }
  }
  
  static func fetchSemesterGrades(user: [String : Any], successCompletionHandler: @escaping ([String : Any]) -> Void, failureCompletionHandler: @escaping (String) -> Void) {
    GradesManager.isFetching = true
    var doRefresh: Bool!
    
    func refresh() {
      if !doRefresh {
        let absences = GradesManager.getSemesterClasses(for: user)!
        GradesManager.isFetching = false
        successCompletionHandler(["semester classes" : absences])
      } else {
        var name = ""
        if let userName = user["name"] as? String { name = userName }
        Alamofire.request("https://cy-woods-app.appspot.com", method: .get, parameters: ["Action" : "GSM", "Init" : name, "Key" : Utility.getAuthKey(), "Username" : user["username"] as! String, "Password" : user["password"] as! String])
          .responseString { response in
            if let dictionary = response.result.value?.toDictionary() {
              let semesterClasses = (dictionary["report card"] as! [String : Any])["classes"] as! [String : [String : Any]]
              
              let lastUpdated = dictionary["last updated"] as! String
              AppDelegate.saveData(with: lastUpdated, key: "CyWoodsApp.Grades.\(user["username"] as! String).SemesterGrades.LastUpdated")
              
              AppDelegate.saveData(with: semesterClasses, key: "CyWoodsApp.Grades.\(user["username"] as! String).SemesterGrades")
              
              GradesManager.isFetching = false
              successCompletionHandler(["semester classes" : semesterClasses])
            } else {
              GradesManager.isFetching = false
              failureCompletionHandler("Internal error")
            }
        }
      }
    }
    
    doRefresh = !AppDelegate.hasData(with: "CyWoodsApp.Grades.\(user["username"] as! String).SemesterGrades.LastUpdated")
    if !doRefresh {
      let readTimeFormatter = DateFormatter()
      readTimeFormatter.dateFormat = "yyyy.MM.dd HH:mm:ss z"
      let refreshDate = readTimeFormatter.date(from: AppDelegate.loadData(with: "CyWoodsApp.Grades.\(user["username"] as! String).SemesterGrades.LastUpdated") as! String)!
      doRefresh = refreshDate.numberOfHours(until: Date()) >= 10
      Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false, block: { (timer) in
        refresh()
      })
    } else {
      refresh()
    }
  }
  
}
