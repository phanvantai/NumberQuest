//
//  MainMenuScene.swift
//  NumberQuest
//
//  Created by NumberQuest on 2024.
//

import SpriteKit
import SwiftUI

/// Main menu scene for NumberQuest
/// Provides animated entry point with game mode selection
class MainMenuScene: BaseGameScene {
    
    // MARK: - Properties
    
    private var titleNode: SKNode?
    private var menuButtons: [SKNode] = []
    private var characterNode: SKNode?
    private var animationTimer: Timer?
    
    // MARK: - Scene Setup
    
    override func setupScene() {
        super.setupScene()
        
        setupTitle()
        setupMenuButtons()
        setupCharacterAnimations()
        startBackgroundAnimations()
    }
    
    override func setupBackground() {
        super.setupBackground()
        
        // Animated gradient background with multiple colors
        createGradientBackground(colors: [
            UIColor(red: 0.1, green: 0.5, blue: 1.0, alpha: 1.0), // Sky blue
            UIColor(red: 0.3, green: 0.8, blue: 0.5, alpha: 1.0), // Green
            UIColor(red: 0.8, green: 0.4, blue: 0.9, alpha: 1.0), // Purple
            UIColor(red: 1.0, green: 0.6, blue: 0.2, alpha: 1.0)  // Orange
        ], animated: true)
        
        // Add floating particles for atmosphere
        addBackgroundParticles()
    }
    
    // MARK: - UI Setup
    
    private func setupTitle() {
        let titleContainer = SKNode()
        titleContainer.position = position(x: 0.5, y: 0.75)
        
        // Main title
        let titleLabel = NodeFactory.shared.createLabel(
            text: "NumberQuest",
            style: .gameTitle,
            color: .white
        )
        titleLabel.position = CGPoint.zero
        
        // Add shadow effect
        let shadowLabel = NodeFactory.shared.createLabel(
            text: "NumberQuest",
            style: .gameTitle,
            color: UIColor.black.withAlphaComponent(0.3)
        )
        shadowLabel.position = CGPoint(x: 3, y: -3)
        shadowLabel.zPosition = -1
        
        titleContainer.addChild(shadowLabel)
        titleContainer.addChild(titleLabel)
        
        // Add sparkles around title
        for i in 0..<8 {
            let sparkle = SKLabelNode(text: "✨")
            sparkle.fontName = "Baloo2-VariableFont_wght"
            sparkle.fontSize = 24
            sparkle.fontColor = .white
            
            let angle = Double(i) * .pi * 2 / 8
            let radius: CGFloat = 120
            sparkle.position = CGPoint(
                x: cos(angle) * radius,
                y: sin(angle) * radius
            )
            titleContainer.addChild(sparkle)
            
            // Animate sparkles
            let rotate = SKAction.repeatForever(
                SKAction.rotate(byAngle: .pi * 2, duration: 4.0 + Double(i) * 0.5)
            )
            let pulse = SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.scale(to: 1.2, duration: 0.8),
                    SKAction.scale(to: 0.8, duration: 0.8)
                ])
            )
            sparkle.run(SKAction.group([rotate, pulse]))
        }
        
        titleNode = titleContainer
        addChild(titleContainer)
        
        // Animate title entrance
        titleContainer.setScale(0.1)
        titleContainer.alpha = 0
        
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.8)
        let fadeIn = SKAction.fadeIn(withDuration: 0.8)
        let bounce = SKAction.sequence([
            SKAction.scale(to: 1.1, duration: 0.2),
            SKAction.scale(to: 1.0, duration: 0.2)
        ])
        
        titleContainer.run(SKAction.sequence([
            SKAction.group([scaleUp, fadeIn]),
            bounce
        ]))
    }
    
    private func setupMenuButtons() {
        let buttonData: [(text: String, action: SceneType)] = [
            ("Campaign", .campaignMap),
            ("Quick Play", .quickPlay),
            ("Progress", .progress),
            ("Settings", .settings)
        ]
        
        let buttonSize = CGSize(width: 250, height: 70)
        let startY: CGFloat = 0.55
        let spacing: CGFloat = 0.12
        
        for (index, data) in buttonData.enumerated() {
            let buttonY = startY - CGFloat(index) * spacing
            
            let button = createMenuButton(
                text: data.text,
                size: buttonSize,
                yPosition: buttonY
            ) { [weak self] in
                self?.navigateToScene(data.action)
            }
            
            menuButtons.append(button)
            addChild(button)
            
            // Animate button entrance with delay
            button.alpha = 0
            button.position.x -= 300
            
            let delay = SKAction.wait(forDuration: 0.3 + Double(index) * 0.1)
            let slideIn = SKAction.moveBy(x: 300, y: 0, duration: 0.5)
            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            let slideAndFade = SKAction.group([slideIn, fadeIn])
            
            button.run(SKAction.sequence([delay, slideAndFade]))
        }
    }
    
    private func createMenuButton(
        text: String,
        size: CGSize,
        yPosition: CGFloat,
        action: @escaping () -> Void
    ) -> SKNode {
        let container = SKNode()
        container.position = position(x: 0.5, y: yPosition)
        
        // Button background with gradient effect
        let buttonBackground = SKShapeNode(
            rectOf: size,
            cornerRadius: 15
        )
        
        // Color based on button type
        let buttonColor: UIColor
        switch text {
        case "Campaign":
            buttonColor = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 0.9)
        case "Quick Play":
            buttonColor = UIColor(red: 0.9, green: 0.5, blue: 0.2, alpha: 0.9)
        case "Progress":
            buttonColor = UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 0.9)
        case "Settings":
            buttonColor = UIColor(red: 0.7, green: 0.4, blue: 0.8, alpha: 0.9)
        default:
            buttonColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.9)
        }
        
        buttonBackground.fillColor = buttonColor
        buttonBackground.strokeColor = .white
        buttonBackground.lineWidth = 2
        
        // Add shadow
        let shadow = SKShapeNode(rectOf: size, cornerRadius: 15)
        shadow.fillColor = UIColor.black.withAlphaComponent(0.3)
        shadow.position = CGPoint(x: 0, y: -3)
        shadow.zPosition = -1
        
        // Button text
        let buttonLabel = NodeFactory.shared.createLabel(
            text: text,
            style: .buttonLarge,
            color: .white
        )
        buttonLabel.position = CGPoint.zero
        
        container.addChild(shadow)
        container.addChild(buttonBackground)
        container.addChild(buttonLabel)
        
        // Touch handling
        let touchNode = SKShapeNode(rectOf: size)
        touchNode.fillColor = .clear
        touchNode.strokeColor = .clear
        touchNode.name = "menuButton_\(text)"
        container.addChild(touchNode)
        
        // Store action in userData
        container.userData = NSMutableDictionary()
        container.userData?["action"] = action
        
        // Add hover and press animations
        addButtonAnimations(to: container, buttonBackground: buttonBackground)
        
        return container
    }
    
    private func addButtonAnimations(to container: SKNode, buttonBackground: SKShapeNode) {
        // Subtle breathing animation
        let breathe = SKAction.sequence([
            SKAction.scale(to: 1.02, duration: 2.0),
            SKAction.scale(to: 1.0, duration: 2.0)
        ])
        container.run(SKAction.repeatForever(breathe))
        
        // Color pulse
        let originalColor = buttonBackground.fillColor
        let brightColor = originalColor.withAlphaComponent(1.0)
        let colorPulse = SKAction.sequence([
            SKAction.run { buttonBackground.fillColor = brightColor },
            SKAction.wait(forDuration: 0.1),
            SKAction.run { buttonBackground.fillColor = originalColor },
            SKAction.wait(forDuration: 3.0)
        ])
        buttonBackground.run(SKAction.repeatForever(colorPulse))
    }
    
    private func setupCharacterAnimations() {
        // Add floating character mascot
        let character = SKLabelNode()
        character.text = "🧮" // Math-themed emoji
        character.fontSize = 60
        character.position = position(x: 0.85, y: 0.2)
        
        characterNode = character
        addChild(character)
        
        // Floating animation
        let float = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 15, duration: 2.0),
            SKAction.moveBy(x: 0, y: -15, duration: 2.0)
        ])
        character.run(SKAction.repeatForever(float))
        
        // Gentle rotation
        let rotate = SKAction.rotate(byAngle: .pi / 12, duration: 3.0)
        let rotateBack = SKAction.rotate(byAngle: -.pi / 6, duration: 6.0)
        let rotateForward = SKAction.rotate(byAngle: .pi / 12, duration: 3.0)
        let rotateSequence = SKAction.sequence([rotate, rotateBack, rotateForward])
        character.run(SKAction.repeatForever(rotateSequence))
    }
    
    private func addBackgroundParticles() {
        // Add subtle floating particles
        for _ in 0..<20 {
            let particle = SKLabelNode()
            particle.text = ["⭐", "✨", "🌟", "💫"].randomElement() ?? "⭐"
            particle.fontSize = CGFloat.random(in: 12...20)
            particle.alpha = 0.3
            particle.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            
            addChild(particle)
            
            // Floating animation
            let floatDistance = CGFloat.random(in: 50...150)
            let duration = TimeInterval.random(in: 8...15)
            
            let float = SKAction.sequence([
                SKAction.moveBy(x: CGFloat.random(in: -floatDistance...floatDistance),
                               y: floatDistance, duration: duration),
                SKAction.removeFromParent()
            ])
            
            particle.run(float)
            
            // Gentle fade and scale
            let fade = SKAction.sequence([
                SKAction.fadeIn(withDuration: 2.0),
                SKAction.wait(forDuration: duration - 4.0),
                SKAction.fadeOut(withDuration: 2.0)
            ])
            
            particle.run(fade)
        }
    }
    
    private func startBackgroundAnimations() {
        // Continuously spawn background particles
        let spawnParticle = SKAction.run { [weak self] in
            self?.addBackgroundParticles()
        }
        let wait = SKAction.wait(forDuration: 5.0)
        let spawnSequence = SKAction.sequence([spawnParticle, wait])
        
        run(SKAction.repeatForever(spawnSequence), withKey: "backgroundParticles")
    }
    
    // MARK: - Navigation
    
    private func navigateToScene(_ sceneType: SceneType) {
        // Play button press sound
        playSound(.buttonTap, haptic: .light)
        
        // Add button press feedback
        addButtonPressEffect()
        
        // Navigate after brief delay for feedback
        let delay = SKAction.wait(forDuration: 0.1)
        let navigate = SKAction.run {
            GameSceneManager.shared.presentScene(sceneType)
        }
        
        run(SKAction.sequence([delay, navigate]))
    }
    
    private func addButtonPressEffect() {
        // Quick screen flash for button press feedback
        let flash = SKShapeNode(rect: frame)
        flash.fillColor = UIColor.white.withAlphaComponent(0.1)
        flash.strokeColor = .clear
        flash.zPosition = 1000
        
        addChild(flash)
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.1)
        let remove = SKAction.removeFromParent()
        
        flash.run(SKAction.sequence([fadeOut, remove]))
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNodes = nodes(at: location)
        
        for node in touchedNodes {
            if let nodeName = node.name,
               nodeName.hasPrefix("menuButton_"),
               let parent = node.parent,
               let action = parent.userData?["action"] as? (() -> Void) {
                
                // Button press animation
                let scaleDown = SKAction.scale(to: 0.95, duration: 0.05)
                let scaleUp = SKAction.scale(to: 1.0, duration: 0.05)
                let pressAnimation = SKAction.sequence([scaleDown, scaleUp])
                
                parent.run(pressAnimation) {
                    action()
                }
                break
            }
        }
    }
    
    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        // Note: Background music would be handled by main SoundManager
        // For now, we'll skip background music to avoid audio conflicts
    }
    
    override func willMove(from view: SKView) {
        super.willMove(from: view)
        
        // Clean up animations
        removeAction(forKey: "backgroundParticles")
        animationTimer?.invalidate()
        animationTimer = nil
    }
}
