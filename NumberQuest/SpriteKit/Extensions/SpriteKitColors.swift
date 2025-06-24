//
//  SpriteKitColors.swift
//  NumberQuest
//
//  Created by TaiPV on 24/6/25.
//

import SpriteKit
import SwiftUI

/// Centralized color management system for SpriteKit scenes
/// Converts SwiftUI colors to SpriteKit-compatible UIColors with consistent theming
struct SpriteKitColors {
    
    // MARK: - Singleton
    static let shared = SpriteKitColors()
    private init() {}
    
    // MARK: - Primary Game Colors
    
    /// Background gradient colors for different game contexts
    struct Backgrounds {
        static let mainMenu = [
            UIColor(red: 0.1, green: 0.2, blue: 0.8, alpha: 1.0), // Deep blue
            UIColor(red: 0.3, green: 0.1, blue: 0.7, alpha: 1.0), // Purple
            UIColor(red: 0.7, green: 0.2, blue: 0.9, alpha: 1.0), // Magenta
            UIColor(red: 0.9, green: 0.4, blue: 0.6, alpha: 1.0)  // Pink
        ]
        
        static let gamePlay = [
            UIColor(red: 0.2, green: 0.7, blue: 1.0, alpha: 1.0), // Bright blue
            UIColor(red: 0.4, green: 0.9, blue: 0.6, alpha: 1.0)  // Green
        ]
        
        static let campaignMap = [
            UIColor(red: 0.1, green: 0.6, blue: 0.3, alpha: 1.0), // Forest green
            UIColor(red: 0.8, green: 0.9, blue: 0.3, alpha: 1.0)  // Light green
        ]
        
        static let results = [
            UIColor(red: 0.9, green: 0.6, blue: 0.1, alpha: 1.0), // Golden
            UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)  // Yellow
        ]
    }
    
    /// UI Element Colors
    struct UI {
        // Button Colors
        static let primaryButton = UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 0.9)
        static let primaryButtonPressed = UIColor(red: 0.1, green: 0.5, blue: 0.9, alpha: 0.9)
        
        static let secondaryButton = UIColor(red: 0.5, green: 0.7, blue: 0.9, alpha: 0.8)
        static let secondaryButtonPressed = UIColor(red: 0.4, green: 0.6, blue: 0.8, alpha: 0.8)
        
        static let successButton = UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 0.9)
        static let warningButton = UIColor(red: 1.0, green: 0.6, blue: 0.1, alpha: 0.9)
        static let dangerButton = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 0.9)
        
        // Answer Button Colors
        static let answerDefault = UIColor(red: 0.3, green: 0.5, blue: 0.9, alpha: 0.8)
        static let answerCorrect = UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 0.9)
        static let answerWrong = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 0.9)
        
        // Progress and Status
        static let progressBackground = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.4)
        static let progressFill = UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 0.9)
        static let progressFillStreak = UIColor(red: 1.0, green: 0.6, blue: 0.1, alpha: 0.9)
        
        // Card and Panel Colors
        static let cardBackground = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.1)
        static let cardShadow = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.3)
        
        // Overlay Colors
        static let successOverlay = UIColor(red: 0.2, green: 0.8, blue: 0.3, alpha: 0.3)
        static let errorOverlay = UIColor(red: 0.9, green: 0.3, blue: 0.3, alpha: 0.3)
        
        // Shorthand aliases for commonly used colors
        static let primary = primaryButton
        static let success = successButton
        static let warning = warningButton
        static let danger = dangerButton
        
        // Text colors for UI elements
        static let onPrimary = UIColor.white
        static let onSuccess = UIColor.white
        static let onWarning = UIColor.white
        static let onDanger = UIColor.white
    }
    
    /// Text Colors for different contexts
    struct Text {
        static let primary = UIColor.white
        static let secondary = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 0.8)
        static let accent = UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0) // Yellow
        static let success = UIColor(red: 0.3, green: 0.9, blue: 0.4, alpha: 1.0)
        static let warning = UIColor(red: 1.0, green: 0.6, blue: 0.1, alpha: 1.0)
        static let error = UIColor(red: 1.0, green: 0.4, blue: 0.4, alpha: 1.0)
        
        // Score and Game Status
        static let score = UIColor.white
        static let streak = UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0)
        static let timer = UIColor(red: 1.0, green: 0.6, blue: 0.1, alpha: 1.0)
        static let question = UIColor.white
    }
    
    /// Particle Effect Colors
    struct Particles {
        static let celebration = [
            UIColor.yellow,
            UIColor.orange,
            UIColor(red: 1.0, green: 0.3, blue: 0.8, alpha: 1.0), // Pink
            UIColor(red: 0.3, green: 0.8, blue: 1.0, alpha: 1.0), // Cyan
        ]
        
        static let success = [
            UIColor(red: 0.2, green: 0.9, blue: 0.3, alpha: 1.0), // Bright green
            UIColor(red: 0.6, green: 1.0, blue: 0.4, alpha: 1.0), // Light green
        ]
        
        static let wrong = [
            UIColor(red: 0.9, green: 0.2, blue: 0.2, alpha: 1.0), // Red
            UIColor(red: 1.0, green: 0.4, blue: 0.1, alpha: 1.0), // Orange-red
        ]
        
        static let magic = [
            UIColor(red: 0.9, green: 0.3, blue: 1.0, alpha: 1.0), // Magenta
            UIColor(red: 0.4, green: 0.7, blue: 1.0, alpha: 1.0), // Sky blue
            UIColor(red: 1.0, green: 0.9, blue: 0.3, alpha: 1.0), // Gold
        ]
    }
    
    // MARK: - Utility Methods
    
    /// Convert SwiftUI Color to UIColor for SpriteKit compatibility
    static func uiColor(from swiftUIColor: Color) -> UIColor {
        return UIColor(swiftUIColor)
    }
    
    /// Create a gradient background node
    static func createGradientBackground(
        colors: [UIColor],
        size: CGSize,
        direction: GradientDirection = .topToBottom
    ) -> SKSpriteNode {
        
        // For now, we'll create a simple color node
        // TODO: Implement proper gradient using shaders or texture generation
        let gradientNode = SKSpriteNode(color: colors.first ?? .blue, size: size)
        gradientNode.zPosition = -100
        
        return gradientNode
    }
    
    /// Get random color from array for particle effects
    static func randomColor(from colors: [UIColor]) -> UIColor {
        return colors.randomElement() ?? .white
    }
}

/// Gradient direction for background creation
enum GradientDirection {
    case topToBottom
    case leftToRight
    case diagonal
    case radial
}

// MARK: - Color Theme Extensions

extension SpriteKitColors {
    
    /// Get themed colors based on game difficulty
    static func getThemeColors(for difficulty: GameDifficulty) -> [UIColor] {
        switch difficulty {
        case .easy:
            return [
                UIColor(red: 0.4, green: 0.9, blue: 0.6, alpha: 1.0), // Light green
                UIColor(red: 0.6, green: 1.0, blue: 0.4, alpha: 1.0)  // Bright green
            ]
        case .medium:
            return [
                UIColor(red: 0.2, green: 0.7, blue: 1.0, alpha: 1.0), // Blue
                UIColor(red: 0.5, green: 0.8, blue: 1.0, alpha: 1.0)  // Light blue
            ]
        case .hard:
            return [
                UIColor(red: 0.9, green: 0.4, blue: 0.2, alpha: 1.0), // Orange-red
                UIColor(red: 1.0, green: 0.6, blue: 0.3, alpha: 1.0)  // Orange
            ]
        }
    }
    
    /// Get colors based on game mode
    static func getColors(for gameMode: GameMode) -> [UIColor] {
        switch gameMode {
        case .campaign:
            return Backgrounds.campaignMap
        case .quickPlay:
            return Backgrounds.gamePlay
        }
    }
    
    /// Get button color based on context
    static func getButtonColor(for context: ButtonContext) -> UIColor {
        switch context {
        case .primary:
            return UI.primaryButton
        case .secondary:
            return UI.secondaryButton
        case .success:
            return UI.successButton
        case .warning:
            return UI.warningButton
        case .danger:
            return UI.dangerButton
        case .answer:
            return UI.answerDefault
        }
    }
}

/// Button context for theming
enum ButtonContext {
    case primary
    case secondary
    case success
    case warning
    case danger
    case answer
}
