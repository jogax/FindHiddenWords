//
//  AddNewWordsToOrigRecord.swift
//  FindHiddenWords
//
//  Created by Romhanyi Jozsef on 2021. 02. 10..
//

import Foundation
import Realm
import RealmSwift
import SpriteKit
import GameplayKit
import GameKit


public func getOrigGamesRewriteableRealm()->Realm {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let gamesURL = documentsURL.appendingPathComponent("OrigGames.realm")
    let config = Realm.Configuration(
        fileURL: gamesURL,
        schemaVersion: 1, // new item words
        shouldCompactOnLaunch: { totalBytes, usedBytes in
            // totalBytes refers to the size of the file on disk in bytes (data + free space)
            // usedBytes refers to the number of bytes used by data in the file

            // Compact if the file is over 100MB in size and less than 50% 'used'
            let oneMB = 10 * 1024 * 1024
            return (totalBytes > oneMB) && (Double(usedBytes) / Double(totalBytes)) < 0.8
    },
        objectTypes: [GameModel.self, FoundedWords.self])
    do {
        // Realm is compacted on the first open if the configuration block conditions were met.
        _ = try Realm(configuration: config)
    } catch {
        print("error")
        // handle error compacting or opening Realm
    }
    return try! Realm(configuration: config)

}

//private func getOriginalGamesRealm()->Realm {
//    let origGamesConfig = Realm.Configuration(
//        fileURL: URL(string: Bundle.main.path(forResource: "OrigGames", ofType: "realm")!),
//    readOnly: true,
//    schemaVersion: 1,
//        objectTypes: [GameModel.self, FoundedWords.self])
//    let realm = try! Realm(configuration: origGamesConfig)
//    return realm
//}
//
class AddNewWordsToOrigRecord {
    var origGamesRewriteableRealm: Realm!
    var gameSize = 0
    var language = ""
    
    public func findNewMandatoryWords() {
        AW.addNewWordsRunning = true

        origGamesRewriteableRealm = getOrigGamesRewriteableRealm()
        printWordCounters()
        checkOrigRecords()
        var continueSize =  0
        var continueLanguage = ""
        let continueRecord = origGamesRewriteableRealm.objects(GameModel.self).filter("OK = false").sorted(byKeyPath: "timeStamp")
        for item in continueRecord {
            if item.myDemos.count > 0 {
                continueSize = item.gameSize
                continueLanguage = item.language
                break
            }
        }
        repeat {
            for actSize in 5...10 {
                gameSize = 15 - actSize
                if continueSize > 0 {
                    if gameSize != continueSize {
                        continue
                    }
                    continueSize = 0
                }
                for actLanguage in ["hu", "ru", "de", "en"] {
                    language = actLanguage
                    if continueLanguage != "" {
                        if language != continueLanguage {
                            continue
                        }
                        continueLanguage = ""
                    }
                    let origRecords = origGamesRewriteableRealm.objects(GameModel.self).filter("primary beginswith %d and primary endswith %d and OK = false", actLanguage, String(gameSize)).sorted(byKeyPath: "gameNumber", ascending: true)
                    AW.addingWordData = AddingWordData()
                    var countRecords = 0
                    for record in origRecords {
                        try! origGamesRewriteableRealm.safeWrite {
                            origGamesRewriteableRealm.delete(record.myDemos)
                        }
                        workingRecord = record
                        let finishedRecords = origGamesRewriteableRealm.objects(GameModel.self).filter("OK = true")
                        let finishedProLanguage = origGamesRewriteableRealm.objects(GameModel.self).filter("OK = true and language = %d and gameSize = %d", language, gameSize)
                        AW.addingWordData.countFinishedRecords = finishedRecords.count
                        AW.addingWordData.language = language
                        AW.addingWordData.finishedProLanguage = finishedProLanguage.count
                        AW.addingWordData.gameSize = gameSize
                        AW.addingWordData.language = actLanguage
                        AW.addingWordData.gameNumber = record.gameNumber
                        AW.addingWordData.lastWord = ""
                        AW.addingWordData.countFoundedWords = 0
                        searchMoreWordsInRecord()
                        countRecords += 1
                        if countRecords == 1 {
                            break
                        }
                    }
                }
            }
        } while origGamesRewriteableRealm.objects(GameModel.self).filter("OK = true").count < 2400
    }
    
    private func checkOrigRecords() {
        let finishedRecords = origGamesRewriteableRealm.objects(GameModel.self).filter("OK = true").sorted(byKeyPath: "primary")
        countDeletedItems = 0
        for record in finishedRecords {
            print("In Record: (\(record.language)-\(record.gameSize)-\(record.gameNumber))  count items before: \(record.myDemos.count)")
            for item in record.myDemos {
                if !checkFoundedWordOK(foundedWord: item.getUsedWord()) {
                    countDeletedItems += 1
                    print("\(countDeletedItems). Item \(item.word) (\(item.usedLetters)) must be deleted from record: (\(record.language)-\(record.gameSize)-\(record.gameNumber))")
                    try! origGamesRewriteableRealm.safeWrite {
                        origGamesRewriteableRealm!.delete(item)
                    }
                }
            }
            print("In Record: (\(record.language)-\(record.gameSize)-\(record.gameNumber))  count items after: \(record.myDemos.count)")
            print()
        }
    }
    var countDeletedItems = 0
    private func checkFoundedWordOK(foundedWord: UsedWord)->Bool {
        let letters = foundedWord.usedLetters
        func notNeighbours(letter1: UsedLetter, letter2: UsedLetter)->Bool {
            return abs(letter1.col - letter2.col) > 1 || abs(letter1.row - letter2.row) > 1
        }
        for (index, usedLetter) in letters.enumerated() {
            if index < letters.count - 1 {
                if notNeighbours(letter1: usedLetter, letter2: letters[index + 1]) {
                    return false
                }
                for ind in index + 1..<letters.count {
                    if usedLetter == letters[ind] {
                        return false
                    }
                }
            }
        }
        return true
    }
    
    var workingRecord: GameModel!
        
    var allCheckedWords = newWordListRealm.objects(NewWordListModel.self).filter("checked = true and (word like %d or word like %d or word like %d or word like %d or word like %d or word like %d)",
                                                                                        "???????",
                                                                                        "????????",
                                                                                        "?????????",
                                                                                        "??????????",
                                                                                        "???????????",
                                                                                        "????????????")
    var cellIndexes = [Int]()
    private func searchMoreWordsInRecord(){
        let startTime = Date()
        let sizeMultiplier = GV.onIpad ? GV.sizeMultiplierIPad : GV.sizeMultiplierIPhone
        let blockSize = GV.minSide * sizeMultiplier[workingRecord.gameSize]
        GV.blockSize = blockSize
        GV.playingGrid = Grid(blockSize: blockSize * 1.1, rows: workingRecord.gameSize, cols: workingRecord.gameSize)
        GV.gameArray = createNewGameArray(size: workingRecord.gameSize)
        fillGameArray(gameArray: GV.gameArray, content:  workingRecord.gameArray, toGrid: GV.playingGrid!)
        for ind in 0..<workingRecord.gameSize*workingRecord.gameSize {
            cellIndexes.append(ind)
        }
        repeat {
            foundedWord = UsedWord()
            let index = 0 //Int.random(in: 0..<cellIndexes.count)
            let actIndex = cellIndexes[index]
            let col = actIndex / workingRecord.gameSize
            let row = actIndex % workingRecord.gameSize
            let workingCell = GV.gameArray[col][row]
            foundedWord.append(UsedLetter(col: workingCell.col, row: workingCell.row, letter: workingCell.letter))
//            resultArray.removeAll()
            recursionWithCells(cell: workingCell)
            AW.addingWordData.callIndexesLeft = cellIndexes.count
            cellIndexes.remove(at: index)
        } while cellIndexes.count > 0
        try! origGamesRewriteableRealm.safeWrite {
            workingRecord.OK = true
            AW.addingWordData.countFoundedWords = workingRecord.myDemos.count
        }
        let usedTime = Double(Date().timeIntervalSince(startTime)).minSec
        let finishedCunt = origGamesRewriteableRealm!.objects(GameModel.self).filter("OK = true").count
        let finishedProLanguage = origGamesRewriteableRealm.objects(GameModel.self).filter("OK = true and language = %d and gameSize = %d", language, gameSize).count
        print("\(finishedCunt) for language: \(language), size: \(gameSize), gameNumber: \(workingRecord.gameNumber), finished: \(finishedProLanguage) found: \(workingRecord.myDemos.count) words in \(usedTime) seconds")
    }
    var foundedWord = UsedWord()
//    var resultArray = [Results<NewWordListModel>]()
    
    private func recursionWithCells(cell:GameboardItem) {
        if AW.stopSearching {
            AW.stopSearching = false
            AW.addNewWordsRunning = false
        }
        let cellsAround = getCellsAround(cell: cell, exclude: foundedWord.usedLetters)
        for secondCell in cellsAround {
            foundedWord.append(UsedLetter(col: secondCell.col, row: secondCell.row, letter: secondCell.letter))
//            var results: Results<NewWordListModel>!
            let results = allCheckedWords.filter("word beginswith %d", (language + foundedWord.word).lowercased())
//            if resultArray.count == 0 {
//                results = allCheckedWords.filter("word beginswith %d", (language + foundedWord.word).lowercased())
//            } else {
//                results = allCheckedWords.filter("word beginswith %d", (language + foundedWord.word).lowercased())
////                results = resultArray.last!.filter("word beginswith %d", (language + foundedWord.word).lowercased())
//            }
//            resultArray.append(results)
//            print("resultArray.count: \(resultArray.count)")
//            print("foundedWord.word.count: \(foundedWord.word.count), results.count: \(results.count), foundedWord: \(foundedWord.word)")
            if foundedWord.word.count >= 5 && foundedWord.word.count <= 10 && results.count > 0 {
                let items = results.filter("word = %d", (language + foundedWord.word).lowercased())
                if items.count == 1 {
                    if  !workingRecord.wordsToFind.contains(where: {$0.word == foundedWord.word}) &&
                    !workingRecord.myDemos.contains(where: {$0.word == foundedWord.word}) &&
                    checkFoundedWordOK(foundedWord: foundedWord) {
                        try! origGamesRewriteableRealm.safeWrite {
                            workingRecord.myDemos.append(FoundedWords(fromUsedWord: foundedWord, actRealm: origGamesRewriteableRealm))
                        }
                        AW.addingWordData.countFoundedWords = workingRecord.myDemos.count
                        AW.addingWordData.callIndexesLeft = cellIndexes.count
                        AW.addingWordData.lastWord = foundedWord.word
    //                    print ("foundedWord: \(foundedWord.word), CellIndexes left: \(cellIndexes.count)")
                    }
                }
            }
            if results.count > 0 {
                recursionWithCells(cell: secondCell)
            } else {
                foundedWord.removeLast()
//                resultArray.removeLast()
            }
        }
//        if resultArray.count > 0 {
//            resultArray.removeLast()
//        }
        foundedWord.removeLast()
    }
    
    private func getCellsAround(cell: GameboardItem, exclude: [UsedLetter])->[GameboardItem] {
        var returnCells = [GameboardItem]()
        
        func appendIfPossible(cell: GameboardItem) {
            for item in exclude {
                if cell.col == item.col && cell.row == item.row {
                    return
                }
            }
            returnCells.append(cell)
        }
        if cell.col > 0 {
            appendIfPossible(cell: GV.gameArray[cell.col - 1][cell.row])
            if cell.row > 0 {
                appendIfPossible(cell: GV.gameArray[cell.col - 1][cell.row - 1])
            }
            if cell.row < gameSize - 1 {
                appendIfPossible(cell: GV.gameArray[cell.col - 1][cell.row + 1])
            }
        }
        if cell.col < gameSize - 1 {
            appendIfPossible(cell: GV.gameArray[cell.col + 1][cell.row])
            if cell.row > 0 {
                appendIfPossible(cell: GV.gameArray[cell.col + 1][cell.row - 1])
            }
            if cell.row < gameSize - 1 {
                appendIfPossible(cell: GV.gameArray[cell.col + 1][cell.row + 1])
            }
        }
        if cell.row > 0 {
            appendIfPossible(cell: GV.gameArray[cell.col][cell.row - 1])
        }
        if cell.row < gameSize - 1 {
            appendIfPossible(cell: GV.gameArray[cell.col][cell.row + 1])
        }
        
        return returnCells
    }
    
    private func fillGameArray(gameArray: [[GameboardItem]], content: String, toGrid: Grid) {
        let size = gameArray.count
        for (index, letter) in content.enumerated() {
            let col = index / size
            let row = index % size
            let cell = gameArray[col][row]
//            gameArray[col][row].position = toGrid.gridPosition(col: col, row: row)
            cell.position = toGrid.gridPosition(col: col, row: row)
            cell.name = "GBD/\(col)/\(row)"
            cell.col = col
            cell.row = row
            _ = cell.setLetter(letter: String(letter), toStatus: .Used, fontSize: GV.blockSize * 0.6)
            toGrid.addChild(cell)
        }
    }

    private func createNewGameArray(size: Int) -> [[GameboardItem]] {
        var gameArray: [[GameboardItem]] = []
        
        for i in 0..<size {
            gameArray.append( [GameboardItem]() )
            
            for j in 0..<size {
                gameArray[i].append( GameboardItem() )
                gameArray[i][j].letter = emptyLetter
            }
        }
        return gameArray
    }
    
    private func printWordCounters() {
        var counterTable = Array(repeating: Array(repeating: 0, count: 6), count: 4)
        let languageCode = ["hu": 0, "ru": 1, "de": 2, "en": 3]
        for language in ["hu", "ru", "de", "en"] {
            for size in 5...10 {
                let OKCounter = origGamesRewriteableRealm.objects(GameModel.self).filter("language = %d and gameSize = %d and OK = true", language, size).count
                counterTable[languageCode[language]!][size - 5] = OKCounter
            }
        }
        let huSum = counterTable[0][0] + counterTable[0][1] + counterTable[0][2] + counterTable[0][3] + counterTable[0][4] + counterTable[0][5]
        let ruSum = counterTable[1][0] + counterTable[1][1] + counterTable[1][2] + counterTable[1][3] + counterTable[1][4] + counterTable[1][5]
        let deSum = counterTable[2][0] + counterTable[2][1] + counterTable[2][2] + counterTable[2][3] + counterTable[2][4] + counterTable[2][5]
        let enSum = counterTable[3][0] + counterTable[3][1] + counterTable[3][2] + counterTable[3][3] + counterTable[3][4] + counterTable[3][5]
        print("Size    hu    ru    de    en   ")
        print("  5     \(counterTable[0][0])    \(counterTable[1][0])    \(counterTable[2][0])    \(counterTable[3][0])")
        print("  6     \(counterTable[0][1])    \(counterTable[1][1])    \(counterTable[2][1])    \(counterTable[3][1])")
        print("  7     \(counterTable[0][2])    \(counterTable[1][2])    \(counterTable[2][2])    \(counterTable[3][2])")
        print("  8     \(counterTable[0][3])    \(counterTable[1][3])    \(counterTable[2][3])    \(counterTable[3][3])")
        print("  9     \(counterTable[0][4])    \(counterTable[1][4])    \(counterTable[2][4])    \(counterTable[3][4])")
        print(" 10    \(counterTable[0][5])   \(counterTable[1][5])    \(counterTable[2][5])    \(counterTable[3][5])")
        print("All    \(huSum)   \(ruSum)   \(deSum)   \(enSum)")
    }



}
