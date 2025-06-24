//
//  CampaignMapScene.swift
//  NumberQuest
//
//  Created by NumberQuest on 2024.
//

import SpriteKit

/// Campaign map scene - placeholder for now
class CampaignMapScene: BaseGameScene {
    
    override func setupScene() {
        super.setupScene()
        
        let titleLabel = NodeFactory.shared.createLabel(
            text: "Campaign Map",
            style: .title,
            color: .white
        )
        titleLabel.position = position(x: 0.5, y: 0.8)
        addChild(titleLabel)
        
        let placeholderLabel = NodeFactory.shared.createLabel(
            text: "Campaign Map Scene\n(SpriteKit Placeholder)",
            style: .body,
            color: .white
        )
        placeholderLabel.position = position(x: 0.5, y: 0.5)
        placeholderLabel.numberOfLines = 2
        addChild(placeholderLabel)
    }
    
    override func setupBackground() {
        super.setupBackground()
        createGradientBackground(colors: SpriteKitColors.Backgrounds.campaignMap)
    }
}
