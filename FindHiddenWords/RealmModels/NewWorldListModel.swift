//
//  NewWordList.swift
//  DuelOfWords
//
//  Created by Romhanyi Jozsef on 2020. 06. 10..
//  Copyright © 2020. Romhanyi Jozsef. All rights reserved.
//

import Foundation
import RealmSwift

class NewWordListModel: Object {
        @objc dynamic var word = ""
        @objc dynamic var checked = false
        override  class func primaryKey() -> String {
            return "word"
        }
}
