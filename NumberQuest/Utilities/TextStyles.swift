//
//  TextStyles.swift
//  NumberQuest
//
//  Created by TaiPV on 20/6/25.
//

import SwiftUI

// MARK: - Text Style System

/// Centralized text styling system for NumberQuest
/// Makes it easy to apply consistent fonts and styles throughout the app
struct TextStyle {
    let font: Font
    let color: Color
    let weight: Font.Weight?
    
    init(font: Font, color: Color = .primary, weight: Font.Weight? = nil) {
        self.font = font
        self.color = color
        self.weight = weight
    }
}

// MARK: - Font Configuration
extension TextStyle {
    /// The main custom font name
    static var customFontName: String {
        return "Chewy-Regular"
    }
    
    /// Fallback font for secondary text
    static var secondaryFontName: String {
        return "Baloo2-VariableFont_wght"
    }
    
    /// Whether to use the custom font or system font
    static var useCustomFont: Bool {
        return true
    }
    
    /// Helper to create the primary custom font
    private static func customFont(size: CGFloat) -> Font {
        return Font.custom(customFontName, size: size)
    }
    
    /// Helper to create the secondary custom font (for body text)
    private static func secondaryFont(size: CGFloat) -> Font {
        return Font.custom(secondaryFontName, size: size)
    }
    
    /// Helper to create system font with consistent design (fallback)
    private static func systemFont(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        return .system(size: size, weight: weight, design: .rounded)
    }
    
    /// Smart font selector - tries custom font first, falls back to system font
    private static func font(size: CGFloat, useSecondary: Bool = false) -> Font {
        if useCustomFont {
            if useSecondary {
                return secondaryFont(size: size)
            } else {
                return customFont(size: size)
            }
        } else {
            return systemFont(size: size)
        }
}

// MARK: - Predefined Text Styles
extension TextStyle {
    
    // MARK: - Headings (use primary custom font - Chewy)
    static let largeTitle = TextStyle(
        font: font(size: 38),
        color: .white
    )
    
    static let title = TextStyle(
        font: font(size: 28),
        color: .white
    )
    
    static let subtitle = TextStyle(
        font: font(size: 22),
        color: .white
    )
    
    static let heading = TextStyle(
        font: font(size: 18),
        color: .white
    )
    
    // MARK: - Body Text (use secondary font - Baloo2 for better readability)
    static let body = TextStyle(
        font: font(size: 16, useSecondary: true),
        color: .white.opacity(0.9)
    )
    
    static let bodySecondary = TextStyle(
        font: font(size: 16, useSecondary: true),
        color: .white.opacity(0.8)
    )
    
    static let caption = TextStyle(
        font: font(size: 14, useSecondary: true),
        color: .white.opacity(0.7)
    )
    
    static let smallCaption = TextStyle(
        font: font(size: 12, useSecondary: true),
        color: .white.opacity(0.6)
    )
    
    // MARK: - Button Text (use primary font - Chewy)
    static let buttonLarge = TextStyle(
        font: font(size: 20),
        color: .white
    )
    
    static let buttonMedium = TextStyle(
        font: font(size: 18),
        color: .white
    )
    
    static let buttonSmall = TextStyle(
        font: font(size: 16),
        color: .white
    )
    
    // MARK: - Game-specific Text (use primary font - Chewy)
    static let gameTitle = TextStyle(
        font: font(size: 42),
        color: .white
    )
    
    static let questionText = TextStyle(
        font: font(size: 32),
        color: .white
    )
    
    static let answerText = TextStyle(
        font: font(size: 24),
        color: .white
    )
    
    static let scoreText = TextStyle(
        font: font(size: 20),
        color: .white
    )
    
    static let timerText = TextStyle(
        font: font(size: 18),
        color: .white
    )
    
    // MARK: - Special Styles
    static let emoji = TextStyle(
        font: .system(size: 24),
        color: .clear // Emojis don't need color
    )
    
    static let largeEmoji = TextStyle(
        font: .system(size: 32),
        color: .clear
    )
}

/*
 INSTRUCTIONS FOR ADDING A CUSTOM FONT:
 
 1. Add your custom font files (.ttf or .otf) to your Xcode project
 2. Add the font files to your Info.plist under "Fonts provided by application"
 3. Update the `customFontName` property above with your font's base name
 4. If your font family has different files for different weights, update the `fontWeightSuffix` method
 5. All text throughout the app will automatically switch to your custom font!
 
 Example:
 If you add a font called "GameFont-Regular.ttf", "GameFont-Bold.ttf", etc:
 - Set customFontName to "GameFont"
 - Adjust fontWeightSuffix to return appropriate suffixes
 
 If you have a single font file, you can return "" from fontWeightSuffix
 */

// MARK: - Dynamic Text Size Support
extension TextStyle {
    /// Creates a text style that adapts to the user's preferred text size
    static func adaptive(baseStyle: TextStyle, sizeCategory: ContentSizeCategory = .large) -> TextStyle {
        return TextStyle(
            font: baseStyle.font,
            color: baseStyle.color
        )
    }
}

// MARK: - Color Variants
extension TextStyle {
    /// Creates a variant of an existing style with a different color
    func withColor(_ color: Color) -> TextStyle {
        return TextStyle(font: self.font, color: color, weight: self.weight)
    }
    
    /// Creates a variant with reduced opacity
    func withOpacity(_ opacity: Double) -> TextStyle {
        return TextStyle(font: self.font, color: self.color.opacity(opacity), weight: self.weight)
    }
}

// MARK: - Theme-specific Styles
extension TextStyle {
    // Light mode variants (if you ever add theme switching)
    static let lightTitle = title.withColor(.black)
    static let lightBody = body.withColor(.black.opacity(0.8))
    static let lightCaption = caption.withColor(.black.opacity(0.6))
    
    // Error/Success states
    static let errorText = body.withColor(.red)
    static let successText = body.withColor(.green)
    static let warningText = body.withColor(.orange)
}

// MARK: - View Extension for Easy Usage
extension View {
    /// Apply a text style to any text view
    func textStyle(_ style: TextStyle) -> some View {
        self
            .font(style.font)
            .foregroundColor(style.color)
    }
}

// MARK: - Text View Extension
extension Text {
    /// Apply a text style directly to Text views
    func style(_ style: TextStyle) -> Text {
        self
            .font(style.font)
            .foregroundColor(style.color)
    }
}

// MARK: - Custom Text Components
struct StyledText: View {
    let text: String
    let style: TextStyle
    
    init(_ text: String, style: TextStyle) {
        self.text = text
        self.style = style
    }
    
    var body: some View {
        Text(text)
            .style(style)
    }
}

// MARK: - Game-specific Text Components
struct GameTitleText: View {
    let text: String
    let emoji: String?
    
    init(_ text: String, emoji: String? = nil) {
        self.text = text
        self.emoji = emoji
    }
    
    var body: some View {
        HStack {
            if let emoji = emoji {
                Text(emoji)
                    .style(.largeEmoji)
            }
            Text(text)
                .style(.gameTitle)
        }
    }
}

struct QuestionText: View {
    let question: String
    
    var body: some View {
        Text(question)
            .style(.questionText)
            .multilineTextAlignment(.center)
    }
}

struct ScoreText: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .style(.body)
            Text(value)
                .style(.scoreText)
        }
    }
}
