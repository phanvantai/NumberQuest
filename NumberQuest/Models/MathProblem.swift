//
//  MathProblem.swift
//  NumberQuest
//
//  Created by GitHub Copilot on 25/6/25.
//

import Foundation

/// Represents a single math problem with all necessary data for gameplay
struct MathProblem {
    let id: UUID
    let problemType: ProblemType
    let firstOperand: Int
    let secondOperand: Int
    let correctAnswer: Int
    let difficultyLevel: DifficultyLevel
    let timeLimit: TimeInterval
    let distractorAnswers: [Int]
    let createdAt: Date
    
    init(type: ProblemType, first: Int, second: Int, difficulty: DifficultyLevel) {
        self.id = UUID()
        self.problemType = type
        self.firstOperand = first
        self.secondOperand = second
        self.difficultyLevel = difficulty
        self.timeLimit = difficulty.timeLimit
        self.createdAt = Date()
        
        // Calculate correct answer based on problem type
        switch type {
        case .addition:
            self.correctAnswer = first + second
        case .subtraction:
            self.correctAnswer = first - second
        case .multiplication:
            self.correctAnswer = first * second
        }
        
        // Generate distractor answers (wrong answers for multiple choice)
        self.distractorAnswers = MathProblem.generateDistractors(
            for: self.correctAnswer,
            count: difficulty.numberOfDistractors,
            problemType: type
        )
    }
    
    /// Returns the problem as a formatted string (e.g., "5 + 3 = ?")
    var formattedProblem: String {
        return "\(firstOperand) \(problemType.symbol) \(secondOperand) = ?"
    }
    
    /// Returns all answer choices (correct + distractors) in randomized order
    var allAnswerChoices: [Int] {
        var choices = distractorAnswers + [correctAnswer]
        choices.shuffle()
        return choices
    }
    
    /// Validates if a given answer is correct
    func isCorrect(answer: Int) -> Bool {
        return answer == correctAnswer
    }
    
    /// Returns hint text to help struggling players
    var hint: String {
        switch problemType {
        case .addition:
            if firstOperand <= 5 && secondOperand <= 5 {
                return "Try counting up from \(firstOperand)!"
            } else {
                return "Break it down: \(firstOperand) + \(secondOperand)"
            }
        case .subtraction:
            if firstOperand <= 10 {
                return "Count backwards from \(firstOperand)!"
            } else {
                return "Think: What do I add to \(secondOperand) to get \(firstOperand)?"
            }
        case .multiplication:
            if secondOperand <= 5 {
                return "Add \(firstOperand) to itself \(secondOperand) times!"
            } else {
                return "Remember your times tables!"
            }
        }
    }
    
    /// Generates plausible wrong answers for multiple choice
    private static func generateDistractors(for correctAnswer: Int, count: Int, problemType: ProblemType) -> [Int] {
        var distractors: Set<Int> = []
        
        // Generate different types of common mistakes
        for _ in 0..<count {
            var distractor: Int
            
            switch problemType {
            case .addition:
                // Common mistakes: off by 1, adding wrong numbers
                let mistakes = [
                    correctAnswer + 1,
                    correctAnswer - 1,
                    correctAnswer + 2,
                    correctAnswer - 2,
                    max(0, correctAnswer - Int.random(in: 1...3))
                ]
                distractor = mistakes.randomElement() ?? correctAnswer + 1
                
            case .subtraction:
                // Common mistakes: wrong direction, off by small amounts
                let mistakes = [
                    correctAnswer + 1,
                    correctAnswer - 1,
                    correctAnswer + 2,
                    max(0, correctAnswer + Int.random(in: 1...5))
                ]
                distractor = mistakes.randomElement() ?? correctAnswer + 1
                
            case .multiplication:
                // Common mistakes: addition instead of multiplication, wrong times table
                let mistakes = [
                    correctAnswer + Int.random(in: 1...5),
                    correctAnswer - Int.random(in: 1...5),
                    max(1, correctAnswer / 2),
                    correctAnswer * 2
                ]
                distractor = mistakes.randomElement() ?? correctAnswer + 1
            }
            
            // Ensure distractor is positive and different from correct answer
            distractor = max(0, distractor)
            if distractor != correctAnswer && !distractors.contains(distractor) {
                distractors.insert(distractor)
            }
        }
        
        // Fill remaining slots if we don't have enough unique distractors
        while distractors.count < count {
            let randomDistractor = max(0, correctAnswer + Int.random(in: -5...5))
            if randomDistractor != correctAnswer {
                distractors.insert(randomDistractor)
            }
        }
        
        return Array(distractors.prefix(count))
    }
}
