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
    public func findNewMandatoryWords() {
        origGamesRealm = getOrigGamesRealm()
        for actSize in 5...10 {
            for actLanguage in ["ru", "hu", "de", "en"] {
                let origRecords = origGamesRealm.objects(GameModel.self).filter("primary beginswith %d and primary endswith %d", actLanguage, String(actSize)).sorted(byKeyPath: "gameNumber", ascending: true)
                for record in origRecords {
                    searchMoreWordsInRecord(record: record)
                }
            }
        }
    }
        
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
            let index = Int.random(in: 0..<cellIndexes.count)
            let actIndex = cellIndexes[index]
            let col = actIndex / record.gameSize
            let row = actIndex % record.gameSize
            let workingCell = GV.gameArray[col][row]
            searchWordForCell(cell: workingCell)
            cellIndexes.remove(at: index)
        } while cellIndexes.count > 0
    }
    
    private func searchWordForCell(cell:GameboardItem) {
        print("col: \(cell.col), row: \(cell.row), letter: \(cell.letter)")
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
