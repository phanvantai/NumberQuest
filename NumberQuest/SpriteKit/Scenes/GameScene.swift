//
//  GameScene.swift
//  NumberQuest
//
//  Created by NumberQuest on 2024.
//

import SpriteKit
import SwiftUI

/// Enhanced game scene foundation with advanced features
/// This serves as the main gameplay screen foundation for NumberQuest
class GameScene: BaseGameScene {
    
    // MARK: - Properties
    
    /// Enhanced background effects
    private var backgroundEffectNodes: [SKNode] = []
    
    /// Floating UI elements for dynamic feel
    private var floatingUIElements: [SKNode] = []
    
    /// Parallax layers for depth
    private var parallaxLayers: [SKNode] = []
    
    // MARK: - Enhanced Setup Methods
    
    override func setupScene() {
        super.setupScene()
        
        // Enhanced scene configuration
        configureScenePhysics()
        setupParallaxLayers()
    }
    
    override func setupBackground() {
        super.setupBackground()
        
        // Create dynamic animated background
        createDynamicBackground()
        setupBackgroundEffects()
    }
    
    // MARK: - Advanced Background System
    
    /// Create a dynamic, multi-layered animated background
    private func createDynamicBackground() {
        // Main gradient base with education-friendly colors
        createGradientBackground(colors: [
            UIColor(red: 0.1, green: 0.6, blue: 0.9, alpha: 1.0),  // Sky blue
            UIColor(red: 0.3, green: 0.8, blue: 0.5, alpha: 1.0),  // Green
            UIColor(red: 0.5, green: 0.4, blue: 0.9, alpha: 1.0),  // Purple
            UIColor(red: 0.9, green: 0.7, blue: 0.3, alpha: 1.0)   // Golden
        ], animated: true)
    }
    
    /// Set up additional background effects
    private func setupBackgroundEffects() {
        // Add geometric shapes floating in background
        addFloatingShapes()
        
        // Add subtle mathematical symbols
        addMathSymbolsBackground()
    }
    
    /// Add floating geometric shapes for visual interest
    private func addFloatingShapes() {
        let shapes = ["triangle", "square", "circle", "star"]
        
        for i in 0..<12 {
            let shapeNode = createRandomShape()
            shapeNode.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            shapeNode.zPosition = -80 + CGFloat(i % 3)
            shapeNode.alpha = 0.08
            
            // Create floating animation
            addFloatingAnimation(to: shapeNode, duration: TimeInterval.random(in: 15...25))
            
            addChild(shapeNode)
            backgroundEffectNodes.append(shapeNode)
        }
    }
    
    /// Add subtle mathematical symbols in the background
    private func addMathSymbolsBackground() {
        let symbols = ["+", "−", "×", "÷", "=", "?"]
        
        for i in 0..<8 {
            let symbolLabel = SKLabelNode(text: symbols.randomElement() ?? "+")
            symbolLabel.fontName = "Baloo2-VariableFont_wght"
            symbolLabel.fontSize = CGFloat.random(in: 40...80)
            symbolLabel.fontColor = UIColor.white.withAlphaComponent(0.03)
            symbolLabel.position = CGPoint(
                x: CGFloat.random(in: 50...size.width - 50),
                y: CGFloat.random(in: 50...size.height - 50)
            )
            symbolLabel.zPosition = -85
            
            // Slow rotation
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: TimeInterval.random(in: 30...60))
            let rotateForever = SKAction.repeatForever(rotate)
            symbolLabel.run(rotateForever)
            
            addChild(symbolLabel)
            backgroundEffectNodes.append(symbolLabel)
        }
    }
    
    /// Create a random geometric shape
    private func createRandomShape() -> SKShapeNode {
        let shapeType = Int.random(in: 0...3)
        let size = CGFloat.random(in: 20...50)
        
        switch shapeType {
        case 0: // Circle
            return SKShapeNode(circleOfRadius: size / 2)
        case 1: // Triangle
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: size / 2))
            path.addLine(to: CGPoint(x: -size / 2, y: -size / 2))
            path.addLine(to: CGPoint(x: size / 2, y: -size / 2))
            path.closeSubpath()
            return SKShapeNode(path: path)
        case 2: // Square
            return SKShapeNode(rectOf: CGSize(width: size, height: size))
        default: // Star
            return createStarShape(size: size)
        }
    }
    
    /// Create a star shape
    private func createStarShape(size: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        let points = 5
        let outerRadius = size / 2
        let innerRadius = outerRadius * 0.4
        
        for i in 0..<points * 2 {
            let angle = CGFloat(i) * CGFloat.pi / CGFloat(points)
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = cos(angle) * radius
            let y = sin(angle) * radius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        
        let star = SKShapeNode(path: path)
        star.fillColor = UIColor.white.withAlphaComponent(0.1)
        star.strokeColor = UIColor.white.withAlphaComponent(0.05)
        star.lineWidth = 1
        
        return star
    }
    
    /// Add floating animation to a node
    private func addFloatingAnimation(to node: SKNode, duration: TimeInterval) {
        let moveDistance: CGFloat = 60
        let moveX = SKAction.moveBy(x: CGFloat.random(in: -moveDistance...moveDistance), 
                                   y: CGFloat.random(in: -moveDistance/2...moveDistance/2), 
                                   duration: duration / 2)
        let moveBack = moveX.reversed()
        let floatSequence = SKAction.sequence([moveX, moveBack])
        let floatForever = SKAction.repeatForever(floatSequence)
        
        // Add subtle rotation
        let rotateAngle = CGFloat.random(in: -CGFloat.pi/4...CGFloat.pi/4)
        let rotate = SKAction.rotate(byAngle: rotateAngle, duration: duration)
        let rotateBack = rotate.reversed()
        let rotateSequence = SKAction.sequence([rotate, rotateBack])
        let rotateForever = SKAction.repeatForever(rotateSequence)
        
        // Add subtle scale pulsing
        let scaleUp = SKAction.scale(to: 1.1, duration: duration / 3)
        let scaleDown = SKAction.scale(to: 0.9, duration: duration / 3)
        let scaleNormal = SKAction.scale(to: 1.0, duration: duration / 3)
        let scaleSequence = SKAction.sequence([scaleUp, scaleDown, scaleNormal])
        let scaleForever = SKAction.repeatForever(scaleSequence)
        
        // Combine all animations
        let combinedAction = SKAction.group([floatForever, rotateForever, scaleForever])
        node.run(combinedAction)
    }
    
    // MARK: - Scene Physics Configuration
    
    /// Configure physics for the scene
    private func configureScenePhysics() {
        // Enable physics world
        physicsWorld.gravity = CGVector(dx: 0, dy: 0) // No gravity for UI elements
        physicsWorld.speed = 1.0
        
        // Set physics world bounds
        let borderBody = SKPhysicsBody(edgeLoopFrom: frame)
        borderBody.friction = 0
        borderBody.restitution = 1
        physicsBody = borderBody
    }
    
    // MARK: - Parallax System
    
    /// Set up parallax background layers
    private func setupParallaxLayers() {
        // Create multiple parallax layers at different depths
        for i in 1...3 {
            let layer = SKNode()
            layer.zPosition = -60 - CGFloat(i * 10)
            addChild(layer)
            parallaxLayers.append(layer)
        }
    }
    
    /// Update parallax layers based on camera movement
    func updateParallax() {
        guard let camera = gameCamera else { return }
        
        let cameraPosition = camera.position
        let basePosition = CGPoint(x: size.width / 2, y: size.height / 2)
        let offset = CGPoint(x: cameraPosition.x - basePosition.x, y: cameraPosition.y - basePosition.y)
        
        // Apply different parallax rates to each layer
        for (index, layer) in parallaxLayers.enumerated() {
            let parallaxRate = CGFloat(index + 1) * 0.1
            layer.position = CGPoint(x: -offset.x * parallaxRate, y: -offset.y * parallaxRate)
        }
    }
    
    // MARK: - Scene Lifecycle Overrides
    
    override func layoutForNewSize() {
        super.layoutForNewSize()
        
        // Update background effects for new size
        backgroundEffectNodes.forEach { $0.removeFromParent() }
        backgroundEffectNodes.removeAll()
        
        // Recreate background effects
        setupBackgroundEffects()
        
        // Update parallax layers
        updateParallax()
    }
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        // Update parallax continuously
        updateParallax()
    }
}

// MARK: - Preview Support

#if DEBUG
extension GameScene {
    static var preview: GameScene {
        let scene = GameScene()
        scene.size = CGSize(width: 390, height: 844) // iPhone 14 size
        return scene
    }
}

#Preview("GameScene Foundation") {
    SpriteKitContainer(scene: GameScene.preview)
        .ignoresSafeArea()
}
#endif
