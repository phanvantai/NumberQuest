//
//  SceneManager.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 26/6/25.
//

import SpriteKit
import UIKit

/// Manages scene transitions and game navigation
class SceneManager {
    
    static let shared = SceneManager()
    
    private weak var currentView: SKView?
    
    private init() {}
    
    /// Set the current SKView for scene management
    func setView(_ view: SKView) {
        self.currentView = view
    }
    
    /// Transition to a new scene with animation
    func transitionToScene(_ newScene: SKScene, transition: SKTransition? = nil) {
        guard let view = currentView else {
            print("⚠️ SceneManager: No view available for transition")
            return
        }
        
        // Set scene size to match view
        newScene.size = view.bounds.size
        newScene.scaleMode = .aspectFill
        
        if let transition = transition {
            view.presentScene(newScene, transition: transition)
        } else {
            // Default fade transition
            let fadeTransition = SKTransition.fade(withDuration: 0.5)
            view.presentScene(newScene, transition: fadeTransition)
        }
    }
    
    /// Navigate to Quick Play mode
    func showQuickPlay() {
        let quickPlayScene = QuickPlayScene()
        let transition = SKTransition.moveIn(with: .left, duration: 0.5)
        transitionToScene(quickPlayScene, transition: transition)
    }
    
    /// Navigate to Campaign mode
    func showCampaign() {
        let campaignMapScene = CampaignMapScene()
        let transition = SKTransition.moveIn(with: .left, duration: 0.5)
        transitionToScene(campaignMapScene, transition: transition)
        
        // Refresh progress after scene is loaded
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            campaignMapScene.refreshCampaignProgress()
        }
    }
    
    /// Navigate to a specific campaign level
    func showCampaignLevel(_ level: CampaignLevel) {
        let campaignLevelScene = CampaignLevelScene(level: level)
        let transition = SKTransition.moveIn(with: .up, duration: 0.5)
        transitionToScene(campaignLevelScene, transition: transition)
    }
    
    /// Navigate to Settings (placeholder for now)
    func showSettings() {
        // TODO: Implement SettingsScene
        print("⚙️ Settings coming soon!")
    }
    
    /// Navigate back to main menu
    func showMainMenu() {
        let mainMenuScene = MainMenuScene()
        let transition = SKTransition.moveIn(with: .right, duration: 0.5)
        transitionToScene(mainMenuScene, transition: transition)
    }
}
