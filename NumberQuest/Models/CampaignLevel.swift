//
//  CampaignLevel.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 27/6/25.
//

import Foundation
import UIKit

/// Represents a single level in the campaign mode
struct CampaignLevel {
    let id: Int
    let worldTheme: WorldTheme
    let title: String
    let description: String
    let requiredStars: Int
    let maxStars: Int
    let difficultyRange: ClosedRange<Int>
    let problemCount: Int
    let isUnlocked: Bool
    let completedStars: Int
    let position: CGPoint // Position on the map
    
    init(id: Int, 
         worldTheme: WorldTheme, 
         title: String, 
         description: String, 
         requiredStars: Int = 0, 
         maxStars: Int = 3, 
         difficultyRange: ClosedRange<Int>, 
         problemCount: Int = 5, 
         position: CGPoint, 
         isUnlocked: Bool = false, 
         completedStars: Int = 0) {
        self.id = id
        self.worldTheme = worldTheme
        self.title = title
        self.description = description
        self.requiredStars = requiredStars
        self.maxStars = maxStars
        self.difficultyRange = difficultyRange
        self.problemCount = problemCount
        self.position = position
        self.isUnlocked = isUnlocked
        self.completedStars = completedStars
    }
    
    /// Whether this level has been completed (at least 1 star)
    var isCompleted: Bool {
        return completedStars > 0
    }
    
    /// Whether this level is perfectly completed (all stars)
    var isPerfectlyCompleted: Bool {
        return completedStars >= maxStars
    }
    
    /// Recommended age range based on difficulty
    var recommendedAgeRange: String {
        let minAge = 5 + difficultyRange.lowerBound / 2
        let maxAge = 5 + difficultyRange.upperBound / 2
        return "\(minAge)-\(maxAge) years"
    }
}

/// Different world themes for campaign levels
enum WorldTheme: String, CaseIterable {
    case forest = "Forest"
    case ocean = "Ocean"
    case space = "Space"
    case castle = "Castle"
    
    /// Background color associated with the theme
    var backgroundColor: UIColor {
        switch self {
        case .forest:
            return UIColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 1.0) // Forest green
        case .ocean:
            return UIColor(red: 0.1, green: 0.4, blue: 0.8, alpha: 1.0) // Ocean blue
        case .space:
            return UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1.0) // Space dark blue
        case .castle:
            return UIColor(red: 0.6, green: 0.5, blue: 0.4, alpha: 1.0) // Castle stone
        }
    }
    
    /// Emoji icon for the theme
    var icon: String {
        switch self {
        case .forest:
            return "🌲"
        case .ocean:
            return "🌊"
        case .space:
            return "🚀"
        case .castle:
            return "🏰"
        }
    }
    
    /// Decorative elements for the theme
    var decorativeElements: [String] {
        switch self {
        case .forest:
            return ["🌳", "🍄", "🦋", "🌸"]
        case .ocean:
            return ["🐠", "🐚", "⭐", "🪸"]
        case .space:
            return ["🌟", "🪐", "🛸", "☄️"]
        case .castle:
            return ["👑", "🗡️", "🛡️", "💎"]
        }
    }
}
