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
    
    /// Create a game button with consistent styling
    func createButton(
        text: String,
        size: CGSize,
        backgroundColor: UIColor = UIColor.green.withAlphaComponent(0.8),
        textColor: UIColor = .white,
        cornerRadius: CGFloat = 15,
        action: @escaping () -> Void
    ) -> GameButtonNode {
        
        return GameButtonNode(
            text: text,
            size: size,
            backgroundColor: backgroundColor,
            textColor: textColor,
            cornerRadius: cornerRadius,
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
    
    /// Create a card-style container node
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
    
    /// Create a progress bar node
    func createProgressBar(
        size: CGSize,
        progress: CGFloat = 0.0,
        backgroundColor: UIColor = UIColor.gray.withAlphaComponent(0.3),
        progressColor: UIColor = .green
    ) -> ProgressBarNode {
        
        return ProgressBarNode(
            size: size,
            progress: progress,
            backgroundColor: backgroundColor,
            progressColor: progressColor
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

// MARK: - Custom Node Classes

/// Custom button node with touch handling
class GameButtonNode: SKNode {
    
    let backgroundNode: SKSpriteNode  // Made public
    private let labelNode: SKLabelNode
    private let action: () -> Void
    
    init(
        text: String,
        size: CGSize,
        backgroundColor: UIColor,
        textColor: UIColor,
        cornerRadius: CGFloat,
        action: @escaping () -> Void
    ) {
        self.action = action
        
        // Create background
        self.backgroundNode = SKSpriteNode(color: backgroundColor, size: size)
        
        // Create label
        self.labelNode = NodeFactory.shared.createLabel(
            text: text,
            style: .buttonLarge,
            color: textColor
        )
        
        super.init()
        
        // Add nodes
        addChild(backgroundNode)
        addChild(labelNode)
        
        // Enable user interaction
        isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Scale down animation
        let scaleDown = SKAction.scale(to: 0.95, duration: 0.1)
        run(scaleDown)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Scale back up and execute action
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        run(scaleUp) { [weak self] in
            self?.action()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Scale back up without action
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        run(scaleUp)
    }
}

/// Custom progress bar node
class ProgressBarNode: SKNode {
    
    private let backgroundBar: SKSpriteNode
    private let progressBar: SKSpriteNode
    private let barSize: CGSize
    private var currentProgress: CGFloat = 0.0
    
    init(
        size: CGSize,
        progress: CGFloat,
        backgroundColor: UIColor,
        progressColor: UIColor
    ) {
        self.barSize = size
        self.currentProgress = progress
        
        // Create background bar
        self.backgroundBar = SKSpriteNode(color: backgroundColor, size: size)
        
        // Create progress bar
        let progressSize = CGSize(width: size.width * progress, height: size.height)
        self.progressBar = SKSpriteNode(color: progressColor, size: progressSize)
        self.progressBar.anchorPoint = CGPoint(x: 0, y: 0.5)
        self.progressBar.position = CGPoint(x: -size.width / 2, y: 0)
        
        super.init()
        
        addChild(backgroundBar)
        addChild(progressBar)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Update progress with animation
    func updateProgress(to newProgress: CGFloat, animated: Bool = true) {
        let clampedProgress = max(0.0, min(1.0, newProgress))
        let newSize = CGSize(width: barSize.width * clampedProgress, height: barSize.height)
        
        if animated {
            let resizeAction = SKAction.resize(toWidth: newSize.width, height: newSize.height, duration: 0.3)
            resizeAction.timingMode = .easeInEaseOut
            progressBar.run(resizeAction)
        } else {
            progressBar.size = newSize
        }
        
        currentProgress = clampedProgress
    }
}
