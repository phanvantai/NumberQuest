//
//  GameUINodes.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 21/6/25.
//

import SpriteKit
import SwiftUI

// MARK: - QuestionCardNode

/// Animated card that displays math questions with visual effects
class QuestionCardNode: SKNode {
    
    // MARK: - Properties
    
    private var backgroundCard: SKShapeNode!
    private var shadowCard: SKShapeNode!
    private var questionLabel: SKLabelNode!
    private var decorativeElements: [SKNode] = []
    
    private let cardSize: CGSize
    private let coordinateSystem: CoordinateSystem
    
    // Animation properties
    private var isAnimating = false
    private var pulseAnimation: SKAction?
    
    // MARK: - Initialization
    
    init(size: CGSize, coordinateSystem: CoordinateSystem) {
        self.cardSize = size
        self.coordinateSystem = coordinateSystem
        super.init()
        
        name = "questionCard"
        setupCard()
        setupDecorations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupCard() {
        // Shadow layer
        shadowCard = SKShapeNode(rectOf: cardSize, cornerRadius: coordinateSystem.scaledValue(25))
        shadowCard.fillColor = UIColor.black.withAlphaComponent(0.3)
        shadowCard.strokeColor = UIColor.clear
        shadowCard.position = CGPoint(x: 6, y: -6)
        shadowCard.zPosition = -2
        addChild(shadowCard)
        
        // Main card background
        backgroundCard = SKShapeNode(rectOf: cardSize, cornerRadius: coordinateSystem.scaledValue(25))
        backgroundCard.fillColor = UIColor.white.withAlphaComponent(0.95)
        backgroundCard.strokeColor = UIColor.white
        backgroundCard.lineWidth = coordinateSystem.scaledValue(4)
        backgroundCard.zPosition = -1
        
        // Add gradient effect using additional colored shapes
        let gradientOverlay = SKShapeNode(rectOf: CGSize(
            width: cardSize.width - 20,
            height: cardSize.height - 20
        ), cornerRadius: coordinateSystem.scaledValue(20))
        gradientOverlay.fillColor = UIColor.nqBlue.withAlphaComponent(0.05)
        gradientOverlay.strokeColor = UIColor.clear
        gradientOverlay.zPosition = 0
        backgroundCard.addChild(gradientOverlay)
        
        addChild(backgroundCard)
        
        // Question text label
        questionLabel = SKLabelNode()
        questionLabel.fontName = "Baloo2-Bold"
        questionLabel.fontSize = coordinateSystem.scaledValue(32)
        questionLabel.fontColor = UIColor.nqBlue
        questionLabel.horizontalAlignmentMode = .center
        questionLabel.verticalAlignmentMode = .center
        questionLabel.position = CGPoint(x: 0, y: 0)
        questionLabel.zPosition = 1
        questionLabel.text = "Ready to play?"
        addChild(questionLabel)
    }
    
    private func setupDecorations() {
        // Add floating sparkles around the card
        for i in 0..<6 {
            let sparkle = createSparkle()
            let angle = CGFloat(i) * CGFloat.pi / 3
            let radius = cardSize.width * 0.6
            
            sparkle.position = CGPoint(
                x: cos(angle) * radius,
                y: sin(angle) * radius
            )
            sparkle.zPosition = 2
            
            decorativeElements.append(sparkle)
            addChild(sparkle)
        }
        
        // Start sparkle animations
        animateSparkles()
    }
    
    private func createSparkle() -> SKNode {
        let sparkle = SKLabelNode(text: "✨")
        sparkle.fontSize = coordinateSystem.scaledValue(16)
        sparkle.alpha = 0.8
        return sparkle
    }
    
    private func animateSparkles() {
        for (index, sparkle) in decorativeElements.enumerated() {
            let delay = Double(index) * 0.3
            let twinkle = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                SKAction.group([
                    SKAction.scale(to: 1.3, duration: 0.5),
                    SKAction.fadeOut(withDuration: 0.5)
                ]),
                SKAction.group([
                    SKAction.scale(to: 1.0, duration: 0.5),
                    SKAction.fadeIn(withDuration: 0.5)
                ])
            ])
            
            sparkle.run(SKAction.repeatForever(twinkle))
        }
    }
    
    // MARK: - Public Methods
    
    /// Update the question text with animation
    func setQuestion(_ question: MathQuestion) {
        guard !isAnimating else { return }
        
        isAnimating = true
        
        // Scale down current text
        let scaleDown = SKAction.scale(to: 0.1, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let shrink = SKAction.group([scaleDown, fadeOut])
        
        // Update text and scale back up
        let updateText = SKAction.run { [weak self] in
            self?.questionLabel.text = question.questionText
        }
        
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let grow = SKAction.group([scaleUp, fadeIn])
        grow.timingMode = .easeOut
        
        let completion = SKAction.run { [weak self] in
            self?.isAnimating = false
        }
        
        let sequence = SKAction.sequence([shrink, updateText, grow, completion])
        questionLabel.run(sequence)
        
        // Add card bounce effect
        animateCardBounce()
    }
    
    /// Animate card entrance
    func animateEntrance(delay: TimeInterval = 0) {
        alpha = 0
        setScale(0.3)
        position.y -= 100
        
        let wait = SKAction.wait(forDuration: delay)
        let moveUp = SKAction.moveBy(x: 0, y: 100, duration: 0.5)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.5)
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        
        let entrance = SKAction.group([moveUp, scaleUp, fadeIn])
        entrance.timingMode = .easeOut
        
        let sequence = SKAction.sequence([wait, entrance])
        run(sequence)
    }
    
    /// Start pulsing animation for emphasis
    func startPulsing() {
        guard pulseAnimation == nil else { return }
        
        let scaleUp = SKAction.scale(to: 1.05, duration: 0.8)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.8)
        scaleUp.timingMode = .easeInOut
        scaleDown.timingMode = .easeInOut
        
        pulseAnimation = SKAction.repeatForever(SKAction.sequence([scaleUp, scaleDown]))
        run(pulseAnimation!, withKey: "pulse")
    }
    
    /// Stop pulsing animation
    func stopPulsing() {
        removeAction(forKey: "pulse")
        pulseAnimation = nil
        
        let resetScale = SKAction.scale(to: 1.0, duration: 0.3)
        run(resetScale)
    }
    
    private func animateCardBounce() {
        let bounceUp = SKAction.scale(to: 1.1, duration: 0.15)
        let bounceDown = SKAction.scale(to: 1.0, duration: 0.15)
        bounceUp.timingMode = .easeOut
        bounceDown.timingMode = .easeIn
        
        let bounce = SKAction.sequence([bounceUp, bounceDown])
        backgroundCard.run(bounce)
    }
}

// MARK: - AnswerButtonNode

/// Interactive button for answer selection with visual feedback
class AnswerButtonNode: SKNode {
    
    // MARK: - Properties
    
    private var backgroundShape: SKShapeNode!
    private var shadowShape: SKShapeNode!
    private var answerLabel: SKLabelNode!
    private var selectionOverlay: SKShapeNode!
    
    private let buttonSize: CGSize
    private let coordinateSystem: CoordinateSystem
    private let tapHandler: (Int) -> Void
    
    // State
    private(set) var answerValue: Int = 0
    private(set) var isEnabled = true
    private(set) var state: ButtonState = .normal
    
    // MARK: - Initialization
    
    init(size: CGSize, coordinateSystem: CoordinateSystem, tapHandler: @escaping (Int) -> Void) {
        self.buttonSize = size
        self.coordinateSystem = coordinateSystem
        self.tapHandler = tapHandler
        super.init()
        
        name = "answerButton"
        isUserInteractionEnabled = true
        setupButton()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupButton() {
        // Shadow
        shadowShape = SKShapeNode(rectOf: buttonSize, cornerRadius: coordinateSystem.scaledValue(20))
        shadowShape.fillColor = UIColor.black.withAlphaComponent(0.25)
        shadowShape.strokeColor = UIColor.clear
        shadowShape.position = CGPoint(x: 4, y: -4)
        shadowShape.zPosition = -2
        addChild(shadowShape)
        
        // Main button background
        backgroundShape = SKShapeNode(rectOf: buttonSize, cornerRadius: coordinateSystem.scaledValue(20))
        backgroundShape.fillColor = UIColor.nqGreen
        backgroundShape.strokeColor = UIColor.white
        backgroundShape.lineWidth = coordinateSystem.scaledValue(3)
        backgroundShape.zPosition = -1
        addChild(backgroundShape)
        
        // Selection overlay (hidden by default)
        selectionOverlay = SKShapeNode(rectOf: buttonSize, cornerRadius: coordinateSystem.scaledValue(20))
        selectionOverlay.fillColor = UIColor.white.withAlphaComponent(0.3)
        selectionOverlay.strokeColor = UIColor.clear
        selectionOverlay.zPosition = 0
        selectionOverlay.alpha = 0
        addChild(selectionOverlay)
        
        // Answer text
        answerLabel = SKLabelNode()
        answerLabel.fontName = "Baloo2-Bold"
        answerLabel.fontSize = coordinateSystem.scaledValue(28)
        answerLabel.fontColor = UIColor.white
        answerLabel.horizontalAlignmentMode = .center
        answerLabel.verticalAlignmentMode = .center
        answerLabel.position = CGPoint(x: 0, y: -2) // Slight offset for better visual centering
        answerLabel.zPosition = 1
        addChild(answerLabel)
    }
    
    // MARK: - Public Methods
    
    /// Set the answer value and update display
    func setAnswer(_ value: Int) {
        answerValue = value
        answerLabel.text = "\(value)"
    }
    
    /// Set button state with visual feedback
    func setState(_ newState: ButtonState, animated: Bool = true) {
        guard state != newState else { return }
        state = newState
        
        updateAppearance(animated: animated)
    }
    
    /// Enable or disable the button
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        isUserInteractionEnabled = enabled
        
        if enabled {
            setState(.normal)
        } else {
            setState(.disabled)
        }
    }
    
    /// Animate button entrance
    func animateEntrance(delay: TimeInterval = 0) {
        alpha = 0
        setScale(0.1)
        
        let wait = SKAction.wait(forDuration: delay)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.4)
        let fadeIn = SKAction.fadeIn(withDuration: 0.4)
        
        scaleUp.timingMode = .easeOut
        let entrance = SKAction.group([scaleUp, fadeIn])
        
        // Add bounce effect
        let bounceUp = SKAction.scale(to: 1.1, duration: 0.1)
        let bounceDown = SKAction.scale(to: 1.0, duration: 0.1)
        let bounce = SKAction.sequence([bounceUp, bounceDown])
        
        let sequence = SKAction.sequence([wait, entrance, bounce])
        run(sequence)
    }
    
    /// Add touch feedback animation
    func addTouchFeedback() {
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        let feedback = SKAction.sequence([scaleDown, scaleUp])
        
        run(feedback, withKey: "touchFeedback")
    }
    
    /// Set hover state (for touch tracking)
    func setHovered(_ hovered: Bool) {
        guard isEnabled, state == .normal else { return }
        
        let alpha: CGFloat = hovered ? 0.3 : 0.0
        let action = SKAction.fadeAlpha(to: alpha, duration: 0.1)
        selectionOverlay.run(action)
    }
    
    private func updateAppearance(animated: Bool) {
        let duration = animated ? 0.2 : 0.0
        
        var fillColor: UIColor
        var strokeColor: UIColor
        var labelColor: UIColor
        var overlayAlpha: CGFloat = 0
        
        switch state {
        case .normal:
            fillColor = UIColor.nqGreen
            strokeColor = UIColor.white
            labelColor = UIColor.white
            
        case .pressed:
            fillColor = UIColor.nqGreen.withAlphaComponent(0.8)
            strokeColor = UIColor.white
            labelColor = UIColor.white
            overlayAlpha = 0.5
            
        case .correct:
            fillColor = UIColor.nqGreen
            strokeColor = UIColor.nqYellow
            labelColor = UIColor.white
            
        case .incorrect:
            fillColor = UIColor.nqCoral
            strokeColor = UIColor.nqRed
            labelColor = UIColor.white
            
        case .disabled:
            fillColor = UIColor.gray
            strokeColor = UIColor.lightGray
            labelColor = UIColor.lightGray
        }
        
        // Animate color changes
        let colorChange = SKAction.run {
            self.backgroundShape.fillColor = fillColor
            self.backgroundShape.strokeColor = strokeColor
            self.answerLabel.fontColor = labelColor
        }
        
        let overlayFade = SKAction.fadeAlpha(to: overlayAlpha, duration: duration)
        
        if animated {
            let fadeOut = SKAction.fadeOut(withDuration: duration / 2)
            let fadeIn = SKAction.fadeIn(withDuration: duration / 2)
            let sequence = SKAction.sequence([fadeOut, colorChange, fadeIn])
            
            run(sequence)
            selectionOverlay.run(overlayFade)
        } else {
            run(colorChange)
            selectionOverlay.alpha = overlayAlpha
        }
        
        // Add special effects for correct/incorrect states
        if state == .correct {
            addCorrectEffect()
        } else if state == .incorrect {
            addIncorrectEffect()
        }
    }
    
    private func addCorrectEffect() {
        // Scale bounce animation
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        scaleUp.timingMode = .easeOut
        scaleDown.timingMode = .easeIn
        
        let bounce = SKAction.sequence([scaleUp, scaleDown])
        run(bounce)
        
        // Add sparkle effect
        for i in 0..<8 {
            let sparkle = SKLabelNode(text: "✨")
            sparkle.fontSize = coordinateSystem.scaledValue(12)
            sparkle.zPosition = 10
            
            let angle = CGFloat(i) * CGFloat.pi / 4
            let radius = buttonSize.width * 0.7
            sparkle.position = CGPoint(
                x: cos(angle) * radius,
                y: sin(angle) * radius
            )
            
            addChild(sparkle)
            
            // Animate sparkle
            let expand = SKAction.scale(to: 1.5, duration: 0.3)
            let fade = SKAction.fadeOut(withDuration: 0.3)
            let remove = SKAction.removeFromParent()
            
            let sparkleSequence = SKAction.sequence([
                SKAction.group([expand, fade]),
                remove
            ])
            sparkle.run(sparkleSequence)
        }
    }
    
    private func addIncorrectEffect() {
        // Shake animation
        let shakeLeft = SKAction.moveBy(x: -10, y: 0, duration: 0.05)
        let shakeRight = SKAction.moveBy(x: 20, y: 0, duration: 0.1)
        let shakeCenter = SKAction.moveBy(x: -10, y: 0, duration: 0.05)
        
        let shake = SKAction.sequence([shakeLeft, shakeRight, shakeCenter])
        let shakeRepeat = SKAction.repeat(shake, count: 2)
        
        run(shakeRepeat)
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled, state != .correct, state != .incorrect else { return }
        setState(.pressed, animated: true)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled, state == .pressed else { return }
        
        setState(.normal, animated: true)
        
        // Check if touch ended within button bounds
        if let touch = touches.first {
            let location = touch.location(in: self)
            let buttonFrame = CGRect(
                x: -buttonSize.width/2,
                y: -buttonSize.height/2,
                width: buttonSize.width,
                height: buttonSize.height
            )
            
            if buttonFrame.contains(location) {
                tapHandler(answerValue)
            }
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard state == .pressed else { return }
        setState(.normal, animated: true)
    }
}

// MARK: - ScoreDisplayNode

/// Animated display for score, streak, and progress information
class ScoreDisplayNode: SKNode {
    
    // MARK: - Properties
    
    private var backgroundShape: SKShapeNode!
    private var scoreLabel: SKLabelNode!
    private var streakLabel: SKLabelNode!
    private var progressBar: SKNode!
    private var progressFill: SKShapeNode!
    
    private let displaySize: CGSize
    private let coordinateSystem: CoordinateSystem
    
    // Data
    private var currentScore: Int = 0
    private var currentStreak: Int = 0
    private var currentProgress: Float = 0.0
    
    // MARK: - Initialization
    
    init(size: CGSize, coordinateSystem: CoordinateSystem) {
        self.displaySize = size
        self.coordinateSystem = coordinateSystem
        super.init()
        
        name = "scoreDisplay"
        setupDisplay()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupDisplay() {
        // Background
        backgroundShape = SKShapeNode(rectOf: displaySize, cornerRadius: coordinateSystem.scaledValue(15))
        backgroundShape.fillColor = UIColor.black.withAlphaComponent(0.3)
        backgroundShape.strokeColor = UIColor.white.withAlphaComponent(0.5)
        backgroundShape.lineWidth = 2
        backgroundShape.zPosition = -1
        addChild(backgroundShape)
        
        // Score label
        scoreLabel = SKLabelNode()
        scoreLabel.fontName = "Baloo2-Bold"
        scoreLabel.fontSize = coordinateSystem.scaledValue(20)
        scoreLabel.fontColor = UIColor.white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .center
        scoreLabel.position = CGPoint(x: -displaySize.width/2 + 15, y: 10)
        scoreLabel.text = "Score: 0"
        addChild(scoreLabel)
        
        // Streak label
        streakLabel = SKLabelNode()
        streakLabel.fontName = "Baloo2-Bold"
        streakLabel.fontSize = coordinateSystem.scaledValue(16)
        streakLabel.fontColor = UIColor.nqYellow
        streakLabel.horizontalAlignmentMode = .left
        streakLabel.verticalAlignmentMode = .center
        streakLabel.position = CGPoint(x: -displaySize.width/2 + 15, y: -15)
        streakLabel.text = "🔥 Streak: 0"
        addChild(streakLabel)
        
        // Progress bar
        setupProgressBar()
    }
    
    private func setupProgressBar() {
        progressBar = SKNode()
        progressBar.position = CGPoint(x: displaySize.width/4, y: 0)
        addChild(progressBar)
        
        let barWidth = coordinateSystem.scaledValue(100)
        let barHeight = coordinateSystem.scaledValue(8)
        
        // Progress background
        let progressBg = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: barHeight/2)
        progressBg.fillColor = UIColor.white.withAlphaComponent(0.3)
        progressBg.strokeColor = UIColor.clear
        progressBar.addChild(progressBg)
        
        // Progress fill
        progressFill = SKShapeNode(rectOf: CGSize(width: 0, height: barHeight), cornerRadius: barHeight/2)
        progressFill.fillColor = UIColor.nqGreen
        progressFill.strokeColor = UIColor.clear
        progressFill.position = CGPoint(x: -barWidth/2, y: 0)
        progressFill.anchorPoint = CGPoint(x: 0, y: 0.5)
        progressBar.addChild(progressFill)
    }
    
    // MARK: - Public Methods
    
    /// Update score with animation
    func updateScore(_ newScore: Int, animated: Bool = true) {
        let oldScore = currentScore
        currentScore = newScore
        
        if animated && newScore > oldScore {
            animateScoreIncrease(from: oldScore, to: newScore)
        } else {
            scoreLabel.text = "Score: \(newScore)"
        }
    }
    
    /// Update streak with animation
    func updateStreak(_ newStreak: Int, animated: Bool = true) {
        currentStreak = newStreak
        
        let streakText = newStreak > 0 ? "🔥 Streak: \(newStreak)" : "Streak: 0"
        
        if animated {
            let pulse = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1)
            ])
            streakLabel.run(pulse)
        }
        
        streakLabel.text = streakText
        
        // Change color based on streak
        if newStreak >= 5 {
            streakLabel.fontColor = UIColor.nqOrange
        } else if newStreak >= 3 {
            streakLabel.fontColor = UIColor.nqYellow
        } else {
            streakLabel.fontColor = UIColor.white
        }
    }
    
    /// Update progress bar
    func updateProgress(_ progress: Float, animated: Bool = true) {
        currentProgress = max(0, min(1, progress))
        
        let barWidth = coordinateSystem.scaledValue(100)
        let newWidth = CGFloat(currentProgress) * barWidth
        
        if animated {
            let resize = SKAction.resize(toWidth: newWidth, duration: 0.5)
            resize.timingMode = .easeOut
            progressFill.run(resize)
        } else {
            progressFill.xScale = CGFloat(currentProgress)
        }
    }
    
    /// Animate entrance
    func animateEntrance(delay: TimeInterval = 0) {
        alpha = 0
        position.x -= 200
        
        let wait = SKAction.wait(forDuration: delay)
        let slideIn = SKAction.moveBy(x: 200, y: 0, duration: 0.5)
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        
        slideIn.timingMode = .easeOut
        let entrance = SKAction.group([slideIn, fadeIn])
        
        let sequence = SKAction.sequence([wait, entrance])
        run(sequence)
    }
    
    private func animateScoreIncrease(from oldScore: Int, to newScore: Int) {
        let difference = newScore - oldScore
        
        // Floating score animation
        let floatingScore = SKLabelNode(text: "+\(difference)")
        floatingScore.fontName = "Baloo2-Bold"
        floatingScore.fontSize = coordinateSystem.scaledValue(18)
        floatingScore.fontColor = UIColor.nqGreen
        floatingScore.position = CGPoint(x: scoreLabel.position.x + 60, y: scoreLabel.position.y)
        floatingScore.zPosition = 10
        addChild(floatingScore)
        
        // Animate floating number
        let moveUp = SKAction.moveBy(x: 0, y: 30, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let remove = SKAction.removeFromParent()
        
        let floatingSequence = SKAction.sequence([
            SKAction.group([moveUp, fadeOut]),
            remove
        ])
        floatingScore.run(floatingSequence)
        
        // Animate score counter
        let counterAnimation = SKAction.customAction(withDuration: 0.5) { [weak self] _, elapsedTime in
            let progress = elapsedTime / 0.5
            let currentValue = oldScore + Int(Float(difference) * Float(progress))
            self?.scoreLabel.text = "Score: \(currentValue)"
        }
        
        let completion = SKAction.run { [weak self] in
            self?.scoreLabel.text = "Score: \(newScore)"
        }
        
        let sequence = SKAction.sequence([counterAnimation, completion])
        run(sequence)
        
        // Scale pulse for score label
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        scoreLabel.run(pulse)
    }
}

// MARK: - TimerNode

/// Countdown timer with visual effects and warnings
class TimerNode: SKNode {
    
    // MARK: - Properties
    
    private var backgroundRing: SKShapeNode!
    private var progressRing: SKShapeNode!
    private var timeLabel: SKLabelNode!
    private var warningEffect: SKNode?
    
    private let radius: CGFloat
    private let coordinateSystem: CoordinateSystem
    
    // Timer data
    private var totalTime: TimeInterval = 30
    private var remainingTime: TimeInterval = 30
    private var isRunning = false
    private var updateTimer: Timer?
    
    // Callbacks
    var onTimeUpdate: ((TimeInterval) -> Void)?
    var onTimeExpired: (() -> Void)?
    
    // MARK: - Initialization
    
    init(radius: CGFloat, coordinateSystem: CoordinateSystem) {
        self.radius = radius
        self.coordinateSystem = coordinateSystem
        super.init()
        
        name = "timer"
        setupTimer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupTimer() {
        // Background ring
        backgroundRing = SKShapeNode(circleOfRadius: radius)
        backgroundRing.fillColor = UIColor.clear
        backgroundRing.strokeColor = UIColor.white.withAlphaComponent(0.3)
        backgroundRing.lineWidth = coordinateSystem.scaledValue(6)
        backgroundRing.zPosition = -1
        addChild(backgroundRing)
        
        // Progress ring
        let progressPath = UIBezierPath(
            arcCenter: .zero,
            radius: radius,
            startAngle: -CGFloat.pi/2,
            endAngle: CGFloat.pi * 1.5,
            clockwise: true
        )
        
        progressRing = SKShapeNode(path: progressPath.cgPath)
        progressRing.fillColor = UIColor.clear
        progressRing.strokeColor = UIColor.nqGreen
        progressRing.lineWidth = coordinateSystem.scaledValue(6)
        progressRing.lineCap = .round
        progressRing.zPosition = 0
        addChild(progressRing)
        
        // Time label
        timeLabel = SKLabelNode()
        timeLabel.fontName = "Baloo2-Bold"
        timeLabel.fontSize = coordinateSystem.scaledValue(18)
        timeLabel.fontColor = UIColor.white
        timeLabel.horizontalAlignmentMode = .center
        timeLabel.verticalAlignmentMode = .center
        timeLabel.position = CGPoint(x: 0, y: -3)
        timeLabel.zPosition = 1
        updateTimeLabel()
        addChild(timeLabel)
    }
    
    // MARK: - Public Methods
    
    /// Start the timer with specified duration
    func startTimer(duration: TimeInterval) {
        totalTime = duration
        remainingTime = duration
        isRunning = true
        
        updateTimeLabel()
        updateProgressRing()
        
        // Start update timer
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTick()
        }
        
        // Reset colors
        progressRing.strokeColor = UIColor.nqGreen
        timeLabel.fontColor = UIColor.white
        removeWarningEffects()
    }
    
    /// Pause the timer
    func pauseTimer() {
        isRunning = false
        updateTimer?.invalidate()
        updateTimer = nil
    }
    
    /// Resume the timer
    func resumeTimer() {
        guard remainingTime > 0 else { return }
        
        isRunning = true
        updateTimer?.invalidate()
        updateTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateTick()
        }
    }
    
    /// Stop and reset the timer
    func stopTimer() {
        isRunning = false
        updateTimer?.invalidate()
        updateTimer = nil
        remainingTime = totalTime
        updateTimeLabel()
        updateProgressRing()
        removeWarningEffects()
    }
    
    /// Add time to the timer
    func addTime(_ seconds: TimeInterval) {
        remainingTime += seconds
        totalTime += seconds
        updateTimeLabel()
        updateProgressRing()
        
        // Show bonus time effect
        showBonusTimeEffect(Int(seconds))
    }
    
    /// Animate entrance
    func animateEntrance(delay: TimeInterval = 0) {
        alpha = 0
        setScale(0.1)
        
        let wait = SKAction.wait(forDuration: delay)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.4)
        let fadeIn = SKAction.fadeIn(withDuration: 0.4)
        
        scaleUp.timingMode = .easeOut
        let entrance = SKAction.group([scaleUp, fadeIn])
        
        let sequence = SKAction.sequence([wait, entrance])
        run(sequence)
    }
    
    // MARK: - Private Methods
    
    private func updateTick() {
        guard isRunning, remainingTime > 0 else {
            if remainingTime <= 0 {
                timeExpired()
            }
            return
        }
        
        remainingTime -= 0.1
        updateTimeLabel()
        updateProgressRing()
        
        // Check for warning states
        let timePercentage = remainingTime / totalTime
        if timePercentage <= 0.2 && timePercentage > 0.1 {
            showWarning()
        } else if timePercentage <= 0.1 {
            showCriticalWarning()
        }
        
        onTimeUpdate?(remainingTime)
    }
    
    private func updateTimeLabel() {
        let minutes = Int(remainingTime) / 60
        let seconds = Int(remainingTime) % 60
        
        if minutes > 0 {
            timeLabel.text = String(format: "%d:%02d", minutes, seconds)
        } else {
            timeLabel.text = String(format: "%d", seconds)
        }
    }
    
    private func updateProgressRing() {
        let progress = remainingTime / totalTime
        let endAngle = -CGFloat.pi/2 + (CGFloat.pi * 2 * CGFloat(progress))
        
        let progressPath = UIBezierPath(
            arcCenter: .zero,
            radius: radius,
            startAngle: -CGFloat.pi/2,
            endAngle: endAngle,
            clockwise: true
        )
        
        progressRing.path = progressPath.cgPath
    }
    
    private func showWarning() {
        guard progressRing.strokeColor != UIColor.nqOrange else { return }
        
        progressRing.strokeColor = UIColor.nqOrange
        timeLabel.fontColor = UIColor.nqOrange
        
        // Gentle pulse
        let pulse = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.3),
            SKAction.scale(to: 1.0, duration: 0.3)
        ])
        run(SKAction.repeatForever(pulse), withKey: "warningPulse")
    }
    
    private func showCriticalWarning() {
        guard progressRing.strokeColor != UIColor.nqRed else { return }
        
        progressRing.strokeColor = UIColor.nqRed
        timeLabel.fontColor = UIColor.nqRed
        
        // Remove gentle pulse
        removeAction(forKey: "warningPulse")
        
        // Faster urgent pulse
        let urgentPulse = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.15),
            SKAction.scale(to: 1.0, duration: 0.15)
        ])
        run(SKAction.repeatForever(urgentPulse), withKey: "criticalPulse")
        
        // Add screen flash effect if not already added
        if warningEffect == nil {
            addScreenFlash()
        }
    }
    
    private func addScreenFlash() {
        warningEffect = SKNode()
        warningEffect!.zPosition = -10
        addChild(warningEffect!)
        
        let flashInterval: TimeInterval = 1.0
        let flash = SKAction.sequence([
            SKAction.run { [weak self] in
                let overlay = SKSpriteNode(color: UIColor.nqRed.withAlphaComponent(0.1), size: CGSize(width: 1000, height: 1000))
                overlay.zPosition = -5
                self?.warningEffect?.addChild(overlay)
                
                let fade = SKAction.fadeOut(withDuration: 0.5)
                let remove = SKAction.removeFromParent()
                overlay.run(SKAction.sequence([fade, remove]))
            },
            SKAction.wait(forDuration: flashInterval)
        ])
        
        warningEffect!.run(SKAction.repeatForever(flash))
    }
    
    private func removeWarningEffects() {
        removeAction(forKey: "warningPulse")
        removeAction(forKey: "criticalPulse")
        
        warningEffect?.removeFromParent()
        warningEffect = nil
        
        // Reset scale
        let resetScale = SKAction.scale(to: 1.0, duration: 0.2)
        run(resetScale)
    }
    
    private func showBonusTimeEffect(_ seconds: Int) {
        let bonusLabel = SKLabelNode(text: "+\(seconds)s")
        bonusLabel.fontName = "Baloo2-Bold"
        bonusLabel.fontSize = coordinateSystem.scaledValue(16)
        bonusLabel.fontColor = UIColor.nqGreen
        bonusLabel.position = CGPoint(x: 0, y: radius + 20)
        bonusLabel.zPosition = 10
        addChild(bonusLabel)
        
        let moveUp = SKAction.moveBy(x: 0, y: 30, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let remove = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([
            SKAction.group([moveUp, fadeOut]),
            remove
        ])
        bonusLabel.run(sequence)
    }
    
    private func timeExpired() {
        isRunning = false
        updateTimer?.invalidate()
        updateTimer = nil
        remainingTime = 0
        
        updateTimeLabel()
        updateProgressRing()
        
        // Final flash effect
        let flash = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        run(SKAction.repeat(flash, count: 3))
        
        onTimeExpired?()
    }
    
    deinit {
        updateTimer?.invalidate()
    }
}

// MARK: - Supporting Types

enum ButtonState {
    case normal
    case pressed
    case correct
    case incorrect
    case disabled
}
