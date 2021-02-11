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
        origGamesRealm = getOrigGamesRealm()
        for actSize in 5...10 {
            gameSize = actSize
            for actLanguage in ["ru", "hu", "de", "en"] {
                language = actLanguage
                let origRecords = origGamesRealm.objects(GameModel.self).filter("primary beginswith %d and primary endswith %d", actLanguage, String(actSize)).sorted(byKeyPath: "gameNumber", ascending: true)
                for record in origRecords {
                    searchMoreWordsInRecord(record: record)
                }
            }
        }
    }
        
    var allWordsWithLength5_10 = newWordListRealm.objects(NewWordListModel.self).filter("word like %d or word like %d or word like %d or word like %d or word like %d or word like %d",
                                                                                        "???????",
                                                                                        "????????",
                                                                                        "?????????",
                                                                                        "??????????",
                                                                                        "???????????",
                                                                                        "????????????")
    
    private func searchMoreWordsInRecord(record: GameModel){
        let sizeMultiplier = GV.onIpad ? GV.sizeMultiplierIPad : GV.sizeMultiplierIPhone
        let blockSize = GV.minSide * sizeMultiplier[record.gameSize]
        GV.blockSize = blockSize
        GV.playingGrid = Grid(blockSize: blockSize * 1.1, rows: record.gameSize, cols: record.gameSize)
        GV.gameArray = createNewGameArray(size: record.gameSize)
        fillGameArray(gameArray: GV.gameArray, content:  record.gameArray, toGrid: GV.playingGrid!)
        var cellIndexes = [Int]()
        for ind in 0..<record.gameSize*record.gameSize {
            cellIndexes.append(ind)
        }
        repeat {
            let index = 0 //Int.random(in: 0..<cellIndexes.count)
            let actIndex = cellIndexes[index]
            let col = actIndex / record.gameSize
            let row = actIndex % record.gameSize
            let workingCell = GV.gameArray[col][row]
            searchWordForCell(cell: workingCell)
            cellIndexes.remove(at: index)
        } while cellIndexes.count > 0
    }

    private func searchWordForCell(cell:GameboardItem) {
        var foundedWord = UsedWord()
        foundedWord.append(UsedLetter(col: cell.col, row: cell.row, letter: cell.letter))
        let cellsAround = getCellsAround(cell: cell, exclude: foundedWord.usedLetters)
        for secondCell in cellsAround {
            let possibleWords2 = allWordsWithLength5_10.filter("word beginswith %d", (language + cell.letter + secondCell.letter).lowercased())
            if possibleWords2.count > 0 {
                foundedWord.append(UsedLetter(col: secondCell.col, row: secondCell.row, letter: secondCell.letter))
                for myWord in possibleWords2 {
                    let cellsAroundSecond = getCellsAround(cell: secondCell, exclude: foundedWord.usedLetters)
                    for thirdCell in cellsAroundSecond {
                        let possibleWords3 = possibleWords2.filter("word beginswith %d", (language + cell.letter + secondCell.letter + thirdCell.letter).lowercased())
                        if possibleWords3.count > 0 {
                            foundedWord.append(UsedLetter(col: thirdCell.col, row: thirdCell.row, letter: thirdCell.letter))
                            print("word OK: \(foundedWord)")
                        }
                    }
                }
                if foundedWord.count == 2 {
                    foundedWord.removeLast()
                }
            }
        }
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
