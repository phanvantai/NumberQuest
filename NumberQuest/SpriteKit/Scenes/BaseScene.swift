//
//  BaseScene.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 21/6/25.
//

import SpriteKit
import SwiftUI

/// Base class for all SpriteKit scenes in NumberQuest
/// Provides common functionality, layout helpers, and consistent setup
class BaseScene: SKScene {
    
    // MARK: - Properties
    
    /// Safe area insets for proper layout
    var safeAreaInsets: UIEdgeInsets = .zero
    
    /// Coordinate system for responsive design
    var coordinateSystem: CoordinateSystem!
    
    /// Node factory for creating UI components
    let nodeFactory = NodeFactory.shared
    
    /// Game data reference
    var gameData: GameData {
        return GameData.shared
    }
    
    /// Background node for consistent styling
    private var backgroundNode: SKNode?
    
    /// Loading overlay node
    private var loadingOverlay: SKNode?
    
    /// Whether the scene is currently loading
    private(set) var isLoading = false
    
    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Initialize coordinate system
        setupCoordinateSystem()
        
        setupScene()
        setupBackground()
        setupLayout()
        setupContent()
    }
    
    override func didChangeSize(_ oldSize: CGSize) {
        super.didChangeSize(oldSize)
        updateCoordinateSystem()
        updateLayout()
    }
    
    // MARK: - Setup Methods (Override in subclasses)
    
    /// Basic scene setup - called first
    func setupScene() {
        // Configure basic scene properties
        self.scaleMode = .aspectFill
        self.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        // Setup assets for this scene
        AssetManager.shared.setupForScene(self)
        
        // Update safe area from view controller if available
        if let viewController = view?.next as? UIViewController {
            safeAreaInsets = viewController.view.safeAreaInsets
        }
    }
    
    /// Setup background elements
    func setupBackground() {
        // Use enhanced background with particles by default
        createEnhancedBackground(withParticles: true)
    }
    
    /// Setup responsive layout system
    func setupLayout() {
        // Override in subclasses for specific layout needs
    }
    
    /// Setup scene-specific content
    func setupContent() {
        // Override in subclasses to add content
    }
    
    /// Update layout when size changes
    func updateLayout() {
        // Override in subclasses for responsive updates
    }
    
    // MARK: - Coordinate System Setup
    
    /// Initialize coordinate system with current scene size
    private func setupCoordinateSystem() {
        // Update safe area from view controller if available
        if let viewController = view?.next as? UIViewController {
            safeAreaInsets = viewController.view.safeAreaInsets
        }
        
        coordinateSystem = CoordinateSystem(sceneSize: size, safeAreaInsets: safeAreaInsets)
        GlobalCoordinateSystem.setup(sceneSize: size, safeAreaInsets: safeAreaInsets)
    }
    
    /// Update coordinate system when size changes
    private func updateCoordinateSystem() {
        coordinateSystem = CoordinateSystem(sceneSize: size, safeAreaInsets: safeAreaInsets)
        GlobalCoordinateSystem.update(sceneSize: size)
    }
    
    // MARK: - Loading State Management
    
    /// Show loading overlay
    func showLoading(message: String = "Loading...") {
        guard !isLoading else { return }
        
        isLoading = true
        
        let overlay = SKNode()
        overlay.name = "loadingOverlay"
        overlay.zPosition = 1000
        
        // Semi-transparent background
        let background = SKSpriteNode(color: .black.withAlphaComponent(0.7), size: size)
        background.position = CGPoint(x: 0, y: 0)
        overlay.addChild(background)
        
        // Loading indicator
        let loadingIndicator = nodeFactory.createLoadingIndicator()
        loadingIndicator.position = CGPoint(x: 0, y: 50)
        overlay.addChild(loadingIndicator)
        
        // Loading message
        let messageLabel = SKLabelNode(text: message, style: .heading)
        messageLabel.position = CGPoint(x: 0, y: -20)
        overlay.addChild(messageLabel)
        
        addChild(overlay)
        loadingOverlay = overlay
        
        // Fade in animation
        overlay.alpha = 0
        overlay.run(SKAction.fadeIn(withDuration: 0.3))
    }
    
    /// Hide loading overlay
    func hideLoading() {
        guard isLoading, let overlay = loadingOverlay else { return }
        
        isLoading = false
        
        overlay.run(SKAction.fadeOut(withDuration: 0.3)) {
            overlay.removeFromParent()
            self.loadingOverlay = nil
        }
    }
    
    // MARK: - Enhanced Layout Helpers
    
    /// Position node using relative coordinates with coordinate system
    func positionNode(_ node: SKNode, relativeX: CGFloat, relativeY: CGFloat) {
        node.position = coordinateSystem.absolutePosition(relativeX: relativeX, relativeY: relativeY)
    }
    
    /// Position node at screen edge with safe area consideration
    func positionNodeAtEdge(_ node: SKNode, edge: ScreenEdge, padding: CGFloat = 20) {
        node.position = coordinateSystem.edgePosition(edge, padding: padding)
    }
    
    /// Create a grid layout of nodes
    func layoutNodesInGrid(_ nodes: [SKNode], columns: Int, itemSize: CGSize, spacing: CGFloat = 10, centerOffset: CGPoint = .zero) {
        let rows = Int(ceil(Double(nodes.count) / Double(columns)))
        let positions = coordinateSystem.gridPositions(
            columns: columns,
            rows: rows,
            itemSize: itemSize,
            spacing: spacing,
            centerOffset: centerOffset
        )
        
        for (index, node) in nodes.enumerated() {
            let row = index / columns
            let col = index % columns
            
            if row < positions.count && col < positions[row].count {
                let targetPosition = positions[row][col]
                
                // Animate to position if node is already in scene
                if node.parent != nil {
                    let moveAction = SKAction.move(to: targetPosition, duration: coordinateSystem.animationDuration(0.3))
                    moveAction.timingMode = .easeOut
                    node.run(moveAction)
                } else {
                    node.position = targetPosition
                }
            }
        }
    }
    
    // MARK: - Animation Helpers
    
    /// Animate node entrance with bounce effect
    func animateNodeEntrance(_ node: SKNode, delay: TimeInterval = 0) {
        node.alpha = 0
        node.setScale(0.1)
        
        let wait = SKAction.wait(forDuration: delay)
        let fadeIn = SKAction.fadeIn(withDuration: coordinateSystem.animationDuration(0.3))
        let scaleUp = SKAction.scale(to: 1.0, duration: coordinateSystem.animationDuration(0.4))
        scaleUp.timingMode = .easeOut
        
        let bounceUp = SKAction.scale(to: 1.1, duration: coordinateSystem.animationDuration(0.1))
        let bounceDown = SKAction.scale(to: 1.0, duration: coordinateSystem.animationDuration(0.1))
        let bounce = SKAction.sequence([bounceUp, bounceDown])
        
        let entrance = SKAction.group([fadeIn, scaleUp])
        let sequence = SKAction.sequence([wait, entrance, bounce])
        
        node.run(sequence)
    }
    
    /// Animate node exit
    func animateNodeExit(_ node: SKNode, completion: @escaping () -> Void = {}) {
        let fadeOut = SKAction.fadeOut(withDuration: coordinateSystem.animationDuration(0.2))
        let scaleDown = SKAction.scale(to: 0.1, duration: coordinateSystem.animationDuration(0.2))
        let exit = SKAction.group([fadeOut, scaleDown])
        let remove = SKAction.removeFromParent()
        let completionAction = SKAction.run(completion)
        
        let sequence = SKAction.sequence([exit, remove, completionAction])
        node.run(sequence)
    }
    
    /// Animate scene transition
    func animateSceneTransition(completion: @escaping () -> Void = {}) {
        let overlay = SKSpriteNode(color: .black, size: size)
        overlay.position = CGPoint(x: 0, y: 0)
        overlay.zPosition = 999
        overlay.alpha = 0
        addChild(overlay)
        
        let fadeIn = SKAction.fadeIn(withDuration: coordinateSystem.animationDuration(0.3))
        let wait = SKAction.wait(forDuration: 0.1)
        let fadeOut = SKAction.fadeOut(withDuration: coordinateSystem.animationDuration(0.3))
        let remove = SKAction.removeFromParent()
        let completionAction = SKAction.run(completion)
        
        let sequence = SKAction.sequence([fadeIn, wait, completionAction, fadeOut, remove])
        overlay.run(sequence)
    }
    
    // MARK: - Enhanced Background Creation
    
    /// Create animated gradient background with particles
    func createEnhancedBackground(withParticles: Bool = true) {
        backgroundNode?.removeFromParent()
        
        let backgroundContainer = SKNode()
        backgroundContainer.name = "enhancedBackground"
        backgroundContainer.zPosition = -100
        
        // Create gradient layers
        let gradientColors: [(color: UIColor, alpha: CGFloat, scale: CGFloat)] = [
            (.nqBlue, 1.0, 1.0),
            (.nqPurple, 0.8, 1.1),
            (.nqPink, 0.6, 1.2),
            (.nqCoral, 0.4, 1.3)
        ]
        
        for (index, colorInfo) in gradientColors.enumerated() {
            let rect = SKSpriteNode(color: colorInfo.color, size: CGSize(width: size.width * colorInfo.scale, height: size.height * colorInfo.scale))
            rect.alpha = colorInfo.alpha
            rect.position = CGPoint(x: 0, y: 0)
            rect.zPosition = CGFloat(-90 + index)
            
            // Add subtle animation
            let rotate = SKAction.rotate(byAngle: CGFloat.pi * 2, duration: 60.0 + Double(index * 10))
            rect.run(SKAction.repeatForever(rotate))
            
            backgroundContainer.addChild(rect)
        }
        
        // Add floating elements if requested
        if withParticles {
            let floatingElements = nodeFactory.createFloatingElements(
                count: coordinateSystem.particleCount(15),
                in: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height)
            )
            floatingElements.forEach { backgroundContainer.addChild($0) }
        }
        
        addChild(backgroundContainer)
        backgroundNode = backgroundContainer
    }
    
    // MARK: - Scene Transition Helpers
    
    /// Transition to another scene with animation
    func transitionToScene(_ scene: SKScene, transition: SKTransition = SKTransition.fade(withDuration: 0.5)) {
        scene.scaleMode = self.scaleMode
        view?.presentScene(scene, transition: transition)
    }
    
    /// Present scene modally (for popups, settings, etc.)
    func presentModalScene(_ scene: SKScene) {
        let transition = SKTransition.moveIn(with: .up, duration: 0.3)
        view?.presentScene(scene, transition: transition)
    }
}

// MARK: - Supporting Types

enum AnchorPoint {
    case center
    case topLeft, topRight, bottomLeft, bottomRight
    case top, bottom, left, right
}
