//
//  AthleticsManager.swift
//  Cy-Woods
//
//  Created by Krish Suchdev on 11/12/17.
//  Copyright © 2017 Krish Suchdev. All rights reserved.
//

import UIKit
import Alamofire

class AthleticsManager: NSObject {
  
  static var athleticGames = [String : [AthleticGame]]()
  
  static var isFetching = false
  
  static func fetchAthleticGames( sport: String, type: Int?, completionHandler: @escaping () -> Void) {
    AthleticsManager.isFetching = true
    Alamofire.request("https://cy-woods-app.appspot.com", method: .get, parameters: ["Action" : "ASC", "Key" : Utility.getAuthKey(), "Sport" : sport])
      .responseString { response in
        if let dictionary = response.result.value?.toDictionary() {
          var athleticSportGames = [AthleticGame]()
          let games = dictionary["schedule"] as! [[String : Any]]
          for gameInfo in games {
            let gameNumber = gameInfo["gameNumber"] as! Int
            let date = gameInfo["date"] as! String
            let time = gameInfo["time"] as! String
            let opponent = gameInfo["opponent"] as! String
            let location = gameInfo["location"] as? String ?? ""
            let home = gameInfo["home"] as! Bool
            let score = gameInfo["score"] as! String
            let result = gameInfo["result"] as! String
            athleticSportGames.append(AthleticGame(sport: sport, gameNumber: gameNumber, date: date, time: time, location: location, home: home, opponent: opponent, score: score, result: result))
          }
          athleticSportGames.sort()
          athleticGames.updateValue(athleticSportGames, forKey: sport)
        }
        AthleticsManager.isFetching = false
        completionHandler()
    }
  }
  
  static func sportHasTypes(sport: String) -> Bool {
    return ["Basketball", "Soccer"].contains(sport)
  }
  
  static func getSportName(selectedSport: String, typeIndex: Int?) -> String {
    if AthleticsManager.sportHasTypes(sport: selectedSport) {
      return "\(typeIndex == nil || typeIndex == 0 ? "M" : "W")\(selectedSport)"
    } else {
      return selectedSport
    }
  }
  
}

struct AthleticGame: Comparable {
  var sport: String!
  
  var gameNumber: Int!
  var date: String!
  var time: String!
  var location: String!
  
  var home: Bool!
  var opponent: String!
  var opponentPrimaryColor: UIColor!
  var opponentSecondaryColor: UIColor!
  
  var score: NSAttributedString!
  var result: String!
  
  init(sport: String, gameNumber: Int, date: String, time: String, location: String, home: Bool, opponent: String, score: String, result: String) {
    self.sport = sport
    
    self.gameNumber = gameNumber
    self.date = date
    self.time = time
    self.location = location
    
    self.home = home
    self.opponent = opponent
    switch self.opponent {
    case "Cy-Woods":
      self.opponentPrimaryColor = UIColor.crimsonRed
      self.opponentSecondaryColor = UIColor.yellow
      break
    case "Cy-Fair":
      self.opponentPrimaryColor = UIColor.red.darker(amount: 0.25)
      self.opponentSecondaryColor = UIColor.white
      break
    case "Cy-Creek":
      self.opponentPrimaryColor = UIColor.blue
      self.opponentSecondaryColor = UIColor.white
      break
    case "Cy-Falls":
      self.opponentPrimaryColor = UIColor.green.darker(amount: 0.25)
      self.opponentSecondaryColor = UIColor.yellow
      break
    case "Cy-Lakes":
      self.opponentPrimaryColor = UIColor.red
      self.opponentSecondaryColor = UIColor.white
      break
    case "Cy-Ranch":
      self.opponentPrimaryColor = UIColor.blue.darker(amount: 0.25)
      self.opponentSecondaryColor = UIColor.yellow
      break
    case "Cy-Ridge":
      self.opponentPrimaryColor = UIColor.blue.darker(amount: 0.25)
      self.opponentSecondaryColor = UIColor.green
      break
    case "Cy-Springs":
      self.opponentPrimaryColor = UIColor.blue.darker(amount: 0.25)
      self.opponentSecondaryColor = UIColor.white
      break
    case "Jersey Village":
      self.opponentPrimaryColor = UIColor.purple
      self.opponentSecondaryColor = UIColor.yellow
      break
    case "Langham Creek":
      self.opponentPrimaryColor = UIColor.red.darker(amount: 0.25)
      self.opponentSecondaryColor = UIColor.black
      break
    default:
      self.opponentPrimaryColor = UIColor(white: 0.2, alpha: 1.0)
      self.opponentSecondaryColor = UIColor.white
      break
    }
    self.opponentPrimaryColor = self.opponentPrimaryColor.withAlphaComponent(0.9)
    
    let attributedScore = NSMutableAttributedString(string: score)
    let loseColor = UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0)
    var loseGrayedOutRange = NSRange(location: 0, length: (score as NSString).length)
    let scoreSeperatorIndex = (score as NSString).range(of: "-").location
    if self.home == (result == "Win") {
      loseGrayedOutRange = NSRange(location: 0, length: scoreSeperatorIndex + 1)
    } else if !["Tie", "Not Started"].contains(result) {
      loseGrayedOutRange = NSRange(location: scoreSeperatorIndex, length: (score as NSString).length - scoreSeperatorIndex)
    }
    attributedScore.addAttribute(NSAttributedStringKey.foregroundColor, value: loseColor, range: loseGrayedOutRange)
    self.score = attributedScore
    self.result = result
  }
  
  static func == (lhs: AthleticGame, rhs: AthleticGame) -> Bool {
    return lhs.sport == rhs.sport && lhs.gameNumber == rhs.gameNumber && lhs.opponent == rhs.opponent
  }
  
  static func < (lhs: AthleticGame, rhs: AthleticGame) -> Bool {
    return lhs.gameNumber <= rhs.gameNumber
  }
  
}
