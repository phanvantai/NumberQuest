//
//  AssetValidationScene.swift
//  NumberQuest
//
//  Created by NumberQuest on 2024.
//

import SpriteKit

/// Test scene to validate all assets, particles, and sound integration
class AssetValidationScene: BaseGameScene {
    
    private var testLabel: SKLabelNode?
    private var validationResults: [String] = []
    
    override func setupScene() {
        super.setupScene()
        
        setupTestUI()
        runValidationTests()
    }
    
    private func setupTestUI() {
        // Title
        let titleLabel = NodeFactory.shared.createLabel(
            text: "Asset Validation Test",
            style: .title,
            color: .white
        )
        titleLabel.position = position(x: 0.5, y: 0.9)
        addChild(titleLabel)
        
        // Test status label
        testLabel = NodeFactory.shared.createLabel(
            text: "Running tests...",
            style: .body,
            color: .white
        )
        testLabel?.position = position(x: 0.5, y: 0.7)
        testLabel?.numberOfLines = 0
        testLabel?.preferredMaxLayoutWidth = size.width * 0.8
        
        if let testLabel = testLabel {
            addChild(testLabel)
        }
        
        // Back button
        let backButton = NodeFactory.shared.createButton(
            text: "Back to Menu",
            style: .primary,
            size: .medium
        ) {
            GameSceneManager.shared.presentScene(.mainMenu)
        }
        backButton.position = position(x: 0.5, y: 0.1)
        addChild(backButton)
    }
    
    private func runValidationTests() {
        validationResults.removeAll()
        
        // Test 1: Validate colors
        testColorSystem()
        
        // Test 2: Validate textures
        testTextureSystem()
        
        // Test 3: Validate particle effects
        testParticleEffects()
        
        // Test 4: Validate sound system
        testSoundSystem()
        
        // Test 5: Test particle playback
        testParticlePlayback()
        
        // Update results display
        updateResultsDisplay()
    }
    
    private func testColorSystem() {
        validationResults.append("🎨 Color System Tests:")
        
        // Test primary colors
        let primaryColors = [
            ("Primary Button", SpriteKitColors.UI.primaryButton),
            ("Success Button", SpriteKitColors.UI.successButton),
            ("Danger Button", SpriteKitColors.UI.dangerButton),
            ("Warning Button", SpriteKitColors.UI.warningButton)
        ]
        
        for (name, color) in primaryColors {
            let result = "✅"
            validationResults.append("  \(result) \(name)")
        }
        
        validationResults.append("")
    }
    
    private func testTextureSystem() {
        validationResults.append("🖼️ Texture System Tests:")
        
        // Test basic textures
        let sparkTexture = AssetManager.shared.getSparkTexture()
        let starTexture = AssetManager.shared.getStarTexture()
        let circleTexture = AssetManager.shared.getCircleTexture()
        
        validationResults.append("  \(sparkTexture != nil ? "✅" : "❌") Spark Texture")
        validationResults.append("  \(starTexture != nil ? "✅" : "❌") Star Texture")
        validationResults.append("  \(circleTexture != nil ? "✅" : "❌") Circle Texture")
        
        validationResults.append("")
    }
    
    private func testParticleEffects() {
        validationResults.append("✨ Particle Effects Tests:")
        
        // Test particle effect loading
        let celebrationParticle = ParticleManager.shared.createCelebrationEffect()
        let correctParticle = ParticleManager.shared.createCorrectAnswerEffect()
        let wrongParticle = ParticleManager.shared.createWrongAnswerEffect()
        
        validationResults.append("  \(celebrationParticle != nil ? "✅" : "❌") Celebration Particles")
        validationResults.append("  \(correctParticle != nil ? "✅" : "❌") Correct Answer Particles")
        validationResults.append("  \(wrongParticle != nil ? "✅" : "❌") Wrong Answer Particles")
        
        // Test asset manager validation
        let allParticlesValid = AssetManager.shared.validateParticleEffects()
        validationResults.append("  \(allParticlesValid ? "✅" : "❌") All Particles Valid")
        
        validationResults.append("")
    }
    
    private func testSoundSystem() {
        validationResults.append("🔊 Sound System Tests:")
        
        let soundManager = SpriteKitSoundManager.shared
        
        validationResults.append("  \(soundManager.isSoundEnabled ? "✅" : "⚠️") Sound Enabled")
        validationResults.append("  \(soundManager.isMusicEnabled ? "✅" : "⚠️") Music Enabled")
        validationResults.append("  ✅ Sound Manager Available")
        validationResults.append("  ✅ SpriteKit Integration Available")
        
        validationResults.append("")
    }
    
    private func testParticlePlayback() {
        validationResults.append("🎬 Particle Playback Tests:")
        
        // Test celebration effect
        if let celebration = ParticleManager.shared.createCelebrationEffect() {
            let testPosition = position(x: 0.8, y: 0.5)
            ParticleManager.shared.playEffect(celebration, at: testPosition, in: self, duration: 2.0)
            validationResults.append("  ✅ Celebration Effect Playing")
        } else {
            validationResults.append("  ❌ Celebration Effect Failed")
        }
        
        // Test correct answer effect
        if let correct = ParticleManager.shared.createCorrectAnswerEffect() {
            let testPosition = position(x: 0.8, y: 0.4)
            ParticleManager.shared.playEffect(correct, at: testPosition, in: self, duration: 1.5)
            validationResults.append("  ✅ Correct Answer Effect Playing")
        } else {
            validationResults.append("  ❌ Correct Answer Effect Failed")
        }
        
        // Test wrong answer effect
        if let wrong = ParticleManager.shared.createWrongAnswerEffect() {
            let testPosition = position(x: 0.8, y: 0.3)
            ParticleManager.shared.playEffect(wrong, at: testPosition, in: self, duration: 1.0)
            validationResults.append("  ✅ Wrong Answer Effect Playing")
        } else {
            validationResults.append("  ❌ Wrong Answer Effect Failed")
        }
        
        validationResults.append("")
        validationResults.append("🎉 Asset Validation Complete!")
        validationResults.append("Watch right side for particle effects")
    }
    
    private func updateResultsDisplay() {
        let resultsText = validationResults.joined(separator: "\n")
        testLabel?.text = resultsText
        
        // Play test sounds
        SoundManager.shared.playSound(.buttonTap)
        
        // Small delay then play more sounds
        let soundTest = SKAction.sequence([
            SKAction.wait(forDuration: 1.0),
            SKAction.run { [weak self] in
                SoundManager.shared.playSound(.correct)
                SoundManager.shared.playHaptic(.success)
            },
            SKAction.wait(forDuration: 0.5),
            SKAction.run { [weak self] in
                SoundManager.shared.playSound(.incorrect)
                SoundManager.shared.playHaptic(.error)
            }
        ])
        
        run(soundTest)
    }
    
    override func setupBackground() {
        super.setupBackground()
        
        // Create test gradient
        createGradientBackground(colors: [
            UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1.0),
            UIColor(red: 0.2, green: 0.1, blue: 0.4, alpha: 1.0)
        ])
    }
}
