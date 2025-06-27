//
//  DifficultyLevel.swift
//  NumberQuest
//
//  Created by GitHub Copilot on 25/6/25.
//

import Foundation

/// Represents difficulty levels from 1-10 with age-appropriate constraints
struct DifficultyLevel: Codable {
    let level: Int
    
    init(_ level: Int) {
        self.level = max(1, min(10, level)) // Clamp between 1-10
    }
    
    /// Maximum number range for first operand based on difficulty
    var maxFirstOperand: Int {
        switch level {
        case 1: return 5      // 1-5 (ages 5-6)
        case 2: return 10     // 1-10 (ages 6-7)
        case 3: return 15     // 1-15
        case 4: return 20     // 1-20 (ages 7-8)
        case 5: return 25     // 1-25
        case 6: return 50     // 1-50 (ages 8-9)
        case 7: return 75     // 1-75
        case 8: return 100    // 1-100 (ages 9-10)
        case 9: return 150    // 1-150
        case 10: return 200   // 1-200 (advanced)
        default: return 10
        }
    }
    
    /// Maximum number range for second operand based on difficulty
    var maxSecondOperand: Int {
        switch level {
        case 1: return 3      // Keep second number smaller for beginners
        case 2: return 5
        case 3: return 8
        case 4: return 10
        case 5: return 12
        case 6: return 15
        case 7: return 20
        case 8: return 25
        case 9: return 30
        case 10: return 50
        default: return 5
        }
    }
    
    /// Time limit in seconds for solving a problem at this difficulty
    var timeLimit: TimeInterval {
        switch level {
        case 1...2: return 15.0   // Plenty of time for beginners
        case 3...4: return 12.0
        case 5...6: return 10.0
        case 7...8: return 8.0
        case 9...10: return 6.0   // Quick thinking for advanced
        default: return 10.0
        }
    }
    
    /// Number of incorrect answer choices to provide (for multiple choice)
    var numberOfDistractors: Int {
        switch level {
        case 1...3: return 2      // 3 total choices (1 correct + 2 wrong)
        case 4...6: return 3      // 4 total choices
        case 7...10: return 4     // 5 total choices
        default: return 2
        }
    }
    
    /// Points awarded for correct answer at this difficulty
    var pointsAwarded: Int {
        return level * 10
    }
    
    /// Age range typically associated with this difficulty level
    var recommendedAge: ClosedRange<Int> {
        switch level {
        case 1...2: return 5...6
        case 3...4: return 6...7
        case 5...6: return 7...8
        case 7...8: return 8...9
        case 9...10: return 9...10
        default: return 5...10
        }
    }
}
