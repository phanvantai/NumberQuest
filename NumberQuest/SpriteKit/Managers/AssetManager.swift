//
//  AssetManager.swift
//  NumberQuest
//
//  Created by TaiPV on 24/6/25.
//

import SpriteKit
import SwiftUI

/// Centralized asset management system for SpriteKit textures, sounds, and resources
class AssetManager {
    
    // MARK: - Singleton
    static let shared = AssetManager()
    private init() {}
    
    // MARK: - Texture Caching
    private var textureCache: [String: SKTexture] = [:]
    private var textureAtlasCache: [String: SKTextureAtlas] = [:]
    
    // MARK: - Asset Names
    struct TextureNames {
        // Particle Textures
        static let spark = "spark"
        static let star = "star"
        static let circle = "circle"
        static let confetti = "confetti"
        
        // UI Elements
        static let button = "button"
        static let buttonPressed = "button_pressed"
        static let cardBackground = "card_background"
        static let progressBarBackground = "progress_bar_bg"
        static let progressBarFill = "progress_bar_fill"
        
        // Characters (for future use)
        static let characterIdle = "character_idle"
        static let characterHappy = "character_happy"
        static let characterSad = "character_sad"
    }
    
    struct ParticleNames {
        static let celebration = "CelebrationParticles"
        static let correctAnswer = "CorrectAnswerParticles"
        static let wrongAnswer = "WrongAnswerParticles"
        
        // Background Elements
        static let cloudSmall = "cloud_small"
        static let cloudLarge = "cloud_large"
        static let starBackground = "star_bg"
    }
    
    struct AtlasNames {
        static let ui = "UI"
        static let particles = "Particles"
        static let characters = "Characters"
        static let backgrounds = "Backgrounds"
    }
    
    // MARK: - Texture Loading
    
    /// Load and cache a texture by name
    func texture(named name: String) -> SKTexture? {
        // Check cache first
        if let cachedTexture = textureCache[name] {
            return cachedTexture
        }
        
        // Try to load texture
        let texture = SKTexture(imageNamed: name)
        
        // Only cache if texture exists (not the default missing texture)
        if texture.size() != CGSize(width: 32, height: 32) { // Default missing texture size
            textureCache[name] = texture
            return texture
        }
        
        // Return nil if texture doesn't exist
        return nil
    }
    
    /// Load texture atlas and cache it
    func textureAtlas(named name: String) -> SKTextureAtlas? {
        // Check cache first
        if let cachedAtlas = textureAtlasCache[name] {
            return cachedAtlas
        }
        
        // Try to load atlas
        let atlas = SKTextureAtlas(named: name)
        textureAtlasCache[name] = atlas
        return atlas
    }
    
    /// Create placeholder textures for missing assets
    func createPlaceholderTexture(size: CGSize, color: UIColor) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
        return SKTexture(image: image)
    }
    
    // MARK: - Specific Asset Getters
    
    /// Get spark texture for particle effects
    func sparkTexture() -> SKTexture {
        if let texture = texture(named: TextureNames.spark) {
            return texture
        }
        
        // Create placeholder spark texture
        return createSparkTexture()
    }
    
    /// Get star texture for celebrations
    func starTexture() -> SKTexture {
        if let texture = texture(named: TextureNames.star) {
            return texture
        }
        
        // Create placeholder star texture
        return createStarTexture()
    }
    
    /// Get circle texture for particles
    func circleTexture() -> SKTexture {
        if let texture = texture(named: TextureNames.circle) {
            return texture
        }
        
        // Create placeholder circle texture
        return createCircleTexture()
    }
    
    // MARK: - Procedural Texture Generation
    
    private func createSparkTexture() -> SKTexture {
        let size = CGSize(width: 16, height: 16)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            let rect = CGRect(origin: .zero, size: size)
            
            // Create spark gradient
            let colors = [UIColor.yellow.cgColor, UIColor.orange.cgColor, UIColor.clear.cgColor]
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: [0, 0.7, 1])!
            
            // Draw radial gradient
            context.cgContext.drawRadialGradient(
                gradient,
                startCenter: CGPoint(x: size.width/2, y: size.height/2),
                startRadius: 0,
                endCenter: CGPoint(x: size.width/2, y: size.height/2),
                endRadius: size.width/2,
                options: []
            )
        }
        
        let texture = SKTexture(image: image)
        textureCache[TextureNames.spark] = texture
        return texture
    }
    
    private func createStarTexture() -> SKTexture {
        let size = CGSize(width: 20, height: 20)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            UIColor.yellow.setFill()
            
            // Create simple star shape
            let path = UIBezierPath()
            let center = CGPoint(x: size.width/2, y: size.height/2)
            let radius: CGFloat = 8
            
            for i in 0..<10 {
                let angle = CGFloat(i) * .pi / 5
                let pointRadius = (i % 2 == 0) ? radius : radius * 0.5
                let x = center.x + cos(angle) * pointRadius
                let y = center.y + sin(angle) * pointRadius
                
                if i == 0 {
                    path.move(to: CGPoint(x: x, y: y))
                } else {
                    path.addLine(to: CGPoint(x: x, y: y))
                }
            }
            path.close()
            path.fill()
        }
        
        let texture = SKTexture(image: image)
        textureCache[TextureNames.star] = texture
        return texture
    }
    
    private func createCircleTexture() -> SKTexture {
        let size = CGSize(width: 12, height: 12)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            UIColor.white.setFill()
            let rect = CGRect(origin: .zero, size: size)
            context.cgContext.fillEllipse(in: rect)
        }
        
        let texture = SKTexture(image: image)
        textureCache[TextureNames.circle] = texture
        return texture
    }
    
    // MARK: - Memory Management
    
    /// Clear texture cache to free memory
    func clearCache() {
        textureCache.removeAll()
        textureAtlasCache.removeAll()
    }
    
    /// Preload commonly used textures
    func preloadCommonTextures() {
        // Preload particle textures
        _ = sparkTexture()
        _ = starTexture()
        _ = circleTexture()
        
        // Preload any other commonly used assets
        _ = texture(named: TextureNames.button)
    }
    
    // MARK: - Asset Validation
    
    /// Check if all required assets are available
    func validateAssets() -> [String] {
        var missingAssets: [String] = []
        
        let requiredTextures = [
            TextureNames.spark,
            TextureNames.star,
            TextureNames.circle
        ]
        
        for textureName in requiredTextures {
            if texture(named: textureName) == nil {
                missingAssets.append(textureName)
            }
        }
        
        return missingAssets
    }
    
    // MARK: - Particle Effects
    
    /// Validate that all required particle effects are available
    func validateParticleEffects() -> Bool {
        let requiredParticles = [
            ParticleNames.celebration,
            ParticleNames.correctAnswer,
            ParticleNames.wrongAnswer
        ]
        
        var allValid = true
        
        for particleName in requiredParticles {
            if Bundle.main.path(forResource: particleName, ofType: "sks") == nil {
                print("⚠️ AssetManager: Missing particle effect: \(particleName).sks")
                allValid = false
            } else {
                print("✅ AssetManager: Found particle effect: \(particleName).sks")
            }
        }
        
        return allValid
    }
    
    /// Load a particle effect from the bundle
    func loadParticleEffect(named name: String) -> SKEmitterNode? {
        guard let path = Bundle.main.path(forResource: name, ofType: "sks") else {
            print("⚠️ AssetManager: Particle effect not found: \(name).sks")
            return nil
        }
        
        guard let particleNode = SKEmitterNode(fileNamed: name) else {
            print("⚠️ AssetManager: Failed to create particle effect: \(name)")
            return nil
        }
        
        print("✅ AssetManager: Loaded particle effect: \(name)")
        return particleNode
    }
    
    // MARK: - Convenience Methods for Validation
    
    /// Get spark texture (convenience method)
    func getSparkTexture() -> SKTexture {
        return sparkTexture()
    }
    
    /// Get star texture (convenience method)
    func getStarTexture() -> SKTexture {
        return starTexture()
    }
    
    /// Get circle texture (convenience method)
    func getCircleTexture() -> SKTexture {
        return circleTexture()
    }
}
