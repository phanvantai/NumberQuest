//
//  MathProblemGenerator.swift
//  NumberQuest
//
//  Created by GitHub Copilot on 25/6/25.
//

import Foundation
import GameplayKit

/// Generates age-appropriate math problems with adaptive difficulty and variety
class MathProblemGenerator {
    
    // MARK: - Properties
    
    /// Current difficulty level (1-10)
    private var currentDifficulty: DifficultyLevel
    
    /// Random number generator for consistent randomization
    private let randomSource: GKRandomSource
    
    /// Problem type distribution weights (addition: 70%, subtraction: 20%, multiplication: 10%)
    private let problemTypeWeights: [ProblemType: Double] = [
        .addition: 0.7,
        .subtraction: 0.2,
        .multiplication: 0.1
    ]
    
    /// Recently generated problems to avoid repetition
    private var recentProblems: [String] = []
    private let maxRecentProblemsToTrack = 10
    
    /// Player performance tracking for adaptive difficulty
    private var performanceHistory: [PerformanceData] = []
    private let maxPerformanceHistory = 20
    
    // MARK: - Initialization
    
    init(initialDifficulty: Int = 1) {
        self.currentDifficulty = DifficultyLevel(initialDifficulty)
        self.randomSource = GKRandomSource.sharedRandom()
    }
    
    // MARK: - Public Methods
    
    /// Generates a new math problem at the current difficulty level
    func generateProblem() -> MathProblem {
        let problemType = selectProblemType()
        let (first, second) = generateOperands(for: problemType)
        let problem = MathProblem(type: problemType, first: first, second: second, difficulty: currentDifficulty)
        
        // Track this problem to avoid repetition
        trackGeneratedProblem(problem)
        
        return problem
    }
    
    /// Generates a batch of problems for a level or session
    func generateProblems(count: Int) -> [MathProblem] {
        var problems: [MathProblem] = []
        
        for _ in 0..<count {
            let problem = generateProblem()
            problems.append(problem)
        }
        
        return problems
    }
    
    /// Updates difficulty based on player performance
    func updateDifficulty(basedOn performance: PerformanceData) {
        performanceHistory.append(performance)
        
        // Keep only recent performance data
        if performanceHistory.count > maxPerformanceHistory {
            performanceHistory.removeFirst()
        }
        
        // Analyze recent performance and adjust difficulty
        if performanceHistory.count >= 5 {
            let recentPerformance = Array(performanceHistory.suffix(5))
            adjustDifficultyBasedOnPerformance(recentPerformance)
        }
    }
    
    /// Returns current difficulty level
    var difficulty: Int {
        return currentDifficulty.level
    }
    
    /// Manually sets difficulty level (useful for parent controls)
    func setDifficulty(_ level: Int) {
        currentDifficulty = DifficultyLevel(level)
    }
    
    /// Resets the generator state (useful for new players or sessions)
    func reset() {
        recentProblems.removeAll()
        performanceHistory.removeAll()
        currentDifficulty = DifficultyLevel(1)
    }
    
    // MARK: - Private Methods
    
    /// Selects a problem type based on difficulty and distribution weights
    private func selectProblemType() -> ProblemType {
        // Filter problem types based on current difficulty level
        let availableTypes = ProblemType.allCases.filter { type in
            type.minimumDifficultyLevel <= currentDifficulty.level
        }
        
        // Create weighted distribution
        let weights = availableTypes.map { problemTypeWeights[$0] ?? 0.1 }
        let distribution = GKRandomDistribution(randomSource: randomSource, lowestValue: 0, highestValue: weights.count - 1)
        
        // Use weighted random selection
        let totalWeight = weights.reduce(0, +)
        let randomValue = Double.random(in: 0..<totalWeight)
        
        var cumulativeWeight = 0.0
        for (index, weight) in weights.enumerated() {
            cumulativeWeight += weight
            if randomValue < cumulativeWeight {
                return availableTypes[index]
            }
        }
        
        // Fallback to addition if something goes wrong
        return .addition
    }
    
    /// Generates appropriate operands for a given problem type
    private func generateOperands(for type: ProblemType) -> (first: Int, second: Int) {
        let maxFirst = currentDifficulty.maxFirstOperand
        let maxSecond = currentDifficulty.maxSecondOperand
        
        var first: Int
        var second: Int
        var attempts = 0
        let maxAttempts = 20
        
        repeat {
            attempts += 1
            
            switch type {
            case .addition:
                first = randomSource.nextInt(upperBound: maxFirst) + 1
                second = randomSource.nextInt(upperBound: maxSecond) + 1
                
            case .subtraction:
                // Ensure first >= second for positive results
                first = randomSource.nextInt(upperBound: maxFirst) + 1
                second = randomSource.nextInt(upperBound: min(first, maxSecond)) + 1
                
            case .multiplication:
                first = randomSource.nextInt(upperBound: min(maxFirst, 12)) + 1  // Keep multiplication manageable
                second = randomSource.nextInt(upperBound: min(maxSecond, 10)) + 1
            }
            
            // Check if this combination was used recently
            let problemKey = "\(first)\(type.symbol)\(second)"
            if !recentProblems.contains(problemKey) || attempts >= maxAttempts {
                break
            }
            
        } while attempts < maxAttempts
        
        return (first, second)
    }
    
    /// Tracks generated problems to avoid repetition
    private func trackGeneratedProblem(_ problem: MathProblem) {
        let problemKey = "\(problem.firstOperand)\(problem.problemType.symbol)\(problem.secondOperand)"
        recentProblems.append(problemKey)
        
        // Keep only recent problems
        if recentProblems.count > maxRecentProblemsToTrack {
            recentProblems.removeFirst()
        }
    }
    
    /// Adjusts difficulty based on performance analysis
    private func adjustDifficultyBasedOnPerformance(_ recentPerformance: [PerformanceData]) {
        let averageAccuracy = recentPerformance.map { $0.accuracy }.reduce(0, +) / Double(recentPerformance.count)
        let averageSpeed = recentPerformance.map { $0.responseTime }.reduce(0, +) / Double(recentPerformance.count)
        let targetTime = currentDifficulty.timeLimit * 0.7 // Target 70% of time limit
        
        // Increase difficulty if player is performing well
        if averageAccuracy >= 0.8 && averageSpeed <= targetTime {
            let newLevel = min(10, currentDifficulty.level + 1)
            currentDifficulty = DifficultyLevel(newLevel)
        }
        // Decrease difficulty if player is struggling
        else if averageAccuracy < 0.5 || averageSpeed > currentDifficulty.timeLimit {
            let newLevel = max(1, currentDifficulty.level - 1)
            currentDifficulty = DifficultyLevel(newLevel)
        }
    }
}

// MARK: - Supporting Data Structures

/// Represents player performance data for a single problem
struct PerformanceData {
    let problemId: UUID
    let wasCorrect: Bool
    let responseTime: TimeInterval
    let hintsUsed: Int
    let timestamp: Date
    
    /// Accuracy as a value between 0.0 and 1.0
    var accuracy: Double {
        return wasCorrect ? 1.0 : 0.0
    }
    
    init(problemId: UUID, correct: Bool, time: TimeInterval, hints: Int = 0) {
        self.problemId = problemId
        self.wasCorrect = correct
        self.responseTime = time
        self.hintsUsed = hints
        self.timestamp = Date()
    }
}
