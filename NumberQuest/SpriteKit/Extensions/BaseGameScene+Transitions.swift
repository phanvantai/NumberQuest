//
//  BaseGameScene+Transitions.swift
//  NumberQuest
//
//  Created by NumberQuest on 2024.
//

import SpriteKit

/// Extension to BaseGameScene providing convenient transition methods
extension BaseGameScene {
    
    // MARK: - Convenience Transition Methods
    
    /// Navigate to another scene with enhanced transition
    func navigateToScene(
        _ sceneType: SceneType,
        transitionType: GameSceneManager.TransitionType = .default,
        showLoading: Bool = true,
        completion: ((Bool) -> Void)? = nil
    ) {
        GameSceneManager.shared.presentScene(
            sceneType,
            transitionType: transitionType,
            showLoading: showLoading,
            completion: completion
        )
    }
    
    /// Go back to previous scene with enhanced effects
    func goBackWithEffect(_ withEffect: Bool = true) {
        GameSceneManager.shared.goBack(withEffect: withEffect)
    }
    
    /// Go back to a specific scene type
    func goBackToScene(_ targetSceneType: SceneType) {
        GameSceneManager.shared.goBackToScene(targetSceneType)
    }
    
    /// Navigate to main menu with fade transition
    func returnToMainMenu() {
        navigateToScene(.mainMenu, transitionType: .fade, showLoading: false)
    }
    
    /// Navigate to campaign map with slide transition
    func goToCampaignMap() {
        navigateToScene(.campaignMap, transitionType: .slide(direction: .left))
    }
    
    /// Navigate to quick play with push transition
    func goToQuickPlay() {
        navigateToScene(.quickPlay, transitionType: .push(direction: .up))
    }
    
    /// Navigate to settings with move-in transition
    func goToSettings() {
        navigateToScene(.settings, transitionType: .moveIn(direction: .up))
    }
    
    /// Navigate to progress with reveal transition
    func goToProgress() {
        navigateToScene(.progress, transitionType: .reveal(direction: .up))
    }
    
    /// Start a game level with doorway transition
    func startGameLevel(_ level: GameLevel) {
        let gameSession = GameSession()
        gameSession.setupLevel(level)
        
        navigateToScene(
            .game(gameSession),
            transitionType: .doorway,
            showLoading: true
        )
    }
    
    /// Show game over with flip transition
    func showGameOver(_ gameSession: GameSession) {
        navigateToScene(
            .gameOver(gameSession),
            transitionType: .flipVertical,
            showLoading: false
        )
    }
    
    // MARK: - Transition Status
    
    /// Check if can go back in navigation
    var canGoBack: Bool {
        return GameSceneManager.shared.canGoBack
    }
    
    /// Get navigation history count
    var navigationHistoryCount: Int {
        return GameSceneManager.shared.historyCount
    }
    
    // MARK: - Loading State
    
    /// Check if currently transitioning
    var isTransitioning: Bool {
        return GameSceneManager.shared.isLoading
    }
    
    /// Get transition progress (0.0 to 1.0)
    var transitionProgress: Double {
        return GameSceneManager.shared.transitionProgress
    }
}
