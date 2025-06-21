//
//  ParticleEffects.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 21/6/25.
//

import SpriteKit

/// Manages particle effects for visual feedback and celebrations
/// Provides pre-configured particle systems for different game events
class ParticleEffects {
    
    // MARK: - Singleton
    static let shared = ParticleEffects()
    private init() {}
    
    // MARK: - Effect Types
    
    enum EffectType {
        case correctAnswer
        case wrongAnswer
        case celebration
        case starBurst
        case confetti
        case sparkles
        case explosion
        case healing
        case streak
        case levelComplete
    }
    
    // MARK: - Create Particle Effects
    
    /// Create a particle emitter for the specified effect type
    func createEffect(_ type: EffectType, at position: CGPoint) -> SKEmitterNode {
        let emitter = SKEmitterNode()
        emitter.position = position
        
        configureEffect(emitter, for: type)
        
        return emitter
    }
    
    /// Configure particle emitter based on effect type
    private func configureEffect(_ emitter: SKEmitterNode, for type: EffectType) {
        switch type {
        case .correctAnswer:
            configureCorrectAnswerEffect(emitter)
        case .wrongAnswer:
            configureWrongAnswerEffect(emitter)
        case .celebration:
            configureCelebrationEffect(emitter)
        case .starBurst:
            configureStarBurstEffect(emitter)
        case .confetti:
            configureConfettiEffect(emitter)
        case .sparkles:
            configureSparklesEffect(emitter)
        case .explosion:
            configureExplosionEffect(emitter)
        case .healing:
            configureHealingEffect(emitter)
        case .streak:
            configureStreakEffect(emitter)
        case .levelComplete:
            configureLevelCompleteEffect(emitter)
        }
    }
    
    // MARK: - Effect Configurations
    
    private func configureCorrectAnswerEffect(_ emitter: SKEmitterNode) {
        // Green sparkles emanating upward
        emitter.particleTexture = createCircleTexture(radius: 4, color: ColorAssets.Primary.green)
        emitter.particleBirthRate = 30
        emitter.numParticlesToEmit = 20
        emitter.particleLifetime = 1.0
        emitter.particleLifetimeRange = 0.3
        
        emitter.emissionAngle = -.pi / 2 // Upward
        emitter.emissionAngleRange = .pi / 3
        
        emitter.particleSpeed = 100
        emitter.particleSpeedRange = 50
        
        emitter.particleAlpha = 1.0
        emitter.particleAlphaRange = 0.3
        emitter.particleAlphaSpeed = -1.0
        
        emitter.particleScale = 1.0
        emitter.particleScaleRange = 0.5
        emitter.particleScaleSpeed = -0.5
        
        emitter.particleColor = ColorAssets.Primary.green
        emitter.particleColorBlendFactor = 1.0
        
        // Auto-remove after emission
        let waitAction = SKAction.wait(forDuration: 2.0)
        let removeAction = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([waitAction, removeAction]))
    }
    
    private func configureWrongAnswerEffect(_ emitter: SKEmitterNode) {
        // Red particles with slight shake
        emitter.particleTexture = createCircleTexture(radius: 3, color: ColorAssets.Primary.coral)
        emitter.particleBirthRate = 20
        emitter.numParticlesToEmit = 15
        emitter.particleLifetime = 0.8
        emitter.particleLifetimeRange = 0.2
        
        emitter.emissionAngleRange = .pi * 2 // All directions
        
        emitter.particleSpeed = 60
        emitter.particleSpeedRange = 30
        
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -1.5
        
        emitter.particleScale = 0.8
        emitter.particleScaleRange = 0.3
        
        emitter.particleColor = ColorAssets.Primary.coral
        emitter.particleColorBlendFactor = 1.0
        
        let waitAction = SKAction.wait(forDuration: 1.5)
        let removeAction = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([waitAction, removeAction]))
    }
    
    private func configureCelebrationEffect(_ emitter: SKEmitterNode) {
        // Multi-colored bursts
        emitter.particleTexture = createStarTexture(size: 8, color: .white)
        emitter.particleBirthRate = 50
        emitter.numParticlesToEmit = 40
        emitter.particleLifetime = 2.0
        emitter.particleLifetimeRange = 0.5
        
        emitter.emissionAngle = -.pi / 2
        emitter.emissionAngleRange = .pi / 2
        
        emitter.particleSpeed = 150
        emitter.particleSpeedRange = 100
        
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -0.5
        
        emitter.particleScale = 1.0
        emitter.particleScaleRange = 0.5
        emitter.particleScaleSpeed = -0.3
        
        // Color variation
        emitter.particleColorSequence = createRainbowColorSequence()
        
        let waitAction = SKAction.wait(forDuration: 3.0)
        let removeAction = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([waitAction, removeAction]))
    }
    
    private func configureStarBurstEffect(_ emitter: SKEmitterNode) {
        // Star-shaped particles bursting outward
        emitter.particleTexture = createStarTexture(size: 12, color: ColorAssets.Primary.yellow)
        emitter.particleBirthRate = 20
        emitter.numParticlesToEmit = 12
        emitter.particleLifetime = 1.5
        emitter.particleLifetimeRange = 0.3
        
        emitter.emissionAngleRange = .pi * 2
        
        emitter.particleSpeed = 120
        emitter.particleSpeedRange = 40
        
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -0.8
        
        emitter.particleScale = 1.2
        emitter.particleScaleSpeed = -0.6
        
        emitter.particleRotation = 0
        emitter.particleRotationRange = .pi * 2
        emitter.particleRotationSpeed = .pi
        
        emitter.particleColor = ColorAssets.Primary.yellow
        emitter.particleColorBlendFactor = 1.0
        
        let waitAction = SKAction.wait(forDuration: 2.5)
        let removeAction = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([waitAction, removeAction]))
    }
    
    private func configureConfettiEffect(_ emitter: SKEmitterNode) {
        // Colorful rectangles falling like confetti
        emitter.particleTexture = createRectangleTexture(size: CGSize(width: 6, height: 12), color: .white)
        emitter.particleBirthRate = 40
        emitter.numParticlesToEmit = 60
        emitter.particleLifetime = 3.0
        emitter.particleLifetimeRange = 1.0
        
        emitter.emissionAngle = -.pi / 2
        emitter.emissionAngleRange = .pi / 6
        
        emitter.particleSpeed = 80
        emitter.particleSpeedRange = 40
        
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -0.3
        
        emitter.particleScale = 1.0
        emitter.particleScaleRange = 0.3
        
        emitter.particleRotation = 0
        emitter.particleRotationRange = .pi
        emitter.particleRotationSpeed = .pi * 2
        
        // Gravity effect
        emitter.yAcceleration = -200
        emitter.xAcceleration = 20
        
        emitter.particleColorSequence = createConfettiColorSequence()
        
        let waitAction = SKAction.wait(forDuration: 5.0)
        let removeAction = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([waitAction, removeAction]))
    }
    
    private func configureSparklesEffect(_ emitter: SKEmitterNode) {
        // Gentle sparkles for ambient effects
        emitter.particleTexture = createCircleTexture(radius: 2, color: ColorAssets.Primary.yellow)
        emitter.particleBirthRate = 10
        emitter.numParticlesToEmit = 0 // Continuous
        emitter.particleLifetime = 2.0
        emitter.particleLifetimeRange = 1.0
        
        emitter.emissionAngleRange = .pi * 2
        
        emitter.particleSpeed = 20
        emitter.particleSpeedRange = 15
        
        emitter.particleAlpha = 0.8
        emitter.particleAlphaRange = 0.4
        emitter.particleAlphaSpeed = -0.4
        
        emitter.particleScale = 0.5
        emitter.particleScaleRange = 0.3
        emitter.particleScaleSpeed = 0.2
        
        emitter.particleColor = ColorAssets.Primary.yellow
        emitter.particleColorBlendFactor = 0.8
    }
    
    private func configureExplosionEffect(_ emitter: SKEmitterNode) {
        // Dramatic explosion effect
        emitter.particleTexture = createCircleTexture(radius: 6, color: ColorAssets.Primary.orange)
        emitter.particleBirthRate = 100
        emitter.numParticlesToEmit = 50
        emitter.particleLifetime = 1.2
        emitter.particleLifetimeRange = 0.4
        
        emitter.emissionAngleRange = .pi * 2
        
        emitter.particleSpeed = 200
        emitter.particleSpeedRange = 100
        
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -1.0
        
        emitter.particleScale = 1.5
        emitter.particleScaleSpeed = -1.0
        
        emitter.particleColor = ColorAssets.Primary.orange
        emitter.particleColorBlendFactor = 1.0
        
        let waitAction = SKAction.wait(forDuration: 2.0)
        let removeAction = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([waitAction, removeAction]))
    }
    
    private func configureHealingEffect(_ emitter: SKEmitterNode) {
        // Gentle upward floating particles
        emitter.particleTexture = createCircleTexture(radius: 3, color: ColorAssets.Primary.mint)
        emitter.particleBirthRate = 15
        emitter.numParticlesToEmit = 20
        emitter.particleLifetime = 2.5
        emitter.particleLifetimeRange = 0.5
        
        emitter.emissionAngle = -.pi / 2
        emitter.emissionAngleRange = .pi / 4
        
        emitter.particleSpeed = 40
        emitter.particleSpeedRange = 20
        
        emitter.particleAlpha = 0.8
        emitter.particleAlphaSpeed = -0.3
        
        emitter.particleScale = 0.8
        emitter.particleScaleRange = 0.2
        emitter.particleScaleSpeed = 0.1
        
        emitter.particleColor = ColorAssets.Primary.mint
        emitter.particleColorBlendFactor = 1.0
        
        let waitAction = SKAction.wait(forDuration: 3.0)
        let removeAction = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([waitAction, removeAction]))
    }
    
    private func configureStreakEffect(_ emitter: SKEmitterNode) {
        // Fire-like effect for streaks
        emitter.particleTexture = createCircleTexture(radius: 4, color: ColorAssets.Primary.orange)
        emitter.particleBirthRate = 25
        emitter.numParticlesToEmit = 0 // Continuous while active
        emitter.particleLifetime = 1.0
        emitter.particleLifetimeRange = 0.3
        
        emitter.emissionAngle = -.pi / 2
        emitter.emissionAngleRange = .pi / 6
        
        emitter.particleSpeed = 60
        emitter.particleSpeedRange = 30
        
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -1.2
        
        emitter.particleScale = 1.0
        emitter.particleScaleRange = 0.4
        emitter.particleScaleSpeed = -0.8
        
        // Color transition from yellow to red
        let colorSequence = SKKeyframeSequence(keyframeValues: [
            ColorAssets.Primary.yellow,
            ColorAssets.Primary.orange,
            ColorAssets.Primary.coral
        ], times: [0.0, 0.5, 1.0])
        emitter.particleColorSequence = colorSequence
    }
    
    private func configureLevelCompleteEffect(_ emitter: SKEmitterNode) {
        // Grand celebration with multiple elements
        emitter.particleTexture = createStarTexture(size: 10, color: .white)
        emitter.particleBirthRate = 60
        emitter.numParticlesToEmit = 100
        emitter.particleLifetime = 3.0
        emitter.particleLifetimeRange = 1.0
        
        emitter.emissionAngle = -.pi / 2
        emitter.emissionAngleRange = .pi
        
        emitter.particleSpeed = 180
        emitter.particleSpeedRange = 120
        
        emitter.particleAlpha = 1.0
        emitter.particleAlphaSpeed = -0.4
        
        emitter.particleScale = 1.3
        emitter.particleScaleRange = 0.7
        emitter.particleScaleSpeed = -0.3
        
        emitter.particleRotation = 0
        emitter.particleRotationRange = .pi * 2
        emitter.particleRotationSpeed = .pi
        
        emitter.particleColorSequence = createRainbowColorSequence()
        
        let waitAction = SKAction.wait(forDuration: 4.0)
        let removeAction = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([waitAction, removeAction]))
    }
    
    // MARK: - Helper Methods
    
    /// Create a rainbow color sequence for particles
    private func createRainbowColorSequence() -> SKKeyframeSequence {
        let colors = [
            ColorAssets.Primary.blue,
            ColorAssets.Primary.mint,
            ColorAssets.Primary.green,
            ColorAssets.Primary.yellow,
            ColorAssets.Primary.orange,
            ColorAssets.Primary.coral,
            ColorAssets.Primary.pink,
            ColorAssets.Primary.purple
        ]
        
        var times: [NSNumber] = []
        for i in 0..<colors.count {
            times.append(NSNumber(value: Double(i) / Double(colors.count - 1)))
        }
        
        return SKKeyframeSequence(keyframeValues: colors, times: times)
    }
    
    /// Create a confetti color sequence
    private func createConfettiColorSequence() -> SKKeyframeSequence {
        let colors = [
            ColorAssets.Primary.blue,
            ColorAssets.Primary.green,
            ColorAssets.Primary.yellow,
            ColorAssets.Primary.orange,
            ColorAssets.Primary.coral,
            ColorAssets.Primary.pink
        ]
        
        return SKKeyframeSequence(keyframeValues: colors, times: [0.0, 0.2, 0.4, 0.6, 0.8, 1.0])
    }
    
    // MARK: - Texture Creation (shared with TextureAtlasManager)
    
    private func createCircleTexture(radius: CGFloat, color: UIColor) -> SKTexture {
        let size = CGSize(width: radius * 2, height: radius * 2)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }
        
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: CGRect(origin: .zero, size: size))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image ?? UIImage())
    }
    
    private func createRectangleTexture(size: CGSize, color: UIColor) -> SKTexture {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }
        
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image ?? UIImage())
    }
    
    private func createStarTexture(size: CGFloat, color: UIColor) -> SKTexture {
        let canvasSize = CGSize(width: size, height: size)
        
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }
        
        let center = CGPoint(x: size/2, y: size/2)
        let outerRadius = size/2
        let innerRadius = outerRadius * 0.4
        
        let path = UIBezierPath()
        for i in 0..<10 {
            let angle = CGFloat(i) * .pi / 5.0
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = center.x + radius * cos(angle - .pi/2)
            let y = center.y + radius * sin(angle - .pi/2)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.close()
        
        context.setFillColor(color.cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image ?? UIImage())
    }
    
    // MARK: - Convenience Methods
    
    /// Play a particle effect at a specific node
    func playEffect(_ type: EffectType, at node: SKNode) {
        let effect = createEffect(type, at: node.position)
        node.parent?.addChild(effect)
    }
    
    /// Play a particle effect at a specific position in a scene
    func playEffect(_ type: EffectType, at position: CGPoint, in scene: SKScene) {
        let effect = createEffect(type, at: position)
        scene.addChild(effect)
    }
    
    /// Stop continuous particle effects (like sparkles or streak)
    func stopContinuousEffect(_ emitter: SKEmitterNode) {
        emitter.particleBirthRate = 0
        
        let waitAction = SKAction.wait(forDuration: Double(emitter.particleLifetime))
        let removeAction = SKAction.removeFromParent()
        emitter.run(SKAction.sequence([waitAction, removeAction]))
    }
    
    // MARK: - Background Effects
    
    /// Create gentle background particles for ambient effect
    static func createBackgroundParticles() -> SKEmitterNode? {
        let emitter = SKEmitterNode()
        
        // Basic particle settings for gentle floating effect
        emitter.particleTexture = SKTexture(imageNamed: "spark")
        emitter.particleBirthRate = 2
        emitter.numParticlesToEmit = 0 // Continuous
        
        // Particle appearance
        emitter.particleColor = UIColor.white
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColorSequence = nil
        
        // Particle physics
        emitter.particleLifetime = 15.0
        emitter.particleLifetimeRange = 5.0
        
        // Movement
        emitter.particleSpeed = 20
        emitter.particleSpeedRange = 10
        emitter.emissionAngle = CGFloat.pi / 2 // Upward
        emitter.emissionAngleRange = CGFloat.pi / 4
        
        // Size
        emitter.particleScale = 0.2
        emitter.particleScaleRange = 0.1
        emitter.particleScaleSpeed = -0.01
        
        // Alpha
        emitter.particleAlpha = 0.3
        emitter.particleAlphaRange = 0.2
        emitter.particleAlphaSpeed = -0.02
        
        // Position range for wide spread
        emitter.particlePositionRange = CGVector(dx: 400, dy: 50)
        
        return emitter
    }
}
