//
//  FoundedWords.swift
//  FindHiddenWords
//
//  Created by Romhanyi Jozsef on 2021. 01. 30..
//

import RealmSwift
import Foundation

class FoundedWords: Object {
    @objc dynamic var ID = 0
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
        return returnValue
    }
    init(from: String) {
        let firstSeparatorIndex = from.index(of: GV.innerSeparator)!
        self.word = from.startingSubString(length: firstSeparatorIndex)
        self.usedLetters = from.endingSubString(at: firstSeparatorIndex + 1)
    }
    
    init(fromUsedWord: UsedWord) {
        self.word = fromUsedWord.word
        self.usedLetters = fromUsedWord.usedLettersToString()
    }
    override init() {
        super.init()
        self.ID = incrementID()
        self.word = ""
        self.usedLetters = ""
    }
    
    func incrementID()->Int {
//        let realm = try! Realm()
        return (Realm().objects(FoundedWords.self).max(ofProperty: "ID") as Int? ?? 0) + 1
    }
}
