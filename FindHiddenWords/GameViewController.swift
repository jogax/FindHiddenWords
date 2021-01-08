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

class GameViewController: UIViewController {
    
    
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
//        NotificationCenter.default.addObserver(self, selector: #selector(rotated), name: UIDevice.orientationDidChangeNotification, object: nil)

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
//            GV.actDevice = DeviceType.getActDevice()
            
//            view.showsFPS = true
//            view.showsNodeCount = true
        }

    }
    
    @objc func deviceRotated() {
//        print("in Rotated ------ \(self.view.frame) -------- at: \(Date())")
//        let localScene = scene
        
//        setGlobalSizes()
//        GV.deviceOrientation = getDeviceOrientation()
        if GV.orientationHandler != nil && GV.target != nil {
            _ = GV.target!.perform(GV.orientationHandler!)
        }
    }


    override var shouldAutorotate: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
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
    

    
//    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
//        super.willTransition(to: newCollection, with: coordinator)
//
//        coordinator.animate(alongsideTransition: { (context) in
//            guard let windowInterfaceOrientation = self.windowInterfaceOrientation else { return }
//
//            if windowInterfaceOrientation.isLandscape {
//                // activate landscape changes
//            } else {
//                // activate portrait changes
//            }
//        })
//    }
//
//    private var windowInterfaceOrientation: UIInterfaceOrientation? {
//        return UIApplication.shared.windows.first?.windowScene?.interfaceOrientation
//    }


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
