//
//  NodeFactory.swift
//  NumberQuest
//
//  Created by TaiPV on 24/6/25.
//

import SpriteKit
import SwiftUI

/// Factory class for creating reusable SpriteKit nodes with consistent styling
/// Based on the existing TextStyles system from the SwiftUI version
class NodeFactory {
    
    // MARK: - Shared Instance
    
    static let shared = NodeFactory()
    private init() {}
    
    // MARK: - Text Nodes
    
    /// Create a styled label node based on TextStyles
    func createLabel(
        text: String,
        style: TextStyleType,
        color: UIColor = .white
    ) -> SKLabelNode {
        let label = SKLabelNode(text: text)
        
        // Apply font and size based on style
        switch style {
        case .gameTitle:
            label.fontName = "Baloo2-VariableFont_wght"
            label.fontSize = 42
            
        case .title:
            label.fontName = "Baloo2-VariableFont_wght"
            label.fontSize = 28
            
        case .subtitle:
            label.fontName = "Baloo2-VariableFont_wght"
            label.fontSize = 22
            
        case .heading:
            label.fontName = "Baloo2-VariableFont_wght"
            label.fontSize = 18
            
        case .body:
            label.fontName = "Baloo2-VariableFont_wght"
            label.fontSize = 16
            
        case .bodySecondary:
            label.fontName = "Baloo2-VariableFont_wght"
            label.fontSize = 16
            
        case .caption:
            label.fontName = "Baloo2-VariableFont_wght"
            label.fontSize = 14
            
        case .buttonLarge:
            label.fontName = "Baloo2-VariableFont_wght"
            label.fontSize = 24
            
        case .buttonMedium:
            label.fontName = "Baloo2-VariableFont_wght"
            label.fontSize = 18
            
        case .questionText:
            label.fontName = "Baloo2-VariableFont_wght"
            label.fontSize = 36
            
        case .answerText:
            label.fontName = "Baloo2-VariableFont_wght"
            label.fontSize = 28
            
        case .scoreText:
            label.fontName = "Baloo2-VariableFont_wght"
            label.fontSize = 20
        }
        
        label.fontColor = color
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        
        return label
    }
    
    // MARK: - Button Nodes
    
    /// Create a game button with enhanced styling and effects
    func createButton(
        text: String,
        style: GameButtonNode.ButtonStyle = .primary,
        size: GameButtonNode.ButtonSize = .medium,
        icon: String? = nil,
        action: (() -> Void)? = nil
    ) -> GameButtonNode {
        
        return GameButtonNode(
            text: text,
            style: style,
            size: size,
            icon: icon,
            action: action
        )
    }
    
    /// Create a custom sized button
    func createCustomButton(
        text: String,
        style: GameButtonNode.ButtonStyle = .primary,
        customSize: CGSize,
        icon: String? = nil,
        action: (() -> Void)? = nil
    ) -> GameButtonNode {
        
        return GameButtonNode(
            text: text,
            style: style,
            customSize: customSize,
            icon: icon,
            action: action
        )
    }
    
    /// Create an answer button for math questions
    func createAnswerButton(
        answer: String,
        size: CGSize,
        isCorrect: Bool,
        action: @escaping (Bool) -> Void
    ) -> AnswerButtonNode {
        
        let button = AnswerButtonNode(
            size: size,
            answer: answer,
            isCorrect: isCorrect
        )
        
        // Set the callback
        button.onTap = { answerText, isCorrect in
            action(isCorrect)
        }
        
        return button
    }
    
    // MARK: - Card Nodes
    
    /// Create an info card with enhanced styling
    func createInfoCard(
        title: String,
        value: String = "",
        style: InfoCardNode.CardStyle = .stats,
        size: InfoCardNode.CardSize = .medium,
        icon: String? = nil,
        subtitle: String? = nil,
        interactive: Bool = false,
        action: (() -> Void)? = nil
    ) -> InfoCardNode {
        
        let card = InfoCardNode(
            title: title,
            value: value,
            style: style,
            size: size,
            icon: icon,
            subtitle: subtitle,
            interactive: interactive
        )
        
        card.onTap = action
        return card
    }
    
    /// Create a simple card-style container node (legacy method)
    func createCard(
        size: CGSize,
        backgroundColor: UIColor = UIColor.white.withAlphaComponent(0.1),
        cornerRadius: CGFloat = 20,
        shadowColor: UIColor = UIColor.black.withAlphaComponent(0.3)
    ) -> SKSpriteNode {
        
        let card = SKSpriteNode(color: backgroundColor, size: size)
        
        // Add shadow effect
        let shadow = SKSpriteNode(color: shadowColor, size: size)
        shadow.position = CGPoint(x: 0, y: -5)
        shadow.zPosition = card.zPosition - 1
        card.addChild(shadow)
        
        return card
    }
    
    // MARK: - Progress Nodes
    
    /// Create an enhanced progress bar node
    func createProgressBar(
        size: CGSize,
        progress: CGFloat = 0.0,
        style: ProgressBarNode.ProgressStyle = .standard,
        progressColor: ProgressBarNode.ProgressColor = .green,
        backgroundColor: UIColor = UIColor.gray.withAlphaComponent(0.3),
        showPercentage: Bool = false,
        segmentCount: Int = 0
    ) -> ProgressBarNode {
        
        return ProgressBarNode(
            size: size,
            progress: progress,
            style: style,
            progressColor: progressColor,
            backgroundColor: backgroundColor,
            showPercentage: showPercentage,
            segmentCount: segmentCount
        )
    }
    
    /// Create a simple progress bar (legacy method)
    func createSimpleProgressBar(
        size: CGSize,
        progress: CGFloat = 0.0,
        backgroundColor: UIColor = UIColor.gray.withAlphaComponent(0.3),
        progressColor: UIColor = .green
    ) -> ProgressBarNode {
        
        return ProgressBarNode(
            size: size,
            progress: progress,
            style: .standard,
            progressColor: .custom(progressColor),
            backgroundColor: backgroundColor
        )
    }
    
    // MARK: - Popup Nodes
    
    /// Create a popup/modal node
    func createPopup(
        title: String,
        message: String? = nil,
        icon: String? = nil,
        style: PopupNode.PopupStyle = .alert,
        buttons: PopupNode.ButtonConfiguration = .ok,
        screenSize: CGSize = CGSize(width: 400, height: 600)
    ) -> PopupNode {
        
        return PopupNode(
            title: title,
            message: message,
            icon: icon,
            style: style,
            buttons: buttons,
            screenSize: screenSize
        )
    }
    
    /// Create a confirmation popup
    func createConfirmationPopup(
        title: String,
        message: String? = nil,
        screenSize: CGSize = CGSize(width: 400, height: 600)
    ) -> PopupNode {
        
        return PopupNode.confirmation(
            title: title,
            message: message,
            screenSize: screenSize
        )
    }
    
    /// Create an alert popup
    func createAlertPopup(
        title: String,
        message: String? = nil,
        screenSize: CGSize = CGSize(width: 400, height: 600)
    ) -> PopupNode {
        
        return PopupNode.alert(
            title: title,
            message: message,
            screenSize: screenSize
        )
    }
    
    // MARK: - Particle Effects
    
    /// Create celebration particle effect
    func createCelebrationEffect(at position: CGPoint) -> SKEmitterNode? {
        // TODO: Create .sks file for celebration particles
        let emitter = SKEmitterNode()
        emitter.position = position
        emitter.particleTexture = SKTexture(imageNamed: "spark") // TODO: Add spark texture
        emitter.particleBirthRate = 100
        emitter.numParticlesToEmit = 50
        emitter.particleLifetime = 2.0
        emitter.particleLifetimeRange = 0.5
        emitter.emissionAngle = .pi / 2
        emitter.emissionAngleRange = .pi
        emitter.particleSpeed = 200
        emitter.particleSpeedRange = 100
        emitter.particleScale = 0.1
        emitter.particleScaleRange = 0.05
        emitter.particleAlpha = 1.0
        emitter.particleAlphaRange = 0.0
        emitter.particleAlphaSpeed = -0.5
        emitter.particleColorBlendFactor = 1.0
        emitter.particleColor = .yellow
        
        return emitter
    }
    
    /// Create wrong answer effect
    func createWrongAnswerEffect() -> SKEmitterNode? {
        // TODO: Implement wrong answer particle effect
        return nil
    }
}

// MARK: - Text Style Types

/// Text style types matching the existing TextStyles system
enum TextStyleType {
    case gameTitle
    case title
    case subtitle
    case heading
    case body
    case bodySecondary
    case caption
    case buttonLarge
    case buttonMedium
    case questionText
    case answerText
    case scoreText
}
