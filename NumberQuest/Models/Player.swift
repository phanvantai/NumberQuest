//
//  Player.swift
//  NumberQuest
//
//  Created by GitHub Copilot on 27/6/25.
//

import Foundation

/// Represents the player's profile, progress, and statistics throughout the game
class Player: Codable {
    // MARK: - Core Identity
    let id: UUID
    var name: String
    var avatarStyle: AvatarStyle
    var createdAt: Date
    var lastPlayedAt: Date
    
    // MARK: - Level System
    var experiencePoints: Int
    var currentLevel: Int {
        // Calculate level based on experience points
        // Each level requires increasingly more XP: 100, 300, 600, 1000, 1500...
        let baseXP = 100
        var requiredXP = 0
        var level = 1
        
        while requiredXP <= experiencePoints {
            level += 1
            requiredXP += baseXP * level
        }
        
        return max(1, level - 1)
    }
    
    var experiencePointsToNextLevel: Int {
        let nextLevel = currentLevel + 1
        let baseXP = 100
        var totalRequiredXP = 0
        
        for i in 1...nextLevel {
            totalRequiredXP += baseXP * i
        }
        
        return totalRequiredXP - experiencePoints
    }
    
    // MARK: - Performance Metrics
    var totalProblemsAttempted: Int
    var totalProblemsCorrect: Int
    var overallAccuracy: Double {
        guard totalProblemsAttempted > 0 else { return 0.0 }
        return Double(totalProblemsCorrect) / Double(totalProblemsAttempted) * 100.0
    }
    
    var currentStreak: Int
    var longestStreak: Int
    var totalPlayTime: TimeInterval // in seconds
    
    // MARK: - Speed Metrics
    var bestAverageResponseTime: TimeInterval
    var currentSessionResponseTimes: [TimeInterval]
    var averageResponseTime: TimeInterval {
        guard !currentSessionResponseTimes.isEmpty else { return bestAverageResponseTime }
        return currentSessionResponseTimes.reduce(0, +) / Double(currentSessionResponseTimes.count)
    }
    
    // MARK: - Problem Type Performance
    var problemTypeStats: [ProblemType: ProblemTypeStats]
    
    // MARK: - Campaign Progress
    var unlockedCampaignLevels: Set<String> // Level IDs
    var completedCampaignLevels: [String: LevelCompletion] // Level ID -> Completion data
    var currentCampaignWorld: Int
    
    // MARK: - Achievements & Rewards
    var earnedStars: Int
    var spentStars: Int
    var availableStars: Int { return earnedStars - spentStars }
    var unlockedAchievements: Set<String> // Achievement IDs
    var unlockedRewards: Set<String> // Reward IDs (outfits, pets, etc.)
    
    // MARK: - Customization
    var selectedOutfit: String?
    var selectedPet: String?
    var customizationItems: Set<String> // Owned customization item IDs
    
    // MARK: - Learning Progression
    var currentDifficultyLevel: DifficultyLevel
    var masteredSkills: Set<MathSkill>
    var strugglingSkills: Set<MathSkill>
    var learningGoals: [LearningGoal]
    
    // MARK: - Settings & Preferences
    var preferredGameMode: GameMode
    var parentalSettings: ParentalSettings?
    
    // MARK: - Initialization
    init(name: String, avatarStyle: AvatarStyle = .default) {
        self.id = UUID()
        self.name = name
        self.avatarStyle = avatarStyle
        self.createdAt = Date()
        self.lastPlayedAt = Date()
        
        // Initialize level system
        self.experiencePoints = 0
        
        // Initialize performance metrics
        self.totalProblemsAttempted = 0
        self.totalProblemsCorrect = 0
        self.currentStreak = 0
        self.longestStreak = 0
        self.totalPlayTime = 0
        
        // Initialize speed metrics
        self.bestAverageResponseTime = 10.0 // 10 seconds default
        self.currentSessionResponseTimes = []
        
        // Initialize problem type performance
        self.problemTypeStats = [
            .addition: ProblemTypeStats(),
            .subtraction: ProblemTypeStats(),
            .multiplication: ProblemTypeStats()
        ]
        
        // Initialize campaign progress
        self.unlockedCampaignLevels = ["level_1_1"] // First level unlocked by default
        self.completedCampaignLevels = [:]
        self.currentCampaignWorld = 1
        
        // Initialize rewards
        self.earnedStars = 0
        self.spentStars = 0
        self.unlockedAchievements = []
        self.unlockedRewards = []
        
        // Initialize customization
        self.selectedOutfit = nil
        self.selectedPet = nil
        self.customizationItems = []
        
        // Initialize learning progression
        self.currentDifficultyLevel = DifficultyLevel(1)
        self.masteredSkills = []
        self.strugglingSkills = []
        self.learningGoals = []
        
        // Initialize preferences
        self.preferredGameMode = .campaign
        self.parentalSettings = nil
    }
    
    // MARK: - Progress Tracking Methods
    
    /// Record a completed math problem and update relevant statistics
    func recordProblemAttempt(problem: MathProblem, isCorrect: Bool, responseTime: TimeInterval) {
        totalProblemsAttempted += 1
        lastPlayedAt = Date()
        
        // Update response times
        currentSessionResponseTimes.append(responseTime)
        if responseTime < bestAverageResponseTime || bestAverageResponseTime == 0 {
            bestAverageResponseTime = responseTime
        }
        
        if isCorrect {
            totalProblemsCorrect += 1
            currentStreak += 1
            longestStreak = max(longestStreak, currentStreak)
            
            // Award experience points based on difficulty and speed
            let baseXP = problem.difficultyLevel.level * 10
            let speedBonus = responseTime < 3.0 ? 5 : (responseTime < 5.0 ? 3 : 0)
            let totalXP = baseXP + speedBonus
            awardExperiencePoints(totalXP)
            
        } else {
            currentStreak = 0
        }
        
        // Update problem type statistics
        if var stats = problemTypeStats[problem.problemType] {
            stats.recordAttempt(isCorrect: isCorrect, responseTime: responseTime)
            problemTypeStats[problem.problemType] = stats
        }
        
        // Update skill progression
        updateSkillProgression(for: problem.problemType, isCorrect: isCorrect)
    }
    
    /// Award experience points and handle level up
    func awardExperiencePoints(_ points: Int) {
        let previousLevel = currentLevel
        experiencePoints += points
        
        let newLevel = currentLevel
        if newLevel > previousLevel {
            handleLevelUp(from: previousLevel, to: newLevel)
        }
    }
    
    /// Handle level up rewards and unlocks
    private func handleLevelUp(from oldLevel: Int, to newLevel: Int) {
        // Award stars for leveling up
        let starsAwarded = (newLevel - oldLevel) * 5
        earnedStars += starsAwarded
        
        // Unlock new content based on level
        unlockContentForLevel(newLevel)
    }
    
    /// Unlock new campaign levels, customization items, etc. based on player level
    private func unlockContentForLevel(_ level: Int) {
        // Unlock new campaign levels every few player levels
        if level % 3 == 0 {
            let worldNumber = (level / 3) + 1
            let levelId = "level_\(worldNumber)_1"
            unlockedCampaignLevels.insert(levelId)
            currentCampaignWorld = max(currentCampaignWorld, worldNumber)
        }
        
        // Unlock customization items at specific levels
        switch level {
        case 5:
            unlockedRewards.insert("outfit_superhero")
        case 10:
            unlockedRewards.insert("pet_dragon")
        case 15:
            unlockedRewards.insert("outfit_wizard")
        case 20:
            unlockedRewards.insert("pet_unicorn")
        default:
            break
        }
    }
    
    /// Complete a campaign level and record stars earned
    func completeCampaignLevel(_ levelId: String, stars: Int, timeBonus: Bool = false) {
        let completion = LevelCompletion(
            stars: stars,
            completedAt: Date(),
            bestTime: nil,
            hasTimeBonus: timeBonus
        )
        
        completedCampaignLevels[levelId] = completion
        earnedStars += stars
        
        // Unlock next level if this was completed with at least 1 star
        if stars > 0 {
            unlockNextLevel(after: levelId)
        }
    }
    
    /// Unlock the next campaign level in sequence
    private func unlockNextLevel(after levelId: String) {
        // Parse level ID to determine next level
        // Format: "level_world_number" (e.g., "level_1_3")
        let components = levelId.components(separatedBy: "_")
        guard components.count == 3,
              let world = Int(components[1]),
              let number = Int(components[2]) else { return }
        
        let nextLevelId = "level_\(world)_\(number + 1)"
        unlockedCampaignLevels.insert(nextLevelId)
    }
    
    /// Update skill progression based on performance
    private func updateSkillProgression(for problemType: ProblemType, isCorrect: Bool) {
        let skill = MathSkill.from(problemType: problemType)
        
        if isCorrect {
            // Check if skill should be marked as mastered
            if let stats = problemTypeStats[problemType],
               stats.accuracy >= 85.0 && stats.attemptCount >= 20 {
                masteredSkills.insert(skill)
                strugglingSkills.remove(skill)
            }
        } else {
            // Check if skill should be marked as struggling
            if let stats = problemTypeStats[problemType],
               stats.accuracy < 60.0 && stats.attemptCount >= 10 {
                strugglingSkills.insert(skill)
                masteredSkills.remove(skill)
            }
        }
    }
    
    /// Record play time for a session
    func recordPlayTime(_ duration: TimeInterval) {
        totalPlayTime += duration
        lastPlayedAt = Date()
    }
    
    /// Reset current session data (call when starting new session)
    func startNewSession() {
        currentSessionResponseTimes = []
        lastPlayedAt = Date()
    }
    
    /// Purchase an item with stars
    func purchaseItem(itemId: String, cost: Int) -> Bool {
        guard availableStars >= cost else { return false }
        
        spentStars += cost
        customizationItems.insert(itemId)
        return true
    }
    
    /// Select an outfit for the character
    func selectOutfit(_ outfitId: String) -> Bool {
        guard unlockedRewards.contains(outfitId) || customizationItems.contains(outfitId) else {
            return false
        }
        selectedOutfit = outfitId
        return true
    }
    
    /// Select a pet companion
    func selectPet(_ petId: String) -> Bool {
        guard unlockedRewards.contains(petId) || customizationItems.contains(petId) else {
            return false
        }
        selectedPet = petId
        return true
    }
}

// MARK: - Supporting Types

/// Player avatar style options
enum AvatarStyle: String, Codable, CaseIterable {
    case `default` = "default"
    case adventurer = "adventurer"
    case scientist = "scientist"
    case artist = "artist"
    case athlete = "athlete"
}

/// Campaign level completion data
struct LevelCompletion: Codable {
    let stars: Int // 1-3 stars
    let completedAt: Date
    let bestTime: TimeInterval?
    let hasTimeBonus: Bool
}

/// Performance statistics for each problem type
struct ProblemTypeStats: Codable {
    var attemptCount: Int
    var correctCount: Int
    var totalResponseTime: TimeInterval
    
    var accuracy: Double {
        guard attemptCount > 0 else { return 0.0 }
        return Double(correctCount) / Double(attemptCount) * 100.0
    }
    
    var averageResponseTime: TimeInterval {
        guard attemptCount > 0 else { return 0.0 }
        return totalResponseTime / Double(attemptCount)
    }
    
    init() {
        self.attemptCount = 0
        self.correctCount = 0
        self.totalResponseTime = 0.0
    }
    
    mutating func recordAttempt(isCorrect: Bool, responseTime: TimeInterval) {
        attemptCount += 1
        totalResponseTime += responseTime
        
        if isCorrect {
            correctCount += 1
        }
    }
}

/// Math skills that can be mastered or struggled with
enum MathSkill: String, Codable, CaseIterable {
    case basicAddition = "basic_addition"
    case basicSubtraction = "basic_subtraction"
    case basicMultiplication = "basic_multiplication"
    case advancedAddition = "advanced_addition"
    case advancedSubtraction = "advanced_subtraction"
    case advancedMultiplication = "advanced_multiplication"
    case numberRecognition = "number_recognition"
    case patternRecognition = "pattern_recognition"
    
    static func from(problemType: ProblemType) -> MathSkill {
        switch problemType {
        case .addition:
            return .basicAddition
        case .subtraction:
            return .basicSubtraction
        case .multiplication:
            return .basicMultiplication
        }
    }
}

/// Learning goals set by parents or the adaptive system
struct LearningGoal: Codable, Identifiable {
    let id: UUID
    let title: String
    let description: String
    let targetSkill: MathSkill
    let targetAccuracy: Double // Percentage
    let targetProblemCount: Int
    let createdAt: Date
    let targetDate: Date?
    var isCompleted: Bool
    
    init(title: String, description: String, targetSkill: MathSkill, targetAccuracy: Double, targetProblemCount: Int, targetDate: Date? = nil) {
        self.id = UUID()
        self.title = title
        self.description = description
        self.targetSkill = targetSkill
        self.targetAccuracy = targetAccuracy
        self.targetProblemCount = targetProblemCount
        self.createdAt = Date()
        self.targetDate = targetDate
        self.isCompleted = false
    }
}

/// Game mode preferences
enum GameMode: String, Codable, CaseIterable {
    case campaign = "campaign"
    case quickPlay = "quick_play"
    case mixed = "mixed"
}

/// Parental control settings
struct ParentalSettings: Codable {
    var maxDailyPlayTime: TimeInterval // in seconds
    var allowedDifficultyRange: ClosedRange<Int> // Min and max difficulty levels
    var requireParentApprovalForPurchases: Bool
    var enableProgressReports: Bool
    var reportFrequency: ReportFrequency
    
    enum ReportFrequency: String, Codable, CaseIterable {
        case daily = "daily"
        case weekly = "weekly"
        case monthly = "monthly"
    }
    
    init() {
        self.maxDailyPlayTime = 60 * 60 // 1 hour default
        self.allowedDifficultyRange = 1...10
        self.requireParentApprovalForPurchases = true
        self.enableProgressReports = true
        self.reportFrequency = .weekly
    }
    
    // MARK: - Codable Implementation
    private enum CodingKeys: String, CodingKey {
        case maxDailyPlayTime
        case allowedDifficultyRangeMin
        case allowedDifficultyRangeMax
        case requireParentApprovalForPurchases
        case enableProgressReports
        case reportFrequency
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        maxDailyPlayTime = try container.decode(TimeInterval.self, forKey: .maxDailyPlayTime)
        let minDifficulty = try container.decode(Int.self, forKey: .allowedDifficultyRangeMin)
        let maxDifficulty = try container.decode(Int.self, forKey: .allowedDifficultyRangeMax)
        allowedDifficultyRange = minDifficulty...maxDifficulty
        requireParentApprovalForPurchases = try container.decode(Bool.self, forKey: .requireParentApprovalForPurchases)
        enableProgressReports = try container.decode(Bool.self, forKey: .enableProgressReports)
        reportFrequency = try container.decode(ReportFrequency.self, forKey: .reportFrequency)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(maxDailyPlayTime, forKey: .maxDailyPlayTime)
        try container.encode(allowedDifficultyRange.lowerBound, forKey: .allowedDifficultyRangeMin)
        try container.encode(allowedDifficultyRange.upperBound, forKey: .allowedDifficultyRangeMax)
        try container.encode(requireParentApprovalForPurchases, forKey: .requireParentApprovalForPurchases)
        try container.encode(enableProgressReports, forKey: .enableProgressReports)
        try container.encode(reportFrequency, forKey: .reportFrequency)
    }
}
