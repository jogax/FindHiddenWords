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


class BasicData: Object {
    @objc dynamic var ID = 0
    @objc dynamic var actLanguage = ""
    @objc dynamic var gameNumber = 0
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

    override  class func primaryKey() -> String {
        return "ID"
    }
    
}
