//
//  MainMenuScene.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 26/6/25.
//

import SpriteKit
import GameplayKit

/// Main menu scene providing navigation to different game modes
class MainMenuScene: SKScene {
    
    // MARK: - UI Elements
    
    private var backgroundNode: SKSpriteNode!
    private var titleLabel: SKLabelNode!
    private var subtitleLabel: SKLabelNode!
    private var quickPlayButton: MenuButton!
    private var campaignButton: MenuButton!
    private var settingsButton: MenuButton!
    
    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
        // Set the scene manager view
        SceneManager.shared.setView(view)
        
        setupBackground()
        setupTitle()
        setupButtons()
        setupLayout()
        addAnimations()
        
        // Add some welcoming background music later
        // AudioManager.shared.playBackgroundMusic("menu_theme")
    }
    
    override func willMove(from view: SKView) {
        // Clean up when leaving the scene
        removeAllActions()
    }
    
    // MARK: - Setup Methods
    
    private func setupBackground() {
        // Create a gradient background
        backgroundNode = SKSpriteNode(color: UIColor(red: 0.1, green: 0.2, blue: 0.4, alpha: 1.0), size: size)
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode.zPosition = -1
        addChild(backgroundNode)
        
        // Add some decorative stars
        addStars()
    }
    
    private func setupTitle() {
        // Main title with FzWitchMagic font
        titleLabel = SKLabelNode()
        titleLabel.configureAsGameTitle("NumberQuest", size: .gameTitle, color: .white)
        titleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.8)
        titleLabel.zPosition = 1
        addChild(titleLabel)
        
        // Subtitle with WowDino font
        subtitleLabel = SKLabelNode()
        subtitleLabel.configureAsGameUI("Math Adventure for Kids", size: .large, color: UIColor(white: 0.9, alpha: 1.0))
        subtitleLabel.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        subtitleLabel.zPosition = 1
        addChild(subtitleLabel)
    }
    
    private func setupButtons() {
        // Quick Play Button
        quickPlayButton = MenuButton(
            title: "Quick Play",
            icon: "⚡",
            size: CGSize(width: 280, height: 70)
        ) { [weak self] in
            self?.startQuickPlay()
        }
        
        // Campaign Button
        campaignButton = MenuButton(
            title: "Adventure",
            icon: "🗺️",
            size: CGSize(width: 280, height: 70)
        ) { [weak self] in
            self?.startCampaign()
        }
        
        // Settings Button
        settingsButton = MenuButton(
            title: "Settings",
            icon: "⚙️",
            size: CGSize(width: 280, height: 70)
        ) { [weak self] in
            self?.showSettings()
        }
        
        addChild(quickPlayButton)
        addChild(campaignButton)
        addChild(settingsButton)
    }
    
    private func setupLayout() {
        let centerX = size.width / 2
        let buttonSpacing: CGFloat = 90
        let startY = size.height * 0.55
        
        quickPlayButton.position = CGPoint(x: centerX, y: startY)
        campaignButton.position = CGPoint(x: centerX, y: startY - buttonSpacing)
        settingsButton.position = CGPoint(x: centerX, y: startY - buttonSpacing * 2)
    }
    
    private func addStars() {
        // Add decorative stars in the background
        for _ in 0..<20 {
            let star = SKLabelNode(text: "⭐")
            star.fontSize = CGFloat.random(in: 12...24)
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            star.alpha = CGFloat.random(in: 0.3...0.8)
            star.zPosition = 0
            
            // Add twinkling animation
            let fadeOut = SKAction.fadeAlpha(to: 0.2, duration: Double.random(in: 1...3))
            let fadeIn = SKAction.fadeAlpha(to: 0.8, duration: Double.random(in: 1...3))
            let twinkle = SKAction.sequence([fadeOut, fadeIn])
            star.run(SKAction.repeatForever(twinkle))
            
            backgroundNode.addChild(star)
        }
    }
    
    private func addAnimations() {
        // Animate title appearance
        titleLabel.alpha = 0
        titleLabel.setScale(0.5)
        
        let fadeIn = SKAction.fadeIn(withDuration: 1.0)
        let scaleUp = SKAction.scale(to: 1.0, duration: 1.0)
        let group = SKAction.group([fadeIn, scaleUp])
        titleLabel.run(group)
        
        // Animate subtitle
        subtitleLabel.alpha = 0
        subtitleLabel.run(SKAction.fadeIn(withDuration: 1.5))
        
        // Animate buttons with staggered timing
        let buttons = [quickPlayButton, campaignButton, settingsButton]
        for (index, button) in buttons.enumerated() {
            button?.alpha = 0
            button?.position.x -= 100
            
            let delay = SKAction.wait(forDuration: 0.5 + Double(index) * 0.2)
            let moveIn = SKAction.moveBy(x: 100, y: 0, duration: 0.5)
            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            let appear = SKAction.group([moveIn, fadeIn])
            let sequence = SKAction.sequence([delay, appear])
            
            button?.run(sequence)
        }
    }
    
    // MARK: - Button Actions
    
    private func startQuickPlay() {
        print("🎮 Starting Quick Play mode...")
        
        // Add button press sound effect
        // AudioManager.shared.playSound("button_tap")
        
        SceneManager.shared.showQuickPlay()
    }
    
    private func startCampaign() {
        print("🗺️ Starting Campaign mode...")
        
        // Show coming soon message for now
        showComingSoonAlert(for: "Adventure Mode")
    }
    
    private func showSettings() {
        print("⚙️ Opening Settings...")
        
        // Show coming soon message for now
        showComingSoonAlert(for: "Settings")
    }
    
    private func showComingSoonAlert(for feature: String) {
        // Create a simple popup overlay
        let overlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: size)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        overlay.zPosition = 100
        
        let popup = SKShapeNode(rectOf: CGSize(width: 300, height: 150), cornerRadius: 20)
        popup.fillColor = UIColor.white
        popup.strokeColor = UIColor.blue
        popup.lineWidth = 3
        popup.position = CGPoint(x: 0, y: 0)
        
        let titleLabel = SKLabelNode(fontNamed: "Helvetica-Bold")
        titleLabel.text = "Coming Soon!"
        titleLabel.fontSize = 24
        titleLabel.fontColor = UIColor.black
        titleLabel.position = CGPoint(x: 0, y: 20)
        
        let messageLabel = SKLabelNode(fontNamed: "Helvetica")
        messageLabel.text = "\(feature) is under development"
        messageLabel.fontSize = 16
        messageLabel.fontColor = UIColor.gray
        messageLabel.position = CGPoint(x: 0, y: -10)
        
        let closeButton = MenuButton(
            title: "OK",
            size: CGSize(width: 100, height: 40)
        ) { [weak self] in
            overlay.removeFromParent()
        }
        closeButton.position = CGPoint(x: 0, y: -50)
        closeButton.setScale(0.7)
        
        popup.addChild(titleLabel)
        popup.addChild(messageLabel)
        popup.addChild(closeButton)
        overlay.addChild(popup)
        
        addChild(overlay)
        
        // Animate popup appearance
        popup.setScale(0.5)
        popup.alpha = 0
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        popup.run(SKAction.group([scaleUp, fadeIn]))
    }
    
    // MARK: - Touch Handling (for any missed touches)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Handle any touches that weren't handled by buttons
        super.touchesBegan(touches, with: event)
    }
}
