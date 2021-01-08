//
//  PlaySearchWords.swift
//  DuelOfWords
//
//  Created by Romhanyi Jozsef on 2020. 06. 05..
//  Copyright © 2020. Romhanyi Jozsef. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import SpriteKit
import GameplayKit
import AVFoundation



public protocol PlaySearchingWordsDelegate: class {
    func goBack()
}
class ObjectSP {
    var frame = CGRect(x: 0, y: 0, width: 0, height: 0)
    var name = ""
    init(_ frame: CGRect, _ name: String){
        self.frame = frame
        self.name = name
    }
}

class PlaySearchingWords: SKScene, TableViewDelegate {
    func getNumberOfSections() -> Int {
        return 1
    }
    
    func getNumberOfRowsInSections(section: Int)->Int {
        switch tableType {
        case .ShowMyWords:
            return myWordsForShow.countWords
        case .ShowWordsOverPosition:
            return wordList.countWords
//        case .ShowFoundedWords:
//            return listOfFoundedWords.count
//        case .ShowHints:
//            return GV.hintTable.count
        default:
            return 0
        }
    }
    let color = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 1.0)

    public func getTableViewCell(tableView: UITableView, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomTableViewCell
        cell.setFont(font: myTableFont)
        let height = "A".height(font: myTableFont)
//        cell.setCellSize(size: CGSize(width: tableView.frame.width /* * (GV.onIpad ? 0.040 : 0.010)*/, height: self.frame.width * (GV.onIpad ? 0.040 : 0.010)))
        cell.setCellSize(size: CGSize(width: 0 /*tableView.frame.width * (GV.onIpad ? 0.040 : 0.010)*/, height: height)) // self.frame.width * (GV.onIpad ? 0.050 : 0.010)))
//        if tableType == .ShowFoundedWords {
//            cell.setBGColor(color: myLightBlue)
//        } else {
            cell.setBGColor(color: UIColor.white)
//        }
        switch tableType {
        case .ShowMyWords:
            let wordForShow = myWordsForShow!.words[indexPath.row]
//            let length = wordForShow.word.lastChar() == "*" ? wordForShow.word.count - 1 : wordForShow.word.count
            cell.addColumn(text: "  " + wordForShow.word.fixLength(length: lengthOfWord, leadingBlanks: false)) // WordColumn
            cell.addColumn(text: String(wordForShow.counter).fixLength(length: lengthOfCnt), color: color) // Counter column
            cell.addColumn(text: String(wordForShow.length).fixLength(length: lengthOfLength))
            cell.addColumn(text: String(wordForShow.score).fixLength(length: lengthOfScore), color: color) // Score column
        case .ShowWordsOverPosition:
            let wordForShow = wordList!.words[indexPath.row]
            cell.addColumn(text: "  " + wordForShow.word.fixLength(length: lengthOfWord + 2, leadingBlanks: false)) // WordColumn
            cell.addColumn(text: String(wordForShow.counter).fixLength(length: lengthOfCnt - 1), color: color)
            cell.addColumn(text: String(wordForShow.length).fixLength(length: lengthOfLength - 1))
//            cell.addColumn(text: String(wordForShow.score).fixLength(length: lengthOfScore + 1), color: color)
//        case .ShowFoundedWords:
//            cell.addColumn(text: "  " + listOfFoundedWords[indexPath.row].word.uppercased().fixLength(length: lengthOfWord, leadingBlanks: false), color: myLightBlue)
//            cell.addColumn(text: String(listOfFoundedWords[indexPath.row].length).fixLength(length: lengthOfLength), color: myLightBlue)
//            cell.addColumn(text: String(listOfFoundedWords[indexPath.row].score).fixLength(length: lengthOfScore), color: myLightBlue)
//            let restLength = Int(tableView.frame.width / "A".width(font:myFont)) - lengthOfWord - lengthOfLength - lengthOfScore
//            let spaces = " "
//            cell.addColumn(text: spaces.fixLength(length: restLength), color: myLightBlue)
//        case .ShowHints:
//            var actColor = UIColor.white
//            let item = hintsTableForShow[indexPath.row]
//            switch item.type {
//            case .WithFixLetter: actColor = UIColor(red: 248/255, green: 209/255, blue: 255/255, alpha: 1.0)
//            case .WithRedLetter: actColor = UIColor(red: 242/255, green: 170/255, blue: 159/255, alpha: 1.0)
//            case .WithGreenLetter: actColor = UIColor(red: 153/255, green: 249/255, blue: 114/255, alpha: 1.0)
//            }
//            cell.addColumn(text: "   " + item.hint.fixLength(length: lengthOfWord, leadingBlanks: false), color: actColor)
//            let lengthText = "\(item.hint.count) (\(item.count))"
//            cell.addColumn(text: lengthText.fixLength(length: lengthOfLength), color: actColor)
//            cell.addColumn(text: String(item.score).fixLength(length: lengthOfScore), color: actColor)
//            let restLength = Int(tableView.frame.width / "A".width(font:myFont)) - lengthOfWord - lengthOfLength - lengthOfScore
//            let spaces = " "
//            cell.addColumn(text: spaces.fixLength(length: restLength), color: actColor)
        default:
            break
        }
        return cell
    }

    func getHeightForRow(tableView: UITableView, indexPath: IndexPath)->CGFloat {
        return tableHeader.height(font: myTableFont)
    }

    func setHeaderView(tableView: UITableView, headerView: UIView, section: Int) {
    }
    
    func fillHeaderView(tableView: UITableView, section: Int) -> UIView {
        let textColor:UIColor = .black
        var text: String = ""
        let text0: String = ""
        let lineHeight = tableHeader.height(font: myTableFont)
        let yPos0: CGFloat = 0
        var yPos1: CGFloat = 0
        var yPos2: CGFloat = lineHeight
        let view = UIView()
        var width:CGFloat = tableHeader.width(font: myTableFont)
        let widthOfChar = "A".width(font: myTableFont)
        let lengthOfTableView = Int(tableView.frame.width / widthOfChar) + 1
        switch tableType {
        case .ShowMyWords:
            let suffix = " (\(myWordsForShow.countWords)/\(myWordsForShow.countAllWords)/\(myWordsForShow.score))"
            text = (GV.language.getText(.tcCollectedOwnWords) + suffix).fixLength(length: lengthOfTableView, center: true)
            if text.width(font: myTableFont) > width {
                width = text.width(font: myTableFont)
            }
        case .ShowWordsOverPosition:
            text = GV.language.getText(.tcWordsOverLetter, values: choosedWord.usedLetters.first!.letter).fixLength(length: tableHeader.length, center: true)
//        case .ShowFoundedWords:
//            let header0 = GV.language.getText(.tcSearchingWord, values: searchingWord)
//            let header1 = GV.language.getText(.tcShowWordlistHeader, values: String(listOfFoundedWords.count))
//            (width, length) = calculateTableViewWidth(header0: header0, header1: header1, header2: title)
//            let optimalLength = Int(tableView.frame.width / "A".width(font: myFont))
//            length = length < optimalLength ? optimalLength : length
//            text = header1.fixLength(length: length, center: true)
//            text0 = header0.fixLength(length: length, center: true)
//        case .ShowHints:
//            let length = Int(tableView.frame.width / "W".width(font: myFont))
//            text = hintHeaderLine.fixLength(length: length + 4, center: true)
//            if title.length < text.length {
//                width = text.width(font: myFont)
//            }
        default:
            break
        }
        if tableType == .ShowFoundedWords {
             let label0 = UILabel(frame: CGRect(x: 0, y: yPos0, width: width, height: lineHeight))
            label0.font = myFont
            label0.text = text0
            label0.textColor = .black
            yPos1 = lineHeight
            yPos2 = 2 * lineHeight
            view.addSubview(label0)
        }
        let label1 = UILabel(frame: CGRect(x: 0, y: yPos1, width: width, height: lineHeight))
        label1.font = myTableFont
        label1.text = text
        label1.textColor = textColor
        view.addSubview(label1)
        let label2 = UILabel(frame: CGRect(x: 0, y: yPos2, width: width, height: lineHeight))
        label2.font = myTableFont
        label2.text = tableHeader
        label2.textColor = textColor
        view.addSubview(label2)
//        if tableType == .ShowFoundedWords {
//            view.backgroundColor = myLightBlue
//        } else {
            view.backgroundColor = UIColor(red:240/255, green: 240/255, blue: 240/255, alpha: 1.0)
//        }
        return view
    }

    func getHeightForHeaderInSection(tableView: UITableView, section: Int)->CGFloat {
        if tableType == .ShowFoundedWords {
            return GV.onIpad ? 72 : 53
        }
        return GV.onIpad ? 48 : 35
    }
    
    func didSelectedRow(tableView: UITableView, indexPath: IndexPath) {
    }
    
    var myDelegate: GameMenuScene?
    var blockSize = CGFloat(0)
//    var gameLayer = SKSpriteNode()
    var gameLayer: SKScene!
//    var playingLayer = SKSpriteNode()
    var myFont = UIFont()
    let myFontName = "ChalkboardSE-Light"
//    let wordFontSizeMpx: CGFloat = GV.onIpad ? 0.020 : 0.02
    override func didMove(to view: SKView) {
        headerMpx = GV.onIpad ? 0.03 : 0.05
        gameLayer = self

    }
    public func start(delegate: GameMenuScene) {
//        newWordListRealm = getNewWordList()
        
        oldOrientation = UIDevice.current.orientation.isPortrait
//        setGlobalSizes()
//        wordsFontSize = GV.minSide * wordFontSizeMpx
//        self.addChild(gameLayer)
        gameLayer.size = CGSize(width: GV.actWidth, height: GV.actHeight)
//        gameLayer.position = CGPoint(x: GV.actWidth * 0.5, y: GV.actHeight * 0.5)
        setBackground(to: gameLayer)
        GV.target = self
        GV.orientationHandler = #selector(handleOrientation)
        self.size = CGSize(width: GV.actWidth, height: GV.actHeight)
        myFont = UIFont(name: myFontName, size: GV.actHeight * 0.03)!
        playedGamesRealm = getRealm(type: .PlayedGameRealm)
        myDelegate = delegate
//        showBackground(to: gameLayer)
//        showGamesMenu()
        startNewGame()
    }
    
    var oldOrientation = false
    var mySounds = MySounds()
    
    @objc private func handleOrientation() {
//        let isPortrait = UIDevice.current.orientation.isPortrait
//        if oldOrientation == isPortrait {
//            return
//        }
//        oldOrientation = isPortrait
        self.size = CGSize(width: GV.actWidth,height: GV.actHeight)
        self.view!.frame = CGRect(x: 0, y: 0, width: GV.actWidth, height: GV.actHeight)
        gameLayer.size = self.size
        setBackground(to: gameLayer)
        gameLayer.setPosAndSizeForAllChildren()
    }
    
    var headerMpx: CGFloat = 0

    
    private func addShortButtonPL(to: SKScene, text: String, action: Selector, col: CGFloat, headerNode: SKNode, countCols: CGFloat) {
        let button = MyButton(fontName: GV.fontName, size: CGSize(width: 100, height: 100))
        button.zPosition = self.zPosition + 20
        button.setButtonLabel(title: text, font: UIFont(name: GV.fontName, size: GV.minSide * 0.04)!)
        button.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: action)
        let buttonPlace = GV.minSide / (countCols + 1)
        let buttonWidth = buttonPlace * 0.8
        let adderP = (GV.minSide * col * 0.15)
        let adderL = (GV.maxSide * col * 0.15)
        let headerNodeHeight = headerNode.frame.height
        button.plPosSize = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.10 + adderP, y: (headerNode.plPosSize?.PPos.y)! - headerNodeHeight),
                                     LPos: CGPoint(x: GV.maxSide * 0.10 + adderL, y: (headerNode.plPosSize?.LPos.y)! - headerNodeHeight),
                                     PSize: CGSize(width: buttonWidth, height: GV.maxSide * 0.04),
                                     LSize: CGSize(width: buttonWidth, height: GV.maxSide * 0.04))
        button.myType = .MyButton
        button.setActPosSize()
        button.name = name
        to.addChild(button)

    }
    
    private func addButtonPL(to: SKNode, text: String, action: Selector, line: CGFloat)->MyButton {
        let button = MyButton(fontName: GV.fontName, size: CGSize(width: GV.minSide * 0.4, height: GV.maxSide * 0.05))
        button.zPosition = self.zPosition + 20
        button.setButtonLabel(title: text, font: UIFont(name: GV.fontName, size: GV.minSide * 0.04)!)
        button.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: action)
        if line == GoBack {
            button.plPosSize = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.25, y: (GV.maxSide * 0.05)),
                                         LPos: CGPoint(x: GV.maxSide * 0.25, y: (GV.maxSide * 0.03)),
                                         PSize: CGSize(width: GV.minSide * 0.3, height: GV.maxSide * 0.05),
                                         LSize: CGSize(width: GV.minSide * 0.3, height: GV.maxSide * 0.05))
        } else if line == ShowMyWords {
            button.plPosSize = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.70, y: (GV.maxSide * 0.05)),
                                         LPos: CGPoint(x: GV.maxSide * 0.70, y: (GV.maxSide * 0.03)),
                                         PSize: CGSize(width: GV.minSide * 0.5, height: GV.maxSide * 0.05),
                                         LSize: CGSize(width: GV.minSide * 0.5, height: GV.maxSide * 0.05))
        } else {
            button.plPosSize = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: (GV.maxSide * 0.8) - (line * GV.maxSide * 0.06)),
                                         LPos: CGPoint(x: GV.maxSide * 0.5, y: (GV.minSide * 0.8) - (line * GV.maxSide * 0.06)),
                                         PSize: CGSize(width: GV.minSide * 0.6, height: GV.maxSide * 0.05),
                                         LSize: CGSize(width: GV.minSide * 0.6, height: GV.maxSide * 0.05))
        }
        button.myType = .MyButton
        button.setActPosSize()
        button.name = name
        to.addChild(button)
        return button
    }

    private func setPosItionsAndSizesOfNodesWithActNames(layer: SKNode, objects: [ObjectSP]) {
        for index in 0..<objects.count {
            let name = objects[index].name
            let buttonName = name.contains("Button")
            let labelName = name.contains("Label")
            let gridName = name.contains("Grid")
            if let node = layer.childNode(withName: name) {
                switch (buttonName, labelName, gridName) {
                case (true, false, false):
                    (node as! MyButton).size = objects[index].frame.size
                    (node as! MyButton).position = objects[index].frame.origin
                case (false, true, false):
                    (node as! MyLabel).position = objects[index].frame.origin
                case (false, false, true):
                    (node as! Grid).size = objects[index].frame.size
                    (node as! Grid).position = objects[index].frame.origin
                default:
                    break
                }
            }
        }
    }


    
    let GoBack: CGFloat = 1000
    let ShowMyWords: CGFloat = 1001
    
    @objc private func goBack() {
        removeChildrenExceptTypes(from: gameLayer, types: [.Background])
        myDelegate!.goBack()
    }
    
    @objc private func createNewGame() {
        startNewGame()
    }
    
    @objc private func startNewGame() {
        GV.oldSize = GV.size
        myLabels.removeAll()
        allWords.removeAll()
        mandatoryWords.removeAll()
        let maxGameNumber = 99
        let startGameNumber = 0
        var primary = GV.actLanguage + GV.innerSeparator + "*" + GV.innerSeparator + String(GV.size)
        playedGamesRealm = getRealm(type: .PlayedGameRealm)
        let actGame = playedGamesRealm!.objects(PlayedGame.self).filter("finished = %d AND primary like %@", false, primary).sorted(byKeyPath: "timeStamp", ascending: true)
        if actGame.count == 0 {
            let finishedGames = playedGamesRealm!.objects(PlayedGame.self).filter("primary like %@ AND finished = true",
                                                                                  primary).sorted(byKeyPath: "gameNumber", ascending: false)
            if finishedGames.count == 0 {
//                GV.size = 8
                GV.gameNumber = startGameNumber
                primary = GV.actLanguage + GV.innerSeparator + String(GV.gameNumber) + GV.innerSeparator + String(GV.size)
            } else {
                let lastPlayed = finishedGames.first!
                GV.gameNumber = lastPlayed.gameNumber + 1
//                GV.size = lastPlayed.gameSize
                if GV.gameNumber > maxGameNumber {
//                    GV.size += 1
                    GV.gameNumber = 1
                }
                primary = GV.actLanguage + GV.innerSeparator + String(GV.gameNumber) + GV.innerSeparator + String(GV.size)
            }
            let origGame = gamesRealm.objects(Games.self).filter("primary = %@", primary)
            if origGame.count > 0 {
                let newGame = PlayedGame()
                newGame.primary = primary
                newGame.gameSize = GV.size
                newGame.language = GV.actLanguage
                newGame.gameNumber = origGame.first!.gameNumber
                newGame.gameArray = origGame.first!.gameArray
                newGame.wordsToFind = origGame.first!.words
                newGame.finished = false
                try! playedGamesRealm!.safeWrite {
                    playedGamesRealm!.add(newGame)
                }
            }
        } else {
//            if !new {
//                try! playedGamesRealm?.safeWrite {
//                    actGame.first!.myWords = ""
//                }
//            }
            GV.gameNumber = actGame.first!.gameNumber
        }
        playingGame()
    }
    
    @objc private func startFinishedGame() {

    }
    
    var games: Results<Games>?
    
    private func createNewGameArray(size: Int) -> [[GameboardItem]] {
        var gameArray: [[GameboardItem]] = []
        
        for i in 0..<size {
            gameArray.append( [GameboardItem]() )
            
            for j in 0..<GV.size {
                gameArray[i].append( GameboardItem() )
                gameArray[i][j].letter = emptyLetter
            }
        }
        return gameArray
    }
    
    private func fillGameArray(gameArray: [[GameboardItem]], content: String, toGrid: Grid) {
        let size = gameArray.count
        for (index, letter) in content.enumerated() {
            let col = index / size
            let row = index % size
            gameArray[col][row].position = toGrid.gridPosition(col: col, row: row)
            gameArray[col][row].name = "GBD/\(col)/\(row)"
            gameArray[col][row].col = col
            gameArray[col][row].row = row
            _ = gameArray[col][row].setLetter(letter: String(letter), toStatus: .Used, fontSize: GV.blockSize * 0.6)
            toGrid.addChild(gameArray[col][row])
        }
    }
    
    var firstTouchLocation = CGPoint(x: 0, y: 0)
    var firstTouchTime = Date()
    var timeIndex = 0
    var movingShapeStartPosition = CGPoint(x: 0, y: 0)
//    enum GameState: Int {
//        case Choosing = 0, Playing
//    }
    var choosedWord = UsedWord()
    var movingLocations = [CGPoint]()
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        stopShowingTableIfNeeded()
        choosedWord = UsedWord()
        let touchLocation = touches.first!.location(in: self)
        movingLocations.removeAll()
        movingLocations.append(touchLocation)
        let (OK, col, row) = analyzeNodesAtLocation(location: touchLocation)
        colRowTable.removeAll()
        if OK {
            choosedWord.append(UsedLetter(col: col, row: row, letter: GV.gameArray[col][row].letter))
            colRowTable.append(ColRow(col: col, row: row, count: 1))
            GV.gameArray[col][row].setStatus(toStatus: .Temporary)
        }
    }
    
    private func stopShowingTableIfNeeded() {
        if tableType == .None {
            return
        }
        switch tableType {
        case .ShowMyWords:
            showMyWordsTableView!.removeFromSuperview()
            showMyWordsTableView = nil
            tableType = .None
//        case .ShowFoundedWords:
//            showFoundedWordsTableView!.removeFromSuperview()
//        case .ShowHints:
//            showHintsTableView!.removeFromSuperview()
        case .ShowWordsOverPosition:
            showWordsOverPositionTableView!.removeFromSuperview()
        default:
            break
        }
    }
    

    struct ColRow {
        var col = Int(0)
        var row = Int(0)
        var count = Int(0)
        init(col: Int, row: Int, count: Int) {
            self.col = col
            self.row = row
            self.count = count
        }
    }
    var colRowTable = [ColRow]()
    

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchLocation = touches.first!.location(in: self)
        movingLocations.append(touchLocation)
        let (OK, col, row) = analyzeNodesAtLocation(location: touchLocation)
        let actLetter = UsedLetter(col: col, row: row, letter: GV.gameArray[col][row].letter)
        if OK {
            var lastIndex = colRowTable.count - 1
            if colRowTable[lastIndex].col == col && colRowTable[lastIndex].row == row {
                colRowTable[lastIndex].count += 1
            } else {
                colRowTable.append(ColRow(col: col, row: row, count: 1))
                lastIndex += 1
            }
            if colRowTable[lastIndex].count == 1 {
                if colRowTable[lastIndex - 1].count < 3 {
                    GV.gameArray[colRowTable[lastIndex - 1].col][colRowTable[lastIndex - 1].row].setStatus(toStatus: .OrigStatus)
                    colRowTable.remove(at: lastIndex - 1)
                    choosedWord.word = choosedWord.word.startingSubString(length: choosedWord.count - 1)
                    choosedWord.usedLetters.removeLast()
                }
            }
            if choosedWord.count > 1 {
                if choosedWord.usedLetters[choosedWord.count - 2] == actLetter {
                    let oldLetter = choosedWord.usedLetters.last!
                    GV.gameArray[oldLetter.col][oldLetter.row].setStatus(toStatus: .OrigStatus)
                    choosedWord.removeLast()
                    return
                }
            }
            if !choosedWord.usedLetters.contains(where: {$0.col == col && $0.row == row && $0.letter == GV.gameArray[col][row].letter}) {
                choosedWord.append(UsedLetter(col:col, row: row, letter: GV.gameArray[col][row].letter))
                GV.gameArray[col][row].setStatus(toStatus: .Temporary)
            } else {
                if colRowTable.last!.count == 1 {
                    colRowTable.removeLast()
                }
            }
        }
    }
    
    private func clearTemporaryCells() {
        iterateGameArray(doing: {(col: Int, row: Int) in
            if GV.gameArray[col][row].status == .Temporary {
                GV.gameArray[col][row].setStatus(toStatus: GV.gameArray[col][row].origStatus)
            }
            if GV.gameArray[col][row].status == .GoldStatus {
                GV.gameArray[col][row].setStatus(toStatus: .WholeWord)
            }
        })
    }
    
    enum animationType: Int {
        case WordIsOK = 0, NoSuchWord, WordIsActiv
    }
    var counter = 0
    var cellsToAnimate = [GameboardItem]()
    private func animateLetters(_ usedWord: UsedWord, type: animationType) {
        cellsToAnimate.removeAll()
        var myActions = [SKAction]()
        switch type {
        case .WordIsOK:
            for usedLetter in usedWord.usedLetters {
                cellsToAnimate.append(GV.gameArray[usedLetter.col][usedLetter.row].copyMe())
            }
            var newBlockSize = GV.blockSize
            var wordSize = CGFloat(0)
            repeat {
                wordSize = CGFloat(cellsToAnimate.count) * newBlockSize * 1.3
                if wordSize > (GV.actWidth * 0.6) {
                    newBlockSize *= 0.95
                }
            } while wordSize > (GV.actWidth * 0.6)
            for cell in cellsToAnimate {
                cell.size = CGSize(width: newBlockSize, height: newBlockSize)
            }
            let firstPositionX = (GV.actWidth - wordSize) * 0.5
//            let fixPositionY = GV.playingGrid!frame.minY - newBlockSize
            let fixPositionY = GV.playingGrid!.frame.maxY + newBlockSize

            for (index, cell) in cellsToAnimate.enumerated() {
                myActions.removeAll()
                gameLayer.addChild(cell)
                cell.setStatus(toStatus: .WholeWord)
                let toPosition = GV.playingGrid!.gridPosition(col: cell.col, row: cell.row) + GV.playingGrid!.position
                cell.position = toPosition
                myActions.append(SKAction.move(to: CGPoint(x: firstPositionX + CGFloat(index) * newBlockSize * 1.3, y: fixPositionY), duration: 0.8))
//                myActions.append(SKAction.resize(toWidth: newBlockSize * 1.2, height: newBlockSize * 1.2, duration: 0.5))
//                myActions.append(SKAction.resize(toWidth: newBlockSize * 0.8, height: newBlockSize * 0.8, duration: 0.5))
//                myActions.append(SKAction.resize(toWidth: newBlockSize * 1.2, height: newBlockSize * 1.2, duration: 0.5))
                myActions.append(SKAction.scale(by: 1.2, duration: 0.5))
                myActions.append(SKAction.scale(by: 0.8, duration: 0.5))
                myActions.append(SKAction.scale(by: 1.2, duration: 0.5))
                myActions.append(SKAction.fadeOut(withDuration: 0.2))
                myActions.append(SKAction.move(to: GV.playingGrid!.gridPosition(col: cell.col, row: cell.row) , duration: 0.2))
                myActions.append(SKAction.removeFromParent())
                cell.zPosition = 100
                let sequence = SKAction.sequence(myActions)
                cell.run(sequence)
            }
        case .NoSuchWord:
            cellsToAnimate.removeAll()
            for item in choosedWord.usedLetters {
                cellsToAnimate.append(GV.gameArray[item.col][item.row])
            }
            for cell in cellsToAnimate {
                myActions.removeAll()
                cell.setStatus(toStatus: .OrigStatus)
//                myActions.append(SKAction.wait(forDuration: 0.2))
                for _ in 0...2 {
                    myActions.append(SKAction.run {
                        cell.setStatus(toStatus: .Error)
                    })
                    myActions.append(SKAction.wait(forDuration: 0.4))
                    myActions.append(SKAction.run {
                        cell.setStatus(toStatus: .OrigStatus)
                    })
                    myActions.append(SKAction.wait(forDuration: 0.2))
                }
                let sequence = SKAction.sequence(myActions)
                cell.run(sequence)
            }
        case .WordIsActiv:
            cellsToAnimate.removeAll()
            for item in choosedWord.usedLetters {
                cellsToAnimate.append(GV.gameArray[item.col][item.row])
            }
            for cell in cellsToAnimate {
                myActions.removeAll()
                cell.setStatus(toStatus: .OrigStatus)
//                myActions.append(SKAction.wait(forDuration: 0.2))
                for _ in 0...2 {
                    myActions.append(SKAction.run {
                        cell.setStatus(toStatus: .GoldStatus)
                    })
                    myActions.append(SKAction.wait(forDuration: 0.4))
                    myActions.append(SKAction.run {
                        cell.setStatus(toStatus: .OrigStatus)
                    })
                    myActions.append(SKAction.wait(forDuration: 0.2))
                }
                let sequence = SKAction.sequence(myActions)
                cell.run(sequence)
            }
        }
    }
    

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        let touchLocation = touches.first!.location(in: self)
        if choosedWord.count > 3 {
            let foundedWords = newWordListRealm.objects(NewWordListModel.self).filter("word = %@", GV.actLanguage + choosedWord.word.lowercased())
            if foundedWords.count == 1 {
                if saveChoosedWord() {
                    animateLetters(choosedWord, type: .WordIsOK)
                    mySounds.play(.OKWord)
                    setGameArrayToActualState()
                    let title = GV.language.getText(.tcShowMyWords, values: String(getMyWordsCount()))
                    showMyWordsButton.setButtonLabel(title: title, font: UIFont(name: GV.fontName, size: GV.minSide * 0.04)!)
                } else {
                    animateLetters(choosedWord, type: .WordIsActiv)
                    clearTemporaryCells()
                    mySounds.play(.NoSuchWord)
                }
            } else {
                clearTemporaryCells()
                animateLetters(choosedWord, type: .NoSuchWord)
                mySounds.play(.NoSuchWord)
            }
            choosedWord = UsedWord()
        } else {
            clearTemporaryCells()
            if choosedWord.count == 1 {
                showWordsOverPosition()
            }
        }
//        var countGreenCells = 0
        var countGreenWords = 0
        for myLabel in myLabels {
            countGreenWords +=  myLabel.founded ? 1 : 0
        }
        if countGreenWords == mandatoryWords.count {
            congratulation()
        }
    }
    
    private func getWordsOverPosition()->([MyFoundedWordsForTable], Int) {
        func setGoldLetters(usedLetters: [UsedLetter]) {
            for letter in usedLetters {
                GV.gameArray[letter.col][letter.row].setStatus(toStatus: .GoldStatus)
            }
        }
        var returnWords = [MyFoundedWordsForTable]()
        var maxLength = 0
        var returnScore = 0
        let letter = choosedWord.usedLetters.first!
        for label in myLabels {
            if !label.mandatory || label.founded {
                let word = label.usedWord!.word + (label.founded ? "*" : "")
                for actLetter in label.usedWord!.usedLetters {
                    if actLetter == letter {
                        if !returnWords.contains(where: {$0.word == word}) {
                            if maxLength < word.length {
                                maxLength = word.length
                            }
                            let length = label.usedWord!.word.count
                            returnWords.append(MyFoundedWordsForTable(word: word, length: length, score: 0, counter: 1))                        } else {
                            for index in 0..<returnWords.count {
                                if returnWords[index].word == word {
                                    returnWords[index].counter += 1
                                    returnScore -= returnWords[index].score
                                    returnWords[index].score *= 2
                                    returnScore += returnWords[index].score
                                }
                            }
                        }
                        setGoldLetters(usedLetters: label.usedWord!.usedLetters)
                    }
                }
            }
        }
        returnWords = returnWords.sorted(by: {$0.word.length > $1.word.length ||
                                              $0.word.length == $1.word.length && $0.counter > $1.counter
        })
        return (returnWords, maxLength)

    }
    
    private func showWordsOverPosition() {
        showWordsOverPositionTableView = TableView()

        tableType = .ShowWordsOverPosition
        let (words, _) = getWordsOverPosition()
        wordList = WordsForShow(words: words)
        calculateColumnWidths(showScore: false)
        let suffix = " (\(wordList.countWords))"
        let headerText = (GV.language.getText(.tcWordsOverLetter, values: choosedWord.usedLetters.first!.letter) + suffix)
        let actWidth = max(tableHeader.width(font: myTableFont), headerText.width(font: myTableFont)) * 1.2

        showWordsOverPositionTableView.setDelegate(delegate: self)
        showWordsOverPositionTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        let origin = CGPoint(x: 0.5 * (self.frame.width - actWidth), y: self.frame.height * 0.08)
        let lineHeight = tableHeader.height(font:myTableFont)
        let headerframeHeight = lineHeight * 2.3
        var showingWordsHeight = CGFloat(wordList!.words.count + 1) * lineHeight
        if showingWordsHeight  > self.frame.height * 0.8 {
            var counter = CGFloat(wordList!.words.count)
            repeat {
                counter -= 1
                showingWordsHeight = lineHeight * counter
            } while showingWordsHeight + headerframeHeight > self.frame.height * 0.8
        }
        if globalMaxLength < GV.language.getText(.tcWord).count {
            globalMaxLength = GV.language.getText(.tcWord).count
        }
        let size = CGSize(width: actWidth, height: showingWordsHeight + headerframeHeight)
        showWordsOverPositionTableView?.frame=CGRect(origin: origin, size: size)
        self.showWordsOverPositionTableView?.reloadData()
//        self.scene?.alpha = 0.2
        self.scene?.view?.addSubview(showWordsOverPositionTableView!)
    }

    
    private func congratulation() {
        try! playedGamesRealm?.safeWrite {
            playedGame.finished = true
        }
        let myAlert = MyAlertController(title: .tcCongratulations,
                                          message: .tcFinishGameMessage,
                                          size: CGSize(width: GV.actWidth * 0.5, height: GV.actHeight * 0.5),
                                          target: self,
                                          type: .Green)
        myAlert.addAction(text: .tcOK, action: #selector(self.createNewGame))
        myAlert.presentAlert()
        self.addChild(myAlert)
    }

    
    private func setConnectionTypes(usedLetters: [UsedLetter])->[ConnectionType] {
        var connectionTypes = Array(repeating: ConnectionType(), count: usedLetters.count)
        if usedLetters.count > 0 {
            for index in 0..<usedLetters.count - 1 {
                
                if usedLetters[index].row < usedLetters[index + 1].row {
                    if usedLetters[index].col < usedLetters[index + 1].col {
                        connectionTypes[index].rightBottom = true
                        connectionTypes[index + 1].leftTop = true
                    } else if usedLetters[index].col > usedLetters[index + 1].col {
                        connectionTypes[index].leftBottom = true
                        connectionTypes[index + 1].rightTop = true
                    } else {
                        connectionTypes[index].bottom = true
                        connectionTypes[index + 1].top = true
                    }
                }
                if usedLetters[index].row > usedLetters[index + 1].row {
                    if usedLetters[index].col > usedLetters[index + 1].col {
                        connectionTypes[index].leftTop = true
                        connectionTypes[index + 1].rightBottom = true
                    } else if usedLetters[index].col < usedLetters[index + 1].col {
                        connectionTypes[index].rightTop = true
                        connectionTypes[index + 1].leftBottom = true
                    } else {
                        connectionTypes[index].top = true
                        connectionTypes[index + 1].bottom = true
                    }
                }
                if usedLetters[index].col < usedLetters[index + 1].col {
                    if usedLetters[index].row < usedLetters[index + 1].row {
                        connectionTypes[index].rightBottom = true
                        connectionTypes[index + 1].leftTop = true
                    } else if usedLetters[index].row > usedLetters[index + 1].row {
                        connectionTypes[index].rightTop = true
                        connectionTypes[index + 1].leftBottom = true
                    } else {
                        connectionTypes[index].right = true
                        connectionTypes[index + 1].left = true
                    }
                }
                if usedLetters[index].col > usedLetters[index + 1].col {
                    if usedLetters[index].row < usedLetters[index + 1].row {
                        connectionTypes[index].leftBottom = true
                        connectionTypes[index + 1].rightTop = true
                    } else if usedLetters[index].row > usedLetters[index + 1].row {
                        connectionTypes[index].leftTop = true
                        connectionTypes[index + 1].rightBottom = true
                    } else {
                        connectionTypes[index].left = true
                        connectionTypes[index + 1].right = true
                    }
                }
            }
        }
        return connectionTypes
    }

    
    private func analyzeNodesAtLocation(location: CGPoint)->(OK: Bool, col: Int, row: Int) {
        let nodes = self.nodes(at: location)
        for node in nodes {
            if node.name != nil && node.name!.begins(with: "GBD") {
                let parts = node.name?.components(separatedBy: "/")
                if parts!.count == 3 {
                    if let col = Int(parts![1]) {
                        if let row = Int(parts![2]) {
                            return(OK: true, col: col, row: row)
                        }
                    }
                }
            }
        }
        return (OK:false, col: 0, row: 0)
    }
    

    var positions = [ObjectSP]()
    var fixWordsHeader: MyLabel!
    var goBackButton: MyButton!
    var showMyWordsButton: MyButton!
    var scoreLabel: MyLabel!
    let fontSize: CGFloat = GV.onIpad ? 22 : 18
    public func playingGame() {
        let sizeMultiplierIPhone: [CGFloat] = [0, 0, 0, 0, 0, 0.13, 0.11, 0.095, 0.09, 0.085, 0.08]
        let sizeMultiplierIPad:   [CGFloat] = [0, 0, 0, 0, 0, 0.1, 0.1, 0.10, 0.09, 0.08, 0.07]
        removeChildrenExceptTypes(from: gameLayer, types: [.Background])
        let sizeMultiplier = GV.onIpad ? sizeMultiplierIPad : sizeMultiplierIPhone
        let blockSize = GV.minSide * sizeMultiplier[GV.size]
        GV.blockSize = blockSize
        GV.playingGrid = Grid(blockSize: blockSize * 1.1, rows: GV.size, cols: GV.size)
        let gridLposX = GV.maxSide - GV.playingGrid!.size.width * 0.65
        GV.gameArray = createNewGameArray(size: GV.size)
        let gameHeaderPosition = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: GV.maxSide * 0.92),
                                           LPos: CGPoint(x: gridLposX , y: GV.minSide * 0.94))
        let scoreLabelPosition = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: gameHeaderPosition.PPos.y - GV.maxSide * 0.02),
                                           LPos: CGPoint(x: gridLposX , y: GV.minSide * 0.90))
        let gridPosition = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: scoreLabelPosition.PPos.y - GV.maxSide * 0.02 - (GV.playingGrid!.size.height) / 2),
                                     LPos: CGPoint(x: gridLposX, y: GV.minSide * 0.89 - GV.playingGrid!.size.height * 0.52),
                                     PSize: GV.playingGrid!.size,
                                     LSize: GV.playingGrid!.size)
        let gameHeader = MyLabel(text: GV.language.getText(.tcSearchWords, values: "\(GV.size)x\(GV.size)"), position: gameHeaderPosition, fontName: GV.headerFontName, fontSize: fontSize)
        gameLayer.addChild(gameHeader) // index 0
        GV.playingGrid!.plPosSize = gridPosition
        GV.playingGrid!.setActPosSize()
        GV.playingGrid!.zPosition = 20
        gameLayer.addChild(GV.playingGrid!)

        let fixWordsHeaderPosition = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.3, y: gridPosition.PPos.y - GV.playingGrid!.plPosSize!.PSize!.height * 0.55),
                                               LPos: CGPoint(x: GV.maxSide * 0.18, y: gameHeaderPosition.LPos.y))
        fixWordsHeader = MyLabel(text: GV.language.getText(.tcFixWords), position: fixWordsHeaderPosition, fontName: GV.headerFontName, fontSize: fontSize)
        gameLayer.addChild(fixWordsHeader)

        scoreLabel = MyLabel(text: GV.language.getText(.tcScore, values: String(0)), position: scoreLabelPosition, fontName: GV.headerFontName, fontSize: fontSize)
        gameLayer.addChild(scoreLabel!) // index 0


        let primary = GV.actLanguage + GV.innerSeparator + String(GV.gameNumber) + GV.innerSeparator + String(GV.size)
        let origGames = gamesRealm.objects(Games.self).filter("primary = %@", primary)
        if origGames.count > 0 {
            let origGame = origGames.first!
            fillGameArray(gameArray: GV.gameArray, content:  origGame.gameArray, toGrid: GV.playingGrid!)
            let myGame = playedGamesRealm!.objects(PlayedGame.self).filter("primary = %@", primary)
            if myGame.count == 0 {
                createNewPlayedGame(to: origGame)
            } else {
                playedGame = myGame.first!
            }
            goBackButton = addButtonPL(to: gameLayer, text: GV.language.getText(.tcBack), action: #selector(goBackToMainMenu), line: GoBack)
            possibleLineCountP = abs((fixWordsHeader.plPosSize?.PPos.y)! - (goBackButton.frame.maxY)) / (1.2 * ("A".height(font: wordFont!)))
            possibleLineCountL = abs((fixWordsHeader.plPosSize?.LPos.y)! - (goBackButton.frame.maxY)) / (1.2 * ("A".height(font: wordFont!)))
            firstWordPositionYP = ((fixWordsHeader.plPosSize?.PPos.y)!) - GV.maxSide * 0.04
            firstWordPositionYL = ((fixWordsHeader.plPosSize?.LPos.y)!) - GV.maxSide * 0.04
            fillMandatoryWords()
            setGameArrayToActualState()
            showMyWordsButton = addButtonPL(to: gameLayer, text: GV.language.getText(.tcShowMyWords, values: String(getMyWordsCount())), action: #selector(showMyWords), line: ShowMyWords)
        }
    }
    
    let wordFont = UIFont(name: GV.headerFontName, size: GV.wordsFontSize)
    var firstWordPositionYP: CGFloat = 0
    var firstWordPositionYL: CGFloat = 0
    var possibleLineCountP: CGFloat = 0
    var possibleLineCountL: CGFloat = 0
    var showMyWordsTableView: TableView!
    var showWordsOverPositionTableView: TableView!

    
    enum TableType: Int {
        case None = 0, ShowMyWords, ShowWordsOverPosition, ShowFoundedWords, ShowHints
    }
    private var tableType: TableType = .None
    private var myWordsForShow: WordsForShow!
    private var wordList: WordsForShow!

    struct WordsForShow {
        var words = [MyFoundedWordsForTable]()
        var countWords = 0
        var countAllWords = 0
        var score = 0
        init(words: [MyFoundedWordsForTable]) {
            self.words = words
            countWords = words.count
            for item in words {
                countAllWords += item.counter
                self.score += item.score
            }
        }
    }
    
    private var tableHeader = ""
    private var lengthOfWord = 0
    private var lengthOfCnt = 0
    private var lengthOfLength = 0
    private var lengthOfScore = 0
    private let myTableFont  = UIFont(name: "CourierNewPS-BoldMT", size: GV.onIpad ? 18 : 18)!
    
    private func calculateColumnWidths(showScore: Bool) {
        tableHeader = ""
        let fixlength = GV.onIpad ? 15 : 10
        lengthOfWord = globalMaxLength < fixlength ? fixlength : globalMaxLength
        let text1 = " \(GV.language.getText(.tcWord).fixLength(length: lengthOfWord, center: true))     "
        let text2 = "\(GV.language.getText(.tcCount)) "
        let text3 = "\(GV.language.getText(.tcLength)) "
        let text4 = showScore ? "\(GV.language.getText(.tcScoreTxt)) " : ""
        tableHeader += text1
        tableHeader += text2
        tableHeader += text3
        tableHeader += text4
        lengthOfCnt = text2.length
        lengthOfLength = text3.length
        lengthOfScore = text4.length + (showScore ? 0 : 4)
    }

    private var globalMaxLength = 0

    
    @objc private func showMyWords() {
        stopShowingTableIfNeeded()
        showOwnWordsInTableView()
    }
    private func showOwnWordsInTableView() {
        showMyWordsTableView = TableView()

        tableType = .ShowMyWords
        var words: [MyFoundedWordsForTable]
//        var score = 0
        (words, globalMaxLength, _) = getMyWordsForShow()
        myWordsForShow = WordsForShow(words: words)
        calculateColumnWidths(showScore: true)
        let suffix = " (\(myWordsForShow.countWords)/\(myWordsForShow.countAllWords)/\(myWordsForShow.score))"
        let headerText = (GV.language.getText(.tcCollectedOwnWords) + suffix)
        let actWidth = max(tableHeader.width(font: myTableFont), headerText.width(font: myTableFont)) * 1.2

        showMyWordsTableView.setDelegate(delegate: self)
        showMyWordsTableView.register(CustomTableViewCell.self, forCellReuseIdentifier: "cell")
        let origin = CGPoint(x: 0.5 * (self.frame.width - actWidth), y: self.frame.height * 0.08)
        let lineHeight = tableHeader.height(font:myTableFont)
        let headerframeHeight = lineHeight * 2.3
        var showingWordsHeight = CGFloat(myWordsForShow!.words.count + 1) * lineHeight
        if showingWordsHeight  > self.frame.height * 0.8 {
            var counter = CGFloat(myWordsForShow!.words.count)
            repeat {
                counter -= 1
                showingWordsHeight = lineHeight * counter
            } while showingWordsHeight + headerframeHeight > self.frame.height * 0.8
        }
        if globalMaxLength < GV.language.getText(.tcWord).count {
            globalMaxLength = GV.language.getText(.tcWord).count
        }
        let size = CGSize(width: actWidth, height: showingWordsHeight + headerframeHeight)
        showMyWordsTableView?.frame=CGRect(origin: origin, size: size)
        self.showMyWordsTableView?.reloadData()
//        self.scene?.alpha = 0.2
        self.scene?.view?.addSubview(showMyWordsTableView!)
    }
    struct MyFoundedWordsForTable {
        var word = ""
        var length = 0
        var score = 0
        var counter = 0
    }
    private func getMyWordsForShow()->([MyFoundedWordsForTable], Int, Int) {
        var returnWords = [MyFoundedWordsForTable]()
        var maxLength = 0
        var returnScore = 0
        for label in myLabels {
            if !label.mandatory || label.founded {
                let word = label.usedWord!.word  + (label.founded ? "*" : "")
                let length = label.usedWord!.word.count
                if !returnWords.contains(where: {$0.word == word}) {
                    let score = label.founded ? 0 : word.length * 50
                    returnWords.append(MyFoundedWordsForTable(word: word, length: length, score: score, counter: 1))
                    returnScore += score
                    if maxLength < word.length {
                        maxLength = word.length
                    }
                } else {
                    for index in 0..<returnWords.count {
                        if returnWords[index].word == word {
                            returnWords[index].counter += 1
                            returnScore -= returnWords[index].score
                            returnWords[index].score *= 2
                            returnScore += returnWords[index].score
                        }
                    }
                }
            }
        }
            returnWords = returnWords.sorted(by:{$0.length > $1.length ||
                                                ($0.length == $1.length && ($0.counter > $1.counter || $0.word < $1.word))
        })
        return (returnWords, maxLength, returnScore)
    }

    
    private func getMyWordsCount()->Int {
        var returnValue = 0
        for label in myLabels {
            returnValue += label.isHidden ? 1 : 0
        }
        return returnValue
    }

    private func fillMandatoryWords() {
        let mandatoryWordsInDB = playedGame.wordsToFind.components(separatedBy: GV.outerSeparator)
        for wordString in mandatoryWordsInDB {
            mandatoryWords.append(UsedWord(from: wordString))
        }
        mandatoryWords = mandatoryWords.sorted(by: {$0.word.count > $1.word.count || ($0.word.count == $1.word.count && $0.word < $1.word)})
    }
    
    var myLabels = [MyFoundedWord]()
    var mandatoryWords = [UsedWord]()
    var allWords = [UsedWord]()
    
    private func addButton(to: SKNode, text: String, action: Selector, line: CGFloat, name: String? = nil) {
        let button = MyButton(fontName: GV.headerFontName, size: CGSize(width: GV.maxSide * 1.1, height: GV.minSide * 0.08))
        button.zPosition = self.zPosition + 20
        button.setButtonLabel(title: text, font: UIFont(name: GV.headerFontName, size: GV.minSide * 0.04)!)
        button.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: action)
        if line == GoBack {
            button.position = CGPoint(x: self.frame.width * 0.5, y: (self.frame.height * 0.2))
        } else {
            button.position = CGPoint(x: self.frame.width * 0.5, y: (self.frame.height * 0.8) - (line * GV.maxSide * 0.06))
        }
        button.size = CGSize(width: GV.minSide * 0.6, height: GV.maxSide * 0.05)
        button.name = name
        to.addChild(button)
    }
    

    @objc private func goBackToMainMenu() {
        stopShowingTableIfNeeded()
        goBack()
    }
  
    private func setGameArrayToActualState() {
        var counter = 0
        let myWordsInDB = playedGame.myWords.components(separatedBy: GV.outerSeparator)
        iterateGameArray(doing: {(col: Int, row: Int) in
            GV.gameArray[col][row].resetCountOccurencesInWords()
        })
        func setPLPos(counter: Int)->PLPosSize {
            let colP = counter / Int(possibleLineCountP)
            let colL = counter / Int(possibleLineCountL)
            let rowP = counter % Int(possibleLineCountP)
            let rowL = counter % Int(possibleLineCountL)
            let wordWidth = CGFloat("A".fill(with: "A", toLength: 15).width(font: wordFont!))
            let wordHeight = CGFloat("A".height(font: wordFont!))
            return PLPosSize(PPos: CGPoint(x: (GV.minSide * 0.1) + (CGFloat(colP) * wordWidth), y: firstWordPositionYP - wordHeight * CGFloat(rowP)),
                             LPos: CGPoint(x: (GV.maxSide * 0.05) + (CGFloat(colL) * wordWidth), y: firstWordPositionYL - wordHeight * CGFloat(rowL)))
        }
        for item in mandatoryWords.sorted(by: {$0.word.count > $1.word.count || ($0.word.count > $1.word.count && $0.word < $1.word)}) {
            if !myLabels.contains(where: {$0.usedWord! == item}) {
                let myWord = MyFoundedWord(usedWord: item, mandatory: true, prefixValue: counter + 1)
                myWord.plPosSize = setPLPos(counter: counter)
                myWord.setActPosSize()
                gameLayer.addChild(myWord)
                myLabels.append(myWord)
            }
            counter += 1
        }
        
        if myWordsInDB.count > 0 {
            for item in myWordsInDB {
                if item != "" {
                    let usedWord = UsedWord(from: item)
                    if !allWords.contains(where: {$0 == usedWord}){
                        allWords.append(usedWord)
                    }
                    for usedLetter in usedWord.usedLetters {
                        let cell = GV.gameArray[usedLetter.col][usedLetter.row]
                        if usedLetter.letter == cell.letter {
                            cell.setStatus(toStatus: .WholeWord)
                        }
                    }
                    let connectionTypes = setConnectionTypes(usedLetters: usedWord.usedLetters)
                    for (index, item) in usedWord.usedLetters.enumerated() {
                        GV.gameArray[item.col][item.row].setStatus(toStatus: .WholeWord, connectionType: connectionTypes[index], incrWords: true)
                    }
 
                    if !mandatoryWords.contains(where: {$0 == usedWord}) {
                        counter += 1
                        if !myLabels.filter({!$0.mandatory}).contains(where: {$0.usedWord! == usedWord}) {
                            let myWord = MyFoundedWord(usedWord: usedWord, mandatory: false, prefixValue: counter + 1)
                            myWord.plPosSize = setPLPos(counter: counter)
                            myWord.setActPosSize()
                            gameLayer.addChild(myWord)
                            myLabels.append(myWord)
                        } else {

                        }
                    }
                }
            }

            for myWord in myLabels {
                if myWord.mandatory {
                    myWord.setQuestionMarks()
                    if allWords.contains(where: {$0 == myWord.usedWord!}) {
                        myWord.fontColor = GV.darkGreen
                        myWord.founded = true
                     }
                } else {
                    myWord.isHidden = true
                    myWord.fontColor = .red
                }
            }
            let (_, _, score) = getMyWordsForShow()
            scoreLabel!.text = GV.language.getText(.tcScore, values: String(score), String(0))
        }
        iterateGameArray(doing: {(col: Int, row: Int) in
            GV.gameArray[col][row].showConnections()
        })
    }
    
    private func iterateGameArray(doing: (_ col: Int, _ row: Int)->()) {
        for col in 0..<GV.size {
            for row in 0..<GV.size {
                doing(col, row)
            }
        }
    }
    
    private func createNewPlayedGame(to origGame: Games) {
        try! playedGamesRealm!.safeWrite {
            playedGame = PlayedGame()
            playedGame.primary = origGame.primary
            playedGame.language = origGame.language
            playedGame.gameNumber = origGame.gameNumber
            playedGame.gameSize = origGame.size
            playedGame.gameArray = origGame.gameArray
            playedGame.wordsToFind = origGame.words
            playedGame.timeStamp = NSDate()
            playedGamesRealm!.add(playedGame)
        }
    }
    
    private func saveChoosedWord()->Bool {
        let returnValue = !allWords.contains(where: {$0 == choosedWord})//checkChoosedWordInFoundedWordsMyWords()
        if returnValue {
            let addString = choosedWord.toString()
            let separator = playedGame.myWords.count == 0 ? "" : GV.outerSeparator
            try! playedGamesRealm!.safeWrite {
                playedGame.myWords.append(separator + addString)
                playedGame.timeStamp = Date() as NSDate
            }
        }
        return returnValue
    }
    
//    var myFoundedWords = [UsedWord]()
    
    
}
