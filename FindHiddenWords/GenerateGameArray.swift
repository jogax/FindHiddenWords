//
//  GenerateGameArray.swift
//  DuelOfWords
//
//  Created by Romhanyi Jozsef on 2020. 05. 13..
//  Copyright © 2020. Romhanyi Jozsef. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import SpriteKit
import GameplayKit

public struct UsedLetter {
    var col: Int = 0
    var row: Int = 0
    var letter: String = emptyLetter
    init(col: Int, row: Int, letter: String) {
        self.col = col
        self.row = row
        self.letter = letter
    }
    func toString()->String {
        return String(col) + String(row) + String(letter)
    }
    static public func ==(lhs: UsedLetter, rhs: UsedLetter) -> Bool {
        return lhs.col == rhs.col && lhs.row == rhs.row && lhs.letter == rhs.letter
    }
    static public func !=(lhs: UsedLetter, rhs: UsedLetter) -> Bool {
        return lhs.col != rhs.col || lhs.row != rhs.row || lhs.letter != rhs.letter
    }

}

public struct UsedWord {
    var word = ""
    var usedLetters = [UsedLetter]()
    static func +(lhs: UsedWord, rhs: UsedWord)->UsedWord {
        return UsedWord(word: lhs.word + rhs.word, usedLetters: lhs.usedLetters + rhs.usedLetters)
    }
    public func reversed()->UsedWord {
        var returnValue = UsedWord()
        for index in 0..<self.word.length {
            returnValue.usedLetters.insert(self.usedLetters[index], at: 0)
        }
        returnValue.word = String(self.word.reversed())
        return returnValue
    }
    init(word: String, usedLetters: [UsedLetter]) {
        self.word = word
        self.usedLetters = usedLetters
    }
    init(from: String="") {
        let parts = from.components(separatedBy: GV.innerSeparator)
        word = parts[0]
        for usedLetter in parts[1...] {
            if let col = Int(usedLetter.char(at: 0)) {
                if let row = Int(usedLetter.char(at: 1)) {
                    let letter = usedLetter.char(at: 2)
                    usedLetters.append(UsedLetter(col: col, row: row, letter: letter))
                }
            }
        }
    }
    public mutating func append(_ usedLetter: UsedLetter) {
        self.word += usedLetter.letter
        self.usedLetters.append(usedLetter)
    }
    public mutating func removeLast() {
        self.word.removeLast()
        self.usedLetters.removeLast()
    }
    public var count: Int {
        return self.word.length
    }
    static public func ==(lhs: UsedWord, rhs: UsedWord) -> Bool {
        if lhs.usedLetters.count != rhs.usedLetters.count {
            return false
        }
        for index in 0..<lhs.usedLetters.count {
            if !(lhs.usedLetters[index] == rhs.usedLetters[index]) {
                return false
            }
        }
        return lhs.word == rhs.word
    }
    
    public func toString()->String {
        var returnValue = ""
        returnValue += word
        for item in usedLetters {
            returnValue += GV.innerSeparator + item.toString()
        }
        return returnValue
    }
}

enum Direction: CaseIterable {
    static var allCases: [Direction] {
        return [.Left, .Up, .Right, .Down]
    }
    case Left, Up, Right, Down
    @available(*, unavailable)
    case all
}



class GenerateGameArray {
    let enabledEmptyCount = [5: 3, 6: 5, 7: 8, 8: 9, 9: 10, 10: 12]
    let questionMark = "?"
    var size: Int
    var allWords = newWordListRealm.objects(NewWordListModel.self).filter("word beginswith %@", GV.actLanguage)
    var usableWords = newWordListRealm.objects(NewWordListModel.self).filter("word beginswith %@ and checked = true and (word like %@ or word like %@ or word like %@ or word like %@ or word like %@ or word like %@)", GV.actLanguage, "???????", "????????", "?????????", "??????????", "???????????", "????????????")
    var letterMap = [String:[UsedLetter]]()
    var words = [UsedWord]()
    var generatedLetters = [UsedLetter]()
    var myRandom = MyRandom(gameNumber: 1, modifier: 333)
    var myGamesRealm: Realm?
    let realm: Realm = try! Realm(configuration: Realm.Configuration.defaultConfiguration)
    var basicData = BasicData()
    init(size: Int) {
        self.size = size
    }
    public func start(new: Bool) {
        myGamesRealm = getRealm(type: .GamesRealm)
        print("Start generating: Language: \(GV.actLanguage), Size: \(size), GamNumber: \(GV.gameNumber)")
        let modifierArray = ["en": 111, "de": 222, "hu": 333, "ru": 444]
        basicData = realm.objects(BasicData.self).first!
        primary = GV.actLanguage + GV.innerSeparator + String(GV.gameNumber) + GV.innerSeparator + String(size)
        let record = myGamesRealm!.objects(Games.self).filter("primary = %@", primary)
        var errorCount = 0
        if record.count > 0 {
            errorCount = record[0].errorCount
//            errorCount = 10 // temporary!!!!!!!!!!!!!!
        }
        myRandom = MyRandom(gameNumber: (GV.gameNumber + 1) * (11 + errorCount * 999), modifier: modifierArray[GV.actLanguage]!)
        for col in 0..<size {
            for row in 0..<size {
                GV.gameArray[col][row].position = grid!.gridPosition(col: col, row: row) //+
//                GV.gameArray[col][row].name = "GBD/\(col)/\(row)"
                GV.gameArray[col][row].setNeighbor(direction: .Down, neighbor: row == size - 1 ? nil : GV.gameArray[col][row + 1])
                GV.gameArray[col][row].setNeighbor(direction: .Up, neighbor: row == 0 ? nil : GV.gameArray[col][row - 1])
                GV.gameArray[col][row].setNeighbor(direction: .Right, neighbor: col == size - 1 ? nil : GV.gameArray[col + 1][row])
                GV.gameArray[col][row].setNeighbor(direction: .Left, neighbor: col == 0 ? nil : GV.gameArray[col - 1][row])
                GV.gameArray[col][row].col = col
                GV.gameArray[col][row].row = row
                grid!.addChild(GV.gameArray[col][row])
                setCountConnections(col: col, row: row)
                let dummy = SKSpriteNode()
                let value = 0.6 * GV.blockSize
                dummy.size = CGSize(width: value, height: value)
                dummy.position = grid!.gridPosition(col: col, row: row)
                dummy.name = "GBD/\(col)/\(row)"
                grid!.addChild(dummy)
            }
        }
        generating()
    }
    
    var primary = ""

    private func generating() {
        let maxItemCount = size * size
        var doing = true
        var countGeneratedWords = 1
        var wordCount = 0
        var countRepeats = 0
        repeat {
            let search = "?".fill(with: "?", toLength: size + 2)
            let myWords = usableWords.filter("word like %@", search)
            let wordIndex = myRandom.getRandomInt(0, max: myWords.count - 1)
            let word = myWords[wordIndex].word.endingSubString(at: 2).uppercased()
            var generatedWord = UsedWord()
            if maxItemCount == countEmptyCells() {
                generatedWord = addFirstWordToGameArray(word: word)
            } else {
                generatedWord = addWordToGameArray()
            }
            if generatedWord.count == 0 {
//                print("stopped")
                let counter = getEmptyCells()
                if counter < enabledEmptyCount[size]! || countRepeats >= 3 {
                    doing = false
                } else {
                    clearGameArray()
                    words.removeAll()
                    wordCount = 0
                    for label in wordLabels {
                        label.text = ""
                    }
                    countRepeats += 1
                    countGeneratedWords = 1
                }
            }
//            if generatedWord.word == "ZABLA" { //МОЗАИКА"  {
//                print("stopped at \(generatedWord.word)")
//            }
            if generatedWord.count.between(min: 3, max: 4) {
                print("generatedWord: \(generatedWord) is too short!")
             }
            if generatedWord.word.length > 0 {
                print("generatedWord: \(countGeneratedWords):\(generatedWord.word) (\(generatedWord.word.count))")
                wordLabels[wordCount].text = "\(String(wordCount + 1).fixLength(length: 2, center: false, leadingBlanks: false)). \(generatedWord.word)"
                wordCount += 1
            }
            countGeneratedWords += 1
            if generatedWord.count != 0 {
                words.append(generatedWord)
            }
            addWord(generatedWord)
//            checkWord(usedWord: generatedWord)
            generatedLetters.sort(by: {$0.col < $1.col || ($0.col == $1.col && $0.row < $1.row)})
//            doing = countEmptyFields() > 0
        } while doing
        _ = getEmptyCells()
        
        if emptyCells.count > 0 {
            for cell in emptyCells {
                repeat {
                    let col = myRandom.getRandomInt(0, max: size - 1)
                    let row = myRandom.getRandomInt(0, max: size - 1)
                    let actCell = GV.gameArray[col][row]
                    if actCell.status == .Used {
                        _ = cell.setLetter(letter: actCell.letter, toStatus: .Used/*, calledFrom: "generating"*/)
                        break
                    }
                } while true
            }
        }
        saveGame()
        printGameArray()
        clearGameArray(neighborToo: true)
        GV.size = 0
    }
    
    private func saveGame() {
//        primary = GV.actLanguage + GV.innerSeparator + String(GV.gameNumber) + GV.innerSeparator + String(size)
        var OK = true
        var countLettersInWords:CGFloat = 0
        for word in words {
            countLettersInWords += CGFloat(word.count)
            for item in word.usedLetters {
                if item.letter != GV.gameArray[item.col][item.row].letter {
                    if GV.gameArray[item.col][item.row].status == .Empty {
                        _ = GV.gameArray[item.col][item.row].setLetter(letter: item.letter, toStatus: .Used)
                    } else {
                        print("error bei check: \(item)")
                        errorLabel.text = "error bei check: gameNumber: \(GV.gameNumber), language: \(GV.actLanguage), size: \(size)"
                        OK = false
                    }
                }
            }
        }
        let cSize = CGFloat(size)
        let valueToPrint = countLettersInWords / (cSize * cSize)
        print("usage: \(valueToPrint.nDecimals(n: 3))")
        let game = myGamesRealm!.objects(Games.self).filter("primary = %@", primary)
        var gameRecord = Games()
        let new = game.count == 0
        if new {
            gameRecord = Games()
        } else {
            gameRecord = game.first!
        }
        try! myGamesRealm?.safeWrite() {
            gameRecord.language = GV.actLanguage
            gameRecord.gameNumber = GV.gameNumber
            gameRecord.size = size
            gameRecord.OK = OK
            gameRecord.gameArray = gameArrayToString()
            gameRecord.words = wordsToString()
            gameRecord.timeStamp = NSDate()
            if new {
                gameRecord.primary = primary
                myGamesRealm?.add(gameRecord)
            }
        }
        let testRecord = myGamesRealm!.objects(Games.self).filter("primary = %@", primary)
        if testRecord.count == 0 {
            print ("record \(primary) not saved!")
        }
    }
    
    private func gameArrayToString()->String {
        var gameArrayString = ""
        for col in 0..<size {
            for row in 0..<size {
                gameArrayString += GV.gameArray[col][row].letter
            }
        }
        return gameArrayString
    }
    
    private func wordsToString() -> String {
        var wordsString = ""
        for word in words {
            wordsString += word.toString() + GV.outerSeparator
        }
        wordsString.removeLast()
        return wordsString
    }
    
    private func addWord(_ generatedWord: UsedWord) {
        for item in generatedWord.usedLetters {
            if letterMap[item.letter] == nil {
                letterMap[item.letter] = [UsedLetter]()
            }
            letterMap[item.letter]!.append(item)
            if !generatedLetters.contains(where: {$0.col == item.col && $0.row == item.row}) {
                generatedLetters.append(item)
            }
        }
    }
    
    private func checkWord(usedWord: UsedWord) {
        if usedWord.word.length == 0 {
            return
        }
        var length = 3
        var index = 0
        var run = true
        var countRuns = 0
        repeat {
            let searchWord = GV.actLanguage + usedWord.word.subString(at: index, length: length).lowercased()
            if allWords.filter("word = %@", searchWord).count == 1 {
                var newUsedLetters = [UsedLetter]()
                for ind in index..<index + length {
                    newUsedLetters.append(usedWord.usedLetters[ind])
                }
                let wordToInsert = UsedWord(word: usedWord.word.subString(at: index, length: length), usedLetters: newUsedLetters)
                if !words.contains(where: {$0.word == wordToInsert.word}) {
                    words.append(wordToInsert)
                }
            }
            let reversedSearchWord = GV.actLanguage + String(usedWord.word.subString(at: index, length: length).reversed()).lowercased()
            if allWords.filter("word endswith %@", reversedSearchWord).count == 1 {
                var newUsedLetters = [UsedLetter]()
                for ind in index..<index + length {
                    newUsedLetters.insert(usedWord.usedLetters[ind], at: 0)
                }
                let wordToInsert = UsedWord(word: String(usedWord.word.subString(at: index, length: length).reversed()), usedLetters: newUsedLetters)
                if !words.contains(where: {$0.word == wordToInsert.word}) {
                    words.append(wordToInsert)
                }
            }
            index += 1
            if index + length > usedWord.word.length {
                length += 1
                index = 0
            }
            if index + length > usedWord.word.length {
                run = false
            }
            countRuns += 1
        } while run
    }

    

    private func addFirstWordToGameArray(word: String)->UsedWord {
        var returnValue = UsedWord()
        var col = myRandom.getRandomInt(0, max:size - 1)
        var row = myRandom.getRandomInt(0, max:size - 1)
        var noMoreSteps = false
        repeat {
            noMoreSteps = false
            returnValue = UsedWord(word: word, usedLetters: [UsedLetter]())
            clearGameArray()
            for item in word {
                let letter = String(item)
                _ = GV.gameArray[col][row].setLetter(letter: letter, toStatus: .Used)
                setCountConnections(col: col,row: row)
                let actUsedLetter = UsedLetter(col: col, row: row, letter: letter)
                returnValue.usedLetters.append(actUsedLetter)
                (noMoreSteps, col, row) = getNextEmptyPosition(actCol: col, actRow: row)
                if noMoreSteps {
                    break
                }
            }
        } while noMoreSteps
        return returnValue
    }
    
    private func setCountConnections(col: Int, row: Int) {
        var positionsToCheck = [(col:Int, row:Int)]()
        positionsToCheck.append((col, row))
        if col > 0 {positionsToCheck.append((col - 1, row))}
        if col < size - 1 {positionsToCheck.append((col + 1, row))}
        if row > 0 {positionsToCheck.append((col, row - 1))}
        if row < size - 1 {positionsToCheck.append((col, row + 1))}
        for position in positionsToCheck {
//            if GV.gameArray[position.col][position.row].status != .Empty {
                var counter = 0
                if position.col > 0 {counter += GV.gameArray[position.col - 1][position.row].status != .Empty ? 0 : 1}
                if position.col < size - 1 {counter += GV.gameArray[position.col + 1][position.row].status != .Empty ? 0 : 1}
                if position.row > 0 {counter += GV.gameArray[position.col][position.row - 1].status != .Empty ? 0 : 1}
                if position.row < size - 1 {counter += GV.gameArray[position.col][position.row + 1].status != .Empty ? 0 : 1}
                GV.gameArray[position.col][position.row].countFreeConnections = counter
//            }
        }
    }
    
    private func clearGameArray(neighborToo: Bool = false) {
        for col in 0..<size {
            for row in 0..<size {
                GV.gameArray[col][row].remove()
                if neighborToo {
                    GV.gameArray[col][row].leftNeighbor = nil
                    GV.gameArray[col][row].rightNeighbor = nil
                    GV.gameArray[col][row].upperNeighbor = nil
                    GV.gameArray[col][row].lowerNeighbor = nil
                }
            }
        }
    }
    
    private func getNextEmptyPosition(actCol: Int, actRow: Int)->(noMoreSteps: Bool, col: Int, row: Int) {
        var newPos = [(col: Int, row: Int)]()
        if actCol > 0 && GV.gameArray[actCol - 1][actRow].status == .Empty {
            newPos.append((col: actCol - 1, row: actRow))
        }
        if actCol < size - 1 && GV.gameArray[actCol + 1][actRow].status == .Empty {
            newPos.append((col: actCol + 1, actRow))
        }
        if actRow > 0 && GV.gameArray[actCol][actRow - 1].status == .Empty {
            newPos.append((actCol, actRow - 1))
        }
        if actRow < size - 1 && GV.gameArray[actCol][actRow + 1].status == .Empty {
            newPos.append((actCol, actRow + 1))
        }
        if newPos.count == 0 {
            return (true, 0,0)
        }
        let index = myRandom.getRandomInt(0, max: newPos.count - 1)
        return (false, newPos[index].col, newPos[index].row)
    }
    
    var charPositions = [(Int, Int)]()
    let star = "*"
//    let QM2 = "????"
//    let QM3 = "?????"
    let QM4 = "??????"
    let QM5 = "???????"
    let QM6 = "????????"
    let QM7 = "?????????"
    let QM8 = "??????????"
    let QM9 = "???????????"
    let QM10 = "????????????"
    let maxSize = 10
    var addedCells = [(col: Int, row:Int)]()
    var lettersInGameArray = [String:[UsedLetter]]()

    private func addWordToGameArray()->UsedWord {
        var countRestarts = 0
        var returnValue = UsedWord()
        var OK = false
        addedCells.removeAll()
        stopCycle:
        repeat {
            let allPossibleFragments: [ReturnedFromRecursion] = createAllPossibleFragmentsWithLength()
            clearAllCheckedCells()
            let sortedFragments = allPossibleFragments.sorted(by: {$0.foundedInDB.count > $1.foundedInDB.count})// && $0.parts[1].count > $1.parts[1].count})
            for fragment in sortedFragments {
                returnValue = UsedWord()
                for item in addedCells {
                    GV.gameArray[item.col][item.row].remove()
                }
                let firstPosOfFragment = fragment.foundedInGameaArray.usedLetters.first!
                let lastPosOfFragment = fragment.foundedInGameaArray.usedLetters.last!
                let myWord = fragment.foundedInDB //usableWords.filter("word like %@", searchWord)
                addedCells.removeAll()
                if !words.contains(where: {$0.word == myWord.uppercased()}) {
                    let wordParts = fragment.parts //String(myWord).myComponents(separatedBy:String(fragment.foundedInGameaArray.word).lowercased())
                    var prefix = ""
                    var postfix = ""
                    var generatedPrefix = UsedWord()
                    var generatedPostFix = UsedWord()
                    var generatedMidPart = UsedWord()
                    var midPart = fragment.foundedInGameaArray
                    for (index, item) in midPart.usedLetters.enumerated() {
                        let letter = wordParts[1].char(at: index).uppercased()
                        if item.letter == "?" {
                            midPart.usedLetters[index].letter = letter
                            _ = GV.gameArray[item.col][item.row].setLetter(letter: letter, toStatus: .Used)
                            addedCells.append((col:item.col, row: item.row))
                        }
                        generatedMidPart.word += letter
                        generatedMidPart.usedLetters.append(midPart.usedLetters[index])
                        
                    }
                    let (countFreeBefore, directionBefore) = getCountFreeCellsAt(col: firstPosOfFragment.col, row: firstPosOfFragment.row, checkLength: wordParts[0].length)
                    prefix = String(wordParts[0].uppercased().reversed())
                    if countFreeBefore >= wordParts[0].length {
                        if prefix.length > 0 {
                            (generatedPrefix, OK) = addWordPartToGameArray(word: prefix, before: firstPosOfFragment, toDirection: directionBefore)
                            if !OK {
                                removeAddedCells()
                                returnValue = UsedWord()
                                continue
                            }
                        }
                    } else {
                        let letterToCheck = fragment.foundedInGameaArray.usedLetters.first!
                        (generatedPrefix, OK) = compareLettersAt(letterToCheck, with: prefix)
                        if OK {
                            for item in generatedPrefix.usedLetters {
                                if GV.gameArray[item.col][item.row].status == .Empty {
                                    _ = GV.gameArray[item.col][item.row].setLetter(letter: item.letter, toStatus: .Used)
                                    addedCells.append((col:item.col, row: item.row))                                }
                            }
                        } else {
                            removeAddedCells()
                            returnValue = UsedWord()
                            continue
                        }
                    }
                    returnValue = generatedPrefix.reversed() + generatedMidPart
                    let (countFreeAfter, directionAfter) = getCountFreeCellsAt(col: lastPosOfFragment.col, row: lastPosOfFragment.row, checkLength: wordParts[2].length)
                    postfix = wordParts[2].uppercased()
                    if countFreeAfter >= wordParts[2].length {
                        if postfix.length > 0 {
                            (generatedPostFix, OK) = addWordPartToGameArray(word: postfix, after: lastPosOfFragment, toDirection: directionAfter)
                            if !OK {
                                removeAddedCells()
                                returnValue = UsedWord()
                                continue
                            }
                            returnValue = returnValue + generatedPostFix
                        }
                    } else {
                        let letterToCheck = fragment.foundedInGameaArray.usedLetters.last!
                        (generatedPostFix, OK) = compareLettersAt(letterToCheck, with: postfix)
                        if OK {
                            if generatedPostFix.usedLetters.count > 0 {
                                for item in generatedPostFix.usedLetters {
                                    if GV.gameArray[item.col][item.row].status == .Empty {
                                        _ = GV.gameArray[item.col][item.row].setLetter(letter: item.letter, toStatus: .Used)
                                        addedCells.append((col:item.col, row: item.row))
                                    }
                                }
                            }
                            returnValue = returnValue + generatedPostFix
                        } else {
                            removeAddedCells()
                            returnValue = UsedWord()
                            continue
                        }
                    }
                    if OK {
                        var testLetters = [UsedLetter]()
                        for item in returnValue.usedLetters {
                            if testLetters.contains(where: {$0.col == item.col && $0.row == item.row && $0.letter == item.letter}) {
                                OK = false
                                returnValue = UsedWord()
                                break
                            } else {
                                testLetters.append(item)
                            }
                        }
                        if OK {
                            break stopCycle
                        }
                    } else {
                        returnValue = UsedWord()
                    }
                }
            }
            func checkReturnValue()->Bool {
                for item in returnValue.usedLetters {
                    let col = item.col
                    let row = item.row
                    let letter = item.letter
                    if GV.gameArray[col][row].letter != letter {
                        if GV.gameArray[col][row].status == .Empty {
                            _ = GV.gameArray[col][row].setLetter(letter: letter, toStatus: .Used)
                        } else {
                            return false
                        }
                    }
                }
                return true
            }
            if returnValue.count > 0 {
                if !checkReturnValue() {
                    break
                }
            }
            if countEmptyCells() <= enabledEmptyCount[size]! || countRestarts >= 1 {
                break
            }
            countRestarts += 1
            print("hier countRestarts: \(countRestarts)")
        } while true
        return returnValue
    }
    
    private func removeAddedCells() {
        for item in addedCells {
            GV.gameArray[item.col][item.row].remove()
        }
    }
    
    private func createAllPossibleFragmentsWithLength()->[ReturnedFromRecursion] {
        var returnArray = [ReturnedFromRecursion]()
        _ = getEmptyCells()
        var indexes = [Int]()
        for index in 0..<generatedLetters.count {
            indexes.append(index)
        }
        repeat {
            let ind = myRandom.getRandomInt(0, max: indexes.count - 1)
            let actIndex = indexes[ind]
            indexes.remove(at: ind)
            let letter = generatedLetters[actIndex]
            recursionArray.removeAll()
            returnArray += getFragments(usedLetter: letter)
        } while indexes.count > 0 && returnArray.count == 0
        return returnArray
    }
    var collectedWord = UsedWord()
    private func getFragments(usedLetter: UsedLetter)->[ReturnedFromRecursion] {
        var distanceToEmptyLetterIsOK: Bool {
            get {
                var distance = 1000
                for cell in emptyCells {
                    distance = min(distance, abs(usedLetter.col - cell.col) + abs(usedLetter.row - cell.row))
                    if distance <= size {
                        return true
                    }
                }
                return false
            }
        }
        collectedWord = UsedWord()
        if distanceToEmptyLetterIsOK {
            doRecursion(usedLetter: usedLetter)
        }
        return recursionArray
    }

    enum ReturnedType: Int {
        case T100 = 0, T001, T200, T002, T300, T003, T400, T004, T010, T110, T011, T210, T012, T310, T013, T410, T014, T414, T101, T111, T201, T211, T102, T112, T202, T212, T301, T311, T113, T302, T312, T213, T303, T313, T103, T203, T104, T114, T411, T401, T000
    }

    struct ReturnedFromRecursion {
        var foundedInGameaArray: UsedWord
        var foundedInDB: String
        var parts: [String] = [String]()
        var type: ReturnedType = .T000
        
        init(foundedInGameaArray: UsedWord, foundedInDB: String, parts: [String], type: ReturnedType) {
            self.foundedInGameaArray = foundedInGameaArray
            self.foundedInDB = foundedInDB
            self.parts = parts
            self.type = type
        }
        static public func <(lhs: ReturnedFromRecursion, rhs: ReturnedFromRecursion) -> Bool {
            return lhs.type.rawValue < rhs.type.rawValue || lhs.type.rawValue == rhs.type.rawValue && lhs.foundedInDB.length < rhs.foundedInDB.length || lhs.type.rawValue == rhs.type.rawValue && lhs.type.rawValue == rhs.type.rawValue && lhs.foundedInDB.length == rhs.foundedInDB.length && lhs.foundedInDB < rhs.foundedInDB
        }
        static public func >(lhs: ReturnedFromRecursion, rhs: ReturnedFromRecursion) -> Bool {
            return lhs.type.rawValue < rhs.type.rawValue || lhs.type.rawValue == rhs.type.rawValue && lhs.foundedInDB.length > rhs.foundedInDB.length || lhs.type.rawValue == rhs.type.rawValue && lhs.foundedInDB.length == rhs.foundedInDB.length && lhs.foundedInDB < rhs.foundedInDB
        }
    }
    
    var recursionArray = [ReturnedFromRecursion]()
    
    func compareLettersAt(_ at: UsedLetter, with: String)->(UsedWord, Bool) {
        var returnValue = UsedWord()
        var cellToCheck = GV.gameArray[at.col][at.row]
        var letterOK = false
        for letter in with.uppercased() {
            letterOK = false
            for direction in Direction.allCases {
                let actCell = cellToCheck.getNeighborInDirection(direction: direction)
                if actCell != nil && actCell!.checked == false {
                    if actCell!.letter == String(letter) || actCell!.letter == emptyLetter {
//                        if actCell!.status == .Empty {
//                            _ = actCell!.setLetter(letter: String(letter), toStatus: .Used, calledFrom: "compareLettersAt")
//                        }
                        actCell!.checked = true
                        cellToCheck = actCell!
                        returnValue.usedLetters.append(UsedLetter(col: actCell!.col, row: actCell!.row, letter: String(letter)))
                        returnValue.word += String(letter)
                        letterOK = true
                        break
                    } else {
                        continue
                    }
                }
            }
            if !letterOK {
                return (UsedWord(), false)
            }
        }
        return (returnValue, true)
    }

    
    private func doRecursion(usedLetter: UsedLetter) {
        let myCell = GV.gameArray[usedLetter.col][usedLetter.row]
        func getNextLetter(usedLetter: UsedLetter, direcion: Direction)->UsedLetter? {
            func distanceToUsedLetterOK(newCol: Int, newRow: Int)->Bool {
                let cell = GV.gameArray[newCol][newRow]
                let upperStatus = (cell.upperNeighbor != nil && cell.upperNeighbor!.status == .Used && cell.upperNeighbor != myCell) ? true : false
                let leftStatus = (cell.leftNeighbor != nil && cell.leftNeighbor!.status == .Used && cell.leftNeighbor != myCell) ? true : false
                let lowerStatus = (cell.lowerNeighbor != nil && cell.lowerNeighbor!.status == .Used && cell.lowerNeighbor != myCell) ? true : false
                let rightStatus = (cell.rightNeighbor != nil && cell.rightNeighbor!.status == .Used && cell.rightNeighbor != myCell) ? true : false
                return upperStatus || leftStatus || lowerStatus || rightStatus
            }
            let col = usedLetter.col
            let row = usedLetter.row
            let hasQM = collectedWord.word.contains(questionMark)
            switch direcion {
            case .Left:
                if col > 0 && GV.gameArray[col - 1][row].status == .Used {
                    return UsedLetter(col: col - 1, row: row, letter: GV.gameArray[col - 1][row].letter)
                } else if col > 0 && GV.gameArray[col - 1][row].status == .Empty && distanceToUsedLetterOK(newCol: col - 1, newRow: row) && !hasQM {
                    return UsedLetter(col: col - 1, row: row, letter: questionMark)
                } else {
                    return nil
                }
            case .Up:
                if row > 0 && GV.gameArray[col][row - 1].status == .Used {
                    return UsedLetter(col: col, row: row - 1, letter: GV.gameArray[col][row - 1].letter)
                } else if row > 0 && GV.gameArray[col][row - 1].status == .Empty && distanceToUsedLetterOK(newCol: col, newRow: row - 1) && !hasQM {
                    return UsedLetter(col: col, row: row - 1, letter: questionMark)
                } else {
                    return nil
                }
            case .Right:
                if col < size - 1 && GV.gameArray[col + 1][row].status == .Used {
                    return UsedLetter(col: col + 1, row: row, letter: GV.gameArray[col + 1][row].letter)
                } else if col < size - 1 && GV.gameArray[col + 1][row].status == .Empty && distanceToUsedLetterOK(newCol: col + 1, newRow: row) && !hasQM {
                    return UsedLetter(col: col + 1, row: row, letter: questionMark)
                } else {
                    return nil
                }
            case .Down:
                if row < size - 1 && GV.gameArray[col][row + 1].status == .Used {
                    return UsedLetter(col: col, row: row + 1, letter: GV.gameArray[col][row + 1].letter)
                } else if row < size - 1 && GV.gameArray[col][row + 1].status  == .Empty && distanceToUsedLetterOK(newCol: col, newRow: row + 1) && !hasQM {
                    return UsedLetter(col: col, row: row + 1, letter: questionMark)
                } else {
                    return nil
                }
            }
        }
        
        let typeTable: [Int:ReturnedType] = [100:.T100, 10: .T010, 101: .T101, 102: .T102, 103: .T103, 104: .T104, 200: .T200, 201: .T201, 202: .T202, 203: .T203, 300: .T300, 301: .T301, 302: .T302, 303: .T303, 400: .T400, 401: .T401, 1: .T001, 2: .T002, 3: .T003, 4: .T004, 110: .T110, 11: .T011, 111: .T111, 210: .T210, 12: .T012, 212: .T212, 310: .T310, 13: .T013, 313: .T313, 410: .T410, 14: .T014, 414: .T414, 112: .T112, 211: .T211, 213: .T213, 312: .T312 ]

        func checkCollectedWord()->Bool {
            if collectedWord.word.endsWith("?") {
                return true
            }

            let firstCol = collectedWord.usedLetters.first!.col
            let firstRow = collectedWord.usedLetters.first!.row
            let lastCol = collectedWord.usedLetters.last!.col
            let lastRow = collectedWord.usedLetters.last!.row
            let (countfreeCellsBefore, _) = getCountFreeCellsAt(col: firstCol, row: firstRow, checkLength: maxSize - collectedWord.word.length)
            let (countfreeCellsAfter, _) = getCountFreeCellsAt(col: lastCol, row: lastRow, checkLength: maxSize - collectedWord.word.length)
            let searchWord = /*star + collectedWord.word + star*/ (countfreeCellsBefore > 0 ? star : "") + collectedWord.word + (countfreeCellsAfter > 0 ? star : "")
            let foundedWords = usableWords.filter("word like %@", GV.actLanguage + searchWord.lowercased())
            var OK = false
            stopCycle:
            if foundedWords.count > 0 {
                for item in foundedWords {
//                    if countfreeCellsBefore == 0 && countfreeCellsAfter == 0 {
//                        let a = "stopped at countfreeCellsBefore cllectedWord: \(collectedWord.word), item: \(item.word)"
////                        print("stopped at countfreeCellsBefore cllectedWord: \(collectedWord.word), item: \(item.word)")
//                    }
//                    if item.word == "beere" {
//                        print("stopped at \(item.word)")
//                    }
                    let parts = item.word.endingSubString(at: 2).myComponents(separatedBy: collectedWord.word.lowercased())
//                    let origIndex = item.word.index(of: collectedWord.word.lowercased())
//                    if parts[0].length <= countfreeCellsBefore && parts[2].length <= countfreeCellsAfter {
                    if !words.contains(where: {$0.word.lowercased() == item.word.endingSubString(at: 2)}) {
                            if !recursionArray.contains(where: {$0.foundedInGameaArray.word == collectedWord.word}) {
                                for item in collectedWord.usedLetters {
                                    GV.gameArray[item.col][item.row].checked = true
                                }
                                if collectedWord.word.countOf(questionMark) > 1 {
                                    break stopCycle
                                }
                                if parts[0].length > 0 {
                                    (_, OK) = compareLettersAt(collectedWord.usedLetters.first!, with: String(parts[0].reversed()))
                                    if !OK {
                                        break stopCycle
                                    }
                                }
                                if parts.last!.length > 0 {
                                    (_, OK) = compareLettersAt(collectedWord.usedLetters.last!, with: parts[2])
                                    if !OK {
                                        break stopCycle
                                    }
                                }
                                let midLen = collectedWord.word.contains(questionMark) ? 10 : 0
                                let lenForType = parts[0].length * 100 + midLen + parts[2].length
                                guard let type = typeTable[lenForType] else {
                                    break stopCycle
                                }
                                recursionArray.append(ReturnedFromRecursion(foundedInGameaArray: collectedWord, foundedInDB: item.word, parts: parts, type: type))
                                return true
                            }
                        }
//                    }
                    break stopCycle
                }
            }
            clearAllCheckedCells()
            return false
        }
        collectedWord.append(usedLetter)
        if collectedWord.count > 2 {
            if !checkCollectedWord() {
                collectedWord.removeLast()
                return
            }
        }
        for direction in Direction.allCases {
            let letter = getNextLetter(usedLetter: usedLetter, direcion: direction)
            if letter != nil && !collectedWord.usedLetters.contains(where: {$0.col == letter!.col && $0.row == letter!.row}) {
                let countQM = collectedWord.word.filter { $0 == "?" }.count
                if countQM == 2 {
                    return
                }
                doRecursion(usedLetter: letter!)
//                collectedWord.removeLast()
                if collectedWord.word.length >= maxSize {
                    return
                }
            }
        }
        collectedWord.removeLast()
        if collectedWord.word.length == 0 {
            return
        }
    }
    
    var emptyCells = [GameboardItem]()
    private func getEmptyCells()->Int {
        var counter = 0
        emptyCells.removeAll()
        for col in 0..<size {
            for row in 0..<size {
                if GV.gameArray[col][row].status == .Empty {
                    emptyCells.append(GV.gameArray[col][row])
                    counter += 1
                }
            }
        }
        return counter
    }
    
    func clearCheckedCells() {
        for cell in emptyCells {
            cell.checked = false
        }
    }

    func clearAllCheckedCells() {
        for col in 0..<size {
            for row in 0..<size {
                GV.gameArray[col][row].checked = false
            }
        }
    }

    
    private func getCountFreeCellsAt(col: Int, row: Int,checkLength: Int)->(Int, Direction) {
        var returnValue = 0
        var returnDirection = Direction.Up
        func countCheckedCells()->(all: Int, withOneFree: Int) {
            var allCounter = 0
            var oneFreeCounter = 0
            for cell in emptyCells {
                if cell.checked {
                    allCounter += 1
                    if cell.countFreeConnections == 1 {
                        oneFreeCounter += 1
                    }
                }
            }
            return (all:allCounter, withOneFree: oneFreeCounter)
        }
        _ = getEmptyCells()
        for direction in Direction.allCases {
            GV.gameArray[col][row].checkFreeCells(direction: direction)
            let (allCounter, oneFreeCounter) = countCheckedCells()
            clearCheckedCells()
            let adder = GV.gameArray[col][row].countFreeConnections == 1 ? 2 : 1
            let counter = allCounter - (oneFreeCounter > adder ? oneFreeCounter - adder : 0)
            if counter > returnValue {
                returnValue = counter
                returnDirection = direction
            }
            if returnValue >= checkLength {
                break
            }
        }
        return (returnValue, returnDirection)
    }
    
    
    
    private func resetInGameArray(word: UsedWord) {
        for index in 0..<word.usedLetters.count {
            let item = word.usedLetters[index]
            GV.gameArray[item.col][item.row].clearIfUsed()
        }
    }
    
    private func addWordPartToGameArray(word: String, before: UsedLetter? = nil, after: UsedLetter? = nil, toDirection: Direction)->(UsedWord, Bool) {
        var actPos: UsedLetter = (before == nil ? after : before)!
        var returnValue = UsedWord(word: word, usedLetters: [])
        let emptyCells = findEmptyCells(at: actPos, count: word.count, toDirection: toDirection)
        if emptyCells.count != word.count {
            return (returnValue, false)
        }
        for (index, item) in word.enumerated() {
            let (col, row) = (emptyCells[index].col, emptyCells[index].row)//getNextEmptyPosition(actCol: actPos.col, actRow: actPos.row)
            let letter = String(item)
            _ = GV.gameArray[col][row].setLetter(letter: letter, toStatus: .Used)
            addedCells.append((col:col, row: row))
            setCountConnections(col: col,row: row)
            let actUsedLetter = UsedLetter(col: col, row: row, letter: letter)
            returnValue.usedLetters.append(actUsedLetter)
            actPos.col = col
            actPos.row = row
        }
        return (returnValue, true)
    }
    
    private func findEmptyCells(at: UsedLetter, count: Int, toDirection: Direction)->[GameboardItem] {
        var emptyCells = [GameboardItem]()
        let noEmptyCells = [GameboardItem]()
        let actCell = GV.gameArray[at.col][at.row]
        func getNextEmptyCell(from: GameboardItem, direction: Direction)->GameboardItem? {
            switch direction {
            case .Down:
                if from.lowerNeighbor != nil && from.lowerNeighbor!.status == .Empty && !from.lowerNeighbor!.checked {
                    return from.lowerNeighbor!
                }
            case .Up:
                if from.upperNeighbor != nil && from.upperNeighbor!.status == .Empty && !from.upperNeighbor!.checked {
                    return from.upperNeighbor!
                }
            case .Left:
                if from.leftNeighbor != nil && from.leftNeighbor!.status == .Empty && !from.leftNeighbor!.checked {
                    return from.leftNeighbor!
                }
            case .Right:
                if from.rightNeighbor != nil && from.rightNeighbor!.status == .Empty && !from.rightNeighbor!.checked {
                    return from.rightNeighbor!
                }
            }
            return nil
        }
        
        guard let firstEmptyCell = getNextEmptyCell(from: actCell, direction: toDirection)  else {
            return noEmptyCells
        }
        emptyCells.append(firstEmptyCell)
        if count == 1 {
            return emptyCells
        }
        var actEmptyCell = emptyCells.first!
        actEmptyCell.checked = true
        let possibleDirections: [Direction] = [.Down, .Left, .Right, .Up]
        var index = 0
        var directionIndexes = [Int](repeating: 0, count: count)
        repeat {
            var returnedCell: GameboardItem?
            if directionIndexes[index] == 4 {
                if emptyCells.count > 0 {
                    emptyCells.last!.checked = false
                }
                return noEmptyCells
            }
            repeat {
                returnedCell = getNextEmptyCell(from: actEmptyCell, direction: possibleDirections[directionIndexes[index]])
                if returnedCell != nil {
                    emptyCells.append(returnedCell!)
                    break
                } else {
                    directionIndexes[index] += 1
                    if directionIndexes[index] == 4 {
                        break
                    }
                }
            } while true
            if returnedCell == nil {
                emptyCells.last!.checked = false
                directionIndexes[index] = 0
                index -= 1
                emptyCells.removeLast()
                if emptyCells.count == 0 {
                    clearCheckedCells()
                    return noEmptyCells
                }
                actEmptyCell = emptyCells.last!
                directionIndexes[index] += 1
            } else {
                returnedCell!.checked = true
                actEmptyCell = returnedCell!
                index += 1
            }
        } while count > emptyCells.count
//        } while index < count - 1
        clearCheckedCells()
        return emptyCells
    }
    
    private func getFragment(length: Int)->(UsedWord, Bool) {
        var freeCells = [(col: Int, row: Int)]()
        for col in 0..<size {
            for row in 0..<size {
                if GV.gameArray[col][row].status == .Used && GV.gameArray[col][row].countFreeConnections > 0 {
                    freeCells.append((col: col, row: row))
                }
            }
        }
        func checkPositionInReturnValue(col: Int, row: Int)->Bool {
            for pos in returnValue.usedLetters {
                if pos.col == col && pos.row == row {
                    return false
                }
            }
            return true
        }
        var returnValue = UsedWord()
        var returnBool = false
        let index = myRandom.getRandomInt(0, max: freeCells.count - 1)
        var col = freeCells[index].col
        var row = freeCells[index].row
        let letter = GV.gameArray[col][row].letter
        let firstLetter = UsedLetter(col: col, row: row, letter: letter)
        returnValue.word = firstLetter.letter
        returnValue.usedLetters.append(firstLetter)
        usedPositions.removeAll()
        usedPositions.append((col: col, row: row))
        var noMoreSteps = false
        var actLetter = firstLetter
        repeat {
            (noMoreSteps, col, row) = getNextUsedPosition(actCol: actLetter.col, actRow: actLetter.row)
            if !noMoreSteps {
                actLetter.letter = GV.gameArray[col][row].letter
                actLetter.col = col
                actLetter.row = row
                returnValue.word += actLetter.letter
                returnValue.usedLetters.append(UsedLetter(col: col, row: row, letter: actLetter.letter))
                usedPositions.append((col: col, row: row))
            }
            noMoreSteps = returnValue.word.count == length ? true : noMoreSteps
        } while !noMoreSteps
        let lastCol = returnValue.usedLetters.last!.col
        let lastrow = returnValue.usedLetters.last!.row
        returnBool = freeCells.contains(where: {$0.col == lastCol && $0.row == lastrow }) ? true : false
        return (returnValue, returnBool)
    }
    
    var usedPositions = [(col:Int, row: Int)]()
    
    private func getNextUsedPosition(actCol: Int, actRow: Int)->(noMoreSteps: Bool, col: Int, row: Int) {
        var newPos = [(col: Int, row: Int)]()
        if actCol > 0 && GV.gameArray[actCol - 1][actRow].status == .Used && !usedPositions.contains(where: {$0.col == actCol - 1 && $0.row == actRow}) {
            newPos.append((col: actCol - 1, row: actRow))
        }
        if actCol < size - 1 && GV.gameArray[actCol + 1][actRow].status == .Used && !usedPositions.contains(where: {$0.col == actCol + 1 && $0.row == actRow}) {
            newPos.append((col: actCol + 1, actRow))
        }
        if actRow > 0 && GV.gameArray[actCol][actRow - 1].status == .Used && !usedPositions.contains(where: {$0.col == actCol && $0.row == actRow - 1}) {
            newPos.append((actCol, actRow - 1))
        }
        if actRow < size - 1 && GV.gameArray[actCol][actRow + 1].status == .Used && !usedPositions.contains(where: {$0.col == actCol && $0.row == actRow + 1}) {
            newPos.append((actCol, actRow + 1))
        }
        if newPos.count == 0 {
            return (true, 0,0)
        }
        let index = myRandom.getRandomInt(0, max: newPos.count - 1)
        return (false, newPos[index].col, newPos[index].row)
    }
    

    
    
    private func countEmptyCells()->Int {
        var counter = 0
        for col in 0..<size {
            for row in 0..<size {
                if GV.gameArray[col][row].status == .Empty {
                    counter += 1
                }
            }
        }
        return counter
    }

    
    private func gameArrayNotFilled()->Bool {
        for col in 0..<size {
            for row in 0..<size {
                if GV.gameArray[col][row].status == .Empty {
                    return true
                }
            }
        }
        return false
    }
    
//    private func createNewGameArray() -> [[GameboardItem]] {
//        var gameArray: [[GameboardItem]] = []
//
//        for i in 0..<size {
//            gameArray.append( [GameboardItem]() )
//
//            for j in 0..<size {
//                gameArray[i].append( GameboardItem() )
//                gameArray[i][j].letter = emptyLetter
//            }
//        }
//        return gameArray
//    }
    
    private func printCell(_ cell: GameboardItem) {
        let infoLine = "col: \(cell.col), row: \(cell.row), letter: \(cell.letter), status: \(cell.status), checked: \(cell.checked)"
        print(infoLine)
    }
    private func printCell(_ cellArray: [GameboardItem]) {
        for cell in cellArray {
            printCell(cell)
        }
    }
    
    deinit {
        print("\n THE CLASS \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT) \n")
    }
}
