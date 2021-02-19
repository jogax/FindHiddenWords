//
//  PlayedGames.swift
//  DuelOfWords
//
//  Created by Romhanyi Jozsef on 2020. 06. 18..
//  Copyright © 2020. Romhanyi Jozsef. All rights reserved.
//

import Foundation
import RealmSwift

var playedGame = GameModel()
class PlayedGame: Object {
    @objc dynamic var primary = ""
    @objc dynamic var language = ""
    @objc dynamic var gameNumber = 0
    @objc dynamic var gameSize = 0
    @objc dynamic var gameArray = ""
    var  wordsToFind = List<FoundedWords>()
    var myWords = List<FoundedWords>()
    @objc dynamic var finished = false
    @objc dynamic var timeStamp = NSDate()
    override  class func primaryKey() -> String {
        return "primary"
    }
}

