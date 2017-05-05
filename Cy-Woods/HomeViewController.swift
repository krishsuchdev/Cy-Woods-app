//
//  HomeViewController.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 5/5/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit
import iCarousel
import SafariServices
import RAMAnimatedTabBarController

class HomeViewController: UITableViewController, iCarouselDataSource, UICollectionViewDelegate, UICollectionViewDataSource {
  
  var cellIDs: [[String]] = [["Carousel"], ["Events"], ["News"]]
  var cellHeights: [[CGFloat]] = [[-1.0], [70.0], [UITableViewAutomaticDimension]]
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.tabBarController?.tabBar.barTintColor = ThemeManager.viewControllerTabBarColor
    if let tabBar = self.tabBarController as? RAMAnimatedTabBarController {
      tabBar.changeSelectedColor(ThemeManager.viewControllerTabBarItemColor, iconSelectedColor: ThemeManager.viewControllerTabBarItemColor)
    }
    
    self.setUpLargeTitleNavigationBar(enabled: true)
    (self.tabBarController as! RAMAnimatedTabBarController).changeSelectedColor(UIColor.crimsonRed, iconSelectedColor: UIColor.crimsonRed)
    
    self.tableView.estimatedRowHeight = 74.0
    
    CarouselManager.fetchSlideItems {
      let indexPath = IndexPath(item: 0, section: 0)
      self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
      (self.tableView.cellForRow(at: indexPath) as! HomeTableViewCell).reloadCarousel()
    }
    EventsManager.fetchEventItems {
      let indexPath = IndexPath(item: 0, section: 1)
      self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
      (self.tableView.cellForRow(at: indexPath) as! HomeTableViewCell).newsCollectionView.reloadData()
    }
    NewsManager.fetchNews {
      self.tableView.reloadSections(IndexSet(integer: 2), with: .none)
    }
  }
  
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    self.tableView.reloadData()
  }
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return self.cellIDs.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if !self.cellIDs[section].isEmpty && self.cellIDs[section][0] == "News" {
      return NewsManager.news.count
    } else {
      return self.cellIDs[section].count
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    var cell: UITableViewCell!
    
    if self.cellIDs[indexPath.section].isEmpty || self.cellIDs[indexPath.section][0] != "News" {
      let cellID = self.cellIDs[indexPath.section][indexPath.row]
      let homeCell = tableView.dequeueReusableCell(withIdentifier: cellID) as! HomeTableViewCell
      
      if indexPath.section == 0 {
        homeCell.homeVC = self
      } else if indexPath.section == 1 {
        homeCell.newsCollectionView.backgroundColor = ThemeManager.tableViewCellBackgroundColor
        homeCell.newsCollectionView.reloadData()
      }
      
      cell = homeCell
    } else {
      let newsCell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as! HomeNewsTableViewCell
      
      newsCell.newsSource.text = "  \(NewsManager.news[indexPath.row].source!)  "
      switch NewsManager.news[indexPath.row].source {
      case "School News":
        newsCell.newsSource.backgroundColor = UIColor.crimsonRed
      case "Crimson Connection":
        newsCell.newsSource.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.0, alpha: 0.75)
      case "District News":
        newsCell.newsSource.backgroundColor = UIColor(red: 0.1, green: 0.4, blue: 0.8, alpha: 0.75)
      case "App News":
        newsCell.newsSource.backgroundColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
      default:
        newsCell.newsSource.backgroundColor = UIColor.darkGray.withAlphaComponent(0.6)
      }
      
      if let _ = NewsManager.news[indexPath.row].url {
        newsCell.accessoryType = .disclosureIndicator
        newsCell.selectionStyle = .blue
      } else {
        newsCell.accessoryType = .none
        newsCell.selectionStyle = .none
      }
      
      newsCell.newsTitle.text = NewsManager.news[indexPath.row].title
      newsCell.newsDate.text = NewsManager.news[indexPath.row].date
      
      newsCell.newsTitle.textColor = ThemeManager.tableViewCellDetailLabelColor
      newsCell.newsDate.textColor = ThemeManager.tableViewCellDetailLabelColor
      
      cell = newsCell
    }
    
    let selectedView = UIView(frame: cell.frame)
    selectedView.backgroundColor = UIColor.gray.withAlphaComponent(ThemeManager.overallDark ? 0.3 : 0.15)
    cell.selectedBackgroundView = selectedView
    
    cell.backgroundColor = ThemeManager.tableViewCellBackgroundColor
    
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
    if let newsCell = self.tableView.cellForRow(at: indexPath) as? HomeNewsTableViewCell {
      switch NewsManager.news[indexPath.row].source {
      case "School News":
        newsCell.newsSource.backgroundColor = UIColor.crimsonRed
      case "Crimson Connection":
        newsCell.newsSource.backgroundColor = UIColor(red: 0.7, green: 0.7, blue: 0.0, alpha: 0.75)
      case "District News":
        newsCell.newsSource.backgroundColor = UIColor(red: 0.1, green: 0.4, blue: 0.8, alpha: 0.75)
      case "App News":
        newsCell.newsSource.backgroundColor = UIColor(red: 0.0, green: 0.8, blue: 0.0, alpha: 1.0)
      default:
        newsCell.newsSource.backgroundColor = UIColor.darkGray.withAlphaComponent(0.6)
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if self.tableView.cellForRow(at: indexPath) as? HomeNewsTableViewCell != nil {
      self.tableView(tableView, didHighlightRowAt: indexPath)
      
      if let url = NewsManager.news[indexPath.row].url {
        let safariWebView = SFSafariViewController(url: URL(string: url)!, entersReaderIfAvailable: true)
        safariWebView.preferredBarTintColor = ThemeManager.viewControllerNavigationBarColor
        safariWebView.preferredControlTintColor = ThemeManager.viewControllerNavigationBarButtonColor
        self.present(safariWebView, animated: true, completion: nil)
      }
    }
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if !self.cellIDs[indexPath.section].isEmpty && self.cellIDs[indexPath.section][0] == "News" {
      return UITableViewAutomaticDimension
    } else if self.cellHeights[indexPath.section][indexPath.row] == -1.0 {
      return UIDevice.current.orientation.isLandscape ? 220.0 : CGFloat(Int(self.view.frame.size.width * 0.53125))
    } else {
      return self.cellHeights[indexPath.section][indexPath.row]
    }
  }

  func numberOfItems(in carousel: iCarousel) -> Int {
    return CarouselManager.slideItems.count
  }
  
  func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
    let imageView = UIImageView(image: CarouselManager.slideItems[index].slideImage)
    imageView.frame = carousel.frame
    imageView.contentMode = .scaleAspectFill
    
    return imageView
  }
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return EventsManager.eventsItems.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! EventsCollectionViewCell
    
    let event = EventsManager.eventsItems[indexPath.row]
    cell.title.text = event.title
    cell.subtitle.text = event.date
    cell.subtitle.textColor = EventsManager.getEventColor(from: event.color)
    
    cell.title.textColor = ThemeManager.tableViewCellDetailLabelColor
    cell.itemBackground.backgroundColor = ThemeManager.tableViewCellImageBackgroundColor
    cell.backgroundColor = ThemeManager.tableViewCellBackgroundColor
    
    return cell
  }
  
  override func updateTheme() {
    super.updateTheme()
    
    self.tableView.backgroundColor = ThemeManager.viewControllerBackgroundColor
    
    self.tableView.reloadData()
  }

}
