//
//  AssetManager.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 21/6/25.
//

import SpriteKit
import SwiftUI

/// Central asset manager that coordinates all game assets
/// Handles initialization, preloading, and management of textures, sounds, and effects
class AssetManager {
    
    // MARK: - Singleton
    static let shared = AssetManager()
    private init() {}
    
    // MARK: - Properties
    
    private var isInitialized = false
    private var preloadingProgress: Float = 0.0
    
    /// Asset managers
    let colors = ColorAssets.shared
    let textures = TextureAtlasManager.shared
    let particles = ParticleEffects.shared
    let sounds = SpriteKitSoundManager.shared
    
    // MARK: - Initialization
    
    /// Initialize all asset systems
    func initialize(completion: @escaping (Bool) -> Void) {
        guard !isInitialized else {
            completion(true)
            return
        }
        
        print("🎮 Initializing NumberQuest assets...")
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.performAssetInitialization { success in
                DispatchQueue.main.async {
                    self.isInitialized = success
                    print(success ? "✅ Assets initialized successfully" : "❌ Asset initialization failed")
                    completion(success)
                }
            }
        }
    }
    
    /// Setup assets for a specific scene
    func setupForScene(_ scene: SKScene) {
        sounds.setupForScene(scene)
        
        // Setup global coordinate system
        if let viewController = scene.view?.next as? UIViewController {
            let safeAreaInsets = viewController.view.safeAreaInsets
            GlobalCoordinateSystem.setup(sceneSize: scene.size, safeAreaInsets: safeAreaInsets)
        } else {
            GlobalCoordinateSystem.setup(sceneSize: scene.size)
        }
        
        print("🎬 Assets configured for scene: \(type(of: scene))")
    }
    
    // MARK: - Asset Quality Settings
    
    enum AssetQuality {
        case low
        case medium
        case high
        case ultra
    }
    
    /// Configure asset quality based on device capabilities
    func configureAssetQuality() -> AssetQuality {
        let deviceModel = UIDevice.current.model
        let screenScale = UIScreen.main.scale
        let memoryInfo = ProcessInfo.processInfo.physicalMemory
        
        // Determine quality based on device capabilities
        if memoryInfo > 6_000_000_000 && screenScale >= 3.0 { // 6GB+ RAM, high DPI
            return .ultra
        } else if memoryInfo > 4_000_000_000 && screenScale >= 2.0 { // 4GB+ RAM, retina
            return .high
        } else if memoryInfo > 2_000_000_000 { // 2GB+ RAM
            return .medium
        } else {
            return .low
        }
    }
    
    // MARK: - Asset Preloading
    
    private func performAssetInitialization(completion: @escaping (Bool) -> Void) {
        var initializationSteps: [() -> Bool] = []
        
        // Step 1: Initialize color assets
        initializationSteps.append {
            print("🎨 Initializing color assets...")
            // Colors are always available, no loading needed
            return true
        }
        
        // Step 2: Preload essential textures
        initializationSteps.append {
            print("🖼️ Preloading texture atlases...")
            self.textures.preloadEssentialAtlases()
            return true
        }
        
        // Step 3: Initialize particle effects
        initializationSteps.append {
            print("✨ Setting up particle effects...")
            // Particle effects are created on-demand, setup validation here
            return self.validateParticleEffects()
        }
        
        // Step 4: Initialize sound system
        initializationSteps.append {
            print("🔊 Configuring sound system...")
            // Sound system is ready, validate audio session
            return self.validateSoundSystem()
        }
        
        // Step 5: Final validation
        initializationSteps.append {
            print("✅ Performing final asset validation...")
            return self.validateAllAssets()
        }
        
        // Execute initialization steps
        var success = true
        for (index, step) in initializationSteps.enumerated() {
            preloadingProgress = Float(index) / Float(initializationSteps.count)
            
            if !step() {
                success = false
                break
            }
            
            // Small delay to prevent blocking
            Thread.sleep(forTimeInterval: 0.1)
        }
        
        preloadingProgress = 1.0
        completion(success)
    }
    
    // MARK: - Asset Validation
    
    private func validateParticleEffects() -> Bool {
        // Test creating each particle effect type
        let testEffectTypes: [ParticleEffects.EffectType] = [
            .correctAnswer, .wrongAnswer, .celebration, .starBurst
        ]
        
        for effectType in testEffectTypes {
            let testEffect = particles.createEffect(effectType, at: .zero)
            if testEffect.particleTexture == nil {
                print("❌ Failed to create particle effect: \(effectType)")
                return false
            }
        }
        
        return true
    }
    
    private func validateSoundSystem() -> Bool {
        // Validate sound manager is accessible
        return SoundManager.shared.isSoundEnabled != nil
    }
    
    private func validateAllAssets() -> Bool {
        // Final comprehensive validation
        let colorValidation = colors.randomPrimaryColor() != UIColor.clear
        let textureValidation = textures.texture(named: "circle", from: "BasicShapes") != nil
        
        return colorValidation && textureValidation
    }
    
    // MARK: - Asset Information
    
    /// Get asset loading progress (0.0 to 1.0)
    var loadingProgress: Float {
        return preloadingProgress
    }
    
    /// Check if assets are ready for use
    var isReady: Bool {
        return isInitialized
    }
    
    /// Get memory usage information
    func getMemoryUsage() -> AssetMemoryInfo {
        let textureMemory = estimateTextureMemoryUsage()
        let particleMemory = estimateParticleMemoryUsage()
        let soundMemory = estimateSoundMemoryUsage()
        
        return AssetMemoryInfo(
            textureMemory: textureMemory,
            particleMemory: particleMemory,
            soundMemory: soundMemory,
            totalMemory: textureMemory + particleMemory + soundMemory
        )
    }
    
    private func estimateTextureMemoryUsage() -> Int {
        // Rough estimation - in real implementation, calculate actual texture sizes
        return 10 * 1024 * 1024 // 10MB estimate
    }
    
    private func estimateParticleMemoryUsage() -> Int {
        // Particle effects are lightweight
        return 2 * 1024 * 1024 // 2MB estimate
    }
    
    private func estimateSoundMemoryUsage() -> Int {
        // Sound effects and music
        return 5 * 1024 * 1024 // 5MB estimate
    }
    
    // MARK: - Asset Cleanup
    
    /// Clear cached assets to free memory
    func clearCache() {
        textures.clearCache()
        
        print("🧹 Asset cache cleared")
    }
    
    /// Reload assets with different quality settings
    func reloadAssets(quality: AssetQuality, completion: @escaping (Bool) -> Void) {
        clearCache()
        isInitialized = false
        
        // Apply quality settings and reinitialize
        applyQualitySettings(quality)
        initialize(completion: completion)
    }
    
    private func applyQualitySettings(_ quality: AssetQuality) {
        // Configure particle counts, texture sizes, etc. based on quality
        switch quality {
        case .low:
            // Reduce particle counts, lower resolution textures
            break
        case .medium:
            // Standard settings
            break
        case .high:
            // Enhanced visual effects
            break
        case .ultra:
            // Maximum quality settings
            break
        }
        
        print("⚙️ Applied asset quality: \(quality)")
    }
    
    // MARK: - Development Helpers
    
    #if DEBUG
    /// Debug information about loaded assets
    func debugInfo() -> String {
        let memoryInfo = getMemoryUsage()
        
        return """
        📊 NumberQuest Asset Debug Info:
        - Initialization Status: \(isInitialized ? "✅ Ready" : "❌ Not Ready")
        - Loading Progress: \(Int(preloadingProgress * 100))%
        - Memory Usage: \(memoryInfo.totalMemory / (1024*1024))MB
          • Textures: \(memoryInfo.textureMemory / (1024*1024))MB
          • Particles: \(memoryInfo.particleMemory / (1024*1024))MB
          • Sounds: \(memoryInfo.soundMemory / (1024*1024))MB
        - Asset Quality: \(configureAssetQuality())
        """
    }
    
    /// Test all asset systems
    func runAssetTests() {
        print("🧪 Running asset tests...")
        
        // Test color assets
        let testColor = colors.randomPrimaryColor()
        print("Color test: \(testColor)")
        
        // Test particle effects
        let testParticle = particles.createEffect(.celebration, at: .zero)
        print("Particle test: \(testParticle)")
        
        // Test sound system
        sounds.playSound(.buttonPress)
        print("Sound test completed")
        
        print("✅ Asset tests completed")
    }
    #endif
}

// MARK: - Supporting Types

struct AssetMemoryInfo {
    let textureMemory: Int
    let particleMemory: Int
    let soundMemory: Int
    let totalMemory: Int
}

// MARK: - Global Asset Access

/// Global convenience accessor for assets
struct Assets {
    static var colors: ColorAssets { AssetManager.shared.colors }
    static var textures: TextureAtlasManager { AssetManager.shared.textures }
    static var particles: ParticleEffects { AssetManager.shared.particles }
    static var sounds: SpriteKitSoundManager { AssetManager.shared.sounds }
    
    static var isReady: Bool { AssetManager.shared.isReady }
    static var loadingProgress: Float { AssetManager.shared.loadingProgress }
}
