//
//  SoundManager.swift
//  NumberQuest
//
//  Created by TaiPV on 20/6/25.
//

import AVFoundation
import AudioToolbox
import SwiftUI

class SoundManager: ObservableObject {
    static let shared = SoundManager()
    
    private var audioPlayers: [String: AVAudioPlayer] = [:]
    @Published var isSoundEnabled = true
    @Published var isMusicEnabled = true
    
    private init() {
        setupAudioSession()
        loadUserPreferences()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }
    
    private func loadUserPreferences() {
        isSoundEnabled = UserDefaults.standard.bool(forKey: "SoundEnabled")
        isMusicEnabled = UserDefaults.standard.bool(forKey: "MusicEnabled")
    }
    
    func savePreferences() {
        UserDefaults.standard.set(isSoundEnabled, forKey: "SoundEnabled")
        UserDefaults.standard.set(isMusicEnabled, forKey: "MusicEnabled")
    }
    
    // Since we don't have actual sound files, we'll use system sounds
    func playSound(_ soundType: SoundType) {
        guard isSoundEnabled else { return }
        
        switch soundType {
        case .correct:
            AudioServicesPlaySystemSound(1016) // SMS_Alert_Popcorn
        case .incorrect:
            AudioServicesPlaySystemSound(1053) // SMSAlert_Alert
        case .buttonTap:
            AudioServicesPlaySystemSound(1104) // SMS_Alert_Calypso
        case .levelComplete:
            AudioServicesPlaySystemSound(1025) // SMSAlert_Anticipate
        case .starEarned:
            AudioServicesPlaySystemSound(1016) // SMS_Alert_Popcorn
        }
    }
    
    func playHaptic(_ hapticType: HapticType) {
        let impactFeedback = UIImpactFeedbackGenerator()
        let notificationFeedback = UINotificationFeedbackGenerator()
        
        switch hapticType {
        case .light:
            impactFeedback.impactOccurred(intensity: 0.5)
        case .medium:
            impactFeedback.impactOccurred(intensity: 0.7)
        case .heavy:
            impactFeedback.impactOccurred(intensity: 1.0)
        case .success:
            notificationFeedback.notificationOccurred(.success)
        case .error:
            notificationFeedback.notificationOccurred(.error)
        case .warning:
            notificationFeedback.notificationOccurred(.warning)
        }
    }
}

enum SoundType {
    case correct
    case incorrect
    case buttonTap
    case levelComplete
    case starEarned
}

enum HapticType {
    case light
    case medium
    case heavy
    case success
    case error
    case warning
}
