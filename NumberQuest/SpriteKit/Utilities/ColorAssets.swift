//
//  ColorAssets.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 21/6/25.
//

import SpriteKit
import SwiftUI

/// Centralized color management for SpriteKit scenes
/// Converts SwiftUI color schemes to SpriteKit-compatible assets
class ColorAssets {
    
    // MARK: - Singleton
    static let shared = ColorAssets()
    private init() {}
    
    // MARK: - Primary Color Palette
    
    /// NumberQuest primary colors optimized for SpriteKit
    struct Primary {
        static let blue = UIColor(red: 0.1, green: 0.2, blue: 0.8, alpha: 1.0)
        static let purple = UIColor(red: 0.3, green: 0.1, blue: 0.7, alpha: 1.0)
        static let pink = UIColor(red: 0.7, green: 0.2, blue: 0.9, alpha: 1.0)
        static let coral = UIColor(red: 0.9, green: 0.4, blue: 0.6, alpha: 1.0)
        static let mint = UIColor(red: 0.4, green: 0.9, blue: 0.8, alpha: 1.0)
        static let yellow = UIColor(red: 1.0, green: 0.8, blue: 0.2, alpha: 1.0)
        static let orange = UIColor(red: 1.0, green: 0.5, blue: 0.2, alpha: 1.0)
        static let green = UIColor(red: 0.2, green: 0.8, blue: 0.4, alpha: 1.0)
    }
    
    // MARK: - Semantic Colors
    
    /// Colors for specific UI states and feedback
    struct Semantic {
        static let correct = Primary.green
        static let incorrect = Primary.coral
        static let warning = Primary.orange
        static let info = Primary.blue
        static let disabled = UIColor.systemGray
        static let background = UIColor.black
        static let surface = UIColor.white.withAlphaComponent(0.1)
    }
    
    // MARK: - Gradient Configurations
    
    /// Pre-configured gradient combinations for backgrounds
    enum GradientType {
        case mainBackground
        case gameBackground
        case menuBackground
        case cardBackground
        case buttonPrimary
        case buttonSecondary
        case success
        case error
        
        var colors: [UIColor] {
            switch self {
            case .mainBackground:
                return [Primary.blue, Primary.purple, Primary.pink, Primary.coral]
            case .gameBackground:
                return [Primary.mint, Primary.blue, Primary.purple]
            case .menuBackground:
                return [Primary.purple, Primary.pink, Primary.orange]
            case .cardBackground:
                return [Primary.blue.withAlphaComponent(0.8), Primary.purple.withAlphaComponent(0.6)]
            case .buttonPrimary:
                return [Primary.blue, Primary.purple]
            case .buttonSecondary:
                return [Primary.mint, Primary.green]
            case .success:
                return [Primary.green, Primary.mint]
            case .error:
                return [Primary.coral, Primary.orange]
            }
        }
        
        var alphas: [CGFloat] {
            switch self {
            case .mainBackground, .gameBackground, .menuBackground:
                return [1.0, 0.8, 0.6, 0.4]
            case .cardBackground:
                return [0.9, 0.7]
            default:
                return [1.0, 0.8]
            }
        }
    }
    
    // MARK: - Color Utilities
    
    /// Create a gradient sprite node
    func createGradientNode(size: CGSize, type: GradientType) -> SKNode {
        let container = SKNode()
        let colors = type.colors
        let alphas = type.alphas
        
        for (index, color) in colors.enumerated() {
            let alpha = index < alphas.count ? alphas[index] : 1.0
            let sprite = SKSpriteNode(color: color, size: size)
            sprite.alpha = alpha
            sprite.zPosition = CGFloat(-index)
            container.addChild(sprite)
        }
        
        return container
    }
    
    /// Get color with dynamic alpha based on context
    func dynamicColor(_ baseColor: UIColor, context: ColorContext) -> UIColor {
        switch context {
        case .background:
            return baseColor.withAlphaComponent(0.3)
        case .foreground:
            return baseColor
        case .disabled:
            return baseColor.withAlphaComponent(0.5)
        case .highlighted:
            return baseColor.withAlphaComponent(0.8)
        case .pressed:
            return baseColor.withAlphaComponent(0.9)
        }
    }
    
    /// Generate random color from palette
    func randomPrimaryColor() -> UIColor {
        let colors = [Primary.blue, Primary.purple, Primary.pink, Primary.coral, 
                     Primary.mint, Primary.yellow, Primary.orange, Primary.green]
        return colors.randomElement() ?? Primary.blue
    }
    
    /// Get contrasting text color for background
    func contrastingTextColor(for backgroundColor: UIColor) -> UIColor {
        // Simple brightness calculation
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        backgroundColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        let brightness = (red * 0.299 + green * 0.587 + blue * 0.114)
        return brightness > 0.5 ? .black : .white
    }
}

// MARK: - Supporting Enums

enum ColorContext {
    case background
    case foreground
    case disabled
    case highlighted
    case pressed
}

// MARK: - Color Extensions

extension UIColor {
    
    /// NumberQuest specific color variations
    func nqVariation(_ variation: ColorVariation) -> UIColor {
        switch variation {
        case .lighter:
            return self.withAlphaComponent(0.7)
        case .darker:
            return self.withBrightness(0.8)
        case .muted:
            return self.withSaturation(0.6)
        case .vibrant:
            return self.withSaturation(1.2)
        }
    }
    
    /// Adjust brightness
    func withBrightness(_ brightness: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var currentBrightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        getHue(&hue, saturation: &saturation, brightness: &currentBrightness, alpha: &alpha)
        
        return UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
    
    /// Adjust saturation
    func withSaturation(_ saturation: CGFloat) -> UIColor {
        var hue: CGFloat = 0
        var currentSaturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        getHue(&hue, saturation: &currentSaturation, brightness: &brightness, alpha: &alpha)
        
        return UIColor(hue: hue, saturation: min(1.0, saturation), brightness: brightness, alpha: alpha)
    }
}

// MARK: - UIColor Extensions

extension UIColor {
    /// NumberQuest branded colors
    static let nqBlue = ColorAssets.Primary.blue
    static let nqPurple = ColorAssets.Primary.purple
    static let nqPink = ColorAssets.Primary.pink
    static let nqCoral = ColorAssets.Primary.coral
    static let nqMint = ColorAssets.Primary.mint
    static let nqYellow = ColorAssets.Primary.yellow
    static let nqOrange = ColorAssets.Primary.orange
    static let nqGreen = ColorAssets.Primary.green
    
    /// Additional themed colors for variety
    static let nqTeal = UIColor(red: 0.2, green: 0.8, blue: 0.8, alpha: 1.0)
    static let nqIndigo = UIColor(red: 0.3, green: 0.0, blue: 0.5, alpha: 1.0)
    static let nqMagenta = UIColor(red: 0.8, green: 0.0, blue: 0.8, alpha: 1.0)
    static let nqCyan = UIColor(red: 0.0, green: 0.8, blue: 1.0, alpha: 1.0)
    static let nqRed = UIColor(red: 0.9, green: 0.2, blue: 0.3, alpha: 1.0)
}

enum ColorVariation {
    case lighter
    case darker
    case muted
    case vibrant
}
