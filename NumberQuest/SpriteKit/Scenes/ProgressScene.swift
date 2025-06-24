//
//  ProgressScene.swift
//  NumberQuest
//
//  Created by NumberQuest on 2024.
//

import SpriteKit

/// Progress scene - placeholder for now
class ProgressScene: BaseGameScene {
    
    override func setupScene() {
        super.setupScene()
        
        let titleLabel = NodeFactory.shared.createLabel(
            text: "Progress",
            style: .title,
            color: .white
        )
        titleLabel.position = position(x: 0.5, y: 0.8)
        addChild(titleLabel)
        
        let placeholderLabel = NodeFactory.shared.createLabel(
            text: "Progress Scene\n(SpriteKit Placeholder)",
            style: .body,
            color: .white
        )
        placeholderLabel.position = position(x: 0.5, y: 0.5)
        placeholderLabel.numberOfLines = 2
        addChild(placeholderLabel)
    }
    
    override func setupBackground() {
        super.setupBackground()
        createGradientBackground(colors: [
            UIColor(red: 0.1, green: 0.7, blue: 0.3, alpha: 1.0),
            UIColor(red: 0.8, green: 0.9, blue: 0.3, alpha: 1.0)
        ])
    }
}
