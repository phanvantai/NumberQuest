//
//  GameSceneManager.swift
//  NumberQuest
//
//  Created by TaiPV on 24/6/25.
//

import SpriteKit
import SwiftUI

/// Scene types available in the game
enum SceneType: Equatable {
    case mainMenu
    case campaignMap
    case quickPlay  
    case game(GameSession)
    case gameOver(GameSession)
    case settings
    case progress
    case assetValidation
    case modelIntegrationTest
    
    // MARK: - Equatable Implementation
    
    static func == (lhs: SceneType, rhs: SceneType) -> Bool {
        switch (lhs, rhs) {
        case (.mainMenu, .mainMenu),
             (.campaignMap, .campaignMap),
             (.quickPlay, .quickPlay),
             (.settings, .settings),
             (.progress, .progress),
             (.assetValidation, .assetValidation),
             (.modelIntegrationTest, .modelIntegrationTest):
            return true
        case (.game(let lhsSession), .game(let rhsSession)):
            return lhsSession === rhsSession
        case (.gameOver(let lhsSession), .gameOver(let rhsSession)):
            return lhsSession === rhsSession
        default:
            return false
        }
    }
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
    private let loadingDuration: TimeInterval = 0.3
    
    /// Scene history for back navigation
    private var sceneHistory: [SceneHistoryEntry] = []
    
    /// Current active scene type
    @Published var currentSceneType: SceneType = .mainMenu
    
    /// Loading state for scene transitions
    @Published var isLoading: Bool = false
    
    /// Transition progress for animations
    @Published var transitionProgress: Double = 0.0
    
    /// Loading overlay node
    private var loadingOverlay: LoadingOverlayNode?
    
    /// Transition callbacks
    private var transitionCompletionHandlers: [(Bool) -> Void] = []
    
    // MARK: - Types
    
    /// Scene history entry with metadata
    struct SceneHistoryEntry {
        let sceneType: SceneType
        let timestamp: Date
        let transitionType: TransitionType
        
        init(sceneType: SceneType, transitionType: TransitionType = .default) {
            self.sceneType = sceneType
            self.timestamp = Date()
            self.transitionType = transitionType
        }
    }
    
    /// Available transition types
    enum TransitionType {
        case `default`
        case fade
        case slide(direction: SKTransitionDirection)
        case push(direction: SKTransitionDirection)
        case doorway
        case flipVertical
        case flipHorizontal
        case moveIn(direction: SKTransitionDirection)
        case reveal(direction: SKTransitionDirection)
        case crossFade
        case custom(SKTransition)
    }
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Scene Management
    
    /// Present a scene with advanced transition options
    func presentScene(
        _ sceneType: SceneType,
        transitionType: TransitionType = .default,
        showLoading: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) {
        guard let sceneView = currentSceneView else {
            print("Warning: No scene view available for transition")
            completion?(false)
            return
        }
        
        // Add completion handler
        if let completion = completion {
            transitionCompletionHandlers.append(completion)
        }
        
        // Play transition sound
        SpriteKitSoundManager.shared.playSound(.buttonTap)
        
        // Show loading animation if requested
        if showLoading {
            showLoadingAnimation()
        }
        
        // Add current scene to history
        addToHistory(currentSceneType, transitionType: transitionType)
        
        // Create loading delay for smooth transition
        let loadingDelay = showLoading ? loadingDuration : 0.0
        
        DispatchQueue.main.asyncAfter(deadline: .now() + loadingDelay) { [weak self] in
            self?.performSceneTransition(sceneType, transitionType: transitionType, sceneView: sceneView)
        }
    }
    
    /// Perform the actual scene transition
    private func performSceneTransition(
        _ sceneType: SceneType,
        transitionType: TransitionType,
        sceneView: SKView
    ) {
        // Update current scene type
        currentSceneType = sceneType
        
        // Create the new scene
        let newScene = createScene(for: sceneType)
        
        // Set up the scene size
        newScene.size = sceneView.bounds.size
        newScene.scaleMode = .resizeFill
        
        // Create transition animation
        let transition = createTransition(for: transitionType, sceneType: sceneType)
        
        // Track transition progress
        animateTransitionProgress()
        
        // Present the scene with transition
        sceneView.presentScene(newScene, transition: transition)
        
        // Hide loading animation
        DispatchQueue.main.asyncAfter(deadline: .now() + transitionDuration) { [weak self] in
            self?.hideLoadingAnimation()
            self?.completeTransition(success: true)
        }
    }
    
    /// Enhanced back navigation with effects
    func goBack(withEffect: Bool = true) {
        guard !sceneHistory.isEmpty else {
            print("Warning: No previous scene in history")
            return
        }
        
        let previousEntry = sceneHistory.removeLast()
        let backTransition: TransitionType = withEffect ? .slide(direction: .right) : .fade
        
        // Play back sound with haptic feedback
        SpriteKitSoundManager.shared.playSound(.buttonTap)
        
        presentScene(
            previousEntry.sceneType,
            transitionType: backTransition,
            showLoading: false
        ) { success in
            if success {
                print("Back navigation completed to: \(previousEntry.sceneType)")
            }
        }
    }
    
    /// Go back multiple steps in history
    func goBackToScene(_ targetSceneType: SceneType) {
        // Find the target scene in history
        var found = false
        while !sceneHistory.isEmpty {
            let entry = sceneHistory.removeLast()
            if entry.sceneType == targetSceneType {
                found = true
                break
            }
        }
        
        if found {
            presentScene(targetSceneType, transitionType: .crossFade)
        } else {
            print("Warning: Target scene \(targetSceneType) not found in history")
        }
    }
    
    /// Clear scene history
    func clearHistory() {
        sceneHistory.removeAll()
    }
    
    /// Get scene history count
    var historyCount: Int {
        return sceneHistory.count
    }
    
    /// Check if can go back
    var canGoBack: Bool {
        return !sceneHistory.isEmpty
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
            
        case .modelIntegrationTest:
            return ModelIntegrationTestScene()
        }
    }
    
    // MARK: - Transition Creation
    
    /// Create transition based on type
    private func createTransition(for transitionType: TransitionType, sceneType: SceneType) -> SKTransition {
        switch transitionType {
        case .default:
            return createDefaultTransition(for: sceneType)
            
        case .fade:
            return SKTransition.fade(withDuration: transitionDuration)
            
        case .slide(let direction):
            return SKTransition.push(with: direction, duration: transitionDuration)
            
        case .push(let direction):
            return SKTransition.push(with: direction, duration: transitionDuration)
            
        case .doorway:
            return SKTransition.doorway(withDuration: transitionDuration)
            
        case .flipVertical:
            return SKTransition.flipVertical(withDuration: transitionDuration)
            
        case .flipHorizontal:
            return SKTransition.flipHorizontal(withDuration: transitionDuration)
            
        case .moveIn(let direction):
            return SKTransition.moveIn(with: direction, duration: transitionDuration)
            
        case .reveal(let direction):
            return SKTransition.reveal(with: direction, duration: transitionDuration)
            
        case .crossFade:
            return SKTransition.crossFade(withDuration: transitionDuration)
            
        case .custom(let transition):
            return transition
        }
    }
    
    /// Create enhanced default transitions for scene types
    private func createDefaultTransition(for sceneType: SceneType) -> SKTransition {
        switch sceneType {
        case .mainMenu:
            return createCustomFadeTransition()
            
        case .campaignMap:
            return createCustomSlideTransition(direction: .left)
            
        case .quickPlay:
            return createCustomSlideTransition(direction: .up)
            
        case .game:
            return createCustomDoorwayTransition()
            
        case .gameOver:
            return createCustomFlipTransition()
            
        case .settings, .progress:
            return createCustomMoveInTransition(direction: .up)
            
        case .assetValidation:
            return SKTransition.fade(withDuration: transitionDuration)
            
        case .modelIntegrationTest:
            return SKTransition.crossFade(withDuration: transitionDuration)
        }
    }
    
    /// Create custom fade transition with enhanced effects
    private func createCustomFadeTransition() -> SKTransition {
        let transition = SKTransition.fade(withDuration: transitionDuration)
        transition.pausesIncomingScene = false
        return transition
    }
    
    /// Create custom slide transition with easing
    private func createCustomSlideTransition(direction: SKTransitionDirection) -> SKTransition {
        let transition = SKTransition.push(with: direction, duration: transitionDuration)
        transition.pausesIncomingScene = false
        return transition
    }
    
    /// Create custom doorway transition with effects
    private func createCustomDoorwayTransition() -> SKTransition {
        let transition = SKTransition.doorway(withDuration: transitionDuration)
        transition.pausesIncomingScene = false
        return transition
    }
    
    /// Create custom flip transition
    private func createCustomFlipTransition() -> SKTransition {
        let transition = SKTransition.flipVertical(withDuration: transitionDuration)
        transition.pausesIncomingScene = false
        return transition
    }
    
    /// Create custom move-in transition
    private func createCustomMoveInTransition(direction: SKTransitionDirection) -> SKTransition {
        let transition = SKTransition.moveIn(with: direction, duration: transitionDuration)
        transition.pausesIncomingScene = false
        return transition
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
        case is AssetValidationScene:
            return .assetValidation
        case is ModelIntegrationTestScene:
            return .modelIntegrationTest
        default:
            return .mainMenu
        }
    }
    
    // MARK: - Loading Animation
    
    /// Show loading overlay with animation
    private func showLoadingAnimation() {
        guard let sceneView = currentSceneView else { return }
        
        isLoading = true
        
        // Remove existing loading overlay
        loadingOverlay?.removeFromParent()
        
        // Create new loading overlay
        loadingOverlay = LoadingOverlayNode(size: sceneView.bounds.size)
        
        // Add to current scene
        if let currentScene = sceneView.scene {
            currentScene.addChild(loadingOverlay!)
            loadingOverlay?.animateIn()
        }
    }
    
    /// Hide loading overlay with animation
    private func hideLoadingAnimation() {
        isLoading = false
        
        loadingOverlay?.animateOut { [weak self] in
            self?.loadingOverlay?.removeFromParent()
            self?.loadingOverlay = nil
        }
    }
    
    /// Animate transition progress for visual feedback
    private func animateTransitionProgress() {
        transitionProgress = 0.0
        
        let progressAction = SKAction.customAction(withDuration: transitionDuration) { [weak self] _, elapsedTime in
            DispatchQueue.main.async {
              self?.transitionProgress = Double(elapsedTime / (self?.transitionDuration ?? 1.0))
            }
        }
        
        // Run on a temporary node since we don't have a persistent scene reference
        let tempNode = SKNode()
        tempNode.run(progressAction) { [weak self] in
            DispatchQueue.main.async {
                self?.transitionProgress = 1.0
            }
        }
    }
    
    /// Complete transition and call handlers
    private func completeTransition(success: Bool) {
        for handler in transitionCompletionHandlers {
            handler(success)
        }
        transitionCompletionHandlers.removeAll()
    }
    
    /// Add scene to history with metadata
    private func addToHistory(_ sceneType: SceneType, transitionType: TransitionType) {
        // Don't add the same scene type consecutively
        if let lastEntry = sceneHistory.last,
           case sceneType = lastEntry.sceneType {
            return
        }
        
        let entry = SceneHistoryEntry(sceneType: sceneType, transitionType: transitionType)
        sceneHistory.append(entry)
        
        // Limit history size to prevent memory issues
        if sceneHistory.count > 10 {
            sceneHistory.removeFirst()
        }
    }
    
    // MARK: - Transition Creation
    
    /// Backward compatibility method
    func presentScene(_ sceneType: SceneType, transition: SKTransition? = nil) {
        let transitionType: TransitionType = transition != nil ? .custom(transition!) : .default
        presentScene(sceneType, transitionType: transitionType, showLoading: false)
    }
    
    // MARK: - Scene Creation
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

/// Model integration test scene - implemented in ModelIntegrationTestScene.swift
/// See ModelIntegrationTestScene class for the actual implementation
