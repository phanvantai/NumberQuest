//
//  AdaptiveDifficultyEngine.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 25/6/25.
//

import Foundation
import GameplayKit

/// Adaptive difficulty engine that analyzes player performance and adjusts game difficulty in real-time
class AdaptiveDifficultyEngine {
    
    // MARK: - Properties
    
    private var performanceHistory: [PerformanceData] = []
    private var sessionStartTime: Date = Date()
    private var currentSessionData: [PerformanceData] = []
    
    // Configuration parameters
    private let minimumSampleSize: Int = 5
    private let performanceWindowSize: Int = 10
    private let streakThreshold: Int = 3
    private let targetAccuracy: Double = 0.75 // 75% target accuracy
    private let targetResponseTime: TimeInterval = 5.0 // 5 seconds target
    
    // Difficulty adjustment thresholds
    private let increaseThreshold: Double = 0.85 // Increase difficulty at 85% accuracy
    private let decreaseThreshold: Double = 0.60 // Decrease difficulty at 60% accuracy
    private let fastResponseThreshold: TimeInterval = 3.0 // Fast response under 3 seconds
    private let slowResponseThreshold: TimeInterval = 8.0 // Slow response over 8 seconds
    
    // MARK: - Initialization
    
    init() {
        sessionStartTime = Date()
    }
    
    // MARK: - Performance Analysis
    
    /// Analyzes current performance metrics
    func analyzePerformance() -> PerformanceMetrics {
        let recentData = getRecentPerformanceData()
        
        return PerformanceMetrics(
            averageResponseTime: calculateAverageResponseTime(from: recentData),
            accuracyPercentage: calculateAccuracy(from: recentData),
            currentStreak: calculateCurrentStreak(),
            longestStreak: calculateLongestStreak(),
            problemTypeAccuracy: calculateProblemTypeAccuracy(from: recentData),
            recentPerformanceTrend: analyzeTrend(from: recentData),
            strugglingAreas: identifyStrugglingAreas(from: recentData),
            masteredAreas: identifyMasteredAreas(from: recentData)
        )
    }
    
    /// Records a new performance data point
    func recordPerformance(_ data: PerformanceData) {
        performanceHistory.append(data)
        currentSessionData.append(data)
        
        // Keep history manageable (last 100 problems)
        if performanceHistory.count > 100 {
            performanceHistory.removeFirst()
        }
    }
    
    /// Provides difficulty adjustment recommendation based on current performance
    func recommendDifficultyAdjustment(currentDifficulty: Int) -> DifficultyAdjustment {
        let metrics = analyzePerformance()
        
        // Not enough data for reliable analysis
        guard performanceHistory.count >= minimumSampleSize else {
            return DifficultyAdjustment(
                recommendedChange: .maintain,
                confidence: 0.3,
                reason: "Insufficient data for analysis",
                helpSuggestions: []
            )
        }
        
        let recentData = getRecentPerformanceData()
        let accuracy = metrics.accuracyPercentage
        let avgTime = metrics.averageResponseTime
        let streak = metrics.currentStreak
        
        var helpSuggestions: [HelpSuggestion] = []
        var change: DifficultyChange = .maintain
        var confidence: Double = 0.5
        var reason: String = ""
        
        // Analysis logic
        if accuracy >= increaseThreshold && avgTime <= fastResponseThreshold && streak >= streakThreshold {
            // Player is performing excellently - increase difficulty
            change = currentDifficulty >= 8 ? .adaptiveIncrease : .increase(by: 1)
            confidence = 0.9
            reason = "Excellent performance: high accuracy (\(Int(accuracy * 100))%) and fast responses"
            
        } else if accuracy <= decreaseThreshold || avgTime >= slowResponseThreshold {
            // Player is struggling - decrease difficulty or provide help
            if currentDifficulty > 1 {
                change = .decrease(by: 1)
                confidence = 0.8
                reason = "Performance indicates need for easier problems"
            } else {
                change = .maintain
                helpSuggestions.append(.showHint)
                helpSuggestions.append(.slowDown)
            }
            
            if avgTime >= slowResponseThreshold {
                helpSuggestions.append(.slowDown)
                reason += " - slow response times detected"
            }
            
        } else if accuracy >= targetAccuracy && avgTime <= targetResponseTime {
            // Player is in the sweet spot - maintain current difficulty
            change = .maintain
            confidence = 0.7
            reason = "Performance is optimal for current difficulty level"
            
        } else {
            // Mixed performance - use trend analysis
            switch metrics.recentPerformanceTrend {
            case .improving:
                change = .adaptiveIncrease
                confidence = 0.6
                reason = "Performance trend is improving"
                
            case .declining:
                change = .adaptiveDecrease
                confidence = 0.6
                reason = "Performance trend is declining"
                helpSuggestions.append(.encouragement)
                
            case .fluctuating:
                change = .maintain
                confidence = 0.4
                reason = "Performance is inconsistent"
                helpSuggestions.append(.providePractice(problemType: findWeakestProblemType(from: recentData)))
                
            case .stable:
                change = .maintain
                confidence = 0.8
                reason = "Performance is stable at current difficulty"
            }
        }
        
        // Add struggle-specific help suggestions
        for strugglingArea in metrics.strugglingAreas {
            helpSuggestions.append(.providePractice(problemType: strugglingArea))
        }
        
        // Check for fatigue indicators
        if detectFatigue(from: recentData) {
            helpSuggestions.append(.breakTime)
            if change == .increase(by: 1) {
                change = .maintain // Don't increase difficulty when tired
            }
        }
        
        return DifficultyAdjustment(
            recommendedChange: change,
            confidence: confidence,
            reason: reason,
            helpSuggestions: Array(Set(helpSuggestions)) // Remove duplicates
        )
    }
    
    /// Generates a session summary
    func generateSessionSummary() -> SessionSummary {
        let totalProblems = currentSessionData.count
        let correctAnswers = currentSessionData.filter { $0.wasCorrect }.count
        let averageTime = calculateAverageResponseTime(from: currentSessionData)
        
        var difficultyProgression: [Int] = []
        // This would be populated by tracking difficulty changes during the session
        
        let helpUsed = currentSessionData.reduce(0) { $0 + $1.hintsUsed }
        
        let achievements = generateAchievements(from: currentSessionData)
        let areasForImprovement = identifyStrugglingAreas(from: currentSessionData)
        
        return SessionSummary(
            totalProblems: totalProblems,
            correctAnswers: correctAnswers,
            averageTime: averageTime,
            difficultyProgression: difficultyProgression,
            helpUsed: helpUsed,
            achievements: achievements,
            areasForImprovement: areasForImprovement
        )
    }
    
    /// Resets session data for a new session
    func startNewSession() {
        currentSessionData.removeAll()
        sessionStartTime = Date()
    }
    
    // MARK: - Private Analysis Methods
    
    private func getRecentPerformanceData() -> [PerformanceData] {
        let count = min(performanceWindowSize, performanceHistory.count)
        return Array(performanceHistory.suffix(count))
    }
    
    private func calculateAverageResponseTime(from data: [PerformanceData]) -> TimeInterval {
        guard !data.isEmpty else { return 0 }
        return data.reduce(0) { $0 + $1.responseTime } / Double(data.count)
    }
    
    private func calculateAccuracy(from data: [PerformanceData]) -> Double {
        guard !data.isEmpty else { return 0 }
        let correct = data.filter { $0.wasCorrect }.count
        return Double(correct) / Double(data.count)
    }
    
    private func calculateCurrentStreak() -> Int {
        var streak = 0
        for data in performanceHistory.reversed() {
            if data.wasCorrect {
                streak += 1
            } else {
                break
            }
        }
        return streak
    }
    
    private func calculateLongestStreak() -> Int {
        var longestStreak = 0
        var currentStreak = 0
        
        for data in performanceHistory {
            if data.wasCorrect {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }
        
        return longestStreak
    }
    
    private func calculateProblemTypeAccuracy(from data: [PerformanceData]) -> [ProblemType: Double] {
        var typeStats: [ProblemType: (correct: Int, total: Int)] = [:]
        
        // Note: We'd need to store problem type in PerformanceData for this to work
        // For now, returning empty dictionary as placeholder
        return [:]
    }
    
    private func analyzeTrend(from data: [PerformanceData]) -> PerformanceTrend {
        guard data.count >= 5 else { return .stable }
        
        let firstHalf = Array(data.prefix(data.count / 2))
        let secondHalf = Array(data.suffix(data.count / 2))
        
        let firstAccuracy = calculateAccuracy(from: firstHalf)
        let secondAccuracy = calculateAccuracy(from: secondHalf)
        
        let difference = secondAccuracy - firstAccuracy
        
        if difference > 0.1 {
            return .improving
        } else if difference < -0.1 {
            return .declining
        } else if abs(difference) <= 0.05 {
            return .stable
        } else {
            return .fluctuating
        }
    }
    
    private func identifyStrugglingAreas(from data: [PerformanceData]) -> [ProblemType] {
        // Placeholder - would analyze performance by problem type
        return []
    }
    
    private func identifyMasteredAreas(from data: [PerformanceData]) -> [ProblemType] {
        // Placeholder - would identify problem types with consistently high performance
        return []
    }
    
    private func findWeakestProblemType(from data: [PerformanceData]) -> ProblemType {
        // Placeholder - would return the problem type with lowest accuracy
        return .addition
    }
    
    private func detectFatigue(from data: [PerformanceData]) -> Bool {
        guard data.count >= 5 else { return false }
        
        let recentData = Array(data.suffix(5))
        let recentAvgTime = calculateAverageResponseTime(from: recentData)
        let overallAvgTime = calculateAverageResponseTime(from: data)
        
        // Fatigue indicated by 50% slower responses in recent problems
        return recentAvgTime > overallAvgTime * 1.5
    }
    
    private func generateAchievements(from data: [PerformanceData]) -> [String] {
        var achievements: [String] = []
        
        let correctCount = data.filter { $0.wasCorrect }.count
        let accuracy = calculateAccuracy(from: data)
        let streak = calculateCurrentStreak()
        
        if correctCount >= 10 {
            achievements.append("Problem Solver: Solved 10+ problems!")
        }
        
        if accuracy >= 0.9 {
            achievements.append("Math Master: 90%+ accuracy!")
        }
        
        if streak >= 5 {
            achievements.append("Hot Streak: 5 correct in a row!")
        }
        
        let avgTime = calculateAverageResponseTime(from: data)
        if avgTime <= 3.0 && accuracy >= 0.8 {
            achievements.append("Speed Demon: Fast and accurate!")
        }
        
        return achievements
    }
}
