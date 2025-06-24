//
//  LoadingOverlayNode.swift
//  NumberQuest
//
//  Created by NumberQuest on 2024.
//

import SpriteKit

/// Loading overlay node with animated loading indicator
class LoadingOverlayNode: SKNode {
    
    // MARK: - Properties
    
    private let overlaySize: CGSize
    private var backgroundNode: SKShapeNode?
    private var loadingContainer: SKNode?
    private var loadingSpinner: SKShapeNode?
    private var loadingLabel: SKLabelNode?
    private var loadingDots: [SKLabelNode] = []
    
    // Animation properties
    private var spinnerRotation: SKAction?
    private var dotsAnimation: SKAction?
    
    // MARK: - Initialization
    
    init(size: CGSize) {
        self.overlaySize = size
        super.init()
        
        setupOverlay()
        setupLoadingIndicator()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupOverlay() {
        // Semi-transparent background
        let rect = CGRect(
            x: -overlaySize.width / 2,
            y: -overlaySize.height / 2,
            width: overlaySize.width,
            height: overlaySize.height
        )
        
        backgroundNode = SKShapeNode(rect: rect)
        backgroundNode?.fillColor = UIColor.black.withAlphaComponent(0.7)
        backgroundNode?.strokeColor = .clear
        backgroundNode?.zPosition = 0
        backgroundNode?.name = "background"
        addChild(backgroundNode!)
        
        // Loading container
        loadingContainer = SKNode()
        loadingContainer?.zPosition = 1
        addChild(loadingContainer!)
    }
    
    private func setupLoadingIndicator() {
        guard let loadingContainer = loadingContainer else { return }
        
        // Loading spinner
        loadingSpinner = SKShapeNode(circleOfRadius: 25)
        loadingSpinner?.strokeColor = .white
        loadingSpinner?.fillColor = .clear
        loadingSpinner?.lineWidth = 3
        loadingSpinner?.position = CGPoint(x: 0, y: 20)
        loadingContainer.addChild(loadingSpinner!)
        
        // Add spinner segments for better visual effect
        setupSpinnerSegments()
        
        // Loading text
        loadingLabel = NodeFactory.shared.createLabel(
            text: "Loading",
            style: .heading,
            color: .white
        )
        loadingLabel?.position = CGPoint(x: -30, y: -20)
        loadingContainer.addChild(loadingLabel!)
        
        // Animated dots
        setupLoadingDots()
        
        // Start animations
        startLoadingAnimations()
    }
    
    private func setupSpinnerSegments() {
        guard let loadingSpinner = loadingSpinner else { return }
        
        // Create spinner segments with different opacity for rotation effect
        for i in 0..<8 {
            let angle = CGFloat(i) * .pi / 4
            let segment = SKShapeNode()
            
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 20, y: 0))
            path.addLine(to: CGPoint(x: 25, y: 0))
            
            segment.path = path
            segment.strokeColor = UIColor.white.withAlphaComponent(1.0 - CGFloat(i) * 0.1)
            segment.lineWidth = 2
            segment.zRotation = angle
            
            loadingSpinner.addChild(segment)
        }
    }
    
    private func setupLoadingDots() {
        guard let loadingContainer = loadingContainer else { return }
        
        let dotSpacing: CGFloat = 8
        let startX: CGFloat = 10
        
        for i in 0..<3 {
            let dot = NodeFactory.shared.createLabel(
                text: ".",
                style: .heading,
                color: .white
            )
            dot.position = CGPoint(x: startX + CGFloat(i) * dotSpacing, y: -20)
            dot.name = "dot_\(i)"
            loadingContainer.addChild(dot)
            loadingDots.append(dot)
        }
    }
    
    // MARK: - Animations
    
    private func startLoadingAnimations() {
        startSpinnerAnimation()
        startDotsAnimation()
    }
    
    private func startSpinnerAnimation() {
        guard let loadingSpinner = loadingSpinner else { return }
        
        let rotation = SKAction.rotate(byAngle: .pi * 2, duration: 1.0)
        spinnerRotation = SKAction.repeatForever(rotation)
        
        loadingSpinner.run(spinnerRotation!, withKey: "spinner_rotation")
    }
    
    private func startDotsAnimation() {
        for (index, dot) in loadingDots.enumerated() {
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            let sequence = SKAction.sequence([fadeOut, fadeIn])
            let repeatForever = SKAction.repeatForever(sequence)
            
            // Stagger the animation
            let delay = SKAction.wait(forDuration: Double(index) * 0.2)
            let delayedAnimation = SKAction.sequence([delay, repeatForever])
            
            dot.run(delayedAnimation, withKey: "dot_animation")
        }
    }
    
    // MARK: - Public Methods
    
    /// Animate the loading overlay in
    func animateIn(completion: (() -> Void)? = nil) {
        // Initial state
        alpha = 0
        setScale(0.8)
        
        // Entrance animation
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        let entrance = SKAction.group([fadeIn, scaleUp])
        
        entrance.timingMode = .easeOut
        run(entrance) {
            completion?()
        }
    }
    
    /// Animate the loading overlay out
    func animateOut(completion: (() -> Void)? = nil) {
        // Stop animations
        stopLoadingAnimations()
        
        // Exit animation
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let scaleDown = SKAction.scale(to: 0.8, duration: 0.2)
        let exit = SKAction.group([fadeOut, scaleDown])
        
        exit.timingMode = .easeIn
        run(exit) {
            completion?()
        }
    }
    
    /// Update loading text
    func updateLoadingText(_ text: String) {
        loadingLabel?.text = text
    }
    
    // MARK: - Private Methods
    
    private func stopLoadingAnimations() {
        loadingSpinner?.removeAction(forKey: "spinner_rotation")
        
        for dot in loadingDots {
            dot.removeAction(forKey: "dot_animation")
        }
    }
    
    // MARK: - Cleanup
    
    deinit {
        stopLoadingAnimations()
    }
}
