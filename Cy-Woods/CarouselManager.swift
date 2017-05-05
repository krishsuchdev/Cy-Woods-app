//
//  CarouselManager.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 5/6/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit
import Firebase

class CarouselManager: NSObject {
  
  static var firebaseReference = Database.database().reference()
  static var firebaseStorage = Storage.storage().reference(forURL: "gs://cy-woods-app.appspot.com/")
  
  static var slideItems = [CarouselSlideItem]()
  
  static func fetchSlideItems(completionHandler: @escaping () -> Void) {
    var slideItems = [CarouselSlideItem]()
    firebaseReference.child("Home Tab").child("Slides").observe(.value, with: { (snapshot) in
      for (_, slideInfo) in snapshot.value! as! NSDictionary {
        let imageName = (slideInfo as! NSDictionary)["Image"] as! String
        let link = (slideInfo as! NSDictionary)["Link"] as? String
        let priority = (slideInfo as! NSDictionary)["Priority"] as! Int
        
        firebaseStorage.child("Slides/\(imageName)").getData(maxSize: 1000000, completion: { (data, error) in
          if error != nil {
            print(error!)
          } else {
            let slideItem = CarouselSlideItem(slideImage: UIImage(data: data!)!, link: link, priority: priority)
            slideItems.append(slideItem)
            
            if slideItems.count == (snapshot.value! as! NSDictionary).count {
              slideItems.sort()
              self.slideItems = slideItems
              completionHandler()
            }
          }
        })
      }
    })
  }
  
}

struct CarouselSlideItem: Comparable {
  
  var slideImage: UIImage!
  var link: String?
  var priority: Int!
  
  init(slideImage: UIImage, link: String?, priority: Int) {
    self.slideImage = slideImage
    self.link = link
    self.priority = priority
  }
  
  static func == (lhs: CarouselSlideItem, rhs: CarouselSlideItem) -> Bool {
    return lhs.priority == rhs.priority
  }
  
  static func < (lhs: CarouselSlideItem, rhs: CarouselSlideItem) -> Bool {
    return lhs.priority <= rhs.priority
  }
  
}
