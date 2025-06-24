//
//  GameOverScene.swift
//  NumberQuest
//
//  Created by TaiPV on 24/6/25.
//

import SpriteKit
import SwiftUI

/// Enhanced Game Over scene with animated results, star ratings, and achievement effects
class GameOverScene: BaseGameScene {
    
    // MARK: - Properties
    
    /// Game session containing final results
    var gameSession: GameSession
    
    /// Level information (for campaign mode)
    var currentLevel: GameLevel?
    
    /// Stars earned this session
    private var starsEarned: Int = 0
    
    /// New achievements unlocked
    private var newAchievements: [String] = []
    
    // UI Containers
    private var resultsContainer: SKNode!
    private var starsContainer: SKNode!
    private var achievementsContainer: SKNode!
    private var buttonsContainer: SKNode!
    
    // UI Elements
    private var titleLabel: SKLabelNode!
    private var scoreCard: InfoCardNode!
    private var accuracyCard: InfoCardNode!
    private var timeCard: InfoCardNode!
    private var streakCard: InfoCardNode!
    
    // Star elements
    private var starNodes: [SKSpriteNode] = []
    private var starLabels: [SKLabelNode] = []
    
    // Buttons
    private var playAgainButton: GameButtonNode!
    private var nextLevelButton: GameButtonNode?
    private var mainMenuButton: GameButtonNode!
    
    // Animation state
    private var animationStep: Int = 0
    private var isAnimating: Bool = false
    
    // MARK: - Initialization
    
    init(gameSession: GameSession, level: GameLevel? = nil) {
        self.gameSession = gameSession
        self.currentLevel = level ?? gameSession.currentLevel
        super.init(size: .zero)
        
        calculateResults()
        
        // Ensure final progress is saved
        if gameSession.gameMode == .campaign {
            gameSession.completeLevel()
        } else {
            gameSession.syncWithGameData()
        }
    }
    
    convenience init(gameSession: GameSession) {
        self.init(gameSession: gameSession, level: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Scene Setup
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScene()
        setupUI()
        
        // Start entrance animation after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.startEntranceAnimation()
        }
    }
    
    override func setupScene() {
        super.setupScene()
        
        // Create containers
        resultsContainer = SKNode()
        starsContainer = SKNode()
        achievementsContainer = SKNode()
        buttonsContainer = SKNode()
        
        addChild(resultsContainer)
        addChild(starsContainer)
        addChild(achievementsContainer)
        addChild(buttonsContainer)
    }
    
    override func setupBackground() {
        super.setupBackground()
        
        // Dynamic background based on performance
        let accuracy = calculateAccuracy()
        let colors: [UIColor]
        
        if accuracy >= 90 {
            // Gold/celebration theme
            colors = [
                UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0),  // Gold
                UIColor(red: 1.0, green: 0.6, blue: 0.0, alpha: 1.0),  // Orange
                UIColor(red: 0.8, green: 0.4, blue: 0.8, alpha: 1.0)   // Purple
            ]
        } else if accuracy >= 70 {
            // Success theme
            colors = [
                UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0),  // Green
                UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0),  // Blue
                UIColor(red: 0.6, green: 0.4, blue: 0.9, alpha: 1.0)   // Purple
            ]
        } else {
            // Encouraging theme
            colors = [
                UIColor(red: 0.5, green: 0.7, blue: 1.0, alpha: 1.0),  // Light Blue
                UIColor(red: 0.7, green: 0.5, blue: 0.9, alpha: 1.0),  // Light Purple
                UIColor(red: 0.9, green: 0.6, blue: 0.7, alpha: 1.0)   // Light Pink
            ]
        }
        
        createGradientBackground(colors: colors, animated: true)
    }
    
    override func setupUI() {
        setupTitle()
        setupResultsCards()
        setupStarDisplay()
        setupAchievements()
        setupButtons()
    }
    
    // MARK: - UI Setup Methods
    
    private func setupTitle() {
        titleLabel = NodeFactory.shared.createLabel(
            text: getCompletionTitle(),
            style: .gameTitle,
            color: .white
        )
        titleLabel.position = position(x: 0.5, y: 0.9)
        titleLabel.alpha = 0
        titleLabel.setScale(0.1)
        resultsContainer.addChild(titleLabel)
        
        // Add text glow effect
        titleLabel.fontColor = UIColor.white
        let glowNode = titleLabel.copy() as! SKLabelNode
        glowNode.fontColor = UIColor.yellow.withAlphaComponent(0.5)
        glowNode.zPosition = titleLabel.zPosition - 1
        glowNode.setScale(1.1)
        resultsContainer.addChild(glowNode)
    }
    
    private func setupResultsCards() {
        // Calculate positions for 2x2 grid
        let spacing: CGFloat = CoordinateSystem.adaptiveSpacing(phone: 20, pad: 30)
        let cardSize = InfoCardNode.CardSize.small.size
        let startX: CGFloat = 0.5 - (cardSize.width + spacing) / size.width
        let endX: CGFloat = 0.5 + (cardSize.width + spacing) / size.width
        let topY: CGFloat = 0.65
        let bottomY: CGFloat = 0.45
        
        // Score Card
        scoreCard = InfoCardNode(
            title: "Score",
            value: "\(gameSession.score)",
            style: .score,
            size: .small,
            icon: "🏆"
        )
        scoreCard.position = position(x: startX, y: topY)
        scoreCard.alpha = 0
        scoreCard.position.x -= 100
        resultsContainer.addChild(scoreCard)
        
        // Accuracy Card
        let accuracy = calculateAccuracy()
        accuracyCard = InfoCardNode(
            title: "Accuracy",
            value: "\(Int(accuracy))%",
            style: .stats,
            size: .small,
            icon: "🎯"
        )
        accuracyCard.position = position(x: endX, y: topY)
        accuracyCard.alpha = 0
        accuracyCard.position.x += 100
        resultsContainer.addChild(accuracyCard)
        
        // Time Card
        let timeText: String
        if gameSession.gameMode == .quickPlay {
            let elapsed = 60 - gameSession.timeRemaining // Assuming 60 seconds for quick play
            timeText = formatTime(TimeInterval(elapsed))
        } else {
            // For campaign mode, we can show questions answered or just hide time
            timeText = "\(gameSession.questionsAnswered) Qs"
        }
        timeCard = InfoCardNode(
            title: gameSession.gameMode == .quickPlay ? "Time" : "Questions",
            value: timeText,
            style: .level,
            size: .small,
            icon: gameSession.gameMode == .quickPlay ? "⏱️" : "❓"
        )
        timeCard.position = position(x: startX, y: bottomY)
        timeCard.alpha = 0
        timeCard.position.x -= 100
        resultsContainer.addChild(timeCard)
        
        // Streak Card
        streakCard = InfoCardNode(
            title: "Best Streak",
            value: "\(gameSession.playerProgress.bestStreak)",
            style: .achievement,
            size: .small,
            icon: "🔥"
        )
        streakCard.position = position(x: endX, y: bottomY)
        streakCard.alpha = 0
        streakCard.position.x += 100
        resultsContainer.addChild(streakCard)
    }
    
    private func setupStarDisplay() {
        guard gameSession.gameMode == .campaign else { return }
        
        let starSize: CGFloat = CoordinateSystem.adaptiveSpacing(phone: 40, pad: 60)
        let starSpacing: CGFloat = CoordinateSystem.adaptiveSpacing(phone: 60, pad: 80)
        let startX = 0.5 - starSpacing
        let starY: CGFloat = 0.25
        
        // Create star background label
        let starsLabel = NodeFactory.shared.createLabel(
            text: "Stars Earned",
            style: .title,
            color: .white
        )
        starsLabel.position = position(x: 0.5, y: starY + 0.08)
        starsLabel.alpha = 0
        starsContainer.addChild(starsLabel)
        starLabels.append(starsLabel)
        
        // Create star nodes
        for i in 0..<3 {
            let star = SKSpriteNode()
            star.texture = AssetManager.shared.starTexture()
            star.size = CGSize(width: starSize, height: starSize)
            star.position = position(x: startX + CGFloat(i) * starSpacing, y: starY)
            star.colorBlendFactor = 1.0
            star.color = i < starsEarned ? UIColor.yellow : UIColor.gray.withAlphaComponent(0.3)
            star.alpha = 0
            star.setScale(0.1)
            starsContainer.addChild(star)
            starNodes.append(star)
        }
    }
    
    private func setupAchievements() {
        // Only show if there are new achievements
        guard !newAchievements.isEmpty else { return }
        
        let achievementY: CGFloat = 0.1
        
        // Achievement title
        let achievementLabel = NodeFactory.shared.createLabel(
            text: "🎉 New Achievement Unlocked! 🎉",
            style: .title,
            color: UIColor.yellow
        )
        achievementLabel.position = position(x: 0.5, y: achievementY + 0.05)
        achievementLabel.alpha = 0
        achievementsContainer.addChild(achievementLabel)
        
        // Achievement description
        let achievementText = newAchievements.first ?? "Great Job!"
        let descriptionLabel = NodeFactory.shared.createLabel(
            text: achievementText,
            style: .subtitle,
            color: .white
        )
        descriptionLabel.position = position(x: 0.5, y: achievementY)
        descriptionLabel.alpha = 0
        achievementsContainer.addChild(descriptionLabel)
    }
    
    private func setupButtons() {
        let buttonY: CGFloat = 0.05
        let buttonSpacing: CGFloat = 0.25
        
        // Main Menu Button
        mainMenuButton = NodeFactory.shared.createButton(
            text: "Main Menu",
            style: .secondary,
            size: .medium
        ) { [weak self] in
            self?.handleMainMenu()
        }
        mainMenuButton.position = position(x: 0.25, y: buttonY)
        mainMenuButton.alpha = 0
        mainMenuButton.setScale(0.8)
        buttonsContainer.addChild(mainMenuButton)
        
        // Play Again Button
        playAgainButton = NodeFactory.shared.createButton(
            text: "Play Again",
            style: .primary,
            size: .medium
        ) { [weak self] in
            self?.handlePlayAgain()
        }
        playAgainButton.position = position(x: 0.75, y: buttonY)
        playAgainButton.alpha = 0
        playAgainButton.setScale(0.8)
        buttonsContainer.addChild(playAgainButton)
        
        // Next Level Button (if applicable)
        if gameSession.gameMode == .campaign && hasNextLevel() {
            nextLevelButton = NodeFactory.shared.createButton(
                text: "Next Level",
                style: .success,
                size: .medium
            ) { [weak self] in
                self?.handleNextLevel()
            }
            nextLevelButton!.position = position(x: 0.5, y: buttonY)
            nextLevelButton!.alpha = 0
            nextLevelButton!.setScale(0.8)
            buttonsContainer.addChild(nextLevelButton!)
            
            // Adjust other button positions
            mainMenuButton.position = position(x: 0.2, y: buttonY)
            playAgainButton.position = position(x: 0.8, y: buttonY)
        }
    }
    
    // MARK: - Animation System
    
    private func startEntranceAnimation() {
        guard !isAnimating else { return }
        isAnimating = true
        animationStep = 0
        
        animateTitle()
    }
    
    private func animateTitle() {
        SpriteKitSoundManager.shared.playSound(.levelComplete)
        
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
        scaleUp.timingMode = .easeOut
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        scaleDown.timingMode = .easeIn
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        
        let titleAnimation = SKAction.group([
            SKAction.sequence([scaleUp, scaleDown]),
            fadeIn
        ])
        
        titleLabel.run(titleAnimation) { [weak self] in
            self?.animateResultsCards()
        }
        
        // Title particle effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            self.playCelebrationEffect(at: self.titleLabel.position)
        }
    }
    
    private func animateResultsCards() {
        let cards = [scoreCard, accuracyCard, timeCard, streakCard]
        
        for (index, card) in cards.enumerated() {
            let delay = SKAction.wait(forDuration: Double(index) * 0.2)
            let moveIn = SKAction.moveBy(x: card!.position.x > size.width / 2 ? -100 : 100, y: 0, duration: 0.3)
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            let bounce = SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1)
            ])
            
            let cardAnimation = SKAction.group([moveIn, fadeIn, bounce])
            let sequence = SKAction.sequence([delay, cardAnimation])
            
            card?.run(sequence) { [weak self] in
                if index == cards.count - 1 {
                    self?.animateStarRating()
                }
            }
            
            // Card-specific sound effects
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2 + 0.15) {
                SpriteKitSoundManager.shared.playSound(.correct)
            }
        }
    }
    
    private func animateStarRating() {
        guard gameSession.gameMode == .campaign else {
            animateAchievements()
            return
        }
        
        // Animate star label first
        let labelFadeIn = SKAction.fadeIn(withDuration: 0.3)
        starLabels.first?.run(labelFadeIn)
        
        // Animate each star with increasing delay
        for (index, star) in starNodes.enumerated() {
            let delay = SKAction.wait(forDuration: 0.5 + Double(index) * 0.3)
            let fadeIn = SKAction.fadeIn(withDuration: 0.2)
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.2)
            
            let starAnimation = SKAction.group([fadeIn, scaleUp])
            let sequence = SKAction.sequence([delay, starAnimation])
            
            star.run(sequence) { [weak self] in
                // Only animate earned stars
                if index < self?.starsEarned ?? 0 {
                    self?.animateStarEarned(star: star, index: index)
                }
                
                if index == self?.starNodes.count ?? 0 - 1 {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                        self?.animateAchievements()
                    }
                }
            }
        }
    }
    
    private func animateStarEarned(star: SKSpriteNode, index: Int) {
        // Color animation to gold
        let colorAction = SKAction.colorize(with: UIColor.yellow, colorBlendFactor: 1.0, duration: 0.3)
        
        // Star burst effect
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        
        let starAnimation = SKAction.group([colorAction, pulse])
        star.run(starAnimation)
        
        // Particle effect for each star
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            guard let self = self else { return }
            self.playCorrectAnswerEffect(at: star.position)
            SpriteKitSoundManager.shared.playSoundAndHaptic(.starEarned, haptic: .medium)
        }
    }
    
    private func animateAchievements() {
        guard !newAchievements.isEmpty else {
            animateButtons()
            return
        }
        
        // Animate achievement display
        achievementsContainer.children.forEach { node in
            if let label = node as? SKLabelNode {
                let fadeIn = SKAction.fadeIn(withDuration: 0.4)
                let bounce = SKAction.sequence([
                    SKAction.scale(to: 1.2, duration: 0.2),
                    SKAction.scale(to: 1.0, duration: 0.2)
                ])
                let animation = SKAction.group([fadeIn, bounce])
                label.run(animation)
            }
        }
        
        // Achievement celebration effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self = self else { return }
            let achievementPos = self.position(x: 0.5, y: 0.1)
            self.playCelebrationEffect(at: achievementPos)
            SpriteKitSoundManager.shared.playSoundAndHaptic(.starEarned, haptic: .heavy)
        }
        
        // Continue to buttons after achievement display
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.animateButtons()
        }
    }
    
    private func animateButtons() {
        let buttons = [mainMenuButton, playAgainButton, nextLevelButton].compactMap { $0 }
        
        for (index, button) in buttons.enumerated() {
            let delay = SKAction.wait(forDuration: Double(index) * 0.1)
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
            let bounce = SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1)
            ])
            
            let buttonAnimation = SKAction.group([fadeIn, scaleUp])
            let sequence = SKAction.sequence([delay, buttonAnimation, bounce])
            
            button.run(sequence) { [weak self] in
                if index == buttons.count - 1 {
                    self?.isAnimating = false
                }
            }
        }
    }
    
    // MARK: - Action Handlers
    
    private func handlePlayAgain() {
        guard !isAnimating else { return }
        
        SpriteKitSoundManager.shared.playSoundAndHaptic(.buttonTap, haptic: .light)
        
        // Create new game session with same settings
        let newGameSession = GameSession()
        newGameSession.gameMode = gameSession.gameMode
        newGameSession.currentLevel = gameSession.currentLevel
        newGameSession.playerProgress = gameSession.playerProgress
        
        // Transition back to game
        GameSceneManager.shared.presentScene(.game(newGameSession), transitionType: .fade)
    }
    
    private func handleNextLevel() {
        guard !isAnimating else { return }
        guard let nextLevel = getNextLevel() else {
            handleMainMenu()
            return
        }
        
        SpriteKitSoundManager.shared.playSoundAndHaptic(.buttonTap, haptic: .light)
        
        // Create game session for next level
        let newGameSession = GameSession()
        newGameSession.gameMode = .campaign
        newGameSession.currentLevel = nextLevel
        newGameSession.playerProgress = gameSession.playerProgress
        
        // Transition to next level
        GameSceneManager.shared.presentScene(.game(newGameSession), transitionType: .slide(direction: .left))
    }
    
    private func handleMainMenu() {
        guard !isAnimating else { return }
        
        SpriteKitSoundManager.shared.playSoundAndHaptic(.buttonTap, haptic: .light)
        
        // Transition to main menu
        GameSceneManager.shared.presentScene(.mainMenu, transitionType: .fade)
    }
    
    // MARK: - Helper Methods
    
    private func calculateResults() {
        // Calculate stars earned based on performance
        if gameSession.gameMode == .campaign {
            let accuracy = calculateAccuracy()
            if accuracy >= 90 {
                starsEarned = 3
            } else if accuracy >= 75 {
                starsEarned = 2
            } else if accuracy >= 60 {
                starsEarned = 1
            } else {
                starsEarned = 0
            }
            
            // Save stars to level
            if let level = currentLevel {
                GameData.shared.addStarsToLevel(level.id, stars: starsEarned)
            }
        }
        
        // Check for new achievements
        checkForNewAchievements()
    }
    
    private func checkForNewAchievements() {
        // Check various achievement conditions
        let accuracy = calculateAccuracy()
        
        if accuracy == 100 && gameSession.questionsAnswered >= 10 {
            newAchievements.append("Perfect Score!")
        }
        
        if gameSession.playerProgress.bestStreak >= 10 {
            newAchievements.append("Streak Master!")
        }
        
        if gameSession.score >= 1000 {
            newAchievements.append("High Scorer!")
        }
        
        // Add more achievement logic as needed
    }
    
    private func calculateAccuracy() -> Double {
        guard gameSession.questionsAnswered > 0 else { return 0 }
        return Double(gameSession.correctAnswers) / Double(gameSession.questionsAnswered) * 100
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    private func getCompletionTitle() -> String {
        let accuracy = calculateAccuracy()
        
        if accuracy >= 95 {
            return "🌟 Outstanding! 🌟"
        } else if accuracy >= 85 {
            return "🎉 Excellent! 🎉"
        } else if accuracy >= 75 {
            return "👏 Great Job! 👏"
        } else if accuracy >= 65 {
            return "👍 Well Done! 👍"
        } else if accuracy >= 50 {
            return "💪 Good Effort! 💪"
        } else {
            return "📚 Keep Practicing! 📚"
        }
    }
    
    private func hasNextLevel() -> Bool {
        return getNextLevel() != nil
    }
    
    private func getNextLevel() -> GameLevel? {
        guard let currentLevel = currentLevel else { return nil }
        
        // Find the next level after the current one
        let sortedLevels = GameData.shared.levels.sorted { $0.id < $1.id }
        if let currentIndex = sortedLevels.firstIndex(where: { $0.id == currentLevel.id }),
           currentIndex + 1 < sortedLevels.count {
            let nextLevel = sortedLevels[currentIndex + 1]
            // Only return if it's unlocked or should be unlocked after this completion
            return nextLevel.isUnlocked || GameData.shared.playerProgress.totalStars >= nextLevel.requiredStars ? nextLevel : nil
        }
        return nil
    }
}
