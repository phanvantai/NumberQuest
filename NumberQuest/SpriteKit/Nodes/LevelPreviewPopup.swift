//
//  LevelPreviewPopup.swift
//  NumberQuest
//
//  Created by NumberQuest on 2024.
//

import SpriteKit

/// Popup that shows level details and allows starting the level
class LevelPreviewPopup: SKNode {
    
    // MARK: - Types
    
    enum Action {
        case startLevel
        case close
    }
    
    // MARK: - Properties
    
    private let level: GameLevel
    private let actionHandler: (Action) -> Void
    private let popupSize = CGSize(width: 300, height: 400)
    
    private var backgroundNode: SKShapeNode?
    private var contentContainer: SKNode?
    private var closeButton: SKNode?
    private var startButton: SKNode?
    
    // MARK: - Initialization
    
    init(level: GameLevel, actionHandler: @escaping (Action) -> Void) {
        self.level = level
        self.actionHandler = actionHandler
        super.init()
        
        setupPopup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupPopup() {
        // Semi-transparent background overlay
        let overlaySize = CGSize(width: 1000, height: 1000)
        let overlay = SKShapeNode(rectOf: overlaySize)
        overlay.fillColor = UIColor.black.withAlphaComponent(0.5)
        overlay.strokeColor = .clear
        overlay.zPosition = 0
        overlay.name = "overlay"
        addChild(overlay)
        
        // Main popup background
        let rect = CGRect(
            x: -popupSize.width / 2,
            y: -popupSize.height / 2,
            width: popupSize.width,
            height: popupSize.height
        )
        
        backgroundNode = SKShapeNode(rect: rect, cornerRadius: 25)
        backgroundNode?.fillColor = UIColor.black.withAlphaComponent(0.9)
        backgroundNode?.strokeColor = UIColor.white.withAlphaComponent(0.3)
        backgroundNode?.lineWidth = 2
        backgroundNode?.zPosition = 1
        backgroundNode?.name = "background"
        addChild(backgroundNode!)
        
        // Content container
        contentContainer = SKNode()
        contentContainer?.zPosition = 2
        addChild(contentContainer!)
        
        setupContent()
        setupButtons()
    }
    
    private func setupContent() {
        guard let contentContainer = contentContainer else { return }
        
        // Level icon
        let iconSize: CGFloat = 80
        let iconBackground = SKShapeNode(circleOfRadius: iconSize / 2)
        iconBackground.fillColor = UIColor.white.withAlphaComponent(0.9)
        iconBackground.strokeColor = .clear
        iconBackground.position = CGPoint(x: 0, y: 130)
        contentContainer.addChild(iconBackground)
        
        // Add level icon (using emoji for now)
        let iconEmoji = getIconEmoji(for: level.imageName)
        let iconLabel = NodeFactory.shared.createLabel(
            text: iconEmoji,
            style: .gameTitle,
            color: .blue
        )
        iconLabel.position = CGPoint(x: 0, y: 130)
        iconLabel.fontSize = 40
        contentContainer.addChild(iconLabel)
        
        // Level name
        let nameLabel = NodeFactory.shared.createLabel(
            text: level.name,
            style: .title,
            color: .white
        )
        nameLabel.position = CGPoint(x: 0, y: 70)
        nameLabel.preferredMaxLayoutWidth = popupSize.width - 40
        nameLabel.numberOfLines = 2
        contentContainer.addChild(nameLabel)
        
        // Level description
        let descriptionLabel = NodeFactory.shared.createLabel(
            text: level.description,
            style: .body,
            color: UIColor.white.withAlphaComponent(0.9)
        )
        descriptionLabel.position = CGPoint(x: 0, y: 30)
        descriptionLabel.preferredMaxLayoutWidth = popupSize.width - 40
        descriptionLabel.numberOfLines = 3
        contentContainer.addChild(descriptionLabel)
        
        // Level details
        setupDetailCards()
        
        // Stars display
        setupStarsDisplay()
    }
    
    private func setupDetailCards() {
        guard let contentContainer = contentContainer else { return }
        
        let cardWidth: CGFloat = 120
        let cardHeight: CGFloat = 60
        let cardSpacing: CGFloat = 20
        
        // Operations card
        let operationsCard = createDetailCard(
            title: "Operations",
            content: level.allowedOperations.map { $0.rawValue }.joined(separator: ", "),
            size: CGSize(width: cardWidth, height: cardHeight),
            position: CGPoint(x: -cardWidth/2 - cardSpacing/2, y: -30)
        )
        contentContainer.addChild(operationsCard)
        
        // Difficulty card
        let difficultyCard = createDetailCard(
            title: "Difficulty",
            content: level.difficulty.rawValue.capitalized,
            size: CGSize(width: cardWidth, height: cardHeight),
            position: CGPoint(x: cardWidth/2 + cardSpacing/2, y: -30)
        )
        contentContainer.addChild(difficultyCard)
        
        // Questions card
        let questionsCard = createDetailCard(
            title: "Questions",
            content: "\(level.maxQuestions)",
            size: CGSize(width: cardWidth, height: cardHeight),
            position: CGPoint(x: 0, y: -100)
        )
        contentContainer.addChild(questionsCard)
    }
    
    private func createDetailCard(title: String, content: String, size: CGSize, position: CGPoint) -> SKNode {
        let card = SKNode()
        card.position = position
        
        // Background
        let rect = CGRect(
            x: -size.width / 2,
            y: -size.height / 2,
            width: size.width,
            height: size.height
        )
        
        let background = SKShapeNode(rect: rect, cornerRadius: 12)
        background.fillColor = UIColor.white.withAlphaComponent(0.1)
        background.strokeColor = UIColor.white.withAlphaComponent(0.3)
        background.lineWidth = 1
        card.addChild(background)
        
        // Title
        let titleLabel = NodeFactory.shared.createLabel(
            text: title,
            style: .caption,
            color: UIColor.white.withAlphaComponent(0.7)
        )
        titleLabel.position = CGPoint(x: 0, y: 10)
        titleLabel.fontSize = 12
        card.addChild(titleLabel)
        
        // Content
        let contentLabel = NodeFactory.shared.createLabel(
            text: content,
            style: .heading,
            color: .white
        )
        contentLabel.position = CGPoint(x: 0, y: -10)
        contentLabel.fontSize = 14
        contentLabel.preferredMaxLayoutWidth = size.width - 10
        contentLabel.numberOfLines = 2
        card.addChild(contentLabel)
        
        return card
    }
    
    private func setupStarsDisplay() {
        guard let contentContainer = contentContainer else { return }
        
        // Stars title
        let starsTitle = NodeFactory.shared.createLabel(
            text: "Stars Earned",
            style: .heading,
            color: .white
        )
        starsTitle.position = CGPoint(x: 0, y: -130)
        contentContainer.addChild(starsTitle)
        
        // Stars
        let starSpacing: CGFloat = 20
        let startX = -CGFloat(2) * starSpacing / 2
        
        for i in 0..<3 {
            let star = createStarNode(filled: i < level.starsEarned)
            star.position = CGPoint(x: startX + CGFloat(i) * starSpacing, y: -155)
            contentContainer.addChild(star)
        }
    }
    
    private func createStarNode(filled: Bool) -> SKNode {
        let star = SKNode()
        
        // Star background
        let starBg = SKShapeNode(circleOfRadius: 12)
        starBg.fillColor = filled ? UIColor.yellow.withAlphaComponent(0.3) : UIColor.gray.withAlphaComponent(0.2)
        starBg.strokeColor = filled ? .yellow : .gray
        starBg.lineWidth = 1
        star.addChild(starBg)
        
        // Star emoji
        let starLabel = NodeFactory.shared.createLabel(
            text: filled ? "⭐" : "☆",
            style: .heading,
            color: filled ? .yellow : .gray
        )
        starLabel.fontSize = 16
        star.addChild(starLabel)
        
        return star
    }
    
    private func setupButtons() {
        guard let contentContainer = contentContainer else { return }
        
        // Close button (X in top right)
        closeButton = NodeFactory.shared.createButton(
            text: "✕",
            size: CGSize(width: 40, height: 40),
            backgroundColor: UIColor.red.withAlphaComponent(0.7),
            textColor: .white
        ) { [weak self] in
            self?.actionHandler(.close)
        }
        
        closeButton?.position = CGPoint(x: popupSize.width/2 - 30, y: popupSize.height/2 - 30)
        contentContainer.addChild(closeButton!)
        
        // Start button
        startButton = NodeFactory.shared.createButton(
            text: "🚀 Start Adventure",
            size: CGSize(width: 200, height: 50),
            backgroundColor: UIColor.green.withAlphaComponent(0.8),
            textColor: .white
        ) { [weak self] in
            self?.actionHandler(.startLevel)
        }
        
        startButton?.position = CGPoint(x: 0, y: -popupSize.height/2 + 40)
        contentContainer.addChild(startButton!)
    }
    
    private func getIconEmoji(for imageName: String) -> String {
        switch imageName {
        case "sun.max.fill":
            return "☀️"
        case "tree.fill":
            return "🌲"
        case "mountain.2.fill":
            return "🏔️"
        case "building.2.fill":
            return "🏰"
        case "diamond.fill":
            return "💎"
        case "flame.fill":
            return "🔥"
        default:
            return "🎯"
        }
    }
    
    // MARK: - Animation Methods
    
    func animateIn() {
        // Initial state
        alpha = 0
        setScale(0.3)
        
        // Entrance animation
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.3)
        let entrance = SKAction.group([fadeIn, scaleUp])
        
        entrance.timingMode = .easeOut
        run(entrance)
        
        // Add bounce effect
        let bounce = SKAction.sequence([
            SKAction.scale(to: 1.05, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.3),
            bounce
        ]))
    }
    
    func animateOut(completion: @escaping () -> Void) {
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let scaleDown = SKAction.scale(to: 0.3, duration: 0.2)
        let exit = SKAction.group([fadeOut, scaleDown])
        
        exit.timingMode = .easeIn
        run(exit) {
            completion()
        }
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        // Close if tapped outside popup
        if touchedNode.name == "overlay" {
            actionHandler(.close)
        }
    }
}
