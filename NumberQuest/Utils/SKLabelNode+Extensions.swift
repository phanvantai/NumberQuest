//
//  SKLabelNode+Extensions.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 26/6/25.
//

import SpriteKit

extension SKLabelNode {
    
    // MARK: - Custom Font Convenience Initializers
    
    /// Create an SKLabelNode with custom font
    convenience init(text: String, fontName: FontManager.FontName, fontSize: FontManager.FontSize) {
        self.init()
        self.text = text
        self.fontName = fontName.rawValue
        self.fontSize = fontSize.rawValue
    }
    
    /// Create an SKLabelNode with custom font and custom size
    convenience init(text: String, fontName: FontManager.FontName, fontSize: CGFloat) {
        self.init()
        self.text = text
        self.fontName = fontName.rawValue
        self.fontSize = fontSize
    }
    
    // MARK: - Convenience Methods for Common Styles
    
    /// Configure as game title (FzWitchMagic, large, centered)
    func configureAsGameTitle(_ text: String, size: FontManager.FontSize = .gameTitle, color: UIColor = .white) {
        self.text = text
      self.fontName = FontManager.FontName.domCasual.rawValue
        self.fontSize = size.rawValue
        self.fontColor = color
        self.horizontalAlignmentMode = .center
        self.verticalAlignmentMode = .center
        
        // Add glow effect for magical appearance
        addGlowEffect(color: color, radius: 8.0)
    }
    
    /// Configure as menu button text (FzWitchMagic, medium, centered)
    func configureAsMenuButton(_ text: String, size: FontManager.FontSize = .large, color: UIColor = .white) {
        self.text = text
        self.fontName = FontManager.FontName.domCasual.rawValue
        self.fontSize = size.rawValue
        self.fontColor = color
        self.horizontalAlignmentMode = .center
        self.verticalAlignmentMode = .center
        
        // Add subtle glow for button highlight
        addGlowEffect(color: color, radius: 4.0)
    }
    
    /// Configure as game UI text (WowDino, various purposes)
    func configureAsGameUI(_ text: String, size: FontManager.FontSize = .medium, color: UIColor = .white, alignment: SKLabelHorizontalAlignmentMode = .center) {
        self.text = text
        self.fontName = FontManager.FontName.wowDino.rawValue
        self.fontSize = size.rawValue
        self.fontColor = color
        self.horizontalAlignmentMode = alignment
        self.verticalAlignmentMode = .center
    }
    
    /// Configure as score text (WowDino, right-aligned, yellow)
    func configureAsScore(_ text: String, size: FontManager.FontSize = .large, color: UIColor = .yellow) {
        self.text = text
        self.fontName = FontManager.FontName.wowDino.rawValue
        self.fontSize = size.rawValue
        self.fontColor = color
        self.horizontalAlignmentMode = .right
        self.verticalAlignmentMode = .center
        
        // Add outline for better visibility
        addStrokeEffect(color: .black, width: 2.0)
    }
    
    /// Configure as problem text (WowDino, large, centered, white)
    func configureAsProblem(_ text: String, size: FontManager.FontSize = .extraLarge, color: UIColor = .white) {
        self.text = text
        self.fontName = FontManager.FontName.wowDino.rawValue
        self.fontSize = size.rawValue
        self.fontColor = color
        self.horizontalAlignmentMode = .center
        self.verticalAlignmentMode = .center
        
        // Add stroke for readability
        addStrokeEffect(color: .black, width: 3.0)
    }
    
    // MARK: - Visual Effects
    
    /// Add glow effect to the label
    func addGlowEffect(color: UIColor, radius: CGFloat) {
        // Remove existing glow
        removeGlowEffect()
        
        // Create glow effect
        let glowEffect = SKEffectNode()
        glowEffect.name = "glowEffect"
        
        // Create a copy of the label for the glow
        let glowLabel = SKLabelNode()
        glowLabel.text = self.text
        glowLabel.fontName = self.fontName
        glowLabel.fontSize = self.fontSize
        glowLabel.fontColor = color
        glowLabel.horizontalAlignmentMode = self.horizontalAlignmentMode
        glowLabel.verticalAlignmentMode = self.verticalAlignmentMode
        
        // Apply blur filter
        let blurFilter = CIFilter(name: "CIGaussianBlur")!
        blurFilter.setValue(radius, forKey: "inputRadius")
        glowEffect.filter = blurFilter
        glowEffect.shouldRasterize = true
        
        glowEffect.addChild(glowLabel)
        
        // Insert glow behind the main label
        if let parent = self.parent {
            parent.insertChild(glowEffect, at: 0)
            glowEffect.position = self.position
        }
    }
    
    /// Remove glow effect
    func removeGlowEffect() {
        parent?.childNode(withName: "glowEffect")?.removeFromParent()
    }
    
    /// Add stroke/outline effect to the label
    func addStrokeEffect(color: UIColor, width: CGFloat) {
        // Note: SpriteKit doesn't have built-in stroke for labels
        // This creates a simple shadow effect as an alternative
        let shadowLabel = SKLabelNode()
        shadowLabel.text = self.text
        shadowLabel.fontName = self.fontName
        shadowLabel.fontSize = self.fontSize
        shadowLabel.fontColor = color
        shadowLabel.horizontalAlignmentMode = self.horizontalAlignmentMode
        shadowLabel.verticalAlignmentMode = self.verticalAlignmentMode
        shadowLabel.position = CGPoint(x: width, y: -width)
        shadowLabel.zPosition = self.zPosition - 1
        shadowLabel.name = "strokeEffect"
        
        // Remove existing stroke
        removeStrokeEffect()
        
        // Add shadow as stroke
        self.parent?.addChild(shadowLabel)
    }
    
    /// Remove stroke effect
    func removeStrokeEffect() {
        parent?.childNode(withName: "strokeEffect")?.removeFromParent()
    }
    
    // MARK: - Animation Helpers
    
    /// Animate text change with fade effect
    func animateTextChange(to newText: String, duration: TimeInterval = 0.3) {
        let fadeOut = SKAction.fadeAlpha(to: 0.0, duration: duration / 2)
        let changeText = SKAction.run { [weak self] in
            self?.text = newText
        }
        let fadeIn = SKAction.fadeAlpha(to: 1.0, duration: duration / 2)
        
        let sequence = SKAction.sequence([fadeOut, changeText, fadeIn])
        run(sequence)
    }
    
    /// Pulse animation for emphasis
    func pulseAnimation(scale: CGFloat = 1.2, duration: TimeInterval = 0.5) {
        let scaleUp = SKAction.scale(to: scale, duration: duration / 2)
        let scaleDown = SKAction.scale(to: 1.0, duration: duration / 2)
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        
        run(pulse)
    }
    
    /// Typewriter effect for text appearance
    func typewriterEffect(fullText: String, duration: TimeInterval = 1.0) {
        self.text = ""
        let charactersPerSecond = Double(fullText.count) / duration
        let delayPerCharacter = 1.0 / charactersPerSecond
        
        for (index, character) in fullText.enumerated() {
            let delay = SKAction.wait(forDuration: delayPerCharacter * Double(index))
            let addCharacter = SKAction.run { [weak self] in
                if let currentText = self?.text {
                    self?.text = currentText + String(character)
                }
            }
            let sequence = SKAction.sequence([delay, addCharacter])
            run(sequence)
        }
    }
}
