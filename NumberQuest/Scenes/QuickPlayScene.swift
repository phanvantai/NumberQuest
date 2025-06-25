//
//  QuickPlayScene.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 25/6/25.
//

import SpriteKit
import GameplayKit

/// Fast-paced math challenge scene with adaptive difficulty
class QuickPlayScene: SKScene {
    
    // MARK: - Game Components
    
    private var mathGenerator: MathProblemGenerator!
    private var difficultyEngine: AdaptiveDifficultyEngine!
    private var currentProblem: MathProblem?
    
    // MARK: - UI Elements
    
    private var backgroundNode: SKSpriteNode!
    private var problemLabel: SKLabelNode!
    private var answerButtons: [SKSpriteNode] = []
    private var answerLabels: [SKLabelNode] = []
    
    // Performance feedback UI
    private var scoreLabel: SKLabelNode!
    private var streakLabel: SKLabelNode!
    private var accuracyLabel: SKLabelNode!
    private var timerBar: SKSpriteNode!
    private var timerBarFill: SKSpriteNode!
    
    // Control UI
    private var pauseButton: SKSpriteNode!
    private var homeButton: SKSpriteNode!
    
    // MARK: - Game State
    
    private var currentScore: Int = 0
    private var currentStreak: Int = 0
    private var totalProblems: Int = 0
    private var correctAnswers: Int = 0
    private var sessionStartTime: Date = Date()
    private var problemStartTime: Date = Date()
    private var isGameActive: Bool = false
    private var isGamePaused: Bool = false
    
    // MARK: - Real-time Analysis Properties
    
    // Response time tracking
    private var responseTimes: [TimeInterval] = []
    private var averageResponseTime: TimeInterval = 0.0
    private var bestResponseTime: TimeInterval = Double.infinity
    
    // Error pattern analysis
    private var errorPatterns: [ProblemType: Int] = [:]
    private var consecutiveErrors: Int = 0
    private var lastErrorTime: Date?
    
    // Performance trends
    private var recentAccuracyWindow: [Bool] = [] // Last 10 results
    private var performanceTrend: String = "Starting"
    
    // Enhanced UI for real-time feedback
    private var avgTimeLabel: SKLabelNode!
    private var bestTimeLabel: SKLabelNode!
    private var trendLabel: SKLabelNode!
    private var difficultyLabel: SKLabelNode!
    private var errorPatternLabel: SKLabelNode!
    
    // Performance visualization
    private var performanceGraph: SKNode!
    private var graphPoints: [SKShapeNode] = []
    
    // MARK: - Configuration
    
    private let buttonSize = CGSize(width: 120, height: 60)
    private let buttonSpacing: CGFloat = 20
    private let animationDuration: TimeInterval = 0.3
    private let problemTimeLimit: TimeInterval = 10.0
    
    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
        setupGameComponents()
        setupBackground()
        setupUI()
        setupLayout()
        startNewGame()
    }
    
    override func willMove(from view: SKView) {
        // Clean up timers and actions
        removeAllActions()
    }
    
    // MARK: - Setup Methods
    
    private func setupGameComponents() {
        mathGenerator = MathProblemGenerator(initialDifficulty: 3) // Start at medium difficulty
        difficultyEngine = AdaptiveDifficultyEngine()
        difficultyEngine.startNewSession()
    }
    
    private func setupBackground() {
        // Create clean, minimalist background
        backgroundColor = SKColor(red: 0.95, green: 0.95, blue: 0.98, alpha: 1.0) // Light blue-gray
        
        // Add subtle gradient effect
        backgroundNode = SKSpriteNode(color: SKColor(red: 0.9, green: 0.9, blue: 0.95, alpha: 1.0), size: size)
        backgroundNode.position = CGPoint(x: frame.midX, y: frame.midY)
        backgroundNode.zPosition = -10
        addChild(backgroundNode)
    }
    
    private func setupUI() {
        setupPerformanceUI()
        setupProblemUI()
        setupAnswerButtons()
        setupControlButtons()
        setupTimer()
    }
    
    private func setupPerformanceUI() {
        // Score display
        scoreLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
        scoreLabel.text = "Score: 0"
        scoreLabel.fontSize = 24
        scoreLabel.fontColor = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
        
        // Streak indicator
        streakLabel = SKLabelNode(fontNamed: "Avenir-Medium")
        streakLabel.text = "Streak: 0"
        streakLabel.fontSize = 18
        streakLabel.fontColor = SKColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 1.0)
        streakLabel.horizontalAlignmentMode = .left
        addChild(streakLabel)
        
        // Accuracy percentage
        accuracyLabel = SKLabelNode(fontNamed: "Avenir-Medium")
        accuracyLabel.text = "Accuracy: 100%"
        accuracyLabel.fontSize = 18
        accuracyLabel.fontColor = SKColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
        accuracyLabel.horizontalAlignmentMode = .right
        addChild(accuracyLabel)
        
        // Average response time
        avgTimeLabel = SKLabelNode(fontNamed: "Avenir-Medium")
        avgTimeLabel.text = "Avg Time: --"
        avgTimeLabel.fontSize = 18
        avgTimeLabel.fontColor = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        avgTimeLabel.horizontalAlignmentMode = .left
        addChild(avgTimeLabel)
        
        // Best response time
        bestTimeLabel = SKLabelNode(fontNamed: "Avenir-Medium")
        bestTimeLabel.text = "Best Time: --"
        bestTimeLabel.fontSize = 18
        bestTimeLabel.fontColor = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        bestTimeLabel.horizontalAlignmentMode = .left
        addChild(bestTimeLabel)
        
        // Performance trend
        trendLabel = SKLabelNode(fontNamed: "Avenir-Medium")
        trendLabel.text = "Trend: --"
        trendLabel.fontSize = 18
        trendLabel.fontColor = SKColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
        trendLabel.horizontalAlignmentMode = .right
        addChild(trendLabel)
        
        // Difficulty level
        difficultyLabel = SKLabelNode(fontNamed: "Avenir-Medium")
        difficultyLabel.text = "Difficulty: 3"
        difficultyLabel.fontSize = 18
        difficultyLabel.fontColor = SKColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0)
        difficultyLabel.horizontalAlignmentMode = .right
        addChild(difficultyLabel)
        
        // Error pattern display
        errorPatternLabel = SKLabelNode(fontNamed: "Avenir-Medium")
        errorPatternLabel.text = "Errors: --"
        errorPatternLabel.fontSize = 18
        errorPatternLabel.fontColor = SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0)
        errorPatternLabel.horizontalAlignmentMode = .right
        addChild(errorPatternLabel)
    }
    
    private func setupProblemUI() {
        // Math problem display
        problemLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
        problemLabel.text = "Loading..."
        problemLabel.fontSize = 48
        problemLabel.fontColor = SKColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        problemLabel.horizontalAlignmentMode = .center
        addChild(problemLabel)
    }
    
    private func setupAnswerButtons() {
        // Create 4 answer option buttons
        for i in 0..<4 {
            // Button background
            let button = SKSpriteNode(color: SKColor.white, size: buttonSize)
            button.name = "answerButton_\(i)"
            
            // Add shadow effect
            let shadow = SKSpriteNode(color: SKColor(white: 0.8, alpha: 0.3), size: buttonSize)
            shadow.position = CGPoint(x: 2, y: -2)
            shadow.zPosition = -1
            button.addChild(shadow)
            
            // Add border
            let border = SKShapeNode(rect: CGRect(origin: CGPoint(x: -buttonSize.width/2, y: -buttonSize.height/2), size: buttonSize))
            border.strokeColor = SKColor(red: 0.7, green: 0.7, blue: 0.7, alpha: 1.0)
            border.lineWidth = 2
            border.fillColor = SKColor.clear
            button.addChild(border)
            
            // Ensure button is above background
            button.zPosition = 10
            
            answerButtons.append(button)
            addChild(button)
            
            // Answer text label
            let label = SKLabelNode(fontNamed: "Avenir-Heavy")
            label.text = "0"
            label.fontSize = 32
            label.fontColor = SKColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
            label.horizontalAlignmentMode = .center
            label.verticalAlignmentMode = .center
            label.name = "answerLabel_\(i)"
            
            answerLabels.append(label)
            button.addChild(label)
        }
    }
    
    private func setupControlButtons() {
        // Pause button
        pauseButton = SKSpriteNode(color: SKColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0), size: CGSize(width: 50, height: 50))
        pauseButton.name = "pauseButton"
        pauseButton.zPosition = 10
        
        let pauseLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
        pauseLabel.text = "⏸"
        pauseLabel.fontSize = 24
        pauseLabel.fontColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        pauseLabel.horizontalAlignmentMode = .center
        pauseLabel.verticalAlignmentMode = .center
        pauseButton.addChild(pauseLabel)
        addChild(pauseButton)
        
        // Home button
        homeButton = SKSpriteNode(color: SKColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0), size: CGSize(width: 50, height: 50))
        homeButton.name = "homeButton"
        homeButton.zPosition = 10
        
        let homeLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
        homeLabel.text = "🏠"
        homeLabel.fontSize = 24
        homeLabel.fontColor = SKColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
        homeLabel.horizontalAlignmentMode = .center
        homeLabel.verticalAlignmentMode = .center
        homeButton.addChild(homeLabel)
        addChild(homeButton)
    }
    
    private func setupTimer() {
        // Timer bar background
        timerBar = SKSpriteNode(color: SKColor(white: 0.9, alpha: 1.0), size: CGSize(width: 300, height: 8))
        timerBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        addChild(timerBar)
        
        // Timer bar fill
        timerBarFill = SKSpriteNode(color: SKColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0), size: CGSize(width: 300, height: 8))
        timerBarFill.anchorPoint = CGPoint(x: 0, y: 0.5)
        timerBar.addChild(timerBarFill)
    }
    
    private func setupLayout() {
        let safeAreaTop = frame.maxY - 80
        let safeAreaBottom = frame.minY + 100
        
        // Performance UI arranged in a more organized layout
        // Left side - Primary metrics
        scoreLabel.position = CGPoint(x: frame.minX + 60, y: safeAreaTop - 30)
        streakLabel.position = CGPoint(x: frame.minX + 60, y: safeAreaTop - 55)
        
        // Left side - Timing metrics (smaller)
        avgTimeLabel.position = CGPoint(x: frame.minX + 60, y: safeAreaTop - 80)
        bestTimeLabel.position = CGPoint(x: frame.minX + 60, y: safeAreaTop - 100)
        
        // Right side - Analysis metrics
        accuracyLabel.position = CGPoint(x: frame.maxX - 60, y: safeAreaTop - 30)
        trendLabel.position = CGPoint(x: frame.maxX - 60, y: safeAreaTop - 55)
        difficultyLabel.position = CGPoint(x: frame.maxX - 60, y: safeAreaTop - 80)
        
        // Error feedback centered below main UI
        errorPatternLabel.position = CGPoint(x: frame.midX, y: safeAreaTop - 110)
        
        // Control buttons at top right (adjusted for new layout)
        pauseButton.position = CGPoint(x: frame.maxX - 140, y: safeAreaTop - 100)
        homeButton.position = CGPoint(x: frame.maxX - 80, y: safeAreaTop - 100)
        
        // Problem display in center-top area
        problemLabel.position = CGPoint(x: frame.midX, y: frame.midY + 100)
        
        // Timer below problem
        timerBar.position = CGPoint(x: frame.midX - 150, y: frame.midY + 40)
        
        // Answer buttons in 2x2 grid at bottom
        let gridStartX = frame.midX - buttonSize.width - buttonSpacing/2
        let gridStartY = frame.midY - 50
        
        for i in 0..<4 {
            let row = i / 2
            let col = i % 2
            let x = gridStartX + CGFloat(col) * (buttonSize.width + buttonSpacing)
            let y = gridStartY - CGFloat(row) * (buttonSize.height + buttonSpacing)
            answerButtons[i].position = CGPoint(x: x, y: y)
        }
    }
    
    // MARK: - Game Logic
    
    private func startNewGame() {
        isGameActive = true
        isGamePaused = false
        currentScore = 0
        currentStreak = 0
        totalProblems = 0
        correctAnswers = 0
        sessionStartTime = Date()
        
        // Reset real-time analysis data
        responseTimes = []
        averageResponseTime = 0.0
        bestResponseTime = Double.infinity
        errorPatterns = [:]
        consecutiveErrors = 0
        lastErrorTime = nil
        recentAccuracyWindow = []
        performanceTrend = "Starting"
        
        updatePerformanceUI()
        presentNextProblem()
    }
    
    private func presentNextProblem() {
        guard isGameActive && !isGamePaused else { return }
        
        currentProblem = mathGenerator.generateProblem()
        guard let problem = currentProblem else { return }
        
        totalProblems += 1
        problemStartTime = Date()
        
        // Update problem display
        problemLabel.text = problem.formattedProblem
        
        // Create answer options (correct + distractors)
        var allAnswers = problem.distractorAnswers
        allAnswers.append(problem.correctAnswer)
        allAnswers.shuffle()
        
        // Update answer buttons
        for (index, button) in answerButtons.enumerated() {
            if index < allAnswers.count {
                answerLabels[index].text = "\(allAnswers[index])"
                button.isHidden = false
                button.alpha = 1.0
                
                // Store the answer value in the button's userData
                button.userData = ["answer": allAnswers[index]]
            } else {
                button.isHidden = true
            }
        }
        
        // Start timer animation
        startProblemTimer()
        
        // Add entrance animation
        animateElementsIn()
    }
    
    private func startProblemTimer() {
        // Reset timer bar
        timerBarFill.size.width = 300
        timerBarFill.color = SKColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0)
        
        // Animate timer countdown
        let shrinkAction = SKAction.resize(toWidth: 0, duration: problemTimeLimit)
        let colorAction = SKAction.colorize(with: SKColor.red, colorBlendFactor: 1.0, duration: problemTimeLimit * 0.8)
        
        timerBarFill.run(SKAction.group([shrinkAction, colorAction])) { [weak self] in
            self?.handleTimeUp()
        }
    }
    
    private func handleTimeUp() {
        guard isGameActive && !isGamePaused else { return }
        
        // Time's up - treat as incorrect answer
        handleAnswer(isCorrect: false, selectedAnswer: nil)
    }
    
    private func handleAnswer(isCorrect: Bool, selectedAnswer: Int?) {
        guard let problem = currentProblem else { return }
        
        // Stop timer
        timerBarFill.removeAllActions()
        
        // Calculate response time
        let responseTime = Date().timeIntervalSince(problemStartTime)
        
        // Update game state
        if isCorrect {
            correctAnswers += 1
            currentStreak += 1
            currentScore += calculateScore(responseTime: responseTime, streak: currentStreak)
        } else {
            currentStreak = 0
        }
        
        // Record performance data
        let performanceData = PerformanceData(
            problemId: problem.id,
            correct: isCorrect,
            time: responseTime,
            hints: 0
        )
        
        difficultyEngine.recordPerformance(performanceData)
        
        // Get difficulty adjustment recommendation
        let adjustment = difficultyEngine.recommendDifficultyAdjustment(currentDifficulty: mathGenerator.difficulty)
        
        // Apply difficulty changes
        switch adjustment.recommendedChange {
        case .increase(let amount):
            mathGenerator.setDifficulty(mathGenerator.difficulty + amount)
        case .decrease(let amount):
            mathGenerator.setDifficulty(max(1, mathGenerator.difficulty - amount))
        case .adaptiveIncrease:
            mathGenerator.setDifficulty(mathGenerator.difficulty + 1)
        case .adaptiveDecrease:
            mathGenerator.setDifficulty(max(1, mathGenerator.difficulty - 1))
        case .maintain:
            break
        }
        
        // Update real-time analysis data
        updateResponseTimeData(responseTime: responseTime, isCorrect: isCorrect)
        updateErrorPatternData(isCorrect: isCorrect)
        updateRecentAccuracy(isCorrect: isCorrect)
        
        // Update UI
        updatePerformanceUI()
        
        // Show feedback
        showAnswerFeedback(isCorrect: isCorrect, correctAnswer: problem.correctAnswer)
        
        // Schedule next problem
        let delay = isCorrect ? 1.0 : 1.5 // Longer delay for incorrect answers
        run(SKAction.wait(forDuration: delay)) { [weak self] in
            self?.presentNextProblem()
        }
    }
    
    private func calculateScore(responseTime: TimeInterval, streak: Int) -> Int {
        let baseScore = 10
        let speedBonus = max(0, Int((5.0 - responseTime) * 2)) // Bonus for fast responses
        let streakMultiplier = min(5, 1 + streak / 3) // Up to 5x multiplier
        
        return (baseScore + speedBonus) * streakMultiplier
    }
    
    private func showAnswerFeedback(isCorrect: Bool, correctAnswer: Int) {
        // Highlight correct answer
        for (index, button) in answerButtons.enumerated() {
            if let answer = button.userData?["answer"] as? Int, answer == correctAnswer {
                // Highlight correct answer in green
                let highlightAction = SKAction.colorize(with: SKColor.green, colorBlendFactor: 0.5, duration: 0.2)
                let fadeAction = SKAction.colorize(with: SKColor.white, colorBlendFactor: 0.0, duration: 0.5)
                button.run(SKAction.sequence([highlightAction, fadeAction]))
                break
            }
        }
        
        // Show feedback text
        let feedbackLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
        feedbackLabel.text = isCorrect ? "Correct! ⭐" : "Try again! 💪"
        feedbackLabel.fontSize = 24
        feedbackLabel.fontColor = isCorrect ? SKColor.green : SKColor.red
        feedbackLabel.position = CGPoint(x: frame.midX, y: frame.midY - 100)
        feedbackLabel.alpha = 0
        addChild(feedbackLabel)
        
        // Animate feedback
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let wait = SKAction.wait(forDuration: 0.8)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        
        feedbackLabel.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
    }
    
    private func updatePerformanceUI() {
        scoreLabel.text = "Score: \(currentScore)"
        streakLabel.text = "Streak: \(currentStreak)"
        
        let accuracy = totalProblems > 0 ? (Double(correctAnswers) / Double(totalProblems)) * 100 : 100
        accuracyLabel.text = "Accuracy: \(Int(accuracy))%"
        
        // Update real-time analysis labels with enhanced feedback
        if responseTimes.isEmpty {
            avgTimeLabel.text = "Avg Time: --"
            bestTimeLabel.text = "Best: --"
        } else {
            avgTimeLabel.text = String(format: "Avg: %.1fs", averageResponseTime)
            bestTimeLabel.text = String(format: "Best: %.1fs", bestResponseTime == Double.infinity ? 0 : bestResponseTime)
        }
        
        trendLabel.text = performanceTrend
        difficultyLabel.text = "Level: \(mathGenerator.difficulty)"
        
        // Enhanced error pattern feedback
        let errorFeedback = analyzeErrorPatterns()
        if !errorFeedback.isEmpty {
            errorPatternLabel.text = errorFeedback
            errorPatternLabel.isHidden = false
        } else {
            errorPatternLabel.isHidden = true
        }
        
        // Update accuracy label color based on performance
        if accuracy >= 90 {
            accuracyLabel.fontColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0) // Green
        } else if accuracy >= 70 {
            accuracyLabel.fontColor = SKColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 1.0) // Orange
        } else {
            accuracyLabel.fontColor = SKColor(red: 0.8, green: 0.2, blue: 0.2, alpha: 1.0) // Red
        }
        
        // Update streak label color for motivation
        if currentStreak >= 5 {
            streakLabel.fontColor = SKColor(red: 1.0, green: 0.7, blue: 0.0, alpha: 1.0) // Gold
        } else if currentStreak >= 3 {
            streakLabel.fontColor = SKColor(red: 0.2, green: 0.8, blue: 0.2, alpha: 1.0) // Green
        } else {
            streakLabel.fontColor = SKColor(red: 0.8, green: 0.4, blue: 0.2, alpha: 1.0) // Orange
        }
        
        // Show performance insight
        showPerformanceInsight()
    }
    
    private func animateElementsIn() {
        // Scale animation for problem label
        problemLabel.setScale(0.5)
        problemLabel.alpha = 0
        let scaleUp = SKAction.scale(to: 1.0, duration: animationDuration)
        let fadeIn = SKAction.fadeIn(withDuration: animationDuration)
        problemLabel.run(SKAction.group([scaleUp, fadeIn]))
        
        // Slide in animation for answer buttons
        for (index, button) in answerButtons.enumerated() {
            button.position.y -= 50
            button.alpha = 0
            
            let moveUp = SKAction.moveBy(x: 0, y: 50, duration: animationDuration)
            let fadeIn = SKAction.fadeIn(withDuration: animationDuration)
            let delay = SKAction.wait(forDuration: Double(index) * 0.1)
            
            button.run(SKAction.sequence([delay, SKAction.group([moveUp, fadeIn])]))
        }
    }
    
    // MARK: - Real-time Analysis Methods
    
    private func updateResponseTimeData(responseTime: TimeInterval, isCorrect: Bool) {
        // Only track response times for correct answers to avoid skewing data
        if isCorrect {
            responseTimes.append(responseTime)
            
            // Keep only last 20 response times for rolling average
            if responseTimes.count > 20 {
                responseTimes.removeFirst()
            }
            
            // Update average
            averageResponseTime = responseTimes.reduce(0, +) / Double(responseTimes.count)
            
            // Update best time
            bestResponseTime = min(bestResponseTime, responseTime)
        }
    }
    
    private func updateErrorPatternData(isCorrect: Bool) {
        if !isCorrect {
            consecutiveErrors += 1
            lastErrorTime = Date()
            
            // Track error by problem type (would need problem type in PerformanceData)
            // For now, just track total errors
            if let currentProblem = currentProblem {
                let problemType = determineProblemType(from: currentProblem)
                errorPatterns[problemType, default: 0] += 1
            }
        } else {
            consecutiveErrors = 0
        }
    }
    
    private func updateRecentAccuracy(isCorrect: Bool) {
        recentAccuracyWindow.append(isCorrect)
        
        // Keep only last 10 results
        if recentAccuracyWindow.count > 10 {
            recentAccuracyWindow.removeFirst()
        }
        
        // Analyze performance trend
        updatePerformanceTrend()
    }
    
    private func updatePerformanceTrend() {
        guard recentAccuracyWindow.count >= 6 else {
            performanceTrend = "Starting"
            return
        }
        
        let firstHalf = Array(recentAccuracyWindow.prefix(recentAccuracyWindow.count / 2))
        let secondHalf = Array(recentAccuracyWindow.suffix(recentAccuracyWindow.count / 2))
        
        let firstAccuracy = Double(firstHalf.filter { $0 }.count) / Double(firstHalf.count)
        let secondAccuracy = Double(secondHalf.filter { $0 }.count) / Double(secondHalf.count)
        
        let improvement = secondAccuracy - firstAccuracy
        
        if improvement > 0.2 {
            performanceTrend = "Improving! 📈"
        } else if improvement < -0.2 {
            performanceTrend = "Need Focus 📉"
        } else if abs(improvement) <= 0.1 {
            performanceTrend = "Steady 📊"
        } else {
            performanceTrend = "Variable 🌊"
        }
    }
    
    private func determineProblemType(from problem: MathProblem) -> ProblemType {
        // Simple heuristic based on the problem text
        let problemText = problem.formattedProblem.lowercased()
        
        if problemText.contains("+") {
            return .addition
        } else if problemText.contains("-") {
            return .subtraction
        } else if problemText.contains("×") || problemText.contains("*") {
            return .multiplication
        } else {
            return .addition // Default fallback to addition
        }
    }
    
    private func analyzeErrorPatterns() -> String {
        guard !errorPatterns.isEmpty else { return "" }
        
        let sortedErrors = errorPatterns.sorted { $0.value > $1.value }
        let mostCommonError = sortedErrors.first!
        
        if mostCommonError.value >= 3 {
            switch mostCommonError.key {
            case .addition:
                return "Practice addition"
            case .subtraction:
                return "Practice subtraction"
            case .multiplication:
                return "Practice multiplication"
            }
        }
        
        if consecutiveErrors >= 3 {
            return "Take a break?"
        }
        
        return ""
    }
    
    private func getPerformanceInsight() -> String {
        // Provide helpful insights based on performance data
        if totalProblems < 3 {
            return "Getting started..."
        }
        
        let accuracy = Double(correctAnswers) / Double(totalProblems)
        
        if accuracy >= 0.9 && averageResponseTime <= 3.0 {
            return "Excellent! 🌟"
        } else if accuracy >= 0.8 && averageResponseTime <= 4.0 {
            return "Great work! 👍"
        } else if accuracy >= 0.7 {
            return "Good progress! 👌"
        } else if accuracy >= 0.5 {
            return "Keep practicing! 💪"
        } else {
            return "Slow down, think carefully 🤔"
        }
    }
    
    private func showPerformanceInsight() {
        // Show periodic performance insights (every 5 problems)
        if totalProblems > 0 && totalProblems % 5 == 0 {
            let insight = getPerformanceInsight()
            
            // Remove any existing insight label
            childNode(withName: "performanceInsight")?.removeFromParent()
            
            // Create insight label
            let insightLabel = SKLabelNode(fontNamed: "Avenir-Medium")
            insightLabel.text = insight
            insightLabel.name = "performanceInsight"
            insightLabel.fontSize = 20
            insightLabel.fontColor = SKColor(red: 0.4, green: 0.2, blue: 0.8, alpha: 1.0)
            insightLabel.horizontalAlignmentMode = .center
            insightLabel.position = CGPoint(x: frame.midX, y: frame.midY - 150)
            insightLabel.alpha = 0
            addChild(insightLabel)
            
            // Animate insight
            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            let wait = SKAction.wait(forDuration: 2.0)
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            
            insightLabel.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
        }
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        print("Touch detected at: \(location)")
        print("Scene frame: \(frame)")
        print("Answer buttons positions:")
        for (index, button) in answerButtons.enumerated() {
            print("  Button \(index): \(button.position), hidden: \(button.isHidden)")
        }
        
        // Use the location directly instead of relying on node detection
        handleTouchAtLocation(location)
    }
    
    private func handleTouchAtLocation(_ location: CGPoint) {
        guard isGameActive else { 
            print("Game not active")
            return 
        }
        
        // Always allow control button touches (even when paused)
        let pauseFrame = CGRect(
            x: pauseButton.position.x - 25,
            y: pauseButton.position.y - 25,
            width: 50,
            height: 50
        )
        if pauseFrame.contains(location) {
            print("Hit pause button")
            handlePauseButton()
            return
        }
        
        let homeFrame = CGRect(
            x: homeButton.position.x - 25,
            y: homeButton.position.y - 25,
            width: 50,
            height: 50
        )
        if homeFrame.contains(location) {
            print("Hit home button")
            handleHomeButton()
            return
        }
        
        // Only check answer buttons if game is not paused
        guard !isGamePaused else {
            print("Game is paused - only control buttons work")
            return
        }
        
        // Check if touch hits any answer button
        for (index, button) in answerButtons.enumerated() {
            let buttonFrame = CGRect(
                x: button.position.x - buttonSize.width/2,
                y: button.position.y - buttonSize.height/2,
                width: buttonSize.width,
                height: buttonSize.height
            )
            
            print("Checking button \(index) frame: \(buttonFrame)")
            
            if buttonFrame.contains(location) && !button.isHidden {
                print("Hit answer button \(index)")
                handleAnswerButtonTouch(node: button)
                return
            }
        }
        
        print("No interactive element found at touch location")
    }
    
    private func handleTouch(on node: SKNode) {
        guard isGameActive && !isGamePaused else { 
            print("Game not active or paused")
            return 
        }
        
        // Get touch location
        let location = node.parent?.convert(node.position, to: self) ?? node.position
        print("Checking touch at converted location: \(location)")
        
        // Check if touch hits any answer button directly
        for (index, button) in answerButtons.enumerated() {
            let buttonFrame = CGRect(
                x: button.position.x - buttonSize.width/2,
                y: button.position.y - buttonSize.height/2,
                width: buttonSize.width,
                height: buttonSize.height
            )
            
            if buttonFrame.contains(location) && !button.isHidden {
                print("Hit answer button \(index)")
                handleAnswerButtonTouch(node: button)
                return
            }
        }
        
        // Check control buttons
        let pauseFrame = CGRect(
            x: pauseButton.position.x - 25,
            y: pauseButton.position.y - 25,
            width: 50,
            height: 50
        )
        if pauseFrame.contains(location) {
            print("Hit pause button")
            handlePauseButton()
            return
        }
        
        let homeFrame = CGRect(
            x: homeButton.position.x - 25,
            y: homeButton.position.y - 25,
            width: 50,
            height: 50
        )
        if homeFrame.contains(location) {
            print("Hit home button")
            handleHomeButton()
            return
        }
        
        // Check the touched node and its parent for button names as fallback
        var nodeToCheck: SKNode? = node
        
        while nodeToCheck != nil {
            if let nodeName = nodeToCheck?.name {
                print("Checking node with name: \(nodeName)")
                if nodeName.hasPrefix("answerButton_") {
                    handleAnswerButtonTouch(node: nodeToCheck!)
                    return
                } else if nodeName == "pauseButton" {
                    handlePauseButton()
                    return
                } else if nodeName == "homeButton" {
                    handleHomeButton()
                    return
                }
            }
            nodeToCheck = nodeToCheck?.parent
        }
        
        print("No interactive element found at touch location")
    }
    
    private func handleAnswerButtonTouch(node: SKNode) {
        guard let button = node as? SKSpriteNode,
              let answer = button.userData?["answer"] as? Int,
              let problem = currentProblem else { return }
        
        // Visual feedback for button press
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        button.run(SKAction.sequence([scaleDown, scaleUp]))
        
        // Check if answer is correct
        let isCorrect = (answer == problem.correctAnswer)
        handleAnswer(isCorrect: isCorrect, selectedAnswer: answer)
    }
    
    private func handlePauseButton() {
        isGamePaused.toggle()
        
        print("Game paused state: \(isGamePaused)")
        
        if isGamePaused {
            // Pause game
            scene?.isPaused = true
            print("Game paused - timer and animations stopped")
        } else {
            // Resume game
            scene?.isPaused = false
            print("Game resumed - timer and animations resumed")
        }
    }
    
    private func handleHomeButton() {
        // Return to main menu (would trigger scene transition)
        // This would be handled by the GameViewController or SceneManager
        print("Returning to main menu...")
    }
}
