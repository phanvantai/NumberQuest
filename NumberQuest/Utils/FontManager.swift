//
//  FontManager.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 26/6/25.
//

import UIKit

/// FontManager handles custom font configuration and provides easy access to app fonts
class FontManager {
    
    // MARK: - Font Names
    
    enum FontName: String {
        case witchMagic = "FzWitchMagic"
        case wowDino = "WowDino"
      case blockBluePrint = "BlockBlueprint"
      case stormfaze = "Stormfaze-Regular"
      case domCasual = "FzDomCasual"
        
        var fileName: String {
            switch self {
            case .witchMagic:
                return "FzWitchMagic.ttf"
            case .wowDino:
                return "WowDino-G33vP.ttf"
            case .blockBluePrint:
                return "Blockblueprint-LV7z5.ttf"
            case .stormfaze:
                return "Stormfaze.otf"
            case .domCasual:
                return "FzDomCasual.otf"
            }
        }
    }
    
    // MARK: - Font Sizes
    
    enum FontSize: CGFloat {
        case extraSmall = 12
        case small = 16
        case medium = 24
        case large = 32
        case extraLarge = 48
        case title = 64
        case gameTitle = 80
    }
    
    // MARK: - Public Methods
    
    /// Get a custom font with specified name and size
    static func font(_ fontName: FontName, size: FontSize) -> UIFont {
        return font(fontName, size: size.rawValue)
    }
    
    /// Get a custom font with specified name and custom size
    static func font(_ fontName: FontName, size: CGFloat) -> UIFont {
        if let customFont = UIFont(name: fontName.rawValue, size: size) {
            return customFont
        } else {
            print("⚠️ Warning: Custom font '\(fontName.rawValue)' not found. Using system font instead.")
            return UIFont.systemFont(ofSize: size, weight: .bold)
        }
    }
    
    // MARK: - Convenience Methods for Common Use Cases
    
    /// Main game title font (FzWitchMagic, large size)
    static func gameTitle(size: FontSize = .gameTitle) -> UIFont {
        return font(.witchMagic, size: size)
    }
    
    /// Menu button font (FzWitchMagic, medium size)
    static func menuButton(size: FontSize = .large) -> UIFont {
        return font(.witchMagic, size: size)
    }
    
    /// Game UI font (WowDino, various sizes)
    static func gameUI(size: FontSize = .medium) -> UIFont {
        return font(.wowDino, size: size)
    }
    
    /// Score and stats font (WowDino, medium size)
    static func scoreText(size: FontSize = .medium) -> UIFont {
        return font(.wowDino, size: size)
    }
    
    /// Action/adventure font (Stormfaze, for dramatic text)
    static func adventureText(size: FontSize = .large) -> UIFont {
        return font(.stormfaze, size: size)
    }
    
    /// Blueprint/construction font (BlockBlueprint, for technical elements)
    static func technicalText(size: FontSize = .medium) -> UIFont {
        return font(.blockBluePrint, size: size)
    }
    
    /// Casual/friendly font (DomCasual, for hints and help text)
    static func casualText(size: FontSize = .medium) -> UIFont {
        return font(.domCasual, size: size)
    }
    
    // MARK: - Font Registration
    
    /// Register all custom fonts (call this at app startup)
    static func registerCustomFonts() {
      let fontNames: [FontName] = [.witchMagic, .wowDino, .blockBluePrint, .stormfaze, .domCasual]
        
        for fontName in fontNames {
            registerFont(fontName)
        }
    }
    
    /// Register a specific font
    private static func registerFont(_ fontName: FontName) {
        let fileName = fontName.fileName
        let fileExtension = (fileName as NSString).pathExtension
        let baseName = (fileName as NSString).deletingPathExtension
        
        guard let fontPath = Bundle.main.path(forResource: baseName, ofType: fileExtension),
              let fontData = NSData(contentsOfFile: fontPath),
              let dataProvider = CGDataProvider(data: fontData),
              let font = CGFont(dataProvider) else {
            print("❌ Error: Unable to load font '\(fontName.fileName)'")
            return
        }
        
        var error: Unmanaged<CFError>?
        if !CTFontManagerRegisterGraphicsFont(font, &error) {
            if let error = error {
                let errorDescription = CFErrorCopyDescription(error.takeUnretainedValue())
                print("❌ Error registering font '\(fontName.fileName)': \(errorDescription ?? "Unknown error" as CFString)")
                error.release()
            }
        } else {
            print("✅ Successfully registered font: \(fontName.fileName)")
        }
    }
    
    // MARK: - Font Testing
    
    /// List all available fonts (useful for debugging)
    static func listAllFonts() {
        print("📝 Available Fonts:")
        for family in UIFont.familyNames.sorted() {
            print("Family: \(family)")
            for name in UIFont.fontNames(forFamilyName: family) {
                print("  - \(name)")
            }
        }
    }
    
    /// Test if custom fonts are properly loaded
    static func testCustomFonts() {
        print("🧪 Testing Custom Fonts:")
        
        let testFonts: [(FontName, FontSize)] = [
            (.witchMagic, .title),
            (.wowDino, .medium),
            (.blockBluePrint, .medium),
            (.stormfaze, .medium),
            (.domCasual, .medium)
        ]
        
        for (fontName, fontSize) in testFonts {
            let font = FontManager.font(fontName, size: fontSize)
            let isCustom = font.fontName == fontName.rawValue
            let status = isCustom ? "✅" : "❌"
            print("\(status) \(fontName.rawValue) (\(fontSize.rawValue)pt): \(font.fontName)")
        }
    }
    
    /// Debug method to find the correct font names for custom fonts
    static func debugCustomFontNames() {
        print("🔍 Debugging Custom Font Names:")
        
        let customFontFiles = ["FzWitchMagic.ttf", "WowDino-G33vP.ttf", "Blockblueprint-LV7z5.ttf", "Stormfaze.otf", "FzDomCasual.otf"]
        
        for fontFile in customFontFiles {
            let fileExtension = (fontFile as NSString).pathExtension
            let baseName = (fontFile as NSString).deletingPathExtension
            
            if let fontPath = Bundle.main.path(forResource: baseName, ofType: fileExtension),
               let fontData = NSData(contentsOfFile: fontPath),
               let dataProvider = CGDataProvider(data: fontData),
               let font = CGFont(dataProvider),
               let fontName = font.postScriptName {
                print("📁 File: \(fontFile)")
                print("   PostScript Name: \(fontName)")
                
                // Also check if it's in the font families
                for family in UIFont.familyNames {
                    let fontNames = UIFont.fontNames(forFamilyName: family)
                    if fontNames.contains(String(fontName)) {
                        print("   Found in family: \(family)")
                        print("   Available variants: \(fontNames)")
                    }
                }
                print("---")
            } else {
                print("❌ Could not load font file: \(fontFile)")
            }
        }
    }
}
