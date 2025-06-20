//
//  GameData.swift
//  NumberQuest
//
//  Created by TaiPV on 20/6/25.
//

import Foundation

class GameData: ObservableObject {
    static let shared = GameData()
    
    @Published var levels: [GameLevel] = []
    @Published var playerProgress = PlayerProgress()
    
    private init() {
        loadLevels()
        loadPlayerProgress()
    }
    
    private func loadLevels() {
        levels = [
            GameLevel(
                id: 1,
                name: "Sunny Meadows",
                description: "Learn basic addition in the beautiful meadows!",
                requiredStars: 0,
                maxQuestions: 10,
                allowedOperations: [.addition],
                difficulty: .easy,
                isUnlocked: true,
                starsEarned: 0,
                imageName: "sun.max.fill"
            ),
            GameLevel(
                id: 2,
                name: "Forest Path",
                description: "Practice subtraction among the trees!",
                requiredStars: 15,
                maxQuestions: 12,
                allowedOperations: [.subtraction],
                difficulty: .easy,
                isUnlocked: false,
                starsEarned: 0,
                imageName: "tree.fill"
            ),
            GameLevel(
                id: 3,
                name: "Mountain Peak",
                description: "Master addition and subtraction at the summit!",
                requiredStars: 30,
                maxQuestions: 15,
                allowedOperations: [.addition, .subtraction],
                difficulty: .medium,
                isUnlocked: false,
                starsEarned: 0,
                imageName: "mountain.2.fill"
            ),
            GameLevel(
                id: 4,
                name: "Magical Castle",
                description: "Discover multiplication in the enchanted castle!",
                requiredStars: 50,
                maxQuestions: 12,
                allowedOperations: [.multiplication],
                difficulty: .medium,
                isUnlocked: false,
                starsEarned: 0,
                imageName: "building.2.fill"
            ),
            GameLevel(
                id: 5,
                name: "Crystal Cave",
                description: "Explore division in the sparkling cave!",
                requiredStars: 70,
                maxQuestions: 10,
                allowedOperations: [.division],
                difficulty: .medium,
                isUnlocked: false,
                starsEarned: 0,
                imageName: "diamond.fill"
            ),
            GameLevel(
                id: 6,
                name: "Dragon's Lair",
                description: "Face the ultimate math challenge!",
                requiredStars: 100,
                maxQuestions: 20,
                allowedOperations: [.addition, .subtraction, .multiplication, .division],
                difficulty: .hard,
                isUnlocked: false,
                starsEarned: 0,
                imageName: "flame.fill"
            )
        ]
    }
    
    private func loadPlayerProgress() {
        if let data = UserDefaults.standard.data(forKey: "PlayerProgress"),
           let decoded = try? JSONDecoder().decode(PlayerProgress.self, from: data) {
            playerProgress = decoded
        }
    }
    
    func savePlayerProgress() {
        if let encoded = try? JSONEncoder().encode(playerProgress) {
            UserDefaults.standard.set(encoded, forKey: "PlayerProgress")
        }
    }
    
    func unlockLevel(_ levelId: Int) {
        if let index = levels.firstIndex(where: { $0.id == levelId }) {
            levels[index] = GameLevel(
                id: levels[index].id,
                name: levels[index].name,
                description: levels[index].description,
                requiredStars: levels[index].requiredStars,
                maxQuestions: levels[index].maxQuestions,
                allowedOperations: levels[index].allowedOperations,
                difficulty: levels[index].difficulty,
                isUnlocked: true,
                starsEarned: levels[index].starsEarned,
                imageName: levels[index].imageName
            )
        }
    }
    
    func addStarsToLevel(_ levelId: Int, stars: Int) {
        if let index = levels.firstIndex(where: { $0.id == levelId }) {
            let currentStars = levels[index].starsEarned
            levels[index] = GameLevel(
                id: levels[index].id,
                name: levels[index].name,
                description: levels[index].description,
                requiredStars: levels[index].requiredStars,
                maxQuestions: levels[index].maxQuestions,
                allowedOperations: levels[index].allowedOperations,
                difficulty: levels[index].difficulty,
                isUnlocked: levels[index].isUnlocked,
                starsEarned: max(currentStars, stars),
                imageName: levels[index].imageName
            )
        }
        
        playerProgress.totalStars += stars
        playerProgress.completedLevels.insert(levelId)
        
        // Check if next level should be unlocked
        checkAndUnlockNextLevel()
        savePlayerProgress()
    }
    
    private func checkAndUnlockNextLevel() {
        for level in levels {
            if !level.isUnlocked && playerProgress.totalStars >= level.requiredStars {
                unlockLevel(level.id)
            }
        }
    }
    
    func getLevelProgress(_ levelId: Int) -> GameLevel? {
        return levels.first { $0.id == levelId }
    }
    
    func getUnlockedLevels() -> [GameLevel] {
        return levels.filter { $0.isUnlocked }
    }
    
    func earnBadge(_ badgeName: String) {
        if !playerProgress.badges.contains(badgeName) {
            playerProgress.badges.append(badgeName)
            savePlayerProgress()
        }
    }
    
    func checkBadgeEligibility() {
        // First Answer Badge
        if playerProgress.totalQuestionsAnswered >= 1 && !playerProgress.badges.contains("First Answer") {
            earnBadge("First Answer")
        }
        
        // Perfect Score Badge
        if playerProgress.bestStreak >= 10 && !playerProgress.badges.contains("Perfect 10") {
            earnBadge("Perfect 10")
        }
        
        // Math Master Badge
        if playerProgress.totalStars >= 100 && !playerProgress.badges.contains("Math Master") {
            earnBadge("Math Master")
        }
        
        // Accuracy Expert Badge
        if playerProgress.accuracy >= 90 && playerProgress.totalQuestionsAnswered >= 50 && !playerProgress.badges.contains("Accuracy Expert") {
            earnBadge("Accuracy Expert")
        }
    }
}
