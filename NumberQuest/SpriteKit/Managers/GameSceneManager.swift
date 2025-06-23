//
//  GameSceneManager.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 21/6/25.
//

import SpriteKit
import SwiftUI

/// Manages scene transitions and navigation for the SpriteKit version of NumberQuest
/// Coordinates between SwiftUI and SpriteKit when using hybrid approach
class GameSceneManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = GameSceneManager()
    
    // MARK: - Properties
    
    /// Current active scene
    @Published var currentScene: BaseScene?
    
    /// Scene history for back navigation
    private var sceneHistory: [SceneType] = []
    
    /// The SKView that displays scenes
    weak var skView: SKView?
    
    /// Game data reference
    var gameData: GameData {
        return GameData.shared
    }
    
    private init() {}
    
    // MARK: - Scene Management
    
    /// Initialize the scene manager with an SKView
    func initialize(with skView: SKView) {
        self.skView = skView
        
        // Configure SKView
        skView.ignoresSiblingOrder = true
        skView.showsFPS = false // Set to true for debugging
        skView.showsNodeCount = false // Set to true for debugging
        
        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        #endif
    }
    
    /// Navigate to a specific scene type
    func navigateToScene(_ sceneType: SceneType, transition: SKTransition? = nil) {
        guard let skView = skView else {
            print("⚠️ SKView not initialized")
            return
        }
        
        // Add current scene to history for back navigation
        if let current = currentScene,
           let currentType = SceneType.from(scene: current) {
            sceneHistory.append(currentType)
        }
        
        // Create the new scene
        let newScene = createScene(for: sceneType)
        let sceneSize = skView.bounds.size
        newScene.size = sceneSize
        
        // Apply transition
        let finalTransition = transition ?? defaultTransition(for: sceneType)
        skView.presentScene(newScene, transition: finalTransition)
        
        currentScene = newScene
        
        print("🎬 Navigated to \(sceneType)")
    }
    
    /// Navigate back to previous scene
    func navigateBack() {
        guard !sceneHistory.isEmpty else {
            print("⚠️ No scene history available")
            return
        }
        
        let previousSceneType = sceneHistory.removeLast()
        navigateToScene(previousSceneType, transition: SKTransition.moveIn(with: .left, duration: 0.3))
    }
    
    /// Present a modal scene (doesn't affect navigation history)
    func presentModal(_ sceneType: SceneType) {
        guard let skView = skView else { return }
        
        let modalScene = createScene(for: sceneType)
        modalScene.size = skView.bounds.size
        
        let transition = SKTransition.moveIn(with: .up, duration: 0.3)
        skView.presentScene(modalScene, transition: transition)
        
        currentScene = modalScene
    }
    
    /// Dismiss current modal and return to previous scene
    func dismissModal() {
        navigateBack()
    }
    
    // MARK: - Scene Creation
    
    private func createScene(for sceneType: SceneType) -> BaseScene {
        switch sceneType {
        case .mainMenu:
            return MainMenuScene()
        case .campaignMap:
            return CampaignMapScene()
        case .quickPlay:
            return QuickPlayScene()
        case .game(let gameMode, let level):
            return GameScene(gameMode: gameMode, level: level)
        case .gameOver(let results):
            return GameOverScene(results: results)
        case .settings:
            return SettingsScene()
        case .progress:
            return ProgressScene()
        }
    }
    
    private func defaultTransition(for sceneType: SceneType) -> SKTransition {
        switch sceneType {
        case .mainMenu:
            return SKTransition.fade(withDuration: 0.5)
        case .campaignMap, .quickPlay:
            return SKTransition.push(with: .left, duration: 0.3)
        case .game:
            return SKTransition.flipHorizontal(withDuration: 0.4)
        case .gameOver:
            return SKTransition.doorway(withDuration: 0.5)
        case .settings, .progress:
            return SKTransition.moveIn(with: .up, duration: 0.3)
        }
    }
    
    // MARK: - Utility Methods
    
    /// Check if we can navigate back
    var canNavigateBack: Bool {
        return !sceneHistory.isEmpty
    }
    
    /// Clear navigation history
    func clearHistory() {
        sceneHistory.removeAll()
    }
    
    /// Get current scene type
    var currentSceneType: SceneType? {
        guard let currentScene = currentScene else { return nil }
        return SceneType.from(scene: currentScene)
    }
}

// MARK: - Scene Types

enum SceneType: Equatable {
    case mainMenu
    case campaignMap
    case quickPlay
    case game(GameMode, GameLevel?)
    case gameOver(GameResults)
    case settings
    case progress
    
    /// Create SceneType from a scene instance
    static func from(scene: BaseScene) -> SceneType? {
        switch scene {
        case is MainMenuScene:
            return .mainMenu
        case is CampaignMapScene:
            return .campaignMap
        case is QuickPlayScene:
            return .quickPlay
        case let gameScene as GameScene:
            return .game(gameScene.gameMode, gameScene.level)
        case let gameOverScene as GameOverScene:
            return .gameOver(gameOverScene.results)
        case is SettingsScene:
            return .settings
        case is ProgressScene:
            return .progress
        default:
            return nil
        }
    }
}

// MARK: - Game Results

struct GameResults: Equatable {
    let score: Int
    let questionsAnswered: Int
    let correctAnswers: Int
    let streak: Int
    let starsEarned: Int
    let timeSpent: TimeInterval
    let gameMode: GameMode
    let level: GameLevel?
    
    var accuracy: Double {
        guard questionsAnswered > 0 else { return 0 }
        return Double(correctAnswers) / Double(questionsAnswered) * 100
    }
}

// MARK: - Placeholder Scene Classes (to be implemented in later steps)

class MainMenuScene: BaseScene {
    override func setupContent() {
        // Placeholder - will be implemented in Phase 4
        let label = SKLabelNode(text: "Main Menu Scene")
        label.fontSize = 32
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: 0)
        addChild(label)
    }
}

class CampaignMapScene: BaseScene {
    override func setupContent() {
        let label = SKLabelNode(text: "Campaign Map Scene")
        label.fontSize = 32
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: 0)
        addChild(label)
    }
}

class QuickPlayScene: BaseScene {
    override func setupContent() {
        let label = SKLabelNode(text: "Quick Play Scene")
        label.fontSize = 32
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: 0)
        addChild(label)
    }
}

class GameOverScene: BaseScene {
    let results: GameResults
    
    init(results: GameResults) {
        self.results = results
        super.init(size: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupContent() {
        let label = SKLabelNode(text: "Game Over Scene")
        label.fontSize = 32
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: 0)
        addChild(label)
    }
}

class SettingsScene: BaseScene {
    override func setupContent() {
        let label = SKLabelNode(text: "Settings Scene")
        label.fontSize = 32
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: 0)
        addChild(label)
    }
}

class ProgressScene: BaseScene {
    override func setupContent() {
        let label = SKLabelNode(text: "Progress Scene")
        label.fontSize = 32
        label.fontColor = .white
        label.position = CGPoint(x: 0, y: 0)
        addChild(label)
    }
}
