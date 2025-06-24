//
//  SpriteKitTextStyles.swift
//  NumberQuest
//
//  Created by TaiPV on 24/6/25.
//

import SpriteKit
import UIKit

// MARK: - SpriteKit Text Style System

/// Comprehensive text styling system for SpriteKit
/// Converts SwiftUI TextStyles to SpriteKit-compatible formatting with enhanced features
struct SpriteKitTextStyle {
    
    // MARK: - Core Properties
    let fontName: String
    let fontSize: CGFloat
    let fontColor: UIColor
    let alignment: SKLabelHorizontalAlignmentMode
    let verticalAlignment: SKLabelVerticalAlignmentMode
    
    // MARK: - Enhanced Effects
    let shadowColor: UIColor?
    let shadowOffset: CGPoint
    let shadowBlurRadius: CGFloat
    let outlineColor: UIColor?
    let outlineWidth: CGFloat
    let glowColor: UIColor?
    let glowRadius: CGFloat
    
    // MARK: - Animation Properties
    let animationScale: CGFloat
    let animationDuration: TimeInterval
    let bounceIntensity: CGFloat
    
    // MARK: - Responsive Properties
    let responsiveScaling: Bool
    let minimumFontSize: CGFloat
    let maximumFontSize: CGFloat
    
    init(
        fontName: String = SpriteKitTextStyle.defaultFontName,
        fontSize: CGFloat,
        fontColor: UIColor = .white,
        alignment: SKLabelHorizontalAlignmentMode = .center,
        verticalAlignment: SKLabelVerticalAlignmentMode = .center,
        shadowColor: UIColor? = nil,
        shadowOffset: CGPoint = CGPoint(x: 2, y: -2),
        shadowBlurRadius: CGFloat = 0,
        outlineColor: UIColor? = nil,
        outlineWidth: CGFloat = 0,
        glowColor: UIColor? = nil,
        glowRadius: CGFloat = 0,
        animationScale: CGFloat = 1.0,
        animationDuration: TimeInterval = 0.3,
        bounceIntensity: CGFloat = 1.1,
        responsiveScaling: Bool = true,
        minimumFontSize: CGFloat = 10,
        maximumFontSize: CGFloat = 200
    ) {
        self.fontName = fontName
        self.fontSize = fontSize
        self.fontColor = fontColor
        self.alignment = alignment
        self.verticalAlignment = verticalAlignment
        self.shadowColor = shadowColor
        self.shadowOffset = shadowOffset
        self.shadowBlurRadius = shadowBlurRadius
        self.outlineColor = outlineColor
        self.outlineWidth = outlineWidth
        self.glowColor = glowColor
        self.glowRadius = glowRadius
        self.animationScale = animationScale
        self.animationDuration = animationDuration
        self.bounceIntensity = bounceIntensity
        self.responsiveScaling = responsiveScaling
        self.minimumFontSize = minimumFontSize
        self.maximumFontSize = maximumFontSize
    }
}

// MARK: - Font Configuration
extension SpriteKitTextStyle {
    
    /// Primary custom font name
    static var defaultFontName: String {
        return "Baloo2-VariableFont_wght"
    }
    
    /// Secondary font for special text
    static var secondaryFontName: String {
        return "Chewy-Regular"
    }
    
    /// System font fallback
    static var systemFontName: String {
        return "Helvetica Neue"
    }
    
    /// Get responsive font size based on device
    func responsiveFontSize() -> CGFloat {
        guard responsiveScaling else { return fontSize }
        
        let scaledSize = CoordinateSystem.responsiveFontSize(base: fontSize)
        return max(minimumFontSize, min(maximumFontSize, scaledSize))
    }
    
    /// Get font name with fallback logic
    var safeFontName: String {
        // Check if custom font is available
        if UIFont(name: fontName, size: 12) != nil {
            return fontName
        }
        
        // Try secondary font
        if UIFont(name: Self.secondaryFontName, size: 12) != nil {
            return Self.secondaryFontName
        }
        
        // Fall back to system font
        return Self.systemFontName
    }
}

// MARK: - Predefined Styles
extension SpriteKitTextStyle {
    
    // MARK: - Title Styles
    static let gameTitle = SpriteKitTextStyle(
        fontSize: 42,
        fontColor: .white,
        shadowColor: UIColor.black.withAlphaComponent(0.5),
        shadowOffset: CGPoint(x: 3, y: -3),
        glowColor: UIColor.yellow.withAlphaComponent(0.3),
        glowRadius: 5,
        animationScale: 1.2,
        bounceIntensity: 1.3
    )
    
    static let title = SpriteKitTextStyle(
        fontSize: 28,
        fontColor: .white,
        shadowColor: UIColor.black.withAlphaComponent(0.4),
        shadowOffset: CGPoint(x: 2, y: -2),
        bounceIntensity: 1.15
    )
    
    static let subtitle = SpriteKitTextStyle(
        fontSize: 22,
        fontColor: .white,
        shadowColor: UIColor.black.withAlphaComponent(0.3),
        shadowOffset: CGPoint(x: 1, y: -1)
    )
    
    static let heading = SpriteKitTextStyle(
        fontSize: 18,
        fontColor: .white,
        shadowColor: UIColor.black.withAlphaComponent(0.2)
    )
    
    // MARK: - Body Text Styles
    static let body = SpriteKitTextStyle(
        fontSize: 16,
        fontColor: UIColor.white.withAlphaComponent(0.9)
    )
    
    static let bodySecondary = SpriteKitTextStyle(
        fontSize: 16,
        fontColor: UIColor.white.withAlphaComponent(0.8)
    )
    
    static let caption = SpriteKitTextStyle(
        fontSize: 14,
        fontColor: UIColor.white.withAlphaComponent(0.7)
    )
    
    static let smallCaption = SpriteKitTextStyle(
        fontSize: 12,
        fontColor: UIColor.white.withAlphaComponent(0.6)
    )
    
    // MARK: - Button Text Styles
    static let buttonLarge = SpriteKitTextStyle(
        fontSize: 20,
        fontColor: .white,
        shadowColor: UIColor.black.withAlphaComponent(0.3),
        shadowOffset: CGPoint(x: 1, y: -1),
        animationScale: 1.05,
        bounceIntensity: 1.2
    )
    
    static let buttonMedium = SpriteKitTextStyle(
        fontSize: 18,
        fontColor: .white,
        shadowColor: UIColor.black.withAlphaComponent(0.3),
        shadowOffset: CGPoint(x: 1, y: -1),
        animationScale: 1.05,
        bounceIntensity: 1.15
    )
    
    static let buttonSmall = SpriteKitTextStyle(
        fontSize: 16,
        fontColor: .white,
        shadowColor: UIColor.black.withAlphaComponent(0.3),
        shadowOffset: CGPoint(x: 1, y: -1),
        animationScale: 1.03,
        bounceIntensity: 1.1
    )
    
    // MARK: - Game-specific Styles
    static let questionText = SpriteKitTextStyle(
        fontSize: 32,
        fontColor: .white,
        shadowColor: UIColor.black.withAlphaComponent(0.4),
        shadowOffset: CGPoint(x: 2, y: -2),
        glowColor: UIColor.cyan.withAlphaComponent(0.2),
        glowRadius: 3,
        animationScale: 1.1,
        bounceIntensity: 1.2
    )
    
    static let answerText = SpriteKitTextStyle(
        fontSize: 24,
        fontColor: .white,
        shadowColor: UIColor.black.withAlphaComponent(0.3),
        shadowOffset: CGPoint(x: 1, y: -1),
        animationScale: 1.08,
        bounceIntensity: 1.15
    )
    
    static let scoreText = SpriteKitTextStyle(
        fontSize: 20,
        fontColor: UIColor.yellow,
        shadowColor: UIColor.black.withAlphaComponent(0.4),
        shadowOffset: CGPoint(x: 1, y: -1),
        glowColor: UIColor.yellow.withAlphaComponent(0.3),
        glowRadius: 2,
        animationScale: 1.2,
        bounceIntensity: 1.3
    )
    
    static let timerText = SpriteKitTextStyle(
        fontSize: 18,
        fontColor: .white,
        shadowColor: UIColor.black.withAlphaComponent(0.3),
        shadowOffset: CGPoint(x: 1, y: -1)
    )
    
    // MARK: - Special Effect Styles
    static let correctAnswer = SpriteKitTextStyle(
        fontSize: 28,
        fontColor: UIColor.systemGreen,
        shadowColor: UIColor.black.withAlphaComponent(0.4),
        shadowOffset: CGPoint(x: 2, y: -2),
        glowColor: UIColor.green.withAlphaComponent(0.5),
        glowRadius: 8,
        animationScale: 1.5,
        bounceIntensity: 1.8
    )
    
    static let wrongAnswer = SpriteKitTextStyle(
        fontSize: 28,
        fontColor: UIColor.systemRed,
        shadowColor: UIColor.black.withAlphaComponent(0.4),
        shadowOffset: CGPoint(x: 2, y: -2),
        glowColor: UIColor.red.withAlphaComponent(0.5),
        glowRadius: 8,
        animationScale: 1.3,
        bounceIntensity: 1.4
    )
    
    static let celebration = SpriteKitTextStyle(
        fontSize: 36,
        fontColor: UIColor.systemYellow,
        shadowColor: UIColor.black.withAlphaComponent(0.5),
        shadowOffset: CGPoint(x: 3, y: -3),
        glowColor: UIColor.yellow.withAlphaComponent(0.8),
        glowRadius: 12,
        animationScale: 2.0,
        animationDuration: 0.8,
        bounceIntensity: 2.5
    )
    
    // MARK: - Outline Styles
    static let outlineWhite = SpriteKitTextStyle(
        fontSize: 24,
        fontColor: .white,
        outlineColor: UIColor.black,
        outlineWidth: 2
    )
    
    static let outlineBlack = SpriteKitTextStyle(
        fontSize: 24,
        fontColor: .black,
        outlineColor: UIColor.white,
        outlineWidth: 2
    )
}

// MARK: - Style Variants
extension SpriteKitTextStyle {
    
    /// Create a variant with different color
    func withColor(_ color: UIColor) -> SpriteKitTextStyle {
        return SpriteKitTextStyle(
            fontName: fontName,
            fontSize: fontSize,
            fontColor: color,
            alignment: alignment,
            verticalAlignment: verticalAlignment,
            shadowColor: shadowColor,
            shadowOffset: shadowOffset,
            shadowBlurRadius: shadowBlurRadius,
            outlineColor: outlineColor,
            outlineWidth: outlineWidth,
            glowColor: glowColor,
            glowRadius: glowRadius,
            animationScale: animationScale,
            animationDuration: animationDuration,
            bounceIntensity: bounceIntensity,
            responsiveScaling: responsiveScaling,
            minimumFontSize: minimumFontSize,
            maximumFontSize: maximumFontSize
        )
    }
    
    /// Create a variant with different size
    func withSize(_ size: CGFloat) -> SpriteKitTextStyle {
        return SpriteKitTextStyle(
            fontName: fontName,
            fontSize: size,
            fontColor: fontColor,
            alignment: alignment,
            verticalAlignment: verticalAlignment,
            shadowColor: shadowColor,
            shadowOffset: shadowOffset,
            shadowBlurRadius: shadowBlurRadius,
            outlineColor: outlineColor,
            outlineWidth: outlineWidth,
            glowColor: glowColor,
            glowRadius: glowRadius,
            animationScale: animationScale,
            animationDuration: animationDuration,
            bounceIntensity: bounceIntensity,
            responsiveScaling: responsiveScaling,
            minimumFontSize: minimumFontSize,
            maximumFontSize: maximumFontSize
        )
    }
    
    /// Create a variant with opacity
    func withOpacity(_ opacity: CGFloat) -> SpriteKitTextStyle {
        return withColor(fontColor.withAlphaComponent(opacity))
    }
    
    /// Create a variant with shadow
    func withShadow(color: UIColor, offset: CGPoint = CGPoint(x: 2, y: -2), blur: CGFloat = 0) -> SpriteKitTextStyle {
        return SpriteKitTextStyle(
            fontName: fontName,
            fontSize: fontSize,
            fontColor: fontColor,
            alignment: alignment,
            verticalAlignment: verticalAlignment,
            shadowColor: color,
            shadowOffset: offset,
            shadowBlurRadius: blur,
            outlineColor: outlineColor,
            outlineWidth: outlineWidth,
            glowColor: glowColor,
            glowRadius: glowRadius,
            animationScale: animationScale,
            animationDuration: animationDuration,
            bounceIntensity: bounceIntensity,
            responsiveScaling: responsiveScaling,
            minimumFontSize: minimumFontSize,
            maximumFontSize: maximumFontSize
        )
    }
    
    /// Create a variant with glow effect
    func withGlow(color: UIColor, radius: CGFloat = 5) -> SpriteKitTextStyle {
        return SpriteKitTextStyle(
            fontName: fontName,
            fontSize: fontSize,
            fontColor: fontColor,
            alignment: alignment,
            verticalAlignment: verticalAlignment,
            shadowColor: shadowColor,
            shadowOffset: shadowOffset,
            shadowBlurRadius: shadowBlurRadius,
            outlineColor: outlineColor,
            outlineWidth: outlineWidth,
            glowColor: color,
            glowRadius: radius,
            animationScale: animationScale,
            animationDuration: animationDuration,
            bounceIntensity: bounceIntensity,
            responsiveScaling: responsiveScaling,
            minimumFontSize: minimumFontSize,
            maximumFontSize: maximumFontSize
        )
    }
    
    /// Create a variant with outline
    func withOutline(color: UIColor, width: CGFloat = 2) -> SpriteKitTextStyle {
        return SpriteKitTextStyle(
            fontName: fontName,
            fontSize: fontSize,
            fontColor: fontColor,
            alignment: alignment,
            verticalAlignment: verticalAlignment,
            shadowColor: shadowColor,
            shadowOffset: shadowOffset,
            shadowBlurRadius: shadowBlurRadius,
            outlineColor: color,
            outlineWidth: width,
            glowColor: glowColor,
            glowRadius: glowRadius,
            animationScale: animationScale,
            animationDuration: animationDuration,
            bounceIntensity: bounceIntensity,
            responsiveScaling: responsiveScaling,
            minimumFontSize: minimumFontSize,
            maximumFontSize: maximumFontSize
        )
    }
}

// MARK: - Enhanced Label Node
class EnhancedLabelNode: SKLabelNode {
    
    private var style: SpriteKitTextStyle
    private var shadowNode: SKLabelNode?
    private var outlineNodes: [SKLabelNode] = []
    private var glowNode: SKLabelNode?
    
    // MARK: - Initialization
    init(text: String, style: SpriteKitTextStyle) {
        self.style = style
        super.init()
        
        self.text = text
        applyStyle()
        setupEffects()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Style Application
    private func applyStyle() {
        fontName = style.safeFontName
        fontSize = style.responsiveFontSize()
        fontColor = style.fontColor
        horizontalAlignmentMode = style.alignment
        verticalAlignmentMode = style.verticalAlignment
        zPosition = 10
    }
    
    private func setupEffects() {
        // Remove existing effects
        shadowNode?.removeFromParent()
        outlineNodes.forEach { $0.removeFromParent() }
        glowNode?.removeFromParent()
        
        shadowNode = nil
        outlineNodes.removeAll()
        glowNode = nil
        
        // Add shadow effect
        if let shadowColor = style.shadowColor {
            createShadow(color: shadowColor, offset: style.shadowOffset)
        }
        
        // Add outline effect
        if let outlineColor = style.outlineColor, style.outlineWidth > 0 {
            createOutline(color: outlineColor, width: style.outlineWidth)
        }
        
        // Add glow effect
        if let glowColor = style.glowColor, style.glowRadius > 0 {
            createGlow(color: glowColor, radius: style.glowRadius)
        }
    }
    
    private func createShadow(color: UIColor, offset: CGPoint) {
        shadowNode = SKLabelNode(text: text)
        shadowNode?.fontName = fontName
        shadowNode?.fontSize = fontSize
        shadowNode?.fontColor = color
        shadowNode?.horizontalAlignmentMode = horizontalAlignmentMode
        shadowNode?.verticalAlignmentMode = verticalAlignmentMode
        shadowNode?.position = offset
        shadowNode?.zPosition = zPosition - 1
        
        if let shadowNode = shadowNode {
            addChild(shadowNode)
        }
    }
    
    private func createOutline(color: UIColor, width: CGFloat) {
        let offsets = [
            CGPoint(x: -width, y: -width),
            CGPoint(x: 0, y: -width),
            CGPoint(x: width, y: -width),
            CGPoint(x: -width, y: 0),
            CGPoint(x: width, y: 0),
            CGPoint(x: -width, y: width),
            CGPoint(x: 0, y: width),
            CGPoint(x: width, y: width)
        ]
        
        for offset in offsets {
            let outlineNode = SKLabelNode(text: text)
            outlineNode.fontName = fontName
            outlineNode.fontSize = fontSize
            outlineNode.fontColor = color
            outlineNode.horizontalAlignmentMode = horizontalAlignmentMode
            outlineNode.verticalAlignmentMode = verticalAlignmentMode
            outlineNode.position = offset
            outlineNode.zPosition = zPosition - 2
            
            outlineNodes.append(outlineNode)
            addChild(outlineNode)
        }
    }
    
    private func createGlow(color: UIColor, radius: CGFloat) {
        glowNode = SKLabelNode(text: text)
        glowNode?.fontName = fontName
        glowNode?.fontSize = fontSize
        glowNode?.fontColor = color
        glowNode?.horizontalAlignmentMode = horizontalAlignmentMode
        glowNode?.verticalAlignmentMode = verticalAlignmentMode
        glowNode?.zPosition = zPosition - 3
        
        // Create glow effect using blur (simplified version)
        glowNode?.alpha = 0.6
        glowNode?.setScale(1.1)
        
        if let glowNode = glowNode {
            addChild(glowNode)
            
            // Animate glow
            let pulse = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.3, duration: 1.0),
                SKAction.fadeAlpha(to: 0.6, duration: 1.0)
            ])
            glowNode.run(SKAction.repeatForever(pulse))
        }
    }
    
    // MARK: - Text Updates
    override var text: String? {
        didSet {
            updateEffectText()
        }
    }
    
    private func updateEffectText() {
        shadowNode?.text = text
        outlineNodes.forEach { $0.text = text }
        glowNode?.text = text
    }
    
    // MARK: - Animation Methods
    func animateEntrance() {
        alpha = 0
        setScale(0.3)
        
        let fadeIn = SKAction.fadeIn(withDuration: style.animationDuration)
        let scaleUp = SKAction.scale(to: 1.0, duration: style.animationDuration)
        let entrance = SKAction.group([fadeIn, scaleUp])
        entrance.timingMode = .easeOut
        
        run(entrance)
    }
    
    func animateBounce() {
        let originalScale = xScale
        let bounceScale = originalScale * style.bounceIntensity
        
        let scaleUp = SKAction.scale(to: bounceScale, duration: style.animationDuration * 0.4)
        let scaleDown = SKAction.scale(to: originalScale, duration: style.animationDuration * 0.6)
        
        scaleUp.timingMode = .easeOut
        scaleDown.timingMode = .easeInEaseOut
        
        let bounce = SKAction.sequence([scaleUp, scaleDown])
        run(bounce)
    }
    
    func animatePulse() {
        let originalScale = xScale
        let pulseScale = originalScale * style.animationScale
        
        let scaleUp = SKAction.scale(to: pulseScale, duration: style.animationDuration * 0.5)
        let scaleDown = SKAction.scale(to: originalScale, duration: style.animationDuration * 0.5)
        
        scaleUp.timingMode = .easeInEaseOut
        scaleDown.timingMode = .easeInEaseOut
        
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        run(SKAction.repeatForever(pulse))
    }
    
    func animateColorChange(to color: UIColor, duration: TimeInterval = 0.3) {
        let colorAction = SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: duration)
        run(colorAction)
    }
    
    func animateFloatingText(direction: CGVector = CGVector(dx: 0, dy: 50), duration: TimeInterval = 1.0) {
        let move = SKAction.move(by: direction, duration: duration)
        let fade = SKAction.fadeOut(withDuration: duration)
        let float = SKAction.group([move, fade])
        
        run(float) { [weak self] in
            self?.removeFromParent()
        }
    }
}

// MARK: - Factory Extensions
extension SpriteKitTextStyle {
    
    /// Create an enhanced label node with this style
    func createLabel(text: String) -> EnhancedLabelNode {
        return EnhancedLabelNode(text: text, style: self)
    }
    
    /// Create a standard SKLabelNode with basic styling
    func createSimpleLabel(text: String) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        label.fontName = safeFontName
        label.fontSize = responsiveFontSize()
        label.fontColor = fontColor
        label.horizontalAlignmentMode = alignment
        label.verticalAlignmentMode = verticalAlignment
        return label
    }
}

// MARK: - Dynamic Text Sizing
extension SpriteKitTextStyle {
    
    /// Calculate optimal font size for given constraints
    static func optimalFontSize(
        for text: String,
        in bounds: CGSize,
        style: SpriteKitTextStyle,
        minimumSize: CGFloat = 8,
        maximumSize: CGFloat = 100
    ) -> CGFloat {
        
        var testSize = style.fontSize
        let testLabel = SKLabelNode(text: text)
        testLabel.fontName = style.safeFontName
        
        // Binary search for optimal size
        var minSize = minimumSize
        var maxSize = min(maximumSize, style.fontSize * 2)
        
        while maxSize - minSize > 1 {
            testSize = (minSize + maxSize) / 2
            testLabel.fontSize = testSize
            
            let labelSize = testLabel.frame.size
            
            if labelSize.width <= bounds.width && labelSize.height <= bounds.height {
                minSize = testSize
            } else {
                maxSize = testSize
            }
        }
        
        return minSize
    }
}
