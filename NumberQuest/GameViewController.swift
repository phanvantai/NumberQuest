//
//  GameViewController.swift
//  NumberQuest
//
//  Created by TaiPV on 25/6/25.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.view as! SKView? {
            // Create the QuickPlayScene
            let scene = QuickPlayScene()
            
            // Set the scale mode to scale to fit the window
            scene.scaleMode = .aspectFill
            
            // Set the scene size to match the view
            scene.size = view.bounds.size
            
            // Present the scene
            view.presentScene(scene)
            
            view.ignoresSiblingOrder = true
            
            // Show debug info for development
            view.showsFPS = true
            view.showsNodeCount = true
        }
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .phone {
            return .allButUpsideDown
        } else {
            return .all
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }
}
