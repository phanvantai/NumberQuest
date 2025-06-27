//
//  CampaignLevelScene.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 27/6/25.
//

import SpriteKit
import GameplayKit

/// Individual campaign level gameplay scene with themed backgrounds and character interactions
class CampaignLevelScene: SKScene {
    
    // MARK: - Game Components
    
    private var mathGenerator: MathProblemGenerator!
    private var difficultyEngine: AdaptiveDifficultyEngine!
    private var currentProblem: MathProblem?
    private var level: CampaignLevel!
    
    // MARK: - UI Elements
    
    private var backgroundNode: SKSpriteNode!
    private var characterNode: SKNode!
    private var problemContainerNode: SKNode!
    private var problemLabel: SKLabelNode!
    private var answerButtons: [MenuButton] = []
    
    // HUD Elements
    private var progressBar: SKNode!
    private var progressFill: SKShapeNode!
    private var levelTitleLabel: SKLabelNode!
    private var problemCountLabel: SKLabelNode!
    private var starsDisplay: SKNode!
    private var pauseButton: MenuButton!
    
    // Character and animations
    private var mainCharacter: SKSpriteNode!
    private var characterState: CharacterState = .idle
    
    // MARK: - Game State
    
    private var currentProblemIndex: Int = 0
    private var totalProblems: Int = 5
    private var correctAnswers: Int = 0
    private var currentScore: Int = 0
    private var problemStartTime: Date = Date()
    private var isLevelActive: Bool = false
    private var levelStartTime: Date = Date()
    
    // Level progression
    private var problemResults: [Bool] = []
    private var responseTimes: [TimeInterval] = []
    
    // MARK: - Configuration
    
    private let buttonSize = CGSize(width: 140, height: 70)
    private let buttonSpacing: CGFloat = 30
    private let animationDuration: TimeInterval = 0.4
    
    // MARK: - Character States
    
    enum CharacterState {
        case idle
        case thinking
        case celebrating
        case encouraging
        case explaining
    }
    
    // MARK: - Initialization
    
    init(level: CampaignLevel) {
        self.level = level
        super.init(size: CGSize.zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
        setupGameComponents()
        setupBackground()
        setupCharacter()
        setupProblemContainer()
        setupHUD()
        setupLayout()
        startLevel()
    }
    
    override func willMove(from view: SKView) {
        removeAllActions()
    }
    
    // MARK: - Setup Methods
    
    private func setupGameComponents() {
        // Initialize math components with level-specific difficulty
        mathGenerator = MathProblemGenerator()
        mathGenerator.setDifficulty(level.difficultyRange.lowerBound)
        
        difficultyEngine = AdaptiveDifficultyEngine()
        
        // Set total problems for this level
        totalProblems = level.problemCount
    }
    
    private func setupBackground() {
        // Create themed background
        backgroundNode = SKSpriteNode(color: level.worldTheme.backgroundColor, size: size)
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode.zPosition = -100
        addChild(backgroundNode)
        
        // Add decorative theme elements
        addThemeDecorations()
    }
    
    private func addThemeDecorations() {
        let decorativeElements = level.worldTheme.decorativeElements
        
        // Add corner decorations
        for i in 0..<4 {
            let decoration = SKLabelNode(text: decorativeElements.randomElement() ?? "⭐")
            decoration.fontSize = 40
            decoration.alpha = 0.6
            
            switch i {
            case 0: // Top-left
                decoration.position = CGPoint(x: 60, y: size.height - 60)
            case 1: // Top-right
                decoration.position = CGPoint(x: size.width - 60, y: size.height - 60)
            case 2: // Bottom-left
                decoration.position = CGPoint(x: 60, y: 60)
            case 3: // Bottom-right
                decoration.position = CGPoint(x: size.width - 60, y: 60)
            default:
                break
            }
            
            decoration.zPosition = -50
            addChild(decoration)
            
            // Add gentle floating animation
            let floatUp = SKAction.moveBy(x: 0, y: 10, duration: 2.0)
            let floatDown = SKAction.moveBy(x: 0, y: -10, duration: 2.0)
            floatUp.timingMode = .easeInEaseOut
            floatDown.timingMode = .easeInEaseOut
            let floatSequence = SKAction.sequence([floatUp, floatDown])
            decoration.run(SKAction.repeatForever(floatSequence))
        }
    }
    
    private func setupCharacter() {
        characterNode = SKNode()
        characterNode.position = CGPoint(x: size.width * 0.2, y: size.height * 0.3)
        addChild(characterNode)
        
        // Main character sprite (using emoji for now, will be replaced with actual sprites)
        mainCharacter = SKSpriteNode()
        let characterEmoji = getCharacterForTheme()
        let characterLabel = SKLabelNode(text: characterEmoji)
        characterLabel.fontSize = 80
        characterLabel.position = CGPoint.zero
        mainCharacter.addChild(characterLabel)
        characterNode.addChild(mainCharacter)
        
        // Character speech bubble (initially hidden)
        createSpeechBubble()
        
        // Start idle animation
        animateCharacter(to: .idle)
    }
    
    private func getCharacterForTheme() -> String {
        switch level.worldTheme {
        case .forest:
            return "🦉" // Wise owl for forest
        case .ocean:
            return "🐙" // Friendly octopus for ocean
        case .space:
            return "👽" // Alien for space
        case .castle:
            return "🧙‍♂️" // Wizard for castle
        }
    }
    
    private func createSpeechBubble() {
        let bubble = SKShapeNode(rectOf: CGSize(width: 200, height: 80), cornerRadius: 15)
        bubble.fillColor = UIColor.white.withAlphaComponent(0.9)
        bubble.strokeColor = UIColor.gray
        bubble.lineWidth = 2
        bubble.position = CGPoint(x: 120, y: 60)
        bubble.alpha = 0
        bubble.name = "speechBubble"
        characterNode.addChild(bubble)
        
        let speechLabel = SKLabelNode()
        speechLabel.configureAsMenuButton("", size: .small, color: .black)
        speechLabel.preferredMaxLayoutWidth = 180
        speechLabel.numberOfLines = 2
        speechLabel.name = "speechText"
        bubble.addChild(speechLabel)
    }
    
    private func setupProblemContainer() {
        problemContainerNode = SKNode()
        problemContainerNode.position = CGPoint(x: size.width / 2, y: size.height * 0.6)
        addChild(problemContainerNode)
        
        // Problem background
        let problemBG = SKShapeNode(rectOf: CGSize(width: 400, height: 150), cornerRadius: 20)
        problemBG.fillColor = UIColor.white.withAlphaComponent(0.9)
        problemBG.strokeColor = level.worldTheme.backgroundColor
        problemBG.lineWidth = 4
        problemBG.zPosition = -1
        problemContainerNode.addChild(problemBG)
        
        // Problem label
        problemLabel = SKLabelNode()
        problemLabel.configureAsMenuButton("", size: .extraLarge, color: .black)
        problemLabel.position = CGPoint(x: 0, y: 0)
        problemContainerNode.addChild(problemLabel)
    }
    
    private func setupHUD() {
        // Level title
        levelTitleLabel = SKLabelNode()
        levelTitleLabel.configureAsMenuButton("\(level.worldTheme.icon) \(level.title)", size: .large, color: .white)
        levelTitleLabel.position = CGPoint(x: size.width / 2, y: size.height - 50)
        levelTitleLabel.zPosition = 100
        addChild(levelTitleLabel)
        
        // Progress bar
        createProgressBar()
        
        // Problem counter
        problemCountLabel = SKLabelNode()
        problemCountLabel.configureAsMenuButton("Problem 1 of \(totalProblems)", size: .medium, color: .white)
        problemCountLabel.position = CGPoint(x: size.width / 2, y: size.height - 120)
        problemCountLabel.zPosition = 100
        addChild(problemCountLabel)
        
        // Stars display (current session)
        createStarsDisplay()
        
        // Pause button
        pauseButton = MenuButton(
            title: "⏸️",
            size: CGSize(width: 60, height: 60)
        ) { [weak self] in
            self?.pauseLevel()
        }
        pauseButton.position = CGPoint(x: size.width - 50, y: size.height - 50)
        pauseButton.zPosition = 100
        addChild(pauseButton)
    }
    
    private func createProgressBar() {
        progressBar = SKNode()
        progressBar.position = CGPoint(x: size.width / 2, y: size.height - 90)
        addChild(progressBar)
        
        // Background bar
        let barBG = SKShapeNode(rectOf: CGSize(width: 300, height: 20), cornerRadius: 10)
        barBG.fillColor = UIColor.white.withAlphaComponent(0.3)
        barBG.strokeColor = UIColor.white
        barBG.lineWidth = 2
        progressBar.addChild(barBG)
        
        // Progress fill
        progressFill = SKShapeNode(rectOf: CGSize(width: 0, height: 16), cornerRadius: 8)
        progressFill.fillColor = UIColor.green
        progressFill.position = CGPoint(x: -150, y: 0)
        progressBar.addChild(progressFill)
    }
    
    private func createStarsDisplay() {
        starsDisplay = SKNode()
        starsDisplay.position = CGPoint(x: 60, y: size.height - 50)
        addChild(starsDisplay)
        
        for i in 0..<3 {
            let star = SKLabelNode(text: "☆")
            star.fontSize = 24
            star.position = CGPoint(x: CGFloat(i) * 30, y: 0)
            star.alpha = 0.5
            star.name = "star_\(i)"
            starsDisplay.addChild(star)
        }
    }
    
    private func setupLayout() {
        // Answer buttons container
        let buttonsContainer = SKNode()
        buttonsContainer.position = CGPoint(x: size.width / 2, y: size.height * 0.25)
        addChild(buttonsContainer)
        
        // Create answer buttons
        for i in 0..<4 {
            let button = MenuButton(
                title: "",
                size: buttonSize
            ) { [weak self] in
                self?.answerSelected(index: i)
            }
            
            // Arrange in 2x2 grid
            let row = i / 2
            let col = i % 2
            let x = (CGFloat(col) - 0.5) * (buttonSize.width + buttonSpacing)
            let y = (CGFloat(1 - row) - 0.5) * (buttonSize.height + buttonSpacing)
            
            button.position = CGPoint(x: x, y: y)
            buttonsContainer.addChild(button)
            answerButtons.append(button)
        }
    }
    
    // MARK: - Game Logic
    
    private func startLevel() {
        isLevelActive = true
        levelStartTime = Date()
        currentProblemIndex = 0
        
        // Show level introduction
        showLevelIntroduction()
    }
    
    private func showLevelIntroduction() {
        showCharacterSpeech("Welcome to \(level.title)! Let's solve some math problems together!")
        animateCharacter(to: .encouraging)
        
        // Start first problem after introduction
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.presentNextProblem()
        }
    }
    
    private func presentNextProblem() {
        guard isLevelActive && currentProblemIndex < totalProblems else {
            completeLevelSuccess()
            return
        }
        
        currentProblemIndex += 1
        problemStartTime = Date()
        
        // Update progress
        updateProgress()
        
        // Generate problem with progressive difficulty
        let progressRatio = Float(currentProblemIndex) / Float(totalProblems)
        let difficulty = level.difficultyRange.lowerBound + Int(Float(level.difficultyRange.count) * progressRatio)
        mathGenerator.setDifficulty(difficulty)
        
        currentProblem = mathGenerator.generateProblem()
        
        guard let problem = currentProblem else { return }
        
        // Display problem
        displayProblem(problem)
        
        // Character reaction
        animateCharacter(to: .thinking)
        showCharacterSpeech(getEncouragementMessage())
    }
    
    private func displayProblem(_ problem: MathProblem) {
        // Animate problem appearance
        problemLabel.text = problem.formattedProblem
        problemLabel.setScale(0.1)
        problemLabel.alpha = 0
        
        let scaleUp = SKAction.scale(to: 1.0, duration: animationDuration)
        let fadeIn = SKAction.fadeIn(withDuration: animationDuration)
        scaleUp.timingMode = .easeInEaseOut
        
        problemLabel.run(SKAction.group([scaleUp, fadeIn]))
        
        // Set up answer buttons
        let answers = problem.allAnswerChoices
        for (index, button) in answerButtons.enumerated() {
            if index < answers.count {
                button.updateTitle("\(answers[index])")
                button.isHidden = false
                
                // Animate button appearance with delay
                button.alpha = 0
                button.setScale(0.8)
                
                let delay = SKAction.wait(forDuration: 0.1 + Double(index) * 0.1)
                let fadeIn = SKAction.fadeIn(withDuration: 0.3)
                let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
                let appear = SKAction.group([fadeIn, scaleUp])
                
                button.run(SKAction.sequence([delay, appear]))
            } else {
                button.isHidden = true
            }
        }
    }
    
    private func answerSelected(index: Int) {
        guard let problem = currentProblem, isLevelActive else { return }
        
        let selectedAnswer = problem.allAnswerChoices[index]
        let isCorrect = selectedAnswer == problem.correctAnswer
        let responseTime = Date().timeIntervalSince(problemStartTime)
        
        // Record result
        problemResults.append(isCorrect)
        responseTimes.append(responseTime)
        
        if isCorrect {
            correctAnswers += 1
            handleCorrectAnswer(selectedIndex: index)
        } else {
            handleIncorrectAnswer(selectedIndex: index, correctAnswer: problem.correctAnswer)
        }
        
        // Update difficulty engine
        let performanceData = PerformanceData(
            problemId: UUID(), // Generate a unique ID for this problem
            correct: isCorrect,
            time: responseTime,
            hints: 0 // No hints system in campaign mode yet
        )
        difficultyEngine.recordPerformance(performanceData)
    }
    
    private func handleCorrectAnswer(selectedIndex: Int) {
        // Visual feedback
        highlightButton(index: selectedIndex, isCorrect: true)
        
        // Character celebration
        animateCharacter(to: .celebrating)
        showCharacterSpeech(getCorrectAnswerMessage())
        
        // Add sparkle effect
        addSparkleEffect(at: answerButtons[selectedIndex].position)
        
        // Continue to next problem after feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.presentNextProblem()
        }
    }
    
    private func handleIncorrectAnswer(selectedIndex: Int, correctAnswer: Int) {
        // Visual feedback
        highlightButton(index: selectedIndex, isCorrect: false)
        
        // Show correct answer
        if let correctIndex = currentProblem?.allAnswerChoices.firstIndex(of: correctAnswer) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.highlightButton(index: correctIndex, isCorrect: true)
            }
        }
        
        // Character encouragement
        animateCharacter(to: .encouraging)
        showCharacterSpeech(getIncorrectAnswerMessage())
        
        // Continue to next problem after feedback
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) { [weak self] in
            self?.presentNextProblem()
        }
    }
    
    private func highlightButton(index: Int, isCorrect: Bool) {
        let button = answerButtons[index]
        let color = isCorrect ? UIColor.green : UIColor.red
        
        // Flash animation
        let colorize = SKAction.colorize(with: color, colorBlendFactor: 0.7, duration: 0.2)
        let decolorize = SKAction.colorize(with: UIColor.clear, colorBlendFactor: 0.0, duration: 0.2)
        let flash = SKAction.sequence([colorize, decolorize])
        
        if isCorrect {
            button.run(flash)
        } else {
            button.run(SKAction.repeat(flash, count: 2))
        }
    }
    
    private func updateProgress() {
        // Update progress bar
        let progress = CGFloat(currentProblemIndex) / CGFloat(totalProblems)
        let newWidth = 300 * progress
        
        progressFill.run(SKAction.resize(toWidth: newWidth, duration: 0.3))
        
        // Update problem counter
        problemCountLabel.text = "Problem \(currentProblemIndex) of \(totalProblems)"
        
        // Update stars based on performance
        updateStarsDisplay()
    }
    
    private func updateStarsDisplay() {
        let accuracyRate = Float(correctAnswers) / Float(max(1, problemResults.count))
        let starsEarned = getStarsForAccuracy(accuracyRate)
        
        for i in 0..<3 {
            if let star = starsDisplay.childNode(withName: "star_\(i)") as? SKLabelNode {
                if i < starsEarned {
                    star.text = "⭐"
                    star.alpha = 1.0
                    
                    // Animate star gain
                    let scaleUp = SKAction.scale(to: 1.3, duration: 0.2)
                    let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
                    star.run(SKAction.sequence([scaleUp, scaleDown]))
                } else {
                    star.text = "☆"
                    star.alpha = 0.5
                }
            }
        }
    }
    
    private func getStarsForAccuracy(_ accuracy: Float) -> Int {
        switch accuracy {
        case 0.9...1.0:
            return 3
        case 0.7..<0.9:
            return 2
        case 0.5..<0.7:
            return 1
        default:
            return 0
        }
    }
    
    private func completeLevelSuccess() {
        isLevelActive = false
        
        let finalAccuracy = Float(correctAnswers) / Float(totalProblems)
        let starsEarned = getStarsForAccuracy(finalAccuracy)
        
        // Character final celebration
        animateCharacter(to: .celebrating)
        showCharacterSpeech("Amazing work! You completed \(level.title)!")
        
        // Show results after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.showLevelResults(starsEarned: starsEarned)
        }
    }
    
    // MARK: - Character Animation & Speech
    
    private func animateCharacter(to state: CharacterState) {
        characterState = state
        
        switch state {
        case .idle:
            let gentle = SKAction.sequence([
                SKAction.scale(to: 1.05, duration: 1.5),
                SKAction.scale(to: 1.0, duration: 1.5)
            ])
            mainCharacter.run(SKAction.repeatForever(gentle))
            
        case .thinking:
            let think = SKAction.sequence([
                SKAction.rotate(byAngle: 0.1, duration: 0.3),
                SKAction.rotate(byAngle: -0.2, duration: 0.6),
                SKAction.rotate(byAngle: 0.1, duration: 0.3)
            ])
            mainCharacter.run(SKAction.repeat(think, count: 2))
            
        case .celebrating:
            let jump = SKAction.sequence([
                SKAction.moveBy(x: 0, y: 20, duration: 0.3),
                SKAction.moveBy(x: 0, y: -20, duration: 0.3)
            ])
            let spin = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 0.6)
            mainCharacter.run(SKAction.group([jump, spin]))
            
        case .encouraging:
            let nod = SKAction.sequence([
                SKAction.rotate(byAngle: 0.2, duration: 0.2),
                SKAction.rotate(byAngle: -0.2, duration: 0.2),
                SKAction.rotate(byAngle: 0, duration: 0.2)
            ])
            mainCharacter.run(SKAction.repeat(nod, count: 2))
            
        case .explaining:
            let gentle = SKAction.sequence([
                SKAction.scale(to: 1.1, duration: 0.5),
                SKAction.scale(to: 1.0, duration: 0.5)
            ])
            mainCharacter.run(gentle)
        }
    }
    
    private func showCharacterSpeech(_ message: String) {
        guard let bubble = characterNode.childNode(withName: "speechBubble"),
              let speechText = bubble.childNode(withName: "speechText") as? SKLabelNode else {
            return
        }
        
        speechText.text = message
        
        // Animate bubble appearance
        bubble.alpha = 0
        bubble.setScale(0.1)
        
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let appear = SKAction.group([scaleUp, fadeIn])
        
        let wait = SKAction.wait(forDuration: 2.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        
        bubble.run(SKAction.sequence([appear, wait, fadeOut]))
    }
    
    // MARK: - Helper Methods & Messages
    
    private func getEncouragementMessage() -> String {
        let messages = [
            "You can do it!",
            "Take your time!",
            "Think carefully!",
            "You're doing great!",
            "What do you think?"
        ]
        return messages.randomElement() ?? "Good luck!"
    }
    
    private func getCorrectAnswerMessage() -> String {
        let messages = [
            "Excellent!",
            "Well done!",
            "Perfect!",
            "Amazing!",
            "You got it!",
            "Fantastic!"
        ]
        return messages.randomElement() ?? "Correct!"
    }
    
    private func getIncorrectAnswerMessage() -> String {
        let messages = [
            "Not quite, but keep trying!",
            "Almost! Let's try again!",
            "Good effort! Here's the answer:",
            "Don't worry, learning is fun!",
            "That's okay, see the correct answer?"
        ]
        return messages.randomElement() ?? "Try again!"
    }
    
    private func addSparkleEffect(at position: CGPoint) {
        for _ in 0..<8 {
            let sparkle = SKLabelNode(text: "✨")
            sparkle.fontSize = 16
            sparkle.position = position
            sparkle.alpha = 0
            addChild(sparkle)
            
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let radius: CGFloat = 60
            let targetPosition = CGPoint(
                x: position.x + cos(angle) * radius,
                y: position.y + sin(angle) * radius
            )
            
            let move = SKAction.move(to: targetPosition, duration: 0.8)
            let fadeIn = SKAction.fadeIn(withDuration: 0.2)
            let fadeOut = SKAction.fadeOut(withDuration: 0.6)
            let remove = SKAction.removeFromParent()
            
            let sequence = SKAction.sequence([
                SKAction.group([move, SKAction.sequence([fadeIn, fadeOut])]),
                remove
            ])
            
            sparkle.run(sequence)
        }
    }
    
    // MARK: - Scene Transitions
    
    private func showLevelResults(starsEarned: Int) {
        // Create results overlay
        let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.8), size: size)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 1000
        addChild(overlay)
        
        let resultsContainer = SKNode()
        resultsContainer.position = CGPoint(x: size.width / 2, y: size.height / 2)
        resultsContainer.zPosition = 1001
        addChild(resultsContainer)
        
        // Results background
        let resultsBG = SKShapeNode(rectOf: CGSize(width: 350, height: 300), cornerRadius: 20)
        resultsBG.fillColor = level.worldTheme.backgroundColor.withAlphaComponent(0.95)
        resultsBG.strokeColor = UIColor.white
        resultsBG.lineWidth = 4
        resultsContainer.addChild(resultsBG)
        
        // Level completed title
        let titleLabel = SKLabelNode()
        titleLabel.configureAsMenuButton("Level Complete!", size: .large, color: .white)
        titleLabel.position = CGPoint(x: 0, y: 80)
        resultsContainer.addChild(titleLabel)
        
        // Stars display
        let finalStarsContainer = SKNode()
        finalStarsContainer.position = CGPoint(x: 0, y: 20)
        resultsContainer.addChild(finalStarsContainer)
        
        for i in 0..<3 {
            let star = SKLabelNode()
            if i < starsEarned {
                star.text = "⭐"
                star.alpha = 1.0
            } else {
                star.text = "☆"
                star.alpha = 0.5
            }
            star.fontSize = 32
            star.position = CGPoint(x: CGFloat(i - 1) * 40, y: 0)
            finalStarsContainer.addChild(star)
        }
        
        // Stats
        let accuracyLabel = SKLabelNode()
        let accuracy = Int((Float(correctAnswers) / Float(totalProblems)) * 100)
        accuracyLabel.configureAsMenuButton("Accuracy: \(accuracy)%", size: .medium, color: .white)
        accuracyLabel.position = CGPoint(x: 0, y: -30)
        resultsContainer.addChild(accuracyLabel)
        
        // Buttons
        let buttonContainer = SKNode()
        buttonContainer.position = CGPoint(x: 0, y: -80)
        resultsContainer.addChild(buttonContainer)
        
        let retryButton = MenuButton(
            title: "Try Again",
            size: CGSize(width: 120, height: 50)
        ) { [weak self] in
            self?.restartLevel()
        }
        retryButton.position = CGPoint(x: -70, y: 0)
        buttonContainer.addChild(retryButton)
        
        let continueButton = MenuButton(
            title: "Continue",
            size: CGSize(width: 120, height: 50)
        ) { [weak self] in
            self?.returnToCampaignMap(starsEarned: starsEarned)
        }
        continueButton.position = CGPoint(x: 70, y: 0)
        buttonContainer.addChild(continueButton)
        
        // Animate results appearance
        resultsContainer.setScale(0.1)
        resultsContainer.alpha = 0
        
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.5)
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        scaleUp.timingMode = .easeInEaseOut
        
        resultsContainer.run(SKAction.group([scaleUp, fadeIn]))
    }
    
    private func pauseLevel() {
        guard isLevelActive else { return }
        
        isLevelActive = false
        
        // Pause all animations
        isPaused = true
        
        // Create pause overlay
        let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.8), size: size)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 1000
        overlay.name = "pauseOverlay"
        addChild(overlay)
        
        let pauseContainer = SKNode()
        pauseContainer.position = CGPoint(x: size.width / 2, y: size.height / 2)
        pauseContainer.zPosition = 1001
        pauseContainer.name = "pauseContainer"
        addChild(pauseContainer)
        
        // Pause background
        let pauseBG = SKShapeNode(rectOf: CGSize(width: 300, height: 250), cornerRadius: 20)
        pauseBG.fillColor = level.worldTheme.backgroundColor.withAlphaComponent(0.95)
        pauseBG.strokeColor = UIColor.white
        pauseBG.lineWidth = 4
        pauseContainer.addChild(pauseBG)
        
        // Pause title
        let titleLabel = SKLabelNode()
        titleLabel.configureAsMenuButton("⏸️ Paused", size: .extraLarge, color: .white)
        titleLabel.position = CGPoint(x: 0, y: 60)
        pauseContainer.addChild(titleLabel)
        
        // Buttons
        let resumeButton = MenuButton(
            title: "Resume",
            icon: "▶️",
            size: CGSize(width: 120, height: 50)
        ) { [weak self] in
            self?.resumeLevel()
        }
        resumeButton.position = CGPoint(x: 0, y: 10)
        pauseContainer.addChild(resumeButton)
        
        let quitButton = MenuButton(
            title: "Quit Level",
            size: CGSize(width: 120, height: 50)
        ) { [weak self] in
            self?.quitLevel()
        }
        quitButton.position = CGPoint(x: 0, y: -50)
        pauseContainer.addChild(quitButton)
        
        // Animate pause menu appearance
        pauseContainer.setScale(0.1)
        pauseContainer.alpha = 0
        
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        scaleUp.timingMode = .easeInEaseOut
        
        pauseContainer.run(SKAction.group([scaleUp, fadeIn]))
        
        print("⏸️ Level paused")
    }
    
    private func resumeLevel() {
        // Remove pause overlay
        childNode(withName: "pauseOverlay")?.removeFromParent()
        childNode(withName: "pauseContainer")?.removeFromParent()
        
        // Resume game
        isPaused = false
        isLevelActive = true
        
        print("▶️ Level resumed")
    }
    
    private func quitLevel() {
        print("🚪 Quitting level")
        SceneManager.shared.showCampaign()
    }
    
    private func restartLevel() {
        // Reset all progress and restart
        currentProblemIndex = 0
        correctAnswers = 0
        problemResults.removeAll()
        responseTimes.removeAll()
        
        // Reset UI
        for star in starsDisplay.children {
            if let starLabel = star as? SKLabelNode {
                starLabel.text = "☆"
                starLabel.alpha = 0.5
            }
        }
        
        // Remove results overlay
        children.filter { $0.zPosition >= 1000 }.forEach { $0.removeFromParent() }
        
        // Restart
        startLevel()
    }
    
    private func returnToCampaignMap(starsEarned: Int) {
        // Calculate final stats
        let totalTime = Date().timeIntervalSince(levelStartTime)
        let finalAccuracy = Float(correctAnswers) / Float(totalProblems)
        
        // Update campaign progress
        CampaignProgressManager.shared.updateLevelProgress(
            levelId: level.id,
            starsEarned: starsEarned,
            completionTime: totalTime,
            accuracy: finalAccuracy
        )
        
        print("🏆 Level \(level.id) completed with \(starsEarned) stars!")
        print("📊 Final stats: \(Int(finalAccuracy * 100))% accuracy in \(Int(totalTime))s")
        
        // Return to campaign map
        SceneManager.shared.showCampaign()
    }
}
