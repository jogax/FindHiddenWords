//
//  MyFunctions.swift
//  DuelOfWords
//
//  Created by Romhanyi Jozsef on 2020. 05. 07..
//  Copyright © 2020. Romhanyi Jozsef. All rights reserved.
//

import Foundation
import AVFoundation
import Realm
import RealmSwift
import UIKit
import GameplayKit
import Reachability


func + (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width + right.width, height: left.height + right.height)
}

func - (left: CGSize, right: CGSize) -> CGSize {
    return CGSize(width: left.width - right.width, height: left.height - right.height)
}

func * (size: CGSize, scalar: CGFloat) -> CGSize {
    return CGSize(width: size.width * scalar, height: size.height * scalar)
}

func * (size: CGSize, multiplier: CGSize) -> CGSize {
    return CGSize(width: size.width * multiplier.width, height: size.height * multiplier.height)
}

func / (point: CGSize, scalar: CGFloat) -> CGSize {
    return CGSize(width: point.width / scalar, height: point.height / scalar)
}



func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func - (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x - right.x, y: left.y - right.y)
}

func * (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x * scalar, y: point.y * scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / scalar, y: point.y / scalar)
}

func getLocalDate()->Date {
    let UTCDate = Date()
    return UTCDate + TimeInterval(NSTimeZone.system.secondsFromGMT(for: UTCDate))
}

public func printFontNames() {
    let familyNames = UIFont.familyNames
    for family in familyNames {
    print("Family name " + family)
    let fontNames = UIFont.fontNames(forFamilyName: family)
    for font in fontNames {
    print("    Font name: " + font)
        }
    }
}

public func printGameArray() {
    let line = "____________________________________________"
    for row in 0..<GV.basicData.gameSize {
        var infoLine = "|"
        for col in 0..<GV.basicData.gameSize {
            let char = GV.gameArray[col][row].letter
            infoLine += " " + (char == "" ? " " : char) + " " + "|"
        }
        print(infoLine)
    }
    print(line)
}

public func printGameArray3D() {
    for gameIndex in 0..<6 {
        print("-------- cube side: \(gameIndex + 1) ------- ")
        print()
        for row in 0..<GV.basicData.gameSize {
            var infoLine = "|"
            for col in 0..<GV.basicData.gameSize {
                let char = GV.gameArray3D[gameIndex][col][row].letter
                infoLine += " " + (char == "" ? " " : char) + " " + "|"
            }
            print(infoLine)
        }
        print()
    }
    let line = "-------- all sides printed --------"
    print(line)
}

public func printConnectios() {
    let line = "____________________________________________"
    print(line)
    for row in 0..<GV.basicData.gameSize {
        var infoLine = "|"
        for col in 0..<GV.basicData.gameSize {
            let char = String(GV.gameArray[col][row].connectionType.toString())
            infoLine += " " + char + " " + "|"
        }
        print(infoLine)
    }
    print(line)
}

public func printChecked() {
    let line = "____________________________________________"
    print(line)
    for row in 0..<GV.basicData.gameSize {
        var infoLine = "|"
        for col in 0..<GV.basicData.gameSize {
            let char = String(GV.gameArray[col][row].checked ? "#" : " ")
            infoLine += " " + (char == "" ? " " : char) + " " + "|"
        }
        print(infoLine)
    }
    print(line)
}

public func getOrigGamesRealm()->Realm {
    let origGamesConfig = Realm.Configuration(
        fileURL: URL(string: Bundle.main.path(forResource: "OrigGames", ofType: "realm")!),
    readOnly: true,
    schemaVersion: 1,
        objectTypes: [GameModel.self, FoundedWords.self])
    let realm = try! Realm(configuration: origGamesConfig)
    return realm
}

public func getPlayedGamesRealm()->Realm {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let gamesURL = documentsURL.appendingPathComponent("PlayedGames.realm")
    let origGamesConfig = Realm.Configuration(
        fileURL: gamesURL,
        schemaVersion: 7,
        objectTypes: [GameModel.self, FoundedWords.self])
    let realm = try! Realm(configuration: origGamesConfig)
    return realm
}

public func updateOrigGamesRealm()->Realm {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let gamesURL = documentsURL.appendingPathComponent("OrigGames.realm")
    let origGamesConfig = Realm.Configuration(
        fileURL: gamesURL,
        schemaVersion: 2,
//        migrationBlock: { migration, oldSchemaVersion in
//                migration.enumerateObjects(ofType: GameModel.className())
//                { oldObject, newObject in
//
//                }
//        },
        objectTypes: [GameModel.self, FoundedWords.self])
    let realm = try! Realm(configuration: origGamesConfig)
    return realm
}



//public  func getRealm(type: RealmType)->Realm {
//    let shemaVersion: UInt64 = type == .PlayedGameRealm ? 6 : 4
//    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//    let gamesURL = documentsURL.appendingPathComponent(type == .GamesRealm ? "OrigGames.realm" : "OrigGames.realm")
//    let config = Realm.Configuration(
//        fileURL: gamesURL,
//        schemaVersion: shemaVersion,
//        migrationBlock: { migration, oldSchemaVersion in
//            switch (type, oldSchemaVersion) {
//            case (.PlayedGameRealm, _):
//                migration.enumerateObjects(ofType: PlayedGame.className())
//                { oldObject, newObject in
////                        newObject!["buttonType"] = GV.ButtonTypeSimple
//                }
//            case (.GamesRealm, _):
//                migration.enumerateObjects(ofType: Games.className())
//                { oldObject, newObject in
////                        newObject!["buttonType"] = GV.ButtonTypeSimple
//                }
//            }
//        },
//        shouldCompactOnLaunch: { totalBytes, usedBytes in
//            // totalBytes refers to the size of the file on disk in bytes (data + free space)
//            // usedBytes refers to the number of bytes used by data in the file
//
//            // Compact if the file is over 100MB in size and less than 50% 'used'
//            let oneMB = 10 * 1024 * 1024
//            return (totalBytes > oneMB) && (Double(usedBytes) / Double(totalBytes)) < 0.8
//    },
//        objectTypes: [(type == .GamesRealm ? Games.self : PlayedGame.self), FoundedWords.self])
//    do {
//        // Realm is compacted on the first open if the configuration block conditions were met.
//        _ = try Realm(configuration: config)
//    } catch {
//        print("error")
//        // handle error compacting or opening Realm
//    }
//
//    let realm = try! Realm(configuration: config)
//    return realm
//}

public func getGames()->Realm? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let gamesURL = documentsURL.appendingPathComponent("OrigGames.realm")
        let config = Realm.Configuration(
            fileURL: gamesURL,
            schemaVersion: 4,
            migrationBlock: { migration, oldSchemaVersion in
                    migration.enumerateObjects(ofType: Games.className())
                    { oldObject, newObject in
    //                        newObject!["buttonType"] = GV.ButtonTypeSimple
                    }
                },
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

        let realm = try! Realm(configuration: config)
        return realm
}

public func getNewWordList()->Realm? {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let gamesURL = documentsURL.appendingPathComponent("WordList.realm")
        let config = Realm.Configuration(
            fileURL: gamesURL,
            schemaVersion: 3,
            migrationBlock: { migration, oldSchemaVersion in
                    migration.enumerateObjects(ofType: Games.className())
                    { oldObject, newObject in
    //                        newObject!["buttonType"] = GV.ButtonTypeSimple
                    }
                },
            shouldCompactOnLaunch: { totalBytes, usedBytes in
                // totalBytes refers to the size of the file on disk in bytes (data + free space)
                // usedBytes refers to the number of bytes used by data in the file

                // Compact if the file is over 100MB in size and less than 50% 'used'
                let oneMB = 10 * 1024 * 1024
                return (totalBytes > oneMB) && (Double(usedBytes) / Double(totalBytes)) < 0.8
        },
            objectTypes: [NewWordListModel.self])
        do {
            // Realm is compacted on the first open if the configuration block conditions were met.
            _ = try Realm(configuration: config)
        } catch {
            print("error")
            // handle error compacting or opening Realm
        }

        let realm = try! Realm(configuration: config)
        return realm
}


//public func setGlobalSizes() {
//    print("UIDevice sizes: \(UIScreen.main.bounds)")
//    #if SIMULATOR
//    GV.actWidth = GV.actDevice.getSize().width
//    GV.actHeight = GV.actDevice.getSize().height
//    #else
//    if getDeviceOrientation() == .Landscape {
//        GV.actWidth = GV.maxSide
//        GV.actHeight = GV.minSide
//    } else {
//        GV.actWidth = GV.minSide
//        GV.actHeight = GV.maxSide
//    }
//    #endif
////    GV.minSide = min(GV.actWidth, GV.actHeight)
////    GV.maxSide = max(GV.actWidth, GV.actHeight)
//}

public func getAllUsedLetters()->[String:[UsedLetter]] {
    let size = GV.gameArray.count
    var returnValue = [String:[UsedLetter]]()
    let myLetters = GV.language.getText(.tcAlphabet)
    for letter in myLetters {
        returnValue[String(letter)] = [UsedLetter]()
    }
    for col in 0..<size {
        for row in 0..<size {
            if GV.gameArray[col][row].status == .Used /* || GV.gameArray[col][row].fixItem */ {
                let actLetter = UsedLetter(col: col, row: row, letter: GV.gameArray[col][row].letter)
                returnValue[GV.gameArray[col][row].letter]?.append(actLetter)
            }
        }
    }
    return returnValue
}

let backgroundName = "backgroundName"
public func setBackground(to: SKScene) {
    removeChildrenWithTypes(from: to, types: [.Background])
    var myBackground: SKSpriteNode!
//    var origImage: UIImage!
    let myTexture: SKTexture!
    switch getDeviceOrientation() {
    case .Portrait: myTexture = SKTexture(imageNamed: "PortraitBG")
    case .Landscape: myTexture = SKTexture(imageNamed: "LandscapeBG")
    }
    myBackground = SKSpriteNode(texture: myTexture, color: .clear, size: to.size)
    myBackground.position = CGPoint(x: to.frame.width / 2, y: to.frame.height / 2)
    myBackground.zPosition = -10
    myBackground.myType = .Background
    to.addChild(myBackground)

}

public enum MyDeviceOrientation: Int {
    case Portrait = 0, Landscape //PortraitUpsideDown, LandscapeLeft, LandscapeRight
}

public func getDeviceOrientation() -> MyDeviceOrientation {
    return GV.actHeight > GV.actWidth ? .Portrait : .Landscape
        
//    if #available(iOS 13.0, *) {
//        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return .Portrait}
//        switch windowScene.interfaceOrientation {
//        case .unknown:
//            return .Portrait
//
//        case .portrait:
//            return .Portrait
//
////        case .portraitUpsideDown:
////            return .PortraitUpsideDown
//
//        case .landscapeLeft:
//            return .Landscape
//
//        case .landscapeRight:
//            return .Landscape
//
//        default:
//            return .Portrait
//        }
//
//    } else {
//        let orientation =  UIApplication.shared.statusBarOrientation
//        switch orientation {
//        case .portrait:
//            return .Portrait
//        case .portraitUpsideDown:
//            return .Portrait
//        case .landscapeLeft:
//            return .Landscape
//        case .landscapeRight:
//            return .Landscape
//        case .unknown:
//            return .Portrait
//        @unknown default:
//            return .Portrait
//        }
//    }

}


public func removeChildrenWithNames(from: SKNode, names: [Int:String]) {
    for name in names {
        if let node = from.childNode(withName: name.value) {
            node.removeFromParent()
        }
    }
}

func removeChildrenWithTypes(from: SKNode, types: [SKNodeSubclassType]) {
    for child in from.children {
        if child.myType != nil {
            if types.contains(child.myType!) {
                child.removeAllStoredPropertys()
                child.removeFromParent()
            }
        }
    }
}

func removeChildrenExceptTypes(from: SKNode, types: [SKNodeSubclassType]) {
    for child in from.children {
        if child.myType != nil {
            if !types.contains(child.myType!) {
                child.removeAllStoredPropertys()
                child.removeFromParent()
            }
        }
    }
}


//public func setPosItionsAndSizesOfNodesWithActNames(layer: SKNode, frames: [CGRect], actNames: [Int: String]) {
//    for index in 0..<actNames.count {
//        if let name = actNames[index] {
//            let buttonName = name.contains("Button")
//            let labelName = name.contains("Label")
//            let gridName = name.contains("Grid")
//            if let node = layer.childNode(withName: name) {
//                switch (buttonName, labelName, gridName) {
//                case (true, false, false):
//                    (node as! MyButton).size = frames[index].size
//                    (node as! MyButton).position = frames[index].origin
//                case (false, true, false):
//                    (node as! MyLabel).position = frames[index].origin
//                case (false, false, true):
//                    (node as! Grid).size = frames[index].size
//                    (node as! Grid).position = frames[index].origin
//                default:
//                    break
//                }
//            }
//        }
//    }
//}


public func generateNewRealm(oldRealmName: String, newRealmName: String) {
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
    let oldRealmURL = documentsURL.appendingPathComponent(oldRealmName)
    let oldConfig = Realm.Configuration(
        fileURL: oldRealmURL,
        schemaVersion: 4,
        shouldCompactOnLaunch: { totalBytes, usedBytes in
            let oneMB = 10 * 1024 * 1024
            return (totalBytes > oneMB) && (Double(usedBytes) / Double(totalBytes)) < 0.8
        },
        objectTypes: [NewWordListModel.self, Games.self])
    let newRealmURL = documentsURL.appendingPathComponent(newRealmName)
    let newConfig = Realm.Configuration(
        fileURL: newRealmURL,
        schemaVersion: 1,
        shouldCompactOnLaunch: { totalBytes, usedBytes in
            let oneMB = 10 * 1024 * 1024
            return (totalBytes > oneMB) && (Double(usedBytes) / Double(totalBytes)) < 0.8
        },
        objectTypes: [NewWordListModel.self, Games.self])
    let oldRealm = try! Realm(configuration: oldConfig)
    let newRealm = try! Realm(configuration: newConfig)
    let origData = oldRealm.objects(Games.self)
    if origData.count > 0 {
        print("origData.count: \(origData.count)")
        var countRecords = 0
        for record in origData {
            let newRecord = Games()
            newRecord.errorCount = 0
            newRecord.gameArray = record.gameArray
            newRecord.gameNumber = record.gameNumber
            newRecord.language = record.language
            newRecord.OK = record.OK
            newRecord.primary = record.primary
            newRecord.size = record.size
            newRecord.timeStamp = record.timeStamp
            newRecord.words = record.words
            try! newRealm.safeWrite {
                newRealm.add(newRecord)
            }
            countRecords += 1
            if countRecords % 1000 == 0 {
                print("countRecords: \(countRecords)")
            }
        }
    }
}

public func startReachability() {
    if GV.reachability == nil {
        try! GV.reachability = Reachability()
    }
    GV.reachability!.whenReachable = { reachability in
        if reachability.connection == .wifi {
            print("Reachable via WiFi")
        } else {
            print("Reachable via Cellular")
        }
    }
    GV.reachability!.whenUnreachable = { _ in
        print("Not reachable")
    }
    
    do {
        try GV.reachability!.startNotifier()
    } catch {
        print("Unable to start notifier")
    }

}
public func getBasicData() {
    if realm.objects(BasicData.self).count == 0 {
        GV.basicData = BasicData()
        GV.basicData.actLanguage = GV.language.getText(.tcAktLanguage)
        GV.basicData.creationTime = Date()
        GV.basicData.deviceType = UIDevice().getModelCode()
        GV.basicData.land = GV.convertLocaleToInt()
        GV.basicData.lastPlayingDay = Date().yearMonthDay
        GV.basicData.gameSize = 8
        
        for size in 0...10 {
            GV.basicData.worldMaxScores.append(MaxScores(newSize: size, type: .GameCenter))
            GV.basicData.deviceMaxScores.append(MaxScores(newSize: size, type: .Device))
        }

        try! realm.safeWrite() {
            realm.add(GV.basicData)
        }
    } else {
        GV.basicData = realm.objects(BasicData.self).first!
//        GV.maxScoresProLanguageAndSize = MaxScoresProLanguageAndSize(initValue: GV.basicData.localMaxScores)
        GV.language.setLanguage(GV.basicData.actLanguage)
        try! realm.safeWrite() {
            GV.basicData.deviceType = UIDevice().getModelCode()
            GV.basicData.land = GV.convertLocaleToInt()
        }
        if Date().yearMonthDay != GV.basicData.lastPlayingDay {
            try! realm.safeWrite() {
                GV.basicData.lastPlayingDay = Date().yearMonthDay
                GV.basicData.playingTimeToday = 0
                GV.basicData.countPlaysToday = 0
            }
        }
    }

}

