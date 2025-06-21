//
//  GameScene.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 21/6/25.
//

import SpriteKit
import SwiftUI

/// Main gameplay scene for NumberQuest
/// Handles the core math game experience with questions, answers, and scoring
class GameScene: BaseScene {
    
    // MARK: - Properties
    
    /// Current game session data
    var gameSession: GameSession?
    
    /// Game mode (campaign or quick play)
    var gameMode: GameMode = .campaign
    
    /// Current level being played (for campaign mode)
    var currentLevel: GameLevel?
    
    /// Question generator for creating math problems
    private var questionGenerator = QuestionGenerator()
    
    /// Game data reference for progress tracking
    var gameDataRef: GameData {
        return GameData.shared
    }
    
    /// Camera node for managing viewport
    private var gameCamera: SKCameraNode!
    
    /// Main game container for all UI elements
    private var gameContainer: SKNode!
    
    /// Background container for animated elements
    private var backgroundContainer: SKNode!
    
    /// UI layer container
    private var uiContainer: SKNode!
    
    /// Question display area container
    private var questionContainer: SKNode!
    
    /// Answer buttons container
    private var answersContainer: SKNode!
    
    /// Score and progress display container
    private var headerContainer: SKNode!
    
    /// Game state
    private var isGameActive = false
    private var isPaused = false
    
    // UI Components
    private var questionCard: QuestionCardNode?
    private var answerButtons: [AnswerButtonNode] = []
    private var scoreDisplay: ScoreDisplayNode?
    private var timerDisplay: TimerNode?
    
    // MARK: - Scene Lifecycle
    
    override func setupScene() {
        super.setupScene()
        
        // Setup camera
        setupCamera()
        
        // Initialize game session if not provided
        if gameSession == nil {
            gameSession = GameSession()
        }
    }
    
    override func setupBackground() {
        // Create enhanced animated background
        createGameBackground()
    }
    
    override func setupLayout() {
        super.setupLayout()
        
        // Create main containers
        createContainers()
        
        // Setup responsive layout zones
        setupLayoutZones()
    }
    
    override func setupContent() {
        super.setupContent()
        
        // Setup UI elements
        setupHeader()
        setupQuestionArea()
        setupAnswersArea()
        
        // Setup initial game state
        initializeGame()
    }
    
    override func updateLayout() {
        super.updateLayout()
        
        // Update camera bounds
        updateCamera()
        
        // Reposition all containers
        repositionContainers()
        
        // Update UI layout
        updateUILayout()
    }
    
    // MARK: - Camera Setup
    
    /// Setup camera for consistent viewport management
    private func setupCamera() {
        gameCamera = SKCameraNode()
        gameCamera.name = "gameCamera"
        
        // Position camera at scene center
        gameCamera.position = CGPoint(x: 0, y: 0)
        
        // Add camera to scene and set as active camera
        addChild(gameCamera)
        camera = gameCamera
        
        print("🎥 Game camera initialized")
    }
    
    /// Update camera bounds and position
    private func updateCamera() {
        guard let camera = gameCamera else { return }
        
        // Ensure camera stays centered
        camera.position = CGPoint(x: 0, y: 0)
        
        // Set camera bounds to prevent overshooting
        let inset: CGFloat = 50
        let bounds = CGRect(
            x: -size.width/2 + inset,
            y: -size.height/2 + inset,
            width: size.width - (inset * 2),
            height: size.height - (inset * 2)
        )
        
        // Create camera constraint (if needed for advanced camera movement)
        // This is ready for future enhancements like screen shake effects
    }
    
    // MARK: - Container Setup
    
    /// Create main containers for organizing scene elements
    private func createContainers() {
        // Main game container
        gameContainer = SKNode()
        gameContainer.name = "gameContainer"
        gameContainer.zPosition = 0
        addChild(gameContainer)
        
        // Background container for animated elements
        backgroundContainer = SKNode()
        backgroundContainer.name = "backgroundContainer"
        backgroundContainer.zPosition = -50
        gameContainer.addChild(backgroundContainer)
        
        // UI container for all interactive elements
        uiContainer = SKNode()
        uiContainer.name = "uiContainer"
        uiContainer.zPosition = 10
        gameContainer.addChild(uiContainer)
        
        // Header container for score, level info, etc.
        headerContainer = SKNode()
        headerContainer.name = "headerContainer"
        headerContainer.zPosition = 20
        uiContainer.addChild(headerContainer)
        
        // Question container for displaying math problems
        questionContainer = SKNode()
        questionContainer.name = "questionContainer"
        questionContainer.zPosition = 15
        uiContainer.addChild(questionContainer)
        
        // Answers container for answer buttons
        answersContainer = SKNode()
        answersContainer.name = "answersContainer"
        answersContainer.zPosition = 15
        uiContainer.addChild(answersContainer)
        
        print("📦 Game containers created")
    }
    
    /// Setup responsive layout zones using coordinate system
    private func setupLayoutZones() {
        // Position main containers using coordinate system
        positionContainer(headerContainer, zone: .header)
        positionContainer(questionContainer, zone: .questionArea)
        positionContainer(answersContainer, zone: .answersArea)
    }
    
    /// Position container in specific layout zone
    private func positionContainer(_ container: SKNode, zone: LayoutZone) {
        switch zone {
        case .header:
            // Header at top of safe area
            container.position = coordinateSystem.absolutePosition(relativeX: 0.5, relativeY: 0.9)
            
        case .questionArea:
            // Question area in upper middle
            container.position = coordinateSystem.absolutePosition(relativeX: 0.5, relativeY: 0.65)
            
        case .answersArea:
            // Answers area in lower middle
            container.position = coordinateSystem.absolutePosition(relativeX: 0.5, relativeY: 0.3)
        }
    }
    
    /// Reposition containers when screen size changes
    private func repositionContainers() {
        setupLayoutZones()
    }
    
    // MARK: - Background Creation
    
    /// Create animated game background with particles and effects
    private func createGameBackground() {
        // Remove existing background
        backgroundContainer.removeAllChildren()
        
        // Create gradient layers with different colors based on level/difficulty
        let backgroundColors = getBackgroundColors()
        
        for (index, colorInfo) in backgroundColors.enumerated() {
            let gradientLayer = SKSpriteNode(color: colorInfo.color, size: CGSize(
                width: size.width * colorInfo.scale,
                height: size.height * colorInfo.scale
            ))
            gradientLayer.alpha = colorInfo.alpha
            gradientLayer.position = CGPoint(x: 0, y: 0)
            gradientLayer.zPosition = CGFloat(-40 + index)
            
            // Add gentle rotation animation
            let rotationDuration = 45.0 + Double(index * 15)
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: rotationDuration)
            gradientLayer.run(SKAction.repeatForever(rotate))
            
            backgroundContainer.addChild(gradientLayer)
        }
        
        // Add floating geometric shapes
        addFloatingElements()
        
        // Add subtle particle effects
        addBackgroundParticles()
        
        print("🎨 Game background created")
    }
    
    /// Get background colors based on current level or difficulty
    private func getBackgroundColors() -> [(color: UIColor, alpha: CGFloat, scale: CGFloat)] {
        // Different color schemes based on level theme
        if let level = currentLevel {
            switch level.id {
            case 1: // Sunny Meadows
                return [
                    (.nqGreen, 0.8, 1.0),
                    (.nqYellow, 0.6, 1.1),
                    (.nqOrange, 0.4, 1.2)
                ]
            case 2: // Forest Path
                return [
                    (.nqGreen, 0.9, 1.0),
                    (.nqBlue, 0.6, 1.1),
                    (.nqTeal, 0.4, 1.2)
                ]
            case 3: // Mountain Peak
                return [
                    (.nqBlue, 0.8, 1.0),
                    (.nqPurple, 0.6, 1.1),
                    (.nqIndigo, 0.4, 1.2)
                ]
            case 4: // Magical Castle
                return [
                    (.nqPurple, 0.8, 1.0),
                    (.nqPink, 0.6, 1.1),
                    (.nqMagenta, 0.4, 1.2)
                ]
            case 5: // Crystal Cave
                return [
                    (.nqTeal, 0.8, 1.0),
                    (.nqCyan, 0.6, 1.1),
                    (.nqBlue, 0.4, 1.2)
                ]
            case 6: // Dragon's Lair
                return [
                    (.nqRed, 0.8, 1.0),
                    (.nqOrange, 0.6, 1.1),
                    (.nqYellow, 0.4, 1.2)
                ]
            default:
                return getDefaultBackgroundColors()
            }
        } else {
            return getDefaultBackgroundColors()
        }
    }
    
    /// Default background colors for quick play mode
    private func getDefaultBackgroundColors() -> [(color: UIColor, alpha: CGFloat, scale: CGFloat)] {
        return [
            (.nqBlue, 0.8, 1.0),
            (.nqPurple, 0.6, 1.1),
            (.nqPink, 0.4, 1.2),
            (.nqCoral, 0.3, 1.3)
        ]
    }
    
    /// Add floating geometric elements to background
    private func addFloatingElements() {
        let elementCount = coordinateSystem.particleCount(8)
        let bounds = CGRect(
            x: -size.width/2,
            y: -size.height/2,
            width: size.width,
            height: size.height
        )
        
        for i in 0..<elementCount {
            let element = nodeFactory.createFloatingGeometry(
                type: .random,
                size: CGSize(width: 20 + CGFloat(i * 5), height: 20 + CGFloat(i * 5)),
                color: UIColor.white.withAlphaComponent(0.1)
            )
            
            // Random position within bounds
            element.position = CGPoint(
                x: CGFloat.random(in: bounds.minX...bounds.maxX),
                y: CGFloat.random(in: bounds.minY...bounds.maxY)
            )
            
            // Add floating animation
            let duration = 8.0 + Double.random(in: -2...2)
            let moveBy = CGPoint(x: CGFloat.random(in: -50...50), y: CGFloat.random(in: -30...30))
            let move = SKAction.moveBy(x: moveBy.x, y: moveBy.y, duration: duration)
            let reverse = move.reversed()
            let float = SKAction.sequence([move, reverse])
            element.run(SKAction.repeatForever(float))
            
            backgroundContainer.addChild(element)
        }
    }
    
    /// Add subtle particle effects to background
    private func addBackgroundParticles() {
        // Add gentle floating particles using particle system
        if let particles = ParticleEffects.createBackgroundParticles() {
            particles.position = CGPoint(x: 0, y: size.height/2)
            particles.zPosition = -30
            backgroundContainer.addChild(particles)
        }
    }
    
    // MARK: - Header Setup
    
    /// Setup header with score, level info, and controls
    private func setupHeader() {
        headerContainer.removeAllChildren()
        
        // Create score display
        let scoreSize = CGSize(
            width: coordinateSystem.scaledValue(200),
            height: coordinateSystem.scaledValue(60)
        )
        scoreDisplay = ScoreDisplayNode(size: scoreSize, coordinateSystem: coordinateSystem)
        scoreDisplay!.position = CGPoint(x: -coordinateSystem.scaledValue(90), y: 0)
        headerContainer.addChild(scoreDisplay!)
        
        // Create timer display
        let timerRadius = coordinateSystem.scaledValue(25)
        timerDisplay = TimerNode(radius: timerRadius, coordinateSystem: coordinateSystem)
        timerDisplay!.position = CGPoint(x: coordinateSystem.scaledValue(90), y: 0)
        
        // Set up timer callbacks
        timerDisplay?.onTimeUpdate = { [weak self] remainingTime in
            // Handle time updates if needed
        }
        
        timerDisplay?.onTimeExpired = { [weak self] in
            self?.handleTimeExpired()
        }
        
        headerContainer.addChild(timerDisplay!)
        
        print("📊 Header setup completed with ScoreDisplay and Timer")
    }
    
    /// Update header UI layout
    private func updateHeaderLayout() {
        // Update positions of score display and timer if needed
        scoreDisplay?.position = CGPoint(x: -coordinateSystem.scaledValue(90), y: 0)
        timerDisplay?.position = CGPoint(x: coordinateSystem.scaledValue(90), y: 0)
    }
    
    // MARK: - Question Area Setup
    
    /// Setup question display area
    private func setupQuestionArea() {
        questionContainer.removeAllChildren()
        
        // Create question card
        let cardSize = CGSize(
            width: coordinateSystem.scaledValue(350),
            height: coordinateSystem.scaledValue(120)
        )
        questionCard = QuestionCardNode(size: cardSize, coordinateSystem: coordinateSystem)
        questionContainer.addChild(questionCard!)
        
        print("❓ Question area setup completed with QuestionCardNode")
    }
    
    // MARK: - Answers Area Setup
    
    /// Setup answer buttons area
    private func setupAnswersArea() {
        answersContainer.removeAllChildren()
        answerButtons.removeAll()
        
        // Create answer buttons
        let buttonCount = 4
        let buttonSize = CGSize(
            width: coordinateSystem.scaledValue(140),
            height: coordinateSystem.scaledValue(50)
        )
        
        for i in 0..<buttonCount {
            let button = AnswerButtonNode(
                size: buttonSize,
                coordinateSystem: coordinateSystem
            ) { [weak self] answerValue in
                self?.handleAnswerSelected(answerValue)
            }
            
            button.name = "answerButton_\(i)"
            
            // Position buttons in a 2x2 grid
            let col = i % 2
            let row = i / 2
            let spacing = coordinateSystem.scaledValue(20)
            
            button.position = CGPoint(
                x: (CGFloat(col) - 0.5) * (buttonSize.width + spacing),
                y: (0.5 - CGFloat(row)) * (buttonSize.height + spacing)
            )
            
            answerButtons.append(button)
            answersContainer.addChild(button)
        }
        
        print("🎯 Answers area setup completed with \(buttonCount) AnswerButtonNodes")
    }
    
    // MARK: - Game Initialization
    
    /// Initialize the game session
    private func initializeGame() {
        isGameActive = false
        isPaused = false
        
        // Setup game session based on mode
        if gameSession == nil {
            gameSession = GameSession()
        }
        
        guard let session = gameSession else { return }
        
        // Load player progress
        session.loadProgress()
        
        // Configure session based on game mode and level
        configureGameSession(session)
        
        print("🎮 Game initialized - Mode: \(gameMode)")
        
        // Start the game after a brief delay
        let startDelay = SKAction.wait(forDuration: 1.0)
        let startGame = SKAction.run { [weak self] in
            self?.startGame()
        }
        run(SKAction.sequence([startDelay, startGame]))
    }
    
    /// Configure game session based on mode and level
    private func configureGameSession(_ session: GameSession) {
        // Reset session state
        session.score = 0
        session.streak = 0
        session.questionsAnswered = 0
        session.correctAnswers = 0
        session.gameMode = gameMode
        session.currentLevel = currentLevel
        
        // Set session parameters based on mode
        if gameMode == .campaign, let level = currentLevel {
            // Campaign mode: use level settings
            session.maxQuestions = level.maxQuestions
            session.timeRemaining = level.maxQuestions * 45 // 45 seconds per question
            
            print("📚 Campaign Level: \(level.name)")
            print("📊 Questions: \(level.maxQuestions), Operations: \(level.allowedOperations.map(\.rawValue))")
            
        } else {
            // Quick play mode: adaptive settings
            session.maxQuestions = 15
            session.timeRemaining = 300 // 5 minutes
            
            print("⚡ Quick Play Mode")
        }
        
        // Initialize displays with session data
        updateDisplaysWithSession(session)
    }
    
    /// Update all displays with current session data
    private func updateDisplaysWithSession(_ session: GameSession) {
        scoreDisplay?.updateScore(session.score, animated: false)
        scoreDisplay?.updateStreak(session.streak, animated: false)
        
        let progress = Float(session.questionsAnswered) / Float(session.maxQuestions)
        scoreDisplay?.updateProgress(progress, animated: false)
    }
    
    /// Start the actual game
    private func startGame() {
        isGameActive = true
        
        // Show entrance animations for all UI elements
        animateGameStart()
        
        // Start timer and GameSession
        if let session = gameSession {
            session.isGameActive = true
            timerDisplay?.startTimer(duration: TimeInterval(session.timeRemaining))
            
            // Start observing session changes
            observeGameSessionChanges()
        }
        
        // Load first question
        if let session = gameSession {
            generateAndDisplayNextQuestion(session: session)
        }
        
        // Play game start sound
        playSoundEffect(.levelComplete) // Using levelComplete as game start sound
        playHapticFeedback(.success)
        
        print("🚀 Game started!")
    }
    
    // MARK: - UI Layout Updates
    
    /// Update all UI layouts for responsive design
    private func updateUILayout() {
        updateHeaderLayout()
        // Additional layout updates will be added in subsequent steps
    }
    
    // MARK: - Animations
    
    /// Animate game start with UI entrance effects
    private func animateGameStart() {
        // Animate score display entrance
        scoreDisplay?.animateEntrance(delay: 0.2)
        
        // Animate timer entrance
        timerDisplay?.animateEntrance(delay: 0.3)
        
        // Animate question card entrance
        questionCard?.animateEntrance(delay: 0.4)
        
        // Animate answer buttons entrance with staggered timing
        for (index, button) in answerButtons.enumerated() {
            button.animateEntrance(delay: 0.6 + Double(index) * 0.1)
        }
        
        // Add background animation enhancement
        animateBackgroundEntrance()
    }
    
    /// Animate background elements entrance
    private func animateBackgroundEntrance() {
        // Fade in background elements
        backgroundContainer.alpha = 0
        let fadeIn = SKAction.fadeIn(withDuration: coordinateSystem.animationDuration(1.0))
        backgroundContainer.run(fadeIn)
        
        // Scale up effect for background layers
        backgroundContainer.setScale(0.8)
        let scaleUp = SKAction.scale(to: 1.0, duration: coordinateSystem.animationDuration(0.8))
        scaleUp.timingMode = .easeOut
        backgroundContainer.run(scaleUp)
    }
    
    // MARK: - Initializers
    
    /// Initialize GameScene with game mode and optional level
    convenience init(gameMode: GameMode, level: GameLevel? = nil) {
        self.init()
        configure(gameMode: gameMode, level: level)
    }
    
    // MARK: - Public Methods
    
    /// Initialize scene with specific game configuration
    func configure(gameMode: GameMode, level: GameLevel? = nil, session: GameSession? = nil) {
        self.gameMode = gameMode
        self.currentLevel = level
        self.gameSession = session ?? GameSession()
        
        print("⚙️ GameScene configured - Mode: \(gameMode), Level: \(level?.name ?? "Quick Play")")
    }
    
    /// Public property to access current level (used by GameSceneManager)
    var level: GameLevel? {
        return currentLevel
    }
    
    /// Pause the game
    func pauseGame() {
        guard isGameActive && !isPaused else { return }
        isPaused = true
        
        // Pause all actions
        gameContainer.isPaused = true
        
        // Pause timer
        timerDisplay?.pauseTimer()
        
        print("⏸️ Game paused")
    }
    
    /// Resume the game
    func resumeGame() {
        guard isGameActive && isPaused else { return }
        isPaused = false
        
        // Resume all actions
        gameContainer.isPaused = false
        
        // Resume timer
        timerDisplay?.resumeTimer()
        
        print("▶️ Game resumed")
    }
    
    /// End the game
    func endGame() {
        isGameActive = false
        isPaused = false
        
        // Stop all animations
        gameContainer.removeAllActions()
        
        // Stop timer
        timerDisplay?.stopTimer()
        
        // Disable answer buttons
        answerButtons.forEach { $0.setEnabled(false) }
        
        print("🏁 Game ended")
    }
    
    // MARK: - Game Logic Methods
    
    /// Handle answer selection
    private func handleAnswerSelected(_ answerValue: Int) {
        guard isGameActive, !isPaused, let session = gameSession else { return }
        guard let currentQuestion = session.currentQuestion else { return }
        
        // Disable all buttons to prevent multiple selections
        answerButtons.forEach { $0.setEnabled(false) }
        
        // Enhanced answer validation
        let validationResult = validateAnswer(answerValue, correctAnswer: currentQuestion.correctAnswer)
        
        // Update button states with enhanced visual feedback
        updateButtonStatesForAnswer(
            selectedAnswer: answerValue, 
            correctAnswer: currentQuestion.correctAnswer, 
            isCorrect: validationResult.isCorrect
        )
        
        // Process the answer through GameSession
        processAnswerWithSession(validationResult.isCorrect, session: session)
        
        // Play sound effects and haptic feedback
        if validationResult.isCorrect {
            playSoundEffect(.correct)
            playHapticFeedback(.success)
        } else {
            playSoundEffect(.incorrect)
            playHapticFeedback(.error)
        }
        
        // Provide detailed feedback
        provideFeedback(for: validationResult)
        
        // Add visual celebrations or feedback
        if validationResult.isCorrect {
            addCorrectAnswerCelebration()
        } else {
            addIncorrectAnswerFeedback()
        }
        
        // Schedule next question or game end
        scheduleNextAction(isCorrect: validationResult.isCorrect, session: session)
    }
    
    /// Update button visual states based on answer
    private func updateButtonStatesForAnswer(selectedAnswer: Int, correctAnswer: Int, isCorrect: Bool) {
        for button in answerButtons {
            if button.answerValue == selectedAnswer {
                // The button that was selected
                button.setState(isCorrect ? .correct : .incorrect, animated: true)
            } else if button.answerValue == correctAnswer && !isCorrect {
                // Show the correct answer if user was wrong
                button.setState(.correct, animated: true)
            } else {
                // Other buttons become disabled
                button.setState(.disabled, animated: true)
            }
        }
    }
    
    /// Process the answer using GameSession logic
    private func processAnswerWithSession(_ isCorrect: Bool, session: GameSession) {
        // Update session statistics
        session.questionsAnswered += 1
        session.playerProgress.totalQuestionsAnswered += 1
        
        if isCorrect {
            session.correctAnswers += 1
            session.playerProgress.correctAnswers += 1
            session.streak += 1
            
            // Calculate score using GameSession's logic
            let points = calculatePointsForAnswer(session: session)
            session.score += points
            
            // Update best streak
            if session.streak > session.playerProgress.bestStreak {
                session.playerProgress.bestStreak = session.streak
            }
            
            // Add bonus time for correct answers in campaign mode
            if gameMode == .campaign {
                let bonusTime = min(session.streak * 2, 10) // Up to 10 seconds bonus
                timerDisplay?.addTime(TimeInterval(bonusTime))
            }
            
        } else {
            session.streak = 0
        }
        
        // Update displays with new data
        updateDisplaysWithSessionData(session)
        
        // Save progress after each answer
        session.saveProgress()
        
        // Update GameData for persistence
        updateGameDataProgress(session)
        
        print("📊 Answer processed - Score: \(session.score), Streak: \(session.streak)")
    }
    
    /// Calculate points for an answer using enhanced logic
    private func calculatePointsForAnswer(session: GameSession) -> Int {
        guard let question = session.currentQuestion else { return 10 }
        
        let basePoints = 10
        let streakBonus = min(session.streak * 2, 20) // Cap at 20 bonus points
        
        let difficultyMultiplier: Int
        switch question.difficulty {
        case .easy: difficultyMultiplier = 1
        case .medium: difficultyMultiplier = 2
        case .hard: difficultyMultiplier = 3
        }
        
        // Time bonus for quick answers (if we track answer time)
        let timeBonus = 0 // Could add time-based bonus here
        
        return (basePoints + streakBonus + timeBonus) * difficultyMultiplier
    }
    
    /// Update displays with current session data
    private func updateDisplaysWithSessionData(_ session: GameSession) {
        scoreDisplay?.updateScore(session.score, animated: true)
        scoreDisplay?.updateStreak(session.streak, animated: true)
        
        let progress = Float(session.questionsAnswered) / Float(session.maxQuestions)
        scoreDisplay?.updateProgress(progress, animated: true)
    }
    
    /// Update GameData with current progress
    private func updateGameDataProgress(_ session: GameSession) {
        gameDataRef.playerProgress = session.playerProgress
        
        // Update level completion for campaign mode
        if gameMode == .campaign, let level = currentLevel {
            let accuracy = Double(session.correctAnswers) / Double(session.questionsAnswered)
            let stars = calculateStarsEarned(accuracy: accuracy, streak: session.streak)
            
            // Update level progress if better than before
            // This would require enhanced GameData model
            print("🌟 Level accuracy: \(Int(accuracy * 100))%, Stars: \(stars)")
        }
    }
    
    /// Calculate stars earned based on performance
    private func calculateStarsEarned(accuracy: Double, streak: Int) -> Int {
        if accuracy >= 0.9 && streak >= 5 {
            return 3 // Perfect performance
        } else if accuracy >= 0.7 && streak >= 3 {
            return 2 // Good performance
        } else if accuracy >= 0.5 {
            return 1 // Basic completion
        } else {
            return 0 // No stars
        }
    }
    
    /// Schedule the next action (question or game end)
    private func scheduleNextAction(isCorrect: Bool, session: GameSession) {
        let delay = isCorrect ? 1.8 : 2.5 // Longer delay for wrong answers
        
        let nextAction = SKAction.sequence([
            SKAction.wait(forDuration: delay),
            SKAction.run { [weak self] in
                self?.proceedToNextQuestion(session: session)
            }
        ])
        run(nextAction)
    }
    
    /// Proceed to next question or end game
    private func proceedToNextQuestion(session: GameSession) {
        // Check if game should end
        if session.questionsAnswered >= session.maxQuestions {
            completeGame(session: session)
            return
        }
        
        // Generate and display next question
        generateAndDisplayNextQuestion(session: session)
        
        // Re-enable buttons
        answerButtons.forEach { $0.setEnabled(true) }
    }
    
    /// Generate and display the next question
    private func generateAndDisplayNextQuestion(session: GameSession) {
        // Use GameSession's question generation
        session.generateNewQuestion()
        
        guard let newQuestion = session.currentQuestion else {
            print("❌ Failed to generate question")
            return
        }
        
        // Update UI with new question
        questionCard?.setQuestion(newQuestion)
        updateAnswerButtons(with: newQuestion)
        
        print("❓ New question: \(newQuestion.questionText)")
    }
    
    /// Complete the game with final score calculation
    private func completeGame(session: GameSession) {
        endGame()
        
        // Calculate final results
        let finalAccuracy = Double(session.correctAnswers) / Double(session.questionsAnswered)
        let stars = calculateStarsEarned(accuracy: finalAccuracy, streak: session.playerProgress.bestStreak)
        
        print("🎉 Game Complete!")
        print("📊 Final Score: \(session.score)")
        print("🎯 Accuracy: \(Int(finalAccuracy * 100))%")
        print("🌟 Stars Earned: \(stars)")
        
        // Save final progress
        session.saveProgress()
        
        // TODO: Transition to game over scene
        // GameSceneManager.shared.navigateToScene(.gameOver(GameResults(...)))
    }
    
    /// Handle timer expiration
    private func handleTimeExpired() {
        guard let session = gameSession else { return }
        
        // Time's up - complete the game
        completeGame(session: session)
        
        print("⏰ Time's up! Final Score: \(session.score)")
    }
    
    /// Generate a new math question using GameSession's QuestionGenerator
    private func generateQuestionWithSession(_ session: GameSession) -> MathQuestion {
        let difficulty: GameDifficulty
        let operations: [MathOperation]
        
        if let level = currentLevel {
            // Campaign mode: use level settings
            difficulty = level.difficulty
            operations = level.allowedOperations
        } else {
            // Quick play mode: adaptive difficulty
            difficulty = getAdaptiveDifficulty(session: session)
            operations = getOperationsForDifficulty(difficulty)
        }
        
        return questionGenerator.generateQuestion(difficulty: difficulty, operations: operations)
    }
    
    /// Get adaptive difficulty based on current performance
    private func getAdaptiveDifficulty(session: GameSession) -> GameDifficulty {
        guard session.questionsAnswered > 0 else { return .easy }
        
        let accuracy = Double(session.correctAnswers) / Double(session.questionsAnswered)
        let recentStreak = session.streak
        
        // Adaptive difficulty logic
        if accuracy >= 0.8 && recentStreak >= 4 {
            return .hard
        } else if accuracy >= 0.6 && recentStreak >= 2 {
            return .medium
        } else {
            return .easy
        }
    }
    
    /// Get operations allowed for a difficulty level
    private func getOperationsForDifficulty(_ difficulty: GameDifficulty) -> [MathOperation] {
        switch difficulty {
        case .easy:
            return [.addition, .subtraction]
        case .medium:
            return [.addition, .subtraction, .multiplication]
        case .hard:
            return MathOperation.allCases
        }
    }
    
    /// Update answer buttons with new question data
    private func updateAnswerButtons(with question: MathQuestion) {
        let answers = [question.correctAnswer] + question.wrongAnswers
        let shuffledAnswers = answers.shuffled()
        
        for (index, button) in answerButtons.enumerated() {
            if index < shuffledAnswers.count {
                button.setAnswer(shuffledAnswers[index])
                button.setEnabled(true)
                button.setState(.normal, animated: true)
            } else {
                button.setAnswer(0)
                button.setEnabled(false)
                button.setState(.disabled, animated: true)
            }
        }
        
        print("🔄 Answer buttons updated with: \(shuffledAnswers)")
    }
    
    // MARK: - Touch Handling
    
    /// Handle touch began events
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameActive, !isPaused else { return }
        
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)
            
            // Check if any answer button was touched
            for node in touchedNodes {
                if let answerButton = node.parent as? AnswerButtonNode {
                    handleAnswerButtonTouch(answerButton)
                    return
                } else if let answerButton = node as? AnswerButtonNode {
                    handleAnswerButtonTouch(answerButton)
                    return
                }
            }
        }
    }
    
    /// Handle answer button touch
    private func handleAnswerButtonTouch(_ button: AnswerButtonNode) {
        guard button.isEnabled else { return }
        
        // Add touch feedback
        button.addTouchFeedback()
        
        // Handle the answer selection
        handleAnswerSelected(button.answerValue)
        
        print("🎯 Answer button touched: \(button.answerValue)")
    }
    
    /// Handle touch moved events (for button highlighting)
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isGameActive, !isPaused else { return }
        
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNodes = nodes(at: location)
            
            // Update button hover states
            for button in answerButtons {
                let isHovered = touchedNodes.contains { node in
                    return node.parent == button || node == button
                }
                button.setHovered(isHovered)
            }
        }
    }
    
    /// Handle touch ended events
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Clear all hover states
        for button in answerButtons {
            button.setHovered(false)
        }
    }
    
    /// Handle touch cancelled events
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Clear all hover states
        for button in answerButtons {
            button.setHovered(false)
        }
    }

    // MARK: - Game Session Observation
    
    /// Start observing GameSession changes
    private func observeGameSessionChanges() {
        // In a real implementation, this would set up observers for GameSession changes
        // For now, we rely on direct method calls to update the UI
        print("👀 Started observing GameSession changes")
    }
    
    /// Update answer buttons with new question data
    private func updateAnswerButtons(with question: MathQuestion) {
        let answers = [question.correctAnswer] + question.wrongAnswers
        let shuffledAnswers = answers.shuffled()
        
        for (index, button) in answerButtons.enumerated() {
            if index < shuffledAnswers.count {
                button.setAnswer(shuffledAnswers[index])
                button.setEnabled(true)
                button.setState(.normal, animated: true)
            } else {
                button.setAnswer(0)
                button.setEnabled(false)
                button.setState(.disabled, animated: true)
            }
        }
        
        print("🔄 Answer buttons updated with: \(shuffledAnswers)")
    }
    
    /// Schedule next action based on answer result
    private func scheduleNextAction(isCorrect: Bool, session: GameSession) {
        let delayDuration: TimeInterval = isCorrect ? 1.5 : 2.0 // Longer delay for wrong answers
        
        let nextAction = SKAction.sequence([
            SKAction.wait(forDuration: delayDuration),
            SKAction.run { [weak self] in
                self?.proceedToNextQuestion(session: session)
            }
        ])
        
        run(nextAction, withKey: "nextQuestionAction")
    }
    
    /// Proceed to next question or end game
    private func proceedToNextQuestion(session: GameSession) {
        // Check if game should end
        if session.questionsAnswered >= session.maxQuestions {
            completeGame(session: session)
            return
        }
        
        // Update displays with current session state
        updateDisplaysWithSession(session)
        
        // Generate and display next question
        generateAndDisplayNextQuestion(session: session)
        
        // Re-enable buttons
        answerButtons.forEach { $0.setEnabled(true) }
    }
}

// MARK: - SKLabelNode Extensions for Visual Effects

extension SKLabelNode {
    /// Add glow effect to label
    func addGlow(color: UIColor, radius: CGFloat) {
        let effectNode = SKEffectNode()
        effectNode.shouldRasterize = true
        effectNode.shouldEnableEffects = true
        
        let blur = CIFilter(name: "CIGaussianBlur")
        blur?.setValue(radius, forKey: kCIInputRadiusKey)
        effectNode.filter = blur
        
        let glowLabel = self.copy() as! SKLabelNode
        glowLabel.fontColor = color
        glowLabel.blendMode = .add
        
        effectNode.addChild(glowLabel)
        parent?.insertChild(effectNode, at: 0)  // Insert behind original label
    }
}
