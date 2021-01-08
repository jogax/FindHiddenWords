//
//  WordTrisGameboardItem.swift
//  MagicOfWords
//
//  Created by Jozsef Romhanyi on 14/02/2018.
//  Copyright © 2018 Jozsef Romhanyi. All rights reserved.
//

import Foundation
import GameplayKit

enum ItemStatus: Int {
    case Empty = 0, Temporary, Used, WholeWord, FixUsed, FixWholeWord, FixItem, Error, DarkGreenStatus, GoldStatus, DarkGoldStatus, OrigStatus
    var description: String {
        return String(self.rawValue)
    }
}

public struct ConnectionType {
    var left = false
    var leftTop = false
    var top = false
    var rightTop = false
    var right = false
    var rightBottom = false
    var bottom = false
    var leftBottom = false
    init(left: Bool=false, leftTop: Bool=false, top: Bool=false, rightTop: Bool=false, right: Bool=false, rightBottom: Bool=false, bottom: Bool=false, leftBottom: Bool=false) {
        self.left = left
        self.leftTop = leftTop
        self.top = top
        self.rightTop = rightTop
        self.right = right
        self.rightBottom = rightBottom
        self.bottom = bottom
        self.leftBottom = leftBottom
    }
    func isSet() -> Bool {
        return left || leftTop || top || rightTop || right || rightBottom || bottom || leftBottom
    }
}


let emptyLetter = " "
let noChange = ""


class GameboardItem: SKSpriteNode {
    public var status: ItemStatus = .Empty
    private var origLetter: String = emptyLetter
    public var origStatus: ItemStatus = .Empty
    public var doubleUsed = false
    private var blockSize:CGFloat = 0
    private var label: SKLabelNode
    private var countWordsLabel: SKLabelNode
    private var connectionType = ConnectionType()
    private var countOccurencesInWords = 0
    public var upperNeighbor: GameboardItem?
    public var lowerNeighbor: GameboardItem?
    public var leftNeighbor: GameboardItem?
    public var rightNeighbor: GameboardItem?
    public var col: Int = 0
    public var row: Int = 0
    public var checked = false
    public var fixItem = false
    public var countFreeConnections = 0
    public var inFreeArray = -1
    struct StatusType: Hashable {
        var itemStatus: ItemStatus = .Empty
        var fixItem: Bool = false
    }
    private var textureName: [StatusType : String] =
        [StatusType(itemStatus: .Empty, fixItem: false) : "whiteSprite",
         StatusType(itemStatus: .Empty, fixItem: true) : "whiteSprite",
         StatusType(itemStatus: .Temporary, fixItem: false) : "BlueOctagon", //LightBlueSprite",
         StatusType(itemStatus: .Temporary, fixItem: true) : "BlueOctagon", //"LightBlueSprite",
         StatusType(itemStatus: .Used, fixItem: false) : "GrayOctagon", //"LightGraySprite", //"LightRedSprite",
         StatusType(itemStatus: .Used, fixItem: true) : "GrayOctagon", //Octagon" //"LilaSprite",
         StatusType(itemStatus: .WholeWord, fixItem: false) : "GreenOctagon", //"GreenSprite",
         StatusType(itemStatus: .WholeWord, fixItem: true) : "GreenOctagon", //"GreenLilaSprite",
         StatusType(itemStatus: .Error, fixItem: false) : "RedOctagon",//"RedSprite",
         StatusType(itemStatus: .Error, fixItem: true) : "RedOctagon", //"RedSprite",
         StatusType(itemStatus: .DarkGreenStatus, fixItem: false) : "DarkGreenSprite",
         StatusType(itemStatus: .DarkGreenStatus, fixItem: true) : "DarkGreenSprite",
         StatusType(itemStatus: .GoldStatus, fixItem: false) : "GoldOctagon", //"GoldSprite",
         StatusType(itemStatus: .GoldStatus, fixItem: true) : "GoldOctagon", //"GoldSprite",
         StatusType(itemStatus: .DarkGoldStatus, fixItem: false) : "DarkGoldSprite",
         StatusType(itemStatus: .DarkGoldStatus, fixItem: true) : "DarkGoldSprite"]

    public var letter = emptyLetter
    private var fontSize: CGFloat = 0
    let countWordsLabelFontSize: CGFloat = GV.onIpad ? 15 : 15
    init() {
        label = SKLabelNode()
        // Call the init
        countWordsLabel = SKLabelNode()
//        GameboardItem.countInstances += 1
        self.fontSize = GV.buttonFontSize
        self.blockSize = GV.blockSize
        let texture = SKTexture(imageNamed: "whiteSprite")
        super.init(texture: texture, color: .white, size: CGSize(width: blockSize, height: blockSize))
        label.fontName = "KohinoorTelugu-Regular"
//        label.fontName = "Baskerville"
//        label.fontName = "ChalkboardSE-Light"
//        label.fontName = "PingFangTC-Semibold"
//        label.fontName = GV.actPieceFont //"KohinoorBangla-Regular"
        label.fontColor = .black
        label.verticalAlignmentMode = .center
        label.fontSize = self.fontSize
        label.zPosition = self.zPosition + 1
        addChild(label)

        countWordsLabel.position = CGPoint(x: blockSize * 0.28, y: -blockSize * 0.35)
        countWordsLabel.fontName = GV.actPieceFont //"KohinoorBangla-Regular"
        countWordsLabel.fontColor = .black
//        countWordsLabel.verticalAlignmentMode = .center
        countWordsLabel.fontSize = countWordsLabelFontSize
        countWordsLabel.text = countOccurencesInWords > 0 ? String(countOccurencesInWords) : ""
        countWordsLabel.zPosition = self.zPosition + 2
        addChild(countWordsLabel)
    }
    
    public func setLabelFontSize(_ fontSize: CGFloat) {
        label.fontSize = fontSize
    }
    public var moveable:Bool {
        get {
            if fixItem {
                return false
            }
            if status == .Temporary && origStatus == .WholeWord {
                return false
            }
            if status == .WholeWord {
                return false
            }
           return true
        }
    }
    public func copyMe()->GameboardItem {
        let copyed = GameboardItem()
        copyed.col = self.col
        copyed.row = self.row
        copyed.texture = self.texture
        copyed.position = self.position
        copyed.status = self.status
        copyed.origLetter = self.origLetter
        copyed.origStatus = self.origStatus
        copyed.blockSize = self.blockSize
        copyed.letter = self.letter
        copyed.label = self.label.copyMe()
        copyed.label.zPosition = self.zPosition + 1
        copyed.addChild(copyed.label)
        copyed.countWordsLabel = self.countWordsLabel.copyMe()
        copyed.addChild(copyed.countWordsLabel)
        copyed.countWordsLabel.zPosition = self.zPosition + 1
        return copyed
    }
    public func setLetter(letter: String, toStatus: ItemStatus/*, calledFrom: String*/, fontSize: CGFloat = 0)->Bool {
        if letter != emptyLetter && toStatus == .Empty {
            print("hier at problem")
        }
        if fontSize != 0 {
            label.fontSize = fontSize
        }
        if (self.status == .Used && toStatus != .FixItem) || self.status == .WholeWord {
            self.origStatus = self.status
            setStatus(toStatus: .Error)
            self.origLetter = label.text!
            label.text = letter
            self.letter = letter
            doubleUsed = true
            return false
        } else {
            self.colorBlendFactor = 1
            if letter != noChange {
                label.text = letter
                self.letter = letter
            }
            if toStatus == .FixItem {
                fixItem = true
                setStatus(toStatus: .Used)
            } else {
                setStatus(toStatus: toStatus)
            }
            return true
        }
    }
    
    public func setNeighbor(direction: Direction, neighbor: GameboardItem?) {
        switch direction {
        case .Down:
            lowerNeighbor = neighbor
        case .Up:
            upperNeighbor = neighbor
        case .Left:
            leftNeighbor = neighbor
        case .Right:
            rightNeighbor = neighbor
        }
    }
    
    public func checkFreeCells(direction: Direction) {
        switch direction {
        case .Up:
            if upperNeighbor != nil && upperNeighbor!.status == .Empty {
                upperNeighbor!.checkFreeCells()
            }
        case .Down:
            if lowerNeighbor != nil && lowerNeighbor!.status == .Empty {
                lowerNeighbor!.checkFreeCells()
            }
        case .Left:
            if leftNeighbor != nil && leftNeighbor!.status == .Empty {
                leftNeighbor!.checkFreeCells()
            }
        case .Right:
            if rightNeighbor != nil && rightNeighbor!.status == .Empty {
                rightNeighbor!.checkFreeCells()
            }
        }
    }

    public func checkFreeCells() {
        checked = true
        if upperNeighbor != nil && !upperNeighbor!.checked && upperNeighbor!.status == .Empty {
            upperNeighbor!.checkFreeCells()
        }
        if lowerNeighbor != nil && !lowerNeighbor!.checked && lowerNeighbor!.status == .Empty {
            lowerNeighbor!.checkFreeCells()
        }
       if leftNeighbor != nil && !leftNeighbor!.checked && leftNeighbor!.status == .Empty {
           leftNeighbor!.checkFreeCells()
       }
       if rightNeighbor != nil && !rightNeighbor!.checked && rightNeighbor!.status == .Empty {
           rightNeighbor!.checkFreeCells()
       }
    }

    public func clearFixLetter() {
        fixItem = false
    }
    
    public func resetCountOccurencesInWords() {
        countOccurencesInWords = 0
    }
    
//    public func getColor()->MyColor {
//        return myColor
//    }
//
    public func getCountOccurencesInWords()->Int {
        return countOccurencesInWords
    }
    
    public func incrementCountOccurencesInWords() {
        countOccurencesInWords += 1
    }

    public func getNeighborInDirection(direction: Direction)->GameboardItem? {
        switch direction {
        case .Up:   return upperNeighbor
        case .Down: return lowerNeighbor
        case .Left: return leftNeighbor
        case .Right:return rightNeighbor
        }
    }
    
    public func clearIfTemporary(col: Int, row: Int) {
        label.removeShadow()
        switch (status, fixItem) {
        case (.Temporary, false):
            label.text = emptyLetter
            self.letter = emptyLetter
            setStatus(toStatus: .Empty)
        case (.Temporary, true):
            if doubleUsed {
                label.text = self.origLetter
                self.letter = self.origLetter
                setStatus(toStatus: self.origStatus)
            }
        case (.Used, _):
            if doubleUsed {
                label.text = self.origLetter
                self.letter = self.origLetter
                setStatus(toStatus: self.origStatus)
            }
        case (.WholeWord, _):
            if doubleUsed {
                label.text = self.origLetter
                self.letter = self.origLetter
                setStatus(toStatus: self.origStatus)
            }
        case (.Error, _):
            if doubleUsed {
                label.text = self.origLetter
                self.letter = self.origLetter
                setStatus(toStatus: self.origStatus)
            }
        case (.GoldStatus, _):
            setStatus(toStatus: .Used)
        case (.DarkGoldStatus, _):
            setStatus(toStatus: .Used)
        default:
            break
        }
//        if status == .Temporary {
//        } else if (status == .Used || status == .WholeWord || status == .FixItem || status == .Error) && doubleUsed {
////            self.color = convertMyColorToSKColor(color: self.origColor)
//        } else if letter != emptyLetter && (status == .Temporary || status == .GoldStatus || status == .DarkGoldStatus) {
//            setStatus(toStatus: .Used, calledFrom: "clearIfTemporary - 3", col:col, row: row)
//        }
        self.doubleUsed = false
    }
    
    public func fixIfTemporary()->Bool {
        if status == .Temporary {
//            self.status = .used
            setStatus(toStatus: .Used)
            return true
        } else if (status == .Used || status == .WholeWord) && doubleUsed {
            label.text = self.origLetter
            setStatus(toStatus: self.origStatus)
//            self.color = convertMyColorToSKColor(color: self.origColor)
            doubleUsed = false
            return false
        } else if status == .Error {
            label.text = origLetter
            setStatus(toStatus: self.origStatus)
            return false
        }
        return true
    }
    
    public func clearIfUsed() {
        if status == .WholeWord {
            label.text = emptyLetter
            self.letter = emptyLetter
            setStatus(toStatus: .Empty)
            clearConnectionType()
        }
    }
    
    public func correctStatusIfNeeded() {
        if status == .WholeWord && letter == emptyLetter {
            status = .Empty
        }
    }
    public func remove() {
        label.text = emptyLetter
        self.letter = emptyLetter
        setStatus(toStatus: .Empty)
    }
    
    public func clearConnectionType() {
        self.connectionType = ConnectionType()
        setTexture()
    }
    
    public func setConnectionType(connectionType: ConnectionType) {
        if connectionType.left {
            self.connectionType.left = true
        }
        if connectionType.top {
            self.connectionType.top = true
        }
        if connectionType.right {
            self.connectionType.right = true
        }
        if connectionType.bottom {
            self.connectionType.bottom = true
        }
        if connectionType.leftBottom {
            self.connectionType.leftBottom = true
        }
        if connectionType.leftTop {
            self.connectionType.leftTop = true
        }
        if connectionType.rightTop {
            self.connectionType.rightTop = true
        }
        if connectionType.rightBottom {
            self.connectionType.rightBottom = true
        }
//        setTexture()
    }
    
    public func setStatus(/*toColor: MyColor = .myWhiteColor,*/ toStatus: ItemStatus, connectionType: ConnectionType = ConnectionType(), incrWords: Bool = false, decrWords: Bool = false) {
        let newStatus = toStatus == .OrigStatus ? origStatus : toStatus
//        let oldStatus = status
        switch (status, newStatus) {
        case (.Used, .Temporary):
            origStatus = status
            origLetter = letter
            status = .Temporary
        case (.WholeWord, .Temporary):
            origStatus = status
            origLetter = letter
            status = .Temporary
        case (.WholeWord, .DarkGreenStatus):
            origStatus = status
            origLetter = letter
            status = toStatus
        case (.WholeWord, .Error):
            origStatus = status
            origLetter = letter
            status = toStatus
       default:
            self.status = newStatus
        }
        self.status = letter == emptyLetter ? .Empty : self.status
        self.countOccurencesInWords += incrWords ? 1 : 0
        if self.countOccurencesInWords > 0 && decrWords {
            self.countOccurencesInWords -= 1
        }
        
        if newStatus == .WholeWord || newStatus == .GoldStatus || newStatus == .DarkGoldStatus || newStatus == .Error || newStatus == .DarkGreenStatus {
            if countOccurencesInWords > 0 {
                self.countWordsLabel.text = String(countOccurencesInWords)
                self.countWordsLabel.fontSize = countWordsLabelFontSize * (countOccurencesInWords < 10 ? 1.0 : 0.7)
            }
        } else {
            self.countWordsLabel.text = ""
        }
//        print("In SetStatus: caller: \(calledFrom), letter: \(letter), oldStatus: \(oldStatus), status: \(newStatus), newStatus: \(status)")
        if connectionType.isSet() {
            setConnectionType(connectionType: connectionType)
        }
        let name = textureName[StatusType(itemStatus: status, fixItem: fixItem)]!
        self.texture = SKTexture(imageNamed: name)
 
    }
    
    var lastCol = 0
    var lastRow = 0
    var timer = Date()
    private func setFirstTime() {
        timer = Date()
    }
    
    private func showTime(string: String) {
        let date = Date()
        print("time at \(string): \((date.timeIntervalSince(timer) * 1000).nDecimals(10))")
        timer = Date()
    }
    
    public func showConnections() {
        if connectionType.isSet() {
            setTexture()

        }
    }
    

    
    private func setTexture() {
        // Drawing in a shape
//        let name = textureName[StatusType(itemStatus: status, fixItem: fixItem)]!
//        self.texture = SKTexture(imageNamed: name)
//        if status == .Used {
//            return
//        }
        let p1 = GV.gameArray[0][0].position
        let p2 = GV.gameArray[0][2].position
        let distance = abs(p2.y - p1.y)
        let size = CGSize(width: distance, height: distance)
        let connectedSprite = DrawImages.drawConnections(size: size, connections: connectionType)
        let child = SKSpriteNode(texture: connectedSprite) // imageNamed: connectionName)
//        child.size = self.size * 1.1
        child.zPosition = self.zPosition - 10
        child.name = "Connection"
//        let main = self
        child.position = self.position
        GV.playingGrid!.addChild(child)
//        self.addChild(child)
        print()
    }

    public func toString()->String {
        
        var modifiedStatus = status
        if fixItem {
            switch status {
            case .Used:
                modifiedStatus = .FixUsed
            case .WholeWord:
                modifiedStatus = .FixWholeWord
            default: break
            }
        }
        let actLetter = status == .Empty || status == .Temporary ? emptyLetter : letter
        return modifiedStatus.description + actLetter
    }
    
    public func restore(from: String) {
//        var color: MyColor = .myWhiteColor
        var status: ItemStatus = .Empty
        var letter = emptyLetter
        setFirstTime()
        remove()
//        showTime(string: "remove")
        if let rawStatus = Int(from.firstChar()) {
            if let itemStatus = ItemStatus(rawValue: rawStatus) {
                switch itemStatus {
                case .FixUsed:
                    fixItem = true
                    status = .Used
                case .FixWholeWord:
                    fixItem = true
                    status = .WholeWord
                default:
                    status = itemStatus
                }
            }
        }
        letter = from.subString(at: 1, length: 1)
//        showTime(string: "from.subString")
        _ = setLetter(letter: letter, toStatus: status)//, calledFrom: "restore")
//        showTime(string: "setLetter")
        origLetter = emptyLetter
        origStatus = .Empty
        doubleUsed = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
//        print("THE CLASS \((type(of: self))) WAS REMOVED FROM MEMORY (DEINIT): instance: \(GameboardItem.countInstances)")
//        GameboardItem.self.countInstances -= 1
    }

    static var countInstances = 0
}
