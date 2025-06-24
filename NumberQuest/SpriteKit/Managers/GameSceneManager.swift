//
//  GameSceneManager.swift
//  NumberQuest
//
//  Created by TaiPV on 24/6/25.
//

import SpriteKit
import SwiftUI

/// Scene types available in the game
enum SceneType {
    case mainMenu
    case campaignMap
    case quickPlay  
    case game(GameSession)
    case gameOver(GameSession)
    case settings
    case progress
    case assetValidation
}

/// Manages scene transitions and coordination for SpriteKit scenes
class GameSceneManager: ObservableObject {
    
    // MARK: - Properties
    
    /// Shared instance
    static let shared = GameSceneManager()
    
    /// Current scene view reference
    weak var currentSceneView: SKView?
    
    /// Scene transition animations
    private let transitionDuration: TimeInterval = 0.5
    
    /// Scene history for back navigation
    private var sceneHistory: [SceneType] = []
    
    /// Current active scene type
    @Published var currentSceneType: SceneType = .mainMenu
    
    /// Loading state for scene transitions
    @Published var isLoading: Bool = false
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Scene Management
    
    /// Present a scene with transition animation
    func presentScene(_ sceneType: SceneType, transition: SKTransition? = nil) {
        guard let sceneView = currentSceneView else {
            print("Warning: No scene view available for transition")
            return
        }
        
        // Add current scene to history (if not already there)
        if let currentScene = sceneView.scene as? BaseGameScene {
            // Add to history for back navigation
            sceneHistory.append(getCurrentSceneType(currentScene))
        }
        
        // Create the new scene
        let newScene = createScene(for: sceneType)
        
        // Set up the scene size
        newScene.size = sceneView.bounds.size
        newScene.scaleMode = .resizeFill
        
        // Create transition if not provided
        let sceneTransition = transition ?? createDefaultTransition(for: sceneType)
        
        // Present the scene
        sceneView.presentScene(newScene, transition: sceneTransition)
    }
    
    /// Go back to the previous scene
    func goBack() {
        guard !sceneHistory.isEmpty else {
            print("Warning: No previous scene in history")
            return
        }
        
        let previousScene = sceneHistory.removeLast()
        presentScene(previousScene, transition: SKTransition.doorway(withDuration: transitionDuration))
    }
    
    /// Clear scene history
    func clearHistory() {
        sceneHistory.removeAll()
    }
    
    // MARK: - Scene Creation
    
    /// Create a scene based on the scene type
    private func createScene(for sceneType: SceneType) -> BaseGameScene {
        switch sceneType {
        case .mainMenu:
            return MainMenuScene()
            
        case .campaignMap:
            return CampaignMapScene()
            
        case .quickPlay:
            return QuickPlayScene()
            
        case .game(let session):
            return MainGameScene(gameSession: session)
            
        case .gameOver(let session):
            return GameOverScene(gameSession: session)
            
        case .settings:
            // For now, we'll create a placeholder - might keep as SwiftUI
            return SettingsScene()
            
        case .progress:
            // For now, we'll create a placeholder - might keep as SwiftUI
            return ProgressScene()
            
        case .assetValidation:
            return AssetValidationScene()
        }
    }
    
    /// Create default transition animation for scene type
    private func createDefaultTransition(for sceneType: SceneType) -> SKTransition {
        switch sceneType {
        case .mainMenu:
            return SKTransition.fade(withDuration: transitionDuration)
            
        case .campaignMap, .quickPlay:
            return SKTransition.push(with: .left, duration: transitionDuration)
            
        case .game:
            return SKTransition.doorway(withDuration: transitionDuration)
            
        case .gameOver:
            return SKTransition.flipVertical(withDuration: transitionDuration)
            
        case .settings, .progress, .assetValidation:
            return SKTransition.moveIn(with: .up, duration: transitionDuration)
        }
    }
    
    /// Get current scene type from scene instance
    private func getCurrentSceneType(_ scene: BaseGameScene) -> SceneType {
        switch scene {
        case is MainMenuScene:
            return .mainMenu
        case is CampaignMapScene:
            return .campaignMap
        case is QuickPlayScene:
            return .quickPlay
        case let gameScene as MainGameScene:
            return .game(gameScene.gameSession)
        case let gameOverScene as GameOverScene:
            return .gameOver(gameOverScene.gameSession)
        case is SettingsScene:
            return .settings
        case is ProgressScene:
            return .progress
        default:
            return .mainMenu
        }
    }
}

// MARK: - Scene Placeholder Classes

/// CampaignMapScene - implemented in CampaignMapScene.swift
/// See CampaignMapScene class for the actual implementation

/// QuickPlayScene - implemented in QuickPlayScene.swift
/// See QuickPlayScene class for the actual implementation

/// Main game scene - implemented in MainGameScene.swift
/// See MainGameScene class for the actual gameplay implementation

/// Game over scene - implemented in GameOverScene.swift
/// See GameOverScene class for the actual implementation

/// Progress scene - implemented in ProgressScene.swift
/// See ProgressScene class for the actual implementation
