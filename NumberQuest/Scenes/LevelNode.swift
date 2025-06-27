//
//  LevelNode.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 27/6/25.
//

import SpriteKit

/// Protocol for handling level node interactions
protocol LevelNodeDelegate: AnyObject {
    func levelNodeWasTapped(_ levelNode: LevelNode, level: CampaignLevel)
}

/// Visual representation of a campaign level on the map
class LevelNode: SKNode {
    
    // MARK: - Properties
    
    private var level: CampaignLevel
    private let levelIndex: Int
    weak var delegate: LevelNodeDelegate?
    
    // Visual elements
    private var backgroundCircle: SKShapeNode!
    private var levelNumberLabel: SKLabelNode!
    private var titleLabel: SKLabelNode!
    private var starNodes: [SKLabelNode] = []
    private var lockIcon: SKLabelNode?
    private var themeIcon: SKLabelNode!
    private var difficultyIndicator: SKNode!
    private var ageRangeLabel: SKLabelNode!
    
    // Animation properties
    private var isAnimating: Bool = false
    private let nodeSize: CGSize = CGSize(width: 80, height: 80)
    
    // MARK: - Initialization
    
    init(level: CampaignLevel, index: Int) {
        self.level = level
        self.levelIndex = index
        super.init()
        
        setupVisuals()
        setupAnimations()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupVisuals() {
        // Background circle
        backgroundCircle = SKShapeNode(circleOfRadius: nodeSize.width / 2)
        backgroundCircle.fillColor = level.isUnlocked ? level.worldTheme.backgroundColor : UIColor.gray
        backgroundCircle.strokeColor = level.isUnlocked ? UIColor.white : UIColor.darkGray
        backgroundCircle.lineWidth = level.isCompleted ? 4 : 2
        backgroundCircle.alpha = level.isUnlocked ? 1.0 : 0.6
        addChild(backgroundCircle)
        
        // Level number
        levelNumberLabel = SKLabelNode()
        if level.isUnlocked {
            levelNumberLabel.configureAsMenuButton("\(level.id)", size: .large, color: .white)
        } else {
            levelNumberLabel.configureAsMenuButton("\(level.id)", size: .large, color: .darkGray)
        }
        levelNumberLabel.position = CGPoint(x: 0, y: -8)
        addChild(levelNumberLabel)
        
        // Theme icon (small, top-right)
        themeIcon = SKLabelNode(text: level.worldTheme.icon)
        themeIcon.fontSize = 20
        themeIcon.position = CGPoint(x: 25, y: 25)
        themeIcon.alpha = level.isUnlocked ? 1.0 : 0.5
        addChild(themeIcon)
        
        // Title below the circle
        titleLabel = SKLabelNode()
        titleLabel.configureAsMenuButton(level.title, size: .small, color: level.isUnlocked ? .white : .gray)
        titleLabel.position = CGPoint(x: 0, y: -60)
        addChild(titleLabel)
        
        // Age range indicator
        ageRangeLabel = SKLabelNode()
        ageRangeLabel.configureAsMenuButton(level.recommendedAgeRange, size: .extraSmall, color: level.isUnlocked ? .cyan : .darkGray)
        ageRangeLabel.position = CGPoint(x: 0, y: -80)
        addChild(ageRangeLabel)
        
        // Difficulty indicator (top-left)
        setupDifficultyIndicator()
        
        // Stars
        setupStars()
        
        // Lock icon if not unlocked
        if !level.isUnlocked {
            lockIcon = SKLabelNode(text: "🔒")
            lockIcon!.fontSize = 24
            lockIcon!.position = CGPoint(x: 0, y: 15)
            addChild(lockIcon!)
        }
        
        // Special effects for completed levels
        if level.isPerfectlyCompleted {
            addPerfectCompletionEffects()
        }
    }
    
    private func setupStars() {
        let starSpacing: CGFloat = 16
        let startX: CGFloat = -CGFloat(level.maxStars - 1) * starSpacing / 2
        
        for i in 0..<level.maxStars {
            let star = SKLabelNode()
            if i < level.completedStars {
                star.text = "⭐"
                star.alpha = 1.0
            } else {
                star.text = "☆"
                star.alpha = 0.5
            }
            star.fontSize = 16
            star.position = CGPoint(x: startX + CGFloat(i) * starSpacing, y: 45)
            addChild(star)
            starNodes.append(star)
        }
    }
    
    private func addPerfectCompletionEffects() {
        // Add a golden glow effect
        let glowNode = SKShapeNode(circleOfRadius: nodeSize.width / 2 + 5)
        glowNode.fillColor = UIColor.clear
        glowNode.strokeColor = UIColor.yellow
        glowNode.lineWidth = 3
        glowNode.alpha = 0.7
        glowNode.zPosition = -1
        addChild(glowNode)
        
        // Pulsing animation
        let scaleUp = SKAction.scale(to: 1.1, duration: 1.0)
        let scaleDown = SKAction.scale(to: 1.0, duration: 1.0)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        glowNode.run(repeatPulse)
    }
    
    private func setupAnimations() {
        // Idle floating animation
        if level.isUnlocked {
            let floatUp = SKAction.moveBy(x: 0, y: 5, duration: 2.0)
            let floatDown = SKAction.moveBy(x: 0, y: -5, duration: 2.0)
            floatUp.timingMode = .easeInEaseOut
            floatDown.timingMode = .easeInEaseOut
            
            let floatSequence = SKAction.sequence([floatUp, floatDown])
            let floatForever = SKAction.repeatForever(floatSequence)
            
            // Delay the animation based on level index for variety
            let delay = SKAction.wait(forDuration: Double(levelIndex) * 0.3)
            let delayedFloat = SKAction.sequence([delay, floatForever])
            
            run(delayedFloat)
        }
    }
    
    private func setupDifficultyIndicator() {
        difficultyIndicator = SKNode()
        difficultyIndicator.position = CGPoint(x: -25, y: 25)
        addChild(difficultyIndicator)
        
        let difficultyRange = level.difficultyRange
        let averageDifficulty = (difficultyRange.lowerBound + difficultyRange.upperBound) / 2
        
        // Create difficulty dots (1-5 scale for visual simplicity)
        let visualDifficulty = min(5, max(1, (averageDifficulty + 1) / 2))
        
        for i in 0..<5 {
            let dot = SKShapeNode(circleOfRadius: 3)
            if i < visualDifficulty {
                // Filled dot for difficulty level
                dot.fillColor = getDifficultyColor(for: visualDifficulty)
                dot.strokeColor = UIColor.white
                dot.lineWidth = 1
            } else {
                // Empty dot
                dot.fillColor = UIColor.clear
                dot.strokeColor = level.isUnlocked ? UIColor.white.withAlphaComponent(0.5) : UIColor.gray
                dot.lineWidth = 1
            }
            
            dot.position = CGPoint(x: CGFloat(i) * 8, y: 0)
            dot.alpha = level.isUnlocked ? 1.0 : 0.5
            difficultyIndicator.addChild(dot)
        }
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
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isAnimating else { return }
        
        // Scale down animation for feedback
        let scaleDown = SKAction.scale(to: 0.9, duration: 0.1)
        run(scaleDown)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isAnimating else { return }
        
        // Scale back up
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        run(scaleUp)
        
        // Trigger tap animation and delegate call
        animateTap()
        delegate?.levelNodeWasTapped(self, level: level)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Scale back up if touch was cancelled
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        run(scaleUp)
    }
    
    // MARK: - Animations
    
    private func animateTap() {
        guard !isAnimating else { return }
        isAnimating = true
        
        if level.isUnlocked {
            // Success animation - bounce and sparkle
            let bounce = SKAction.sequence([
                SKAction.scale(to: 1.2, duration: 0.1),
                SKAction.scale(to: 1.0, duration: 0.1)
            ])
            
            // Add sparkle effect
            addSparkleEffect()
            
            let completion = SKAction.run { [weak self] in
                self?.isAnimating = false
            }
            
            run(SKAction.sequence([bounce, completion]))
        } else {
            // Shake animation for locked levels
            let shake = SKAction.sequence([
                SKAction.moveBy(x: -5, y: 0, duration: 0.05),
                SKAction.moveBy(x: 10, y: 0, duration: 0.05),
                SKAction.moveBy(x: -10, y: 0, duration: 0.05),
                SKAction.moveBy(x: 5, y: 0, duration: 0.05)
            ])
            
            let completion = SKAction.run { [weak self] in
                self?.isAnimating = false
            }
            
            run(SKAction.sequence([shake, completion]))
        }
    }
    
    private func addSparkleEffect() {
        for _ in 0..<8 {
            let sparkle = SKLabelNode(text: "✨")
            sparkle.fontSize = 12
            sparkle.alpha = 0
            
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let radius: CGFloat = 50
            let targetPosition = CGPoint(
                x: cos(angle) * radius,
                y: sin(angle) * radius
            )
            
            sparkle.position = CGPoint.zero
            addChild(sparkle)
            
            let move = SKAction.move(to: targetPosition, duration: 0.8)
            let fadeIn = SKAction.fadeIn(withDuration: 0.2)
            let fadeOut = SKAction.fadeOut(withDuration: 0.6)
            let remove = SKAction.removeFromParent()
            
            let moveAndFade = SKAction.group([move, SKAction.sequence([fadeIn, fadeOut])])
            sparkle.run(SKAction.sequence([moveAndFade, remove]))
        }
    }
    
    // MARK: - Unlock Animation
    
    func animateUnlock() {
        guard !level.isUnlocked else { return }
        
        // Update visual state
        backgroundCircle.fillColor = level.worldTheme.backgroundColor
        backgroundCircle.strokeColor = UIColor.white
        backgroundCircle.alpha = 1.0
        levelNumberLabel.fontColor = UIColor.white
        titleLabel.fontColor = UIColor.white
        ageRangeLabel.fontColor = UIColor.cyan
        themeIcon.alpha = 1.0
        
        // Update difficulty indicator
        for child in difficultyIndicator.children {
            child.alpha = 1.0
        }
        
        // Remove lock icon
        lockIcon?.removeFromParent()
        lockIcon = nil
        
        // Dramatic unlock animation
        let scaleUp = SKAction.scale(to: 1.5, duration: 0.3)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.3)
        let unlock = SKAction.sequence([scaleUp, scaleDown])
        
        // Flash effect
        let flash = SKAction.sequence([
            SKAction.colorize(with: UIColor.yellow, colorBlendFactor: 0.8, duration: 0.1),
            SKAction.colorize(with: UIColor.clear, colorBlendFactor: 0.0, duration: 0.3)
        ])
        
        backgroundCircle.run(flash)
        run(unlock)
        
        // Add fireworks effect
        addFireworksEffect()
        
        // Start idle animation
        setupAnimations()
    }
    
    private func addFireworksEffect() {
        for _ in 0..<12 {
            let firework = SKLabelNode(text: ["🎆", "🎇", "✨", "⭐"].randomElement()!)
            firework.fontSize = 16
            firework.alpha = 0
            
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let radius: CGFloat = CGFloat.random(in: 60...100)
            let targetPosition = CGPoint(
                x: cos(angle) * radius,
                y: sin(angle) * radius
            )
            
            firework.position = CGPoint.zero
            addChild(firework)
            
            let delay = SKAction.wait(forDuration: CGFloat.random(in: 0...0.5))
            let move = SKAction.move(to: targetPosition, duration: 1.0)
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            let fadeOut = SKAction.fadeOut(withDuration: 0.7)
            let remove = SKAction.removeFromParent()
            
            let animation = SKAction.sequence([
                delay,
                SKAction.group([move, SKAction.sequence([fadeIn, fadeOut])]),
                remove
            ])
            
            firework.run(animation)
        }
    }
    
    // MARK: - Progress Updates
    
    func updateProgress(_ newStars: Int) {
        // Update star display
        for (index, starNode) in starNodes.enumerated() {
            if index < newStars {
                starNode.text = "⭐"
                starNode.alpha = 1.0
                
                // Animate star gain
                let scaleUp = SKAction.scale(to: 1.3, duration: 0.2)
                let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
                let sparkle = SKAction.sequence([scaleUp, scaleDown])
                starNode.run(sparkle)
            }
        }
        
        // Update border if perfectly completed
        if newStars >= level.maxStars && !level.isPerfectlyCompleted {
            addPerfectCompletionEffects()
        }
    }
    
    func updateProgress(_ updatedLevel: CampaignLevel) {
        // Update the level reference
        level = updatedLevel
        
        // Update visual elements
        updateStars()
        updateLockState()
        updateColors()
    }
    
    private func updateStars() {
        for (index, starNode) in starNodes.enumerated() {
            if index < level.completedStars {
                starNode.text = "⭐"
                starNode.alpha = 1.0
            } else {
                starNode.text = "☆"
                starNode.alpha = 0.5
            }
        }
    }
    
    private func updateLockState() {
        if level.isUnlocked {
            // Remove lock if it exists
            lockIcon?.removeFromParent()
            lockIcon = nil
        } else if lockIcon == nil {
            // Add lock if needed
            lockIcon = SKLabelNode(text: "🔒")
            lockIcon!.fontSize = 32
            lockIcon!.position = CGPoint(x: 0, y: 0)
            lockIcon!.alpha = 0.8
            lockIcon!.zPosition = 10
            addChild(lockIcon!)
        }
    }
    
    private func updateColors() {
        // Update colors based on unlock state
        levelNumberLabel.color = level.isUnlocked ? .white : .gray
        titleLabel.color = level.isUnlocked ? .white : .gray
        ageRangeLabel.color = level.isUnlocked ? .cyan : .darkGray
        
        // Update background color
        backgroundCircle.fillColor = level.isUnlocked ? 
            level.worldTheme.backgroundColor : 
            level.worldTheme.backgroundColor.withAlphaComponent(0.5)
    }
}
