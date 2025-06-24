//
//  ParticleManager.swift
//  NumberQuest
//
//  Created by NumberQuest on 2024.
//

import SpriteKit
import Foundation

/// Manages particle effects for the SpriteKit version of NumberQuest
class ParticleManager {
    static let shared = ParticleManager()
    
    private var particleCache: [String: SKEmitterNode] = [:]
    
    private init() {}
    
    /// Load and cache a particle effect
    /// - Parameter name: The name of the .sks file (without extension)
    /// - Returns: A configured SKEmitterNode, or nil if loading fails
    func loadParticleEffect(named name: String) -> SKEmitterNode? {
        // Check cache first
        if let cachedParticle = particleCache[name] {
            return cachedParticle.copy() as? SKEmitterNode
        }
        
        // Load from bundle
        guard let particleNode = SKEmitterNode(fileNamed: name) else {
            print("⚠️ ParticleManager: Failed to load particle effect: \(name)")
            return createFallbackParticle(for: name)
        }
        
        // Cache the original
        particleCache[name] = particleNode
        
        // Return a copy
        return particleNode.copy() as? SKEmitterNode
    }
    
    /// Create a celebration particle effect
    func createCelebrationEffect() -> SKEmitterNode? {
        return loadParticleEffect(named: "CelebrationParticles")
    }
    
    /// Create a correct answer particle effect
    func createCorrectAnswerEffect() -> SKEmitterNode? {
        return loadParticleEffect(named: "CorrectAnswerParticles")
    }
    
    /// Create a wrong answer particle effect
    func createWrongAnswerEffect() -> SKEmitterNode? {
        return loadParticleEffect(named: "WrongAnswerParticles")
    }
    
    /// Play a particle effect at a specific position in a scene
    /// - Parameters:
    ///   - effect: The particle effect to play
    ///   - position: The position to play the effect at
    ///   - scene: The scene to add the effect to
    ///   - duration: How long to let the effect run before removing it
    func playEffect(_ effect: SKEmitterNode?, at position: CGPoint, in scene: SKScene, duration: TimeInterval = 3.0) {
        guard let effect = effect else { return }
        
        effect.position = position
        effect.zPosition = 1000 // High z-position to appear above other elements
        
        scene.addChild(effect)
        
        // Remove the effect after the specified duration
        let removeAction = SKAction.sequence([
            SKAction.wait(forDuration: duration),
            SKAction.removeFromParent()
        ])
        
        effect.run(removeAction)
    }
    
    /// Create a fallback particle effect when loading fails
    private func createFallbackParticle(for name: String) -> SKEmitterNode {
        let particle = SKEmitterNode()
        
        // Configure basic fallback based on the effect name
        switch name {
        case "CelebrationParticles":
            configureCelebrationFallback(particle)
        case "CorrectAnswerParticles":
            configureCorrectAnswerFallback(particle)
        case "WrongAnswerParticles":
            configureWrongAnswerFallback(particle)
        default:
            configureGenericFallback(particle)
        }
        
        return particle
    }
    
    private func configureCelebrationFallback(_ particle: SKEmitterNode) {
        particle.particleTexture = nil
        particle.particleBirthRate = 100
        particle.numParticlesToEmit = 50
        particle.particleLifetime = 2.0
        particle.particleLifetimeRange = 1.0
        particle.particlePositionRange = CGVector(dx: 100, dy: 50)
        particle.particleSpeed = 150
        particle.particleSpeedRange = 50
        particle.emissionAngle = 0
        particle.emissionAngleRange = CGFloat.pi * 2
        particle.yAcceleration = -200
        particle.particleColorSequence = createColorSequence(
            colors: [.systemYellow, .systemPink, .systemBlue],
            keyTimes: [0.0, 0.5, 1.0]
        )
        particle.particleScaleSequence = createScaleSequence(
            scales: [0.1, 1.0, 0.2],
            keyTimes: [0.0, 0.5, 1.0]
        )
    }
    
    private func configureCorrectAnswerFallback(_ particle: SKEmitterNode) {
        particle.particleTexture = nil
        particle.particleBirthRate = 50
        particle.numParticlesToEmit = 25
        particle.particleLifetime = 1.5
        particle.particleLifetimeRange = 0.5
        particle.particlePositionRange = CGVector(dx: 50, dy: 30)
        particle.particleSpeed = 100
        particle.particleSpeedRange = 30
        particle.emissionAngle = 0
        particle.emissionAngleRange = CGFloat.pi * 2
        particle.yAcceleration = -100
        particle.particleColorSequence = createColorSequence(
            colors: [.systemGreen, .systemMint, .systemTeal],
            keyTimes: [0.0, 0.7, 1.0]
        )
        particle.particleScaleSequence = createScaleSequence(
            scales: [0.2, 0.8, 0.1],
            keyTimes: [0.0, 0.3, 1.0]
        )
    }
    
    private func configureWrongAnswerFallback(_ particle: SKEmitterNode) {
        particle.particleTexture = nil
        particle.particleBirthRate = 30
        particle.numParticlesToEmit = 15
        particle.particleLifetime = 1.0
        particle.particleLifetimeRange = 0.3
        particle.particlePositionRange = CGVector(dx: 30, dy: 20)
        particle.particleSpeed = 80
        particle.particleSpeedRange = 20
        particle.emissionAngle = 0
        particle.emissionAngleRange = CGFloat.pi * 2
        particle.yAcceleration = -50
        particle.particleColorSequence = createColorSequence(
            colors: [.systemRed, .systemOrange, .systemYellow],
            keyTimes: [0.0, 0.5, 1.0]
        )
        particle.particleScaleSequence = createScaleSequence(
            scales: [0.3, 0.6, 0.1],
            keyTimes: [0.0, 0.4, 1.0]
        )
    }
    
    private func configureGenericFallback(_ particle: SKEmitterNode) {
        particle.particleTexture = nil
        particle.particleBirthRate = 20
        particle.numParticlesToEmit = 10
        particle.particleLifetime = 1.0
        particle.particleSpeed = 50
        particle.particleColor = .white
        particle.particleAlpha = 0.8
        particle.particleScale = 0.5
    }
    
    private func createColorSequence(colors: [UIColor], keyTimes: [CGFloat]) -> SKKeyframeSequence? {
        guard colors.count == keyTimes.count else { return nil }
        
        let sequence = SKKeyframeSequence(keyframeValues: colors, times: keyTimes.map { NSNumber(value: Float($0)) })
        return sequence
    }
    
    private func createScaleSequence(scales: [CGFloat], keyTimes: [CGFloat]) -> SKKeyframeSequence? {
        guard scales.count == keyTimes.count else { return nil }
        
        let sequence = SKKeyframeSequence(keyframeValues: scales.map { NSNumber(value: Float($0)) }, times: keyTimes.map { NSNumber(value: Float($0)) })
        return sequence
    }
    
    /// Clear the particle cache to free memory
    func clearCache() {
        particleCache.removeAll()
    }
}

// MARK: - Convenience Extensions

extension SKScene {
    /// Convenience method to play a celebration effect
    func playCelebrationEffect(at position: CGPoint) {
        if let effect = ParticleManager.shared.createCelebrationEffect() {
            ParticleManager.shared.playEffect(effect, at: position, in: self)
        }
    }
    
    /// Convenience method to play a correct answer effect
    func playCorrectAnswerEffect(at position: CGPoint) {
        if let effect = ParticleManager.shared.createCorrectAnswerEffect() {
            ParticleManager.shared.playEffect(effect, at: position, in: self, duration: 2.0)
        }
    }
    
    /// Convenience method to play a wrong answer effect
    func playWrongAnswerEffect(at position: CGPoint) {
        if let effect = ParticleManager.shared.createWrongAnswerEffect() {
            ParticleManager.shared.playEffect(effect, at: position, in: self, duration: 1.5)
        }
    }
}
