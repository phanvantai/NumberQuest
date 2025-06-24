//
//  AnswerButtonNode.swift
//  NumberQuest
//
//  Created by NumberQuest on 2024.
//

import SpriteKit
import UIKit

/// Interactive answer button with visual effects and animations
class AnswerButtonNode: SKNode {
    
    // MARK: - Properties
    
    private var backgroundShape: SKShapeNode!
    private var answerLabel: SKLabelNode!
    private var shadowNode: SKShapeNode!
    private var glowNode: SKNode?
    
    private let buttonSize: CGSize
    private var answerText: String = ""
    private var isCorrectAnswer: Bool = false
    private var isPressed: Bool = false
    
    // Callback for button tap
    var onTap: ((String, Bool) -> Void)?
    
    // MARK: - Initialization
    
    init(size: CGSize, answer: String, isCorrect: Bool = false) {
        self.buttonSize = size
        self.answerText = answer
        self.isCorrectAnswer = isCorrect
        super.init()
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupButton() {
        // Enable user interaction
        isUserInteractionEnabled = true
        
        // Create shadow
        createShadow()
        
        // Create background
        createBackground()
        
        // Create label
        createLabel()
        
        // Set up accessibility
        setupAccessibility()
    }
    
    private func createShadow() {
      shadowNode = SKShapeNode(rect: CGRect(
            x: -buttonSize.width / 2,
            y: -buttonSize.height / 2,
            width: buttonSize.width,
            height: buttonSize.height
        ), cornerRadius: 15)
        
        shadowNode.fillColor = SpriteKitColors.UI.cardShadow
        shadowNode.strokeColor = .clear
        shadowNode.position = CGPoint(x: 2, y: -2)
        shadowNode.zPosition = -1
        
        addChild(shadowNode)
    }
    
    private func createBackground() {
      backgroundShape = SKShapeNode(rect: CGRect(
            x: -buttonSize.width / 2,
            y: -buttonSize.height / 2,
            width: buttonSize.width,
            height: buttonSize.height
        ), cornerRadius: 15)
        
        backgroundShape.fillColor = SpriteKitColors.UI.answerDefault
        backgroundShape.strokeColor = UIColor.white.withAlphaComponent(0.4)
        backgroundShape.lineWidth = 2
        backgroundShape.zPosition = 0
        
        addChild(backgroundShape)
    }
    
    private func createLabel() {
        answerLabel = SKLabelNode()
        answerLabel.fontName = "Baloo2-VariableFont_wght"
        answerLabel.fontSize = 24
        answerLabel.fontColor = SpriteKitColors.Text.primary
        answerLabel.horizontalAlignmentMode = .center
        answerLabel.verticalAlignmentMode = .center
        answerLabel.text = answerText
        answerLabel.zPosition = 1
        
        // Add text shadow for better readability
        let textShadow = SKLabelNode()
        textShadow.fontName = answerLabel.fontName
        textShadow.fontSize = answerLabel.fontSize
        textShadow.fontColor = UIColor.black.withAlphaComponent(0.3)
        textShadow.horizontalAlignmentMode = .center
        textShadow.verticalAlignmentMode = .center
        textShadow.text = answerText
        textShadow.position = CGPoint(x: 1, y: -1)
        textShadow.zPosition = 0
        
        answerLabel.addChild(textShadow)
        addChild(answerLabel)
    }
    
    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityLabel = "Answer button"
        accessibilityValue = answerText
        accessibilityHint = "Tap to select this answer"
        accessibilityTraits = .button
    }
    
    // MARK: - Public Methods
    
    /// Update the answer text
    func setAnswer(_ answer: String, isCorrect: Bool = false) {
        answerText = answer
        isCorrectAnswer = isCorrect
        answerLabel.text = answer
        
        // Update shadow text
        if let shadowLabel = answerLabel.children.first as? SKLabelNode {
            shadowLabel.text = answer
        }
        
        // Update accessibility
        accessibilityValue = answer
    }
    
    /// Get the current answer text
    var answer: String {
        return answerText
    }
    
    /// Enable or disable the button
    func setEnabled(_ enabled: Bool) {
        isUserInteractionEnabled = enabled
        alpha = enabled ? 1.0 : 0.5
    }
    
    /// Animate button appearing
    func animateIn(delay: TimeInterval = 0.0) {
        // Start invisible and scaled down
        alpha = 0
        setScale(0.5)
        
        let wait = SKAction.wait(forDuration: delay)
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        scaleUp.timingMode = .easeOut
        
        let appearSequence = SKAction.sequence([
            wait,
            SKAction.group([fadeIn, scaleUp])
        ])
        
        run(appearSequence)
    }
    
    /// Animate button disappearing
    func animateOut(delay: TimeInterval = 0.0, completion: @escaping () -> Void = {}) {
        let wait = SKAction.wait(forDuration: delay)
        let scaleDown = SKAction.scale(to: 0.1, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let disappear = SKAction.group([scaleDown, fadeOut])
        
        let complete = SKAction.run(completion)
        let sequence = SKAction.sequence([wait, disappear, complete])
        
        run(sequence)
    }
    
    /// Show correct answer state
    func showCorrectState() {
        // Change to success colors
        backgroundShape.fillColor = SpriteKitColors.UI.answerCorrect
        
        // Add glow effect
        addGlowEffect()
        
        // Scale animation
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        let bounce = SKAction.sequence([scaleUp, scaleDown])
        
        run(bounce)
    }
    
    /// Show wrong answer state
    func showWrongState() {
        // Change to error colors
        backgroundShape.fillColor = SpriteKitColors.UI.answerWrong
        
        // Shake animation
        let shakeLeft = SKAction.moveBy(x: -5, y: 0, duration: 0.05)
        let shakeRight = SKAction.moveBy(x: 10, y: 0, duration: 0.05)
        let shakeCenter = SKAction.moveBy(x: -5, y: 0, duration: 0.05)
        let shakeSequence = SKAction.sequence([shakeLeft, shakeRight, shakeCenter])
        let shakeRepeat = SKAction.repeat(shakeSequence, count: 2)
        
        run(shakeRepeat)
    }
    
    /// Reset button to default state
    func resetToDefaultState() {
        removeGlowEffect()
        backgroundShape.fillColor = SpriteKitColors.UI.answerDefault
        setScale(1.0)
        position = CGPoint.zero
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isUserInteractionEnabled else { return }
        
        isPressed = true
        
        // Visual feedback for press
        let pressedScale = SKAction.scale(to: 0.95, duration: 0.1)
        let pressedColor = SKAction.run {
            self.backgroundShape.fillColor = SpriteKitColors.UI.primaryButtonPressed
        }
        
        let pressAnimation = SKAction.group([pressedScale, pressedColor])
        run(pressAnimation)
        
        // Play button tap sound
        playSound(.buttonTap, haptic: .light)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isUserInteractionEnabled && isPressed else { return }
        
        isPressed = false
        
        // Check if touch is still inside the button
        if let touch = touches.first {
            let location = touch.location(in: self)
            let buttonRect = CGRect(
                x: -buttonSize.width / 2,
                y: -buttonSize.height / 2,
                width: buttonSize.width,
                height: buttonSize.height
            )
            
            if buttonRect.contains(location) {
                // Button was tapped
                handleButtonTap()
            }
        }
        
        // Restore visual state
        restoreFromPressedState()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isPressed = false
        restoreFromPressedState()
    }
    
    // MARK: - Private Methods
    
    private func handleButtonTap() {
        // Call the callback
        onTap?(answerText, isCorrectAnswer)
        
        // Disable button to prevent multiple taps
        setEnabled(false)
    }
    
    private func restoreFromPressedState() {
        let normalScale = SKAction.scale(to: 1.0, duration: 0.1)
        let normalColor = SKAction.run {
            self.backgroundShape.fillColor = SpriteKitColors.UI.answerDefault
        }
        
        let restoreAnimation = SKAction.group([normalScale, normalColor])
        run(restoreAnimation)
    }
    
    private func addGlowEffect() {
        removeGlowEffect() // Remove existing glow
        
        let glowShape = SKShapeNode(rect: CGRect(
            x: -buttonSize.width / 2 - 5,
            y: -buttonSize.height / 2 - 5,
            width: buttonSize.width + 10,
            height: buttonSize.height + 10
        ), cornerRadius: 20)
        
        glowShape.fillColor = .clear
        glowShape.strokeColor = SpriteKitColors.UI.answerCorrect
        glowShape.lineWidth = 3
        glowShape.alpha = 0.7
        glowShape.zPosition = -0.5
        
        // Pulsing animation
        let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: 0.5)
        let fadeIn = SKAction.fadeAlpha(to: 0.7, duration: 0.5)
        let pulse = SKAction.sequence([fadeOut, fadeIn])
        let pulseForever = SKAction.repeatForever(pulse)
        
        glowShape.run(pulseForever)
        addChild(glowShape)
        
        // Store reference for removal
        glowNode = glowShape
    }
    
    private func removeGlowEffect() {
        glowNode?.removeFromParent()
        glowNode = nil
    }
}

// MARK: - Factory Methods

extension AnswerButtonNode {
    /// Create a standard answer button for the game
    static func createGameAnswerButton(answer: String, isCorrect: Bool = false) -> AnswerButtonNode {
        let buttonSize = CGSize(width: 120, height: 60)
        let button = AnswerButtonNode(size: buttonSize, answer: answer, isCorrect: isCorrect)
        return button
    }
    
    /// Create a large answer button for complex answers
    static func createLargeAnswerButton(answer: String, isCorrect: Bool = false) -> AnswerButtonNode {
        let buttonSize = CGSize(width: 160, height: 80)
        let button = AnswerButtonNode(size: buttonSize, answer: answer, isCorrect: isCorrect)
        return button
    }
}

// MARK: - Enhanced Answer Button Animations

extension AnswerButtonNode {
    /// Add pulsing glow animation for dramatic effect
    func addPulsingGlow() {
        // Remove any existing glow first
        removeGlowEffect()
        
        // Create enhanced glow effect
        let glowNode = self.copy() as! AnswerButtonNode
        glowNode.alpha = 0.8
        glowNode.setScale(1.1)
        glowNode.zPosition = self.zPosition - 1
        glowNode.backgroundShape.fillColor = UIColor.cyan
        glowNode.backgroundShape.strokeColor = .clear
        
        // Add blur effect for better glow
        let blur = SKEffectNode()
        blur.shouldRasterize = true
        blur.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": 8])
        blur.addChild(glowNode)
        
        if let parent = self.parent {
            parent.addChild(blur)
        }
        
        // Pulsing animation
        let pulseIn = SKAction.scale(to: 1.15, duration: 0.6)
        let pulseOut = SKAction.scale(to: 1.05, duration: 0.6)
        let pulse = SKAction.sequence([pulseIn, pulseOut])
        let pulsing = SKAction.repeatForever(pulse)
        
        blur.run(pulsing)
        
        // Store reference for removal
        self.glowNode = blur
    }
    
    /// Enhanced bounce animation with trail effect
    func bounceWithTrail() {
        let originalPosition = position
        
        // Main bounce
        let bounceUp = SKAction.moveBy(x: 0, y: 15, duration: 0.15)
        bounceUp.timingMode = .easeOut
        let bounceDown = SKAction.move(to: originalPosition, duration: 0.15)
        bounceDown.timingMode = .easeIn
        
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.15)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.15)
        
        let bounceAnimation = SKAction.group([
            SKAction.sequence([bounceUp, bounceDown]),
            SKAction.sequence([scaleUp, scaleDown])
        ])
        
        run(bounceAnimation)
        
        // Create particle trail
        for i in 0..<3 {
            let trail = SKLabelNode()
            trail.text = "💫"
            trail.fontSize = 12
            trail.position = position
            trail.zPosition = 999
            trail.alpha = 0.7
            
            parent?.addChild(trail)
            
            let delay = SKAction.wait(forDuration: Double(i) * 0.05)
            let trailMove = SKAction.moveBy(x: CGFloat.random(in: -20...20), y: 30, duration: 0.8)
            let trailFade = SKAction.fadeOut(withDuration: 0.8)
            let trailCleanup = SKAction.removeFromParent()
            
            let trailSequence = SKAction.sequence([
                delay,
                SKAction.group([trailMove, trailFade]),
                trailCleanup
            ])
            
            trail.run(trailSequence)
        }
    }
}
