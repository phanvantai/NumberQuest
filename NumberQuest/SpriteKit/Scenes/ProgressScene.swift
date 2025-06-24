//
//  ProgressScene.swift
//  NumberQuest
//
//  Created by NumberQuest on 2024.
//

import SpriteKit

/// Progress scene with enhanced statistics display
class ProgressScene: BaseGameScene {
    
    // MARK: - Properties
    
    private var statisticsCards: [InfoCardNode] = []
    private var backButton: SKNode?
    
    // MARK: - Scene Setup
    
    override func setupScene() {
        super.setupScene()
        
        setupTitle()
        setupBackButton()
        setupStatisticsCards()
        startAnimations()
    }
    
    private func setupTitle() {
        let titleLabel = NodeFactory.shared.createLabel(
            text: "Your Progress",
            style: .gameTitle,
            color: .white
        )
        titleLabel.position = position(x: 0.5, y: 0.1)
        addChild(titleLabel)
        
        // Add entrance animation
        titleLabel.alpha = 0
        titleLabel.setScale(0.5)
        let fadeIn = SKAction.fadeIn(withDuration: 0.6)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.6)
        let entrance = SKAction.group([fadeIn, scaleUp])
        entrance.timingMode = .easeOut
        titleLabel.run(entrance)
    }
    
    private func setupBackButton() {
        backButton = GameButtonNode.backButton { [weak self] in
            self?.handleBackTapped()
        }
        
        guard let backButton = backButton else { return }
        backButton.position = position(x: 0.1, y: 0.05)
        addChild(backButton)
        
        // Add entrance animation
        backButton.alpha = 0
        let fadeIn = SKAction.fadeIn(withDuration: 0.4)
        backButton.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.2),
            fadeIn
        ]))
    }
    
    private func setupStatisticsCards() {
        let statistics = gameData.getGameStatistics()
        
        // Create statistics cards
        let cardData: [(title: String, value: String, style: InfoCardNode.CardStyle)] = [
            ("Total Stars", "\(statistics.totalStars)", .stats),
            ("Levels Completed", "\(statistics.completedLevels)/\(statistics.totalLevels)", .level),
            ("Accuracy", "\(Int(statistics.accuracy))%", .achievement),
            ("Best Streak", "\(statistics.bestStreak)", .score),
            ("Total Questions", "\(statistics.totalQuestions)", .stats),
            ("Completion", "\(Int(statistics.completionPercentage))%", .progress)
        ]
        
        // Layout cards in a grid
        let cardSizeType: InfoCardNode.CardSize = isIPad ? .medium : .small
        let cardSize = cardSizeType.size
        let columns = isIPad ? 3 : 2
        let rows = (cardData.count + columns - 1) / columns
        
        let totalWidth = CGFloat(columns) * cardSize.width + CGFloat(columns - 1) * 20
        let totalHeight = CGFloat(rows) * cardSize.height + CGFloat(rows - 1) * 20
        let startX = (size.width - totalWidth) / 2 + cardSize.width / 2
        let startY = size.height * 0.65 + totalHeight / 2 - cardSize.height / 2
        
        for (index, data) in cardData.enumerated() {
            let row = index / columns
            let col = index % columns
            
            let x = startX + CGFloat(col) * (cardSize.width + 20)
            let y = startY - CGFloat(row) * (cardSize.height + 20)
            
            let card = InfoCardNode(
                title: data.title,
                value: data.value,
                style: data.style,
                size: cardSizeType
            )
            card.position = CGPoint(x: x, y: y)
            addChild(card)
            statisticsCards.append(card)
            
            // Add entrance animation with stagger
            card.alpha = 0
            card.setScale(0.3)
            let delay = Double(index) * 0.1 + 0.5
            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.5)
            let entrance = SKAction.group([fadeIn, scaleUp])
            entrance.timingMode = .easeOut
            
            card.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                entrance
            ]))
        }
    }
    
    private func startAnimations() {
        // Add floating animations to the cards
        for (index, card) in statisticsCards.enumerated() {
            let delay = Double(index) * 0.2 + 1.0
            
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                self.startFloatingAnimation(for: card, index: index)
            }
        }
    }
    
    private func startFloatingAnimation(for card: InfoCardNode, index: Int) {
        // Create subtle floating animation
        let floatUp = SKAction.moveBy(x: 0, y: 8, duration: 2.0 + Double(index) * 0.3)
        let floatDown = SKAction.moveBy(x: 0, y: -8, duration: 2.0 + Double(index) * 0.3)
        let floatSequence = SKAction.sequence([floatUp, floatDown])
        let floatForever = SKAction.repeatForever(floatSequence)
        
        // Add subtle rotation
        let rotateLeft = SKAction.rotate(byAngle: 0.02, duration: 1.5 + Double(index) * 0.2)
        let rotateRight = SKAction.rotate(byAngle: -0.04, duration: 3.0 + Double(index) * 0.4)
        let rotateBack = SKAction.rotate(byAngle: 0.02, duration: 1.5 + Double(index) * 0.2)
        let rotateSequence = SKAction.sequence([rotateLeft, rotateRight, rotateBack])
        let rotateForever = SKAction.repeatForever(rotateSequence)
        
        // Combine animations
        card.run(floatForever, withKey: "floating")
        card.run(rotateForever, withKey: "rotating")
        
        // Occasional pulse animation
        let pulse = SKAction.run { card.pulse() }
        let wait = SKAction.wait(forDuration: 5.0 + Double(index) * 2.0)
        let pulseSequence = SKAction.sequence([wait, pulse])
        let pulseForever = SKAction.repeatForever(pulseSequence)
        card.run(pulseForever, withKey: "pulsing")
    }
    
    private func handleBackTapped() {
        SpriteKitSoundManager.shared.playSound(.buttonTap)
        GameSceneManager.shared.goBack(withEffect: true)
    }
    
    override func setupBackground() {
        super.setupBackground()
        createGradientBackground(colors: [
            UIColor(red: 0.1, green: 0.7, blue: 0.3, alpha: 1.0),
            UIColor(red: 0.8, green: 0.9, blue: 0.3, alpha: 1.0)
        ])
    }
}
