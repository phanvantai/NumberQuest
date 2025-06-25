//
//  NumberQuestTests.swift
//  NumberQuestTests
//
//  Created by TaiPV on 25/6/25.
//

import Testing
@testable import NumberQuest
import Foundation

struct NumberQuestTests {
  
  @Test func example() async throws {
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
  }
  
  // MARK: - Math Problem Generator Tests
  
  @Test func testMathProblemGeneratorCreation() async throws {
    let generator = MathProblemGenerator(initialDifficulty: 1)
    #expect(generator.difficulty == 1)
  }
  
  @Test func testProblemGeneration() async throws {
    let generator = MathProblemGenerator(initialDifficulty: 1)
    let problem = generator.generateProblem()
    
    // Verify problem properties
    #expect(problem.firstOperand > 0)
    #expect(problem.secondOperand > 0)
    #expect(problem.difficultyLevel.level == 1)
    #expect(problem.timeLimit > 0)
    #expect(!problem.distractorAnswers.isEmpty)
  }
  
  @Test func testCorrectAnswerCalculation() async throws {
    let generator = MathProblemGenerator(initialDifficulty: 1)
    let problem = generator.generateProblem()
    
    // Test correct answer calculation based on problem type
    switch problem.problemType {
    case .addition:
      #expect(problem.correctAnswer == problem.firstOperand + problem.secondOperand)
    case .subtraction:
      #expect(problem.correctAnswer == problem.firstOperand - problem.secondOperand)
    case .multiplication:
      #expect(problem.correctAnswer == problem.firstOperand * problem.secondOperand)
    }
  }
  
  @Test func testAnswerValidation() async throws {
    let generator = MathProblemGenerator(initialDifficulty: 1)
    let problem = generator.generateProblem()
    
    // Test correct answer validation
    #expect(problem.isCorrect(answer: problem.correctAnswer) == true)
    
    // Test incorrect answer validation
    let wrongAnswer = problem.correctAnswer + 1
    #expect(problem.isCorrect(answer: wrongAnswer) == false)
  }
  
  @Test func testDifficultyScaling() async throws {
    let generator = MathProblemGenerator(initialDifficulty: 1)
    let problem1 = generator.generateProblem()
    
    generator.setDifficulty(5)
    let problem5 = generator.generateProblem()
    
    // Higher difficulty should have larger numbers
    #expect(problem5.firstOperand >= problem1.firstOperand)
  }
  
  @Test func testBatchProblemGeneration() async throws {
    let generator = MathProblemGenerator(initialDifficulty: 2)
    let problems = generator.generateProblems(count: 5)
    
    #expect(problems.count == 5)
    
    // Verify each problem is valid
    for problem in problems {
      #expect(problem.firstOperand > 0)
      #expect(problem.secondOperand > 0)
      #expect(problem.correctAnswer >= 0)
    }
  }
  
  @Test func testPerformanceTracking() async throws {
    let generator = MathProblemGenerator(initialDifficulty: 3)
    let problem = generator.generateProblem()
    
    // Simulate good performance
    let goodPerformance = PerformanceData(
      problemId: problem.id,
      correct: true,
      time: 2.0,
      hints: 0
    )
    
    generator.updateDifficulty(basedOn: goodPerformance)
    #expect(generator.difficulty >= 3) // Should maintain or increase difficulty
  }
  
  // MARK: - Adaptive Difficulty Engine Tests
  
  @Test func testAdaptiveDifficultyEngineCreation() async throws {
    let engine = AdaptiveDifficultyEngine()
    let metrics = engine.analyzePerformance()
    
    // Initial state should have zero metrics
    #expect(metrics.averageResponseTime == 0)
    #expect(metrics.accuracyPercentage == 0)
    #expect(metrics.currentStreak == 0)
  }
  
  @Test func testPerformanceRecording() async throws {
    let engine = AdaptiveDifficultyEngine()
    
    let performance1 = PerformanceData(
      problemId: UUID(),
      correct: true,
      time: 3.0,
      hints: 0
    )
    
    engine.recordPerformance(performance1)
    let metrics = engine.analyzePerformance()
    
    #expect(metrics.averageResponseTime == 3.0)
    #expect(metrics.accuracyPercentage == 1.0)
    #expect(metrics.currentStreak == 1)
  }
  
  @Test func testAccuracyCalculation() async throws {
    let engine = AdaptiveDifficultyEngine()
    
    // Record mixed performance
    for i in 0..<10 {
      let performance = PerformanceData(
        problemId: UUID(),
        correct: i < 7, // 7 correct out of 10 = 70%
        time: 4.0,
        hints: 0
      )
      engine.recordPerformance(performance)
    }
    
    let metrics = engine.analyzePerformance()
    #expect(abs(metrics.accuracyPercentage - 0.7) < 0.01) // 70% accuracy
  }
  
  @Test func testStreakCalculation() async throws {
    let engine = AdaptiveDifficultyEngine()
    
    // Record some incorrect answers, then correct streak
    let incorrectData = PerformanceData(
      problemId: UUID(),
      correct: false,
      time: 5.0,
      hints: 1
    )
    engine.recordPerformance(incorrectData)
    
    // Now record 3 correct answers in a row
    for _ in 0..<3 {
      let correctData = PerformanceData(
        problemId: UUID(),
        correct: true,
        time: 3.0,
        hints: 0
      )
      engine.recordPerformance(correctData)
    }
    
    let metrics = engine.analyzePerformance()
    #expect(metrics.currentStreak == 3)
  }
  
  @Test func testDifficultyIncraseRecommendation() async throws {
    let engine = AdaptiveDifficultyEngine()
    
    // Record excellent performance (high accuracy, fast responses)
    for _ in 0..<10 {
      let excellentPerformance = PerformanceData(
        problemId: UUID(),
        correct: true,
        time: 2.5, // Fast response
        hints: 0
      )
      engine.recordPerformance(excellentPerformance)
    }
    
    let adjustment = engine.recommendDifficultyAdjustment(currentDifficulty: 3)
    
    switch adjustment.recommendedChange {
    case .increase(_):
      // Should recommend increase
      break
    case .adaptiveIncrease:
      // Also acceptable
      break
    default:
      throw TestError.unexpectedResult("Expected difficulty increase recommendation")
    }
    
    #expect(adjustment.confidence > 0.7)
  }
  
  @Test func testDifficultyDecreaseRecommendation() async throws {
    let engine = AdaptiveDifficultyEngine()
    
    // Record poor performance (low accuracy, slow responses)
    for i in 0..<10 {
      let poorPerformance = PerformanceData(
        problemId: UUID(),
        correct: i < 4, // 40% accuracy
        time: 9.0, // Slow response
        hints: 2
      )
      engine.recordPerformance(poorPerformance)
    }
    
    let adjustment = engine.recommendDifficultyAdjustment(currentDifficulty: 5)
    
    switch adjustment.recommendedChange {
    case .decrease(_):
      // Should recommend decrease
      break
    case .adaptiveDecrease:
      // Also acceptable
      break
    default:
      throw TestError.unexpectedResult("Expected difficulty decrease recommendation")
    }
    
    #expect(adjustment.confidence > 0.6)
    #expect(!adjustment.helpSuggestions.isEmpty)
  }
  
  @Test func testMaintainDifficultyRecommendation() async throws {
    let engine = AdaptiveDifficultyEngine()
    
    // Record balanced performance (target accuracy and timing)
    for i in 0..<10 {
      let balancedPerformance = PerformanceData(
        problemId: UUID(),
        correct: i < 8, // 80% accuracy - above target (75%)
        time: 4.5, // Good response time (below 5.0 target)
        hints: 0
      )
      engine.recordPerformance(balancedPerformance)
    }
    
    let adjustment = engine.recommendDifficultyAdjustment(currentDifficulty: 4)
    
    switch adjustment.recommendedChange {
    case .maintain:
      // Should recommend maintaining current difficulty
      break
    default:
      throw TestError.unexpectedResult("Expected maintain difficulty recommendation")
    }
  }
  
  @Test func testInsufficientDataHandling() async throws {
    let engine = AdaptiveDifficultyEngine()
    
    // Record only 2 data points (less than minimum sample size)
    for _ in 0..<2 {
      let performance = PerformanceData(
        problemId: UUID(),
        correct: true,
        time: 4.0,
        hints: 0
      )
      engine.recordPerformance(performance)
    }
    
    let adjustment = engine.recommendDifficultyAdjustment(currentDifficulty: 3)
    
    switch adjustment.recommendedChange {
    case .maintain:
      // Should maintain when insufficient data
      break
    default:
      throw TestError.unexpectedResult("Expected maintain with insufficient data")
    }
    
    #expect(adjustment.confidence < 0.5)
  }
  
  @Test func testSessionSummaryGeneration() async throws {
    let engine = AdaptiveDifficultyEngine()
    
    // Record a session of 15 problems
    for i in 0..<15 {
      let performance = PerformanceData(
        problemId: UUID(),
        correct: i < 12, // 12/15 = 80% accuracy
        time: Double.random(in: 2.0...6.0),
        hints: i >= 10 ? 1 : 0 // Use hints on last 5 problems
      )
      engine.recordPerformance(performance)
    }
    
    let summary = engine.generateSessionSummary()
    
    #expect(summary.totalProblems == 15)
    #expect(summary.correctAnswers == 12)
    #expect(summary.averageTime > 0)
    #expect(summary.helpUsed == 5) // Hints used on 5 problems
  }
  
  @Test func testPerformanceTrendAnalysis() async throws {
    let engine = AdaptiveDifficultyEngine()
    
    // Record improving performance (poor start, good finish)
    for i in 0..<10 {
      let performance = PerformanceData(
        problemId: UUID(),
        correct: i >= 3, // First 3 wrong, rest correct = improving
        time: 4.0,
        hints: 0
      )
      engine.recordPerformance(performance)
    }
    
    let metrics = engine.analyzePerformance()
    #expect(metrics.recentPerformanceTrend == .improving)
  }
  
  @Test func testNewSessionReset() async throws {
    let engine = AdaptiveDifficultyEngine()
    
    // Record some performance data
    for _ in 0..<5 {
      let performance = PerformanceData(
        problemId: UUID(),
        correct: true,
        time: 3.0,
        hints: 0
      )
      engine.recordPerformance(performance)
    }
    
    // Start new session
    engine.startNewSession()
    
    // Session data should be reset
    let summary = engine.generateSessionSummary()
    #expect(summary.totalProblems == 0)
    #expect(summary.correctAnswers == 0)
  }
}

// MARK: - Test Helper

enum TestError: Error {
  case unexpectedResult(String)
}
