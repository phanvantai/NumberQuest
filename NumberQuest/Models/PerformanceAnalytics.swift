//
//  PerformanceAnalytics.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 25/6/25.
//

import Foundation

// MARK: - Performance Metrics

/// Comprehensive performance metrics for adaptive difficulty
struct PerformanceMetrics {
    let averageResponseTime: TimeInterval
    let accuracyPercentage: Double
    let currentStreak: Int
    let longestStreak: Int
    let problemTypeAccuracy: [ProblemType: Double]
    let recentPerformanceTrend: PerformanceTrend
    let strugglingAreas: [ProblemType]
    let masteredAreas: [ProblemType]
}

/// Performance trend analysis
enum PerformanceTrend {
    case improving
    case stable
    case declining
    case fluctuating
}

/// Difficulty adjustment recommendation
struct DifficultyAdjustment {
    let recommendedChange: DifficultyChange
    let confidence: Double // 0.0 to 1.0
    let reason: String
    let helpSuggestions: [HelpSuggestion]
}

/// Types of difficulty changes
enum DifficultyChange: Equatable {
    case increase(by: Int)
    case decrease(by: Int)
    case maintain
    case adaptiveIncrease // Gradual increase
    case adaptiveDecrease // Gradual decrease
}

/// Help system suggestions
enum HelpSuggestion: Equatable, Hashable {
    case showHint
    case simplifyProblem
    case providePractice(problemType: ProblemType)
    case slowDown
    case encouragement
    case breakTime
}

/// Session performance summary
struct SessionSummary {
    let totalProblems: Int
    let correctAnswers: Int
    let averageTime: TimeInterval
    let difficultyProgression: [Int]
    let helpUsed: Int
    let achievements: [String]
    let areasForImprovement: [ProblemType]
}
