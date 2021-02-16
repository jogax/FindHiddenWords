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

public var origGamesRealm: Realm!

public func getOrigGamesRealm()->Realm {
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

class AddNewWordsToOrigRecord {
    var gameSize = 0
    var language = ""
    public func findNewMandatoryWords() {
        AW.addNewWordsRunning = true
        origGamesRealm = getOrigGamesRealm()
        checkOrigRecords()
        for actSize in 5...10 {
            gameSize = 15 - actSize
            for actLanguage in ["hu", "ru", "de", "en"] {
                language = actLanguage
                let origRecords = origGamesRealm.objects(GameModel.self).filter("primary beginswith %d and primary endswith %d and OK = false", actLanguage, String(gameSize)).sorted(byKeyPath: "gameNumber", ascending: true)
                AW.addingWordData = AddingWordData()
                for record in origRecords {
                    try! origGamesRealm.safeWrite {
                        origGamesRealm.delete(record.myDemos)
                    }
                    workingRecord = record
                    let finishedRecords = origGamesRealm.objects(GameModel.self).filter("OK = true")
                    let finishedProLanguage = origGamesRealm.objects(GameModel.self).filter("OK = true and language = %d", language)
                    AW.addingWordData.countFinishedRecords = finishedRecords.count
                    AW.addingWordData.language = language
                    AW.addingWordData.finishedProLanguage = finishedProLanguage.count
                    AW.addingWordData.gameSize = gameSize
                    AW.addingWordData.language = actLanguage
                    AW.addingWordData.gameNumber = record.gameNumber
                    print("Start searching in new record: Size: \(gameSize), Language: \(actLanguage), countFinishedRecords: \(finishedRecords.count)")
                    searchMoreWordsInRecord()
                }
            }
        }
    }
    
    private func checkOrigRecords() {
        let finishedRecords = origGamesRealm.objects(GameModel.self).filter("OK = true")
        for record in finishedRecords {
            for item in record.myDemos {
                if !checkFoundedWordOK(foundedWord: item.getUsedWord()) {
                    print("this record must be deleted: \(item.usedLetters)")
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
        try! origGamesRealm.safeWrite {
            let usedTime = Date().timeIntervalSince(startTime)
            workingRecord.OK = true
            AW.addingWordData.countFoundedWords = workingRecord.myDemos.count
            print("Search ended for game \(workingRecord.gameNumber), found \(workingRecord.myDemos.count) records in \(usedTime) seconds")
        }
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
                    try! origGamesRealm.safeWrite {
                        workingRecord.myDemos.append(FoundedWords(fromUsedWord: foundedWord, actRealm: origGamesRealm))
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
