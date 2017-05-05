//
//  AppDelegate.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 5/5/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData
import Firebase
import RAMAnimatedTabBarController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

  var window: UIWindow?
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    FirebaseApp.configure()
    
    if AppDelegate.loadData(with: "CyWoodsApp") == nil {
      AppDelegate.saveData(with: true, key: "CyWoodsApp")
      AppDelegate.saveData(with: 0, key: "CyWoodsApp.Theme")
      AppDelegate.saveData(with: true, key: "CyWoodsApp.Settings.EnableColorCodesInGrades")
      AppDelegate.saveData(with: false, key: "CyWoodsApp.Settings.ShowSecondsInSchedules")
      GradesManager.currentUser = nil
      GradesManager.users = [[String : Any]]()
      
      if Auth.auth().currentUser != nil {
        try! Auth.auth().signOut()
      }
    }
    
    UNUserNotificationCenter.current().delegate = self
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {(accepted, error) in
      print("Notification access \(accepted ? "Granted" : "Denied")")
    }
    UIApplication.shared.registerForRemoteNotifications()
    Messaging.messaging().delegate = self
    
    UIApplication.shared.applicationIconBadgeNumber = 0
    UIApplication.shared.setMinimumBackgroundFetchInterval(3600)
    
    ThemeManager.applyTheme(value: AppDelegate.loadData(with: "CyWoodsApp.Theme") as! Int)
    UIViewController.swizzleViewWillAppear()
    
    if let tabBarVC = self.window?.rootViewController as? RAMAnimatedTabBarController {
      (tabBarVC as UITabBarController).tabBar.barTintColor = ThemeManager.viewControllerTabBarColor
      tabBarVC.changeSelectedColor(ThemeManager.viewControllerTabBarItemColor, iconSelectedColor: ThemeManager.viewControllerTabBarItemColor)
    }
    
    // Data Fetches
    if GradesManager.currentUser != nil { GradesManager.fetchNineWeeksGrades(user: GradesManager.currentUser!, successCompletionHandler: { (classData) in }, failureCompletionHandler: { (error) in }) }
    SchedulesManager.fetchSchedules {}
    
    return true
  }
  
  func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
    let rootViewController = (self.window!.rootViewController as! UITabBarController)
    if String(describing: url).contains("://Home") { rootViewController.selectedIndex = 0 }
    else if String(describing: url).contains("://Grades") { rootViewController.selectedIndex = 1 }
    return true
  }
  
  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    Messaging.messaging().apnsToken = deviceToken
  }
  
  func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
    print("REMOTE MESSAGE")
    print(remoteMessage.appData)
  }

  func applicationWillResignActive(_ application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(_ application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(_ application: UIApplication) {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(_ application: UIApplication) {
    UIApplication.shared.applicationIconBadgeNumber = 0
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
  }
  
  static func saveData(with value: Any?, key: String) {
    let dictionary = UserDefaults.standard
    dictionary.set(value, forKey: key)
    dictionary.synchronize()
  }
  
  static func removeData(key: String) {
    let dictionary = UserDefaults.standard
    dictionary.removeObject(forKey: key)
    dictionary.synchronize()
  }
  
  static func hasData(with key: String) -> Bool {
    let dictionary = UserDefaults.standard
    return dictionary.object(forKey: key) != nil
  }
  
  static func loadData(with key: String) -> Any? {
    let dictionary = UserDefaults.standard
    return dictionary.object(forKey: key)
  }
  
  func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    if let currentUser = GradesManager.currentUser {
      GradesManager.fetchNineWeeksGrades(user: currentUser, successCompletionHandler: { (grades) in
        let newAssignments = grades["new assignments"] as! [[String : Any]]
        
        var newAssignmentClasses = [String]()
        for newAssignment in newAssignments {
          newAssignmentClasses.append(newAssignment["class name"] as! String)
        }
        if newAssignmentClasses.count == 0 {
          completionHandler(.noData)
        } else {
          var notificationBody = "New Grades in "
          newAssignmentClasses = Array(Set(newAssignmentClasses))
          for newAssignmentClassIndex in 0..<newAssignmentClasses.count {
            notificationBody += newAssignmentClasses[newAssignmentClassIndex]
            if newAssignmentClasses.count > 2 {
              notificationBody += ", "
            } else {
              notificationBody += " "
            }
            if newAssignmentClassIndex == newAssignmentClasses.count - 2 {
              notificationBody += "and "
            }
          }
          
          let content = UNMutableNotificationContent()
          content.title = "\(newAssignments.count) New Grades"
          content.body = notificationBody
          content.badge = newAssignments.count as NSNumber
          content.sound = UNNotificationSound.default()
          let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
          let request = UNNotificationRequest(identifier: "New Grades", content: content, trigger: trigger)
          
          UNUserNotificationCenter.current().getDeliveredNotifications(completionHandler: { (notifications) in
            for notification in notifications {
              if notification.request.identifier == "New Grades" && notification.request.content.title == content.title {
                completionHandler(.noData)
                return
              }
            }
            UNUserNotificationCenter.current().add(request) { error in
              if error == nil {
                completionHandler(.newData)
              } else {
                completionHandler(.failed)
              }
            }
          })
        }
      }, failureCompletionHandler: { (error) in
        completionHandler(.failed)
      })
    }
  }

}

