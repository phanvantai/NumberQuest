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
    
    /// Device types for better layout decisions
    enum DeviceType {
        case iPhoneSE      // Small iPhone (4.7" and smaller)
        case iPhoneStandard // Standard iPhone (6.1" - 6.7")
        case iPhoneMax     // Large iPhone (6.7"+)
        case iPadMini      // iPad Mini
        case iPadStandard  // Standard iPad
        case iPadPro       // iPad Pro
        
        static var current: DeviceType {
            let idiom = UIDevice.current.userInterfaceIdiom
            let screenSize = UIScreen.main.bounds.size
            let screenDiagonal = sqrt(pow(screenSize.width, 2) + pow(screenSize.height, 2))
            
            switch idiom {
            case .phone:
                if screenDiagonal < 570 { return .iPhoneSE }
                else if screenDiagonal < 850 { return .iPhoneStandard }
                else { return .iPhoneMax }
            case .pad:
                if screenDiagonal < 1100 { return .iPadMini }
                else if screenDiagonal < 1400 { return .iPadStandard }
                else { return .iPadPro }
            default:
                return .iPhoneStandard
            }
        }
    }
    
    /// Detect if the current device is an iPad
    static var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    /// Get current device type
    static var deviceType: DeviceType {
        return DeviceType.current
    }
    
    /// Detect if the current device is in landscape orientation
    static var isLandscape: Bool {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.interfaceOrientation.isLandscape
        }
        return false
    }
    
    /// Get current interface orientation
    static var interfaceOrientation: UIInterfaceOrientation {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.interfaceOrientation
        }
        return .portrait
    }
    
    // MARK: - Screen Dimensions
    
    /// Get the main screen size
    static var screenSize: CGSize {
        return UIScreen.main.bounds.size
    }
    
    /// Get screen size adjusted for current orientation
    static var orientedScreenSize: CGSize {
        let size = screenSize
        return isLandscape ? CGSize(width: max(size.width, size.height), height: min(size.width, size.height)) 
                          : CGSize(width: min(size.width, size.height), height: max(size.width, size.height))
    }
    
    /// Get safe area insets for current window
    static var safeAreaInsets: UIEdgeInsets {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.safeAreaInsets
        }
        return .zero
    }
    
    /// Get safe area insets adjusted for landscape if needed
    static var orientedSafeAreaInsets: UIEdgeInsets {
        let insets = safeAreaInsets
        if isLandscape {
            return UIEdgeInsets(
                top: insets.left,
                left: insets.bottom, 
                bottom: insets.right,
                right: insets.top
            )
        }
        return insets
    }
    
    // MARK: - Responsive Sizing
    
    /// Device-specific scale factors for responsive design
    private static var deviceScaleFactor: CGFloat {
        switch deviceType {
        case .iPhoneSE: return 0.85
        case .iPhoneStandard: return 1.0
        case .iPhoneMax: return 1.1
        case .iPadMini: return 1.2
        case .iPadStandard: return 1.4
        case .iPadPro: return 1.6
        }
    }
    
    /// Calculate responsive font size based on device and screen size
    static func responsiveFontSize(base: CGFloat) -> CGFloat {
        return base * deviceScaleFactor
    }
    
    /// Calculate responsive spacing based on device
    static func responsiveSpacing(base: CGFloat) -> CGFloat {
        return base * deviceScaleFactor
    }
    
    /// Calculate responsive size for UI elements
    static func responsiveSize(width: CGFloat, height: CGFloat) -> CGSize {
        let factor = deviceScaleFactor
        return CGSize(width: width * factor, height: height * factor)
    }
    
    /// Get responsive size based on device type and orientation
    static func adaptiveSize(
        phone: CGSize,
        pad: CGSize,
        orientationAdjustment: Bool = true
    ) -> CGSize {
        let baseSize = isIPad ? pad : phone
        let scaleFactor = deviceScaleFactor
        let orientationFactor = (orientationAdjustment && isLandscape) ? 0.9 : 1.0
        
        return CGSize(
            width: baseSize.width * scaleFactor * orientationFactor,
            height: baseSize.height * scaleFactor * orientationFactor
        )
    }
    
    /// Get responsive spacing based on device and orientation
    static func adaptiveSpacing(
        phone: CGFloat,
        pad: CGFloat,
        orientationAdjustment: Bool = true
    ) -> CGFloat {
        let baseSpacing = isIPad ? pad : phone
        let scaleFactor = deviceScaleFactor
        let orientationFactor = (orientationAdjustment && isLandscape) ? 0.8 : 1.0
        
        return baseSpacing * scaleFactor * orientationFactor
    }
    
    // MARK: - Position Helpers
    
    /// Convert relative position (0.0 to 1.0) to absolute position in scene
    static func relativePosition(
        x: CGFloat,
        y: CGFloat,
        in scene: SKScene,
        safeArea: UIEdgeInsets = .zero
    ) -> CGPoint {
        let safeAreaToUse = safeArea == .zero ? orientedSafeAreaInsets : safeArea
        let safeWidth = scene.size.width - safeAreaToUse.left - safeAreaToUse.right
        let safeHeight = scene.size.height - safeAreaToUse.top - safeAreaToUse.bottom
        
        return CGPoint(
            x: x * safeWidth + safeAreaToUse.left,
            y: (1.0 - y) * safeHeight + safeAreaToUse.bottom
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
    
    /// Get position that's always visible regardless of orientation
    static func visiblePosition(
        x: CGFloat,
        y: CGFloat,
        in scene: SKScene,
        marginPercent: CGFloat = 0.05
    ) -> CGPoint {
        let safeArea = orientedSafeAreaInsets
        let marginX = scene.size.width * marginPercent
        let marginY = scene.size.height * marginPercent
        
        let adjustedSafeArea = UIEdgeInsets(
            top: max(safeArea.top, marginY),
            left: max(safeArea.left, marginX),
            bottom: max(safeArea.bottom, marginY),
            right: max(safeArea.right, marginX)
        )
        
        return relativePosition(x: x, y: y, in: scene, safeArea: adjustedSafeArea)
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
    
    /// Calculate adaptive grid positions that adjust for device and orientation
    static func adaptiveGridPositions(
        count: Int,
        preferredColumns: Int,
        in scene: SKScene,
        itemSize: CGSize,
        spacing: CGFloat? = nil,
        safeArea: UIEdgeInsets = .zero
    ) -> [CGPoint] {
        let safeAreaToUse = safeArea == .zero ? orientedSafeAreaInsets : safeArea
        let availableWidth = scene.size.width - safeAreaToUse.left - safeAreaToUse.right
        let availableHeight = scene.size.height - safeAreaToUse.top - safeAreaToUse.bottom
        
        // Adjust columns based on available space
        let maxColumns = max(1, Int(availableWidth / (itemSize.width + (spacing ?? adaptiveSpacing(phone: 20, pad: 30)))))
        let actualColumns = min(preferredColumns, maxColumns)
        
        let adaptiveSpacing = spacing ?? CoordinateSystem.adaptiveSpacing(phone: 20, pad: 30)
        
        return gridPositions(
            count: count,
            columns: actualColumns,
            spacing: adaptiveSpacing,
            containerSize: CGSize(width: availableWidth, height: availableHeight),
            itemSize: itemSize
        ).map { position in
            CGPoint(
                x: position.x + safeAreaToUse.left,
                y: position.y + safeAreaToUse.bottom
            )
        }
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
    
    /// Calculate flexible layout positions that adapt to content and screen size
    static func flexibleLayoutPositions(
        count: Int,
        in scene: SKScene,
        preferredItemSize: CGSize,
        minimumSpacing: CGFloat = 10,
        safeArea: UIEdgeInsets = .zero
    ) -> (positions: [CGPoint], actualItemSize: CGSize, actualSpacing: CGFloat) {
        let safeAreaToUse = safeArea == .zero ? orientedSafeAreaInsets : safeArea
        let availableWidth = scene.size.width - safeAreaToUse.left - safeAreaToUse.right
        let availableHeight = scene.size.height - safeAreaToUse.top - safeAreaToUse.bottom
        
        // Calculate optimal layout
        var bestLayout: (columns: Int, rows: Int, itemSize: CGSize, spacing: CGFloat)?
        var bestScore = CGFloat.infinity
        
        // Try different column configurations
        for columns in 1...min(count, 6) {
            let rows = Int(ceil(Double(count) / Double(columns)))
            
            // Calculate required spacing
            let spacingX = max(minimumSpacing, (availableWidth - CGFloat(columns) * preferredItemSize.width) / CGFloat(columns + 1))
            let spacingY = max(minimumSpacing, (availableHeight - CGFloat(rows) * preferredItemSize.height) / CGFloat(rows + 1))
            
            // Check if layout fits
            let totalWidth = CGFloat(columns) * preferredItemSize.width + CGFloat(columns + 1) * spacingX
            let totalHeight = CGFloat(rows) * preferredItemSize.height + CGFloat(rows + 1) * spacingY
            
            if totalWidth <= availableWidth && totalHeight <= availableHeight {
                // Calculate score (prefer more balanced layouts)
                let aspectRatio = totalWidth / totalHeight
                let targetAspectRatio = availableWidth / availableHeight
                let score = abs(aspectRatio - targetAspectRatio)
                
                if score < bestScore {
                    bestScore = score
                    bestLayout = (columns, rows, preferredItemSize, min(spacingX, spacingY))
                }
            }
        }
        
        // Use best layout or fallback
        let layout = bestLayout ?? (1, count, CGSize(width: availableWidth * 0.8, height: preferredItemSize.height), minimumSpacing)
        
        // Generate positions
        let positions = gridPositions(
            count: count,
            columns: layout.columns,
            spacing: layout.spacing,
            containerSize: CGSize(width: availableWidth, height: availableHeight),
            itemSize: layout.itemSize
        ).map { position in
            CGPoint(
                x: position.x + safeAreaToUse.left,
                y: position.y + safeAreaToUse.bottom
            )
        }
        
        return (positions, layout.itemSize, layout.spacing)
    }
    
    // MARK: - Animation Helpers
    
    /// Create smooth easing curves for animations
    static func easeInOut(duration: TimeInterval) -> SKAction {
        let action = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let progress = elapsedTime / duration
            let _ = 0.5 * (1 - cos(progress * .pi))
            // Apply eased progress to animation - this is typically used in combination with other actions
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
    
    /// Create adaptive animation duration based on device performance
    static func adaptiveAnimationDuration(base: TimeInterval) -> TimeInterval {
        // Faster animations on older/slower devices to maintain responsiveness
        switch deviceType {
        case .iPhoneSE: return base * 0.8
        case .iPhoneStandard: return base
        case .iPhoneMax: return base
        case .iPadMini: return base * 0.9
        case .iPadStandard: return base
        case .iPadPro: return base * 1.1 // Slightly longer for better visual effect on large screens
        }
    }
    
    // MARK: - Orientation Change Handling
    
    /// Notification name for orientation changes
    static let orientationDidChangeNotification = Notification.Name("CoordinateSystemOrientationDidChange")
    
    /// Setup orientation change monitoring
    static func startOrientationMonitoring() {
        NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            NotificationCenter.default.post(name: orientationDidChangeNotification, object: nil)
        }
    }
    
    /// Stop orientation change monitoring
    static func stopOrientationMonitoring() {
        NotificationCenter.default.removeObserver(
            self,
            name: UIDevice.orientationDidChangeNotification,
            object: nil
        )
    }
    
    /// Protocol for scenes that want to handle orientation changes
    protocol OrientationAdaptive {
        func handleOrientationChange()
    }
    
    /// Helper to setup orientation change handling for a scene
    static func setupOrientationHandling(for scene: SKScene & OrientationAdaptive) {
        NotificationCenter.default.addObserver(
            forName: orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { _ in
            // Add a small delay to ensure the orientation change is complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                scene.handleOrientationChange()
            }
        }
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
    
    // MARK: - Adaptive Spacing
    static var adaptiveSmallSpacing: CGFloat {
        CoordinateSystem.adaptiveSpacing(phone: smallSpacing, pad: smallSpacing * 1.5)
    }
    
    static var adaptiveMediumSpacing: CGFloat {
        CoordinateSystem.adaptiveSpacing(phone: mediumSpacing, pad: mediumSpacing * 1.5)
    }
    
    static var adaptiveLargeSpacing: CGFloat {
        CoordinateSystem.adaptiveSpacing(phone: largeSpacing, pad: largeSpacing * 1.5)
    }
    
    static var adaptiveExtraLargeSpacing: CGFloat {
        CoordinateSystem.adaptiveSpacing(phone: extraLargeSpacing, pad: extraLargeSpacing * 1.5)
    }
    
    // MARK: - Corner Radius
    static let smallCornerRadius: CGFloat = 8
    static let mediumCornerRadius: CGFloat = 12
    static let largeCornerRadius: CGFloat = 16
    static let extraLargeCornerRadius: CGFloat = 20
    
    // MARK: - Adaptive Corner Radius
    static var adaptiveSmallCornerRadius: CGFloat {
        CoordinateSystem.responsiveSpacing(base: smallCornerRadius)
    }
    
    static var adaptiveMediumCornerRadius: CGFloat {
        CoordinateSystem.responsiveSpacing(base: mediumCornerRadius)
    }
    
    static var adaptiveLargeCornerRadius: CGFloat {
        CoordinateSystem.responsiveSpacing(base: largeCornerRadius)
    }
    
    // MARK: - Button Sizes
    static let smallButtonSize = CGSize(width: 120, height: 44)
    static let mediumButtonSize = CGSize(width: 160, height: 50)
    static let largeButtonSize = CGSize(width: 200, height: 56)
    
    // MARK: - Adaptive Button Sizes
    static var adaptiveSmallButtonSize: CGSize {
        CoordinateSystem.adaptiveSize(
            phone: smallButtonSize,
            pad: CGSize(width: 150, height: 54)
        )
    }
    
    static var adaptiveMediumButtonSize: CGSize {
        CoordinateSystem.adaptiveSize(
            phone: mediumButtonSize,
            pad: CGSize(width: 200, height: 60)
        )
    }
    
    static var adaptiveLargeButtonSize: CGSize {
        CoordinateSystem.adaptiveSize(
            phone: largeButtonSize,
            pad: CGSize(width: 250, height: 66)
        )
    }
    
    // MARK: - Card Sizes
    static let smallCardSize = CGSize(width: 280, height: 200)
    static let mediumCardSize = CGSize(width: 320, height: 240)
    static let largeCardSize = CGSize(width: 360, height: 280)
    
    // MARK: - Adaptive Card Sizes
    static var adaptiveSmallCardSize: CGSize {
        CoordinateSystem.adaptiveSize(
            phone: smallCardSize,
            pad: CGSize(width: 350, height: 250)
        )
    }
    
    static var adaptiveMediumCardSize: CGSize {
        CoordinateSystem.adaptiveSize(
            phone: mediumCardSize,
            pad: CGSize(width: 400, height: 300)
        )
    }
    
    static var adaptiveLargeCardSize: CGSize {
        CoordinateSystem.adaptiveSize(
            phone: largeCardSize,
            pad: CGSize(width: 450, height: 350)
        )
    }
    
    // MARK: - Animation Durations
    static let shortAnimation: TimeInterval = 0.2
    static let mediumAnimation: TimeInterval = 0.3
    static let longAnimation: TimeInterval = 0.5
    
    // MARK: - Adaptive Animation Durations
    static var adaptiveShortAnimation: TimeInterval {
        CoordinateSystem.adaptiveAnimationDuration(base: shortAnimation)
    }
    
    static var adaptiveMediumAnimation: TimeInterval {
        CoordinateSystem.adaptiveAnimationDuration(base: mediumAnimation)
    }
    
    static var adaptiveLongAnimation: TimeInterval {
        CoordinateSystem.adaptiveAnimationDuration(base: longAnimation)
    }
    
    // MARK: - Z-Positions
    static let backgroundZ: CGFloat = -100
    static let uiBackgroundZ: CGFloat = 0
    static let uiElementZ: CGFloat = 10
    static let overlayZ: CGFloat = 50
    static let popupZ: CGFloat = 100
    
    // MARK: - Safe Area Margins
    static let minimumMargin: CGFloat = 20
    static let recommendedMargin: CGFloat = 30
    
    static var adaptiveMinimumMargin: CGFloat {
        CoordinateSystem.adaptiveSpacing(phone: minimumMargin, pad: minimumMargin * 1.2)
    }
    
    static var adaptiveRecommendedMargin: CGFloat {
        CoordinateSystem.adaptiveSpacing(phone: recommendedMargin, pad: recommendedMargin * 1.2)
    }
}
