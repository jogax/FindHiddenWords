//
//  MyFoundedWord.swift
//  DuelOfWords
//
//  Created by Romhanyi Jozsef on 2020. 07. 14..
//  Copyright © 2020. Romhanyi Jozsef. All rights reserved.
//

import Foundation
import UIKit

class MyFoundedWord: MyLabel {
    var usedWord: UsedWord?
    var mandatory: Bool = false
    var founded: Bool = false
    init(usedWord: UsedWord, mandatory: Bool, prefixValue: Int) {
        self.usedWord = usedWord
        self.mandatory = mandatory
        let prefix = (prefixValue < 10 ? "0" : "") + "\(prefixValue). "
        let myText =  prefix + (mandatory ? GV.questionMark.fill(with: GV.questionMark, toLength: usedWord.word.length) : usedWord.word)
//        let myName = usedWord.word + (mandatory ? GV.mandatoryLabelInName : GV.ownLabelInName)
        super.init(text: myText, position: CGPoint(x: 0, y: 0), fontName: GV.headerFontName, fontSize: GV.wordsFontSize)
        self.horizontalAlignmentMode = .left
        self.myType = .MyLabel
    }
    
    public func setQuestionMarks() {
        var newText = text!.startingSubString(length: 4)
        for letter in usedWord!.usedLetters {
            newText += GV.gameArray[letter.col][letter.row].status == .WholeWord ? letter.letter : GV.questionMark
        }
        text = newText
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
