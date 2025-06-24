//
//  MainGameScene.swift
//  NumberQuest
//
//  Created by TaiPV on 24/6/25.
//

import SpriteKit
import SwiftUI

/// Main game scene for NumberQuest math questions
/// This is the core scene where players answer math questions
class MainGameScene: BaseGameScene {
    
    // MARK: - Properties
    
    /// Current game session
    var gameSession: GameSession
    
    /// UI Nodes
    private var questionCard: QuestionCardNode?
    private var answerButtons: [AnswerButtonNode] = []
    private var scoreDisplay: ScoreDisplayNode?
    private var streakDisplay: ScoreDisplayNode?
    private var starsDisplay: ScoreDisplayNode?
    private var timerNode: TimerNode?
    
    /// Layout positions
    private let questionY: CGFloat = 0.3
    private let answersY: CGFloat = 0.6
    private let scoreY: CGFloat = 0.15
    private let timerY: CGFloat = 0.1
    
    // MARK: - Initialization
    
    init(gameSession: GameSession) {
        self.gameSession = gameSession
        super.init(size: .zero)
        
        // Set up GameSession delegate
        self.gameSession.sceneDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Scene Setup
    
    override func setupBackground() {
        super.setupBackground()
        
        // Game-specific animated gradient background
        createGradientBackground(colors: [
            UIColor(red: 0.2, green: 0.7, blue: 1.0, alpha: 1.0), // Bright blue
            UIColor(red: 0.4, green: 0.9, blue: 0.6, alpha: 1.0), // Green
            UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0)  // Purple
        ], animated: true)
    }
    
    override func setupUI() {
        super.setupUI()
        
        setupScoreDisplay()
        setupTimerNode()
        setupQuestionCard()
        setupAnswerButtons()
        
        // Start the game if not already active
        if !gameSession.isGameActive {
            startNewGame()
        } else {
            updateUI()
        }
    }
    
    // MARK: - UI Setup Methods
    
    private func setupScoreDisplay() {
        // Create score display
        scoreDisplay = ScoreDisplayNode(type: .score, size: CGSize(width: 120, height: 70))
        scoreDisplay?.position = CGPoint(x: frame.midX - 120, y: frame.maxY - 120)
        scoreDisplay?.setValue(gameSession.score)
        
        // Create streak display
        streakDisplay = ScoreDisplayNode(type: .streak, size: CGSize(width: 120, height: 70))
        streakDisplay?.position = CGPoint(x: frame.midX, y: frame.maxY - 120)
        streakDisplay?.setValue(gameSession.streak)
        
        // Create stars display (using total stars from player progress)
        starsDisplay = ScoreDisplayNode(type: .stars, size: CGSize(width: 120, height: 70))
        starsDisplay?.position = CGPoint(x: frame.midX + 120, y: frame.maxY - 120)
        starsDisplay?.setValue(gameSession.playerProgress.totalStars)
        
        // Add displays to the scene
        if let scoreDisplay = scoreDisplay {
            addChild(scoreDisplay)
        }
        if let streakDisplay = streakDisplay {
            addChild(streakDisplay)
        }
        if let starsDisplay = starsDisplay {
            addChild(starsDisplay)
        }
    }
    
    private func setupTimerNode() {
        // Only create timer for quick play mode
        if gameSession.gameMode == .quickPlay {
            timerNode = TimerNode(radius: 40)
            timerNode?.position = CGPoint(x: frame.midX, y: frame.maxY - 80)
            
            if let timerNode = timerNode {
                addChild(timerNode)
                
                // Set up timer callbacks
                timerNode.onTimeExpired = { [weak self] in
                    // Timer finished callback - sync with game session
                    self?.gameSession.timeRemaining = 0
                    self?.endGame()
                }
                
                timerNode.onTimeChanged = { [weak self] timeRemaining in
                    // Update game session time as timer counts down
                    self?.gameSession.timeRemaining = Int(timeRemaining)
                }
                
                timerNode.onWarning = { [weak self] timeRemaining in
                    // Visual warning when time is low
                    self?.showTimerWarning(timeRemaining: timeRemaining)
                }
                
                // Start the timer with the game session's time
                timerNode.startTimer(duration: TimeInterval(gameSession.timeRemaining))
            }
        }
    }
    
    private func setupQuestionCard() {
        questionCard = QuestionCardNode(size: CGSize(width: 300, height: 120))
        questionCard?.position = position(x: 0.5, y: questionY)
        
        if let questionCard = questionCard {
            addChild(questionCard)
        }
    }
    
    private func setupAnswerButtons() {
        // We'll create these dynamically when a question is presented
        clearAnswerButtons()
    }
    
    // MARK: - Game Logic
    
    private func startNewGame() {
        // Start the game session but handle timer separately for SpriteKit
        gameSession.startGame(
            mode: gameSession.gameMode,
            level: gameSession.currentLevel
        )
        
        // If using quick play mode, let TimerNode handle the countdown instead of GameSession timer
        if gameSession.gameMode == .quickPlay {
            gameSession.pauseInternalTimer() // Use the new method
        }
        
        // Validate and sync data integrity
        gameSession.syncWithGameData()
        
        updateUI()
        presentNextQuestion()
    }
    
    private func presentNextQuestion() {
        gameSession.generateNewQuestion()
        
        guard let question = gameSession.currentQuestion else {
            endGame()
            return
        }
        
        // Update question card with new question using enhanced animation
        let questionText = "\(question.firstNumber) \(question.operation.symbol) \(question.secondNumber) = ?"
        questionCard?.setQuestion(questionText)
        questionCard?.animateInWithParticles(delay: 0.1)
        
        // Create answer buttons with enhanced animations
        createAnswerButtons(for: question)
        
        // Update UI with latest game session values
        updateUI()
        
        // Enable interaction after animation completes
        let enableDelay = SKAction.wait(forDuration: 1.0)
        let enableButtons = SKAction.run { [weak self] in
            self?.enableAnswerButtons()
        }
        run(SKAction.sequence([enableDelay, enableButtons]))
    }
    
    private func createAnswerButtons(for question: MathQuestion) {
        clearAnswerButtons()
        
        // Create all possible answers
        var allAnswers = question.wrongAnswers
        allAnswers.append(question.correctAnswer)
        allAnswers.shuffle()
        
        let buttonSize = CGSize(width: 120, height: 60)
        let spacing: CGFloat = 20
        let totalWidth = CGFloat(allAnswers.count) * buttonSize.width + CGFloat(allAnswers.count - 1) * spacing
        let startX = (size.width - totalWidth) / 2 + buttonSize.width / 2
        
        for (index, answer) in allAnswers.enumerated() {
            let isCorrect = answer == question.correctAnswer
            
            let button = NodeFactory.shared.createAnswerButton(
                answer: "\(answer)",
                size: buttonSize,
                isCorrect: isCorrect
            ) { [weak self] correct in
                self?.answerSelected(correct: correct, answer: answer)
            }
            
            let x = startX + CGFloat(index) * (buttonSize.width + spacing)
            button.position = CGPoint(x: x, y: position(x: 0, y: answersY).y)
            
            // Start disabled to prevent premature tapping
            button.isUserInteractionEnabled = false
            
            // Animate button appearance with enhanced effects
            button.alpha = 0
            button.setScale(0.8)
            let delay = SKAction.wait(forDuration: Double(index) * 0.1)
            let fadeIn = SKAction.fadeIn(withDuration: 0.2)
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.2)
            let appear = SKAction.group([fadeIn, scaleUp])
            
            // Add bounce effect after appear
            let bounce = SKAction.run {
                button.bounceWithTrail()
            }
            
            button.run(SKAction.sequence([delay, appear, SKAction.wait(forDuration: 0.1), bounce]))
            
            answerButtons.append(button)
            addChild(button)
        }
    }
    
    private func clearAnswerButtons() {
        answerButtons.forEach { $0.removeFromParent() }
        answerButtons.removeAll()
    }
    
    private func answerSelected(correct: Bool, answer: Int) {
        // Immediately disable all buttons to prevent multiple selections
        disableAnswerButtons()
        
        // Submit the answer to game session
        gameSession.submitAnswer(answer)
        
        // Show immediate visual feedback
        if correct {
            showCorrectAnswerFeedback()
            
            // Play success sound and haptic
            playSound(.correct, haptic: .success)
            
            // Show particle effect at question position
            playCorrectAnswerEffect(at: questionCard?.position ?? CGPoint(x: frame.midX, y: frame.midY))
            
            // Enhanced score increase with floating effects
            let scoreIncrease = gameSession.getPointsForAnswer()
            createFloatingScoreEffect(
                points: scoreIncrease, 
                startPosition: scoreDisplay?.position ?? CGPoint(x: frame.midX, y: frame.maxY - 120)
            )
            
            // Show streak celebration for significant streaks
            if gameSession.streak >= 3 {
                showStreakCelebration()
            }
            
        } else {
            // Enhanced wrong answer feedback
            enhancedWrongAnswerFeedback()
            
            // Show error feedback on question card
            questionCard?.shakeForWrongAnswer()
            
            // Play error sound and haptic
            playSound(.incorrect, haptic: .error)
            
            // Show particle effect at question position
            playWrongAnswerEffect(at: questionCard?.position ?? CGPoint(x: frame.midX, y: frame.midY))
            
            // Reset streak visual feedback
            animateStreakReset()
        }
        
        // Update UI with new values from game session
        updateUI()
        
        // Wait for feedback to complete, then continue with enhanced transition
        let feedbackDuration: TimeInterval = correct ? 1.2 : 1.8
        let delay = SKAction.wait(forDuration: feedbackDuration)
        let nextAction = SKAction.run { [weak self] in
            self?.checkGameContinuation()
        }
        
        run(SKAction.sequence([delay, nextAction]))
    }
    
    private func checkGameContinuation() {
        // Check if the game should continue based on game session state
        if !gameSession.isGameActive {
            endGame()
            return
        }
        
        // Check time limit for quick play
        if gameSession.gameMode == .quickPlay && gameSession.timeRemaining <= 0 {
            endGame()
            return
        }
        
        // Check question limit for campaign mode
        if let level = gameSession.currentLevel,
           gameSession.questionsAnswered >= level.maxQuestions {
            endGame()
            return
        }
        
        // Continue with enhanced question transition
        animateQuestionTransition()
    }
    
    private func proceedToNextQuestion() {
        // This method is now replaced by checkGameContinuation() and animateQuestionTransition()
        // for better separation of concerns and enhanced visual effects
        checkGameContinuation()
    }
    
    private func endGame() {
        gameSession.endGame()
        
        // Complete level if in campaign mode
        if gameSession.gameMode == .campaign {
            gameSession.completeLevel()
        } else {
            // Sync progress for quick play
            gameSession.syncWithGameData()
        }
        
        // Enhanced transition to game over scene
        GameSceneManager.shared.presentScene(
            .gameOver(gameSession),
            transitionType: .fade,
            showLoading: true
        )
    }
    
    // MARK: - Feedback Effects
    
    private func showCorrectAnswerFeedback() {
        // Show enhanced success feedback on question card
        questionCard?.glowForCorrectAnswerEnhanced()
        
        // Subtle zoom effect for positive feedback
        zoomCamera(to: 1.05, duration: 0.2)
        let restoreZoom = SKAction.wait(forDuration: 0.2)
        let restoreAction = SKAction.run { [weak self] in
            self?.zoomCamera(to: 1.0, duration: 0.3)
        }
        run(SKAction.sequence([restoreZoom, restoreAction]))
    }
    
    private func showWrongAnswerFeedback() {
        // Show error feedback on question card
        questionCard?.shakeForWrongAnswer()
        
        // Camera shake for wrong answer impact
        shakeCamera(intensity: 8.0, duration: 0.4)
        
        // Briefly desaturate the background for negative feedback
        backgroundAnimationNodes.forEach { node in
            if let spriteNode = node as? SKSpriteNode {
                let desaturate = SKAction.colorize(with: .gray, colorBlendFactor: 0.3, duration: 0.1)
                let restore = SKAction.colorize(with: spriteNode.color, colorBlendFactor: 0.0, duration: 0.4)
                let sequence = SKAction.sequence([desaturate, restore])
                spriteNode.run(sequence)
            }
        }
    }
    
    // MARK: - Timer Integration
    
    private func showTimerWarning(timeRemaining: TimeInterval) {
        // Flash the screen border red when time is running low
        let warningOverlay = SKShapeNode(rect: frame)
        warningOverlay.strokeColor = SpriteKitColors.Text.error
        warningOverlay.lineWidth = 8
        warningOverlay.fillColor = .clear
        warningOverlay.zPosition = 1000
        
        addChild(warningOverlay)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let flash = SKAction.sequence([fadeIn, fadeOut])
        let removeNode = SKAction.run { warningOverlay.removeFromParent() }
        
        warningOverlay.alpha = 0
        warningOverlay.run(SKAction.sequence([flash, removeNode]))
        
        // Play warning sound for critical time
        if timeRemaining <= 5 {
            playSound(.incorrect, haptic: .warning)
        }
    }
    
    // MARK: - Enhanced Answer Selection
    
    private func enableAnswerButtons() {
        answerButtons.forEach { $0.isUserInteractionEnabled = true }
    }
    
    private func disableAnswerButtons() {
        answerButtons.forEach { $0.isUserInteractionEnabled = false }
    }
    
    // MARK: - Game Session Integration
    
    // Note: Game session integration is handled through direct method calls
    // throughout the scene lifecycle (startGame, submitAnswer, endGame, etc.)
    
    // MARK: - Scene Lifecycle
    
    override func layoutForNewSize() {
        super.layoutForNewSize()
        
        // Reposition UI elements for new size
        scoreDisplay?.position = CGPoint(x: frame.midX - 120, y: frame.maxY - 120)
        streakDisplay?.position = CGPoint(x: frame.midX, y: frame.maxY - 120)
        starsDisplay?.position = CGPoint(x: frame.midX + 120, y: frame.maxY - 120)
        timerNode?.position = CGPoint(x: frame.midX, y: frame.maxY - 80)
        questionCard?.position = position(x: 0.5, y: questionY)
        
        // Recreate answer buttons with new layout
        if let question = gameSession.currentQuestion {
            createAnswerButtons(for: question)
        }
    }
    
    override func cleanup() {
        super.cleanup()
        clearAnswerButtons()
    }
    
    private func animateScoreIncrease() {
        // Create floating score increase text
        guard let scoreDisplay = scoreDisplay else { return }
        
        let scoreIncrease = gameSession.getPointsForAnswer()
        let floatingText = SKLabelNode()
        floatingText.text = "+\(scoreIncrease)"
        floatingText.fontName = "Baloo2-VariableFont_wght"
        floatingText.fontSize = 24
        floatingText.fontColor = SpriteKitColors.Text.success
        floatingText.position = scoreDisplay.position
        floatingText.zPosition = 1000
        
        addChild(floatingText)
        
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 1.0)
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.7)
        
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown])
        let animationGroup = SKAction.group([moveUp, fadeOut, scaleSequence])
        let removeNode = SKAction.run { floatingText.removeFromParent() }
        
        floatingText.run(SKAction.sequence([animationGroup, removeNode]))
    }
    
    private func animateStreakReset() {
        // Visual feedback when streak is broken
        guard let streakDisplay = streakDisplay else { return }
        
        if gameSession.streak == 0 {
            // Shake the streak display
            let shakeLeft = SKAction.moveBy(x: -5, y: 0, duration: 0.1)
            let shakeRight = SKAction.moveBy(x: 10, y: 0, duration: 0.1)
            let shakeCenter = SKAction.moveBy(x: -5, y: 0, duration: 0.1)
            let shakeSequence = SKAction.sequence([shakeLeft, shakeRight, shakeCenter])
            
            streakDisplay.run(shakeSequence)
        }
    }
    
    // MARK: - Enhanced Animation Effects for Step 2.4
    
    /// Enhanced celebration animation for high streaks
    private func showStreakCelebration() {
        guard gameSession.streak >= 3 else { return }
        
        // Create streak milestone celebration
        let streakText = SKLabelNode()
        streakText.text = "🔥 \(gameSession.streak) STREAK! 🔥"
        streakText.fontName = "Baloo2-VariableFont_wght"
        streakText.fontSize = 32
        streakText.fontColor = SpriteKitColors.Text.success
        streakText.position = CGPoint(x: frame.midX, y: frame.midY + 50)
        streakText.zPosition = 1000
        streakText.alpha = 0
        streakText.setScale(0.1)
        
        addChild(streakText)
        
        // Animate in with bounce
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let bounce = SKAction.sequence([scaleUp, scaleDown])
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let wait = SKAction.wait(forDuration: 1.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        
        let animationSequence = SKAction.sequence([
            SKAction.group([fadeIn, bounce]),
            wait,
            fadeOut,
            remove
        ])
        
        streakText.run(animationSequence)
        
        // Add particle burst for major streaks
        if gameSession.streak >= 5 {
            playCelebrationEffect(at: CGPoint(x: frame.midX, y: frame.midY))
        }
        
        // Play special streak sound
        playSound(.correct, haptic: .success)
    }
    
    /// Smooth question transition with enhanced effects
    private func animateQuestionTransition() {
        // Fade out current question and buttons
        let fadeOutDuration: TimeInterval = 0.2
        
        // Question card fade
        let questionFadeOut = SKAction.fadeAlpha(to: 0.3, duration: fadeOutDuration)
        let questionScale = SKAction.scale(to: 0.95, duration: fadeOutDuration)
        let questionAnimation = SKAction.group([questionFadeOut, questionScale])
        
        questionCard?.run(questionAnimation)
        
        // Answer buttons cascade out
        for (index, button) in answerButtons.enumerated() {
            let delay = SKAction.wait(forDuration: Double(index) * 0.05)
            let fadeOut = SKAction.fadeOut(withDuration: 0.15)
            let scaleDown = SKAction.scale(to: 0.8, duration: 0.15)
            let buttonAnimation = SKAction.sequence([
                delay,
                SKAction.group([fadeOut, scaleDown])
            ])
            button.run(buttonAnimation)
        }
        
        // Wait for fade out, then present new question
        let totalTransitionTime = fadeOutDuration + 0.3
        let waitAction = SKAction.wait(forDuration: totalTransitionTime)
        let presentAction = SKAction.run { [weak self] in
            self?.presentNextQuestion()
        }
        
        run(SKAction.sequence([waitAction, presentAction]))
    }
    
    /// Enhanced floating score animation with trail effect
    private func createFloatingScoreEffect(points: Int, startPosition: CGPoint) {
        let container = SKNode()
        container.position = startPosition
        container.zPosition = 1000
        addChild(container)
        
        // Main score text
        let scoreLabel = SKLabelNode()
        scoreLabel.text = "+\(points)"
        scoreLabel.fontName = "Baloo2-VariableFont_wght"
        scoreLabel.fontSize = 28
        scoreLabel.fontColor = SpriteKitColors.Text.success
        
        // Shadow text for depth
        let shadowLabel = SKLabelNode()
        shadowLabel.text = "+\(points)"
        shadowLabel.fontName = "Baloo2-VariableFont_wght"
        shadowLabel.fontSize = 28
        shadowLabel.fontColor = UIColor.black.withAlphaComponent(0.3)
        shadowLabel.position = CGPoint(x: 2, y: -2)
        shadowLabel.zPosition = -1
        
        container.addChild(shadowLabel)
        container.addChild(scoreLabel)
        
        // Create sparkle trail
        for i in 0..<5 {
            let sparkle = SKLabelNode()
            sparkle.text = "✨"
            sparkle.fontSize = 16
            sparkle.position = CGPoint(x: CGFloat.random(in: -20...20), y: CGFloat.random(in: -10...10))
            sparkle.alpha = 0
            sparkle.zPosition = 999
            
            container.addChild(sparkle)
            
            // Animate sparkles
            let delay = SKAction.wait(forDuration: Double(i) * 0.1)
            let sparkleIn = SKAction.fadeIn(withDuration: 0.2)
            let sparkleOut = SKAction.fadeOut(withDuration: 0.5)
            let sparkleMove = SKAction.moveBy(x: CGFloat.random(in: -30...30), y: CGFloat.random(in: 20...40), duration: 0.7)
            let sparkleSequence = SKAction.sequence([
                delay,
                SKAction.group([sparkleIn, sparkleMove]),
                sparkleOut
            ])
            
            sparkle.run(sparkleSequence)
        }
        
        // Main text animation
        let moveUp = SKAction.moveBy(x: 0, y: 80, duration: 1.2)
        let fadeOut = SKAction.fadeOut(withDuration: 1.2)
        let scaleUp = SKAction.scale(to: 1.3, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.9)
        
        let scaleAnimation = SKAction.sequence([scaleUp, scaleDown])
        let mainAnimation = SKAction.group([moveUp, fadeOut, scaleAnimation])
        let cleanup = SKAction.removeFromParent()
        
        container.run(SKAction.sequence([mainAnimation, cleanup]))
    }
    
    /// Enhanced wrong answer feedback with visual impact
    private func enhancedWrongAnswerFeedback() {
        // Enhanced camera shake with rotation
        let originalPosition = gameCamera?.position ?? CGPoint.zero
        let shakeIntensity: CGFloat = 12.0
        
        let shakeActions = [
            SKAction.move(by: CGVector(dx: shakeIntensity, dy: 0), duration: 0.04),
            SKAction.move(by: CGVector(dx: -shakeIntensity * 2, dy: shakeIntensity), duration: 0.04),
            SKAction.move(by: CGVector(dx: shakeIntensity, dy: -shakeIntensity * 2), duration: 0.04),
            SKAction.move(by: CGVector(dx: 0, dy: shakeIntensity), duration: 0.04),
            SKAction.move(to: originalPosition, duration: 0.08)
        ]
        
        gameCamera?.run(SKAction.sequence(shakeActions))
        
        // Red flash overlay
        let flashOverlay = SKShapeNode(rect: frame)
        flashOverlay.fillColor = UIColor.red.withAlphaComponent(0.3)
        flashOverlay.strokeColor = .clear
        flashOverlay.zPosition = 900
        flashOverlay.alpha = 0
        
        addChild(flashOverlay)
        
        let flashIn = SKAction.fadeIn(withDuration: 0.1)
        let flashOut = SKAction.fadeOut(withDuration: 0.3)
        let removeFlash = SKAction.removeFromParent()
        
        flashOverlay.run(SKAction.sequence([flashIn, flashOut, removeFlash]))
        
        // Momentary desaturation effect
        backgroundAnimationNodes.forEach { node in
            if let sprite = node as? SKSpriteNode {
                let desaturate = SKAction.colorize(with: .gray, colorBlendFactor: 0.5, duration: 0.1)
                let restore = SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.4)
                sprite.run(SKAction.sequence([desaturate, restore]))
            }
        }
    }
    
    // MARK: - UI Updates
    
    private func updateUI() {
        // Update all score displays with current values
        scoreDisplay?.setValue(gameSession.score, animated: true)
        streakDisplay?.setValue(gameSession.streak, animated: true)
        starsDisplay?.setValue(gameSession.playerProgress.totalStars, animated: true)
        
        // Update timer (if applicable)
        if gameSession.gameMode == .quickPlay {
            timerNode?.setTimeRemaining(TimeInterval(gameSession.timeRemaining))
        }
        
        // Update progress and sync
        gameSession.syncWithGameData()
    }
}

// MARK: - GameSessionDelegate Implementation

extension MainGameScene: GameSessionDelegate {
    func gameSessionDidUpdateScore(_ session: GameSession) {
        scoreDisplay?.setValue(session.score, animated: true)
    }
    
    func gameSessionDidUpdateStreak(_ session: GameSession) {
        streakDisplay?.setValue(session.streak, animated: true)
        
        // Show celebration for significant streaks
        if session.streak >= 3 && session.streak % 3 == 0 {
            showStreakCelebration()
        }
    }
    
    func gameSessionDidUpdateTime(_ session: GameSession) {
        if session.gameMode == .quickPlay {
            timerNode?.setTimeRemaining(TimeInterval(session.timeRemaining))
        }
    }
    
    func gameSessionDidCompleteQuestion(_ session: GameSession, correct: Bool) {
        // This is handled in the main answer selection flow
        // Could be used for additional feedback or analytics
    }
    
    func gameSessionDidEnd(_ session: GameSession) {
        // Prepare for transition to game over scene
        endGame()
    }
}
