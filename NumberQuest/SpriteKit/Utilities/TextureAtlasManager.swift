//
//  TextureAtlasManager.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 21/6/25.
//

import SpriteKit

/// Manages texture atlases for efficient sprite animations
/// Handles loading, caching, and providing textures for game elements
class TextureAtlasManager {
    
    // MARK: - Singleton
    static let shared = TextureAtlasManager()
    private init() {}
    
    // MARK: - Properties
    
    private var atlases: [String: SKTextureAtlas] = [:]
    private var preloadedTextures: [String: [SKTexture]] = [:]
    
    // MARK: - Atlas Names
    
    struct AtlasNames {
        static let characters = "Characters"
        static let buttons = "Buttons"
        static let effects = "Effects"
        static let backgrounds = "Backgrounds"
        static let numbers = "Numbers"
        static let symbols = "Symbols"
        static let decorations = "Decorations"
    }
    
    // MARK: - Loading Methods
    
    /// Preload all essential texture atlases
    func preloadEssentialAtlases() {
        let essentialAtlases = [
            AtlasNames.buttons,
            AtlasNames.numbers,
            AtlasNames.symbols,
            AtlasNames.effects
        ]
        
        for atlasName in essentialAtlases {
            loadAtlas(named: atlasName)
        }
        
        // Create programmatic textures for basic shapes
        createBasicShapeTextures()
        
        print("✅ Essential texture atlases preloaded")
    }
    
    /// Load a specific texture atlas
    func loadAtlas(named name: String) {
        guard atlases[name] == nil else { return }
        
        // For now, create programmatic atlases since we don't have image files yet
        switch name {
        case AtlasNames.buttons:
            createButtonTextures()
        case AtlasNames.numbers:
            createNumberTextures()
        case AtlasNames.symbols:
            createSymbolTextures()
        case AtlasNames.effects:
            createEffectTextures()
        case AtlasNames.backgrounds:
            createBackgroundTextures()
        case AtlasNames.characters:
            createCharacterTextures()
        case AtlasNames.decorations:
            createDecorationTextures()
        default:
            // Try to load from bundle
            let atlas = SKTextureAtlas(named: name)
            atlases[name] = atlas
        }
    }
    
    // MARK: - Texture Retrieval
    
    /// Get texture from atlas
    func texture(named textureName: String, from atlasName: String) -> SKTexture? {
        loadAtlas(named: atlasName)
        
        if let preloaded = preloadedTextures[atlasName]?.first(where: { $0.description.contains(textureName) }) {
            return preloaded
        }
        
        return atlases[atlasName]?.textureNamed(textureName)
    }
    
    /// Get animation textures for a sequence
    func animationTextures(prefix: String, count: Int, from atlasName: String) -> [SKTexture] {
        loadAtlas(named: atlasName)
        
        var textures: [SKTexture] = []
        
        for i in 1...count {
            let textureName = "\(prefix)_\(String(format: "%02d", i))"
            if let texture = texture(named: textureName, from: atlasName) {
                textures.append(texture)
            }
        }
        
        return textures
    }
    
    // MARK: - Programmatic Texture Creation
    
    /// Create basic shape textures programmatically
    private func createBasicShapeTextures() {
        var basicTextures: [SKTexture] = []
        
        // Circle
        basicTextures.append(createCircleTexture(radius: 25, color: .white))
        
        // Rectangle
        basicTextures.append(createRectangleTexture(size: CGSize(width: 50, height: 30), color: .white))
        
        // Rounded rectangle
        basicTextures.append(createRoundedRectangleTexture(size: CGSize(width: 60, height: 40), cornerRadius: 10, color: .white))
        
        preloadedTextures["BasicShapes"] = basicTextures
    }
    
    /// Create button textures
    private func createButtonTextures() {
        var buttonTextures: [SKTexture] = []
        
        let buttonSizes = [
            CGSize(width: 120, height: 40),  // Small
            CGSize(width: 160, height: 50),  // Medium
            CGSize(width: 200, height: 60),  // Large
            CGSize(width: 250, height: 70)   // Extra Large
        ]
        
        let buttonColors = [
            ColorAssets.Primary.blue,
            ColorAssets.Primary.green,
            ColorAssets.Primary.orange,
            ColorAssets.Primary.purple
        ]
        
        for (sizeIndex, size) in buttonSizes.enumerated() {
            for (colorIndex, color) in buttonColors.enumerated() {
                let texture = createRoundedRectangleTexture(size: size, cornerRadius: 15, color: color)
                buttonTextures.append(texture)
            }
        }
        
        preloadedTextures[AtlasNames.buttons] = buttonTextures
    }
    
    /// Create number textures
    private func createNumberTextures() {
        var numberTextures: [SKTexture] = []
        
        // Create textures for numbers 0-9 and basic math symbols
        let characters = Array("0123456789+-×÷=?")
        
        for character in characters {
            let texture = createTextTexture(text: String(character), fontSize: 48, color: .white)
            numberTextures.append(texture)
        }
        
        preloadedTextures[AtlasNames.numbers] = numberTextures
    }
    
    /// Create symbol textures
    private func createSymbolTextures() {
        var symbolTextures: [SKTexture] = []
        
        let symbols = ["⭐", "✨", "🔥", "💎", "🎯", "🏆", "🎉", "⚡", "💫", "🌟"]
        
        for symbol in symbols {
            let texture = createTextTexture(text: symbol, fontSize: 32, color: .white)
            symbolTextures.append(texture)
        }
        
        preloadedTextures[AtlasNames.symbols] = symbolTextures
    }
    
    /// Create effect textures
    private func createEffectTextures() {
        var effectTextures: [SKTexture] = []
        
        // Particle textures
        let particleColors = [ColorAssets.Primary.yellow, ColorAssets.Primary.mint, ColorAssets.Primary.pink]
        
        for color in particleColors {
            // Small particles
            effectTextures.append(createCircleTexture(radius: 3, color: color))
            // Medium particles
            effectTextures.append(createCircleTexture(radius: 6, color: color))
            // Large particles
            effectTextures.append(createCircleTexture(radius: 10, color: color))
        }
        
        // Explosion effects (simple radiating circles)
        for i in 1...5 {
            let radius = CGFloat(10 + i * 5)
            let alpha = 1.0 - (CGFloat(i) * 0.15)
            let color = ColorAssets.Primary.yellow.withAlphaComponent(alpha)
            effectTextures.append(createCircleTexture(radius: radius, color: color))
        }
        
        preloadedTextures[AtlasNames.effects] = effectTextures
    }
    
    /// Create background element textures
    private func createBackgroundTextures() {
        var backgroundTextures: [SKTexture] = []
        
        // Geometric shapes for floating elements
        let shapes = [
            ("triangle", createTriangleTexture(size: 20, color: ColorAssets.Primary.mint.withAlphaComponent(0.7))),
            ("square", createRectangleTexture(size: CGSize(width: 15, height: 15), color: ColorAssets.Primary.pink.withAlphaComponent(0.7))),
            ("circle", createCircleTexture(radius: 10, color: ColorAssets.Primary.yellow.withAlphaComponent(0.7))),
            ("diamond", createDiamondTexture(size: 18, color: ColorAssets.Primary.purple.withAlphaComponent(0.7)))
        ]
        
        backgroundTextures.append(contentsOf: shapes.map { $0.1 })
        
        preloadedTextures[AtlasNames.backgrounds] = backgroundTextures
    }
    
    /// Create character textures (placeholder)
    private func createCharacterTextures() {
        var characterTextures: [SKTexture] = []
        
        // For now, create colored circles to represent different character states
        let characterColors = [
            ColorAssets.Primary.blue,    // Normal
            ColorAssets.Primary.green,   // Happy
            ColorAssets.Primary.yellow,  // Excited
            ColorAssets.Primary.orange,  // Encouraging
            ColorAssets.Primary.purple   // Thinking
        ]
        
        for color in characterColors {
            let texture = createCircleTexture(radius: 40, color: color)
            characterTextures.append(texture)
        }
        
        preloadedTextures[AtlasNames.characters] = characterTextures
    }
    
    /// Create decoration textures
    private func createDecorationTextures() {
        var decorationTextures: [SKTexture] = []
        
        // Various decorative elements
        let decorations = [
            createStarTexture(size: 20, color: ColorAssets.Primary.yellow),
            createHeartTexture(size: 18, color: ColorAssets.Primary.coral),
            createCrownTexture(size: 25, color: ColorAssets.Primary.orange)
        ]
        
        decorationTextures.append(contentsOf: decorations)
        
        preloadedTextures[AtlasNames.decorations] = decorationTextures
    }
    
    // MARK: - Texture Creation Helpers
    
    /// Create a circle texture
    private func createCircleTexture(radius: CGFloat, color: UIColor) -> SKTexture {
        let size = CGSize(width: radius * 2, height: radius * 2)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }
        
        context.setFillColor(color.cgColor)
        context.fillEllipse(in: CGRect(origin: .zero, size: size))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image ?? UIImage())
    }
    
    /// Create a rectangle texture
    private func createRectangleTexture(size: CGSize, color: UIColor) -> SKTexture {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }
        
        context.setFillColor(color.cgColor)
        context.fill(CGRect(origin: .zero, size: size))
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image ?? UIImage())
    }
    
    /// Create a rounded rectangle texture
    private func createRoundedRectangleTexture(size: CGSize, cornerRadius: CGFloat, color: UIColor) -> SKTexture {
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }
        
        let rect = CGRect(origin: .zero, size: size)
        let path = UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius)
        
        context.setFillColor(color.cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image ?? UIImage())
    }
    
    /// Create a text texture
    private func createTextTexture(text: String, fontSize: CGFloat, color: UIColor) -> SKTexture {
        let font = UIFont(name: "Baloo2-VariableFont_wght", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize, weight: .bold)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        
        let size = text.size(withAttributes: attributes)
        let expandedSize = CGSize(width: size.width + 10, height: size.height + 10)
        
        UIGraphicsBeginImageContextWithOptions(expandedSize, false, 0)
        
        let rect = CGRect(x: 5, y: 5, width: size.width, height: size.height)
        text.draw(in: rect, withAttributes: attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image ?? UIImage())
    }
    
    /// Create a triangle texture
    private func createTriangleTexture(size: CGFloat, color: UIColor) -> SKTexture {
        let canvasSize = CGSize(width: size, height: size)
        
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: size/2, y: 0))
        path.addLine(to: CGPoint(x: 0, y: size))
        path.addLine(to: CGPoint(x: size, y: size))
        path.close()
        
        context.setFillColor(color.cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image ?? UIImage())
    }
    
    /// Create a diamond texture
    private func createDiamondTexture(size: CGFloat, color: UIColor) -> SKTexture {
        let canvasSize = CGSize(width: size, height: size)
        
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: size/2, y: 0))
        path.addLine(to: CGPoint(x: size, y: size/2))
        path.addLine(to: CGPoint(x: size/2, y: size))
        path.addLine(to: CGPoint(x: 0, y: size/2))
        path.close()
        
        context.setFillColor(color.cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image ?? UIImage())
    }
    
    /// Create a star texture
    private func createStarTexture(size: CGFloat, color: UIColor) -> SKTexture {
        let canvasSize = CGSize(width: size, height: size)
        
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }
        
        // Simple 5-pointed star
        let center = CGPoint(x: size/2, y: size/2)
        let outerRadius = size/2
        let innerRadius = outerRadius * 0.4
        
        let path = UIBezierPath()
        for i in 0..<10 {
            let angle = CGFloat(i) * .pi / 5.0
            let radius = i % 2 == 0 ? outerRadius : innerRadius
            let x = center.x + radius * cos(angle - .pi/2)
            let y = center.y + radius * sin(angle - .pi/2)
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.close()
        
        context.setFillColor(color.cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image ?? UIImage())
    }
    
    /// Create a heart texture
    private func createHeartTexture(size: CGFloat, color: UIColor) -> SKTexture {
        let canvasSize = CGSize(width: size, height: size)
        
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }
        
        // Simple heart shape using emoji rendering
        let font = UIFont.systemFont(ofSize: size * 0.8)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color
        ]
        
        let heart = "♥"
        let textSize = heart.size(withAttributes: attributes)
        let rect = CGRect(
            x: (size - textSize.width) / 2,
            y: (size - textSize.height) / 2,
            width: textSize.width,
            height: textSize.height
        )
        
        heart.draw(in: rect, withAttributes: attributes)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image ?? UIImage())
    }
    
    /// Create a crown texture
    private func createCrownTexture(size: CGFloat, color: UIColor) -> SKTexture {
        let canvasSize = CGSize(width: size, height: size)
        
        UIGraphicsBeginImageContextWithOptions(canvasSize, false, 0)
        guard let context = UIGraphicsGetCurrentContext() else {
            UIGraphicsEndImageContext()
            return SKTexture()
        }
        
        // Simple crown shape
        let path = UIBezierPath()
        let baseY = size * 0.8
        let topY = size * 0.2
        
        path.move(to: CGPoint(x: 0, y: baseY))
        path.addLine(to: CGPoint(x: size * 0.2, y: topY))
        path.addLine(to: CGPoint(x: size * 0.5, y: size * 0.4))
        path.addLine(to: CGPoint(x: size * 0.8, y: topY))
        path.addLine(to: CGPoint(x: size, y: baseY))
        path.addLine(to: CGPoint(x: size, y: size))
        path.addLine(to: CGPoint(x: 0, y: size))
        path.close()
        
        context.setFillColor(color.cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return SKTexture(image: image ?? UIImage())
    }
    
    // MARK: - Cleanup
    
    /// Clear all cached textures to free memory
    func clearCache() {
        atlases.removeAll()
        preloadedTextures.removeAll()
    }
}
