//
//  InfoCardNode.swift
//  NumberQuest
//
//  Created by TaiPV on 24/6/25.
//

import SpriteKit
import UIKit

/// Information card node for displaying stats, achievements, and other data
class InfoCardNode: SKNode {
    
    // MARK: - Types
    
    enum CardStyle {
        case stats
        case achievement
        case level
        case progress
        case score
        case settings
        
        var colors: (background: UIColor, border: UIColor, text: UIColor, accent: UIColor) {
            switch self {
            case .stats:
                return (
                    background: UIColor(red: 0.2, green: 0.3, blue: 0.8, alpha: 0.8),
                    border: UIColor(red: 0.3, green: 0.4, blue: 0.9, alpha: 0.9),
                    text: .white,
                    accent: UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
                )
            case .achievement:
                return (
                    background: UIColor(red: 0.8, green: 0.6, blue: 0.2, alpha: 0.8),
                    border: UIColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 0.9),
                    text: .white,
                    accent: UIColor(red: 1.0, green: 0.8, blue: 0.0, alpha: 1.0)
                )
            case .level:
                return (
                    background: UIColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 0.8),
                    border: UIColor(red: 0.3, green: 0.8, blue: 0.4, alpha: 0.9),
                    text: .white,
                    accent: UIColor(red: 0.5, green: 1.0, blue: 0.6, alpha: 1.0)
                )
            case .progress:
                return (
                    background: UIColor(red: 0.6, green: 0.3, blue: 0.8, alpha: 0.8),
                    border: UIColor(red: 0.7, green: 0.4, blue: 0.9, alpha: 0.9),
                    text: .white,
                    accent: UIColor(red: 0.9, green: 0.6, blue: 1.0, alpha: 1.0)
                )
            case .score:
                return (
                    background: UIColor(red: 0.8, green: 0.2, blue: 0.3, alpha: 0.8),
                    border: UIColor(red: 0.9, green: 0.3, blue: 0.4, alpha: 0.9),
                    text: .white,
                    accent: UIColor(red: 1.0, green: 0.5, blue: 0.6, alpha: 1.0)
                )
            case .settings:
                return (
                    background: UIColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 0.8),
                    border: UIColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 0.9),
                    text: .white,
                    accent: UIColor(red: 0.7, green: 0.7, blue: 0.8, alpha: 1.0)
                )
            }
        }
    }
    
    enum CardSize {
        case small
        case medium
        case large
        case wide
        case tall
        
        var size: CGSize {
            switch self {
            case .small:
                return CGSize(width: 150, height: 100)
            case .medium:
                return CGSize(width: 200, height: 150)
            case .large:
                return CGSize(width: 280, height: 200)
            case .wide:
                return CGSize(width: 320, height: 120)
            case .tall:
                return CGSize(width: 180, height: 240)
            }
        }
    }
    
    // MARK: - Properties
    
    private var backgroundNode: SKShapeNode!
    private var borderNode: SKShapeNode!
    private var shadowNode: SKShapeNode!
    private var titleLabel: SKLabelNode!
    private var valueLabel: SKLabelNode!
    private var subtitleLabel: SKLabelNode?
    private var iconLabel: SKLabelNode?
    private var progressBar: ProgressBarNode?
    private var glowNode: SKShapeNode?
    
    private let cardSize: CGSize
    private let cardStyle: CardStyle
    private let cornerRadius: CGFloat
    private var isInteractive: Bool = false
    
    // Callbacks
    var onTap: (() -> Void)?
    
    // MARK: - Initialization
    
    init(
        title: String,
        value: String = "",
        style: CardStyle = .stats,
        size: CardSize = .medium,
        icon: String? = nil,
        subtitle: String? = nil,
        cornerRadius: CGFloat = 20,
        interactive: Bool = false
    ) {
        self.cardSize = size.size
        self.cardStyle = style
        self.cornerRadius = cornerRadius
        self.isInteractive = interactive
        
        super.init()
        
        setupCard(title: title, value: value, icon: icon, subtitle: subtitle)
        
        if interactive {
            setupInteraction()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupCard(title: String, value: String, icon: String?, subtitle: String?) {
        // Create shadow
        createShadow()
        
        // Create background
        createBackground()
        
        // Create border
        createBorder()
        
        // Create title
        createTitle(title)
        
        // Create value
        if !value.isEmpty {
            createValue(value)
        }
        
        // Create icon if provided
        if let iconText = icon {
            createIcon(iconText)
        }
        
        // Create subtitle if provided
        if let subtitleText = subtitle {
            createSubtitle(subtitleText)
        }
        
        // Create glow effect (initially hidden)
        createGlow()
        
        // Setup accessibility
        setupAccessibility(title: title, value: value)
    }
    
    private func createShadow() {
        let shadowPath = UIBezierPath(
            roundedRect: CGRect(
                origin: CGPoint(x: -cardSize.width/2, y: -cardSize.height/2),
                size: cardSize
            ),
            cornerRadius: cornerRadius
        )
        
        shadowNode = SKShapeNode(path: shadowPath.cgPath)
        shadowNode.fillColor = SpriteKitColors.UI.cardShadow
        shadowNode.strokeColor = .clear
        shadowNode.position = CGPoint(x: 0, y: -6)
        shadowNode.zPosition = -3
        addChild(shadowNode)
    }
    
    private func createBackground() {
        let backgroundPath = UIBezierPath(
            roundedRect: CGRect(
                origin: CGPoint(x: -cardSize.width/2, y: -cardSize.height/2),
                size: cardSize
            ),
            cornerRadius: cornerRadius
        )
        
        backgroundNode = SKShapeNode(path: backgroundPath.cgPath)
        backgroundNode.fillColor = cardStyle.colors.background
        backgroundNode.strokeColor = .clear
        backgroundNode.zPosition = -2
        addChild(backgroundNode)
    }
    
    private func createBorder() {
        let borderPath = UIBezierPath(
            roundedRect: CGRect(
                origin: CGPoint(x: -cardSize.width/2, y: -cardSize.height/2),
                size: cardSize
            ),
            cornerRadius: cornerRadius
        )
        
        borderNode = SKShapeNode(path: borderPath.cgPath)
        borderNode.fillColor = .clear
        borderNode.strokeColor = cardStyle.colors.border
        borderNode.lineWidth = 2
        borderNode.zPosition = -1
        addChild(borderNode)
    }
    
    private func createTitle(_ title: String) {
        titleLabel = SKLabelNode(text: title)
        titleLabel.fontName = "Baloo2-VariableFont_wght"
        titleLabel.fontSize = 18
        titleLabel.fontColor = cardStyle.colors.text
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: cardSize.height/4)
        titleLabel.zPosition = 1
        addChild(titleLabel)
    }
    
    private func createValue(_ value: String) {
        valueLabel = SKLabelNode(text: value)
        valueLabel.fontName = "Baloo2-VariableFont_wght"
        valueLabel.fontSize = 24
        valueLabel.fontColor = cardStyle.colors.accent
        valueLabel.horizontalAlignmentMode = .center
        valueLabel.verticalAlignmentMode = .center
        valueLabel.position = CGPoint(x: 0, y: -cardSize.height/6)
        valueLabel.zPosition = 1
        addChild(valueLabel)
    }
    
    private func createIcon(_ iconText: String) {
        iconLabel = SKLabelNode(text: iconText)
        iconLabel?.fontSize = 32
        iconLabel?.horizontalAlignmentMode = .center
        iconLabel?.verticalAlignmentMode = .center
        iconLabel?.position = CGPoint(x: 0, y: cardSize.height/6)
        iconLabel?.zPosition = 1
        
        if let icon = iconLabel {
            addChild(icon)
            
            // Adjust title position to make room for icon
            titleLabel.position = CGPoint(x: 0, y: cardSize.height/8)
        }
    }
    
    private func createSubtitle(_ subtitle: String) {
        subtitleLabel = SKLabelNode(text: subtitle)
        subtitleLabel?.fontName = "Baloo2-VariableFont_wght"
        subtitleLabel?.fontSize = 14
        subtitleLabel?.fontColor = cardStyle.colors.text.withAlphaComponent(0.8)
        subtitleLabel?.horizontalAlignmentMode = .center
        subtitleLabel?.verticalAlignmentMode = .center
        subtitleLabel?.position = CGPoint(x: 0, y: -cardSize.height/3)
        subtitleLabel?.zPosition = 1
        
        if let subtitle = subtitleLabel {
            addChild(subtitle)
        }
    }
    
    private func createGlow() {
        let glowPath = UIBezierPath(
            roundedRect: CGRect(
                origin: CGPoint(x: -cardSize.width/2 - 4, y: -cardSize.height/2 - 4),
                size: CGSize(width: cardSize.width + 8, height: cardSize.height + 8)
            ),
            cornerRadius: cornerRadius + 4
        )
        
        glowNode = SKShapeNode(path: glowPath.cgPath)
        glowNode?.fillColor = .clear
        glowNode?.strokeColor = cardStyle.colors.accent.withAlphaComponent(0.6)
        glowNode?.lineWidth = 4
        glowNode?.zPosition = -0.5
        glowNode?.alpha = 0
        addChild(glowNode!)
    }
    
    private func setupAccessibility(title: String, value: String) {
        accessibilityLabel = "\(title): \(value)"
        if isInteractive {
            accessibilityTraits = .button
            accessibilityHint = "Double tap to interact"
        }
    }
    
    private func setupInteraction() {
        isUserInteractionEnabled = true
        
        // Add subtle breathing animation for interactive cards
        let breathe = SKAction.sequence([
            SKAction.scale(to: 1.02, duration: 3.0),
            SKAction.scale(to: 0.98, duration: 3.0)
        ])
        let breatheForever = SKAction.repeatForever(breathe)
        run(breatheForever, withKey: "breathing")
    }
    
    // MARK: - Public Methods
    
    func updateTitle(_ title: String) {
        titleLabel.text = title
        accessibilityLabel = "\(title): \(valueLabel?.text ?? "")"
    }
    
    func updateValue(_ value: String, animated: Bool = true) {
        if animated {
            let fadeOut = SKAction.fadeOut(withDuration: 0.2)
            let fadeIn = SKAction.fadeIn(withDuration: 0.2)
            let updateText = SKAction.run {
                self.valueLabel.text = value
            }
            let sequence = SKAction.sequence([fadeOut, updateText, fadeIn])
            valueLabel.run(sequence)
        } else {
            valueLabel.text = value
        }
        
        accessibilityLabel = "\(titleLabel.text ?? ""): \(value)"
    }
    
    func updateSubtitle(_ subtitle: String) {
        subtitleLabel?.text = subtitle
    }
    
    func updateIcon(_ icon: String) {
        iconLabel?.text = icon
    }
    
    func addProgressBar(progress: CGFloat = 0.0) {
        if progressBar == nil {
            let progressSize = CGSize(width: cardSize.width * 0.8, height: 8)
            progressBar = ProgressBarNode(
                size: progressSize,
                progress: progress,
                style: .standard,
                progressColor: .custom(cardStyle.colors.accent),
                backgroundColor: cardStyle.colors.text.withAlphaComponent(0.3)
            )
            progressBar?.position = CGPoint(x: 0, y: -cardSize.height/2 + 20)
            progressBar?.zPosition = 1
            addChild(progressBar!)
        }
    }
    
    func updateProgress(_ progress: CGFloat, animated: Bool = true) {
        progressBar?.updateProgress(to: progress, animated: animated)
    }
    
    func showGlow(animated: Bool = true) {
        guard let glow = glowNode else { return }
        
        if animated {
            let glowAction = SKAction.fadeIn(withDuration: 0.3)
            glow.run(glowAction)
        } else {
            glow.alpha = 1.0
        }
    }
    
    func hideGlow(animated: Bool = true) {
        guard let glow = glowNode else { return }
        
        if animated {
            let glowAction = SKAction.fadeOut(withDuration: 0.3)
            glow.run(glowAction)
        } else {
            glow.alpha = 0.0
        }
    }
    
    func pulse() {
        let pulseSequence = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.15),
            SKAction.scale(to: 1.0, duration: 0.15)
        ])
        run(pulseSequence)
    }
    
    func celebrateValue() {
        // Animate the value with a celebration effect
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let colorChange = SKAction.colorize(with: cardStyle.colors.accent, colorBlendFactor: 1.0, duration: 0.2)
        let colorRevert = SKAction.colorize(with: cardStyle.colors.accent, colorBlendFactor: 1.0, duration: 0.2)
        
        let celebrateSequence = SKAction.sequence([
            SKAction.group([scaleUp, colorChange]),
            SKAction.group([scaleDown, colorRevert])
        ])
        
        valueLabel.run(celebrateSequence)
        
        // Show temporary glow
        showGlow()
        let hideGlowAction = SKAction.run { [weak self] in
            self?.hideGlow()
        }
        run(SKAction.sequence([SKAction.wait(forDuration: 0.5), hideGlowAction]))
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isInteractive else { return }
        
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        run(scaleDown)
        
        SpriteKitSoundManager.shared.playSound(.buttonTap)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isInteractive else { return }
        
        // Check if touch ended inside card
        if let touch = touches.first {
            let location = touch.location(in: self)
            let cardRect = CGRect(
                origin: CGPoint(x: -cardSize.width/2, y: -cardSize.height/2),
                size: cardSize
            )
            
            if cardRect.contains(location) {
                onTap?()
                pulse()
            }
        }
        
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        run(scaleUp)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isInteractive else { return }
        
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        run(scaleUp)
    }
}

// MARK: - Convenience Extensions

extension InfoCardNode {
    
    /// Create a stats card
    static func statsCard(title: String, value: String, icon: String? = nil) -> InfoCardNode {
        return InfoCardNode(
            title: title,
            value: value,
            style: .stats,
            size: .medium,
            icon: icon
        )
    }
    
    /// Create an achievement card
    static func achievementCard(title: String, subtitle: String? = nil, icon: String = "🏆") -> InfoCardNode {
        return InfoCardNode(
            title: title,
            style: .achievement,
            size: .medium,
            icon: icon,
            subtitle: subtitle
        )
    }
    
    /// Create a level card
    static func levelCard(title: String, stars: Int, interactive: Bool = true, action: (() -> Void)? = nil) -> InfoCardNode {
        let starsText = String(repeating: "⭐", count: stars) + String(repeating: "☆", count: 3 - stars)
        let card = InfoCardNode(
            title: title,
            value: starsText,
            style: .level,
            size: .medium,
            interactive: interactive
        )
        card.onTap = action
        return card
    }
    
    /// Create a progress card with progress bar
    static func progressCard(title: String, progress: CGFloat, subtitle: String? = nil) -> InfoCardNode {
        let card = InfoCardNode(
            title: title,
            value: "\(Int(progress * 100))%",
            style: .progress,
            size: .wide,
            subtitle: subtitle
        )
        card.addProgressBar(progress: progress)
        return card
    }
    
    /// Create a score card
    static func scoreCard(title: String = "Score", score: Int, icon: String = "🎯") -> InfoCardNode {
        return InfoCardNode(
            title: title,
            value: "\(score)",
            style: .score,
            size: .medium,
            icon: icon
        )
    }
}
