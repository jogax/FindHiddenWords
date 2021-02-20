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

private func getOriginalGamesRealm()->Realm {
    let origGamesConfig = Realm.Configuration(
        fileURL: URL(string: Bundle.main.path(forResource: "OrigGames", ofType: "realm")!),
    readOnly: true,
    schemaVersion: 1,
        objectTypes: [GameModel.self, FoundedWords.self])
    let realm = try! Realm(configuration: origGamesConfig)
    return realm
}

class AddNewWordsToOrigRecord {
    var origGamesRewriteableRealm: Realm!
    var gameSize = 0
    var language = ""
    public func findNewMandatoryWords() {
        AW.addNewWordsRunning = true

        origGamesRewriteableRealm = getOrigGamesRewriteableRealm()
        checkOrigRecords()
        var continueSize =  0
        var continueLanguage = ""
        let continueRecord = origGamesRewriteableRealm.objects(GameModel.self).filter("OK = false")
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
//                        print("Start searching in new record: Size: \(gameSize), Language: \(actLanguage), countFinishedRecords: \(finishedRecords.count)")
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
        let finishedRecords = origGamesRewriteableRealm.objects(GameModel.self).filter("OK = true")
        for record in finishedRecords {
            for item in record.myDemos {
                if !checkFoundedWordOK(foundedWord: item.getUsedWord()) {
                    print("this record must be deleted: \(item.usedLetters)")
                    try! origGamesRewriteableRealm.safeWrite {
                        origGamesRewriteableRealm!.delete(item)
                    }
                }
            }
        }
    }
    private func checkFoundedWordOK(foundedWord: UsedWord)->Bool {
        let letters = foundedWord.usedLetters
        for (index, usedLetter) in letters.enumerated() {
            if index < letters.count - 1 {
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
            recursionWithCells(cell: workingCell)
            AW.addingWordData.callIndexesLeft = cellIndexes.count
            cellIndexes.remove(at: index)
        } while cellIndexes.count > 0
        try! origGamesRewriteableRealm.safeWrite {
            workingRecord.OK = true
            AW.addingWordData.countFoundedWords = workingRecord.myDemos.count
        }
        let usedTime = Date().timeIntervalSince(startTime)
        let finishedCunt = origGamesRewriteableRealm!.objects(GameModel.self).filter("OK = true").count
        let finishedProLanguage = origGamesRewriteableRealm.objects(GameModel.self).filter("OK = true and language = %d and gameSize = %d", language, gameSize).count
        print("\(finishedCunt) for language: \(language), size: \(gameSize), finished: \(finishedProLanguage) found: \(workingRecord.myDemos.count) words in \(usedTime.twoDecimals) seconds")
    }
    var foundedWord = UsedWord()

    private func recursionWithCells(cell:GameboardItem) {
        if AW.stopSearching {
            AW.stopSearching = false
            AW.addNewWordsRunning = false
        }
        let cellsAround = getCellsAround(cell: cell, exclude: foundedWord.usedLetters)
        for secondCell in cellsAround {
            foundedWord.append(UsedLetter(col: secondCell.col, row: secondCell.row, letter: secondCell.letter))
            let possibleWords = allCheckedWords.filter("word beginswith %d", (language + foundedWord.word).lowercased())
            if possibleWords.count == 1 && possibleWords[0].word.endingSubString(at: 2) == foundedWord.word.lowercased() {
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
            } else if possibleWords.count > 0 {
                recursionWithCells(cell: secondCell)
            } else {
               foundedWord.removeLast()
            }
        }
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



}
