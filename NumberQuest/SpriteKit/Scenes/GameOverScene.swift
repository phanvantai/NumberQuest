//
//  GameOverScene.swift
//  NumberQuest
//
//  Created by TaiPV on 24/6/25.
//

import SpriteKit
import SwiftUI

/// Game Over scene that displays results and completion statistics
class GameOverScene: BaseGameScene {
    
    // MARK: - Properties
    
    /// Game session containing final results
    var gameSession: GameSession
    
    /// UI Elements
    private var titleLabel: SKLabelNode?
    private var scoreLabel: SKLabelNode?
    private var accuracyLabel: SKLabelNode?
    private var streakLabel: SKLabelNode?
    private var playAgainButton: SKShapeNode?
    private var mainMenuButton: SKShapeNode?
    
    // MARK: - Initialization
    
    init(gameSession: GameSession) {
        self.gameSession = gameSession
        super.init(size: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Scene Setup
    
    override func setupBackground() {
        super.setupBackground()
        
        // Celebratory gradient background
        createGradientBackground(colors: [
            UIColor(red: 1.0, green: 0.7, blue: 0.3, alpha: 1.0), // Orange
            UIColor(red: 0.9, green: 0.4, blue: 0.9, alpha: 1.0), // Pink
            UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0)  // Blue
        ], animated: true)
    }
    
    override func setupUI() {
        super.setupUI()
        
        setupTitle()
        setupStats()
        setupButtons()
        
        // Play entrance animation
        animateEntrance()
    }
    
    // MARK: - UI Setup
    
    private func setupTitle() {
        titleLabel = SKLabelNode()
        titleLabel?.text = getCompletionTitle()
        titleLabel?.fontName = "Baloo2-VariableFont_wght"
        titleLabel?.fontSize = 48
        titleLabel?.fontColor = SpriteKitColors.Text.primary
        titleLabel?.position = position(x: 0.5, y: 0.2)
        titleLabel?.zPosition = 100
        
        if let titleLabel = titleLabel {
            addChild(titleLabel)
        }
    }
    
    private func setupStats() {
        let statsY: CGFloat = 0.4
        let spacing: CGFloat = 0.08
        
        // Score
        scoreLabel = createStatLabel(
            text: "Score: \(gameSession.score)",
            position: position(x: 0.5, y: statsY)
        )
        
        // Accuracy
        let accuracy = gameSession.questionsAnswered > 0 ? 
            Double(gameSession.correctAnswers) / Double(gameSession.questionsAnswered) * 100 : 0
        accuracyLabel = createStatLabel(
            text: "Accuracy: \(Int(accuracy))%",
            position: position(x: 0.5, y: statsY + spacing)
        )
        
        // Best Streak
        streakLabel = createStatLabel(
            text: "Best Streak: \(gameSession.playerProgress.bestStreak)",
            position: position(x: 0.5, y: statsY + spacing * 2)
        )
        
        [scoreLabel, accuracyLabel, streakLabel].forEach { label in
            if let label = label {
                addChild(label)
            }
        }
    }
    
    private func createStatLabel(text: String, position: CGPoint) -> SKLabelNode {
        let label = SKLabelNode()
        label.text = text
        label.fontName = "Baloo2-VariableFont_wght"
        label.fontSize = 24
        label.fontColor = SpriteKitColors.Text.primary
        label.position = position
        label.zPosition = 100
        return label
    }
    
    private func setupButtons() {
        let buttonSize = CGSize(width: 200, height: 60)
        let buttonY: CGFloat = 0.7
        
        // Play Again Button
        playAgainButton = createButton(
            text: "Play Again",
            size: buttonSize,
            color: SpriteKitColors.UI.success,
            position: position(x: 0.3, y: buttonY)
        )
        
        // Main Menu Button
        mainMenuButton = createButton(
            text: "Main Menu",
            size: buttonSize,
            color: SpriteKitColors.UI.primary,
            position: position(x: 0.7, y: buttonY)
        )
        
        if let playAgainButton = playAgainButton {
            addChild(playAgainButton)
        }
        if let mainMenuButton = mainMenuButton {
            addChild(mainMenuButton)
        }
    }
    
    private func createButton(text: String, size: CGSize, color: UIColor, position: CGPoint) -> SKShapeNode {
        let button = SKShapeNode(rectOf: size, cornerRadius: 15)
        button.fillColor = color
        button.strokeColor = .clear
        button.position = position
        button.zPosition = 100
        
        let label = SKLabelNode()
        label.text = text
        label.fontName = "Baloo2-VariableFont_wght"
        label.fontSize = 18
        label.fontColor = SpriteKitColors.UI.onPrimary
        label.verticalAlignmentMode = .center
        label.position = CGPoint.zero
        
        button.addChild(label)
        return button
    }
    
    // MARK: - Animations
    
    private func animateEntrance() {
        // Animate title entrance
        titleLabel?.alpha = 0
        titleLabel?.setScale(0.5)
        let titleFadeIn = SKAction.fadeIn(withDuration: 0.5)
        let titleScaleUp = SKAction.scale(to: 1.0, duration: 0.5)
        let titleAnimation = SKAction.group([titleFadeIn, titleScaleUp])
        titleLabel?.run(titleAnimation)
        
        // Animate stats with delay
        [scoreLabel, accuracyLabel, streakLabel].enumerated().forEach { index, label in
            label?.alpha = 0
            label?.position.x -= 50
            
            let delay = SKAction.wait(forDuration: 0.2 + Double(index) * 0.1)
            let moveIn = SKAction.moveBy(x: 50, y: 0, duration: 0.3)
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            let animation = SKAction.group([moveIn, fadeIn])
            let sequence = SKAction.sequence([delay, animation])
            
            label?.run(sequence)
        }
        
        // Animate buttons with bounce
        [playAgainButton, mainMenuButton].enumerated().forEach { index, button in
            button?.alpha = 0
            button?.setScale(0.8)
            
            let delay = SKAction.wait(forDuration: 0.8 + Double(index) * 0.1)
            let fadeIn = SKAction.fadeIn(withDuration: 0.2)
            let scaleUp = SKAction.scale(to: 1.1, duration: 0.1)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
            let bounce = SKAction.sequence([scaleUp, scaleDown])
            let animation = SKAction.group([fadeIn, bounce])
            let sequence = SKAction.sequence([delay, animation])
            
            button?.run(sequence)
        }
        
        // Add celebration effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.playCelebrationEffect(at: CGPoint(x: self.frame.midX, y: self.frame.midY))
        }
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if touchedNode == playAgainButton || touchedNode.parent == playAgainButton {
            handlePlayAgain()
        } else if touchedNode == mainMenuButton || touchedNode.parent == mainMenuButton {
            handleMainMenu()
        }
    }
    
    // MARK: - Button Actions
    
    private func handlePlayAgain() {
        playSound(.buttonTap, haptic: .light)
        
        // Create new game session with same settings
        let newGameSession = GameSession()
        newGameSession.gameMode = gameSession.gameMode
        newGameSession.currentLevel = gameSession.currentLevel
        newGameSession.playerProgress = gameSession.playerProgress
        
        // Transition back to game
        GameSceneManager.shared.presentScene(.game(newGameSession))
    }
    
    private func handleMainMenu() {
        playSound(.buttonTap, haptic: .light)
        
        // Transition to main menu
        GameSceneManager.shared.presentScene(.mainMenu)
    }
    
    // MARK: - Helper Methods
    
    private func getCompletionTitle() -> String {
        let accuracy = gameSession.questionsAnswered > 0 ? 
            Double(gameSession.correctAnswers) / Double(gameSession.questionsAnswered) * 100 : 0
            
        if accuracy >= 90 {
            return "Outstanding!"
        } else if accuracy >= 80 {
            return "Great Job!"
        } else if accuracy >= 70 {
            return "Well Done!"
        } else if accuracy >= 60 {
            return "Good Effort!"
        } else {
            return "Keep Practicing!"
        }
    }
}
