//
//  SpriteKitContainer.swift
//  NumberQuest
//
//  Created by TaiPV on 24/6/25.
//

import SwiftUI
import SpriteKit

/// SwiftUI container for SpriteKit scenes
/// Allows easy integration of SpriteKit scenes into SwiftUI navigation
struct SpriteKitContainer: UIViewRepresentable {
    
    let scene: BaseGameScene
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        
        // Configure SKView
        view.showsFPS = false
        view.showsNodeCount = false
        view.ignoresSiblingOrder = true
        view.preferredFramesPerSecond = 60
        
        // Set up scene
        scene.size = view.bounds.size
        scene.scaleMode = .resizeFill
        
        // Set the scene manager reference
        GameSceneManager.shared.currentSceneView = view
        
        // Present the scene
        view.presentScene(scene)
        
        return view
    }
    
    func updateUIView(_ uiView: SKView, context: Context) {
        // Handle size changes
        if uiView.bounds.size != scene.size {
            scene.size = uiView.bounds.size
        }
    }
}

/// Demo scene to test our SpriteKit foundation with enhanced infrastructure
class DemoScene: BaseGameScene {
    
    private var demoGameSession: GameSession?
    
    override func setupBackground() {
        super.setupBackground()
        
        // Create a more vibrant gradient background
        createGradientBackground(colors: [
            UIColor(red: 0.2, green: 0.6, blue: 1.0, alpha: 1.0), // Sky blue
            UIColor(red: 0.8, green: 0.3, blue: 1.0, alpha: 1.0)  // Purple
        ])
    }
    
    override func setupUI() {
        super.setupUI()
        
        // Title
        let titleLabel = NodeFactory.shared.createLabel(
            text: "SpriteKit Infrastructure Demo",
            style: .gameTitle,
            color: .white
        )
        titleLabel.position = position(x: 0.5, y: 0.1)
        addChild(titleLabel)
        
        // Subtitle
        let subtitleLabel = NodeFactory.shared.createLabel(
            text: "Phase 1.2 Complete! 🎉",
            style: .subtitle,
            color: .white
        )
        subtitleLabel.position = position(x: 0.5, y: 0.2)
        addChild(subtitleLabel)
        
        // Enhanced feature list
        let features = [
            "✅ Enhanced GameSceneManager with state tracking",
            "✅ MainGameScene for actual gameplay",
            "✅ Coordinate system with animation helpers",
            "✅ Touch handling utilities",
            "✅ Scene transition improvements",
            "✅ Complete core infrastructure ready"
        ]
        
        for (index, feature) in features.enumerated() {
            let featureLabel = NodeFactory.shared.createLabel(
                text: feature,
                style: .body,
                color: .white
            )
            featureLabel.position = position(x: 0.5, y: 0.35 + CGFloat(index) * 0.08)
            addChild(featureLabel)
            
            // Add entrance animation with spring effect
            featureLabel.alpha = 0
            featureLabel.setScale(0.8)
            
            let delay = SKAction.wait(forDuration: Double(index) * 0.15)
            let springBounce = CoordinateSystem.springBounce(scale: 1.1, duration: 0.4)
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            let entrance = SKAction.group([fadeIn, springBounce])
            
            featureLabel.run(SKAction.sequence([delay, entrance]))
        }
        
        // Test MainGameScene button
        let gameTestButton = NodeFactory.shared.createButton(
            text: "Test MainGameScene",
            size: CGSize(width: 250, height: 50),
            backgroundColor: UIColor.blue.withAlphaComponent(0.8),
            textColor: .white,
            cornerRadius: 15
        ) { [weak self] in
            self?.testMainGameScene()
        }
        gameTestButton.position = position(x: 0.3, y: 0.85)
        addChild(gameTestButton)
        
        // Test transitions button
        let transitionButton = NodeFactory.shared.createButton(
            text: "Test Scene Transitions",
            size: CGSize(width: 250, height: 50),
            backgroundColor: UIColor.green.withAlphaComponent(0.8),
            textColor: .white,
            cornerRadius: 15
        ) { [weak self] in
            self?.testSceneTransition()
        }
        transitionButton.position = position(x: 0.7, y: 0.85)
        addChild(transitionButton)
        
        // Enhanced progress bar demo
        let progressBar = NodeFactory.shared.createProgressBar(
            size: CGSize(width: 280, height: 20),
            progress: 0.0,
            backgroundColor: UIColor.gray.withAlphaComponent(0.3),
            progressColor: .orange
        )
        progressBar.position = position(x: 0.5, y: 0.92)
        addChild(progressBar)
        
        // Animate progress bar with better timing
        let progressAnimation = SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run { progressBar.updateProgress(to: 1.0) },
                SKAction.wait(forDuration: 2.5),
                SKAction.run { progressBar.updateProgress(to: 0.0) },
                SKAction.wait(forDuration: 1.0)
            ])
        )
        run(progressAnimation)
        
        // Add floating elements
        addFloatingElements()
    }
    
    private func addFloatingElements() {
        // Add some floating demo elements
        for i in 0..<5 {
            let floatingNode = SKSpriteNode(color: UIColor.white.withAlphaComponent(0.3), size: CGSize(width: 20, height: 20))
            floatingNode.position = CGPoint(
                x: CGFloat.random(in: 50...(size.width - 50)),
                y: CGFloat.random(in: 100...(size.height - 100))
            )
            
            let float = SKAction.repeatForever(
                SKAction.sequence([
                    SKAction.moveBy(x: CGFloat.random(in: -50...50), y: CGFloat.random(in: -30...30), duration: 3.0),
                    SKAction.moveBy(x: CGFloat.random(in: -50...50), y: CGFloat.random(in: -30...30), duration: 3.0)
                ])
            )
            floatingNode.run(float)
            addChild(floatingNode)
        }
    }
    
    private func testMainGameScene() {
        // Create a demo game session
        let demoSession = GameSession()
        
        // Start a quick demo game
        demoSession.startGame(mode: .quickPlay)
        
        // Present the main game scene
        GameSceneManager.shared.presentScene(.game(demoSession))
        
        showSuccessMessage("MainGameScene Demo Started!")
    }
    
    private func testSceneTransition() {
        // Test scene transition to campaign map
        GameSceneManager.shared.presentScene(.campaignMap)
        
        showSuccessMessage("Scene Transition Tested!")
    }
    
    private func showSuccessMessage(_ message: String) {
        let successLabel = NodeFactory.shared.createLabel(
            text: message,
            style: .heading,
            color: .yellow
        )
        successLabel.position = position(x: 0.5, y: 0.75)
        successLabel.alpha = 0
        addChild(successLabel)
        
        // Animate success message with spring
        let appear = SKAction.group([
            SKAction.fadeIn(withDuration: 0.3),
            CoordinateSystem.springBounce(scale: 1.3, duration: 0.6)
        ])
        let disappear = SKAction.group([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.scale(to: 0.8, duration: 0.5)
        ])
        
        successLabel.run(SKAction.sequence([
            appear,
            SKAction.wait(forDuration: 1.5),
            disappear,
            SKAction.removeFromParent()
        ]))
    }
}

// MARK: - Preview Helper

/// SwiftUI view for testing the SpriteKit demo
public struct SpriteKitDemoView: View {
    public init() {}
    
    public var body: some View {
        SpriteKitContainer(scene: DemoScene())
            .navigationBarHidden(true)
            .ignoresSafeArea()
    }
}

#Preview {
    SpriteKitDemoView()
}
