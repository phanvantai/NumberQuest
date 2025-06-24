//
//  BaseGameScene.swift
//  NumberQuest
//
//  Created by TaiPV on 24/6/25.
//

import SpriteKit
import SwiftUI

/// Base class for all game scenes in NumberQuest
/// Provides common functionality, coordinate system helpers, and responsive design
class BaseGameScene: SKScene {
    
    // MARK: - Properties
    
    /// Reference to shared game data
    var gameData: GameData {
        return GameData.shared
    }
    
    /// Safe area insets for responsive design
    var safeAreaInsets: UIEdgeInsets = .zero
    
    /// Device type detection
    var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// Main camera node for scene control
    var gameCamera: SKCameraNode?
    
    /// Background animation nodes
    internal var backgroundAnimationNodes: [SKNode] = []
    
    // MARK: - Coordinate System Helpers
    
    /// Get the safe screen width accounting for safe areas
    var safeWidth: CGFloat {
        return size.width - safeAreaInsets.left - safeAreaInsets.right
    }
    
    /// Get the safe screen height accounting for safe areas
    var safeHeight: CGFloat {
        return size.height - safeAreaInsets.top - safeAreaInsets.bottom
    }
    
    /// Get the center point of the safe area
    var safeCenter: CGPoint {
        return CGPoint(
            x: size.width / 2,
            y: size.height / 2
        )
    }
    
    /// Convert from SwiftUI-style relative positioning to SpriteKit coordinates
    func position(x: CGFloat, y: CGFloat) -> CGPoint {
        return CGPoint(
            x: x * safeWidth + safeAreaInsets.left,
            y: (1.0 - y) * safeHeight + safeAreaInsets.bottom
        )
    }
    
    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Get safe area insets from the view
        if let window = view.window {
            safeAreaInsets = window.safeAreaInsets
        }
        
        setupScene()
        setupBackground()
        setupUI()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        
        // Update safe area insets
        if let view = view, let window = view.window {
            safeAreaInsets = window.safeAreaInsets
        }
        
        layoutForNewSize()
    }
    
    // MARK: - Setup Methods (Override in subclasses)
    
    /// Override this method to set up the scene
    func setupScene() {
        // Default implementation
        backgroundColor = SKColor.clear
        
        // Set up camera
        setupCamera()
    }
    
    /// Set up the main camera node
    private func setupCamera() {
        gameCamera = SKCameraNode()
        addChild(gameCamera!)
        camera = gameCamera
        
        // Position camera at scene center
        gameCamera?.position = CGPoint(x: size.width / 2, y: size.height / 2)
    }
    
    /// Override this method to set up the background
    func setupBackground() {
        // Default gradient background
        createGradientBackground(
            colors: [
                UIColor(red: 0.4, green: 0.8, blue: 1.0, alpha: 1.0),
                UIColor(red: 0.6, green: 0.4, blue: 1.0, alpha: 1.0)
            ]
        )
    }
    
    /// Override this method to set up UI elements
    func setupUI() {
        // Override in subclasses
    }
    
    /// Override this method to handle size changes
    func layoutForNewSize() {
        // Override in subclasses
    }
    
    // MARK: - Background Helpers
    
    /// Create a gradient background using shader or texture
    func createGradientBackground(colors: [UIColor], animated: Bool = false) {
        // Remove existing background nodes
        backgroundAnimationNodes.forEach { $0.removeFromParent() }
        backgroundAnimationNodes.removeAll()
        
        if animated {
            createAnimatedGradientBackground(colors: colors)
        } else {
            createStaticGradientBackground(colors: colors)
        }
    }
    
    /// Create a static gradient background
    private func createStaticGradientBackground(colors: [UIColor]) {
        let gradientNode = SKSpriteNode(color: colors.first ?? .blue, size: size)
        gradientNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        gradientNode.zPosition = -100
        
        // Simple color blend for gradient effect
        if colors.count > 1 {
            gradientNode.color = colors[0]
            let blendNode = SKSpriteNode(color: colors[1], size: size)
            blendNode.alpha = 0.5
            blendNode.position = CGPoint(x: 0, y: 0)
            blendNode.blendMode = .add
            gradientNode.addChild(blendNode)
        }
        
        addChild(gradientNode)
        backgroundAnimationNodes.append(gradientNode)
    }
    
    /// Create an animated gradient background with flowing colors
    private func createAnimatedGradientBackground(colors: [UIColor]) {
        guard colors.count >= 2 else {
            createStaticGradientBackground(colors: colors)
            return
        }
        
        // Create base layer
        let baseNode = SKSpriteNode(color: colors[0], size: size)
        baseNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        baseNode.zPosition = -100
        addChild(baseNode)
        backgroundAnimationNodes.append(baseNode)
        
        // Create animated overlay layers
        for i in 1..<colors.count {
            let overlayNode = SKSpriteNode(color: colors[i], size: size)
            overlayNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
            overlayNode.zPosition = -100 + CGFloat(i)
            overlayNode.alpha = 0.3
            overlayNode.blendMode = .add
            
            // Create pulsing animation
            let pulseIn = SKAction.fadeAlpha(to: 0.6, duration: 3.0 + Double(i) * 0.5)
            let pulseOut = SKAction.fadeAlpha(to: 0.2, duration: 3.0 + Double(i) * 0.5)
            let pulseSequence = SKAction.sequence([pulseIn, pulseOut])
            let pulseForever = SKAction.repeatForever(pulseSequence)
            
            overlayNode.run(pulseForever)
            addChild(overlayNode)
            backgroundAnimationNodes.append(overlayNode)
        }
        
        // Add floating particle effects for extra animation
        addFloatingBackgroundElements()
    }
    
    /// Add subtle floating elements to the background
    private func addFloatingBackgroundElements() {
        for i in 0..<8 {
            let particle = SKShapeNode(circleOfRadius: CGFloat.random(in: 2...6))
            particle.fillColor = UIColor.white.withAlphaComponent(0.1)
            particle.strokeColor = UIColor.white.withAlphaComponent(0.05)
            particle.lineWidth = 1
            
            // Random starting position
            particle.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            particle.zPosition = -90
            
            // Create floating animation
            let moveX = SKAction.moveBy(x: CGFloat.random(in: -50...50), y: CGFloat.random(in: -30...30), duration: TimeInterval.random(in: 8...15))
            let moveBack = moveX.reversed()
            let floatSequence = SKAction.sequence([moveX, moveBack])
            let floatForever = SKAction.repeatForever(floatSequence)
            
            // Add rotation
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: TimeInterval.random(in: 10...20))
            let rotateForever = SKAction.repeatForever(rotate)
            
            // Combine animations
            let combinedAction = SKAction.group([floatForever, rotateForever])
            particle.run(combinedAction)
            
            addChild(particle)
            backgroundAnimationNodes.append(particle)
        }
    }
    
    // MARK: - Animation Helpers
    
    /// Create a spring animation action
    func springAnimation(to position: CGPoint, duration: TimeInterval) -> SKAction {
        let move = SKAction.move(to: position, duration: duration)
        move.timingMode = .easeOut
        return move
    }
    
    /// Create a scale bounce animation
    func bounceAnimation(scale: CGFloat = 1.1, duration: TimeInterval = 0.1) -> SKAction {
        let scaleUp = SKAction.scale(to: scale, duration: duration)
        let scaleDown = SKAction.scale(to: 1.0, duration: duration)
        scaleUp.timingMode = .easeOut
        scaleDown.timingMode = .easeIn
        return SKAction.sequence([scaleUp, scaleDown])
    }
    
    /// Create a shake animation
    func shakeAnimation(intensity: CGFloat = 10, duration: TimeInterval = 0.5) -> SKAction {
        let shake = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.moveBy(x: intensity, y: 0, duration: 0.05),
                SKAction.moveBy(x: -intensity * 2, y: 0, duration: 0.05),
                SKAction.moveBy(x: intensity, y: 0, duration: 0.05)
            ])
        )
        
        let wait = SKAction.wait(forDuration: duration)
        let stopShake = SKAction.removeFromParent()
        
        return SKAction.sequence([shake, wait, stopShake])
    }
    
    // MARK: - Sound Integration
    // Sound and haptic methods are now handled by SKNode extensions in SpriteKitSoundManager
    
    // MARK: - Cleanup
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        cleanup()
    }
    
    /// Override this method to clean up resources
    func cleanup() {
        // Override in subclasses
        removeAllActions()
        removeAllChildren()
    }
    
    // MARK: - Camera Control Methods
    
    /// Smoothly move camera to a new position
    func moveCamera(to position: CGPoint, duration: TimeInterval = 1.0) {
        guard let camera = gameCamera else { return }
        
        let moveAction = SKAction.move(to: position, duration: duration)
        moveAction.timingMode = .easeInEaseOut
        camera.run(moveAction)
    }
    
    /// Shake the camera for impact effects
    func shakeCamera(intensity: CGFloat = 10.0, duration: TimeInterval = 0.5) {
        guard let camera = gameCamera else { return }
        
        let originalPosition = camera.position
        let shakeAction = SKAction.sequence([
            SKAction.move(by: CGVector(dx: intensity, dy: 0), duration: 0.05),
            SKAction.move(by: CGVector(dx: -intensity * 2, dy: 0), duration: 0.05),
            SKAction.move(by: CGVector(dx: intensity * 2, dy: 0), duration: 0.05),
            SKAction.move(by: CGVector(dx: -intensity, dy: 0), duration: 0.05),
            SKAction.move(to: originalPosition, duration: 0.1)
        ])
        
        let repeatCount = Int(duration / 0.25)
        let shakeSequence = SKAction.repeat(shakeAction, count: max(1, repeatCount))
        camera.run(shakeSequence)
    }
    
    /// Zoom camera to a specific scale
    func zoomCamera(to scale: CGFloat, duration: TimeInterval = 1.0) {
        guard let camera = gameCamera else { return }
        
        let scaleAction = SKAction.scale(to: scale, duration: duration)
        scaleAction.timingMode = .easeInEaseOut
        camera.run(scaleAction)
    }
}

// MARK: - Extensions

extension CGPoint {
    /// Create a point with relative positioning (0.0 to 1.0)
    static func relative(x: CGFloat, y: CGFloat, in scene: BaseGameScene) -> CGPoint {
        return scene.position(x: x, y: y)
    }
}

extension SKNode {
    /// Add a glow effect to the node
    func addGlow(radius: CGFloat = 10, color: UIColor = .white) {
        let glow = SKEffectNode()
        glow.shouldRasterize = true
        glow.filter = CIFilter(name: "CIGaussianBlur", parameters: ["inputRadius": radius])
        
        let glowNode = self.copy() as! SKNode
        glowNode.alpha = 0.8
        if let sprite = glowNode as? SKSpriteNode {
            sprite.color = color
            sprite.colorBlendFactor = 1.0
        }
        
        glow.addChild(glowNode)
        glow.zPosition = self.zPosition - 1
        
        if let parent = self.parent {
            parent.addChild(glow)
        }
    }
}
