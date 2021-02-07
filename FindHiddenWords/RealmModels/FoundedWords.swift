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
    @objc dynamic var score = 0
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
        self.score = calculateScore()
    }
    
    init(fromUsedWord: UsedWord) {
        super.init()
        self.ID = getNewID()
        self.language = GV.actLanguage
        self.mandatory = fromUsedWord.mandatory
        self.word = fromUsedWord.word
        self.usedLetters = fromUsedWord.usedLettersToString()
        self.score = calculateScore()
    }
    override init() {
        super.init()
//        self.ID = getNewID()
        self.language = GV.actLanguage
        self.word = ""
        self.usedLetters = ""
    }
    
    private func calculateScore()->Int {
        let positions = self.usedLetters.components(separatedBy: GV.innerSeparator)
        var countLetters = 1
        for index in 0...positions.count - 2 {
            let col1 = Int(positions[index].char(at: 0))!
            let row1 = Int(positions[index].char(at: 1))!
            let col2 = Int(positions[index + 1].char(at: 0))!
            let row2 = Int(positions[index + 1].char(at: 1))!
            countLetters += abs(col1 - col2) + abs(row1 - row2)
        }
        return countLetters * 50
    }
    
    public var calculatedDiagonalConnections: Int {
        get {
            let returnValue = (score - (word.count * 50)) / 50
            return returnValue
        }
    }
    
    func getNewID()->Int {
        return getNextID.incrementID()
//        FoundedWords.newID += 1
//        return FoundedWords.newID
    }
}

class getNextID {
    static func incrementID() -> Int {
        let records = playedGamesRealm!.objects(FoundedWords.self)
        if let maxID = records.max(ofProperty: "ID") as Int? {
            return maxID + 1
        }
        return 1
    }
}

