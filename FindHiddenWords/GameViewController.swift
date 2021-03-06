//
//  GameViewController.swift
//  TestGame
//
//  Created by Romhanyi Jozsef on 2020. 05. 09..
//  Copyright © 2020. Romhanyi Jozsef. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import Reachability
import GameKit

class GameViewController: UIViewController, GCHelperDelegate {
    
    var tenMinutesTimer: Timer?

    func matchStarted() {
        
    }
    
    func match(_ match: GKMatch, didReceive didReceiveData: Data, fromPlayer: String) {
        
    }
    
    func matchEnded(error: String) {
        
    }
    
    func localPlayerAuthenticated() {
        GV.developerModus = GCHelper.shared.getName() == GV.myGCName ? true : false
        if GV.developerModus {
            GV.playSearchingWordsScene!.generateDebugButton()
        }
        GV.connectedToGameCenter = true
        GCHelper.shared.getBestScore(completion: {
            GV.playSearchingWordsScene!.modifyScoreLabel()
        })
    }
    
    func localPlayerNotAuthenticated() {
        GV.connectedToInternet = false
        GV.playSearchingWordsScene!.hideWorldBestResults()
        GV.playSearchingWordsScene!.resetDeveloperButton()
    }
    
    func continueTimeCount() {
        
    }
    
    func firstPlaceFounded() {
        
    }
    
    func myPlaceFounded() {
        
    }
    
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        GV.actWidth = size.width
        GV.actHeight = size.height
        GV.deviceOrientation = getDeviceOrientation()
//        print("in viewWillTransition ---- to Size: \(size)---------- \(getDeviceOrientation()) at \(Date())")
        if GV.orientationHandler != nil && GV.target != nil {
            _ = GV.target!.perform(GV.orientationHandler!)
        }
    }
    
    var scene: SKScene!
    
    override func viewWillAppear(_ animated: Bool) {
       super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(deviceRotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: GV.reachability)
   }
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
   }
    
//    @objc func deviceRotated(){
//        if UIDevice.current.orientation.isLandscape {
//               print("Landscape")
//               // Resize other things
//           }
//        if UIDevice.current.orientation.isPortrait {
//               print("Portrait")
//               // Resize other things
//           }
//       }
//
    override func viewDidLoad() {
        super.viewDidLoad()
//        #if DEBUG
//        GV.debugModus = true
//        #endif

        GV.minSide = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        GV.maxSide = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
        GV.actWidth = UIScreen.main.bounds.width
        GV.actHeight = UIScreen.main.bounds.height
        GV.deviceOrientation = getDeviceOrientation()
        var sceneView:SKView!
        sceneView = SKView()
        self.view = sceneView
        GV.mainView = self
        if let view = self.view as! SKView? {
            // Load the SKScene from 'GameScene.sks'
            scene = GameMenuScene()
                // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            scene.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
            view.frame = CGRect(origin: CGPoint(), size: scene.size)
                
                // Present the scene
                view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
        }
        oneMinutesTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(oneMinutesTimer(timerX: )), userInfo: nil, repeats: false)
    }
    
    var oneMinutesTimer: Timer?

    
    @objc private func oneMinutesTimer(timerX: Timer) {
//        print("oneMinutesTimer actTime: \(Date())")
        try! realm.safeWrite() {
            GV.basicData.playingTime += 1
            GV.basicData.playingTimeToday += 1
        }
        if oneMinutesTimer != nil {
            oneMinutesTimer!.invalidate()
        }
        oneMinutesTimer = Timer.scheduledTimer(timeInterval: 60.0, target: self, selector: #selector(oneMinutesTimer(timerX: )), userInfo: nil, repeats: false)
    }
    
    
    @objc func deviceRotated() {
        if GV.orientationHandler != nil && GV.target != nil {
            _ = GV.target!.perform(GV.orientationHandler!)
        }
    }


    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .portrait
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if GV.touchTarget != nil {
            GV.touchParam1 = touches
            GV.touchParam2 = event
            GV.touchType = .Began
            UIApplication.shared.sendAction(GV.touchSelector, to: GV.touchTarget, from: self, for: nil)
        }
    }
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if GV.touchTarget != nil {
            GV.touchParam1 = touches
            GV.touchParam2 = event
            GV.touchType = .Moved
            UIApplication.shared.sendAction(GV.touchSelector, to: GV.touchTarget, from: self, for: nil)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if GV.touchTarget != nil {
            GV.touchParam1 = touches
            GV.touchParam2 = event
            GV.touchType = .Ended
            UIApplication.shared.sendAction(GV.touchSelector, to: GV.touchTarget, from: self, for: nil)
        }

    }
    
    var oldConnectedToInternet = false
    
    
    @objc func reachabilityChanged(note: Notification) {
        
        let reachability = note.object as! Reachability
        
        switch reachability.connection {
        case .wifi:
            GV.connectedToInternet = true
        case .cellular:
            GV.connectedToInternet = true
        case .none:
            GV.connectedToInternet = false
        case .unavailable:
            GV.connectedToInternet = false
        default:
            GV.connectedToInternet = false
        }
        if oldConnectedToInternet != GV.connectedToInternet {
            if GV.connectedToInternet {
                if GV.basicData.actLanguage == "" { // BsiacDataRecord not loaded yet
                    getBasicData()
                }
                GCHelper.shared.authenticateLocalUser(theDelegate: self, presentingViewController: self)
            } else {
                
            }
            oldConnectedToInternet = GV.connectedToInternet
        }
    }



    func printFonts() {
        let fontFamilyNames = UIFont.familyNames
        for familyName in fontFamilyNames {
            print("------------------------------")
            print("Font Family Name = [\(familyName)]")
            let names = UIFont.fontNames(forFamilyName: familyName)
            print("Font Names = [\(names)]")
        }
    }

}
