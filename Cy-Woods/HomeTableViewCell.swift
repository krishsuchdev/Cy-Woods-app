//
//  HomeTableViewCell.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 5/5/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit
import iCarousel
import SafariServices

class HomeTableViewCell: UITableViewCell, iCarouselDelegate {

  @IBOutlet weak var homeTabCarousel: iCarousel!
  @IBOutlet weak var carouselPageControl: UIPageControl!
  
  @IBOutlet weak var newsCollectionView: UICollectionView!
  
  var homeVC: HomeViewController!
  
  var autoScrollTimer: Timer!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    if homeTabCarousel != nil {
      self.homeTabCarousel.type = .timeMachine
      self.homeTabCarousel.isPagingEnabled = true
      self.homeTabCarousel.bounces = true
      self.homeTabCarousel.ignorePerpendicularSwipes = true
      self.homeTabCarousel.perspective = 0.001
      
      self.autoScrollTimer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(self.carouselScrollToNextItem), userInfo: nil, repeats: true)
    }
  }
  
  func reloadCarousel() {
    self.carouselPageControl.numberOfPages = CarouselManager.slideItems.count
    self.homeTabCarousel.reloadData()
  }
  
  func carouselCurrentItemIndexDidChange(_ carousel: iCarousel) {
    self.carouselPageControl.currentPage = carousel.currentItemIndex
  }
  
  func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
    switch option {
    case .spacing:
      return 1.0
    default:
      return value
    }
  }
  
  @objc func carouselScrollToNextItem() {
    if self.homeTabCarousel.numberOfItems == 0 { return }
    self.homeTabCarousel.scrollToItem(at: (self.homeTabCarousel.currentItemIndex + 1) % self.homeTabCarousel.numberOfItems, duration: 0.5)
  }
  
  func carousel(_ carousel: iCarousel, didSelectItemAt index: Int) {
    if let url = CarouselManager.slideItems[index].link {
      let safariWebView = SFSafariViewController(url: URL(string: url)!, entersReaderIfAvailable: true)
      safariWebView.preferredBarTintColor = ThemeManager.viewControllerNavigationBarColor
      safariWebView.preferredControlTintColor = ThemeManager.viewControllerNavigationBarButtonColor
      self.homeVC.present(safariWebView, animated: true, completion: nil)
    }
  }

}
