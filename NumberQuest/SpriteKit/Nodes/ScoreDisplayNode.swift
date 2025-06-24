//
//  ScoreDisplayNode.swift
//  NumberQuest
//
//  Created by NumberQuest on 2024.
//

import SpriteKit
import UIKit

/// Animated score and streak counter display
class ScoreDisplayNode: SKNode {
    
    // MARK: - Properties
    
    private var backgroundCard: SKShapeNode!
    private var scoreLabel: SKLabelNode!
    private var titleLabel: SKLabelNode!
    private var iconNode: SKLabelNode!
    
    private let cardSize: CGSize
    private var currentValue: Int = 0
    private let displayType: DisplayType
    
    enum DisplayType {
        case score
        case streak
        case lives
        case stars
        
        var title: String {
            switch self {
            case .score: return "Score"
            case .streak: return "Streak"
            case .lives: return "Lives"
            case .stars: return "Stars"
            }
        }
        
        var icon: String {
            switch self {
            case .score: return "🎯"
            case .streak: return "🔥"
            case .lives: return "❤️"
            case .stars: return "⭐"
            }
        }
        
        var color: UIColor {
            switch self {
            case .score: return SpriteKitColors.Text.score
            case .streak: return SpriteKitColors.Text.streak
            case .lives: return SpriteKitColors.Text.error
            case .stars: return SpriteKitColors.Text.accent
            }
        }
    }
    
    // MARK: - Initialization
    
    init(type: DisplayType, size: CGSize = CGSize(width: 140, height: 80)) {
        self.displayType = type
        self.cardSize = size
        super.init()
        setupDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupDisplay() {
        // Create background card
        createBackground()
        
        // Create icon
        createIcon()
        
        // Create title label
        createTitleLabel()
        
        // Create value label
        createValueLabel()
        
        // Set up accessibility
        setupAccessibility()
    }
    
    private func createBackground() {
      backgroundCard = SKShapeNode(rect: CGRect(
            x: -cardSize.width / 2,
            y: -cardSize.height / 2,
            width: cardSize.width,
            height: cardSize.height
        ), cornerRadius: 12)
        
        backgroundCard.fillColor = SpriteKitColors.UI.cardBackground
        backgroundCard.strokeColor = UIColor.white.withAlphaComponent(0.3)
        backgroundCard.lineWidth = 1.5
        backgroundCard.zPosition = 0
        
        // Add subtle shadow
      let shadowCard = SKShapeNode(rect: CGRect(
            x: -cardSize.width / 2,
            y: -cardSize.height / 2,
            width: cardSize.width,
            height: cardSize.height
        ), cornerRadius: 12)
        
        shadowCard.fillColor = SpriteKitColors.UI.cardShadow
        shadowCard.strokeColor = .clear
        shadowCard.position = CGPoint(x: 2, y: -2)
        shadowCard.zPosition = -1
        
        addChild(shadowCard)
        addChild(backgroundCard)
    }
    
    private func createIcon() {
        iconNode = SKLabelNode()
        iconNode.text = displayType.icon
        iconNode.fontSize = 20
        iconNode.horizontalAlignmentMode = .center
        iconNode.verticalAlignmentMode = .center
        iconNode.position = CGPoint(x: -cardSize.width/4, y: cardSize.height/6)
        iconNode.zPosition = 1
        
        addChild(iconNode)
    }
    
    private func createTitleLabel() {
        titleLabel = SKLabelNode()
        titleLabel.fontName = "Baloo2-VariableFont_wght"
        titleLabel.fontSize = 14
        titleLabel.fontColor = SpriteKitColors.Text.secondary
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .center
        titleLabel.text = displayType.title
        titleLabel.position = CGPoint(x: cardSize.width/4, y: cardSize.height/6)
        titleLabel.zPosition = 1
        
        addChild(titleLabel)
    }
    
    private func createValueLabel() {
        scoreLabel = SKLabelNode()
        scoreLabel.fontName = "Baloo2-VariableFont_wght"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = displayType.color
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: 0, y: -cardSize.height/6)
        scoreLabel.zPosition = 1
        
        // Add text glow effect for better visibility
        addTextGlow()
        
        addChild(scoreLabel)
    }
    
    private func addTextGlow() {
        let glowLabel = SKLabelNode()
        glowLabel.fontName = scoreLabel.fontName
        glowLabel.fontSize = scoreLabel.fontSize + 2
        glowLabel.fontColor = displayType.color.withAlphaComponent(0.3)
        glowLabel.horizontalAlignmentMode = .center
        glowLabel.verticalAlignmentMode = .center
        glowLabel.text = scoreLabel.text
        glowLabel.zPosition = -1
        
        scoreLabel.addChild(glowLabel)
    }
    
    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityLabel = displayType.title
        accessibilityValue = "\(currentValue)"
        accessibilityTraits = .staticText
    }
    
    // MARK: - Public Methods
    
    /// Update the displayed value with animation
    func setValue(_ newValue: Int, animated: Bool = true) {
        let oldValue = currentValue
        currentValue = newValue
        
        if animated {
            animateValueChange(from: oldValue, to: newValue)
        } else {
            updateDisplayText()
        }
        
        // Update accessibility
        accessibilityValue = "\(newValue)"
    }
    
    /// Get the current value
    var value: Int {
        return currentValue
    }
    
    /// Animate the display appearing
    func animateIn(delay: TimeInterval = 0.0) {
        // Start invisible and scaled down
        alpha = 0
        setScale(0.5)
        
        let wait = SKAction.wait(forDuration: delay)
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.4)
        scaleUp.timingMode = .easeOut
        
        let appearSequence = SKAction.sequence([
            wait,
            SKAction.group([fadeIn, scaleUp])
        ])
        
        run(appearSequence)
    }
    
    /// Pulse animation for value increases
    func pulseForIncrease() {
        // Scale up slightly and return
        let scaleUp = SKAction.scale(to: 1.15, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.15)
        scaleUp.timingMode = .easeOut
        scaleDown.timingMode = .easeIn
        
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        
        // Add color flash
        let originalColor = backgroundCard.fillColor
        let flashColor = displayType.color.withAlphaComponent(0.3)
        
        let colorFlash = SKAction.run {
            self.backgroundCard.fillColor = flashColor
        }
        let colorRestore = SKAction.run {
            self.backgroundCard.fillColor = originalColor
        }
        
        let colorSequence = SKAction.sequence([
            colorFlash,
            SKAction.wait(forDuration: 0.25),
            colorRestore
        ])
        
        let combinedAnimation = SKAction.group([pulse, colorSequence])
        run(combinedAnimation)
    }
    
    /// Shake animation for value decreases
    func shakeForDecrease() {
        // Create shake effect
        let shakeLeft = SKAction.moveBy(x: -3, y: 0, duration: 0.05)
        let shakeRight = SKAction.moveBy(x: 6, y: 0, duration: 0.05)
        let shakeCenter = SKAction.moveBy(x: -3, y: 0, duration: 0.05)
        let shakeSequence = SKAction.sequence([shakeLeft, shakeRight, shakeCenter])
        let shakeRepeat = SKAction.repeat(shakeSequence, count: 2)
        
        // Add red flash for lives/negative changes
        if displayType == .lives {
            let originalColor = backgroundCard.fillColor
            let errorColor = SpriteKitColors.UI.errorOverlay
            
            let colorFlash = SKAction.run {
                self.backgroundCard.fillColor = errorColor
            }
            let colorRestore = SKAction.run {
                self.backgroundCard.fillColor = originalColor
            }
            
            let colorSequence = SKAction.sequence([
                colorFlash,
                SKAction.wait(forDuration: 0.2),
                colorRestore
            ])
            
            let combinedAnimation = SKAction.group([shakeRepeat, colorSequence])
            run(combinedAnimation)
        } else {
            run(shakeRepeat)
        }
    }
    
    /// Special animation for streak milestones
    func celebrateStreak() {
        guard displayType == .streak else { return }
        
        // Create fire effect animation
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.3)
        let bounceScale = SKAction.sequence([scaleUp, scaleDown])
        
        // Rotate the icon for fire effect
        let rotateLeft = SKAction.rotate(byAngle: -0.3, duration: 0.1)
        let rotateRight = SKAction.rotate(byAngle: 0.6, duration: 0.1)
        let rotateCenter = SKAction.rotate(byAngle: -0.3, duration: 0.1)
        let wobble = SKAction.sequence([rotateLeft, rotateRight, rotateCenter])
        
        iconNode.run(wobble)
        run(bounceScale)
        
        // Add particle effect if streak is high
        if currentValue >= 5 {
            addStreakParticles()
        }
    }
    
    // MARK: - Private Methods
    
    private func animateValueChange(from oldValue: Int, to newValue: Int) {
        // Determine if value increased or decreased
        let isIncrease = newValue > oldValue
        
        // Create counting animation
        let duration = 0.5
        let steps = min(abs(newValue - oldValue), 10) // Limit animation steps
        
        if steps > 0 {
            let stepDuration = duration / Double(steps)
            var currentStep = 0
            
            let countingAction = SKAction.run {
                currentStep += 1
                let progress = Double(currentStep) / Double(steps)
                let intermediateValue = oldValue + Int(Double(newValue - oldValue) * progress)
                self.updateDisplayText(value: intermediateValue)
            }
            
            let wait = SKAction.wait(forDuration: stepDuration)
            let countStep = SKAction.sequence([countingAction, wait])
            let countSequence = SKAction.repeat(countStep, count: steps)
            
            let finalUpdate = SKAction.run {
                self.updateDisplayText()
            }
            
            let completeSequence = SKAction.sequence([countSequence, finalUpdate])
            
            // Add appropriate animation based on change
            if isIncrease {
                let pulseDelay = SKAction.wait(forDuration: duration * 0.8)
                let pulse = SKAction.run { self.pulseForIncrease() }
                let pulseSequence = SKAction.sequence([pulseDelay, pulse])
                
                run(SKAction.group([completeSequence, pulseSequence]))
            } else {
                let shakeDelay = SKAction.wait(forDuration: duration * 0.8)
                let shake = SKAction.run { self.shakeForDecrease() }
                let shakeSequence = SKAction.sequence([shakeDelay, shake])
                
                run(SKAction.group([completeSequence, shakeSequence]))
            }
        } else {
            updateDisplayText()
        }
    }
    
    private func updateDisplayText(value: Int? = nil) {
        let displayValue = value ?? currentValue
        scoreLabel.text = "\(displayValue)"
        
        // Update glow text
        if let glowLabel = scoreLabel.children.first as? SKLabelNode {
            glowLabel.text = "\(displayValue)"
        }
    }
    
    private func addStreakParticles() {
        // Create simple particle effect around the icon
        for i in 0..<6 {
            let particle = SKLabelNode(text: "✨")
            particle.fontSize = 12
            particle.position = iconNode.position
            particle.zPosition = 2
            
            let angle = (CGFloat.pi * 2 / 6) * CGFloat(i)
            let radius: CGFloat = 30
            let targetPosition = CGPoint(
                x: iconNode.position.x + cos(angle) * radius,
                y: iconNode.position.y + sin(angle) * radius
            )
            
            let moveOut = SKAction.move(to: targetPosition, duration: 0.5)
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let scaleUp = SKAction.scale(to: 1.5, duration: 0.5)
            
            let particleAnimation = SKAction.group([moveOut, fadeOut, scaleUp])
            let removeParticle = SKAction.removeFromParent()
            let completeSequence = SKAction.sequence([particleAnimation, removeParticle])
            
            particle.run(completeSequence)
            addChild(particle)
        }
    }
}

// MARK: - Factory Methods

extension ScoreDisplayNode {
    /// Create a score display
    static func createScoreDisplay() -> ScoreDisplayNode {
        return ScoreDisplayNode(type: .score)
    }
    
    /// Create a streak display
    static func createStreakDisplay() -> ScoreDisplayNode {
        return ScoreDisplayNode(type: .streak)
    }
    
    /// Create a lives display
    static func createLivesDisplay() -> ScoreDisplayNode {
        return ScoreDisplayNode(type: .lives)
    }
    
    /// Create a stars display
    static func createStarsDisplay() -> ScoreDisplayNode {
        return ScoreDisplayNode(type: .stars)
    }
}
