//
//  GameModel.swift
//  FindHiddenWords
//
//  Created by Romhanyi Jozsef on 2021. 02. 09..
//

import Foundation
import RealmSwift

var playedGame = GameModel()
class GameModel: Object {
    @objc dynamic var primary = ""
    @objc dynamic var language = ""
    @objc dynamic var gameNumber = 0
    @objc dynamic var gameSize = 0
    @objc dynamic var gameArray = ""
    @objc dynamic var connections = ""
    var wordsToFind = List<FoundedWords>()
    var myWords = List<FoundedWords>()
    var myDemos = List<FoundedWords>()
    @objc dynamic var finished = false
    @objc dynamic var timeStamp = NSDate()
    @objc dynamic var OK = true
    @objc dynamic var errorCount = 0
    override  class func primaryKey() -> String {
        return "primary"
    }
}
