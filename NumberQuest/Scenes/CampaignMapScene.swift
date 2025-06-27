//
//  CampaignMapScene.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 27/6/25.
//

import SpriteKit
import GameplayKit

/// Main adventure map scene with side-scrolling levels and progressive unlocking
class CampaignMapScene: SKScene {
    
    // MARK: - UI Elements
    
    private var backgroundNode: SKSpriteNode!
    private var scrollableContent: SKNode!
    private var levelNodes: [LevelNode] = []
    private var pathNodes: [SKNode] = []
    
    // HUD Elements
    private var titleLabel: SKLabelNode!
    private var totalStarsLabel: SKLabelNode!
    private var homeButton: MenuButton!
    private var worldThemeLabel: SKLabelNode!
    
    // Parallax background layers
    private var backgroundLayers: [SKNode] = []
    
    // MARK: - Game Data
    
    private var campaignLevels: [CampaignLevel] = []
    private var currentWorldTheme: WorldTheme = .forest
    private var totalStarsCollected: Int = 0
    
    // MARK: - Scroll Properties
    
    private var lastTouchLocation: CGPoint = .zero
    private var scrollVelocity: CGFloat = 0
    private var isDragging: Bool = false
    private let maxScrollSpeed: CGFloat = 1000
    private let scrollDamping: CGFloat = 0.9
    
    // MARK: - Layout Constants
    
    private let levelSpacing: CGFloat = 200
    private let pathWidth: CGFloat = 8
    private let levelNodeSize = CGSize(width: 80, height: 80)
    
    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
        setupBackground()
        setupScrolling()
        generateCampaignLevels()
        setupUI()
        setupInitialView()
    }
    
    override func willMove(from view: SKView) {
        removeAllActions()
    }
    
    /// Called when returning from a level to refresh progress
    func refreshCampaignProgress() {
        // Regenerate levels with updated progress
        generateCampaignLevels()
        
        // Update existing level nodes
        for (index, levelNode) in levelNodes.enumerated() {
            if index < campaignLevels.count {
                levelNode.updateProgress(campaignLevels[index])
            }
        }
        
        print("🔄 Campaign progress refreshed")
    }
    
    override func update(_ currentTime: TimeInterval) {
        updateScrolling()
        updateParallax()
    }
    
    // MARK: - Setup Methods
    
    private func setupBackground() {
        // Create gradient background
        backgroundNode = SKSpriteNode(color: currentWorldTheme.backgroundColor, size: size)
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode.zPosition = -100
        addChild(backgroundNode)
    }
    
    private func setupScrolling() {
        scrollableContent = SKNode()
        scrollableContent.position = CGPoint(x: 0, y: size.height / 2)
        addChild(scrollableContent)
    }
    
    private func setupUI() {
        // Title
        titleLabel = SKLabelNode()
        titleLabel.configureAsMenuButton("🗺️ Adventure Map", size: .large, color: .white)
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height - 60)
        titleLabel.zPosition = 100
        addChild(titleLabel)
        
        // Stars display
        totalStarsLabel = SKLabelNode()
        totalStarsLabel.configureAsMenuButton("⭐ \(totalStarsCollected)", size: .medium, color: .yellow)
        totalStarsLabel.position = CGPoint(x: size.width - 100, y: size.height - 60)
        totalStarsLabel.zPosition = 100
        addChild(totalStarsLabel)
        
        // World theme indicator
        worldThemeLabel = SKLabelNode()
        worldThemeLabel.configureAsMenuButton("🌲 Forest World", size: .medium, color: .white)
        worldThemeLabel.position = CGPoint(x: 150, y: size.height - 60)
        worldThemeLabel.zPosition = 100
        addChild(worldThemeLabel)
        
        // Home button
        homeButton = MenuButton(title: "🏠 Home", size: CGSize(width: 120, height: 50)) {
            SceneManager.shared.showMainMenu()
        }
        homeButton.position = CGPoint(x: 80, y: 60)
        homeButton.zPosition = 100
        addChild(homeButton)
    }
    
    private func setupParallaxLayers() {
        // Create 3 parallax layers for depth
        for i in 0..<3 {
            let layer = SKNode()
            layer.zPosition = -90 + CGFloat(i * 10)
            scrollableContent.addChild(layer)
            backgroundLayers.append(layer)
            
            // Add decorative elements to each layer
            addDecorativeElements(to: layer, layerIndex: i)
        }
    }
    
    private func addDecorativeElements(to layer: SKNode, layerIndex: Int) {
        let elements = currentWorldTheme.decorativeElements
        let spacing: CGFloat = 300 + CGFloat(layerIndex * 100)
        let scale: CGFloat = 0.5 + CGFloat(layerIndex) * 0.3
        
        for i in 0..<10 {
            let element = SKLabelNode(text: elements.randomElement() ?? "🌟")
            element.fontSize = 30 * scale
            element.position = CGPoint(
                x: CGFloat(i) * spacing + CGFloat.random(in: -50...50),
                y: CGFloat.random(in: -200...200)
            )
            element.alpha = 0.6 - CGFloat(layerIndex) * 0.1
            layer.addChild(element)
        }
    }
    
    private func generateCampaignLevels() {
        // Create base level definitions
        let baseLevels = [
            // Forest World (Levels 1-5)
            CampaignLevel(id: 1, worldTheme: .forest, title: "First Steps", 
                         description: "Learn basic addition with friendly animals",
                         difficultyRange: 1...2, position: CGPoint(x: 100, y: 0)),
            
            CampaignLevel(id: 2, worldTheme: .forest, title: "Forest Path", 
                         description: "Addition and subtraction adventure",
                         requiredStars: 1, difficultyRange: 2...3, 
                         position: CGPoint(x: 300, y: 50)),
            
            CampaignLevel(id: 3, worldTheme: .forest, title: "Tree Top Challenge", 
                         description: "Higher numbers and mixed operations",
                         requiredStars: 4, difficultyRange: 3...4, 
                         position: CGPoint(x: 500, y: -30)),
            
            CampaignLevel(id: 4, worldTheme: .forest, title: "Deep Woods", 
                         description: "Complex addition and subtraction",
                         requiredStars: 7, difficultyRange: 4...5, 
                         position: CGPoint(x: 700, y: 80)),
            
            CampaignLevel(id: 5, worldTheme: .forest, title: "Forest Guardian", 
                         description: "Master the forest with a boss challenge",
                         requiredStars: 10, difficultyRange: 5...6, 
                         position: CGPoint(x: 900, y: 0)),
            
            // Ocean World (Levels 6-10)
            CampaignLevel(id: 6, worldTheme: .ocean, title: "Shallow Waters", 
                         description: "Dive into multiplication basics",
                         requiredStars: 13, difficultyRange: 4...5, 
                         position: CGPoint(x: 1100, y: -50)),
            
            CampaignLevel(id: 7, worldTheme: .ocean, title: "Coral Reef", 
                         description: "Colorful multiplication adventures",
                         requiredStars: 16, difficultyRange: 5...6, 
                         position: CGPoint(x: 1300, y: 60)),
            
            CampaignLevel(id: 8, worldTheme: .ocean, title: "Deep Sea", 
                         description: "Advanced operations in the depths",
                         requiredStars: 19, difficultyRange: 6...7, 
                         position: CGPoint(x: 1500, y: -20)),
            
            CampaignLevel(id: 9, worldTheme: .ocean, title: "Underwater Cave", 
                         description: "Challenge yourself with complex problems",
                         requiredStars: 22, difficultyRange: 7...8, 
                         position: CGPoint(x: 1700, y: 70)),
            
            CampaignLevel(id: 10, worldTheme: .ocean, title: "Ocean Master", 
                         description: "Conquer the seas with ultimate math skills",
                         requiredStars: 25, difficultyRange: 8...9, 
                         position: CGPoint(x: 1900, y: 0))
        ]
        
        // Apply progress data to each level
        campaignLevels = baseLevels.map { baseLevel in
            let progress = CampaignProgressManager.shared.getLevelProgress(levelId: baseLevel.id)
            return baseLevel.withProgress(progress)
        }
    }
    
    private func setupLevelNodes() {
        for (index, level) in campaignLevels.enumerated() {
            let levelNode = LevelNode(level: level, index: index)
            levelNode.position = level.position
            levelNode.delegate = self
            scrollableContent.addChild(levelNode)
            levelNodes.append(levelNode)
        }
    }
    
    private func setupPaths() {
        // Create paths connecting levels
        for i in 0..<campaignLevels.count - 1 {
            let currentLevel = campaignLevels[i]
            let nextLevel = campaignLevels[i + 1]
            
            let path = createPath(from: currentLevel.position, to: nextLevel.position)
            scrollableContent.addChild(path)
            pathNodes.append(path)
        }
    }
    
    private func createPath(from startPoint: CGPoint, to endPoint: CGPoint) -> SKNode {
        let pathContainer = SKNode()
        
        // Create curved path using multiple segments
        let segments = 10
        let controlPoint = CGPoint(
            x: (startPoint.x + endPoint.x) / 2,
            y: max(startPoint.y, endPoint.y) + 30
        )
        
        for i in 0..<segments {
            let t1 = CGFloat(i) / CGFloat(segments)
            let t2 = CGFloat(i + 1) / CGFloat(segments)
            
            let point1 = quadraticBezierPoint(t: t1, start: startPoint, control: controlPoint, end: endPoint)
            let point2 = quadraticBezierPoint(t: t2, start: startPoint, control: controlPoint, end: endPoint)
            
            let segment = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: point1)
            path.addLine(to: point2)
            segment.path = path
            segment.strokeColor = UIColor.white.withAlphaComponent(0.8)
            segment.lineWidth = pathWidth
            segment.zPosition = -10
            
            pathContainer.addChild(segment)
        }
        
        return pathContainer
    }
    
    private func quadraticBezierPoint(t: CGFloat, start: CGPoint, control: CGPoint, end: CGPoint) -> CGPoint {
        let u = 1 - t
        return CGPoint(
            x: u * u * start.x + 2 * u * t * control.x + t * t * end.x,
            y: u * u * start.y + 2 * u * t * control.y + t * t * end.y
        )
    }
    
    // MARK: - Scrolling Logic
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check if touch is on UI elements
        if homeButton.contains(location) {
            homeButton.touchesBegan(touches, with: event)
            return
        }
        
        // Check for popup overlay closure
        let touchedNodes = nodes(at: location)
        for node in touchedNodes {
            if node.name == "overlay" {
                node.parent?.removeFromParent()
                return
            }
        }
        
        // Check if touch is on level nodes
        let nodeLocation = touch.location(in: scrollableContent)
        for (index, levelNode) in levelNodes.enumerated() {
            if levelNode.contains(nodeLocation) {
                print("🎯 Touch detected on level node \(index + 1) at \(nodeLocation)")
                // Directly call the delegate method instead of forwarding touch events
                let level = campaignLevels[index]
                levelNodeWasTapped(levelNode, level: level)
                return
            }
        }
        
        // Start scrolling
        lastTouchLocation = location
        isDragging = true
        scrollVelocity = 0
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, isDragging else { return }
        
        let location = touch.location(in: self)
        let deltaX = location.x - lastTouchLocation.x
        
        // Move scrollable content
        scrollableContent.position.x += deltaX
        
        // Clamp to bounds
        let minX = -(levelSpacing * CGFloat(campaignLevels.count - 1))
        let maxX: CGFloat = 100
        scrollableContent.position.x = max(minX, min(maxX, scrollableContent.position.x))
        
        scrollVelocity = deltaX
        lastTouchLocation = location
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isDragging = false
    }
    
    private func updateScrolling() {
        guard !isDragging && abs(scrollVelocity) > 0.1 else { return }
        
        // Apply momentum scrolling
        scrollableContent.position.x += scrollVelocity
        scrollVelocity *= scrollDamping
        
        // Clamp to bounds
        let minX = -(levelSpacing * CGFloat(campaignLevels.count - 1))
        let maxX: CGFloat = 100
        scrollableContent.position.x = max(minX, min(maxX, scrollableContent.position.x))
        
        // Stop if velocity is too small
        if abs(scrollVelocity) < 0.1 {
            scrollVelocity = 0
        }
    }
    
    private func updateParallax() {
        // Update parallax layers based on scroll position
        for (index, layer) in backgroundLayers.enumerated() {
            let parallaxFactor = 0.2 + CGFloat(index) * 0.1
            layer.position.x = scrollableContent.position.x * parallaxFactor
        }
        
        // Update world theme based on scroll position
        updateWorldTheme()
    }
    
    private func updateWorldTheme() {
        let scrollProgress = -scrollableContent.position.x / (levelSpacing * CGFloat(campaignLevels.count - 1))
        
        let newTheme: WorldTheme
        if scrollProgress < 0.5 {
            newTheme = .forest
        } else {
            newTheme = .ocean
        }
        
        if newTheme != currentWorldTheme {
            currentWorldTheme = newTheme
            animateThemeChange()
        }
    }
    
    private func animateThemeChange() {
        // Animate background color change
        let colorAction = SKAction.colorize(with: currentWorldTheme.backgroundColor, 
                                          colorBlendFactor: 1.0, duration: 1.0)
        backgroundNode.run(colorAction)
        
        // Update world theme label
        let themeText = "\(currentWorldTheme.icon) \(currentWorldTheme.rawValue) World"
        worldThemeLabel.text = themeText
        
        // Animate label
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.3)
        worldThemeLabel.run(SKAction.sequence([scaleUp, scaleDown]))
    }
    
    private func scrollToLevel(_ levelIndex: Int) {
        guard levelIndex < campaignLevels.count else { return }
        
        let targetX = -campaignLevels[levelIndex].position.x + size.width / 2
        let moveAction = SKAction.moveTo(x: targetX, duration: 1.0)
        moveAction.timingMode = .easeInEaseOut
        scrollableContent.run(moveAction)
    }
    
    private func scrollToFirstUnlockedLevel() {
        // Find the first uncompleted unlocked level or the last completed level
        var targetLevelIndex = 0
        
        for (index, level) in campaignLevels.enumerated() {
            if level.isUnlocked && !level.isPerfectlyCompleted {
                targetLevelIndex = index
                break
            } else if level.isUnlocked {
                targetLevelIndex = index
            }
        }
        
        scrollToLevel(targetLevelIndex)
    }
}

// MARK: - LevelNodeDelegate

extension CampaignMapScene: LevelNodeDelegate {
    func levelNodeWasTapped(_ levelNode: LevelNode, level: CampaignLevel) {
        print("🎯 Level tapped: \(level.title) (ID: \(level.id), Unlocked: \(level.isUnlocked))")
        
        if level.isUnlocked {
            print("🎮 Starting level: \(level.title)")
            showLevelPreview(level)
        } else {
            print("🔒 Level is locked")
            showLockedLevelMessage(level)
        }
    }
    
    private func showLevelPreview(_ level: CampaignLevel) {
        // Create enhanced preview popup
        let popup = createLevelPreviewPopup(for: level)
        addChild(popup)
        
        // Animate popup appearance
        popup.setScale(0.1)
        popup.alpha = 0
        
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.4)
        let fadeIn = SKAction.fadeIn(withDuration: 0.4)
        scaleUp.timingMode = .easeOut
        
        popup.run(SKAction.group([scaleUp, fadeIn]))
    }
    
    private func createLevelPreviewPopup(for level: CampaignLevel) -> SKNode {
        let container = SKNode()
        container.position = CGPoint(x: size.width / 2, y: size.height / 2)
        container.zPosition = 200
        
        // Background overlay
        let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: size)
        overlay.position = CGPoint(x: 0, y: 0)
        overlay.zPosition = -1
        container.addChild(overlay)
        
        // Main popup background
        let popup = SKShapeNode(rectOf: CGSize(width: 350, height: 400), cornerRadius: 20)
        popup.fillColor = level.worldTheme.backgroundColor.withAlphaComponent(0.95)
        popup.strokeColor = UIColor.white
        popup.lineWidth = 3
        container.addChild(popup)
        
        // Level title with theme icon
        let titleContainer = SKNode()
        titleContainer.position = CGPoint(x: 0, y: 150)
        
        let themeIcon = SKLabelNode(text: level.worldTheme.icon)
        themeIcon.fontSize = 40
        themeIcon.position = CGPoint(x: -80, y: 0)
        titleContainer.addChild(themeIcon)
        
        let titleLabel = SKLabelNode()
        titleLabel.configureAsMenuButton(level.title, size: .large, color: .white)
        titleLabel.position = CGPoint(x: 20, y: 0)
        titleLabel.horizontalAlignmentMode = .left
        titleContainer.addChild(titleLabel)
        
        popup.addChild(titleContainer)
        
        // Level description
        let descLabel = SKLabelNode()
        descLabel.configureAsMenuButton(level.description, size: .medium, color: .lightGray)
        descLabel.position = CGPoint(x: 0, y: 90)
        descLabel.preferredMaxLayoutWidth = 300
        descLabel.numberOfLines = 2
        popup.addChild(descLabel)
        
        // Difficulty and age information
        let infoContainer = SKNode()
        infoContainer.position = CGPoint(x: 0, y: 30)
        
        // Difficulty indicator
        let difficultyLabel = SKLabelNode()
        difficultyLabel.configureAsMenuButton("Difficulty:", size: .small, color: .white)
        difficultyLabel.position = CGPoint(x: -120, y: 20)
        difficultyLabel.horizontalAlignmentMode = .left
        infoContainer.addChild(difficultyLabel)
        
        // Visual difficulty dots
        let difficultyRange = level.difficultyRange
        let averageDifficulty = (difficultyRange.lowerBound + difficultyRange.upperBound) / 2
        let visualDifficulty = min(5, max(1, (averageDifficulty + 1) / 2))
        
        for i in 0..<5 {
            let dot = SKShapeNode(circleOfRadius: 6)
            if i < visualDifficulty {
                dot.fillColor = getDifficultyColor(for: visualDifficulty)
                dot.strokeColor = UIColor.white
                dot.lineWidth = 2
            } else {
                dot.fillColor = UIColor.clear
                dot.strokeColor = UIColor.white.withAlphaComponent(0.5)
                dot.lineWidth = 1
            }
            dot.position = CGPoint(x: -40 + CGFloat(i) * 20, y: 20)
            infoContainer.addChild(dot)
        }
        
        // Age range
        let ageLabel = SKLabelNode()
        ageLabel.configureAsMenuButton("Age: \(level.recommendedAgeRange)", size: .small, color: .yellow)
        ageLabel.position = CGPoint(x: -120, y: -10)
        ageLabel.horizontalAlignmentMode = .left
        infoContainer.addChild(ageLabel)
        
        // Problem count
        let problemLabel = SKLabelNode()
        problemLabel.configureAsMenuButton("Problems: \(level.problemCount)", size: .small, color: .cyan)
        problemLabel.position = CGPoint(x: 20, y: -10)
        problemLabel.horizontalAlignmentMode = .left
        infoContainer.addChild(problemLabel)
        
        popup.addChild(infoContainer)
        
        // Star display
        let starContainer = SKNode()
        starContainer.position = CGPoint(x: 0, y: -30)
        
        let starsLabel = SKLabelNode()
        starsLabel.configureAsMenuButton("Best Score:", size: .small, color: .white)
        starsLabel.position = CGPoint(x: -60, y: 0)
        starContainer.addChild(starsLabel)
        
        for i in 0..<level.maxStars {
            let star = SKLabelNode()
            if i < level.completedStars {
                star.text = "⭐"
                star.alpha = 1.0
            } else {
                star.text = "☆"
                star.alpha = 0.5
            }
            star.fontSize = 24
            star.position = CGPoint(x: CGFloat(i) * 30, y: 0)
            starContainer.addChild(star)
        }
        
        popup.addChild(starContainer)
        
        // Action buttons
        let buttonContainer = SKNode()
        buttonContainer.position = CGPoint(x: 0, y: -120)
        
        if level.isUnlocked {
            let playButton = MenuButton(
                title: "Play Level",
                icon: "▶️",
                size: CGSize(width: 150, height: 50)
            ) { [weak self] in
                container.removeFromParent()
                self?.startLevel(level)
            }
            playButton.position = CGPoint(x: 0, y: 20)
            buttonContainer.addChild(playButton)
        } else {
            let lockedLabel = SKLabelNode()
            lockedLabel.configureAsMenuButton("🔒 Need \(level.requiredStars) stars", size: .medium, color: .red)
            lockedLabel.position = CGPoint(x: 0, y: 20)
            buttonContainer.addChild(lockedLabel)
        }
        
        let closeButton = MenuButton(
            title: "Close",
            size: CGSize(width: 100, height: 40)
        ) {
            container.removeFromParent()
        }
        closeButton.position = CGPoint(x: 0, y: -30)
        buttonContainer.addChild(closeButton)
        
        popup.addChild(buttonContainer)
        
        // Add tap to close functionality to overlay
        overlay.isUserInteractionEnabled = true
        overlay.name = "overlay"
        
        return container
    }
    
    private func getDifficultyColor(for difficulty: Int) -> UIColor {
        switch difficulty {
        case 1:
            return UIColor.green
        case 2:
            return UIColor.yellow
        case 3:
            return UIColor.orange
        case 4:
            return UIColor.red
        case 5:
            return UIColor.purple
        default:
            return UIColor.gray
        }
    }
    
    private func startLevel(_ level: CampaignLevel) {
        print("🎮 Starting level \(level.id): \(level.title)")
        SceneManager.shared.showCampaignLevel(level)
    }
    
    private func simulateLevelCompletion(_ level: CampaignLevel) {
        // This is temporary - will be replaced with actual level gameplay
        let starsEarned = Int.random(in: 1...3)
        print("🌟 Level completed with \(starsEarned) stars!")
        
        // Update level progress and unlock next levels
        updateLevelProgress(levelId: level.id, starsEarned: starsEarned)
    }
    
    private func updateLevelProgress(levelId: Int, starsEarned: Int) {
        // Find and update the level
        for i in 0..<campaignLevels.count {
            if campaignLevels[i].id == levelId {
                let level = campaignLevels[i]
                let newStars = max(level.completedStars, starsEarned)
                
                campaignLevels[i] = CampaignLevel(
                    id: level.id,
                    worldTheme: level.worldTheme,
                    title: level.title,
                    description: level.description,
                    requiredStars: level.requiredStars,
                    maxStars: level.maxStars,
                    difficultyRange: level.difficultyRange,
                    problemCount: level.problemCount,
                    position: level.position,
                    isUnlocked: level.isUnlocked,
                    completedStars: newStars
                )
                
                // Update total stars
                totalStarsCollected += (newStars - level.completedStars)
                totalStarsLabel.text = "⭐ \(totalStarsCollected)"
                
                // Update visual representation
                if i < levelNodes.count {
                    levelNodes[i].updateProgress(newStars)
                }
                
                break
            }
        }
        
        // Check for newly unlocked levels
        checkAndUnlockLevels()
        
        // Save progress
        saveProgress()
    }
    
    private func checkAndUnlockLevels() {
        for i in 0..<campaignLevels.count {
            let level = campaignLevels[i]
            if !level.isUnlocked && totalStarsCollected >= level.requiredStars {
                // Unlock this level
                campaignLevels[i] = CampaignLevel(
                    id: level.id,
                    worldTheme: level.worldTheme,
                    title: level.title,
                    description: level.description,
                    requiredStars: level.requiredStars,
                    maxStars: level.maxStars,
                    difficultyRange: level.difficultyRange,
                    problemCount: level.problemCount,
                    position: level.position,
                    isUnlocked: true,
                    completedStars: level.completedStars
                )
                
                // Animate unlock
                if i < levelNodes.count {
                    levelNodes[i].animateUnlock()
                }
                
                // Show unlock notification
                showLevelUnlockedNotification(level)
            }
        }
    }
    
    private func showLevelUnlockedNotification(_ level: CampaignLevel) {
        let notification = SKNode()
        notification.position = CGPoint(x: size.width / 2, y: size.height - 150)
        notification.zPosition = 300
        
        let background = SKShapeNode(rectOf: CGSize(width: 300, height: 60), cornerRadius: 15)
        background.fillColor = UIColor.green.withAlphaComponent(0.9)
        background.strokeColor = UIColor.white
        background.lineWidth = 2
        notification.addChild(background)
        
        let message = SKLabelNode()
        message.configureAsMenuButton("🎉 \(level.title) Unlocked!", size: .medium, color: .white)
        message.position = CGPoint(x: 0, y: 0)
        notification.addChild(message)
        
        addChild(notification)
        
        // Animate notification
        notification.alpha = 0
        notification.position.y += 50
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.5)
        let moveDown = SKAction.moveBy(x: 0, y: -50, duration: 0.5)
        let appear = SKAction.group([fadeIn, moveDown])
        
        let wait = SKAction.wait(forDuration: 2.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([appear, wait, fadeOut, remove])
        notification.run(sequence)
    }
    
    private func showLockedLevelMessage(_ level: CampaignLevel) {
        let message = "Need \(level.requiredStars) stars to unlock!"
        
        let messageLabel = SKLabelNode()
        messageLabel.configureAsMenuButton(message, size: .medium, color: .red)
        messageLabel.position = CGPoint(x: size.width / 2, y: size.height / 2)
        messageLabel.zPosition = 200
        addChild(messageLabel)
        
        // Animate and remove
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.3)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([scaleUp, scaleDown, SKAction.wait(forDuration: 1.0), fadeOut, remove])
        messageLabel.run(sequence)
    }
}

// MARK: - Progress Management

extension CampaignMapScene {
    private func saveProgress() {
        // TODO: Implement Core Data or UserDefaults persistence
        // For now, store in UserDefaults as a simple implementation
        let progressData = campaignLevels.map { level in
            [
                "id": level.id,
                "isUnlocked": level.isUnlocked,
                "completedStars": level.completedStars
            ]
        }
        
        UserDefaults.standard.set(progressData, forKey: "CampaignProgress")
        UserDefaults.standard.set(totalStarsCollected, forKey: "TotalStars")
    }
    
    private func loadProgress() {
        // Load progress from UserDefaults
        if let progressData = UserDefaults.standard.array(forKey: "CampaignProgress") as? [[String: Any]] {
            for data in progressData {
                if let id = data["id"] as? Int,
                   let isUnlocked = data["isUnlocked"] as? Bool,
                   let completedStars = data["completedStars"] as? Int {
                    
                    // Find and update the corresponding level
                    for i in 0..<campaignLevels.count {
                        if campaignLevels[i].id == id {
                            let level = campaignLevels[i]
                            campaignLevels[i] = CampaignLevel(
                                id: level.id,
                                worldTheme: level.worldTheme,
                                title: level.title,
                                description: level.description,
                                requiredStars: level.requiredStars,
                                maxStars: level.maxStars,
                                difficultyRange: level.difficultyRange,
                                problemCount: level.problemCount,
                                position: level.position,
                                isUnlocked: isUnlocked,
                                completedStars: completedStars
                            )
                            break
                        }
                    }
                }
            }
        }
        
        totalStarsCollected = UserDefaults.standard.integer(forKey: "TotalStars")
        if totalStarsCollected == 0 {
            // First time playing - ensure first level is unlocked
            if !campaignLevels.isEmpty {
                let firstLevel = campaignLevels[0]
                campaignLevels[0] = CampaignLevel(
                    id: firstLevel.id,
                    worldTheme: firstLevel.worldTheme,
                    title: firstLevel.title,
                    description: firstLevel.description,
                    requiredStars: firstLevel.requiredStars,
                    maxStars: firstLevel.maxStars,
                    difficultyRange: firstLevel.difficultyRange,
                    problemCount: firstLevel.problemCount,
                    position: firstLevel.position,
                    isUnlocked: true,
                    completedStars: firstLevel.completedStars
                )
            }
        }
    }
    
    private func setupInitialView() {
        // Setup parallax layers
        setupParallaxLayers()
        
        // Setup level nodes
        setupLevelNodes()
        
        // Setup connecting paths
        setupPaths()
        
        // Load saved progress
        loadProgress()
        
        // Update UI with loaded data
        totalStarsLabel.text = "⭐ \(totalStarsCollected)"
        
        // Scroll to the appropriate starting position
        scrollToFirstUnlockedLevel()
        
        print("🗺️ Campaign map initialized with \(campaignLevels.count) levels")
    }
}
