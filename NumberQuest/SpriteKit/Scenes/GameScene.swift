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
        
        // Create header background
        let headerBg = SKShapeNode(rectOf: CGSize(
            width: coordinateSystem.scaledValue(380),
            height: coordinateSystem.scaledValue(80)
        ), cornerRadius: coordinateSystem.scaledValue(20))
        headerBg.fillColor = UIColor.black.withAlphaComponent(0.2)
        headerBg.strokeColor = UIColor.white.withAlphaComponent(0.3)
        headerBg.lineWidth = 2
        headerBg.zPosition = -1
        headerContainer.addChild(headerBg)
        
        // Add header elements (will be implemented in Step 2.2)
        // This is placeholder for now
        let headerLabel = SKLabelNode(text: "Game Header", style: .heading)
        headerLabel.position = CGPoint(x: 0, y: 0)
        headerContainer.addChild(headerLabel)
        
        print("📊 Header setup completed")
    }
    
    /// Update header UI layout
    private func updateHeaderLayout() {
        // This will be expanded in Step 2.2 when we add actual UI components
    }
    
    // MARK: - Question Area Setup
    
    /// Setup question display area
    private func setupQuestionArea() {
        questionContainer.removeAllChildren()
        
        // Create question card background
        let questionBg = SKShapeNode(rectOf: CGSize(
            width: coordinateSystem.scaledValue(350),
            height: coordinateSystem.scaledValue(120)
        ), cornerRadius: coordinateSystem.scaledValue(25))
        questionBg.fillColor = UIColor.white.withAlphaComponent(0.9)
        questionBg.strokeColor = UIColor.white
        questionBg.lineWidth = 3
        questionBg.zPosition = -1
        
        // Add shadow effect
        let shadow = SKShapeNode(rectOf: questionBg.frame.size, cornerRadius: coordinateSystem.scaledValue(25))
        shadow.fillColor = UIColor.black.withAlphaComponent(0.2)
        shadow.position = CGPoint(x: 5, y: -5)
        shadow.zPosition = -2
        
        questionContainer.addChild(shadow)
        questionContainer.addChild(questionBg)
        
        // Placeholder question text (will be replaced in Step 2.2)
        let questionLabel = SKLabelNode(text: "Question will appear here", style: .questionText)
        questionLabel.position = CGPoint(x: 0, y: 0)
        questionContainer.addChild(questionLabel)
        
        print("❓ Question area setup completed")
    }
    
    // MARK: - Answers Area Setup
    
    /// Setup answer buttons area
    private func setupAnswersArea() {
        answersContainer.removeAllChildren()
        
        // Create placeholder answer buttons (will be implemented in Step 2.2)
        let buttonCount = 4
        let buttonSize = CGSize(
            width: coordinateSystem.scaledValue(150),
            height: coordinateSystem.scaledValue(60)
        )
        
        for i in 0..<buttonCount {
            let button = SKShapeNode(rectOf: buttonSize, cornerRadius: coordinateSystem.scaledValue(15))
            button.fillColor = UIColor.systemBlue.withAlphaComponent(0.8)
            button.strokeColor = UIColor.white
            button.lineWidth = 2
            button.name = "answerButton_\(i)"
            
            // Position buttons in a 2x2 grid
            let col = i % 2
            let row = i / 2
            let spacing = coordinateSystem.scaledValue(20)
            
            button.position = CGPoint(
                x: (CGFloat(col) - 0.5) * (buttonSize.width + spacing),
                y: (0.5 - CGFloat(row)) * (buttonSize.height + spacing)
            )
            
            // Add placeholder text
            let label = SKLabelNode(text: "Answer \(i+1)", style: .answerText)
            label.position = CGPoint(x: label.position.x, y: label.position.y - 5)
            button.addChild(label)
            
            answersContainer.addChild(button)
        }
        
        print("🎯 Answers area setup completed")
    }
    
    // MARK: - Game Initialization
    
    /// Initialize the game session
    private func initializeGame() {
        isGameActive = false
        isPaused = false
        
        // Setup game session based on mode
        if let session = gameSession {
            // Initialize session properties
            session.score = 0
            session.streak = 0
            session.questionsAnswered = 0
            session.correctAnswers = 0
            
            // Set time limit based on level or game mode
            if let level = currentLevel {
                session.maxQuestions = level.maxQuestions
                session.timeRemaining = level.maxQuestions * 30 // 30 seconds per question
            } else {
                session.maxQuestions = 10 // Default for quick play
                session.timeRemaining = 300 // 5 minutes default
            }
        }
        
        print("🎮 Game initialized - Mode: \(gameMode)")
        
        // Start the game after a brief delay
        let startDelay = SKAction.wait(forDuration: 1.0)
        let startGame = SKAction.run { [weak self] in
            self?.startGame()
        }
        run(SKAction.sequence([startDelay, startGame]))
    }
    
    /// Start the actual game
    private func startGame() {
        isGameActive = true
        
        // Show entrance animations for all UI elements
        animateGameStart()
        
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
        // Animate header entrance
        animateNodeEntrance(headerContainer, delay: 0.2)
        
        // Animate question area entrance
        animateNodeEntrance(questionContainer, delay: 0.4)
        
        // Animate answer buttons entrance with staggered timing
        for (index, child) in answersContainer.children.enumerated() {
            animateNodeEntrance(child, delay: 0.6 + Double(index) * 0.1)
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
        
        print("⏸️ Game paused")
    }
    
    /// Resume the game
    func resumeGame() {
        guard isGameActive && isPaused else { return }
        isPaused = false
        
        // Resume all actions
        gameContainer.isPaused = false
        
        print("▶️ Game resumed")
    }
    
    /// End the game
    func endGame() {
        isGameActive = false
        isPaused = false
        
        // Stop all animations
        gameContainer.removeAllActions()
        
        print("🏁 Game ended")
    }
}

// MARK: - Supporting Types

/// Layout zones for positioning UI elements
private enum LayoutZone {
    case header
    case questionArea
    case answersArea
}

// MARK: - SKLabelNode Extension for Text Styles

extension SKLabelNode {
    /// Convenience initializer with text style
    convenience init(text: String, style: TextStyle) {
        self.init()
        self.text = text
        
        // Apply text style (simplified version - full implementation would use TextStyles.swift)
        switch style {
        case .gameTitle:
            self.fontSize = 42
            self.fontName = "Baloo2-Bold"
        case .heading:
            self.fontSize = 24
            self.fontName = "Baloo2-Medium"
        case .questionText:
            self.fontSize = 28
            self.fontName = "Baloo2-Bold"
        case .answerText:
            self.fontSize = 18
            self.fontName = "Baloo2-Medium"
        default:
            self.fontSize = 16
            self.fontName = "Baloo2-Regular"
        }
        
        self.fontColor = .white
        self.horizontalAlignmentMode = .center
        self.verticalAlignmentMode = .center
    }
}

/// Text style enumeration
enum TextStyle {
    case gameTitle, heading, questionText, answerText, body
}
