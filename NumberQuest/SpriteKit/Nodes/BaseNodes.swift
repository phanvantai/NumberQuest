//
//  BaseNodes.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 21/6/25.
//

import SpriteKit

// MARK: - Game Button Node

class GameButtonNode: SKNode {
    
    private let backgroundNode: SKSpriteNode
    private let labelNode: SKLabelNode
    private let action: () -> Void
    private let style: ButtonStyle
    private let size: ButtonSize
    
    var isEnabled: Bool = true {
        didSet {
            updateAppearance()
        }
    }
    
    init(text: String, style: ButtonStyle, size: ButtonSize, action: @escaping () -> Void) {
        self.style = style
        self.size = size
        self.action = action
        
        // Create background
        backgroundNode = SKSpriteNode(color: style.backgroundColor, size: size.size)
        backgroundNode.name = "background"
        
        // Create label
        labelNode = SKLabelNode(text: text, style: .buttonMedium)
        labelNode.fontSize = size.fontSize
        labelNode.fontColor = style.textColor
        labelNode.verticalAlignmentMode = .center
        labelNode.name = "label"
        
        super.init()
        
        // Setup hierarchy
        addChild(backgroundNode)
        addChild(labelNode)
        
        // Enable user interaction
        isUserInteractionEnabled = true
        
        updateAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateAppearance() {
        let alpha: CGFloat = isEnabled ? 1.0 : 0.5
        backgroundNode.alpha = alpha
        labelNode.alpha = alpha
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled else { return }
        
        // Button press animation
        backgroundNode.buttonPressEffect()
        run(SKAction.playSoundFileNamed("button_press.wav", waitForCompletion: false))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled else { return }
        
        // Check if touch ended within button bounds
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if backgroundNode.contains(location) {
            // Execute action with slight delay for animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.action()
            }
        }
    }
    
    func updateText(_ newText: String) {
        labelNode.animateTextChange(to: newText)
    }
}

// MARK: - Icon Button Node

class IconButtonNode: SKNode {
    
    private let backgroundNode: SKSpriteNode
    private let iconNode: SKLabelNode // Using emoji for now, can be replaced with images
    private let action: () -> Void
    
    var isEnabled: Bool = true {
        didSet {
            updateAppearance()
        }
    }
    
    init(iconName: String, style: ButtonStyle, size: CGSize, action: @escaping () -> Void) {
        self.action = action
        
        // Create circular background
        backgroundNode = SKSpriteNode(color: style.backgroundColor, size: size)
        backgroundNode.name = "background"
        
        // Create icon (using emoji for now)
        iconNode = SKLabelNode(text: iconName)
        iconNode.fontSize = size.height * 0.5
        iconNode.verticalAlignmentMode = .center
        iconNode.name = "icon"
        
        super.init()
        
        addChild(backgroundNode)
        addChild(iconNode)
        
        isUserInteractionEnabled = true
        updateAppearance()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateAppearance() {
        let alpha: CGFloat = isEnabled ? 1.0 : 0.5
        backgroundNode.alpha = alpha
        iconNode.alpha = alpha
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled else { return }
        
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        if backgroundNode.contains(location) {
            backgroundNode.buttonPressEffect()
            action()
        }
    }
}

// MARK: - Info Card Node

class InfoCardNode: SKNode {
    
    private let backgroundNode: SKSpriteNode
    private let titleNode: SKLabelNode
    private let contentNode: SKLabelNode
    
    init(title: String, content: String, size: CGSize, style: CardStyle) {
        // Create background
        let backgroundColor: UIColor
        switch style {
        case .default: backgroundColor = .systemBackground.withAlphaComponent(0.9)
        case .highlighted: backgroundColor = .nqYellow.withAlphaComponent(0.9)
        case .muted: backgroundColor = .systemGray.withAlphaComponent(0.9)
        case .success: backgroundColor = .nqGreen.withAlphaComponent(0.9)
        case .warning: backgroundColor = .nqOrange.withAlphaComponent(0.9)
        case .error: backgroundColor = .nqCoral.withAlphaComponent(0.9)
        }
        
        backgroundNode = SKSpriteNode(color: backgroundColor, size: size)
        backgroundNode.name = "background"
        
        // Create title
        titleNode = SKLabelNode(text: title, style: .heading)
        titleNode.position = CGPoint(x: 0, y: size.height/4)
        titleNode.name = "title"
        
        // Create content
        contentNode = SKLabelNode(text: content, style: .body)
        contentNode.position = CGPoint(x: 0, y: -size.height/4)
        contentNode.numberOfLines = 0
        contentNode.preferredMaxLayoutWidth = size.width * 0.8
        contentNode.name = "content"
        
        super.init()
        
        addChild(backgroundNode)
        addChild(titleNode)
        addChild(contentNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Question Card Node

class QuestionCardNode: SKNode {
    
    private let backgroundNode: SKSpriteNode
    private let questionLabel: SKLabelNode
    
    init(question: String, size: CGSize) {
        backgroundNode = SKSpriteNode(color: .nqPurple.withAlphaComponent(0.9), size: size)
        backgroundNode.name = "background"
        
        questionLabel = SKLabelNode(text: question, style: .questionText)
        questionLabel.numberOfLines = 0
        questionLabel.preferredMaxLayoutWidth = size.width * 0.9
        questionLabel.verticalAlignmentMode = .center
        questionLabel.name = "question"
        
        super.init()
        
        addChild(backgroundNode)
        addChild(questionLabel)
        
        // Add subtle glow effect
        backgroundNode.run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.colorize(with: .nqPink, colorBlendFactor: 0.3, duration: 2.0),
                SKAction.colorize(with: .nqPurple, colorBlendFactor: 1.0, duration: 2.0)
            ])
        ))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateQuestion(_ newQuestion: String) {
        questionLabel.animateTextChange(to: newQuestion)
    }
}

// MARK: - Progress Bar Node

class ProgressBarNode: SKNode {
    
    private let backgroundBar: SKSpriteNode
    private let progressBar: SKSpriteNode
    private let progressMask: SKCropNode
    
    private let maxWidth: CGFloat
    private var currentProgress: CGFloat = 0
    
    init(width: CGFloat, height: CGFloat, progress: CGFloat, style: ProgressBarStyle) {
        maxWidth = width
        
        // Background bar
        backgroundBar = SKSpriteNode(color: .systemGray.withAlphaComponent(0.3), size: CGSize(width: width, height: height))
        backgroundBar.name = "background"
        
        // Progress bar with style-specific color
        let progressColor: UIColor
        switch style {
        case .default: progressColor = .nqBlue
        case .rainbow: progressColor = .nqPink
        case .gradient: progressColor = .nqMint
        }
        
        progressBar = SKSpriteNode(color: progressColor, size: CGSize(width: width, height: height))
        progressBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        progressBar.position = CGPoint(x: -width/2, y: 0)
        progressBar.name = "progress"
        
        // Mask for smooth progress animation
        progressMask = SKCropNode()
        let maskNode = SKSpriteNode(color: .white, size: CGSize(width: 0, height: height))
        maskNode.anchorPoint = CGPoint(x: 0, y: 0.5)
        maskNode.position = CGPoint(x: -width/2, y: 0)
        progressMask.maskNode = maskNode
        
        super.init()
        
        addChild(backgroundBar)
        progressMask.addChild(progressBar)
        addChild(progressMask)
        
        setProgress(progress, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setProgress(_ progress: CGFloat, animated: Bool = true) {
        let clampedProgress = max(0, min(1, progress))
        currentProgress = clampedProgress
        
        let targetWidth = maxWidth * clampedProgress
        
        if animated {
            guard let maskNode = progressMask.maskNode as? SKSpriteNode else { return }
            let resizeAction = SKAction.resize(toWidth: targetWidth, duration: 0.3)
            resizeAction.timingMode = .easeOut
            maskNode.run(resizeAction)
        } else {
            (progressMask.maskNode as? SKSpriteNode)?.size.width = targetWidth
        }
    }
}

// MARK: - Score Display Node

class ScoreDisplayNode: SKNode {
    
    private let scoreLabel: SKLabelNode
    private let titleLabel: SKLabelNode
    private var currentScore: Int = 0
    
    init(score: Int, style: ScoreDisplayStyle) {
        titleLabel = SKLabelNode(text: "Score", style: .caption)
        titleLabel.position = CGPoint(x: 0, y: 15)
        titleLabel.name = "title"
        
        scoreLabel = SKLabelNode(text: "\(score)", style: .scoreText)
        scoreLabel.position = CGPoint(x: 0, y: -5)
        scoreLabel.name = "score"
        
        super.init()
        
        addChild(titleLabel)
        addChild(scoreLabel)
        
        setScore(score, animated: false)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setScore(_ newScore: Int, animated: Bool = true) {
        let oldScore = currentScore
        currentScore = newScore
        
        if animated && newScore > oldScore {
            // Animate score increase
            scoreLabel.pulse(scale: 1.3, duration: 0.4)
            
            // Count up animation
            let countDuration: TimeInterval = 0.5
            let steps = min(newScore - oldScore, 20) // Limit steps for performance
            let stepDuration = countDuration / Double(steps)
            
            for i in 1...steps {
                let delay = Double(i - 1) * stepDuration
                let intermediateScore = oldScore + ((newScore - oldScore) * i / steps)
                
                let waitAction = SKAction.wait(forDuration: delay)
                let updateAction = SKAction.run {
                    self.scoreLabel.text = "\(intermediateScore)"
                }
                let sequence = SKAction.sequence([waitAction, updateAction])
                
                run(sequence)
            }
        } else {
            scoreLabel.text = "\(newScore)"
        }
    }
}

// MARK: - Timer Node

class TimerNode: SKNode {
    
    private let timeLabel: SKLabelNode
    private let titleLabel: SKLabelNode
    private var timeRemaining: Int
    
    init(timeRemaining: Int, style: TimerStyle) {
        self.timeRemaining = timeRemaining
        
        titleLabel = SKLabelNode(text: "Time", style: .caption)
        titleLabel.position = CGPoint(x: 0, y: 15)
        titleLabel.name = "title"
        
        let color: UIColor
        switch style {
        case .default: color = .white
        case .urgent: color = .nqCoral
        case .calm: color = .nqMint
        }
        
        timeLabel = SKLabelNode(text: formatTime(timeRemaining), style: .scoreText)
        timeLabel.fontColor = color
        timeLabel.position = CGPoint(x: 0, y: -5)
        timeLabel.name = "time"
        
        super.init()
        
        addChild(titleLabel)
        addChild(timeLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateTime(_ newTime: Int) {
        timeRemaining = newTime
        timeLabel.text = formatTime(timeRemaining)
        
        // Add urgency effects when time is low
        if timeRemaining <= 10 && timeRemaining > 0 {
            timeLabel.fontColor = .nqCoral
            timeLabel.pulse(scale: 1.2, duration: 0.5)
        }
    }
    
    private func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Placeholder Nodes (to be implemented in later phases)

class CharacterNode: SKNode {
    let character: GameCharacter
    
    init(character: GameCharacter, size: CGSize) {
        self.character = character
        super.init()
        
        // Placeholder implementation
        let emojiNode = SKLabelNode(text: character.emoji)
        emojiNode.fontSize = size.height * 0.8
        addChild(emojiNode)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class SpeechBubbleNode: SKNode {
    init(text: String, size: CGSize, style: SpeechBubbleStyle) {
        super.init()
        
        // Placeholder implementation
        let bubble = SKSpriteNode(color: .white.withAlphaComponent(0.9), size: size)
        let label = SKLabelNode(text: text, style: .body)
        label.fontColor = .black
        
        addChild(bubble)
        addChild(label)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FloatingElementNode: SKNode {
    let elementType: FloatingElementType
    
    init(type: FloatingElementType) {
        self.elementType = type
        super.init()
        
        // Placeholder implementation with emoji
        let emoji: String
        switch type {
        case .star: emoji = "⭐"
        case .circle: emoji = "⚪"
        case .triangle: emoji = "🔺"
        case .square: emoji = "⬜"
        case .heart: emoji = "💙"
        case .diamond: emoji = "💎"
        }
        
        let node = SKLabelNode(text: emoji)
        node.fontSize = 20
        addChild(node)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func startFloating() {
        startFloating(amplitude: 15, duration: 3.0)
    }
}

class StarFieldNode: SKNode {
    init(rect: CGRect, starCount: Int) {
        super.init()
        
        // Placeholder star field
        for _ in 0..<starCount {
            let star = SKLabelNode(text: "✨")
            star.fontSize = CGFloat.random(in: 8...16)
            star.position = CGPoint(
                x: CGFloat.random(in: rect.minX...rect.maxX),
                y: CGFloat.random(in: rect.minY...rect.maxY)
            )
            star.alpha = CGFloat.random(in: 0.3...1.0)
            addChild(star)
            
            // Twinkling animation
            let fadeOut = SKAction.fadeAlpha(to: 0.3, duration: Double.random(in: 1...3))
            let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: Double.random(in: 1...3))
            let sequence = SKAction.sequence([fadeOut, fadeIn])
            star.run(SKAction.repeatForever(sequence))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class PopupNode: SKNode {
    let buttons: [PopupButton]
    
    init(title: String, message: String, buttons: [PopupButton], style: PopupStyle) {
        self.buttons = buttons
        super.init()
        
        // Placeholder popup implementation
        let background = SKSpriteNode(color: .systemBackground.withAlphaComponent(0.95), size: CGSize(width: 300, height: 200))
        let titleLabel = SKLabelNode(text: title, style: .title)
        titleLabel.position = CGPoint(x: 0, y: 50)
        titleLabel.fontColor = .black
        
        let messageLabel = SKLabelNode(text: message, style: .body)
        messageLabel.position = CGPoint(x: 0, y: 0)
        messageLabel.fontColor = .black
        
        addChild(background)
        addChild(titleLabel)
        addChild(messageLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class LoadingIndicatorNode: SKNode {
    init(size: CGSize, style: LoadingStyle) {
        super.init()
        
        // Placeholder loading indicator
        let spinner = SKLabelNode(text: "⏳")
        spinner.fontSize = size.height * 0.8
        addChild(spinner)
        
        // Spinning animation
        let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 1.0)
        spinner.run(SKAction.repeatForever(rotate))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
