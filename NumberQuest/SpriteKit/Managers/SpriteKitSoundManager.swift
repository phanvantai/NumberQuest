//
//  SpriteKitSoundManager.swift
//  NumberQuest
//
//  Created by NumberQuest on 2024.
//

import SpriteKit
import AVFoundation

/// SpriteKit-specific sound integration wrapper
class SpriteKitSoundManager {
    static let shared = SpriteKitSoundManager()
    
    private let soundManager = SoundManager.shared
    
    private init() {}
    
    /// Play a sound effect for SpriteKit scenes
    /// - Parameters:
    ///   - soundType: The type of sound to play
    ///   - node: Optional node to play the sound from (for positional audio)
    func playSound(_ soundType: SoundType, from node: SKNode? = nil) {
        soundManager.playSound(soundType)
        
        // Add visual feedback if node is provided
        if let node = node {
            addSoundFeedback(to: node, for: soundType)
        }
    }
    
    /// Play haptic feedback
    /// - Parameter hapticType: The type of haptic feedback
    func playHaptic(_ hapticType: HapticType) {
        soundManager.playHaptic(hapticType)
    }
    
    /// Play sound and haptic feedback together
    /// - Parameters:
    ///   - soundType: The sound to play
    ///   - hapticType: The haptic feedback to play
    ///   - node: Optional node for visual feedback
    func playSoundAndHaptic(_ soundType: SoundType, haptic hapticType: HapticType, from node: SKNode? = nil) {
        playSound(soundType, from: node)
        playHaptic(hapticType)
    }
    
    /// Check if sound is enabled
    var isSoundEnabled: Bool {
        return soundManager.isSoundEnabled
    }
    
    /// Check if music is enabled
    var isMusicEnabled: Bool {
        return soundManager.isMusicEnabled
    }
    
    /// Add visual feedback to a node when sound is played
    private func addSoundFeedback(to node: SKNode, for soundType: SoundType) {
        let scale: CGFloat
        let color: UIColor
        
        switch soundType {
        case .correct, .starEarned, .levelComplete:
            scale = 1.1
            color = .systemGreen
        case .incorrect:
            scale = 0.9
            color = .systemRed
        case .buttonTap:
            scale = 1.05
            color = .systemBlue
        }
        
        // Scale animation
        let scaleUp = SKAction.scale(to: scale, duration: 0.1)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.1)
        let scaleAnimation = SKAction.sequence([scaleUp, scaleDown])
        
        // Color flash animation for labels
        if let labelNode = node as? SKLabelNode {
            let originalColor = labelNode.fontColor ?? .white
            let colorChange = SKAction.colorize(with: color, colorBlendFactor: 0.5, duration: 0.1)
            let colorRestore = SKAction.colorize(with: originalColor, colorBlendFactor: 0.0, duration: 0.1)
            let colorAnimation = SKAction.sequence([colorChange, colorRestore])
            
            node.run(SKAction.group([scaleAnimation, colorAnimation]))
        } else {
            node.run(scaleAnimation)
        }
    }
}

// MARK: - SKScene Extension for Easy Access

extension SKScene {
    /// Play a sound effect with optional haptic feedback
    /// - Parameters:
    ///   - soundType: The sound to play
    ///   - hapticType: Optional haptic feedback
    ///   - from: Optional node to provide visual feedback
    func playSound(_ soundType: SoundType, haptic hapticType: HapticType? = nil, from node: SKNode? = nil) {
        if let hapticType = hapticType {
            SpriteKitSoundManager.shared.playSoundAndHaptic(soundType, haptic: hapticType, from: node)
        } else {
            SpriteKitSoundManager.shared.playSound(soundType, from: node)
        }
    }
    
    /// Play haptic feedback
    /// - Parameter hapticType: The type of haptic feedback
    func playHaptic(_ hapticType: HapticType) {
        SpriteKitSoundManager.shared.playHaptic(hapticType)
    }
}

// MARK: - SKNode Extension for Easy Access

extension SKNode {
    /// Play a sound effect with this node as the source
    /// - Parameters:
    ///   - soundType: The sound to play
    ///   - hapticType: Optional haptic feedback
    func playSound(_ soundType: SoundType, haptic hapticType: HapticType? = nil) {
        if let hapticType = hapticType {
            SpriteKitSoundManager.shared.playSoundAndHaptic(soundType, haptic: hapticType, from: self)
        } else {
            SpriteKitSoundManager.shared.playSound(soundType, from: self)
        }
    }
}
