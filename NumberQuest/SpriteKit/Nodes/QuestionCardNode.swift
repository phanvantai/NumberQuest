//
//  QuestionCardNode.swift
//  NumberQuest
//
//  Created by NumberQuest on 2024.
//

import SpriteKit
import UIKit

/// Animated math question display card with visual effects
class QuestionCardNode: SKNode {
    
    // MARK: - Properties
    
    private var backgroundCard: SKShapeNode!
    private var questionLabel: SKLabelNode!
    private var shadowNode: SKShapeNode!
    
    private let cardSize: CGSize
    private var currentQuestion: String = ""
    
    // MARK: - Initialization
    
    init(size: CGSize) {
        self.cardSize = size
        super.init()
        setupCard()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupCard() {
        // Create shadow first (behind the card)
        createShadow()
        
        // Create background card
        createBackground()
        
        // Create question label
        createQuestionLabel()
        
        // Set up accessibility
        setupAccessibility()
    }
    
    private func createShadow() {
      shadowNode = SKShapeNode(rect: CGRect(
            x: -cardSize.width / 2,
            y: -cardSize.height / 2,
            width: cardSize.width,
            height: cardSize.height
        ), cornerRadius: 20)
        
        shadowNode.fillColor = SpriteKitColors.UI.cardShadow
        shadowNode.strokeColor = .clear
        shadowNode.position = CGPoint(x: 3, y: -3) // Offset for shadow effect
        shadowNode.zPosition = -1
        
        addChild(shadowNode)
    }
    
    private func createBackground() {
      backgroundCard = SKShapeNode(rect: CGRect(
            x: -cardSize.width / 2,
            y: -cardSize.height / 2,
            width: cardSize.width,
            height: cardSize.height
        ), cornerRadius: 20)
        
        backgroundCard.fillColor = SpriteKitColors.UI.cardBackground
        backgroundCard.strokeColor = UIColor.white.withAlphaComponent(0.3)
        backgroundCard.lineWidth = 2
        backgroundCard.zPosition = 0
        
        // Add subtle gradient effect
        addGradientToCard()
        
        addChild(backgroundCard)
    }
    
    private func addGradientToCard() {
        // Create a subtle inner glow effect
      let innerGlow = SKShapeNode(rect: CGRect(
            x: -cardSize.width / 2 + 4,
            y: -cardSize.height / 2 + 4,
            width: cardSize.width - 8,
            height: cardSize.height - 8
        ), cornerRadius: 16)
        
        innerGlow.fillColor = .clear
        innerGlow.strokeColor = UIColor.white.withAlphaComponent(0.2)
        innerGlow.lineWidth = 1
        innerGlow.zPosition = 1
        
        backgroundCard.addChild(innerGlow)
    }
    
    private func createQuestionLabel() {
        questionLabel = SKLabelNode()
        questionLabel.fontName = "Baloo2-VariableFont_wght"
        questionLabel.fontSize = 36
        questionLabel.fontColor = SpriteKitColors.Text.question
        questionLabel.horizontalAlignmentMode = .center
        questionLabel.verticalAlignmentMode = .center
        questionLabel.numberOfLines = 2
        questionLabel.preferredMaxLayoutWidth = cardSize.width - 40
        questionLabel.zPosition = 2
        
        // Add text shadow for better readability
        let textShadow = SKLabelNode()
        textShadow.fontName = questionLabel.fontName
        textShadow.fontSize = questionLabel.fontSize
        textShadow.fontColor = UIColor.black.withAlphaComponent(0.3)
        textShadow.horizontalAlignmentMode = .center
        textShadow.verticalAlignmentMode = .center
        textShadow.position = CGPoint(x: 2, y: -2)
        textShadow.zPosition = 1
        
        questionLabel.addChild(textShadow)
        addChild(questionLabel)
    }
    
    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityLabel = "Math Question"
        accessibilityHint = "Math problem to solve"
        accessibilityTraits = .staticText
    }
    
    // MARK: - Public Methods
    
    /// Update the question text with animation
    func setQuestion(_ question: String, animated: Bool = true) {
        currentQuestion = question
        
        if animated {
            animateQuestionChange(to: question)
        } else {
            updateQuestionText(question)
        }
        
        // Update accessibility
        accessibilityValue = question
    }
    
    /// Get the current question text
    var question: String {
        return currentQuestion
    }
    
    /// Animate the card appearing
    func animateIn(delay: TimeInterval = 0.0) {
        // Start invisible and scaled down
        alpha = 0
        setScale(0.1)
        
        // Create appear animation
        let wait = SKAction.wait(forDuration: delay)
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.4)
        scaleUp.timingMode = .easeOut
        
        let bounceScale = SKAction.scale(to: 1.1, duration: 0.1)
        let bounceBack = SKAction.scale(to: 1.0, duration: 0.1)
        let bounce = SKAction.sequence([bounceScale, bounceBack])
        
        let appearSequence = SKAction.sequence([
            wait,
            SKAction.group([fadeIn, scaleUp]),
            bounce
        ])
        
        run(appearSequence)
    }
    
    /// Enhanced question reveal animation with particles
    func animateInWithParticles(delay: TimeInterval = 0.0) {
        // Start invisible and scaled down
        alpha = 0
        setScale(0.1)
        
        // Create sparkle entrance effect
        let particleCount = 8
        for i in 0..<particleCount {
            let sparkle = SKLabelNode()
            sparkle.text = "✨"
            sparkle.fontSize = 14
            sparkle.alpha = 0
            sparkle.zPosition = 10
            
            // Position sparkles around the card
            let angle = (CGFloat.pi * 2 / CGFloat(particleCount)) * CGFloat(i)
            let radius: CGFloat = cardSize.width / 2 + 20
            sparkle.position = CGPoint(
                x: cos(angle) * radius,
                y: sin(angle) * radius
            )
            
            addChild(sparkle)
            
            // Animate sparkles spiraling in
            let spiralIn = SKAction.move(to: CGPoint.zero, duration: 0.6)
            let sparkleIn = SKAction.fadeIn(withDuration: 0.3)
            let sparkleOut = SKAction.fadeOut(withDuration: 0.3)
            let remove = SKAction.removeFromParent()
            
            let sparkleAnimation = SKAction.sequence([
                SKAction.wait(forDuration: delay + Double(i) * 0.05),
                SKAction.group([spiralIn, sparkleIn]),
                sparkleOut,
                remove
            ])
            
            sparkle.run(sparkleAnimation)
        }
        
        // Main card entrance
        let wait = SKAction.wait(forDuration: delay + 0.2)
        let fadeIn = SKAction.fadeIn(withDuration: 0.4)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.5)
        scaleUp.timingMode = .easeOut
        
        let bounceScale = SKAction.scale(to: 1.05, duration: 0.1)
        let bounceBack = SKAction.scale(to: 1.0, duration: 0.1)
        let bounce = SKAction.sequence([bounceScale, bounceBack])
        
        let appearSequence = SKAction.sequence([
            wait,
            SKAction.group([fadeIn, scaleUp]),
            bounce
        ])
        
        run(appearSequence)
    }
    
    /// Animate the card disappearing
    func animateOut(completion: @escaping () -> Void = {}) {
        let scaleDown = SKAction.scale(to: 0.1, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let disappear = SKAction.group([scaleDown, fadeOut])
        
        let complete = SKAction.run(completion)
        let sequence = SKAction.sequence([disappear, complete])
        
        run(sequence)
    }
    
    /// Shake animation for wrong answers
    func shakeForWrongAnswer() {
        // Change background color temporarily
        let originalColor = backgroundCard.fillColor
        let errorColor = SpriteKitColors.UI.errorOverlay
        
        let colorChange = SKAction.run {
            self.backgroundCard.fillColor = errorColor
        }
        let colorRestore = SKAction.run {
            self.backgroundCard.fillColor = originalColor
        }
        
        // Create shake animation
        let shakeLeft = SKAction.moveBy(x: -8, y: 0, duration: 0.05)
        let shakeRight = SKAction.moveBy(x: 16, y: 0, duration: 0.05)
        let shakeCenter = SKAction.moveBy(x: -8, y: 0, duration: 0.05)
        let shakeSequence = SKAction.sequence([shakeLeft, shakeRight, shakeCenter])
        let shakeRepeat = SKAction.repeat(shakeSequence, count: 2)
        
        // Combine animations
        let colorSequence = SKAction.sequence([
            colorChange,
            SKAction.wait(forDuration: 0.3),
            colorRestore
        ])
        
        let combinedAnimation = SKAction.group([shakeRepeat, colorSequence])
        run(combinedAnimation)
    }
    
    /// Enhanced glow effect with color cycling
    func glowForCorrectAnswerEnhanced() {
        let originalColor = backgroundCard.fillColor
        
        // Create multi-color glow sequence
        let colors: [UIColor] = [
            SpriteKitColors.UI.successOverlay,
            UIColor.cyan,
            UIColor.yellow,
            originalColor
        ]
        
        var colorActions: [SKAction] = []
        for (index, color) in colors.enumerated() {
            let colorChange = SKAction.run {
                self.backgroundCard.fillColor = color
            }
            let wait = SKAction.wait(forDuration: 0.2)
            colorActions.append(SKAction.sequence([colorChange, wait]))
            
            // Add scale pulse for each color
            if index < colors.count - 1 {
                let pulse = SKAction.scale(to: 1.02, duration: 0.1)
                let restore = SKAction.scale(to: 1.0, duration: 0.1)
                let pulseSequence = SKAction.sequence([pulse, restore])
                colorActions.append(pulseSequence)
            }
        }
        
        let glowSequence = SKAction.sequence(colorActions)
        run(glowSequence)
        
        // Add floating sparkles
        for i in 0..<6 {
            let sparkle = SKLabelNode()
            sparkle.text = ["✨", "⭐", "💫"].randomElement()!
            sparkle.fontSize = 16
            sparkle.alpha = 0
            sparkle.zPosition = 20
            
            sparkle.position = CGPoint(
                x: CGFloat.random(in: -cardSize.width/2...cardSize.width/2),
                y: CGFloat.random(in: -cardSize.height/2...cardSize.height/2)
            )
            
            addChild(sparkle)
            
            let delay = SKAction.wait(forDuration: Double(i) * 0.1)
            let sparkleIn = SKAction.fadeIn(withDuration: 0.3)
            let floatUp = SKAction.moveBy(x: 0, y: 40, duration: 1.0)
            let sparkleOut = SKAction.fadeOut(withDuration: 0.5)
            let cleanup = SKAction.removeFromParent()
            
            let sparkleSequence = SKAction.sequence([
                delay,
                sparkleIn,
                SKAction.group([floatUp, sparkleOut]),
                cleanup
            ])
            
            sparkle.run(sparkleSequence)
        }
    }
    
    // MARK: - Private Animation Methods
    
    private func animateQuestionChange(to newQuestion: String) {
        // Fade out current text
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.15)
        let changeText = SKAction.run {
            self.updateQuestionText(newQuestion)
        }
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: 0.15)
        
        // Add a slight bounce for emphasis
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        
        let textSequence = SKAction.sequence([fadeOut, changeText, fadeIn])
        let scaleSequence = SKAction.sequence([scaleDown, scaleUp])
        
        let combinedAnimation = SKAction.group([textSequence, scaleSequence])
        questionLabel.run(combinedAnimation)
    }
    
    private func updateQuestionText(_ question: String) {
        questionLabel.text = question
        
        // Update shadow text
        if let shadowLabel = questionLabel.children.first as? SKLabelNode {
            shadowLabel.text = question
        }
    }
}

// MARK: - Factory Methods

extension QuestionCardNode {
    /// Create a standard question card for the game
    static func createGameQuestionCard() -> QuestionCardNode {
        let cardSize = CGSize(width: 280, height: 120)
        return QuestionCardNode(size: cardSize)
    }
    
    /// Create a larger question card for complex problems
    static func createLargeQuestionCard() -> QuestionCardNode {
        let cardSize = CGSize(width: 320, height: 140)
        return QuestionCardNode(size: cardSize)
    }
}
