//
//  GameLogicIntegrationDemo.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 21/6/25.
//

import SwiftUI
import SpriteKit

/// Demo view to showcase Step 2.3: Game Logic Integration completion
/// Demonstrates full game logic integration with touch handling and validation
struct GameLogicIntegrationDemo: View {
    @StateObject private var gameData = GameData.shared
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [.nqBlue, .nqPurple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Text("Step 2.3: Game Logic Integration")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("✅ Fully Completed Features:")
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                VStack(alignment: .leading, spacing: 10) {
                    FeatureRow(title: "GameSession Integration", 
                              description: "Session state, scoring, and progress tracking")
                    FeatureRow(title: "Touch Handling", 
                              description: "Complete touch detection and button interaction")
                    FeatureRow(title: "Question Generation", 
                              description: "Dynamic math questions with adaptive difficulty")
                    FeatureRow(title: "Answer Validation", 
                              description: "Full validation with visual/audio feedback")
                    FeatureRow(title: "Visual Effects", 
                              description: "Celebrations, screen shake, particle effects")
                    FeatureRow(title: "Sound & Haptics", 
                              description: "Audio feedback and haptic responses")
                }
                .padding(.horizontal, 20)
                
                // Demo Game Scene
                SpriteView(scene: createDemoScene())
                    .frame(height: 300)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .padding(.horizontal, 20)
                
                Text("🎮 Interactive Demo Above")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
            }
            .padding(.top, 50)
        }
        .navigationBarHidden(true)
    }
    
    private func createDemoScene() -> GameScene {
        let scene = GameScene()
        scene.size = CGSize(width: 400, height: 300)
        scene.scaleMode = .aspectFit
        
        // Configure for quick demo
        let sampleLevel = GameLevel(
            id: 999,
            name: "Step 2.3 Demo",
            difficulty: .medium,
            allowedOperations: [.addition, .subtraction],
            maxQuestions: 5,
            unlocked: true,
            completed: false,
            stars: 0
        )
        
        scene.configure(gameMode: .campaign, level: sampleLevel)
        return scene
    }
}

struct FeatureRow: View {
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text("✅")
                .font(.system(size: 16))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 14, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
            }
            
            Spacer()
        }
    }
}

#Preview {
    GameLogicIntegrationDemo()
        .environmentObject(GameData.shared)
}
