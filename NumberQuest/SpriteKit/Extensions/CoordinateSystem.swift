//
//  CoordinateSystem.swift
//  NumberQuest
//
//  Created by TaiPV on 24/6/25.
//

import SpriteKit
import SwiftUI

/// Utility class for responsive design and coordinate system management in SpriteKit
/// Helps bridge the gap between SwiftUI's relative positioning and SpriteKit's absolute positioning
struct CoordinateSystem {
    
    // MARK: - Device Information
    
    /// Detect if the current device is an iPad
    static var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// Detect if the current device is in landscape orientation
    static var isLandscape: Bool {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.interfaceOrientation.isLandscape
        }
        return false
    }
    
    // MARK: - Screen Dimensions
    
    /// Get the main screen size
    static var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    /// Get safe area insets
    static var safeAreaInsets: UIEdgeInsets {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.safeAreaInsets
        }
        return .zero
    }
    
    // MARK: - Responsive Sizing
    
    /// Calculate responsive font size based on device and screen size
    static func responsiveFontSize(base: CGFloat) -> CGFloat {
        let screenWidth = screenSize.width
        let scaleFactor: CGFloat
        
        if isIPad {
            scaleFactor = screenWidth / 834.0 // iPad reference width
        } else {
            scaleFactor = screenWidth / 390.0 // iPhone reference width
        }
        
        return base * scaleFactor
    }
    
    /// Calculate responsive spacing based on device
    static func responsiveSpacing(base: CGFloat) -> CGFloat {
        return isIPad ? base * 1.5 : base
    }
    
    /// Calculate responsive size for UI elements
    static func responsiveSize(width: CGFloat, height: CGFloat) -> CGSize {
        let scaleFactor = isIPad ? 1.3 : 1.0
        return CGSize(width: width * scaleFactor, height: height * scaleFactor)
    }
    
    // MARK: - Position Helpers
    
    /// Convert relative position (0.0 to 1.0) to absolute position in scene
    static func relativePosition(
        x: CGFloat,
        y: CGFloat,
        in scene: SKScene,
        safeArea: UIEdgeInsets = .zero
    ) -> CGPoint {
        let safeWidth = scene.size.width - safeArea.left - safeArea.right
        let safeHeight = scene.size.height - safeArea.top - safeArea.bottom
        
        return CGPoint(
            x: x * safeWidth + safeArea.left,
            y: (1.0 - y) * safeHeight + safeArea.bottom
        )
    }
    
    /// Get center position of scene accounting for safe areas
    static func safeCenter(in scene: SKScene, safeArea: UIEdgeInsets = .zero) -> CGPoint {
        return relativePosition(x: 0.5, y: 0.5, in: scene, safeArea: safeArea)
    }
    
    /// Get top-left position of safe area
    static func safeTopLeft(in scene: SKScene, safeArea: UIEdgeInsets = .zero) -> CGPoint {
        return relativePosition(x: 0.0, y: 0.0, in: scene, safeArea: safeArea)
    }
    
    /// Get top-right position of safe area
    static func safeTopRight(in scene: SKScene, safeArea: UIEdgeInsets = .zero) -> CGPoint {
        return relativePosition(x: 1.0, y: 0.0, in: scene, safeArea: safeArea)
    }
    
    /// Get bottom-left position of safe area
    static func safeBottomLeft(in scene: SKScene, safeArea: UIEdgeInsets = .zero) -> CGPoint {
        return relativePosition(x: 0.0, y: 1.0, in: scene, safeArea: safeArea)
    }
    
    /// Get bottom-right position of safe area
    static func safeBottomRight(in scene: SKScene, safeArea: UIEdgeInsets = .zero) -> CGPoint {
        return relativePosition(x: 1.0, y: 1.0, in: scene, safeArea: safeArea)
    }
    
    // MARK: - Layout Helpers
    
    /// Calculate grid positions for a given number of items
    static func gridPositions(
        count: Int,
        columns: Int,
        spacing: CGFloat,
        containerSize: CGSize,
        itemSize: CGSize
    ) -> [CGPoint] {
        
        let rows = Int(ceil(Double(count) / Double(columns)))
        var positions: [CGPoint] = []
        
        let totalWidth = CGFloat(columns) * itemSize.width + CGFloat(columns - 1) * spacing
        let totalHeight = CGFloat(rows) * itemSize.height + CGFloat(rows - 1) * spacing
        
        let startX = (containerSize.width - totalWidth) / 2 + itemSize.width / 2
        let startY = (containerSize.height + totalHeight) / 2 - itemSize.height / 2
        
        for i in 0..<count {
            let row = i / columns
            let col = i % columns
            
            let x = startX + CGFloat(col) * (itemSize.width + spacing)
            let y = startY - CGFloat(row) * (itemSize.height + spacing)
            
            positions.append(CGPoint(x: x, y: y))
        }
        
        return positions
    }
    
    /// Calculate vertical stack positions
    static func verticalStackPositions(
        count: Int,
        spacing: CGFloat,
        containerSize: CGSize,
        itemHeight: CGFloat
    ) -> [CGPoint] {
        
        let totalHeight = CGFloat(count) * itemHeight + CGFloat(count - 1) * spacing
        let startY = (containerSize.height + totalHeight) / 2 - itemHeight / 2
        let centerX = containerSize.width / 2
        
        var positions: [CGPoint] = []
        
        for i in 0..<count {
            let y = startY - CGFloat(i) * (itemHeight + spacing)
            positions.append(CGPoint(x: centerX, y: y))
        }
        
        return positions
    }
    
    /// Calculate horizontal stack positions
    static func horizontalStackPositions(
        count: Int,
        spacing: CGFloat,
        containerSize: CGSize,
        itemWidth: CGFloat
    ) -> [CGPoint] {
        
        let totalWidth = CGFloat(count) * itemWidth + CGFloat(count - 1) * spacing
        let startX = (containerSize.width - totalWidth) / 2 + itemWidth / 2
        let centerY = containerSize.height / 2
        
        var positions: [CGPoint] = []
        
        for i in 0..<count {
            let x = startX + CGFloat(i) * (itemWidth + spacing)
            positions.append(CGPoint(x: x, y: centerY))
        }
        
        return positions
    }
    
    // MARK: - Animation Helpers
    
    /// Create smooth easing curves for animations
    static func easeInOut(duration: TimeInterval) -> SKAction {
        let action = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let progress = elapsedTime / duration
            let easedProgress = 0.5 * (1 - cos(progress * .pi))
            // Apply eased progress to animation
        }
        return action
    }
    
    /// Create spring-like bounce effect
    static func springBounce(scale: CGFloat = 1.2, duration: TimeInterval = 0.6) -> SKAction {
        let scaleUp = SKAction.scale(to: scale, duration: duration * 0.3)
        scaleUp.timingMode = .easeOut
        
        let scaleDown = SKAction.scale(to: 1.0, duration: duration * 0.7)
        scaleDown.timingMode = .easeInEaseOut
        
        return SKAction.sequence([scaleUp, scaleDown])
    }
    
    // MARK: - Touch Helpers
    
    /// Check if a touch is within a node's bounds
    static func isTouchInNode(_ touch: UITouch, node: SKNode, in view: SKView) -> Bool {
        let location = touch.location(in: node.parent ?? node)
        return node.contains(location)
    }
    
    /// Convert touch location to scene coordinates
    static func touchLocation(_ touch: UITouch, in scene: SKScene, from view: SKView) -> CGPoint {
        let location = touch.location(in: view)
        return scene.convertPoint(fromView: location)
    }
}

// MARK: - CGPoint Extensions

extension CGPoint {
    
    /// Create a point with relative positioning in a scene
    static func relative(
        x: CGFloat,
        y: CGFloat,
        in scene: SKScene,
        safeArea: UIEdgeInsets = .zero
    ) -> CGPoint {
        return CoordinateSystem.relativePosition(x: x, y: y, in: scene, safeArea: safeArea)
    }
    
    /// Offset a point by relative amounts
    func offsetBy(x: CGFloat, y: CGFloat, in scene: SKScene) -> CGPoint {
        return CGPoint(
            x: self.x + x * scene.size.width,
            y: self.y + y * scene.size.height
        )
    }
    
    /// Calculate distance to another point
    func distance(to point: CGPoint) -> CGFloat {
        let dx = x - point.x
        let dy = y - point.y
        return sqrt(dx * dx + dy * dy)
    }
}

// MARK: - CGSize Extensions

extension CGSize {
    
    /// Create a responsive size based on device type
    static func responsive(width: CGFloat, height: CGFloat) -> CGSize {
        return CoordinateSystem.responsiveSize(width: width, height: height)
    }
    
    /// Scale the size by a factor
    func scaled(by factor: CGFloat) -> CGSize {
        return CGSize(width: width * factor, height: height * factor)
    }
    
    /// Get aspect ratio
    var aspectRatio: CGFloat {
        return width / height
    }
}

// MARK: - Layout Constants

/// Common layout constants for consistent design
struct LayoutConstants {
    
    // MARK: - Spacing
    static let smallSpacing: CGFloat = 8
    static let mediumSpacing: CGFloat = 16
    static let largeSpacing: CGFloat = 24
    static let extraLargeSpacing: CGFloat = 32
    
    // MARK: - Corner Radius
    static let smallCornerRadius: CGFloat = 8
    static let mediumCornerRadius: CGFloat = 12
    static let largeCornerRadius: CGFloat = 16
    static let extraLargeCornerRadius: CGFloat = 20
    
    // MARK: - Button Sizes
    static let smallButtonSize = CGSize(width: 120, height: 44)
    static let mediumButtonSize = CGSize(width: 160, height: 50)
    static let largeButtonSize = CGSize(width: 200, height: 56)
    
    // MARK: - Card Sizes
    static let smallCardSize = CGSize(width: 280, height: 200)
    static let mediumCardSize = CGSize(width: 320, height: 240)
    static let largeCardSize = CGSize(width: 360, height: 280)
    
    // MARK: - Animation Durations
    static let shortAnimation: TimeInterval = 0.2
    static let mediumAnimation: TimeInterval = 0.3
    static let longAnimation: TimeInterval = 0.5
    
    // MARK: - Z-Positions
    static let backgroundZ: CGFloat = -100
    static let uiBackgroundZ: CGFloat = 0
    static let uiElementZ: CGFloat = 10
    static let overlayZ: CGFloat = 50
    static let popupZ: CGFloat = 100
}
