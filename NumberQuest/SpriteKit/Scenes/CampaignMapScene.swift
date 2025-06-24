//
//  CampaignMapScene.swift
//  NumberQuest
//
//  Created by NumberQuest on 2024.
//

import SpriteKit

/// Campaign map scene with interactive level selection and animations
class CampaignMapScene: BaseGameScene {
    
    // MARK: - Properties
    
    private var titleLabel: SKLabelNode?
    private var backButton: SKNode?
    private var levelNodes: [LevelNode] = []
    private var selectedLevelNode: LevelNode?
    private var levelPreviewPopup: LevelPreviewPopup?
    private var scrollableContainer: SKNode?
    private var floatingStars: [SKSpriteNode] = []
    
    // Animation properties
    private var levelAnimationTimer: Timer?
    private var starAnimationTimer: Timer?
    
    // MARK: - Scene Setup
    
    override func setupScene() {
        super.setupScene()
        
        // Validate data integrity before displaying levels
        gameData.validateDataIntegrity()
        
        // Setup scrollable container for levels
        setupScrollableContainer()
        
        // Setup title
        setupTitle()
        
        // Setup back button
        setupBackButton()
        
        // Setup level grid
        setupLevelGrid()
        
        // Start floating animations
        startFloatingAnimations()
        
        // Setup background stars
        setupBackgroundStars()
    }
    
    override func setupBackground() {
        super.setupBackground()
        
        // Create animated gradient background with campaign map colors
        let gradientColors = [
            UIColor(red: 0.0, green: 0.7, blue: 0.8, alpha: 1.0), // Cyan
            UIColor(red: 0.2, green: 0.4, blue: 0.9, alpha: 1.0), // Blue
            UIColor(red: 0.3, green: 0.2, blue: 0.7, alpha: 1.0)  // Indigo
        ]
        createGradientBackground(colors: gradientColors)
    }
    
    // MARK: - UI Setup
    
    private func setupScrollableContainer() {
        scrollableContainer = SKNode()
        scrollableContainer?.name = "scrollableContainer"
        addChild(scrollableContainer!)
    }
    
    private func setupTitle() {
        titleLabel = NodeFactory.shared.createLabel(
            text: "🗺️ Adventure Map",
            style: .gameTitle,
            color: .white
        )
        
        guard let titleLabel = titleLabel else { return }
        titleLabel.position = position(x: 0.5, y: 0.95)
        titleLabel.name = "titleLabel"
        
        // Add shadow effect
        let shadowLabel = NodeFactory.shared.createLabel(
            text: "🗺️ Adventure Map",
            style: .gameTitle,
            color: UIColor.black.withAlphaComponent(0.3)
        )
        shadowLabel.position = CGPoint(x: 2, y: -2)
        shadowLabel.zPosition = -1
        titleLabel.addChild(shadowLabel)
        
        addChild(titleLabel)
        
        // Entrance animation
        titleLabel.alpha = 0
        titleLabel.setScale(0.5)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.6)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.6)
        let entrance = SKAction.group([fadeIn, scaleUp])
        entrance.timingMode = .easeOut
        
        titleLabel.run(entrance)
    }
    
    private func setupBackButton() {
        backButton = GameButtonNode.backButton { [weak self] in
            self?.handleBackButtonTapped()
        }
        
        guard let backButton = backButton else { return }
        backButton.position = position(x: 0.1, y: 0.05)
        backButton.name = "backButton"
        addChild(backButton)
        
        // Entrance animation
        backButton.alpha = 0
        let fadeIn = SKAction.fadeIn(withDuration: 0.4)
        fadeIn.timingMode = .easeOut
        backButton.run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            fadeIn
        ]))
    }
    
    private func setupLevelGrid() {
        let levels = gameData.levels
        let columns = 2
        let levelSpacing: CGFloat = isIPad ? 120 : 100
        let levelSize: CGFloat = isIPad ? 140 : 120
        
        // Calculate grid dimensions
        let rows = (levels.count + columns - 1) / columns
        let gridWidth = CGFloat(columns - 1) * levelSpacing
        let gridHeight = CGFloat(rows - 1) * levelSpacing
        
        // Starting position (center the grid)
        let startX = safeCenter.x - gridWidth / 2
        let startY = position(x: 0.5, y: 0.25).y + gridHeight / 2
        
        for (index, level) in levels.enumerated() {
            let row = index / columns
            let col = index % columns
            
            let x = startX + CGFloat(col) * levelSpacing
            let y = startY - CGFloat(row) * levelSpacing
            
            let levelNode = LevelNode(
                level: level,
                size: CGSize(width: levelSize, height: levelSize)
            )
            
            levelNode.position = CGPoint(x: x, y: y)
            levelNode.name = "level_\(level.id)"
            
            // Add to scrollable container
            scrollableContainer?.addChild(levelNode)
            levelNodes.append(levelNode)
            
            // Entrance animation with stagger
            levelNode.alpha = 0
            levelNode.setScale(0.3)
            
            let delay = Double(index) * 0.15
            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            let scaleUp = SKAction.scale(to: 1.0, duration: 0.5)
            let entrance = SKAction.group([fadeIn, scaleUp])
            entrance.timingMode = .easeOut
            
            levelNode.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                entrance
            ]))
            
            // Add floating animation if unlocked
            if level.isUnlocked {
                startLevelFloatingAnimation(levelNode)
            }
        }
    }
    
    private func setupBackgroundStars() {
        // Create floating star particles in the background
        for _ in 0..<15 {
            let star = createFloatingStar()
            addChild(star)
            floatingStars.append(star)
        }
        
        // Start continuous star animation
        startStarAnimation()
    }
    
    // MARK: - Animations
    
    private func startFloatingAnimations() {
        // Start level floating animations
        levelAnimationTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateLevelAnimations()
        }
    }
    
    private func startLevelFloatingAnimation(_ levelNode: LevelNode) {
        let floatUp = SKAction.moveBy(x: 0, y: 8, duration: 2.0)
        let floatDown = SKAction.moveBy(x: 0, y: -8, duration: 2.0)
        
        floatUp.timingMode = .easeInEaseOut
        floatDown.timingMode = .easeInEaseOut
        
        let floatSequence = SKAction.sequence([floatUp, floatDown])
        let floatForever = SKAction.repeatForever(floatSequence)
        
        // Random delay to offset the floating
        let randomDelay = Double.random(in: 0...2.0)
        
        levelNode.run(SKAction.sequence([
            SKAction.wait(forDuration: randomDelay),
            floatForever
        ]), withKey: "floating")
    }
    
    private func createFloatingStar() -> SKSpriteNode {
      let star = SKSpriteNode(texture: AssetManager.shared.starTexture())
        star.size = CGSize(width: 12, height: 12)
        star.alpha = 0.6
        star.zPosition = -10
        
        // Random position
        star.position = CGPoint(
            x: CGFloat.random(in: 0...size.width),
            y: CGFloat.random(in: 0...size.height)
        )
        
        // Floating animation
        let duration = Double.random(in: 8...15)
        let moveBy = CGPoint(
            x: CGFloat.random(in: -50...50),
            y: CGFloat.random(in: -50...50)
        )
        
        let move = SKAction.moveBy(x: moveBy.x, y: moveBy.y, duration: duration)
        let fade = SKAction.sequence([
            SKAction.fadeIn(withDuration: duration / 2),
            SKAction.fadeOut(withDuration: duration / 2)
        ])
        
        let group = SKAction.group([move, fade])
        let repeatForever = SKAction.repeatForever(group)
        
        star.run(repeatForever)
        
        return star
    }
    
    private func startStarAnimation() {
        starAnimationTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { [weak self] _ in
            self?.addNewFloatingStar()
        }
    }
    
    private func addNewFloatingStar() {
        // Remove old stars that are off-screen
        floatingStars.removeAll { star in
            if star.alpha < 0.1 || star.position.y < -100 || star.position.y > size.height + 100 {
                star.removeFromParent()
                return true
            }
            return false
        }
        
        // Add new star if needed
        if floatingStars.count < 20 {
            let star = createFloatingStar()
            addChild(star)
            floatingStars.append(star)
        }
    }
    
    private func updateLevelAnimations() {
        // Add subtle glow effects to unlocked levels
        for levelNode in levelNodes {
            if levelNode.level.isUnlocked {
                levelNode.updateGlowEffect()
            }
        }
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        // Check if a level node was touched
        if let levelNode = findLevelNode(at: location) {
            handleLevelTouched(levelNode)
        }
        
        // Handle back button
        if touchedNode.name == "backButton" || touchedNode.parent?.name == "backButton" {
            handleBackButtonTapped()
        }
    }
    
    private func findLevelNode(at location: CGPoint) -> LevelNode? {
        // Convert to scrollable container coordinates
        let containerLocation = convert(location, to: scrollableContainer!)
        
        for levelNode in levelNodes {
            if levelNode.contains(containerLocation) {
                return levelNode
            }
        }
        return nil
    }
    
    private func handleLevelTouched(_ levelNode: LevelNode) {
        guard levelNode.level.isUnlocked else {
            // Show locked level feedback
            showLockedLevelFeedback(levelNode)
            return
        }
        
        // Play selection sound
        SpriteKitSoundManager.shared.playSound(.buttonTap)
        
        // Animate selection
        animateLevelSelection(levelNode)
        
        // Show level preview popup
        showLevelPreview(levelNode.level)
    }
    
    private func showLockedLevelFeedback(_ levelNode: LevelNode) {
        // Play locked sound
        SpriteKitSoundManager.shared.playSound(.incorrect)
        
        // Shake animation
        let shake = SKAction.sequence([
            SKAction.moveBy(x: -5, y: 0, duration: 0.05),
            SKAction.moveBy(x: 10, y: 0, duration: 0.1),
            SKAction.moveBy(x: -10, y: 0, duration: 0.1),
            SKAction.moveBy(x: 5, y: 0, duration: 0.05)
        ])
        
        levelNode.run(shake)
        
        // Show requirement text
        let requirementText = "Requires \(levelNode.level.requiredStars) ⭐"
        showFloatingText(requirementText, at: levelNode.position, color: .orange)
    }
    
    private func animateLevelSelection(_ levelNode: LevelNode) {
        selectedLevelNode = levelNode
        
        // Scale pulse animation
        let scaleUp = SKAction.scale(to: 1.1, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        
        levelNode.run(pulse)
        
        // Glow effect
        levelNode.addSelectionGlow()
    }
    
    private func showLevelPreview(_ level: GameLevel) {
        // Remove existing popup
        levelPreviewPopup?.removeFromParent()
        
        // Create new popup
        levelPreviewPopup = LevelPreviewPopup(level: level) { [weak self] action in
            self?.handlePreviewAction(action, level: level)
        }
        
        guard let popup = levelPreviewPopup else { return }
        popup.position = safeCenter
        popup.zPosition = 1000
        addChild(popup)
        
        // Entrance animation
        popup.animateIn()
    }
    
    private func handlePreviewAction(_ action: LevelPreviewPopup.Action, level: GameLevel) {
        switch action {
        case .startLevel:
            startLevel(level)
        case .close:
            dismissLevelPreview()
        }
    }
    
    private func startLevel(_ level: GameLevel) {
        // Create a new game session for this level
        let gameSession = GameSession()
        gameSession.setupLevel(level)
        
        // Ensure GameData is synchronized
        gameSession.playerProgress = gameData.playerProgress
        
        // Transition to game scene with doorway effect
        GameSceneManager.shared.presentScene(
            .game(gameSession),
            transitionType: .doorway,
            showLoading: true
        ) { [weak self] success in
            if success {
                // Dismiss level preview after successful transition
                self?.dismissLevelPreview()
            }
        }
    }
    
    private func dismissLevelPreview() {
        levelPreviewPopup?.animateOut { [weak self] in
            self?.levelPreviewPopup?.removeFromParent()
            self?.levelPreviewPopup = nil
            self?.selectedLevelNode?.removeSelectionGlow()
            self?.selectedLevelNode = nil
        }
    }
    
    private func handleBackButtonTapped() {
        // Play back sound
        SpriteKitSoundManager.shared.playSound(.buttonTap)
        
        // Use enhanced back navigation with effects
        GameSceneManager.shared.goBack(withEffect: true)
    }
    
    // MARK: - Helper Methods
    
    private func showFloatingText(_ text: String, at position: CGPoint, color: UIColor) {
        let textLabel = NodeFactory.shared.createLabel(
            text: text,
            style: .caption,
            color: color
        )
        
        textLabel.position = position
        textLabel.zPosition = 100
        addChild(textLabel)
        
        // Floating animation
        let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 1.5)
        let fadeOut = SKAction.fadeOut(withDuration: 1.5)
        let group = SKAction.group([moveUp, fadeOut])
        
        textLabel.run(group) {
            textLabel.removeFromParent()
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        levelAnimationTimer?.invalidate()
        starAnimationTimer?.invalidate()
    }
}
