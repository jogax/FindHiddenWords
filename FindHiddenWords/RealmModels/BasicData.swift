//
//  BasicData.swift
//  DuelOfWords
//
//  Created by Romhanyi Jozsef on 2020. 05. 12..
//  Copyright © 2020. Romhanyi Jozsef. All rights reserved.
//

import Foundation
import RealmSwift

enum GCEnabledType: Int {
    case AskForGameCenter = 0, GameCenterEnabled, GameCenterSupressed
}

let NoGamePlayed = 5000


class BasicData: Object {
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
    @objc dynamic var GameCenterEnabled = GCEnabledType.AskForGameCenter.rawValue
    @objc dynamic var deviceRecordInCloudID = ""
    @objc dynamic var showingScoreType = 0 // ScoreType
    @objc dynamic var showingTimeScope = 0 // TimeScope
    @objc dynamic var localMaxScores = "0/0/0/0/0/0/0/0/0/0"
    @objc dynamic var GCMaxScores = "0/0/0/0/0/0/0/0/0/0"

    override  class func primaryKey() -> String {
        return "ID"
    }
    
}
