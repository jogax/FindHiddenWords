//
//  MyGlobals.swift
//  DuelOfWords
//
//  Created by Romhanyi Jozsef on 2020. 05. 07..
//  Copyright © 2020. Romhanyi Jozsef. All rights reserved.
//


import Foundation
import AVFoundation
import UIKit
import RealmSwift
import GameKit
import Reachability

let actVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String

private var codeTableToString: [Int: String]  = [65: "A", 66: "B", 67: "C", 68: "D", 69: "E", 70: "F", 71: "G", 72: "H", 73: "I", 74: "J",
                                         75: "K", 76: "L", 77: "M", 78: "N", 79: "O", 80: "P", 81: "Q", 82: "R", 83: "S", 84: "T",
                                         85: "U", 86: "V", 87: "W", 88: "X", 89: "Y", 90: "Z"]
private var codeTableToInt: [String: Int]  = ["A": 65, "B": 66, "C": 67, "D": 68, "E": 69, "F": 70, "G": 71, "H": 72, "I": 73, "J": 74,
                                      "K": 75, "L": 76, "M": 77, "N": 78, "O": 79, "P": 80, "Q": 81, "R": 82, "S": 83, "T": 84,
                                      "U": 85, "V": 86, "W": 87, "X": 88, "Y": 89, "Z": 90]

let ConnectionName = "Connection"

public enum RealmType: Int {
    case GamesRealm, PlayedGameRealm
}

public enum TouchType: Int {
    case Began = 0, Moved, Ended
}


public enum GradientDirection {
    case Up
    case Left
    case UpLeft
    case UpRight
}

// for GameCenter GlobalData
struct PlayerData {
    var alias = ""
    var isOnline = false
    var allTime = 0
    var lastDay = 0
    var lastTime = 0
    var device = ""
    var version = ""
    var land = ""
    var easyBestScore: Int64 = 0
    var mediumBestScore: Int64 = 0
    var easyActScore = ""
    var mediumActScore = ""
    var countPlays = ""
}
enum ScoreType: Int {
    case X5 = 0, X6, X7, X8, X9, X10, WordCount
}
enum TimeScope: Int {
    case All = 0, Week, Today
}


struct ScoreForShow {
    var scoreType: ScoreType = ScoreType.WordCount
    var timeScope: TimeScope = TimeScope.Today
    var place = 0
    var player = ""
    var score = 0
    var me = false
    init (scoreType: ScoreType, timeScope: TimeScope, place: Int, player: String, score: Int, me: Bool) {
        self.scoreType = scoreType
        self.timeScope = timeScope
        self.place = place
        self.player = player
        self.score = score
        self.me = me
    }
}


func == (left: MyDate, right: MyDate) -> Bool {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day &&
        left.hour == right.hour &&
        abs(left.minute - right.minute) < 11
}

struct MyDate {
    let year: Int
    let month: Int
    let day: Int
    let hour: Int
    let minute: Int
    let second: Int
    init(date: Date) {
        let calendar = Calendar.current
        let actComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
        year = actComponents.year!
        month = actComponents.month!
        day = actComponents.day!
        hour = actComponents.hour!
        minute = actComponents.minute!
        second = actComponents.second!
    }
    func datum()->Int {
        return year * 10000 + month * 100 + day
    }
}


struct GV {
    static var actLanguage: String {
        get {
            return GV.language.getText(.tcAktLanguage)
        }
    }
//    static var size: Int = 0
    static var justStarted = true
    static var oldSize: Int = 0
    static var gameArray = [[GameboardItem]]()
    static var reachability: Reachability!
    static var playingGrid: Grid?
    static var globalInfoTable = [PlayerData]()
    static var gameArray3D = [[[GameboardItem]]]()
    static var scoreForShowTable = [ScoreForShow]()
    static var scoreTable = [Int]()
    static var mainView: UIViewController?
    static let language = Language()
    static var basicData = BasicData()
    static var gameNumber = 0
    static var games = Games()
    static var blockSize = CGFloat(0)
    static var parentScene = SKScene()
    static var buttonFontSize: CGFloat = GV.onIpad ? 18 : 15
    static var innerSeparator = "°"
    static var outerSeparator = "/"
    static let onIpad = UIDevice.current.model.hasSuffix("iPad")
    static let PieceFont = "HelveticaNeue-Light"
    static var deviceOrientation: MyDeviceOrientation!
    static var actWidth = CGFloat(0)
    static var actHeight = CGFloat(09)
    static var minSide = CGFloat(0)
    static var maxSide = CGFloat(0)
    static var target: AnyObject?
    static let questionMark = "?"
    static let mandatoryLabelInName = "Mandatory-Label"
    static let ownLabelInName = "Own-Label"
    static let headerFontName = "Menlo-Bold"
    static let wordsFontSize: CGFloat = GV.onIpad ? 18 : 15
    static let darkGreen = UIColor(red: 11/255, green: 151/255, blue: 6/255, alpha: 1)
    static var touchTarget: AnyObject!
    static var touchSelector: Selector!
    static var touchParam1: Set<UITouch>!
    static var touchParam2: UIEvent?
    static var touchType: TouchType?
    static var connectedToInternet = false
    static let TimeModifier: Int64 = 10000000000
    static let myGCName = "RJogax"
    static var playSearchingWordsScene: PlaySearchingWords?
    static let sizeMultiplierIPhone: [CGFloat] = [0, 0, 0, 0, 0, 0.13, 0.11, 0.095, 0.09, 0.085, 0.08]
    static let sizeMultiplierIPad:   [CGFloat] = [0, 0, 0, 0, 0, 0.1, 0.095, 0.09, 0.08, 0.075, 0.07]
//    static var maxScore = MaxScoresProLanguageAndSize()

    static var orientationHandler: Selector?
    #if SIMULATOR
    static var actDevice: DeviceType = .iPhoneSE1
    #endif
    static var rootWindow: UIWindow = UIWindow()
    static var actPieceFont: String {
        get {
            return PieceFont
        }
    }
    static let fontName = "TimesNewRomanPS-BoldMT"
    static var actFont: String {
        get {
            return fontName
        }
    }

    static func convertIntToLocale(value: Int)->String {
        let landInt = value / 10000
        let languageInt = value % 10000
        let returnValue =
            codeTableToString[landInt / 100]! +
            codeTableToString[landInt % 100]! +
            "/" +
            codeTableToString[languageInt / 100]!.lowercased() +
            codeTableToString[languageInt % 100]!.lowercased()
        return returnValue
    }
    
    static func convertNowToMyDate()->MyDate {
        let returnValue = MyDate(date: Date())
        return returnValue
    }
    
    static func getTimeIntervalSince20190101(date: Date = Date())->Int {
        var dateComponents = DateComponents()
        dateComponents.year = 2019
        dateComponents.month = 1
        dateComponents.day = 1
        //        dateComponents.timeZone = TimeZone(abbreviation: "JST") // Japan Standard Time
        let userCalendar = Calendar.current // user calendar
        let someDateTime = userCalendar.date(from: dateComponents)
        let now = date
        let returnValue = now.timeIntervalSince(someDateTime!)
        return Int(returnValue)
    }
    


    static func convertLocaleToInt()->Int {
        var actLocale = "EN"
        if Locale.current.regionCode != nil {
            actLocale = Locale.current.regionCode!
        }
        let language = actLanguage.uppercased()
        let letter1 = actLocale.subString(at:0, length: 1)
        let letter2 = actLocale.subString(at:1, length: 1)
        let letter3 = language.subString(at:0, length: 1)
        let letter4 = language.subString(at:1, length: 1)
        let value = 10000 * (codeTableToInt[letter1]! * 100 + codeTableToInt[letter2]!) + codeTableToInt[letter3]! * 100 + codeTableToInt[letter4]!
        return value
    }
    
    static func radian(_ grad: CGFloat)->CGFloat {
        return grad * CGFloat(Double.pi) / 180
    }

    static func getDateFromInterval(interval: Int)->MyDate {
        var dateComponents = DateComponents()
        dateComponents.year = 2019
        dateComponents.month = 1
        dateComponents.day = 1
        let userCalendar = Calendar.current // user calendar
        let referenceDate = userCalendar.date(from: dateComponents)
        let date = Date(timeInterval: Double(interval), since: referenceDate!)
        let returnValue = MyDate(date: date)
        return returnValue
    }
    
    static var screenWidth: CGFloat {
        if UIWindow.isLandscape {
            return UIScreen.main.bounds.size.height
        } else {
            return UIScreen.main.bounds.size.width
        }
    }
    static var screenHeight: CGFloat {
        if UIWindow.isLandscape {
            return UIScreen.main.bounds.size.width
        } else {
            return UIScreen.main.bounds.size.height
        }
    }

//    static var myUser: SyncUser? = nil {
//        willSet(newValue) {
//            for callBack in callBackMyUser {
//                callBack.callBackFunc()
//            }
//        }
//    }
//    static var expertUser = false {
//        didSet(newValue) {
//            for callBack in callBackExpertUser {
//                callBack.callBackFunc()
//            }
//        }
//    }
    struct CallBackStruct {
        var myCaller:String
        var callBackFunc: ()->()
        init(caller: String, callBackFunction: @escaping ()->()) {
            myCaller = caller
            callBackFunc = callBackFunction
        }
    }
    static var callBackExpertUser: Array<CallBackStruct> = []
    static var callBackMyUser: Array<CallBackStruct> = []



//    RealmSync Constants
//    static let MY_INSTANCE_ADDRESS = "magic-of-words.us1.cloud.realm.io" // <- update this
//
//    static let AUTH_URL  = URL(string: "https://\(MY_INSTANCE_ADDRESS)")!
////    static let REALM_URL = URL(string: "realms://\(MY_INSTANCE_ADDRESS)/MagicOfWords")!
//    static let REALM_URL = URL(string: "realms://\(MY_INSTANCE_ADDRESS)/MagicOfWordsTest1")!
//    static let NEW_REALM_URL = URL(string: "realms://\(MY_INSTANCE_ADDRESS)/MagicOfWordsRealm")!

}
var timer = [Date]()
public func setFirstTime()->Int {
    let time = Date()
    timer.append(time)
    return timer.count - 1
}

public func showTime(num: Int, string: String) {
    let date = Date()
    print("time at \(string): \((date.timeIntervalSince(timer[num]) * 1000).nDecimals(10))")
    timer[num] = Date()
}

public func getTimeInterval(num: Int)->Double {
    return Date().timeIntervalSince(timer[num])
}

public func stopTime() {
    timer.removeLast()
}

#if SIMULATOR
enum DeviceType {
   
    //MARK: - iPhones
    /**
    iPhone 5, iPhone 5S, iPhone 5C, iPhone SE 1st gen
    */
    case iPhoneSE1

    /**
    iPhone 6, iPhone 6S, iPhone 7, iPhone 8, iPhone SE 2nd gen
    */
    case iPhoneSE2
    /**
    iPhone 6 Plus, iPhone 6S Plus, iPhone 7 Plus, iPhone 8 Plus
    */
    case iPhone8Plus

    /**
    iPhone X, iPhone XS, iPhone 11 Pro
    */
    case iPhoneX

    /**
    iPhone XR, iPhone 11
    */
    case iPhone11
    /**
    iPhone XS Max, iPhone 11 Pro Max
    */
    case iPhone11ProMax

    //MARK: - iPads

    /**
    iPad Mini 2nd, 3rd, 4th and 5th Generation
    */
    case iPadMini

    /**
    iPad 3rd, iPad 4th, iPad Air 1st, iPad Air 2nd, iPad Pro 9.7-inch, iPad 5th, iPad 6th Generation
    */
    case iPad9_7

    /**
    iPad 7th Generation
    */
    case iPad10_2

    /**
    iPad Pro 10.5, iPad Air 3rd Generation
    */
    case iPad10_5

    /**
    iPad Pro 11-inch 1st and 2nd Generation
    */
    case iPadPro11

    /**
    iPad Pro 12.9-inch 1st, 2nd, 3rd and 4th Generation
    */
    case iPadPro12

    func getSize() -> CGSize {
       switch self {
       
       case .iPhoneSE1:         return GV.isPortrait ? CGSize(width: 320, height: 568) : CGSize(width: 568, height: 320)
       case .iPhoneSE2:         return GV.isPortrait ? CGSize(width: 375, height: 667) : CGSize(width: 667, height: 375)
       case .iPhone8Plus:       return GV.isPortrait ? CGSize(width: 414, height: 736) : CGSize(width: 736, height: 414)
       case .iPhoneX:           return GV.isPortrait ? CGSize(width: 375, height: 812) : CGSize(width: 812, height: 375)
       case .iPhone11:          return GV.isPortrait ? CGSize(width: 414, height: 896) : CGSize(width: 896, height: 414)
       case .iPhone11ProMax:    return GV.isPortrait ? CGSize(width: 414, height: 896) : CGSize(width: 896, height: 414)
       case .iPadMini:          return GV.isPortrait ? CGSize(width: 768, height: 1024) : CGSize(width: 1024, height: 768)
       case .iPad9_7:           return GV.isPortrait ? CGSize(width: 768, height: 1024) : CGSize(width: 1024, height: 768)
       case .iPad10_2:          return GV.isPortrait ? CGSize(width: 810, height: 1080) : CGSize(width: 1080, height: 810)
       case .iPad10_5:          return GV.isPortrait ? CGSize(width: 834, height: 1112) : CGSize(width: 1112, height: 834)
       case .iPadPro11:         return GV.isPortrait ? CGSize(width: 834, height: 1194) : CGSize(width: 1194, height: 834)
       case .iPadPro12:         return GV.isPortrait ? CGSize(width: 1024, height: 1366) : CGSize(width: 1366, height: 1024)
       }
    }
    
    static func getActDevice()->DeviceType {
        switch UIScreen.main.bounds.size {
        case CGSize(width: 320, height: 568): return .iPhoneSE1
        case CGSize(width: 568, height: 320): return .iPhoneSE1
        case CGSize(width: 375, height: 667): return .iPhoneSE2
        case CGSize(width: 667, height: 375): return .iPhoneSE2
        case CGSize(width: 414, height: 736): return .iPhone8Plus
        case CGSize(width: 736, height: 414): return .iPhone8Plus
        case CGSize(width: 375, height: 812): return .iPhoneX
        case CGSize(width: 812, height: 375): return .iPhoneX
        case CGSize(width: 414, height: 896): return .iPhone11
        case CGSize(width: 896, height: 414): return .iPhone11
        case CGSize(width: 414, height: 896): return .iPhone11ProMax
        case CGSize(width: 896, height: 414): return .iPhone11ProMax
        case CGSize(width: 768, height: 1024): return .iPadMini
        case CGSize(width: 1024, height: 768): return .iPadMini
        case CGSize(width: 768, height: 1024): return .iPad9_7
        case CGSize(width: 1024, height: 768): return .iPad9_7
        case CGSize(width: 810, height: 1080): return .iPad10_2
        case CGSize(width: 1080, height: 810): return .iPad10_2
        case CGSize(width: 834, height: 1112): return .iPad10_5
        case CGSize(width: 1112, height: 834): return .iPad10_5
        case CGSize(width: 834, height: 1194): return .iPadPro11
        case CGSize(width: 1194, height: 834): return .iPadPro11
        case CGSize(width: 1024, height: 1366): return .iPadPro12
        case CGSize(width: 1366, height: 1024): return .iPadPro12
        default: return .iPad10_5
        }
    }
}
#endif






