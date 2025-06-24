//
//  SettingsScene.swift
//  NumberQuest
//
//  Created by NumberQuest on 2024.
//

import SpriteKit

/// Settings scene - placeholder for now
class SettingsScene: BaseGameScene {
    
    override func setupScene() {
        super.setupScene()
        
        let titleLabel = NodeFactory.shared.createLabel(
            text: "Settings",
            style: .title,
            color: .white
        )
        titleLabel.position = position(x: 0.5, y: 0.8)
        addChild(titleLabel)
        
        let placeholderLabel = NodeFactory.shared.createLabel(
            text: "Settings Scene\n(SpriteKit Placeholder)",
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
            UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0),
            UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        ])
    }
}
