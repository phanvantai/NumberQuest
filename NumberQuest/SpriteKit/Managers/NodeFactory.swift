//
//  NodeFactory.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 21/6/25.
//

import SpriteKit
import SwiftUI

/// Factory class for creating consistent, reusable UI components
/// Centralizes the creation of common game elements with proper styling
class NodeFactory {
    
    // MARK: - Singleton
    static let shared = NodeFactory()
    private init() {}
    
    // MARK: - Button Creation
    
    /// Create a standard game button with NumberQuest styling
    func createGameButton(
        text: String,
        style: ButtonStyle = .primary,
        size: ButtonSize = .medium,
        action: @escaping () -> Void
    ) -> GameButtonNode {
        
        let button = GameButtonNode(text: text, style: style, size: size, action: action)
        return button
    }
    
    /// Create a circular icon button
    func createIconButton(
        iconName: String,
        style: ButtonStyle = .secondary,
        size: CGSize = CGSize(width: 60, height: 60),
        action: @escaping () -> Void
    ) -> IconButtonNode {
        
        let button = IconButtonNode(iconName: iconName, style: style, size: size, action: action)
        return button
    }
    
    // MARK: - Card Creation
    
    /// Create an info card with consistent styling
    func createInfoCard(
        title: String,
        content: String,
        size: CGSize,
        style: CardStyle = .default
    ) -> InfoCardNode {
        
        let card = InfoCardNode(title: title, content: content, size: size, style: style)
        return card
    }
    
    /// Create a question card for math problems
    func createQuestionCard(
        question: String,
        size: CGSize = CGSize(width: 300, height: 120)
    ) -> QuestionCardNode {
        
        let card = QuestionCardNode(question: question, size: size)
        return card
    }
    
    // MARK: - Progress Elements
    
    /// Create an animated progress bar
    func createProgressBar(
        width: CGFloat = 200,
        height: CGFloat = 20,
        progress: CGFloat = 0.0,
        style: ProgressBarStyle = .default
    ) -> ProgressBarNode {
        
        let progressBar = ProgressBarNode(width: width, height: height, progress: progress, style: style)
        return progressBar
    }
    
    /// Create a score display with animations
    func createScoreDisplay(
        score: Int = 0,
        style: ScoreDisplayStyle = .default
    ) -> ScoreDisplayNode {
        
        let scoreDisplay = ScoreDisplayNode(score: score, style: style)
        return scoreDisplay
    }
    
    /// Create a timer display
    func createTimerDisplay(
        timeRemaining: Int = 60,
        style: TimerStyle = .default
    ) -> TimerNode {
        
        let timer = TimerNode(timeRemaining: timeRemaining, style: style)
        return timer
    }
    
    // MARK: - Character Elements
    
    /// Create an animated character node
    func createCharacterNode(
        character: GameCharacter,
        size: CGSize = CGSize(width: 80, height: 80)
    ) -> CharacterNode {
        
        let characterNode = CharacterNode(character: character, size: size)
        return characterNode
    }
    
    /// Create a speech bubble for character dialogue
    func createSpeechBubble(
        text: String,
        size: CGSize = CGSize(width: 200, height: 80),
        style: SpeechBubbleStyle = .default
    ) -> SpeechBubbleNode {
        
        let speechBubble = SpeechBubbleNode(text: text, size: size, style: style)
        return speechBubble
    }
    
    // MARK: - Background Elements
    
    /// Create animated floating elements for backgrounds
    func createFloatingElements(
        count: Int = 10,
        in rect: CGRect,
        elementTypes: [FloatingElementType] = [.star, .circle, .triangle]
    ) -> [FloatingElementNode] {
        
        var elements: [FloatingElementNode] = []
        
        for _ in 0..<count {
            let elementType = elementTypes.randomElement() ?? .star
            let element = FloatingElementNode(type: elementType)
            
            // Random position within rect
            let x = CGFloat.random(in: rect.minX...rect.maxX)
            let y = CGFloat.random(in: rect.minY...rect.maxY)
            element.position = CGPoint(x: x, y: y)
            
            // Random scale
            let scale = CGFloat.random(in: 0.3...1.0)
            element.setScale(scale)
            
            // Start floating animation
            element.startFloating()
            
            elements.append(element)
        }
        
        return elements
    }
    
    /// Create animated star field background
    func createStarField(
        in rect: CGRect,
        starCount: Int = 50
    ) -> StarFieldNode {
        
        let starField = StarFieldNode(rect: rect, starCount: starCount)
        return starField
    }
    
    /// Create floating geometric shape for background decoration
    func createFloatingGeometry(
        type: GeometryType = .circle,
        size: CGSize,
        color: UIColor
    ) -> SKNode {
        let container = SKNode()
        
        let shape: SKShapeNode
        
        switch type {
        case .circle:
            shape = SKShapeNode(circleOfRadius: min(size.width, size.height) / 2)
        case .square:
            shape = SKShapeNode(rectOf: size)
        case .triangle:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: size.height/2))
            path.addLine(to: CGPoint(x: -size.width/2, y: -size.height/2))
            path.addLine(to: CGPoint(x: size.width/2, y: -size.height/2))
            path.closeSubpath()
            shape = SKShapeNode(path: path)
        case .star:
            shape = createStarShape(size: size)
        case .diamond:
            let path = CGMutablePath()
            path.move(to: CGPoint(x: 0, y: size.height/2))
            path.addLine(to: CGPoint(x: size.width/2, y: 0))
            path.addLine(to: CGPoint(x: 0, y: -size.height/2))
            path.addLine(to: CGPoint(x: -size.width/2, y: 0))
            path.closeSubpath()
            shape = SKShapeNode(path: path)
        case .random:
            let randomType = GeometryType.allCases.randomElement() ?? .circle
            return createFloatingGeometry(type: randomType, size: size, color: color)
        }
        
        shape.fillColor = color
        shape.strokeColor = color.withAlphaComponent(0.5)
        shape.lineWidth = 1
        
        container.addChild(shape)
        return container
    }
    
    /// Create star shape path
    private func createStarShape(size: CGSize) -> SKShapeNode {
        let path = CGMutablePath()
        let radius = min(size.width, size.height) / 2
        let innerRadius = radius * 0.4
        let points = 5
        
        for i in 0..<points * 2 {
            let angle = CGFloat(i) * .pi / CGFloat(points)
            let currentRadius = i % 2 == 0 ? radius : innerRadius
            let x = cos(angle - .pi/2) * currentRadius
            let y = sin(angle - .pi/2) * currentRadius
            
            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }
        path.closeSubpath()
        
        return SKShapeNode(path: path)
    }
    
    // MARK: - Modal Elements
    
    /// Create a popup modal
    func createPopupModal(
        title: String,
        message: String,
        buttons: [PopupButton],
        style: PopupStyle = .default
    ) -> PopupNode {
        
        let popup = PopupNode(title: title, message: message, buttons: buttons, style: style)
        return popup
    }
    
    /// Create a loading indicator
    func createLoadingIndicator(
        size: CGSize = CGSize(width: 60, height: 60),
        style: LoadingStyle = .spinner
    ) -> LoadingIndicatorNode {
        
        let loading = LoadingIndicatorNode(size: size, style: style)
        return loading
    }
}

// MARK: - Style Enums

enum ButtonStyle {
    case primary
    case secondary
    case success
    case warning
    case danger
    case transparent
    
    var backgroundColor: UIColor {
        switch self {
        case .primary: return .nqBlue
        case .secondary: return .nqPurple
        case .success: return .nqGreen
        case .warning: return .nqOrange
        case .danger: return .nqCoral
        case .transparent: return .clear
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .transparent: return .white
        default: return .white
        }
    }
}

enum ButtonSize {
    case small
    case medium
    case large
    case extraLarge
    
    var size: CGSize {
        switch self {
        case .small: return CGSize(width: 120, height: 40)
        case .medium: return CGSize(width: 160, height: 50)
        case .large: return CGSize(width: 200, height: 60)
        case .extraLarge: return CGSize(width: 250, height: 70)
        }
    }
    
    var fontSize: CGFloat {
        switch self {
        case .small: return 16
        case .medium: return 18
        case .large: return 20
        case .extraLarge: return 24
        }
    }
}

enum CardStyle {
    case `default`
    case highlighted
    case muted
    case success
    case warning
    case error
}

enum ProgressBarStyle {
    case `default`
    case rainbow
    case gradient
}

enum ScoreDisplayStyle {
    case `default`
    case compact
    case detailed
}

enum TimerStyle {
    case `default`
    case urgent
    case calm
}

enum SpeechBubbleStyle {
    case `default`
    case thought
    case exclamation
}

enum FloatingElementType {
    case star
    case circle
    case triangle
    case square
    case heart
    case diamond
}

enum PopupStyle {
    case `default`
    case success
    case warning
    case error
    case info
}

enum LoadingStyle {
    case spinner
    case dots
    case pulse
}

// MARK: - Popup Button Configuration

struct PopupButton {
    let title: String
    let style: ButtonStyle
    let action: () -> Void
    
    init(title: String, style: ButtonStyle = .primary, action: @escaping () -> Void) {
        self.title = title
        self.style = style
        self.action = action
    }
}

// MARK: - Geometry Types

enum GeometryType: CaseIterable {
    case circle
    case square
    case triangle
    case star
    case diamond
    case random
}
