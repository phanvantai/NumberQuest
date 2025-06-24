//
//  TimerNode.swift
//  NumberQuest
//
//  Created by NumberQuest on 2024.
//

import SpriteKit
import UIKit

/// Countdown timer with visual effects and animations
class TimerNode: SKNode {
    
    // MARK: - Properties
    
    private var backgroundRing: SKShapeNode!
    private var progressRing: SKShapeNode!
    private var timerLabel: SKLabelNode!
    private var iconLabel: SKLabelNode!
    
    private let radius: CGFloat
    private var totalTime: TimeInterval = 60.0
    private var currentTime: TimeInterval = 60.0
    private var isRunning: Bool = false
    private var isTimerPaused: Bool = false
    
    // Callback for timer events
    var onTimeChanged: ((TimeInterval) -> Void)?
    var onTimeExpired: (() -> Void)?
    var onWarning: ((TimeInterval) -> Void)? // Called when time is low
    
    // Warning thresholds
    private let warningTime: TimeInterval = 10.0
    private let criticalTime: TimeInterval = 5.0
    
    // MARK: - Initialization
    
    init(radius: CGFloat = 40) {
        self.radius = radius
        super.init()
        setupTimer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupTimer() {
        // Create background ring
        createBackgroundRing()
        
        // Create progress ring
        createProgressRing()
        
        // Create icon
        createIcon()
        
        // Create timer label
        createTimerLabel()
        
        // Set up accessibility
        setupAccessibility()
    }
    
    private func createBackgroundRing() {
        let ringPath = UIBezierPath(
            arcCenter: .zero,
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: CGFloat.pi * 3 / 2,
            clockwise: true
        )
        
        backgroundRing = SKShapeNode(path: ringPath.cgPath)
        backgroundRing.strokeColor = UIColor.white.withAlphaComponent(0.2)
        backgroundRing.fillColor = .clear
        backgroundRing.lineWidth = 6
        backgroundRing.zPosition = 0
        
        addChild(backgroundRing)
    }
    
    private func createProgressRing() {
        let ringPath = UIBezierPath(
            arcCenter: .zero,
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: CGFloat.pi * 3 / 2,
            clockwise: true
        )
        
        progressRing = SKShapeNode(path: ringPath.cgPath)
        progressRing.strokeColor = SpriteKitColors.Text.timer
        progressRing.fillColor = .clear
        progressRing.lineWidth = 8
        progressRing.lineCap = .round
        progressRing.zPosition = 1
        
        addChild(progressRing)
    }
    
    private func createIcon() {
        iconLabel = SKLabelNode()
        iconLabel.text = "⏰"
        iconLabel.fontSize = 16
        iconLabel.horizontalAlignmentMode = .center
        iconLabel.verticalAlignmentMode = .center
        iconLabel.position = CGPoint(x: 0, y: 10)
        iconLabel.zPosition = 2
        
        addChild(iconLabel)
    }
    
    private func createTimerLabel() {
        timerLabel = SKLabelNode()
        timerLabel.fontName = "Baloo2-VariableFont_wght"
        timerLabel.fontSize = 14
        timerLabel.fontColor = SpriteKitColors.Text.timer
        timerLabel.horizontalAlignmentMode = .center
        timerLabel.verticalAlignmentMode = .center
        timerLabel.position = CGPoint(x: 0, y: -10)
        timerLabel.zPosition = 2
        
        updateTimerLabel()
        addChild(timerLabel)
    }
    
    private func setupAccessibility() {
        isAccessibilityElement = true
        accessibilityLabel = "Timer"
        accessibilityTraits = .staticText
        updateAccessibilityValue()
    }
    
    // MARK: - Public Methods
    
    /// Start the timer with a specific duration
    func startTimer(duration: TimeInterval) {
        totalTime = duration
        currentTime = duration
        isRunning = true
        isTimerPaused = false
        
        updateDisplay()
        runTimerUpdate()
    }
    
    /// Pause the timer
    func pauseTimer() {
        isTimerPaused = true
        removeAction(forKey: "timerUpdate")
    }
    
    /// Resume the timer
    func resumeTimer() {
        guard isRunning && isTimerPaused else { return }
        isTimerPaused = false
        runTimerUpdate()
    }
    
    /// Stop the timer
    func stopTimer() {
        isRunning = false
        isTimerPaused = false
        removeAction(forKey: "timerUpdate")
    }
    
    /// Reset the timer to initial state
    func resetTimer() {
        stopTimer()
        currentTime = totalTime
        updateDisplay()
    }
    
    /// Set time remaining directly
    func setTimeRemaining(_ time: TimeInterval) {
        currentTime = max(0, time)
        updateDisplay()
        
        if currentTime <= 0 && isRunning {
            timeExpired()
        }
    }
    
    /// Get current time remaining
    var timeRemaining: TimeInterval {
        return currentTime
    }
    
    /// Check if timer is currently running
    var isTimerRunning: Bool {
        return isRunning && !isTimerPaused
    }
    
    /// Animate the timer appearing
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
    
    /// Flash animation for warnings
    func flashWarning() {
        let originalColor = progressRing.strokeColor
        let warningColor = SpriteKitColors.Text.warning
        
        let colorChange = SKAction.run {
            self.progressRing.strokeColor = warningColor
            self.timerLabel.fontColor = warningColor
        }
        let colorRestore = SKAction.run {
            self.progressRing.strokeColor = originalColor
            self.timerLabel.fontColor = originalColor
        }
        
        let flashSequence = SKAction.sequence([
            colorChange,
            SKAction.wait(forDuration: 0.2),
            colorRestore,
            SKAction.wait(forDuration: 0.2)
        ])
        
        let flashRepeat = SKAction.repeat(flashSequence, count: 3)
        run(flashRepeat)
    }
    
    /// Pulse animation for critical time
    func pulseCritical() {
        // Change to critical colors
        progressRing.strokeColor = SpriteKitColors.Text.error
        timerLabel.fontColor = SpriteKitColors.Text.error
        iconLabel.text = "⚠️"
        
        // Create pulsing animation
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.3)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        let pulseForever = SKAction.repeatForever(pulse)
        
        run(pulseForever, withKey: "criticalPulse")
    }
    
    /// Stop critical pulsing
    func stopCriticalPulse() {
        removeAction(forKey: "criticalPulse")
        setScale(1.0)
        
        // Restore normal colors
        progressRing.strokeColor = SpriteKitColors.Text.timer
        timerLabel.fontColor = SpriteKitColors.Text.timer
        iconLabel.text = "⏰"
    }
    
    // MARK: - Private Methods
    
    private func runTimerUpdate() {
        let updateAction = SKAction.run { [weak self] in
            self?.updateTimer()
        }
        let wait = SKAction.wait(forDuration: 0.1) // Update 10 times per second
        let sequence = SKAction.sequence([updateAction, wait])
        let repeatForever = SKAction.repeatForever(sequence)
        
        run(repeatForever, withKey: "timerUpdate")
    }
    
    private func updateTimer() {
        guard isRunning && !isTimerPaused else { return }
        
        currentTime -= 0.1
        
        if currentTime <= 0 {
            currentTime = 0
            timeExpired()
        }
        
        updateDisplay()
        checkWarningStates()
        
        // Call time changed callback
        onTimeChanged?(currentTime)
    }
    
    private func updateDisplay() {
        updateProgressRing()
        updateTimerLabel()
        updateAccessibilityValue()
    }
    
    private func updateProgressRing() {
        let progress = totalTime > 0 ? currentTime / totalTime : 0
        let endAngle = -CGFloat.pi / 2 + (CGFloat.pi * 2 * CGFloat(progress))
        
        let ringPath = UIBezierPath(
            arcCenter: .zero,
            radius: radius,
            startAngle: -CGFloat.pi / 2,
            endAngle: endAngle,
            clockwise: true
        )
        
        progressRing.path = ringPath.cgPath
    }
    
    private func updateTimerLabel() {
        let minutes = Int(currentTime) / 60
        let seconds = Int(currentTime) % 60
        
        if minutes > 0 {
            timerLabel.text = String(format: "%d:%02d", minutes, seconds)
        } else {
            timerLabel.text = String(format: "%d", seconds)
        }
    }
    
    private func updateAccessibilityValue() {
        let minutes = Int(currentTime) / 60
        let seconds = Int(currentTime) % 60
        
        if minutes > 0 {
            accessibilityValue = "\(minutes) minutes and \(seconds) seconds remaining"
        } else {
            accessibilityValue = "\(seconds) seconds remaining"
        }
    }
    
    private func checkWarningStates() {
        if currentTime <= criticalTime && currentTime > 0 {
            if action(forKey: "criticalPulse") == nil {
                pulseCritical()
            }
        } else if currentTime <= warningTime && currentTime > criticalTime {
            if action(forKey: "criticalPulse") != nil {
                stopCriticalPulse()
            }
            // Call warning callback
            onWarning?(currentTime)
        } else {
            if action(forKey: "criticalPulse") != nil {
                stopCriticalPulse()
            }
        }
    }
    
    private func timeExpired() {
        stopTimer()
        
        // Final visual state
        progressRing.strokeColor = SpriteKitColors.Text.error
        timerLabel.fontColor = SpriteKitColors.Text.error
        timerLabel.text = "0"
        iconLabel.text = "⏰"
        
        // Shake animation
        let shakeLeft = SKAction.moveBy(x: -5, y: 0, duration: 0.1)
        let shakeRight = SKAction.moveBy(x: 10, y: 0, duration: 0.1)
        let shakeCenter = SKAction.moveBy(x: -5, y: 0, duration: 0.1)
        let shakeSequence = SKAction.sequence([shakeLeft, shakeRight, shakeCenter])
        let shakeRepeat = SKAction.repeat(shakeSequence, count: 3)
        
        run(shakeRepeat)
        
        // Call expired callback
        onTimeExpired?()
    }
}

// MARK: - Factory Methods

extension TimerNode {
    /// Create a standard game timer
    static func createGameTimer(radius: CGFloat = 40) -> TimerNode {
        return TimerNode(radius: radius)
    }
    
    /// Create a large timer for emphasis
    static func createLargeTimer() -> TimerNode {
        return TimerNode(radius: 60)
    }
    
    /// Create a compact timer for minimal space
    static func createCompactTimer() -> TimerNode {
        return TimerNode(radius: 30)
    }
}
