//
//  TextAnimationEffects.swift
//  NumberQuest
//
//  Created by TaiPV on 24/6/25.
//

import SpriteKit
import UIKit

// MARK: - Text Animation Effects

/// Comprehensive text animation system for SpriteKit
/// Provides various animation effects for enhanced text presentation
struct TextAnimationEffects {
    
    // MARK: - Animation Types
    enum AnimationType {
        case typewriter
        case bounce
        case wave
        case shake
        case glow
        case rainbow
        case fireworks
        case floating
        case zoom
        case flip
        case elastic
        case wobble
    }
    
    // MARK: - Typewriter Effect
    static func typewriterEffect(
        for label: SKLabelNode,
        text: String,
        duration: TimeInterval = 2.0,
        completion: (() -> Void)? = nil
    ) {
        guard !text.isEmpty else {
            completion?()
            return
        }
        
        label.text = ""
        let characters = Array(text)
        let charDuration = duration / Double(characters.count)
        
        var currentIndex = 0
        
        let typeAction = SKAction.run {
            if currentIndex < characters.count {
                label.text = String(characters[0...currentIndex])
                currentIndex += 1
            }
        }
        
        let wait = SKAction.wait(forDuration: charDuration)
        let sequence = SKAction.sequence([typeAction, wait])
        let repeatAction = SKAction.repeat(sequence, count: characters.count)
        
        label.run(repeatAction) {
            completion?()
        }
    }
    
    // MARK: - Bounce Animation
    static func bounceAnimation(
        for node: SKNode,
        intensity: CGFloat = 1.3,
        duration: TimeInterval = 0.6
    ) {
        let originalScale = node.xScale
        let bounceScale = originalScale * intensity
        
        let scaleUp = SKAction.scale(to: bounceScale, duration: duration * 0.3)
        let scaleDown = SKAction.scale(to: originalScale, duration: duration * 0.7)
        
        scaleUp.timingMode = .easeOut
        scaleDown.timingMode = .easeInEaseOut
        
        let bounce = SKAction.sequence([scaleUp, scaleDown])
        node.run(bounce)
    }
    
    // MARK: - Wave Animation
    static func waveAnimation(
        for labels: [SKLabelNode],
        amplitude: CGFloat = 20,
        wavelength: CGFloat = 100,
        speed: TimeInterval = 2.0
    ) {
        for (index, label) in labels.enumerated() {
            let delay = TimeInterval(index) * 0.1
            let originalY = label.position.y
            
            let moveUp = SKAction.moveBy(x: 0, y: amplitude, duration: speed * 0.25)
            let moveDown = SKAction.moveBy(x: 0, y: -amplitude * 2, duration: speed * 0.5)
            let moveBack = SKAction.moveBy(x: 0, y: amplitude, duration: speed * 0.25)
            
            moveUp.timingMode = .easeOut
            moveDown.timingMode = .easeInEaseOut
            moveBack.timingMode = .easeIn
            
            let wave = SKAction.sequence([moveUp, moveDown, moveBack])
            let delayedWave = SKAction.sequence([
                SKAction.wait(forDuration: delay),
                wave
            ])
            
            label.run(delayedWave)
        }
    }
    
    // MARK: - Shake Animation
    static func shakeAnimation(
        for node: SKNode,
        intensity: CGFloat = 10,
        duration: TimeInterval = 0.5
    ) {
        let originalPosition = node.position
        
        let shakeLeft = SKAction.moveBy(x: -intensity, y: 0, duration: 0.05)
        let shakeRight = SKAction.moveBy(x: intensity * 2, y: 0, duration: 0.05)
        let returnToCenter = SKAction.move(to: originalPosition, duration: 0.05)
        
        let shakeSequence = SKAction.sequence([shakeLeft, shakeRight, returnToCenter])
        let repeatedShake = SKAction.repeat(shakeSequence, count: Int(duration / 0.15))
        
        node.run(repeatedShake)
    }
    
    // MARK: - Glow Animation
    static func glowAnimation(
        for node: SKNode,
        color: UIColor = .yellow,
        intensity: CGFloat = 0.8,
        duration: TimeInterval = 1.0
    ) {
        let glowUp = SKAction.colorize(with: color, colorBlendFactor: intensity, duration: duration * 0.5)
        let glowDown = SKAction.colorize(with: .white, colorBlendFactor: 0, duration: duration * 0.5)
        
        glowUp.timingMode = .easeInEaseOut
        glowDown.timingMode = .easeInEaseOut
        
        let glow = SKAction.sequence([glowUp, glowDown])
        node.run(SKAction.repeatForever(glow))
    }
    
    // MARK: - Rainbow Animation
    static func rainbowAnimation(
        for label: SKLabelNode,
        duration: TimeInterval = 3.0
    ) {
        let colors: [UIColor] = [
            .red, .orange, .yellow, .green, .blue, .purple, .magenta
        ]
        
        var colorActions: [SKAction] = []
        let colorDuration = duration / Double(colors.count)
        
        for color in colors {
            let colorize = SKAction.colorize(with: color, colorBlendFactor: 0.8, duration: colorDuration)
            colorActions.append(colorize)
        }
        
        let rainbow = SKAction.sequence(colorActions)
        label.run(SKAction.repeatForever(rainbow))
    }
    
    // MARK: - Fireworks Text Effect
    static func fireworksEffect(
        for label: SKLabelNode,
        particleCount: Int = 20
    ) {
        for _ in 0..<particleCount {
            let particle = SKLabelNode(text: "✨")
            particle.fontSize = CGFloat.random(in: 12...24)
            particle.position = label.position
            particle.zPosition = label.zPosition + 1
            
            label.parent?.addChild(particle)
            
            let randomX = CGFloat.random(in: -100...100)
            let randomY = CGFloat.random(in: -100...100)
            let duration = TimeInterval.random(in: 0.5...1.5)
            
            let move = SKAction.moveBy(x: randomX, y: randomY, duration: duration)
            let fade = SKAction.fadeOut(withDuration: duration)
            let scale = SKAction.scale(to: 0.1, duration: duration)
            
            let effect = SKAction.group([move, fade, scale])
            
            particle.run(effect) {
                particle.removeFromParent()
            }
        }
    }
    
    // MARK: - Floating Text Effect
    static func floatingTextEffect(
        text: String,
        style: SpriteKitTextStyle,
        startPosition: CGPoint,
        direction: CGVector = CGVector(dx: 0, dy: 50),
        duration: TimeInterval = 2.0,
        parent: SKNode
    ) -> EnhancedLabelNode {
        let floatingLabel = style.createLabel(text: text)
        floatingLabel.position = startPosition
        floatingLabel.alpha = 0
        
        parent.addChild(floatingLabel)
        
        // Set initial scale
        floatingLabel.setScale(0.5)
        
        // Entrance animation
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let scaleIn = SKAction.scale(to: 1.0, duration: 0.2)
        let entrance = SKAction.group([fadeIn, scaleIn])
        
        // Floating animation
        let move = SKAction.moveBy(x: direction.dx, y: direction.dy, duration: duration)
        let fadeOut = SKAction.fadeOut(withDuration: duration * 0.7)
        let scaleOut = SKAction.scale(to: 0.8, duration: duration)
        
        move.timingMode = .easeOut
        fadeOut.timingMode = .easeIn
        
        let float = SKAction.group([move, fadeOut, scaleOut])
        
        let complete = SKAction.sequence([entrance, float])
        
        floatingLabel.run(complete) {
            floatingLabel.removeFromParent()
        }
        
        return floatingLabel
    }
    
    // MARK: - Zoom Animation
    static func zoomAnimation(
        for node: SKNode,
        fromScale: CGFloat = 0.1,
        toScale: CGFloat = 1.0,
        duration: TimeInterval = 0.5,
        overshoot: CGFloat = 1.2
    ) {
        node.setScale(fromScale)
        node.alpha = 0
        
        let fadeIn = SKAction.fadeIn(withDuration: duration * 0.3)
        let scaleToOvershoot = SKAction.scale(to: overshoot, duration: duration * 0.7)
        let scaleToFinal = SKAction.scale(to: toScale, duration: duration * 0.3)
        
        scaleToOvershoot.timingMode = .easeOut
        scaleToFinal.timingMode = .easeInEaseOut
        
        let zoom = SKAction.sequence([
            SKAction.group([fadeIn, scaleToOvershoot]),
            scaleToFinal
        ])
        
        node.run(zoom)
    }
    
    // MARK: - Flip Animation
    static func flipAnimation(
        for node: SKNode,
        axis: FlipAxis = .horizontal,
        duration: TimeInterval = 0.6
    ) {
        let midScale: CGFloat = axis == .horizontal ? 0.0 : 1.0
        let scaleX = axis == .horizontal ? midScale : 1.0
        let scaleY = axis == .vertical ? midScale : 1.0
        
        let shrink = SKAction.scaleX(to: scaleX, y: scaleY, duration: duration * 0.5)
        let grow = SKAction.scaleX(to: 1.0, y: 1.0, duration: duration * 0.5)
        
        shrink.timingMode = .easeIn
        grow.timingMode = .easeOut
        
        let flip = SKAction.sequence([shrink, grow])
        node.run(flip)
    }
    
    enum FlipAxis {
        case horizontal
        case vertical
    }
    
    // MARK: - Elastic Animation
    static func elasticAnimation(
        for node: SKNode,
        targetScale: CGFloat = 1.5,
        duration: TimeInterval = 1.0,
        oscillations: Int = 3
    ) {
        let originalScale = node.xScale
        
        var actions: [SKAction] = []
        
        for i in 0..<oscillations {
            let scale = targetScale * (1.0 - CGFloat(i) / CGFloat(oscillations))
            let oscillationDuration = duration / Double(oscillations * 2)
            
            let scaleUp = SKAction.scale(to: scale, duration: oscillationDuration)
            let scaleDown = SKAction.scale(to: originalScale, duration: oscillationDuration)
            
            scaleUp.timingMode = .easeOut
            scaleDown.timingMode = .easeIn
            
            actions.append(contentsOf: [scaleUp, scaleDown])
        }
        
        let elastic = SKAction.sequence(actions)
        node.run(elastic)
    }
    
    // MARK: - Wobble Animation
    static func wobbleAnimation(
        for node: SKNode,
        angle: CGFloat = .pi / 6,
        duration: TimeInterval = 0.5,
        oscillations: Int = 3
    ) {
        let originalRotation = node.zRotation
        
        var actions: [SKAction] = []
        let oscillationDuration = duration / Double(oscillations * 2)
        
        for i in 0..<oscillations {
            let wobbleAngle = angle * (1.0 - CGFloat(i) / CGFloat(oscillations))
            
            let rotateRight = SKAction.rotate(toAngle: originalRotation + wobbleAngle, duration: oscillationDuration)
            let rotateLeft = SKAction.rotate(toAngle: originalRotation - wobbleAngle, duration: oscillationDuration)
            
            rotateRight.timingMode = .easeInEaseOut
            rotateLeft.timingMode = .easeInEaseOut
            
            actions.append(contentsOf: [rotateRight, rotateLeft])
        }
        
        let returnToOriginal = SKAction.rotate(toAngle: originalRotation, duration: oscillationDuration)
        actions.append(returnToOriginal)
        
        let wobble = SKAction.sequence(actions)
        node.run(wobble)
    }
}

// MARK: - Convenience Extensions
extension SKLabelNode {
    
    /// Apply typewriter effect to this label
    func typewrite(text: String, duration: TimeInterval = 2.0, completion: (() -> Void)? = nil) {
        TextAnimationEffects.typewriterEffect(for: self, text: text, duration: duration, completion: completion)
    }
    
    /// Apply bounce animation to this label
    func bounce(intensity: CGFloat = 1.3, duration: TimeInterval = 0.6) {
        TextAnimationEffects.bounceAnimation(for: self, intensity: intensity, duration: duration)
    }
    
    /// Apply shake animation to this label
    func shake(intensity: CGFloat = 10, duration: TimeInterval = 0.5) {
        TextAnimationEffects.shakeAnimation(for: self, intensity: intensity, duration: duration)
    }
    
    /// Apply glow animation to this label
    func glow(color: UIColor = .yellow, intensity: CGFloat = 0.8, duration: TimeInterval = 1.0) {
        TextAnimationEffects.glowAnimation(for: self, color: color, intensity: intensity, duration: duration)
    }
    
    /// Apply rainbow animation to this label
    func rainbow(duration: TimeInterval = 3.0) {
        TextAnimationEffects.rainbowAnimation(for: self, duration: duration)
    }
    
    /// Apply fireworks effect to this label
    func fireworks(particleCount: Int = 20) {
        TextAnimationEffects.fireworksEffect(for: self, particleCount: particleCount)
    }
    
    /// Apply zoom entrance animation
    func zoomIn(fromScale: CGFloat = 0.1, duration: TimeInterval = 0.5, overshoot: CGFloat = 1.2) {
        TextAnimationEffects.zoomAnimation(for: self, fromScale: fromScale, duration: duration, overshoot: overshoot)
    }
    
    /// Apply flip animation
    func flip(axis: TextAnimationEffects.FlipAxis = .horizontal, duration: TimeInterval = 0.6) {
        TextAnimationEffects.flipAnimation(for: self, axis: axis, duration: duration)
    }
    
    /// Apply elastic animation
    func elastic(targetScale: CGFloat = 1.5, duration: TimeInterval = 1.0, oscillations: Int = 3) {
        TextAnimationEffects.elasticAnimation(for: self, targetScale: targetScale, duration: duration, oscillations: oscillations)
    }
    
    /// Apply wobble animation
    func wobble(angle: CGFloat = .pi / 6, duration: TimeInterval = 0.5, oscillations: Int = 3) {
        TextAnimationEffects.wobbleAnimation(for: self, angle: angle, duration: duration, oscillations: oscillations)
    }
}

// MARK: - EnhancedLabelNode Extensions
extension EnhancedLabelNode {
    
    /// Create floating score text
    static func createFloatingScore(
        score: Int,
        startPosition: CGPoint,
        parent: SKNode
    ) -> EnhancedLabelNode {
        let scoreText = "+\(score)"
        let style = SpriteKitTextStyle.scoreText.withGlow(color: .yellow, radius: 5)
        
        return TextAnimationEffects.floatingTextEffect(
            text: scoreText,
            style: style,
            startPosition: startPosition,
            direction: CGVector(dx: 0, dy: 80),
            duration: 1.5,
            parent: parent
        )
    }
    
    /// Create celebration text
    static func createCelebration(
        text: String,
        startPosition: CGPoint,
        parent: SKNode
    ) -> EnhancedLabelNode {
        let style = SpriteKitTextStyle.celebration
        
        let celebrationLabel = style.createLabel(text: text)
        celebrationLabel.position = startPosition
        parent.addChild(celebrationLabel)
        
        // Entrance with fireworks
        celebrationLabel.zoomIn(fromScale: 0.1, duration: 0.8, overshoot: 2.2)
        celebrationLabel.fireworks(particleCount: 30)
        
        // Rainbow effect
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            celebrationLabel.rainbow(duration: 2.0)
        }
        
        // Auto-remove after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
            let fadeOut = SKAction.fadeOut(withDuration: 1.0)
            celebrationLabel.run(fadeOut) {
                celebrationLabel.removeFromParent()
            }
        }
        
        return celebrationLabel
    }
    
    /// Create answer feedback text
    static func createAnswerFeedback(
        isCorrect: Bool,
        startPosition: CGPoint,
        parent: SKNode
    ) -> EnhancedLabelNode {
        let text = isCorrect ? "Correct! ✨" : "Try Again! 💪"
        let style = isCorrect ? SpriteKitTextStyle.correctAnswer : SpriteKitTextStyle.wrongAnswer
        
        let feedbackLabel = style.createLabel(text: text)
        feedbackLabel.position = startPosition
        parent.addChild(feedbackLabel)
        
        if isCorrect {
            feedbackLabel.bounce(intensity: 1.8, duration: 0.8)
            feedbackLabel.fireworks(particleCount: 15)
        } else {
            feedbackLabel.shake(intensity: 15, duration: 0.6)
            feedbackLabel.wobble(angle: .pi / 8, duration: 0.8, oscillations: 2)
        }
        
        // Auto-remove
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            feedbackLabel.run(fadeOut) {
                feedbackLabel.removeFromParent()
            }
        }
        
        return feedbackLabel
    }
}
