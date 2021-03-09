//
//  BasicData.swift
//  DuelOfWords
//
//  Created by Romhanyi Jozsef on 2020. 05. 12..
//  Copyright © 2020. Romhanyi Jozsef. All rights reserved.
//

import Foundation
import RealmSwift
import GameKit

let languageIndex = ["en": 0, "de": 1, "hu": 2, "ru":3]

enum GCEnabledType: Int {
    case AskForGameCenter = 0, GameCenterEnabled, GameCenterSupressed
}

class MaxScoresProLanguageAndSizeAndDevice {
    var arr = Array(repeating: Array(repeating: 0, count: 6), count: 4)
    public func toString()->String {
        var strValue = ""
        for languageIndex in 0...3 {
            for sizeIndex in 0...5 {
                strValue += String(arr[languageIndex][sizeIndex]) + GV.innerSeparator
            }
            strValue.removeLast()
            strValue += GV.outerSeparator
        }
        strValue.removeLast()
        return strValue
    }
    public func addMaxScore(language: String, size: Int, maxValue: Int) {
        if let lIndex = languageIndex[language] {
            arr[lIndex][size - 5] = maxValue
        }
    }
    public func getValue (language: String, size: Int, type: String)->Int {
        var returnValue = 0
        if let lIndex = languageIndex[language] {
            returnValue = arr[lIndex][size - 5]
        }
        return returnValue
    }
    init(initValue: String) {
        arr = Array(repeating: Array(repeating: 0, count: 6), count: 4)
        let languages = initValue.components(separatedBy: GV.outerSeparator)
        for (languageIndex, language) in languages.enumerated() {
            let sizes = language.components(separatedBy: GV.innerSeparator)
            for (sizeIndex, value) in sizes.enumerated() {
                arr[languageIndex][sizeIndex] = Int(value)!
            }
        }
    }
    init() {
        arr = Array(repeating: Array(repeating: 0, count: 6), count: 4)
    }

}
let NoGamePlayed = 50000

enum MaxScoreType: Int {
    case GameCenter = 0, Device
    var description : String {
      switch self {
      // Use Internationalization, as appropriate.
      case .GameCenter: return "W"
      case .Device: return "D"
      }
    }

}

class BasicData: Object {
    @objc dynamic var showDemo = true
    @objc dynamic var ID = 0
    @objc dynamic var actLanguage = ""
    @objc dynamic var gameSize = 0
    @objc dynamic var gameNumber = NoGamePlayed
    @objc dynamic var creationTime = Date()
    @objc dynamic var playingTime = 0
    @objc dynamic var playingTimeToday = 0
    @objc dynamic var countPlaysToday = 0
    @objc dynamic var lastPlayingDay = 0
    @objc dynamic var deviceType = 0
    @objc dynamic var land = 0
    @objc dynamic var version = 0
    @objc dynamic var countPlays = 0
    @objc dynamic var musicOn = false
    @objc dynamic var deviceInfoSaved = false
//    @objc dynamic var GameCenterEnabled = GCEnabledType.AskForGameCenter.rawValue
    @objc dynamic var deviceRecordInCloudID = ""
    @objc dynamic var showingScoreType = 0 // ScoreType
    @objc dynamic var showingTimeScope = 0 // TimeScope
    let deviceMaxScores = List<MaxScores>()
    let worldMaxScores = List<MaxScores>()
    let allFoundedWords = List<FoundedWords>()

    override  class func primaryKey() -> String {
        return "ID"
    }
    
    public func getMaxScore(type: MaxScoreType)->(String, Int) {
        if type == .GameCenter {
            if GV.connectedToGameCenter {
                return (worldMaxScores[gameSize - 5].player, worldMaxScores[gameSize - 5].maxScore)
            }
        } else {
            return (GKLocalPlayer.local.alias, deviceMaxScores[gameSize - 5].maxScore)
        }
        return ("", 0)
    }
    public func getLocalMaxScore()->Int {
        return deviceMaxScores[gameSize - 5].maxScore
    }
    public func setLocalMaxScore(score: Int) {
        if deviceMaxScores[gameSize - 5].maxScore < score {
            deviceMaxScores[gameSize - 5].maxScore = score
        }
    }
    public func setGCMaxScore(score: Int, player: String) {
        worldMaxScores[gameSize - 5].maxScore = score
        worldMaxScores[gameSize - 5].player = player
    }
}

class MaxScores: Object {
    @objc dynamic var ID = "" // W5...10, D5...10
    @objc dynamic var size = 0
    @objc dynamic var maxScore = 0
    @objc dynamic var player = ""
    override  class func primaryKey() -> String {
        return "ID"
    }
    init(newSize: Int, type: MaxScoreType) {
        ID = type.description + String(newSize)
    }
    override init() {
        
    }
}
