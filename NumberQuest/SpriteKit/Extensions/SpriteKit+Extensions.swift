//
//  SpriteKit+Extensions.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 21/6/25.
//

import SpriteKit
import SwiftUI

// MARK: - SKNode Extensions

extension SKNode {
    
    /// Add multiple children at once
    func addChildren(_ nodes: [SKNode]) {
        nodes.forEach { addChild($0) }
    }
    
    /// Remove all children with a specific name
    func removeChildren(withName name: String) {
        children.filter { $0.name == name }.forEach { $0.removeFromParent() }
    }
    
    /// Animate scale with spring effect
    func animateScale(to scale: CGFloat, duration: TimeInterval = 0.3) {
        let scaleAction = SKAction.scale(to: scale, duration: duration)
        scaleAction.timingMode = .easeOut
        run(scaleAction)
    }
    
    /// Pulse animation for emphasis
    func pulse(scale: CGFloat = 1.2, duration: TimeInterval = 0.6) {
        let pulseUp = SKAction.scale(to: scale, duration: duration / 2)
        let pulseDown = SKAction.scale(to: 1.0, duration: duration / 2)
        let sequence = SKAction.sequence([pulseUp, pulseDown])
        run(sequence)
    }
    
    /// Shake animation for errors or attention
    func shake(intensity: CGFloat = 10, duration: TimeInterval = 0.5) {
        let originalPosition = position
        let shakeLeft = SKAction.moveTo(x: originalPosition.x - intensity, duration: 0.05)
        let shakeRight = SKAction.moveTo(x: originalPosition.x + intensity, duration: 0.05)
        let returnToCenter = SKAction.move(to: originalPosition, duration: 0.05)
        
        let shakeSequence = SKAction.sequence([shakeLeft, shakeRight])
        let repeatShake = SKAction.repeat(shakeSequence, count: Int(duration / 0.1))
        let fullSequence = SKAction.sequence([repeatShake, returnToCenter])
        
        run(fullSequence)
    }
    
    /// Fade in animation
    func fadeIn(duration: TimeInterval = 0.3) {
        alpha = 0
        let fadeAction = SKAction.fadeIn(withDuration: duration)
        run(fadeAction)
    }
    
    /// Fade out animation
    func fadeOut(duration: TimeInterval = 0.3, completion: @escaping () -> Void = {}) {
        let fadeAction = SKAction.fadeOut(withDuration: duration)
        let completionAction = SKAction.run(completion)
        let sequence = SKAction.sequence([fadeAction, completionAction])
        run(sequence)
    }
    
    /// Float animation (subtle up and down movement)
    func startFloating(amplitude: CGFloat = 10, duration: TimeInterval = 2.0) {
        let moveUp = SKAction.moveBy(x: 0, y: amplitude, duration: duration)
        let moveDown = SKAction.moveBy(x: 0, y: -amplitude, duration: duration)
        moveUp.timingMode = .easeInEaseOut
        moveDown.timingMode = .easeInEaseOut
        
        let sequence = SKAction.sequence([moveUp, moveDown])
        let repeatForever = SKAction.repeatForever(sequence)
        
        run(repeatForever, withKey: "floating")
    }
    
    /// Stop floating animation
    func stopFloating() {
        removeAction(forKey: "floating")
    }
}

// MARK: - SKLabelNode Extensions

extension SKLabelNode {
    
    /// Create label with NumberQuest text styling
    convenience init(text: String, style: TextStyleType) {
        self.init(text: text)
        applyStyle(style)
    }
    
    /// Apply NumberQuest text style
    func applyStyle(_ style: TextStyleType) {
        switch style {
        case .gameTitle:
            fontSize = 42
            fontName = "Baloo2-VariableFont_wght"
            fontColor = .white
        case .title:
            fontSize = 28
            fontName = "Baloo2-VariableFont_wght"
            fontColor = .white
        case .subtitle:
            fontSize = 22
            fontName = "Baloo2-VariableFont_wght"
            fontColor = .white
        case .heading:
            fontSize = 18
            fontName = "Baloo2-VariableFont_wght"
            fontColor = .white
        case .body:
            fontSize = 16
            fontName = "Baloo2-VariableFont_wght"
            fontColor = .white
        case .caption:
            fontSize = 14
            fontName = "Baloo2-VariableFont_wght"
            fontColor = .lightGray
        case .buttonLarge:
            fontSize = 20
            fontName = "Baloo2-VariableFont_wght"
            fontColor = .white
        case .buttonMedium:
            fontSize = 18
            fontName = "Baloo2-VariableFont_wght"
            fontColor = .white
        case .questionText:
            fontSize = 32
            fontName = "Baloo2-VariableFont_wght"
            fontColor = .white
        case .answerText:
            fontSize = 24
            fontName = "Baloo2-VariableFont_wght"
            fontColor = .white
        case .scoreText:
            fontSize = 20
            fontName = "Baloo2-VariableFont_wght"
            fontColor = .yellow
        }
        
        // Add drop shadow for better readability
        addDropShadow()
    }
    
    /// Add drop shadow to text
    func addDropShadow(color: UIColor = .black, offset: CGSize = CGSize(width: 2, height: -2), blur: CGFloat = 4) {
        // Create shadow effect by adding a duplicate label behind
        guard let parent = parent else { return }
        
        let shadowLabel = SKLabelNode(text: text)
        shadowLabel.fontSize = fontSize
        shadowLabel.fontName = fontName
        shadowLabel.fontColor = color.withAlphaComponent(0.5)
        shadowLabel.position = CGPoint(x: position.x + offset.width, y: position.y + offset.height)
        shadowLabel.zPosition = zPosition - 1
        shadowLabel.horizontalAlignmentMode = horizontalAlignmentMode
        shadowLabel.verticalAlignmentMode = verticalAlignmentMode
        
        parent.insertChild(shadowLabel, at: 0)
    }
    
    /// Animate text change with fade effect
    func animateTextChange(to newText: String, duration: TimeInterval = 0.3) {
        let fadeOut = SKAction.fadeOut(withDuration: duration / 2)
        let changeText = SKAction.run { self.text = newText }
        let fadeIn = SKAction.fadeIn(withDuration: duration / 2)
        let sequence = SKAction.sequence([fadeOut, changeText, fadeIn])
        run(sequence)
    }
    
    /// Type writer effect for text
    func typeWriterEffect(text: String, interval: TimeInterval = 0.1) {
        self.text = ""
        
        for (index, character) in text.enumerated() {
            let wait = SKAction.wait(forDuration: interval * Double(index))
            let addCharacter = SKAction.run {
                self.text = String(text.prefix(index + 1))
            }
            let sequence = SKAction.sequence([wait, addCharacter])
            run(sequence)
        }
    }
}

// MARK: - SKSpriteNode Extensions

extension SKSpriteNode {
    
    /// Create a rounded rectangle sprite
    convenience init(color: UIColor, size: CGSize, cornerRadius: CGFloat) {
        // For now, use regular rectangle - can be enhanced with custom textures
        self.init(color: color, size: size)
        self.name = "roundedRect"
    }
    
    /// Animate color change
    func animateColor(to color: UIColor, duration: TimeInterval = 0.3) {
        let colorAction = SKAction.colorize(with: color, colorBlendFactor: 1.0, duration: duration)
        run(colorAction)
    }
    
    /// Create button press effect
    func buttonPressEffect() {
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        let sequence = SKAction.sequence([scaleDown, scaleUp])
        run(sequence)
    }
}

// MARK: - Color Extensions

extension UIColor {
    
    /// NumberQuest color palette
    static let nqBlue = UIColor(red: 0.1, green: 0.2, blue: 0.8, alpha: 1.0)
    static let nqPurple = UIColor(red: 0.3, green: 0.1, blue: 0.7, alpha: 1.0)
    static let nqPink = UIColor(red: 0.7, green: 0.2, blue: 0.9, alpha: 1.0)
    static let nqCoral = UIColor(red: 0.9, green: 0.4, blue: 0.6, alpha: 1.0)
    static let nqMint = UIColor(red: 0.4, green: 0.9, blue: 0.8, alpha: 1.0)
    static let nqYellow = UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)
    static let nqOrange = UIColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
    static let nqGreen = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
    
    /// Create color with hex string
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            alpha: Double(a) / 255
        )
    }
}

// MARK: - Supporting Types

enum TextStyleType {
    case gameTitle
    case title
    case subtitle
    case heading
    case body
    case caption
    case buttonLarge
    case buttonMedium
    case questionText
    case answerText
    case scoreText
}
