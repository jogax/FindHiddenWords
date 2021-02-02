//
//  FoundedWords.swift
//  FindHiddenWords
//
//  Created by Romhanyi Jozsef on 2021. 01. 30..
//

import RealmSwift
import Foundation

class FoundedWords: Object {
//    static var newID = 0
    @objc dynamic var ID = 0
    @objc dynamic var language = ""
    @objc dynamic var mandatory = false
    @objc dynamic var word = ""
    @objc dynamic var usedLetters = ""
    override  class func primaryKey() -> String {
        return "ID"
    }
    public func getUsedWord()->UsedWord {
        var returnValue = UsedWord()
        let myUsedLetters = usedLetters.components(separatedBy: GV.innerSeparator)
        for item in myUsedLetters {
            let itemToAppend = UsedLetter(col: Int(item.char(at: 0))!, row: Int(item.char(at: 1))!, letter: item.char(at: 2))
            returnValue.usedLetters.append(itemToAppend)
        }
        returnValue.word = self.word
        returnValue.mandatory = self.mandatory
        return returnValue
    }
    init(from: String) {
        let firstSeparatorIndex = from.index(of: GV.innerSeparator)!
        super.init()
        self.ID = getNewID()
        self.language = GV.actLanguage
        self.word = from.startingSubString(length: firstSeparatorIndex)
        self.usedLetters = from.endingSubString(at: firstSeparatorIndex + 1)
    }
    
    init(fromUsedWord: UsedWord) {
        super.init()
        self.ID = getNewID()
        self.language = GV.actLanguage
        self.mandatory = fromUsedWord.mandatory
        self.word = fromUsedWord.word
        self.usedLetters = fromUsedWord.usedLettersToString()
    }
    override init() {
        super.init()
//        self.ID = getNewID()
        self.language = GV.actLanguage
        self.word = ""
        self.usedLetters = ""
    }
    
    func getNewID()->Int {
        return getNextID.incrementID()
//        FoundedWords.newID += 1
//        return FoundedWords.newID
    }
}

class getNextID {
    static func incrementID() -> Int {
//        let playedGamesRealm = getRealm(type: .PlayedGameRealm)
        return playedGamesRealm!.objects(FoundedWords.self).count + 1
    }
}

