//
//  SpriteKitSoundManager.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 21/6/25.
//

import SpriteKit
import AVFoundation

/// Enhanced sound manager specifically for SpriteKit scenes
/// Integrates with the existing SoundManager while providing SpriteKit-specific features
class SpriteKitSoundManager {
    
    // MARK: - Singleton
    static let shared = SpriteKitSoundManager()
    private init() {}
    
    // MARK: - Properties
    
    /// Reference to the main sound manager
    private let soundManager = SoundManager.shared
    
    /// Cache of SKAction sound actions for performance
    private var soundActions: [String: SKAction] = [:]
    
    /// Background music player
    private var backgroundMusicNode: SKAudioNode?
    
    /// Currently playing scene for context-aware sound
    weak var currentScene: SKScene?
    
    // MARK: - Sound File Names
    
    struct SoundFiles {
        // UI Sounds
        static let buttonPress = "button_press.wav"
        static let buttonHover = "button_hover.wav"
        static let menuTransition = "menu_transition.wav"
        static let popup = "popup.wav"
        
        // Game Sounds
        static let correctAnswer = "correct_answer.wav"
        static let wrongAnswer = "wrong_answer.wav"
        static let questionAppear = "question_appear.wav"
        static let timerTick = "timer_tick.wav"
        static let timerWarning = "timer_warning.wav"
        
        // Celebration Sounds
        static let streak = "streak.wav"
        static let levelComplete = "level_complete.wav"
        static let starEarned = "star_earned.wav"
        static let achievement = "achievement.wav"
        
        // Background Music
        static let menuMusic = "menu_music.mp3"
        static let gameMusic = "game_music.mp3"
        static let celebrationMusic = "celebration_music.mp3"
        
        // Character Sounds
        static let characterCheer = "character_cheer.wav"
        static let characterEncouragement = "character_encouragement.wav"
    }
    
    // MARK: - Public Methods
    
    /// Setup sound manager for a specific scene
    func setupForScene(_ scene: SKScene) {
        currentScene = scene
        preloadSounds()
    }
    
    /// Play a sound effect
    func playSound(_ soundType: SpriteKitSoundType, from node: SKNode? = nil) {
        guard soundManager.isSoundEnabled else { return }
        
        let soundFile = soundFileForType(soundType)
        
        if let node = node {
            // Play from specific node for positional audio
            playSoundFromNode(soundFile, node: node)
        } else if let scene = currentScene {
            // Play from scene
            playSoundFromScene(soundFile, scene: scene)
        } else {
            // Fallback to system sound
            playSystemSoundForType(soundType)
        }
    }
    
    /// Play background music
    func playBackgroundMusic(_ musicType: BackgroundMusicType) {
        guard soundManager.isMusicEnabled else { return }
        
        stopBackgroundMusic()
        
        let musicFile = musicFileForType(musicType)
        
        // For now, use placeholder - in real implementation, load actual audio file
        if let scene = currentScene {
            // Placeholder: create a silent audio node
            backgroundMusicNode = SKAudioNode(fileNamed: musicFile)
            backgroundMusicNode?.autoplayLooped = true
            scene.addChild(backgroundMusicNode!)
        }
    }
    
    /// Stop background music
    func stopBackgroundMusic() {
        backgroundMusicNode?.removeFromParent()
        backgroundMusicNode = nil
    }
    
    /// Play sound with custom volume and pitch
    func playSoundWithCustomization(
        _ soundType: SpriteKitSoundType,
        volume: Float = 1.0,
        pitch: Float = 1.0,
        from node: SKNode? = nil
    ) {
        guard soundManager.isSoundEnabled else { return }
        
        let soundFile = soundFileForType(soundType)
        let action = createCustomSoundAction(soundFile, volume: volume, pitch: pitch)
        
        if let node = node {
            node.run(action)
        } else {
            currentScene?.run(action)
        }
    }
    
    /// Play a sequence of sounds
    func playSoundSequence(_ soundTypes: [SpriteKitSoundType], interval: TimeInterval = 0.1) {
        guard soundManager.isSoundEnabled else { return }
        
        var actions: [SKAction] = []
        
        for (index, soundType) in soundTypes.enumerated() {
            if index > 0 {
                actions.append(SKAction.wait(forDuration: interval))
            }
            
            let soundFile = soundFileForType(soundType)
            let soundAction = getSoundAction(for: soundFile)
            actions.append(soundAction)
        }
        
        let sequence = SKAction.sequence(actions)
        currentScene?.run(sequence)
    }
    
    /// Play celebration sound combo
    func playCelebrationCombo(for achievement: CelebrationLevel) {
        guard soundManager.isSoundEnabled else { return }
        
        switch achievement {
        case .correctAnswer:
            playSound(.correctAnswer)
            
        case .streak:
            playSoundSequence([.correctAnswer, .streak], interval: 0.2)
            
        case .levelComplete:
            playSoundSequence([.correctAnswer, .starEarned, .levelComplete], interval: 0.3)
            
        case .achievement:
            playSoundSequence([.achievement, .characterCheer], interval: 0.5)
            playBackgroundMusic(.celebration)
        }
    }
    
    // MARK: - Private Methods
    
    private func preloadSounds() {
        let soundFiles = [
            SoundFiles.buttonPress,
            SoundFiles.correctAnswer,
            SoundFiles.wrongAnswer,
            SoundFiles.questionAppear,
            SoundFiles.streak,
            SoundFiles.starEarned
        ]
        
        for soundFile in soundFiles {
            soundActions[soundFile] = createSoundAction(soundFile)
        }
    }
    
    private func soundFileForType(_ type: SpriteKitSoundType) -> String {
        switch type {
        case .buttonPress: return SoundFiles.buttonPress
        case .buttonHover: return SoundFiles.buttonHover
        case .menuTransition: return SoundFiles.menuTransition
        case .popup: return SoundFiles.popup
        case .correctAnswer: return SoundFiles.correctAnswer
        case .wrongAnswer: return SoundFiles.wrongAnswer
        case .questionAppear: return SoundFiles.questionAppear
        case .timerTick: return SoundFiles.timerTick
        case .timerWarning: return SoundFiles.timerWarning
        case .streak: return SoundFiles.streak
        case .levelComplete: return SoundFiles.levelComplete
        case .starEarned: return SoundFiles.starEarned
        case .achievement: return SoundFiles.achievement
        case .characterCheer: return SoundFiles.characterCheer
        case .characterEncouragement: return SoundFiles.characterEncouragement
        }
    }
    
    private func musicFileForType(_ type: BackgroundMusicType) -> String {
        switch type {
        case .menu: return SoundFiles.menuMusic
        case .game: return SoundFiles.gameMusic
        case .celebration: return SoundFiles.celebrationMusic
        }
    }
    
    private func getSoundAction(for soundFile: String) -> SKAction {
        if let cachedAction = soundActions[soundFile] {
            return cachedAction
        }
        
        let action = createSoundAction(soundFile)
        soundActions[soundFile] = action
        return action
    }
    
    private func createSoundAction(_ soundFile: String) -> SKAction {
        // In a real implementation, this would load the actual sound file
        // For now, return a placeholder action
        return SKAction.run {
            // Placeholder: could trigger system sound here
            print("🔊 Playing sound: \(soundFile)")
        }
    }
    
    private func createCustomSoundAction(_ soundFile: String, volume: Float, pitch: Float) -> SKAction {
        // Custom sound action with volume and pitch adjustment
        return SKAction.run {
            print("🔊 Playing custom sound: \(soundFile) (vol: \(volume), pitch: \(pitch))")
        }
    }
    
    private func playSoundFromNode(_ soundFile: String, node: SKNode) {
        let action = getSoundAction(for: soundFile)
        node.run(action)
    }
    
    private func playSoundFromScene(_ soundFile: String, scene: SKScene) {
        let action = getSoundAction(for: soundFile)
        scene.run(action)
    }
    
    private func playSystemSoundForType(_ type: SpriteKitSoundType) {
        // Fallback to existing SoundManager system sounds
        switch type {
        case .correctAnswer:
            soundManager.playSound(.correct)
        case .wrongAnswer:
            soundManager.playSound(.incorrect)
        case .buttonPress:
            soundManager.playSound(.button)
        case .levelComplete:
            soundManager.playSound(.levelComplete)
        default:
            soundManager.playSound(.button) // Default fallback
        }
    }
    
    // MARK: - Volume Control
    
    /// Set master volume for all sounds
    func setMasterVolume(_ volume: Float) {
        // In real implementation, adjust audio session volume
        print("🔊 Setting master volume to: \(volume)")
    }
    
    /// Fade in background music
    func fadeInBackgroundMusic(_ musicType: BackgroundMusicType, duration: TimeInterval = 2.0) {
        playBackgroundMusic(musicType)
        
        if let musicNode = backgroundMusicNode {
            musicNode.volume = 0.0
            let fadeAction = SKAction.changeVolume(to: 1.0, duration: duration)
            musicNode.run(fadeAction)
        }
    }
    
    /// Fade out background music
    func fadeOutBackgroundMusic(duration: TimeInterval = 2.0) {
        guard let musicNode = backgroundMusicNode else { return }
        
        let fadeAction = SKAction.changeVolume(to: 0.0, duration: duration)
        let removeAction = SKAction.removeFromParent()
        let sequence = SKAction.sequence([fadeAction, removeAction])
        
        musicNode.run(sequence) {
            self.backgroundMusicNode = nil
        }
    }
}

// MARK: - Supporting Types

enum SpriteKitSoundType {
    // UI Sounds
    case buttonPress
    case buttonHover
    case menuTransition
    case popup
    
    // Game Sounds
    case correctAnswer
    case wrongAnswer
    case questionAppear
    case timerTick
    case timerWarning
    
    // Celebration Sounds
    case streak
    case levelComplete
    case starEarned
    case achievement
    
    // Character Sounds
    case characterCheer
    case characterEncouragement
}

enum BackgroundMusicType {
    case menu
    case game
    case celebration
}

enum CelebrationLevel {
    case correctAnswer
    case streak
    case levelComplete
    case achievement
}

// MARK: - SKNode Extension for Easy Sound Playing

extension SKNode {
    
    /// Play a sound from this node
    func playSound(_ soundType: SpriteKitSoundType) {
        SpriteKitSoundManager.shared.playSound(soundType, from: self)
    }
    
    /// Play a sound with custom parameters
    func playSound(_ soundType: SpriteKitSoundType, volume: Float = 1.0, pitch: Float = 1.0) {
        SpriteKitSoundManager.shared.playSoundWithCustomization(
            soundType,
            volume: volume,
            pitch: pitch,
            from: self
        )
    }
}
