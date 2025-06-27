//
//  ProblemType.swift
//  NumberQuest
//
//  Created by GitHub Copilot on 25/6/25.
//

import Foundation

/// Represents the different types of math problems available in the game
enum ProblemType: String, CaseIterable, Codable {
    case addition = "+"
    case subtraction = "-"
    case multiplication = "×"
    
    /// User-friendly display name for the problem type
    var displayName: String {
        switch self {
        case .addition:
            return "Addition"
        case .subtraction:
            return "Subtraction"
        case .multiplication:
            return "Multiplication"
        }
    }
    
    /// Symbol used to display the operation
    var symbol: String {
        return self.rawValue
    }
    
    /// Age range where this problem type is typically introduced
    var recommendedAgeRange: ClosedRange<Int> {
        switch self {
        case .addition:
            return 5...10
        case .subtraction:
            return 6...10
        case .multiplication:
            return 8...10
        }
    }
    
    /// Minimum difficulty level for this problem type
    var minimumDifficultyLevel: Int {
        switch self {
        case .addition:
            return 1
        case .subtraction:
            return 2
        case .multiplication:
            return 5
        }
    }
}
