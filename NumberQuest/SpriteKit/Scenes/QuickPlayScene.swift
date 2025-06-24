//
//  QuickPlayScene.swift
//  NumberQuest
//
//  Created by NumberQuest on 2024.
//

import SpriteKit

/// Quick play scene - placeholder for now
class QuickPlayScene: BaseGameScene {
    
    override func setupScene() {
        super.setupScene()
        
        let titleLabel = NodeFactory.shared.createLabel(
            text: "Quick Play",
            style: .title,
            color: .white
        )
        titleLabel.position = position(x: 0.5, y: 0.8)
        addChild(titleLabel)
        
        let placeholderLabel = NodeFactory.shared.createLabel(
            text: "Quick Play Scene\n(SpriteKit Placeholder)",
            style: .body,
            color: .white
        )
        placeholderLabel.position = position(x: 0.5, y: 0.5)
        placeholderLabel.numberOfLines = 2
        addChild(placeholderLabel)
    }
    
    override func setupBackground() {
        super.setupBackground()
        createGradientBackground(colors: SpriteKitColors.Backgrounds.gamePlay)
    }
}
