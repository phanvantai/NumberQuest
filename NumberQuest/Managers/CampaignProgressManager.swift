//
//  CampaignProgressManager.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 27/6/25.
//

import Foundation

/// Manages campaign progress, level completion, and unlocking logic
class CampaignProgressManager {
    
    static let shared = CampaignProgressManager()
    
    private let userDefaults = UserDefaults.standard
    private let progressKey = "CampaignProgress"
    
    private init() {}
    
    // MARK: - Progress Data Structure
    
    struct LevelProgress: Codable {
        let levelId: Int
        var starsEarned: Int
        var isUnlocked: Bool
        var bestTime: TimeInterval?
        var bestAccuracy: Float?
        var timesPlayed: Int
        
        init(levelId: Int, starsEarned: Int = 0, isUnlocked: Bool = false) {
            self.levelId = levelId
            self.starsEarned = starsEarned
            self.isUnlocked = isUnlocked
            self.timesPlayed = 0
        }
    }
    
    // MARK: - Progress Management
    
    /// Get the current progress for a specific level
    func getLevelProgress(levelId: Int) -> LevelProgress {
        let allProgress = loadProgress()
        return allProgress[levelId] ?? LevelProgress(levelId: levelId)
    }
    
    /// Update progress for a completed level
    func updateLevelProgress(levelId: Int, starsEarned: Int, completionTime: TimeInterval, accuracy: Float) {
        var allProgress = loadProgress()
        var levelProgress = allProgress[levelId] ?? LevelProgress(levelId: levelId)
        
        // Update stats
        levelProgress.starsEarned = max(levelProgress.starsEarned, starsEarned)
        levelProgress.timesPlayed += 1
        
        if let currentBestTime = levelProgress.bestTime {
            levelProgress.bestTime = min(currentBestTime, completionTime)
        } else {
            levelProgress.bestTime = completionTime
        }
        
        if let currentBestAccuracy = levelProgress.bestAccuracy {
            levelProgress.bestAccuracy = max(currentBestAccuracy, accuracy)
        } else {
            levelProgress.bestAccuracy = accuracy
        }
        
        allProgress[levelId] = levelProgress
        
        // Unlock next levels based on stars earned
        unlockNextLevels(from: levelId, starsEarned: starsEarned, progress: &allProgress)
        
        // Save progress
        saveProgress(allProgress)
        
        print("📊 Progress updated for level \(levelId): \(starsEarned) stars, \(Int(accuracy * 100))% accuracy")
    }
    
    /// Unlock a specific level (for initialization or special cases)
    func unlockLevel(levelId: Int) {
        var allProgress = loadProgress()
        var levelProgress = allProgress[levelId] ?? LevelProgress(levelId: levelId)
        levelProgress.isUnlocked = true
        allProgress[levelId] = levelProgress
        saveProgress(allProgress)
    }
    
    /// Get total stars earned across all levels
    func getTotalStarsEarned() -> Int {
        let allProgress = loadProgress()
        return allProgress.values.reduce(0) { $0 + $1.starsEarned }
    }
    
    /// Get completion percentage
    func getCompletionPercentage(totalLevels: Int) -> Float {
        let allProgress = loadProgress()
        let completedLevels = allProgress.values.filter { $0.starsEarned > 0 }.count
        return Float(completedLevels) / Float(totalLevels)
    }
    
    /// Reset all progress (for testing or new game)
    func resetProgress() {
        userDefaults.removeObject(forKey: progressKey)
        userDefaults.synchronize()
        
        // Unlock the first level
        unlockLevel(levelId: 1)
        print("🔄 Campaign progress reset")
    }
    
    // MARK: - Private Methods
    
    private func loadProgress() -> [Int: LevelProgress] {
        guard let data = userDefaults.data(forKey: progressKey),
              let progress = try? JSONDecoder().decode([Int: LevelProgress].self, from: data) else {
            // Return default progress with first level unlocked
            let defaultProgress: [Int: LevelProgress] = [1: LevelProgress(levelId: 1, isUnlocked: true)]
            return defaultProgress
        }
        return progress
    }
    
    private func saveProgress(_ progress: [Int: LevelProgress]) {
        do {
            let data = try JSONEncoder().encode(progress)
            userDefaults.set(data, forKey: progressKey)
            userDefaults.synchronize()
        } catch {
            print("❌ Failed to save campaign progress: \(error)")
        }
    }
    
    private func unlockNextLevels(from completedLevelId: Int, starsEarned: Int, progress: inout [Int: LevelProgress]) {
        // Basic unlocking logic: unlock next level if at least 1 star earned
        if starsEarned >= 1 {
            let nextLevelId = completedLevelId + 1
            var nextLevelProgress = progress[nextLevelId] ?? LevelProgress(levelId: nextLevelId)
            nextLevelProgress.isUnlocked = true
            progress[nextLevelId] = nextLevelProgress
            
            print("🔓 Level \(nextLevelId) unlocked!")
        }
        
        // Special unlocking logic: unlock bonus levels or skip levels with 3 stars
        if starsEarned >= 3 {
            // Could unlock special bonus levels or allow skipping
            print("⭐⭐⭐ Perfect completion! Bonus features unlocked!")
        }
    }
}

// MARK: - Campaign Level Extensions

extension CampaignLevel {
    /// Create a level with progress data applied
    func withProgress(_ progress: CampaignProgressManager.LevelProgress) -> CampaignLevel {
        return CampaignLevel(
            id: self.id,
            worldTheme: self.worldTheme,
            title: self.title,
            description: self.description,
            requiredStars: self.requiredStars,
            maxStars: self.maxStars,
            difficultyRange: self.difficultyRange,
            problemCount: self.problemCount,
            position: self.position,
            isUnlocked: progress.isUnlocked,
            completedStars: progress.starsEarned
        )
    }
}
