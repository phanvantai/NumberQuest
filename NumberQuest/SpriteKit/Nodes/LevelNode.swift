//
//  LevelNode.swift
//  NumberQuest
//
//  Created by NumberQuest on 2024.
//

import SpriteKit

/// Custom node representing a level in the campaign map
class LevelNode: SKNode {
  
  // MARK: - Properties
  
  let level: GameLevel
  private let nodeSize: CGSize
  
  private var backgroundNode: SKShapeNode?
  private var iconNode: SKSpriteNode?
  private var nameLabel: SKLabelNode?
  private var descriptionLabel: SKLabelNode?
  private var starsContainer: SKNode?
  private var lockIcon: SKSpriteNode?
  private var requirementLabel: SKLabelNode?
  private var glowNode: SKShapeNode?
  
  // MARK: - Initialization
  
  init(level: GameLevel, size: CGSize) {
    self.level = level
    self.nodeSize = size
    super.init()
    
    setupNode()
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - Setup
  
  private func setupNode() {
    setupBackground()
    setupContent()
    updateAppearance()
  }
  
  private func setupBackground() {
    // Create rounded rectangle background
    let rect = CGRect(
      x: -nodeSize.width / 2,
      y: -nodeSize.height / 2,
      width: nodeSize.width,
      height: nodeSize.height
    )
    
    backgroundNode = SKShapeNode(rect: rect, cornerRadius: 20)
    backgroundNode?.name = "background"
    backgroundNode?.zPosition = 0
    addChild(backgroundNode!)
    
    // Create glow effect (initially hidden)
    glowNode = SKShapeNode(rect: rect, cornerRadius: 20)
    glowNode?.name = "glow"
    glowNode?.zPosition = -1
    glowNode?.alpha = 0
    addChild(glowNode!)
  }
  
  private func setupContent() {
    if level.isUnlocked {
      setupUnlockedContent()
    } else {
      setupLockedContent()
    }
  }
  
  private func setupUnlockedContent() {
    // Level icon
    if let iconTexture = getIconTexture() {
      iconNode = SKSpriteNode(texture: iconTexture)
      iconNode?.size = CGSize(width: 40, height: 40)
      iconNode?.position = CGPoint(x: 0, y: 25)
      iconNode?.name = "icon"
      addChild(iconNode!)
    }
    
    // Level name
    nameLabel = NodeFactory.shared.createLabel(
      text: level.name,
      style: .heading,
      color: .white
    )
    nameLabel?.position = CGPoint(x: 0, y: -5)
    nameLabel?.name = "nameLabel"
    nameLabel?.preferredMaxLayoutWidth = nodeSize.width - 20
    nameLabel?.numberOfLines = 2
    addChild(nameLabel!)
    
    // Description
    descriptionLabel = NodeFactory.shared.createLabel(
      text: level.description,
      style: .caption,
      color: UIColor.white.withAlphaComponent(0.8)
    )
    descriptionLabel?.position = CGPoint(x: 0, y: -25)
    descriptionLabel?.name = "descriptionLabel"
    descriptionLabel?.preferredMaxLayoutWidth = nodeSize.width - 20
    descriptionLabel?.numberOfLines = 2
    addChild(descriptionLabel!)
    
    // Stars
    setupStarsDisplay()
  }
  
  private func setupLockedContent() {
    // Lock icon
    lockIcon = SKSpriteNode(texture: AssetManager.shared.circleTexture())
    lockIcon?.size = CGSize(width: 40, height: 40)
    lockIcon?.position = CGPoint(x: 0, y: 10)
    lockIcon?.color = .gray
    lockIcon?.colorBlendFactor = 1.0
    lockIcon?.name = "lockIcon"
    addChild(lockIcon!)
    
    // Add lock symbol as emoji
    let lockLabel = NodeFactory.shared.createLabel(
      text: "🔒",
      style: .heading,
      color: .gray
    )
    lockLabel.position = CGPoint(x: 0, y: 10)
    lockLabel.name = "lockLabel"
    addChild(lockLabel)
    
    // Level name (grayed out)
    nameLabel = NodeFactory.shared.createLabel(
      text: level.name,
      style: .heading,
      color: .gray
    )
    nameLabel?.position = CGPoint(x: 0, y: -15)
    nameLabel?.name = "nameLabel"
    nameLabel?.preferredMaxLayoutWidth = nodeSize.width - 20
    nameLabel?.numberOfLines = 2
    addChild(nameLabel!)
    
    // Requirement text
    requirementLabel = NodeFactory.shared.createLabel(
      text: "Requires \(level.requiredStars) ⭐",
      style: .caption,
      color: .gray
    )
    requirementLabel?.position = CGPoint(x: 0, y: -35)
    requirementLabel?.name = "requirementLabel"
    addChild(requirementLabel!)
  }
  
  private func setupStarsDisplay() {
    starsContainer = SKNode()
    starsContainer?.name = "starsContainer"
    starsContainer?.position = CGPoint(x: 0, y: -42)
    addChild(starsContainer!)
    
    let starSpacing: CGFloat = 16
    let startX = -CGFloat(2) * starSpacing / 2
    
    for i in 0..<3 {
      let star = createStarNode(filled: i < level.starsEarned)
      star.position = CGPoint(x: startX + CGFloat(i) * starSpacing, y: 0)
      star.name = "star_\(i)"
      starsContainer?.addChild(star)
    }
  }
  
  private func createStarNode(filled: Bool) -> SKSpriteNode {
    let starTexture = filled ? AssetManager.shared.starTexture : AssetManager.shared.circleTexture
    let star = SKSpriteNode(texture: starTexture())
    star.size = CGSize(width: 12, height: 12)
    star.color = filled ? .yellow : UIColor.white.withAlphaComponent(0.5)
    star.colorBlendFactor = filled ? 0.0 : 1.0
    
    // Add star shape with emoji for better visibility
    let starLabel = NodeFactory.shared.createLabel(
      text: filled ? "⭐" : "☆",
      style: .caption,
      color: filled ? .yellow : UIColor.white.withAlphaComponent(0.5)
    )
    starLabel.fontSize = 10
    star.addChild(starLabel)
    
    return star
  }
  
  private func getIconTexture() -> SKTexture? {
    // Map level image names to textures or use procedural generation
    switch level.imageName {
      case "sun.max.fill":
        return AssetManager.shared.sparkTexture()
      case "tree.fill":
        return AssetManager.shared.circleTexture()
      case "mountain.2.fill":
        return AssetManager.shared.starTexture()
      case "building.2.fill":
        return AssetManager.shared.circleTexture()
      case "diamond.fill":
        return AssetManager.shared.sparkTexture()
      case "flame.fill":
        return AssetManager.shared.starTexture()
      default:
        return AssetManager.shared.circleTexture()
    }
  }
  
  // MARK: - Appearance Updates
  
  private func updateAppearance() {
    guard let backgroundNode = backgroundNode else { return }
    
    if level.isUnlocked {
      // Unlocked appearance
      backgroundNode.fillColor = UIColor.white.withAlphaComponent(0.15)
      backgroundNode.strokeColor = UIColor.white.withAlphaComponent(0.3)
      backgroundNode.lineWidth = 1.0
      
      // Glow effect
      glowNode?.fillColor = UIColor.white.withAlphaComponent(0.1)
      glowNode?.strokeColor = UIColor.white.withAlphaComponent(0.5)
      glowNode?.lineWidth = 2.0
      
      // Scale and opacity
      setScale(1.0)
      alpha = 1.0
    } else {
      // Locked appearance
      backgroundNode.fillColor = UIColor.black.withAlphaComponent(0.2)
      backgroundNode.strokeColor = UIColor.clear
      backgroundNode.lineWidth = 0
      
      // Scale and opacity
      setScale(0.9)
      alpha = 0.6
    }
  }
  
  // MARK: - Animation Methods
  
  func updateGlowEffect() {
    guard level.isUnlocked, let glowNode = glowNode else { return }
    
    // Subtle breathing glow effect
    let intensity = (sin(CACurrentMediaTime() * 2.0) + 1.0) / 2.0 // 0 to 1
    glowNode.alpha = 0.2 + (intensity * 0.3)
  }
  
  func addSelectionGlow() {
    guard let glowNode = glowNode else { return }
    
    let pulseIn = SKAction.fadeAlpha(to: 0.8, duration: 0.3)
    let pulseOut = SKAction.fadeAlpha(to: 0.2, duration: 0.3)
    let pulse = SKAction.sequence([pulseIn, pulseOut])
    let repeatPulse = SKAction.repeatForever(pulse)
    
    glowNode.run(repeatPulse, withKey: "selectionGlow")
  }
  
  func removeSelectionGlow() {
    glowNode?.removeAction(forKey: "selectionGlow")
    glowNode?.alpha = 0
  }
  
  // MARK: - Touch Detection
  
  override func contains(_ point: CGPoint) -> Bool {
    let rect = CGRect(
      x: -nodeSize.width / 2,
      y: -nodeSize.height / 2,
      width: nodeSize.width,
      height: nodeSize.height
    )
    return rect.contains(point)
  }
}
