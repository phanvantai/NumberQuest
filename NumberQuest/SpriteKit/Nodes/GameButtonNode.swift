//
//  GameButtonNode.swift
//  NumberQuest
//
//  Created by TaiPV on 24/6/25.
//

import SpriteKit
import UIKit

/// Enhanced game button with visual effects, animations, and multiple styles
class GameButtonNode: SKNode {
    
    // MARK: - Types
    
    enum ButtonStyle {
        case primary
        case secondary
        case success
        case warning
        case danger
        case campaign
        case quickPlay
        case settings
        case back
        case toggle
        case selector
        case destructive
        
        var colors: (normal: UIColor, pressed: UIColor, text: UIColor) {
            switch self {
            case .primary:
                return (SpriteKitColors.UI.primaryButton, SpriteKitColors.UI.primaryButtonPressed, SpriteKitColors.UI.onPrimary)
            case .secondary:
                return (SpriteKitColors.UI.secondaryButton, SpriteKitColors.UI.secondaryButtonPressed, SpriteKitColors.UI.onPrimary)
            case .success:
                return (SpriteKitColors.UI.successButton, SpriteKitColors.UI.successButton.withAlphaComponent(0.7), SpriteKitColors.UI.onSuccess)
            case .warning:
                return (SpriteKitColors.UI.warningButton, SpriteKitColors.UI.warningButton.withAlphaComponent(0.7), SpriteKitColors.UI.onWarning)
            case .danger:
                return (SpriteKitColors.UI.dangerButton, SpriteKitColors.UI.dangerButton.withAlphaComponent(0.7), SpriteKitColors.UI.onDanger)
            case .campaign:
                return (UIColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 0.9), UIColor(red: 0.1, green: 0.6, blue: 0.2, alpha: 0.9), .white)
            case .quickPlay:
                return (UIColor(red: 1.0, green: 0.6, blue: 0.1, alpha: 0.9), UIColor(red: 0.9, green: 0.5, blue: 0.0, alpha: 0.9), .white)
            case .settings:
                return (UIColor(red: 0.5, green: 0.5, blue: 0.6, alpha: 0.9), UIColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 0.9), .white)
            case .back:
                return (UIColor(red: 0.3, green: 0.3, blue: 0.4, alpha: 0.8), UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 0.8), .white)
            case .toggle:
                return (UIColor(red: 0.2, green: 0.6, blue: 0.9, alpha: 0.9), UIColor(red: 0.1, green: 0.5, blue: 0.8, alpha: 0.9), .white)
            case .selector:
                return (UIColor(red: 0.6, green: 0.4, blue: 0.8, alpha: 0.9), UIColor(red: 0.5, green: 0.3, blue: 0.7, alpha: 0.9), .white)
            case .destructive:
                return (UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 0.9), UIColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 0.9), .white)
            }
        }
    }
    
    enum ButtonSize {
        case small
        case medium
        case large
        case extraLarge
        
        var size: CGSize {
            switch self {
            case .small:
                return CGSize(width: 120, height: 50)
            case .medium:
                return CGSize(width: 200, height: 60)
            case .large:
                return CGSize(width: 280, height: 70)
            case .extraLarge:
                return CGSize(width: 320, height: 80)
            }
        }
        
        var fontSize: CGFloat {
            switch self {
            case .small:
                return 16
            case .medium:
                return 20
            case .large:
                return 24
            case .extraLarge:
                return 28
            }
        }
    }
    
    // MARK: - Properties
    
    private var backgroundNode: SKShapeNode!
    private var shadowNode: SKShapeNode!
    private var labelNode: SKLabelNode!
    private var iconNode: SKLabelNode?
    private var glowNode: SKShapeNode?
    
    private let buttonSize: CGSize
    private let buttonStyle: ButtonStyle
    private let cornerRadius: CGFloat
    private var isEnabled: Bool = true
    private var isPressed: Bool = false
    
    // Callbacks
    var onTap: (() -> Void)?
    var onTouchDown: (() -> Void)?
    var onTouchUp: (() -> Void)?
    
    // MARK: - Initialization
    
    init(
        text: String,
        style: ButtonStyle = .primary,
        size: ButtonSize = .medium,
        icon: String? = nil,
        cornerRadius: CGFloat = 15,
        action: (() -> Void)? = nil
    ) {
        self.buttonSize = size.size
        self.buttonStyle = style
        self.cornerRadius = cornerRadius
        self.onTap = action
        
        super.init()
        
        setupButton(text: text, fontSize: size.fontSize, icon: icon)
        setupAnimations()
    }
    
    convenience init(
        text: String,
        style: ButtonStyle = .primary,
        customSize: CGSize,
        icon: String? = nil,
        cornerRadius: CGFloat = 15,
        action: (() -> Void)? = nil
    ) {
        self.init(text: text, style: style, size: .medium, icon: icon, cornerRadius: cornerRadius, action: action)
        // Override size after initialization
        backgroundNode.path = UIBezierPath(roundedRect: CGRect(origin: CGPoint(x: -customSize.width/2, y: -customSize.height/2), size: customSize), cornerRadius: cornerRadius).cgPath
        shadowNode.path = backgroundNode.path
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupButton(text: String, fontSize: CGFloat, icon: String?) {
        isUserInteractionEnabled = true
        
        // Create shadow
        createShadow()
        
        // Create background
        createBackground()
        
        // Create label
        createLabel(text: text, fontSize: fontSize)
        
        // Create icon if provided
        if let iconText = icon {
            createIcon(iconText: iconText)
        }
        
        // Create glow effect (initially hidden)
        createGlow()
        
        // Setup accessibility
        setupAccessibility(text: text)
    }
    
    private func createShadow() {
        let shadowPath = UIBezierPath(
            roundedRect: CGRect(
                origin: CGPoint(x: -buttonSize.width/2, y: -buttonSize.height/2),
                size: buttonSize
            ),
            cornerRadius: cornerRadius
        )
        
        shadowNode = SKShapeNode(path: shadowPath.cgPath)
        shadowNode.fillColor = SpriteKitColors.UI.cardShadow
        shadowNode.strokeColor = .clear
        shadowNode.position = CGPoint(x: 0, y: -4)
        shadowNode.zPosition = -2
        addChild(shadowNode)
    }
    
    private func createBackground() {
        let backgroundPath = UIBezierPath(
            roundedRect: CGRect(
                origin: CGPoint(x: -buttonSize.width/2, y: -buttonSize.height/2),
                size: buttonSize
            ),
            cornerRadius: cornerRadius
        )
        
        backgroundNode = SKShapeNode(path: backgroundPath.cgPath)
        backgroundNode.fillColor = buttonStyle.colors.normal
        backgroundNode.strokeColor = .clear
        backgroundNode.zPosition = -1
        addChild(backgroundNode)
    }
    
    private func createLabel(text: String, fontSize: CGFloat) {
        labelNode = SKLabelNode(text: text)
        labelNode.fontName = "Baloo2-VariableFont_wght"
        labelNode.fontSize = fontSize
        labelNode.fontColor = buttonStyle.colors.text
        labelNode.horizontalAlignmentMode = .center
        labelNode.verticalAlignmentMode = .center
        labelNode.zPosition = 1
        addChild(labelNode)
    }
    
    private func createIcon(iconText: String) {
        iconNode = SKLabelNode(text: iconText)
        iconNode?.fontSize = labelNode.fontSize * 0.8
        iconNode?.fontColor = buttonStyle.colors.text
        iconNode?.horizontalAlignmentMode = .center
        iconNode?.verticalAlignmentMode = .center
        iconNode?.position = CGPoint(x: -labelNode.frame.width/2 - 20, y: 0)
        iconNode?.zPosition = 1
        
        if let icon = iconNode {
            addChild(icon)
            
            // Adjust label position to make room for icon
            labelNode.position = CGPoint(x: 10, y: 0)
        }
    }
    
    private func createGlow() {
        let glowPath = UIBezierPath(
            roundedRect: CGRect(
                origin: CGPoint(x: -buttonSize.width/2 - 4, y: -buttonSize.height/2 - 4),
                size: CGSize(width: buttonSize.width + 8, height: buttonSize.height + 8)
            ),
            cornerRadius: cornerRadius + 4
        )
        
        glowNode = SKShapeNode(path: glowPath.cgPath)
        glowNode?.fillColor = .clear
        glowNode?.strokeColor = buttonStyle.colors.normal.withAlphaComponent(0.6)
        glowNode?.lineWidth = 3
        glowNode?.zPosition = -0.5
        glowNode?.alpha = 0
        addChild(glowNode!)
    }
    
    private func setupAccessibility(text: String) {
        accessibilityLabel = text
        accessibilityTraits = .button
        accessibilityHint = "Double tap to activate"
    }
    
    private func setupAnimations() {
        // Idle breathing animation
        let breathe = SKAction.sequence([
            SKAction.scale(to: 1.02, duration: 2.0),
            SKAction.scale(to: 0.98, duration: 2.0)
        ])
        let breatheForever = SKAction.repeatForever(breathe)
        run(breatheForever, withKey: "breathing")
    }
    
    // MARK: - Public Methods
    
    func setText(_ text: String) {
        labelNode.text = text
    }
    
    func setEnabled(_ enabled: Bool) {
        isEnabled = enabled
        alpha = enabled ? 1.0 : 0.6
        isUserInteractionEnabled = enabled
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
            SKAction.scale(to: 1.1, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        run(pulseSequence)
    }
    
    func shake() {
        let shakeSequence = SKAction.sequence([
            SKAction.moveBy(x: -5, y: 0, duration: 0.05),
            SKAction.moveBy(x: 10, y: 0, duration: 0.05),
            SKAction.moveBy(x: -10, y: 0, duration: 0.05),
            SKAction.moveBy(x: 5, y: 0, duration: 0.05)
        ])
        run(shakeSequence)
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled, !isPressed else { return }
        
        isPressed = true
        onTouchDown?()
        
        // Visual feedback
        backgroundNode.fillColor = buttonStyle.colors.pressed
        
        // Scale animation
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        scaleDown.timingMode = .easeOut
        run(scaleDown)
        
        // Haptic feedback
        SpriteKitSoundManager.shared.playSound(.buttonTap)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isEnabled, isPressed else { return }
        
        isPressed = false
        onTouchUp?()
        
        // Check if touch ended inside button
        if let touch = touches.first {
            let location = touch.location(in: self)
            let buttonRect = CGRect(
                origin: CGPoint(x: -buttonSize.width/2, y: -buttonSize.height/2),
                size: buttonSize
            )
            
            if buttonRect.contains(location) {
                // Execute action
                onTap?()
                
                // Success visual feedback
                pulse()
            }
        }
        
        // Reset visual state
        backgroundNode.fillColor = buttonStyle.colors.normal
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        scaleUp.timingMode = .easeOut
        run(scaleUp)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isPressed else { return }
        
        isPressed = false
        
        // Reset visual state
        backgroundNode.fillColor = buttonStyle.colors.normal
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        scaleUp.timingMode = .easeOut
        run(scaleUp)
    }
    
    // MARK: - Dynamic Updates
    
    /// Update the button text
    /// - Parameter text: The new text to display
    func updateText(_ text: String) {
        labelNode.text = text
    }
    
    /// Update the button style
    /// - Parameter style: The new style to apply
    func setButtonStyle(_ style: ButtonStyle) {
        let colors = style.colors
        backgroundNode.fillColor = colors.normal
        labelNode.fontColor = colors.text
        shadowNode.fillColor = colors.normal.withAlphaComponent(0.3)
    }
    
    /// Update the button icon
    /// - Parameter icon: The new icon to display (emoji or symbol)
    func updateIcon(_ icon: String?) {
        if let icon = icon {
            if iconNode == nil {
                iconNode = SKLabelNode(text: icon)
                iconNode!.fontSize = buttonSize.height * 0.3
                iconNode!.fontName = "Arial"
                iconNode!.verticalAlignmentMode = .center
                iconNode!.position = CGPoint(x: -buttonSize.width/2 + 30, y: 0)
                iconNode!.zPosition = 2
                addChild(iconNode!)
                
                // Adjust label position to accommodate icon
                labelNode.position.x = 10
            } else {
                iconNode!.text = icon
            }
        } else {
            // Remove icon and center text
            iconNode?.removeFromParent()
            iconNode = nil
            labelNode.position.x = 0
        }
    }
}

// MARK: - Convenience Extensions

extension GameButtonNode {
    
    /// Create a campaign button
    static func campaignButton(text: String = "Campaign", action: (() -> Void)? = nil) -> GameButtonNode {
        return GameButtonNode(
            text: text,
            style: .campaign,
            size: .large,
            icon: "🗺️",
            action: action
        )
    }
    
    /// Create a quick play button
    static func quickPlayButton(text: String = "Quick Play", action: (() -> Void)? = nil) -> GameButtonNode {
        return GameButtonNode(
            text: text,
            style: .quickPlay,
            size: .large,
            icon: "⚡",
            action: action
        )
    }
    
    /// Create a back button
    static func backButton(action: (() -> Void)? = nil) -> GameButtonNode {
        return GameButtonNode(
            text: "Back",
            style: .back,
            size: .medium,
            icon: "←",
            action: action
        )
    }
    
    /// Create a start game button
    static func startButton(text: String = "Start Adventure", action: (() -> Void)? = nil) -> GameButtonNode {
        return GameButtonNode(
            text: text,
            style: .success,
            size: .large,
            action: action
        )
    }
}
