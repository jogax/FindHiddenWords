//
//  AppDelegate.swift
//  TestGame
//
//  Created by Romhanyi Jozsef on 2020. 05. 09..
//  Copyright © 2020. Romhanyi Jozsef. All rights reserved.
//

import UIKit
import RealmSwift
import Reachability

let realm: Realm = try! Realm(configuration: Realm.Configuration.defaultConfiguration)

let newWordListConfig = Realm.Configuration(
fileURL: URL(string: Bundle.main.path(forResource: "NewWordList", ofType: "realm")!),
readOnly: true,
schemaVersion: 1,
objectTypes: [NewWordListModel.self])

//var newWordListRealm: Realm?

let newWordListRealm:Realm = try! Realm(configuration: newWordListConfig)

let origGamesConfig = Realm.Configuration(
fileURL: URL(string: Bundle.main.path(forResource: "Games", ofType: "realm")!),
readOnly: true,
schemaVersion: 1,
objectTypes: [Games.self])
var gamesRealm: Realm = try! Realm(configuration: origGamesConfig)


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var reachability: Reachability?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let config1 = Realm.Configuration(shouldCompactOnLaunch: { totalBytes, usedBytes in
            // totalBytes refers to the size of the file on disk in bytes (data + free space)
            // usedBytes refers to the number of bytes used by data in the file

            // Compact if the file is over 100MB in size and less than 50% 'used'
            let oneMB = 1024 * 1024
            return (totalBytes > oneMB) && (Double(usedBytes) / Double(totalBytes)) < 0.8
        })
//        print("hier")
        do {
            // Realm is compacted on the first open if the configuration block conditions were met.
            _ = try Realm(configuration: config1)
        } catch {
//            print("error")
            // handle error compacting or opening Realm
        }
        let config = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            //            schemaVersion: 3,
            schemaVersion: 1, // used since 2020-05-12
           // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                switch oldSchemaVersion {
//                        case 0...18:
//                            migration.deleteData(forType: GameDataModel.className())
//                            migration.deleteData(forType: RoundDataModel.className())
//                            migration.deleteData(forType: BasicDataModel.className())
//                case 19:
//                    migration.enumerateObjects(ofType: BasicDataModel.className()) { oldObject, newObject in
//                        newObject!["buttonType"] = GV.ButtonType
//                    }
                default: migration.enumerateObjects(ofType: BasicData.className())
                    { oldObject, newObject in
//                        newObject!["buttonType"] = GV.ButtonTypeSimple
                    }

                }
        },
            objectTypes: [BasicData.self/*, GameDataModel.self, RoundDataModel.self, , ScoreInfoForDifficulty.self, MyWords.self, FinishedGames.self, MyReportedWords.self, WordsFromCloud.self*/]
//            objectTypes: [WordListModel.self]
        )
        
        // Tell Realm to use this new configuration object for the default Realm
        Realm.Configuration.defaultConfiguration = config
//        loginToRealmSync()
        if reachability == nil {
            try! reachability = Reachability()
        }
        reachability!.whenReachable = { reachability in
            if reachability.connection == .wifi {
//                print("Reachable via WiFi")
            } else {
//                print("Reachable via Cellular")
            }
        }
        reachability!.whenUnreachable = { _ in
//            print("Not reachable")
        }
        
        do {
            try reachability!.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
//        generateNewDB()
        window = UIWindow(frame: UIScreen.main.bounds)
//        let homeViewController = GameViewController3D()
        let homeViewController = GameViewController()
//        homeViewController.view.backgroundColor = UIColor.red
        window!.rootViewController = homeViewController
        window!.makeKeyAndVisible()
        #if SIMULATOR
        GV.actDevice = DeviceType.getActDevice()
        if let rootWindow = window {
            GV.rootWindow = rootWindow
//            let iPhoneXSize = CGSize(width: 375, height: 812) /// if you're running this on an iPhone X, delete this line...
//            let iPhone8Size = CGSize(width: 375, height: 667) /// ...and uncomment this line
//            let screenSize = DeviceType.getActDevice().getSize()
            GV.actDevice = DeviceType.iPadMini
            let screenSize = GV.actDevice.getSize()
            Projector.display(rootWindow: rootWindow, testingSize: screenSize)
//            Projector.display(rootWindow: rootWindow, testingSize: iPhone8Size)
        }
        #endif

//        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        return true
    }
    
    @objc func rotated() {
//        if UIDevice.current.orientation.isPortrait {
//            GV.isPortrait = true
//        }
//        if UIDevice.current.orientation.isLandscape {
//            GV.isPortrait = false
//        }
//        setGlobalSizes()
        if GV.orientationHandler != nil && GV.target != nil {
                _ = GV.target!.perform(GV.orientationHandler!)
        }
    }
    
//    private func generateNewDB() {
//        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let gamesURL = documentsURL.appendingPathComponent("NewWordList.realm")
//        let config = Realm.Configuration(
//            fileURL: gamesURL,
//            schemaVersion: 1, // new item words
//            shouldCompactOnLaunch: { totalBytes, usedBytes in
//                // totalBytes refers to the size of the file on disk in bytes (data + free space)
//                // usedBytes refers to the number of bytes used by data in the file
//
//                // Compact if the file is over 100MB in size and less than 50% 'used'
//                let oneMB = 10 * 1024 * 1024
//                return (totalBytes > oneMB) && (Double(usedBytes) / Double(totalBytes)) < 0.8
//        },
//            objectTypes: [NewWordListModel.self])
//        do {
//            // Realm is compacted on the first open if the configuration block conditions were met.
//            _ = try Realm(configuration: config)
//        } catch {
//            print("error")
//            // handle error compacting or opening Realm
//        }
//        let newWordListRealm = try! Realm(configuration: config)
//        let newRecords = newWordListRealm.objects(NewWordListModel.self)
//        try! newWordListRealm.safeWrite() {
//            newWordListRealm.delete(newRecords)
//        }
//        let myWordList = realmWordList.objects(WordListModel.self)
//        let countRecords = myWordList.count
//        var countGeneratedRecords = 0
//        let myHints = realmHints.objects(HintModel.self)
//        for word in myWordList {
//            let newRecord = NewWordListModel()
//            newRecord.word = word.word
//            if myHints.filter("languageWord = %@", word.word).count > 0 {
//                newRecord.checked = true
//            }
//            countGeneratedRecords += 1
//            if countGeneratedRecords % 1000 == 0 {
//                print("Generated \(countGeneratedRecords) Records from \(countRecords) (\(((CGFloat(countGeneratedRecords) / CGFloat(countRecords)) * 100).nDecimals(n: 3)) %)")
//            }
//            try! newWordListRealm.safeWrite() {
//                newWordListRealm.add(newRecord)
//            }
//        }
//    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//        if playSearchingWordsScene != nil {
//            playSearchingWordsScene!.playingGame()
//        }
    }
}

