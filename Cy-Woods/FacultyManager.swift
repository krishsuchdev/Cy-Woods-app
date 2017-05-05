//
//  FacultyManager.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 6/14/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit
import CoreData
import Firebase

class FacultyManager: NSObject {
  
  static var firebaseReference = Database.database().reference()
  
  static var departments = [Department]()
  static var faculty = [Faculty]()
  
  static func fetchTeachers(completionHandler: @escaping () -> Void) {
    var departments = [Department]()
    var faculty = [Faculty]()
    
    self.firebaseReference.child("Faculty Tab").observeSingleEvent(of: .value, with: { (snapshot) in
      let facultyDictionary = (snapshot.value! as! NSDictionary)["Faculty"] as! NSDictionary
      let subjectsDictionary = (snapshot.value! as! NSDictionary)["Subjects"] as! NSDictionary
      
      for (facultyID, facultyInfo) in facultyDictionary {
        let facultyName = ((facultyInfo as! NSDictionary)["Name"] as! String).replacingOccurrences(of: "_", with: " ").capitalizingFirstLetter()
        let facultyEmail = (facultyInfo as! NSDictionary)["Email"] as! String
        let facultyWebsite = (facultyInfo as! NSDictionary)["Website"] as! String
        let facultyMember = Faculty(id: facultyID as! String, name: facultyName, email: facultyEmail, website: facultyWebsite)
        faculty.append(facultyMember)
      }
      
      for (departmentName, subjectInfo) in subjectsDictionary {
        var department = Department(name: departmentName as! String)
        if department.name == "Unknown" { continue }
        if departments.contains(department) {
          department = departments[departments.index(of: department)!]
        } else {
          departments.append(department)
        }
        for (subjectName, facultyDictionary) in subjectInfo as! NSDictionary {
          var subject = Subject(name: subjectName as! String, department: department)
          if department.subjects.contains(subject) {
            subject = department.subjects[department.subjects.index(of: subject)!]
          } else {
            department.subjects.append(subject)
          }
          for (facultyID, _) in facultyDictionary as! NSDictionary {
            let facultyMember = faculty[faculty.index(of: Faculty(id: facultyID as! String))!]
            subject.faculty.append(facultyMember)
          }
        }
      }
      faculty.sort(by: { (one, two) -> Bool in
        return one.name.compare(two.name) == .orderedAscending
      })
      
      FacultyManager.departments = departments.sorted(by: { (one, two) -> Bool in
        return one.name.compare(two.name) == .orderedAscending
      })
      FacultyManager.faculty = faculty
      completionHandler()
    })
  }
  
  static func getTeachersAlphabetically() -> [String : [Faculty]] {
    var dictionary = [String : [Faculty]]()
    for teacher in FacultyManager.faculty {
      let firstLetter = "\(teacher.name.characters.first!)"
      if var teachers = dictionary[firstLetter] {
        teachers.append(teacher)
        dictionary[firstLetter] = teachers
      } else {
        dictionary[firstLetter] = [teacher]
      }
    }
    return dictionary
  }
  
  static func getFacultyLetters() -> [String] {
    return Array(self.getTeachersAlphabetically().keys).sorted()
  }
  
  static func getFacultyForLetter(letter: String) -> [Faculty] {
    return self.getTeachersAlphabetically()[letter]!
  }
  
}

class Faculty: Equatable {
  var id: String
  
  var name: String
  var email: String?
  var website: String?
  var departments: [Department]
  var subjects: [Subject]
  
  init(id: String) {
    self.id = id
    self.name = id
    self.email = nil
    self.website = nil
    self.departments = [Department]()
    self.subjects = [Subject]()
  }
  
  init(id: String, name: String, email:String, website: String) {
    self.id = id
    self.name = name
    self.email = email
    self.website = website
    self.departments = [Department]()
    self.subjects = [Subject]()
  }
  
  static func == (one: Faculty, two: Faculty) -> Bool {
    return one.id == two.id
  }
}

class Department: Equatable {
  var name: String
  var subjects: [Subject]
  
  init(name: String) {
    self.name = name
    self.subjects = [Subject]()
  }
  
  func getSubjects() -> [Subject] {
    return subjects.sorted(by: { (one, two) -> Bool in
      return one.name.compare(two.name) == .orderedAscending
    })
  }
  
  static func == (one: Department, two: Department) -> Bool {
    return one.name == two.name
  }
}

class Subject: Equatable {
  var name: String
  var department: Department
  var faculty: [Faculty]
  
  init(name: String, department: Department) {
    self.name = name
    self.department = department
    self.faculty = [Faculty]()
  }
  
  func getFaculty() -> [Faculty] {
    return faculty.sorted(by: { (one, two) -> Bool in
      return one.name.compare(two.name) == .orderedAscending
    })
  }
  
  static func == (one: Subject, two: Subject) -> Bool {
    return one.name == two.name && one.department == two.department
  }
}
