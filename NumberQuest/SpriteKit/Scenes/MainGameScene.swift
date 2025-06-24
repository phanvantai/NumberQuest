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
            gameSession.pauseInternalTimer() // We'll create this method
        }
        
        updateUI()
        presentNextQuestion()
    }
    
    private func presentNextQuestion() {
        gameSession.generateNewQuestion()
        
        guard let question = gameSession.currentQuestion else {
            endGame()
            return
        }
        
        // Update question card with new question
        let questionText = "\(question.firstNumber) \(question.operation.symbol) \(question.secondNumber) = ?"
        questionCard?.setQuestion(questionText)
        
        // Create answer buttons
        createAnswerButtons(for: question)
        
        // Update UI with latest game session values
        updateUI()
        
        // Enable interaction after a brief delay to prevent accidental taps
        let enableDelay = SKAction.wait(forDuration: 0.5)
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
            
            // Animate button appearance
            button.alpha = 0
            button.setScale(0.8)
            let delay = SKAction.wait(forDuration: Double(index) * 0.1)
            let fadeIn = SKAction.fadeIn(withDuration: 0.2)
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.2)
            let appear = SKAction.group([fadeIn, scaleUp])
            
            button.run(SKAction.sequence([delay, appear]))
            
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
            
            // Animate score increase
            animateScoreIncrease()
            
        } else {
            showWrongAnswerFeedback()
            
            // Play error sound and haptic
            playSound(.incorrect, haptic: .error)
            
            // Show particle effect at question position
            playWrongAnswerEffect(at: questionCard?.position ?? CGPoint(x: frame.midX, y: frame.midY))
            
            // Reset streak visual feedback
            animateStreakReset()
        }
        
        // Update UI with new values from game session
        updateUI()
        
        // Wait for feedback to complete, then continue
        let feedbackDuration: TimeInterval = correct ? 1.2 : 1.8
        let delay = SKAction.wait(forDuration: feedbackDuration)
        let nextAction = SKAction.run { [weak self] in
            self?.proceedToNextQuestion()
        }
        
        run(SKAction.sequence([delay, nextAction]))
    }
    
    // The checkGameContinuation method has been replaced with proceedToNextQuestion for better logic flow
    
    private func endGame() {
        // Disable all interactions immediately
        disableAnswerButtons()
        
        // Stop the timer if running
        timerNode?.stopTimer()
        
        // Ensure game session is properly ended
        if gameSession.isGameActive {
            gameSession.endGame() // We'll need to make this method public
        }
        
        // Calculate performance metrics
        let finalScore = gameSession.score
        let totalQuestions = gameSession.questionsAnswered
        let accuracyPercent = totalQuestions > 0 ? (Double(gameSession.correctAnswers) / Double(totalQuestions)) * 100 : 0
        
        // Show celebration effects based on performance
        if accuracyPercent >= 80 {
            playCelebrationEffect(at: CGPoint(x: frame.midX, y: frame.midY))
            playSound(.levelComplete, haptic: .success)
        } else if accuracyPercent >= 60 {
            playSound(.levelComplete, haptic: .medium)
        } else {
            playSound(.levelComplete)
        }
        
        // Wait for effects to complete before transitioning
        let effectsDelay = SKAction.wait(forDuration: 2.0)
        let transitionAction = SKAction.run { [weak self] in
            self?.transitionToGameOver()
        }
        
        run(SKAction.sequence([effectsDelay, transitionAction]))
    }
    
    private func transitionToGameOver() {
        // Create and transition to game over scene
        let gameOverScene = GameOverScene(gameSession: gameSession)
        GameSceneManager.shared.presentScene(.gameOver(gameSession))
    }
    
    // MARK: - Feedback Effects
    
    private func showCorrectAnswerFeedback() {
        // Show success feedback on question card
        questionCard?.glowForCorrectAnswer()
        
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
    }
    
    private func proceedToNextQuestion() {
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
        
        // Continue with next question
        presentNextQuestion()
    }
}
