//
//  FoundedWords.swift
//  FindHiddenWords
//
//  Created by Romhanyi Jozsef on 2021. 01. 30..
//

import RealmSwift
import Foundation

class FoundedWords: Object {
        @objc dynamic var word = ""
        @objc dynamic var usedLetters = ""
        override  class func primaryKey() -> String {
            return "word"
        }
    public func convertsUsedLetters()->[UsedLetter] {
        let myUsedLetters = usedLetters.components(separatedBy: GV.innerSeparator)
        for letter in myUsedLetters {
            let itemToAppend = UsedLetter(col: <#T##Int#>, row: <#T##Int#>, letter: <#T##String#>)
        }
    }
}
