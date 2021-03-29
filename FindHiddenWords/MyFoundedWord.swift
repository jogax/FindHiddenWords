//
//  MyFoundedWord.swift
//  DuelOfWords
//
//  Created by Romhanyi Jozsef on 2020. 07. 14..
//  Copyright © 2020. Romhanyi Jozsef. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

class MyFoundedWord: MyLabel {
    var usedWord: UsedWord!
    var mandatory: Bool = false
    var founded: Bool = false
    init(usedWord: UsedWord, mandatory: Bool, prefixValue: Int) {
        self.usedWord = usedWord
        self.mandatory = mandatory
        let prefix = (prefixValue < 10 ? "0" : "") + "\(prefixValue). "
        let myText =  prefix + (mandatory ? GV.questionMark.fill(with: GV.questionMark, toLength: usedWord.word.length) : usedWord.word)
        let dummyText = " ".fixLength(length: myText.count)
//        let myName = usedWord.word + (mandatory ? GV.mandatoryLabelInName : GV.ownLabelInName)
//        super.init(text: myText, position: CGPoint(x: 0, y: 0), fontName: GV.headerFontName, fontSize: GV.wordsFontSize)
        super.init(text: dummyText, position: CGPoint(x: 0, y: 0), fontName: GV.headerFontName, fontSize: GV.wordsFontSize)
        self.horizontalAlignmentMode = .left
        self.myType = .MyLabel
        for (index, letter) in myText.enumerated() {
            var child = SKLabelNode()
            child.text = String(letter)
            child.fontName = GV.headerFontName
            child.fontSize = GV.wordsFontSize
            child.fontColor = .black
            child.position = CGPoint(x: index * Int(String(letter).width(font: UIFont(name: GV.headerFontName, size: GV.wordsFontSize)!)), y: 0)
            addChild(child)
            if index >= prefix.length {
                let col = usedWord.usedLetters[index - prefix.length].col
                let row = usedWord.usedLetters[index - prefix.length].row
                GV.gameArray[col][row].addLetterForUpdate(letter: &child)
            }
        }
    }
    
    
    public func setQuestionMarks() {
//        var newText = text!.startingSubString(length: 4)
//        for letter in usedWord!.usedLetters {
//            var addingLetter: String!
//            switch GV.basicData.gameDifficulty {
//            case EasyGame:
//                addingLetter = letter.letter
//            case MediumGame:
//                addingLetter = GV.gameArray[letter.col][letter.row].status == .WholeWord ? letter.letter : GV.questionMark
//            case HardGame:
//                addingLetter = GV.gameArray[letter.col][letter.row].status == .WholeWord ? GV.innerSeparator : GV.questionMark
//            default:
//                break
//            }
//            newText += addingLetter
//        }
//
//        text = newText
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
