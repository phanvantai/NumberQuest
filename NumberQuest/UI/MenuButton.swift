//
//  MenuButton.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 26/6/25.
//

import SpriteKit

/// Custom button designed for children with large touch targets and visual feedback
class MenuButton: SKNode {
    
    // MARK: - Properties
    
    private let backgroundNode: SKShapeNode
    private let labelNode: SKLabelNode
    private let iconNode: SKLabelNode?
    
    private let action: () -> Void
    private let buttonSize: CGSize
    
    // Colors for different states
    private let normalColor = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0) // Blue
    private let highlightedColor = UIColor(red: 0.1, green: 0.5, blue: 0.9, alpha: 1.0) // Darker blue
    private let textColor = UIColor.white
    
    // MARK: - Initialization
    
    init(title: String, icon: String? = nil, size: CGSize = CGSize(width: 280, height: 70), action: @escaping () -> Void) {
        self.action = action
        self.buttonSize = size
        
        // Create background with rounded corners
        self.backgroundNode = SKShapeNode(rectOf: size, cornerRadius: 16)
        self.backgroundNode.fillColor = normalColor
        self.backgroundNode.strokeColor = UIColor.white
        self.backgroundNode.lineWidth = 3
        
        // Create title label with custom font
        self.labelNode = SKLabelNode()
        self.labelNode.configureAsMenuButton(title, size: .large, color: textColor)
        
        // Create icon if provided
        if let iconText = icon {
            self.iconNode = SKLabelNode(text: iconText)
            self.iconNode?.fontSize = 32
            self.iconNode?.verticalAlignmentMode = .center
        } else {
            self.iconNode = nil
        }
        
        super.init()
        
        setupButton()
        setupAccessibility(title: title)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupButton() {
        // Add background
        addChild(backgroundNode)
        
        // Position icon and text
        if let iconNode = iconNode {
            // Icon on the left, text on the right
            iconNode.position = CGPoint(x: -60, y: 0)
            labelNode.position = CGPoint(x: 20, y: 0)
            addChild(iconNode)
        } else {
            // Center the text
            labelNode.position = CGPoint(x: 0, y: 0)
        }
        
        addChild(labelNode)
        
        // Enable touch interaction
        isUserInteractionEnabled = true
        
        // Add subtle animation
        addIdleAnimation()
    }
    
    private func setupAccessibility(title: String) {
        // Make button accessible for VoiceOver
        self.isAccessibilityElement = true
        self.accessibilityLabel = title
        self.accessibilityTraits = .button
        self.accessibilityHint = "Double tap to select \(title)"
    }
    
    private func addIdleAnimation() {
        let scaleUp = SKAction.scale(to: 1.05, duration: 2.0)
        let scaleDown = SKAction.scale(to: 0.95, duration: 2.0)
        let sequence = SKAction.sequence([scaleUp, scaleDown])
        let forever = SKAction.repeatForever(sequence)
        
        run(forever, withKey: "idleAnimation")
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check if touch is within button bounds
        if backgroundNode.contains(location) {
            animatePressed()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check if touch ended within button bounds
        if backgroundNode.contains(location) {
            animateRelease()
            // Execute action after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.action()
            }
        } else {
            animateRelease()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        animateRelease()
    }
    
    // MARK: - Animations
    
    private func animatePressed() {
        removeAction(forKey: "idleAnimation")
        
        backgroundNode.fillColor = highlightedColor
        
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        run(scaleDown)
        
        // Add haptic feedback for better UX
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func animateRelease() {
        backgroundNode.fillColor = normalColor
        
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        let completion = SKAction.run { [weak self] in
            self?.addIdleAnimation()
        }
        let sequence = SKAction.sequence([scaleUp, completion])
        run(sequence)
    }
    
    // MARK: - Public Methods
    
    func setEnabled(_ enabled: Bool) {
        isUserInteractionEnabled = enabled
        alpha = enabled ? 1.0 : 0.5
        
        if enabled {
            addIdleAnimation()
        } else {
            removeAction(forKey: "idleAnimation")
        }
    }
}
