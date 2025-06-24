//
//  MainMenuScene.swift
//  NumberQuest
//
//  Created by NumberQuest on 2024.
//

import SpriteKit

/// Main menu scene - placeholder for now
class MainMenuScene: BaseGameScene {
    
    override func setupScene() {
        super.setupScene()
        
        // Add title
        let titleLabel = NodeFactory.shared.createLabel(
            text: "NumberQuest",
            style: .gameTitle,
            color: .white
        )
        titleLabel.position = position(x: 0.5, y: 0.7)
        addChild(titleLabel)
        
        // Add placeholder text
        let placeholderLabel = NodeFactory.shared.createLabel(
            text: "Main Menu Scene\n(SpriteKit Placeholder)",
            style: .body,
            color: .white
        )
        placeholderLabel.position = position(x: 0.5, y: 0.5)
        placeholderLabel.numberOfLines = 2
        addChild(placeholderLabel)
        
        // Asset validation button
        let validationButton = NodeFactory.shared.createButton(
            text: "Test Assets",
            size: CGSize(width: 200, height: 60),
            backgroundColor: .systemOrange,
            textColor: .white
        ) { [weak self] in
            GameSceneManager.shared.presentScene(.assetValidation)
        }
        validationButton.position = position(x: 0.5, y: 0.3)
        addChild(validationButton)
    }
    
    override func setupBackground() {
        super.setupBackground()
        createGradientBackground(colors: SpriteKitColors.Backgrounds.mainMenu)
    }
}
