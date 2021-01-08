//
//  GameScene.swift
//  TestGame
//
//  Created by Romhanyi Jozsef on 2020. 05. 09..
//  Copyright © 2020. Romhanyi Jozsef. All rights reserved.
//

import SpriteKit
import GameplayKit
import Realm
import RealmSwift

var grid: Grid?
//var gamesRealm: Realm?
var playedGamesRealm: Realm?
var wordLabels = [SKLabelNode]()
var errorLabel = SKLabelNode(fontNamed: GV.actFont)
var playSearchingWordsScene: PlaySearchingWords?
//var playWithCubeOfWords: PlayWithCubeOfWords?


class GameMenuScene: SKScene, PlaySearchingWordsDelegate {
    func goBack() {
        closePopup()
        GV.target = self
        GV.orientationHandler = #selector(handleOrientation)
        showMainMenu()
    }
    
    private var label : SKLabelNode?
    private var spinnyNode : SKShapeNode?
    private var labelOfState = SKLabelNode(fontNamed: GV.actFont)
    private var labelOfGameCount = SKLabelNode(fontNamed: GV.actFont)
    private var labelOfEmptyCells1 = SKLabelNode(fontNamed: GV.actFont)
    private var labelOfEmptyCells2 = SKLabelNode(fontNamed: GV.actFont)
    private var skView: SKView?
//    private var myBackground: SKSpriteNode?
    private var popup: SKView?
//    private var menuLayer: SKSpriteNode?
    private var menuLayer: SKScene?
    
    private func showPopupScene(_ scene : SKScene) {

        (self.view)?.scene?.isPaused = true
        self.isHidden = true
        self.isUserInteractionEnabled = false
        popup?.isHidden=false
        popup?.presentScene(scene)

    }
    
//    private func showPopupScene(_ scene : SCNScene) {
//        let myScene = scene as! PlayWithCubeOfWords
//        let sceneView = SCNView(frame: CGRect(x: 0, y: 0, width: self.view!.frame.width, height: self.view!.frame.height))
//        sceneView.allowsCameraControl = true
////        sceneView.isUserInteractionEnabled = false
////        sceneView.showsStatistics = true
////        sceneView.autoenablesDefaultLighting = true
//        sceneView.isUserInteractionEnabled = true
//        sceneView.scene = scene
//        GV.mainView!.view.addSubview(sceneView)
//        (self.view)?.scene?.isPaused = true
//        self.isHidden = true
//        self.isUserInteractionEnabled = false
//        popup?.isHidden=false
//        myScene.sceneView = sceneView
//        myScene.start()
//        sceneView.present(scene,
//                          with: SKTransition.fade(withDuration: 1.0),
//            incomingPointOfView: nil,
//            completionHandler: nil)
//
//
//
//    }

//
    private func closePopup() {
        popup?.isHidden=true
        if let v=view {
            v.scene?.isPaused=false
            self.isHidden = false
            self.isUserInteractionEnabled = true
        }
    }

    
    override func didMove(to view: SKView) {
//        generateNewRealm(oldRealmName: "OrigGames.realm", newRealmName: "RO_Games.realm")
        #if SIMULATOR
            GV.actDevice = DeviceType.getActDevice()
        #endif
        
//        let octagon = DrawImages.drawOctagon(size: CGSize(width: 250, height: 250))

        menuLayer = self
//        newWordListRealm = getNewWordList()
//        gamesRealm = getGames()!
        headerMpx = GV.onIpad ? 0.06 : 0.1
//        generateAssets()
//        generateScreenShotsForAllDevices()
        oldOrientation = getDeviceOrientation()
        getBasicData()
//        setGlobalSizes()
//        menuLayer = SKSpriteNode()
//        let xxx = menuLayer!
//        menuLayer!.color = .red
//        menuLayer?.backgroundColor = .red
        self.size = CGSize(width: GV.actWidth, height: GV.actHeight)
        menuLayer!.size = self.size
        menuLayer!.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
//        self.backgroundColor = .green
//        self.addChild(menuLayer!)
        setBackground(to: self)
//        setBackground(to: menuLayer!)
//        gamesRealm = getRealm(type: .GamesRealm)
//        initiateGames()
        let psize = UIScreen.main.bounds
        popup = SKView.init(frame: psize)
        self.view!.addSubview(popup!)
        popup?.allowsTransparency=true
        popup?.isHidden=true

        let blockSize = self.frame.width / 15
        GV.target = self
        GV.orientationHandler = #selector(handleOrientation)
        GV.blockSize = blockSize
        GV.parentScene = self
//        GV.buttonFontSize = self.frame.width * 0.040
        GV.oldSize = 0
        GV.size = 0
        showMainMenu()
    }
    
    private func generateAssets() {
        let assetSizes = [20, 29, 40, 58, 60, 76, 87, 80, 120, 152, 167, 180, 1024]
        for size in assetSizes {
            let node = SKSpriteNode(imageNamed: "AppIcon.png")
//            node.size = CGSize(width: size, height: size)
            let toFileName = "AppIcon\(size).png"
            saveImage (toFile: toFileName, fromNode: node, size: size)
        }
    }
    
//    enum ScreenStates: Int {
//        case Nothing = 0, MainMenu, LanguageMenu, GameMenu, DeveloperMenu, GeneratingGames
//    }
//    var actScreenState: ScreenStates = .Nothing
    var oldOrientation: MyDeviceOrientation!

    @objc private func handleOrientation() {
//        let rootWindow = UIWindow(frame: UIScreen.main.bounds)
//        let screenSize = DeviceType.getActDevice().getSize()
//        Projector.display(rootWindow: rootWindow, testingSize: screenSize)
//        if oldOrientation == getDeviceOrientation() {
//            return
//        }
        oldOrientation = getDeviceOrientation()
        self.size = CGSize(width: GV.actWidth,height: GV.actHeight)
        self.view!.frame = CGRect(x: 0, y: 0, width: GV.actWidth, height: GV.actHeight)
//        let xxx = menuLayer!
//        menuLayer!.size = self.size
        menuLayer!.setPosAndSizeForAllChildren()
        setBackground(to: menuLayer!)
//        print("in function handleOrientation: \(getDeviceOrientation())")
 //        menuLayer!.backgroundColor = .red
//        menuLayer!.position = CGPoint(x: GV.actWidth / 2, y: GV.actHeight / 2)
        scaleMode = .aspectFill //.aspectFit //.fill //.resizeFill
    }
    
    private func createWordLabels() {
        wordFontSize = GV.minSide * (GV.onIpad ? 0.015 : 0.03)
        for wordLabel in wordLabels {
            wordLabel.text = ""
        }
        if wordLabels.count == 0 {
            let firstY = GV.actHeight * 0.88
            let firstX = GV.actWidth * 0.2
            let xAdder = GV.actWidth * 0.3
            for col in 0...2 {
                for row in 0...11 {
                    let label = SKLabelNode(fontNamed: GV.actFont)
                    label.text = ""
                    label.verticalAlignmentMode = .center
                    label.horizontalAlignmentMode = .left
                    label.fontSize = wordFontSize
                    label.fontColor = SKColor.black
                    label.position = CGPoint(x: firstX + CGFloat(col) * xAdder , y: firstY - CGFloat(row * 21))
                    label.zPosition = 10
                    wordLabels.append(label)
                    self.addChild(label)
                }
            }
        }
        if self.childNode(withName: "ErrorLabel") == nil {
            errorLabel.text = "No error records"
            errorLabel.verticalAlignmentMode = .center
            errorLabel.horizontalAlignmentMode = .left
            errorLabel.fontSize = wordFontSize
            errorLabel.fontColor = SKColor.black
            errorLabel.position = CGPoint(x: GV.actWidth * 0.2, y: GV.actHeight * 0.90)
            errorLabel.zPosition = 10
            errorLabel.name = "ErrorLabel"
            self.addChild(errorLabel)
        }
    }
    
    let deviceDimensions: [String: CGSize] = [
         "01 iPhone 5P"    : CGSize(width: 320, height: 568),
         "02 iPhone 5L"    : CGSize(width: 568, height: 320),
         "03 iPhone 6P"    : CGSize(width: 375, height: 667),
         "04 iPhone 6L"    : CGSize(width: 667, height: 375),
         "05 iPhone 6+P"   : CGSize(width: 414, height: 736),
         "06 iPhone 6+L"   : CGSize(width: 736, height: 414),
         "07 iPhone XP"    : CGSize(width: 375, height: 812),
         "08 iPhone XL"    : CGSize(width: 812, height: 375),
         "09 iPhone 11P"   : CGSize(width: 414, height: 896),
         "10 iPhone 11L"   : CGSize(width: 896, height: 414),
    ]
    
    private func generateScreenShotsForAllDevices() {
        for dimension in deviceDimensions.sorted(by: {$0.key < $1.key}) {
            GV.actWidth = dimension.value.width
            GV.actHeight = dimension.value.height
            GV.minSide = min(GV.actWidth, GV.actHeight)
            GV.maxSide = max(GV.actWidth, GV.actHeight)
//            if dimension.value.width > dimension.value.height {
//                GV.isPortrait = false
//            } else {
//                GV.isPortrait = true
//            }
            menuLayer!.size = CGSize(width: GV.actWidth,height: GV.actHeight)
            setBackground(to: menuLayer!)
            showMainMenu(dimension: dimension.key)
//            let layer1 = menuLayer!
            saveImage(toFile: "MainMenu\(dimension).png", from: menuLayer!, deviceSize: dimension.value)
            showLanguageMenu(dimension: dimension.key)
            saveImage(toFile: "LanguageMenu\(dimension).png", from: menuLayer!, deviceSize: dimension.value)
        }
        self.size = UIScreen.main.bounds.size
        GV.actWidth = self.frame.width
        GV.actHeight = self.frame.height
        GV.minSide = min(GV.actWidth, GV.actHeight)
        GV.maxSide = max(GV.actWidth, GV.actHeight)
    }
    
//    private func setMainMenuSizesAndPositions() {
//        let heightMpx: CGFloat = GV.onIpad ? 0.04 : 0.06
//
//        if GV.isPortrait {
//            let frames: [CGRect] = [
//                CGRect(x: GV.minSide * 0.5, y: GV.maxSide * 0.90, width: GV.minSide * 0.5, height: GV.maxSide * heightMpx),
//                CGRect(x: GV.minSide * 0.5, y: GV.maxSide * 0.85, width: GV.minSide * 0.5, height: GV.maxSide * heightMpx),
//                CGRect(x: GV.minSide * 0.5, y: GV.maxSide * 0.80, width: GV.minSide * 0.5, height: GV.maxSide * heightMpx),
//                CGRect(x: GV.minSide * 0.5, y: GV.maxSide * 0.75, width: GV.minSide * 0.5, height: GV.maxSide * heightMpx),
//            ]
////            setPosItionsAndSizesOfNodesWithActNames(layer: menuLayer!, frames: frames, actNames: actNames)
//        } else {
//            let yPos1: CGFloat = GV.actHeight - GV.actHeight * (GV.onIpad ? 0.10 : 0.10)
//            let yPos2: CGFloat = GV.actHeight - GV.actHeight * (GV.onIpad ? 0.20 : 0.20)
//            let yPos3: CGFloat = GV.actHeight - GV.actHeight * (GV.onIpad ? 0.26 : 0.32)
//            let yPos4: CGFloat = GV.actHeight - GV.actHeight * (GV.onIpad ? 0.32 : 0.44)
//
//            let frames: [CGRect] = [
//                CGRect(x: GV.actWidth * 0.5, y: yPos1, width: GV.minSide * 0.5, height: GV.maxSide * heightMpx),
//                CGRect(x: GV.actWidth * 0.5, y: yPos2, width: GV.minSide * 0.5, height: GV.maxSide * heightMpx),
//                CGRect(x: GV.actWidth * 0.5, y: yPos3, width: GV.minSide * 0.5, height: GV.maxSide * heightMpx),
//                CGRect(x: GV.actWidth * 0.5, y: yPos4, width: GV.minSide * 0.5, height: GV.maxSide * heightMpx),
//            ]
////            setPosItionsAndSizesOfNodesWithActNames(layer: menuLayer!, frames: frames, actNames: actNames)
//
//        }
//    }
    
    @objc private func showMainMenu() {
        showMainMenu(dimension: "")
    }
    
    var headerMpx: CGFloat = 0
    
  
    @objc private func showMainMenu(dimension: String  = "") {
//        let xxx = menuLayer!
        let isPortrait = getDeviceOrientation() == .Portrait
        removeChildrenExceptTypes(from: menuLayer!, types: [.Background])
        let mainTitlePosition = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: GV.maxSide * 0.9),
                                          LPos: CGPoint(x: GV.maxSide * 0.5, y: GV.minSide * 0.9),
                                          PSize: nil,
                                          LSize: nil)
        let mainMenuHeader = MyLabel(text: GV.language.getText(.tcMainTitle), position: mainTitlePosition, fontName: GV.fontName, fontSize: GV.minSide * headerMpx)
        mainMenuHeader.position = isPortrait ? mainTitlePosition.PPos : mainTitlePosition.LPos
//        mainMenuHeader.position = isPortrait ? CGPoint() : CGPoint()
        menuLayer!.addChild(mainMenuHeader)
        addButtonPL(to: menuLayer!, text: GV.language.getText(.tcStartGame), action: #selector(showGameMenu), line: 0)
        addButtonPL(to: menuLayer!, text: GV.language.getText(.tcChooseLanguage), action: #selector(showLanguageMenu), line: 1)
        addButtonPL(to: menuLayer!, text: GV.language.getText(.tcDeveloperMenu), action: #selector(showDeveloperMenu), line: 2)
        menuLayer!.setPosAndSizeForAllChildren()
    }
    

    private func saveImage (toFile: String, from: SKScene? = nil, fromNode: SKSpriteNode? = nil, size: Int = 0, deviceSize: CGSize = CGSize(width: 0, height: 0)) {
//        #if SIMULATOR
        var texture: SKTexture?
        if from != nil {
            texture = SKView().texture(from: from!)!
        } else {
            texture = SKView().texture(from: fromNode!)!
        }
        if texture != nil {
            let myCGImage = (texture!.cgImage())
            let image = UIImage(cgImage: myCGImage)
            var resizeFactor: CGFloat = CGFloat(size)
            if resizeFactor == 0 && deviceSize != CGSize(width: 0, height: 0) {
                resizeFactor = deviceSize.width / image.size.width
            }
            let newImage = image.resizeImage(newWidth: CGFloat(resizeFactor))
//            let newImage = image.resizeImageUsingVImage(size: CGSize(width: GV.actWidth, height: GV.actHeight))
            if let pngImageData = newImage.pngData() {
                let filename = getDocumentsDirectory().appendingPathComponent(toFile)
                try? pngImageData.write(to: filename)
            }
        }
//        #endif
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory
    }
    
//    private func addButtonPL(to: SKNode, text: String, action: Selector, line: CGFloat, name: String? = nil) {
//        let button = MyButton(fontName: GV.fontName, size: CGSize(width: GV.maxSide * 1.1, height: GV.minSide * 0.08))
//        button.zPosition = self.zPosition + 20
//        button.setButtonLabel(title: text, font: UIFont(name: GV.fontName, size: GV.minSide * 0.04)!)
//        button.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: action)
//        if line == GoBack {
//            button.position = CGPoint(x: self.frame.width * 0.5, y: (self.frame.height * 0.2))
//        } else {
//            button.position = CGPoint(x: self.frame.width * 0.5, y: (self.frame.height * 0.8) - (line * GV.maxSide * 0.06))
//        }
//        button.size = CGSize(width: GV.minSide * 0.6, height: GV.maxSide * 0.05)
//        button.name = name
//        to.addChild(button)
//    }
    private func addButtonPL(to: SKNode, text: String, action: Selector, line: CGFloat, buttonWidth: CGFloat=0.6, name: String? = nil) {
        let button = MyButton(fontName: GV.fontName, size: CGSize(width: GV.minSide * buttonWidth, height: GV.maxSide * 0.08))
        button.zPosition = self.zPosition + 20
        button.setButtonLabel(title: text, font: UIFont(name: GV.fontName, size: GV.minSide * 0.04)!)
        button.setButtonAction(target: self, triggerEvent: .TouchUpInside, action: action)
        if line == GoBack {
            button.plPosSize = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: (GV.maxSide * 0.2)),
                                         LPos: CGPoint(x: GV.maxSide * 0.5, y: (GV.minSide * 0.2)),
                                         PSize: CGSize(width: GV.minSide * buttonWidth, height: GV.maxSide * 0.05),
                                         LSize: CGSize(width: GV.minSide * buttonWidth, height: GV.maxSide * 0.05))
        } else {
            button.plPosSize = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: (GV.maxSide * 0.8) - (line * GV.maxSide * 0.06)),
                                         LPos: CGPoint(x: GV.maxSide * 0.5, y: (GV.minSide * 0.8) - (line * GV.maxSide * 0.06)),
                                         PSize: CGSize(width: GV.minSide * buttonWidth, height: GV.maxSide * 0.05),
                                         LSize: CGSize(width: GV.minSide * buttonWidth, height: GV.maxSide * 0.05))
        }
        button.myType = .MyButton
        button.setActPosSize()
//        button.drawBorder()
        button.name = name
        to.addChild(button)
    }

    @objc private func showDeveloperMenu() {
        removeChildrenExceptTypes(from: menuLayer!, types: [.Background])
        let developerHeaderPosition = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: GV.maxSide * 0.9),
                                                LPos: CGPoint(x: GV.maxSide * 0.5, y: GV.minSide * 0.9),
                                                PSize: nil,
                                                LSize: nil)
        let gameMenuHeader = MyLabel(text: GV.language.getText(.tcDeveloperMenuTitle), position: developerHeaderPosition, fontName: GV.fontName, fontSize: GV.minSide * headerMpx)
        gameMenuHeader.zPosition = self.zPosition + 1
        menuLayer!.addChild(gameMenuHeader)
        addButtonPL(to: menuLayer!, text: GV.language.getText(.tcGenerateGameArray), action: #selector(generateGameArray), line: 0)
        addButtonPL(to: menuLayer!, text: GV.language.getText(.tcBack), action: #selector(showMainMenu), line: GoBack)
    }
    
    let fontSize: CGFloat = 28
    var wordFontSize: CGFloat = 18
    
    @objc private func generateGameArray() {
//        let names = ["StateLabel", "GameCountLabel", "emptyCellsLabel1", "emptyCellsLabel2"]
//        removeChildrenWithNames(from: menuLayer!, names: actNames)
//        actScreenState = .GeneratingGames
        labelOfState.text = ""
        labelOfState.verticalAlignmentMode = .center
        labelOfState.fontSize = fontSize * 0.6
        labelOfState.fontColor = SKColor.black
        labelOfState.position = CGPoint(x: self.frame.midX, y: GV.actHeight * 0.94)
        labelOfState.zPosition = 10
//        labelOfState.name = names[0]
        self.addChild(labelOfState)
        labelOfGameCount.text = ""
        labelOfGameCount.verticalAlignmentMode = .center
        labelOfGameCount.fontSize = fontSize * 0.6
        labelOfGameCount.fontColor = SKColor.black
        labelOfGameCount.position = CGPoint(x: self.frame.midX, y: GV.actHeight * 0.92)
        labelOfGameCount.zPosition = 10
//        labelOfGameCount.name = names[1]
        self.addChild(labelOfGameCount)
        labelOfEmptyCells1.text = ""
        labelOfEmptyCells1.verticalAlignmentMode = .center
        labelOfEmptyCells1.fontSize = fontSize * 0.4
        labelOfEmptyCells1.fontColor = SKColor.black
        labelOfEmptyCells1.position = CGPoint(x: self.frame.midX, y: GV.actHeight * 0.08)
        labelOfEmptyCells1.zPosition = 10
//        labelOfEmptyCells1.name = names[2]
        self.addChild(labelOfEmptyCells1)
        labelOfEmptyCells2.text = ""
        labelOfEmptyCells2.verticalAlignmentMode = .center
        labelOfEmptyCells2.fontSize = fontSize * 0.4
        labelOfEmptyCells2.fontColor = SKColor.black
        labelOfEmptyCells2.position = CGPoint(x: self.frame.midX, y: GV.actHeight * 0.05)
        labelOfEmptyCells2.zPosition = 10
//        labelOfEmptyCells2.name = names[2]
        self.addChild(labelOfEmptyCells2)

        generate()
    }
    
    let languages = ["ru", "hu", "de", "en"]
    let maxSize = 10
    let minSize = 5

    
    private func generate() {
        let globalQueue = DispatchQueue.global()
        globalQueue.async {
            self.checkGameRecords()
        }
    }
    var maxGameNumber = 101
    
    private func checkGameRecords() {
        let myRealm = getRealm(type: .GamesRealm)
        emptyCellsProSize1 = Array(repeating: [0, 0, 0, 0, 0, 0, 0, 0, 0], count: 3)
        emptyCellsProSize2 = Array(repeating: [0, 0, 0, 0, 0, 0, 0, 0, 0], count: 3)
//        var repeats = 0
        countErrorGames = 0
        countOKGames = 0
        for size in minSize...maxSize {
            for languageIndex in 0..<languages.count {
                for gameNumber in 0..<maxGameNumber {
                    createWordLabels()
                    let primary = languages[languageIndex] + GV.innerSeparator + String(gameNumber) + GV.innerSeparator + String(size)
//                    if primary == "de°17°7" {
//                        print("hier bei primary: \(primary)")
//                    }
                    let record = myRealm.objects(Games.self).filter("primary = %@", primary)
                    var OKRecord = true
                    labelOfState.text = "Gamenumber: \(gameNumber), language: \(languages[languageIndex]), size: \(size)"
                    labelOfGameCount.text = "OKGames: \(countOKGames), ErrorGames: \(countErrorGames), CountRepeats: 1"
                    if record.count > 0 {
                        OKRecord = checkRecord(record: record.first!)
                        if !OKRecord {
                            try! myRealm.safeWrite {
                                record.first!.errorCount += 1
                            }
                        } else {
//                            emptyCellsProSize[size - 5][countEmptyCells] += 1
                        }
                    } else {
//                        if size < maxSize && languageIndex < 4 {
//                            break
//                        }
                        print(emptyCellsProSize1)
                        print(emptyCellsProSize2)
                    }
                    labelOfEmptyCells1.text = "\(emptyCellsProSize1)"
                    labelOfEmptyCells2.text = "\(emptyCellsProSize2)"
                    if record.count == 0 {
                        print("founded \(countOKGames) OK Records, \(countErrorGames) error Records")
                    }
                    var origOKRecord = OKRecord
                    var countRepeats = 0
                    while record.count == 0 || !OKRecord && countRepeats < 50 {
                        GV.language.setLanguage(languages[languageIndex])
                        GV.gameNumber = gameNumber
                        GV.size = size
                        callGenerating(OKRecord: OKRecord, languageIndex: languageIndex)
                        let record = myRealm.objects(Games.self).filter("primary = %@", primary).first!
                        OKRecord = checkRecord(record: record)
                        if OKRecord && !origOKRecord {
//                            emptyCellsProSize[record.size - 5][countEmptyCells] += 1
//                            countOKGames += 1
                            origOKRecord = true
                        } else {
                            try! myRealm.safeWrite {
                                record.errorCount += 1
                            }
                            for label in wordLabels {
                                label.text = ""
                            }
                        }
                        countRepeats += 1
                        labelOfGameCount.text = "OKGames: \(countOKGames), ErrorGames: \(countErrorGames), CountRepeats: \(countRepeats + 1)"
                    }
                    if countRepeats == 10 {
                        countErrorGames += 1
                        if size - 5 < 3 {
                            emptyCellsProSize1[size - 5][countEmptyCells] += 1
                        } else {
                            emptyCellsProSize2[size - 8][countEmptyCells] += 1
                        }
                    }
                }
            }
        }
    }
    var countErrorGames = 0
    var countOKGames = 0
    
    private func callGenerating(OKRecord: Bool, languageIndex: Int) {
        var repeats = 0
        func waiting() {
            repeats = 0
            repeat {
                repeats += 1
            } while GV.size != GV.oldSize
        }
        waiting()

        if let child = self.childNode(withName: self.gridName) as? SKSpriteNode {
            child.removeFromParent()
        }
        self.createBackgroundShape(size: GV.size)
        let generateGameArray = GenerateGameArray(size: GV.size)
        generateGameArray.start(new: OKRecord)
        waiting()

    }
    var emptyCellsProSize1 = Array(repeating: [0, 0, 0, 0], count: 3)
    var emptyCellsProSize2 = Array(repeating: [0, 0, 0, 0], count: 3)
    private func checkRecord(record: Games)->Bool{
        var cellArray = [(col: Int, row: Int)]()
        let size = record.size
        if !record.OK {
            return false
        }
        let myWords = record.words.components(separatedBy: GV.outerSeparator)
        let gameArray = record.gameArray

        for item in myWords {
            let parts = item.components(separatedBy: GV.innerSeparator)
//            let word = parts.first!
//            print(word)
            var usedLetters = [UsedLetter]()
            for part in parts[1..<parts.count] {
                if let col = Int(part.char(at: 0)) {
                    if let row = Int(part.char(at: 1)) {
                        if !cellArray.contains(where: {$0.col == col && $0.row == row}) {
                            cellArray.append((col: col, row: row))
                        }
                        let letter = part.char(at: 2)
                        let usedLetter = UsedLetter(col: col, row: row, letter: letter)
                        if usedLetters.contains(where: {$0.col == col && $0.row == row && $0.letter == letter}) {
                            return false
                        }
                        usedLetters.append(usedLetter)
                        let gameArrayIndex = (col * size) + row
                        let letterInGameArray = gameArray.char(at: gameArrayIndex)
                        if letter != letterInGameArray {
                            return false
                        }
                    }
                }
            }
        }
        let maxEmptyCells = [0, 0, 0, 0, 0, 0]
        let countEmptyCells = record.size * record.size - cellArray.count
        if countEmptyCells > maxEmptyCells[record.size - 5] {
            print("Error: gameNumber: \(record.gameNumber), language: \(record.language), size: \(record.size), emptyCells: \(countEmptyCells)")
//            emptyCellsProSize[record.size - 5][countEmptyCells] += 1
            return false
        } else {
            if record.size - 5 < 3 {
                emptyCellsProSize1[record.size - 5][countEmptyCells] += 1
            } else {
                emptyCellsProSize2[record.size - 8][countEmptyCells] += 1
            }
            countOKGames += 1
//            print("OK: gameNumber: \(record.gameNumber), language: \(record.language), size: \(record.size), emptyCells: \(countEmptyCells)")
        }
        print("OK: ggameNumber: \(record.gameNumber), language: \(record.language), size: \(record.size), emptyCells: \(countEmptyCells)")
        return true
    }
    
    let gridName = "GridName"
//    var blockSize = CGFloat(0)
    let gameboardCenterY: CGFloat = GV.onIpad ? 0.35 : 0.46
    var countEmptyCells = 0


    
    private func createBackgroundShape(size: Int) {
        //        let myShape =
//        self.blockSize = frame.size.width * (GV.onIpad ? 0.70 : 0.90) / CGFloat(size) //* 0.175
        grid = Grid(blockSize: GV.blockSize, rows:size, cols:size)
        grid!.position = CGPoint (x:frame.midX, y:frame.maxY * gameboardCenterY)
        grid!.name = gridName
        self.addChild(grid!)
    }
    
    @objc private func showGameMenu() {
        removeChildrenExceptTypes(from: menuLayer!, types: [.Background])
        let gameHeaderPosition = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: GV.maxSide * 0.9),
                                           LPos: CGPoint(x: GV.maxSide * 0.5, y: GV.minSide * 0.9),
                                           PSize: nil,
                                           LSize: nil)
        let gameMenuHeader = MyLabel(text: GV.language.getText(.tcStartGame), position: gameHeaderPosition, fontName: GV.fontName, fontSize: GV.minSide * 0.1)
        gameMenuHeader.zPosition = self.zPosition + 1
        menuLayer!.addChild(gameMenuHeader)
//        addButtonPL(to: menuLayer!, text: GV.language.getText(.tcDuelOfWords), action: #selector(duelWords), line: 0)
        addButtonPL(to: menuLayer!, text: "5x5", action: #selector(startGame5), line: 0, buttonWidth: 0.2)
        addButtonPL(to: menuLayer!, text: "6x6", action: #selector(startGame6), line: 1, buttonWidth: 0.2)
        addButtonPL(to: menuLayer!, text: "7x7", action: #selector(startGame7), line: 2, buttonWidth: 0.2)
        addButtonPL(to: menuLayer!, text: "8x8", action: #selector(startGame8), line: 3, buttonWidth: 0.2)
        addButtonPL(to: menuLayer!, text: "9x9", action: #selector(startGame9), line: 4, buttonWidth: 0.2)
        addButtonPL(to: menuLayer!, text: "10x10", action: #selector(startGame10), line: 5, buttonWidth: 0.2)
        addButtonPL(to: menuLayer!, text: GV.language.getText(.tcBack), action: #selector(showMainMenu), line: GoBack, buttonWidth: 0.4)
    }
    
    let GoBack: CGFloat = 1000
    
    @objc private func showLanguageMenu() {
        showLanguageMenu(dimension: "")
    }

    @objc private func showLanguageMenu(dimension: String = "") {
        removeChildrenExceptTypes(from: menuLayer!, types: [.Background])
        let languageTitlePosition = PLPosSize(PPos: CGPoint(x: GV.minSide * 0.5, y: GV.maxSide * 0.9),
                                              LPos: CGPoint(x: GV.maxSide * 0.5, y: GV.minSide * 0.9),
                                              PSize: nil,
                                              LSize: nil)
        let languageMenuHeader = MyLabel(text: GV.language.getText(.tcChooseLanguageTitle), position: languageTitlePosition, fontName: GV.fontName, fontSize: GV.minSide * headerMpx)
        languageMenuHeader.zPosition = self.zPosition + 1
        menuLayer!.addChild(languageMenuHeader)
        addButtonPL(to: menuLayer!, text: GV.language.getText(.tcEnglish), action: #selector(choosedEN), line: 0)
        addButtonPL(to: menuLayer!, text: GV.language.getText(.tcGerman), action: #selector(choosedDE), line: 1)
        addButtonPL(to: menuLayer!, text: GV.language.getText(.tcHungarian), action: #selector(choosedHU), line: 2)
        addButtonPL(to: menuLayer!, text: GV.language.getText(.tcRussian), action: #selector(choosedRU), line: 3)
        addButtonPL(to: menuLayer!, text: GV.language.getText(.tcBack), action: #selector(showMainMenu), line: GoBack)
        menuLayer!.setActPosSize()
    }
    
    @objc private func startGame5() {
        searchWords(size: 5)
    }
    
    @objc private func startGame6() {
        searchWords(size: 6)
    }
    
    @objc private func startGame7() {
        searchWords(size: 7)
    }
    
    @objc private func startGame8() {
        searchWords(size: 8)
    }
    
    @objc private func startGame9() {
        searchWords(size: 9)
    }
    
    @objc private func startGame10() {
        searchWords(size: 10)
    }
    


    

    @objc private func searchWords(size: Int) {
        GV.size = size
        for child in menuLayer!.children {
            if child.myType == .MyButton {
                (child as! MyButton).disableUserInteraction()
            }
        }
        playSearchingWordsScene = PlaySearchingWords(/*fileNamed: "NewGameScene"*/)
        showPopupScene(playSearchingWordsScene!)
        playSearchingWordsScene!.start(delegate: self)
    }
    
    @objc private func cubeOfWords() {
        for child in menuLayer!.children {
            if child.myType == .MyButton {
                (child as! MyButton).disableUserInteraction()
            }
        }
        GV.gameNumber = 0
        GV.size = 5
        
        
        
        let primary: String = GV.actLanguage + GV.innerSeparator + String(GV.gameNumber) + GV.innerSeparator + String(GV.size)
        let game = gamesRealm.objects(Games.self).filter("primary = %@", primary)
        if game.count > 0 {
            GV.gameArray = createNewGameArray()
            let grid = Grid(blockSize: 50, rows: GV.size, cols: GV.size)
            fillGameArray(gameArray: GV.gameArray, content: game.first!.gameArray, toGrid: grid!)
//            playWithCubeOfWords = PlayWithCubeOfWords()
//            showPopupScene(playWithCubeOfWords!)
//            playWithCubeOfWords!.start()
        }
    }
    
    private func fillGameArray(gameArray: [[GameboardItem]], content: String, toGrid: Grid) {
        let size = GV.size
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


    @objc private func choosedEN() {
        GV.language.setLanguage(GV.language.getText(.tcEnglishShort))
        saveBasicData()
        showMainMenu()
    }
    
    @objc private func choosedDE() {
        GV.language.setLanguage(GV.language.getText(.tcGermanShort))
        saveBasicData()
        showMainMenu()
    }
    
    @objc private func choosedHU() {
        GV.language.setLanguage(GV.language.getText(.tcHungarianShort))
        saveBasicData()
        showMainMenu()
    }
    
    @objc private func choosedRU() {
        GV.language.setLanguage(GV.language.getText(.tcRussianShort))
        saveBasicData()
        showMainMenu()
    }
    
    private func saveBasicData() {
        try! realm.safeWrite() {
            GV.basicData.actLanguage = GV.language.getText((.tcAktLanguage))
        }

    }


    override func update(_ currentTime: TimeInterval) {
        if GV.size != GV.oldSize {
            if GV.size > 0 {
                GV.gameArray = createNewGameArray()
            } else {
                if let child = childNode(withName: gridName) {
                    child.removeFromParent()
                    GV.gameArray.removeAll()
//                    self.addChild(child)
                }

            }
            GV.oldSize = GV.size
        }
        // Called before each frame is rendered
    }
    
    private func createNewGameArray() -> [[GameboardItem]] {
        var gameArray: [[GameboardItem]] = []
        
        for i in 0..<GV.size {
            gameArray.append( [GameboardItem]() )
            
            for j in 0..<GV.size {
                gameArray[i].append( GameboardItem() )
                gameArray[i][j].letter = emptyLetter
            }
        }
        return gameArray
    }

    
    private func getBasicData() {
        if realm.objects(BasicData.self).count == 0 {
            GV.basicData = BasicData()
            GV.basicData.actLanguage = GV.language.getText(.tcAktLanguage)
            GV.basicData.creationTime = Date()
            GV.basicData.deviceType = UIDevice().getModelCode()
            GV.basicData.land = GV.convertLocaleToInt()
            GV.basicData.lastPlayingDay = Date().yearMonthDay

            try! realm.safeWrite() {
                realm.add(GV.basicData)
            }
        } else {
            GV.basicData = realm.objects(BasicData.self).first!
            GV.language.setLanguage(GV.basicData.actLanguage)

            if GV.basicData.deviceType == 0 {
                try! realm.safeWrite() {
                    GV.basicData.deviceType = UIDevice().getModelCode()
                    GV.basicData.land = GV.convertLocaleToInt()
               }
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
    
//    private func initiateGames() {
//        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        let gamesURL = documentsURL.appendingPathComponent("Games.realm")
//        let config = Realm.Configuration(
//            fileURL: gamesURL,
//            schemaVersion: 2, // new item words
//            shouldCompactOnLaunch: { totalBytes, usedBytes in
//                // totalBytes refers to the size of the file on disk in bytes (data + free space)
//                // usedBytes refers to the number of bytes used by data in the file
//
//                // Compact if the file is over 100MB in size and less than 50% 'used'
//                let oneMB = 10 * 1024 * 1024
//                return (totalBytes > oneMB) && (Double(usedBytes) / Double(totalBytes)) < 0.8
//        },
//            objectTypes: [Games.self])
//        do {
//            // Realm is compacted on the first open if the configuration block conditions were met.
//            _ = try Realm(configuration: config)
//        } catch {
//            print("error")
//            // handle error compacting or opening Realm
//        }
//
//        gamesRealm = try! Realm(configuration: config)
//        gamesRealm = getRealm()
//    }
    
}
