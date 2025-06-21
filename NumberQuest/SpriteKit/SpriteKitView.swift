//
//  SpriteKitView.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 21/6/25.
//

import SwiftUI
import SpriteKit

/// SwiftUI wrapper for SpriteKit scenes
/// Allows embedding SpriteKit scenes within SwiftUI views for hybrid approach
struct SpriteKitView: UIViewRepresentable {
    
    let scene: BaseScene
    let sceneManager: GameSceneManager
    
    init(scene: BaseScene, sceneManager: GameSceneManager = GameSceneManager.shared) {
        self.scene = scene
        self.sceneManager = sceneManager
    }
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        
        // Configure SKView
        skView.backgroundColor = UIColor.clear
        skView.allowsTransparency = true
        
        // Initialize scene manager
        sceneManager.initialize(with: skView)
        
        // Present the scene
        scene.size = skView.bounds.size
        skView.presentScene(scene)
        
        return skView
    }
    
    func updateUIView(_ skView: SKView, context: Context) {
        // Update scene size if view size changed
        if skView.scene?.size != skView.bounds.size {
            skView.scene?.size = skView.bounds.size
        }
    }
}

/// Convenience SwiftUI view for launching SpriteKit scenes
struct SpriteKitGameView: View {
    let sceneType: SceneType
    @StateObject private var sceneManager = GameSceneManager.shared
    
    var body: some View {
        GeometryReader { geometry in
            SpriteKitView(scene: createScene())
                .onAppear {
                    // Any setup when view appears
                }
                .onDisappear {
                    // Cleanup when view disappears
                }
        }
        .navigationBarHidden(true)
    }
    
    private func createScene() -> BaseScene {
        switch sceneType {
        case .mainMenu:
            return MainMenuScene()
        case .campaignMap:
            return CampaignMapScene()
        case .quickPlay:
            return QuickPlayScene()
        case .game(let gameMode, let level):
            return GameScene(gameMode: gameMode, level: level)
        case .gameOver(let results):
            return GameOverScene(results: results)
        case .settings:
            return SettingsScene()
        case .progress:
            return ProgressScene()
        }
    }
}

// MARK: - Preview Support

#Preview("Main Menu") {
    SpriteKitGameView(sceneType: .mainMenu)
}

#Preview("Game Scene") {
    SpriteKitGameView(sceneType: .game(.quickPlay, nil))
}
