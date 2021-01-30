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
        override  class func primaryKey() -> String {
            return "word"
        }
}
