//
//  CoordinateSystem.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 21/6/25.
//

import SpriteKit
import UIKit

/// Coordinate system helpers for responsive design across different devices
/// Provides consistent positioning and scaling for iPhone and iPad
struct CoordinateSystem {
    
    // MARK: - Device Information
    
    let sceneSize: CGSize
    let safeAreaInsets: UIEdgeInsets
    let deviceType: DeviceType
    
    init(sceneSize: CGSize, safeAreaInsets: UIEdgeInsets = .zero) {
        self.sceneSize = sceneSize
        self.safeAreaInsets = safeAreaInsets
        self.deviceType = Self.determineDeviceType(for: sceneSize)
    }
    
    private static func determineDeviceType(for size: CGSize) -> DeviceType {
        let minDimension = min(size.width, size.height)
        let maxDimension = max(size.width, size.height)
        
        // iPad detection
        if minDimension >= 768 {
            return .iPad
        }
        // iPhone detection based on common sizes
        else if maxDimension >= 926 { // iPhone 14 Pro Max and similar
            return .iPhoneProMax
        }
        else if maxDimension >= 844 { // iPhone 14 Pro and similar
            return .iPhonePro
        }
        else if maxDimension >= 736 { // iPhone 8 Plus and similar
            return .iPhonePlus
        }
        else {
            return .iPhoneStandard
        }
    }
    
    // MARK: - Scale Factors
    
    /// Get scale factor for text based on device
    var textScaleFactor: CGFloat {
        switch deviceType {
        case .iPad: return 1.3
        case .iPhoneProMax: return 1.1
        case .iPhonePro: return 1.0
        case .iPhonePlus: return 0.95
        case .iPhoneStandard: return 0.85
        }
    }
    
    /// Get scale factor for UI elements
    var uiScaleFactor: CGFloat {
        switch deviceType {
        case .iPad: return 1.2
        case .iPhoneProMax: return 1.05
        case .iPhonePro: return 1.0
        case .iPhonePlus: return 0.95
        case .iPhoneStandard: return 0.9
        }
    }
    
    /// Get padding scale factor
    var paddingScaleFactor: CGFloat {
        switch deviceType {
        case .iPad: return 1.5
        case .iPhoneProMax: return 1.2
        case .iPhonePro: return 1.0
        case .iPhonePlus: return 0.9
        case .iPhoneStandard: return 0.8
        }
    }
    
    // MARK: - Position Helpers
    
    /// Convert relative position (0-1) to absolute scene coordinates
    func absolutePosition(relativeX: CGFloat, relativeY: CGFloat) -> CGPoint {
        let x = (relativeX - 0.5) * sceneSize.width
        let y = (relativeY - 0.5) * sceneSize.height
        return CGPoint(x: x, y: y)
    }
    
    /// Get position with safe area considerations
    func safePosition(relativeX: CGFloat, relativeY: CGFloat) -> CGPoint {
        var position = absolutePosition(relativeX: relativeX, relativeY: relativeY)
        
        // Adjust for safe area
        let safeWidth = sceneSize.width - safeAreaInsets.left - safeAreaInsets.right
        let safeHeight = sceneSize.height - safeAreaInsets.top - safeAreaInsets.bottom
        
        // Apply safe area offsets
        position.x += (safeAreaInsets.left - safeAreaInsets.right) / 2
        position.y += (safeAreaInsets.bottom - safeAreaInsets.top) / 2
        
        return position
    }
    
    /// Get position relative to screen edges with padding
    func edgePosition(_ edge: ScreenEdge, padding: CGFloat = 20) -> CGPoint {
        let scaledPadding = padding * paddingScaleFactor
        
        switch edge {
        case .top:
            return CGPoint(x: 0, y: sceneSize.height/2 - scaledPadding - safeAreaInsets.top)
        case .bottom:
            return CGPoint(x: 0, y: -sceneSize.height/2 + scaledPadding + safeAreaInsets.bottom)
        case .left:
            return CGPoint(x: -sceneSize.width/2 + scaledPadding + safeAreaInsets.left, y: 0)
        case .right:
            return CGPoint(x: sceneSize.width/2 - scaledPadding - safeAreaInsets.right, y: 0)
        case .topLeft:
            return CGPoint(
                x: -sceneSize.width/2 + scaledPadding + safeAreaInsets.left,
                y: sceneSize.height/2 - scaledPadding - safeAreaInsets.top
            )
        case .topRight:
            return CGPoint(
                x: sceneSize.width/2 - scaledPadding - safeAreaInsets.right,
                y: sceneSize.height/2 - scaledPadding - safeAreaInsets.top
            )
        case .bottomLeft:
            return CGPoint(
                x: -sceneSize.width/2 + scaledPadding + safeAreaInsets.left,
                y: -sceneSize.height/2 + scaledPadding + safeAreaInsets.bottom
            )
        case .bottomRight:
            return CGPoint(
                x: sceneSize.width/2 - scaledPadding - safeAreaInsets.right,
                y: -sceneSize.height/2 + scaledPadding + safeAreaInsets.bottom
            )
        }
    }
    
    // MARK: - Layout Helpers
    
    /// Get recommended button size for device
    func buttonSize(for size: ButtonSize) -> CGSize {
        let baseSize = size.size
        let scaleFactor = uiScaleFactor
        return CGSize(
            width: baseSize.width * scaleFactor,
            height: baseSize.height * scaleFactor
        )
    }
    
    /// Get font size scaled for device
    func fontSize(base: CGFloat) -> CGFloat {
        return base * textScaleFactor
    }
    
    /// Get spacing value scaled for device
    func spacing(_ base: CGFloat) -> CGFloat {
        return base * paddingScaleFactor
    }
    
    /// Calculate grid layout positions
    func gridPositions(
        columns: Int,
        rows: Int,
        itemSize: CGSize,
        spacing: CGFloat = 10,
        centerOffset: CGPoint = .zero
    ) -> [[CGPoint]] {
        
        let scaledSpacing = self.spacing(spacing)
        let scaledItemSize = CGSize(
            width: itemSize.width * uiScaleFactor,
            height: itemSize.height * uiScaleFactor
        )
        
        let totalWidth = CGFloat(columns) * scaledItemSize.width + CGFloat(columns - 1) * scaledSpacing
        let totalHeight = CGFloat(rows) * scaledItemSize.height + CGFloat(rows - 1) * scaledSpacing
        
        let startX = -totalWidth / 2 + scaledItemSize.width / 2 + centerOffset.x
        let startY = totalHeight / 2 - scaledItemSize.height / 2 + centerOffset.y
        
        var positions: [[CGPoint]] = []
        
        for row in 0..<rows {
            var rowPositions: [CGPoint] = []
            for col in 0..<columns {
                let x = startX + CGFloat(col) * (scaledItemSize.width + scaledSpacing)
                let y = startY - CGFloat(row) * (scaledItemSize.height + scaledSpacing)
                rowPositions.append(CGPoint(x: x, y: y))
            }
            positions.append(rowPositions)
        }
        
        return positions
    }
    
    /// Get safe content area (excluding safe area insets)
    var safeContentArea: CGRect {
        return CGRect(
            x: -sceneSize.width/2 + safeAreaInsets.left,
            y: -sceneSize.height/2 + safeAreaInsets.bottom,
            width: sceneSize.width - safeAreaInsets.left - safeAreaInsets.right,
            height: sceneSize.height - safeAreaInsets.top - safeAreaInsets.bottom
        )
    }
    
    /// Check if position is within safe content area
    func isInSafeArea(_ position: CGPoint) -> Bool {
        return safeContentArea.contains(position)
    }
    
    // MARK: - Animation Helpers
    
    /// Get recommended animation duration scaled for device performance
    func animationDuration(_ baseDuration: TimeInterval) -> TimeInterval {
        switch deviceType {
        case .iPad:
            return baseDuration * 1.1 // Slightly longer for better visibility
        case .iPhoneStandard:
            return baseDuration * 0.9 // Slightly faster for performance
        default:
            return baseDuration
        }
    }
    
    /// Get particle count recommendation for device
    func particleCount(_ baseCount: Int) -> Int {
        switch deviceType {
        case .iPad:
            return Int(CGFloat(baseCount) * 1.5)
        case .iPhoneProMax, .iPhonePro:
            return baseCount
        case .iPhonePlus:
            return Int(CGFloat(baseCount) * 0.8)
        case .iPhoneStandard:
            return Int(CGFloat(baseCount) * 0.6)
        }
    }
}

// MARK: - Supporting Types

// MARK: - Supporting Types

enum DeviceType {
    case iPad
    case iPhoneProMax
    case iPhonePro
    case iPhonePlus
    case iPhoneStandard
}

enum ScreenEdge {
    case top, bottom, left, right
    case topLeft, topRight, bottomLeft, bottomRight
}

// MARK: - Global Coordinate Helper

/// Global coordinate system instance for easy access
class GlobalCoordinateSystem {
    static var current: CoordinateSystem?
    
    static func setup(sceneSize: CGSize, safeAreaInsets: UIEdgeInsets = .zero) {
        current = CoordinateSystem(sceneSize: sceneSize, safeAreaInsets: safeAreaInsets)
    }
    
    static func update(sceneSize: CGSize) {
        guard let current = current else { return }
        self.current = CoordinateSystem(sceneSize: sceneSize, safeAreaInsets: current.safeAreaInsets)
    }
}

// MARK: - Convenience Extensions

extension SKNode {
    
    /// Position node using relative coordinates (0-1)
    func setRelativePosition(x: CGFloat, y: CGFloat) {
        guard let coordinator = GlobalCoordinateSystem.current else { return }
        position = coordinator.absolutePosition(relativeX: x, relativeY: y)
    }
    
    /// Position node at screen edge with padding
    func setEdgePosition(_ edge: ScreenEdge, padding: CGFloat = 20) {
        guard let coordinator = GlobalCoordinateSystem.current else { return }
        position = coordinator.edgePosition(edge, padding: padding)
    }
    
    /// Scale node for current device
    func scaleForDevice(_ baseScale: CGFloat = 1.0) {
        guard let coordinator = GlobalCoordinateSystem.current else { return }
        setScale(baseScale * coordinator.uiScaleFactor)
    }
}
