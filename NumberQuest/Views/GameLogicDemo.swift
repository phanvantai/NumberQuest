//
//  GameLogicDemo.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 21/6/25.
//

import SwiftUI
import SpriteKit

/// Demo view showcasing the enhanced GameScene with full GameSession integration
struct GameLogicDemo: View {
    @EnvironmentObject var gameData: GameData
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDifficulty: GameDifficulty = .easy
    @State private var selectedMode: GameMode = .quickPlay
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Game Logic Integration Demo")
                .style(.title)
                .padding()
            
            Text("This demo showcases the enhanced GameScene with full GameSession integration, adaptive difficulty, detailed feedback, and complete game logic flow.")
                .style(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Mode Selection
            VStack(alignment: .leading, spacing: 10) {
                Text("Game Mode:")
                    .style(.heading)
                
                HStack(spacing: 15) {
                    Button("Quick Play") {
                        selectedMode = .quickPlay
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(selectedMode == .quickPlay ? Color.blue : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Button("Campaign") {
                        selectedMode = .campaign
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(selectedMode == .campaign ? Color.green : Color.gray.opacity(0.3))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            // Difficulty Selection (for Quick Play)
            if selectedMode == .quickPlay {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Starting Difficulty:")
                        .style(.heading)
                    
                    HStack(spacing: 15) {
                        ForEach(GameDifficulty.allCases, id: \.self) { difficulty in
                            Button(difficulty.rawValue) {
                                selectedDifficulty = difficulty
                            }
                            .padding(.horizontal, 15)
                            .padding(.vertical, 8)
                            .background(selectedDifficulty == difficulty ? Color.orange : Color.gray.opacity(0.3))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Features List
            VStack(alignment: .leading, spacing: 8) {
                Text("Enhanced Features:")
                    .style(.heading)
                
                FeatureRow("🧠", "Adaptive difficulty based on performance")
                FeatureRow("🎯", "Detailed answer validation with feedback")
                FeatureRow("🔊", "Sound effects and haptic feedback")
                FeatureRow("💾", "Progress tracking and persistence")
                FeatureRow("⚡", "Real-time score and streak calculation")
                FeatureRow("🎨", "Enhanced visual feedback system")
                FeatureRow("⏱️", "Dynamic timer with bonus time rewards")
                FeatureRow("🎮", "Complete GameSession model integration")
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Launch Demo Button
            NavigationLink(destination: createDemoGameScene()) {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                    Text("Launch Enhanced Game Demo")
                        .style(.buttonLarge)
                }
                .frame(maxWidth: .infinity)
                .padding(20)
                .background(LinearGradient(
                    gradient: Gradient(colors: [Color.purple, Color.pink]),
                    startPoint: .leading,
                    endPoint: .trailing
                ))
                .foregroundColor(.white)
                .cornerRadius(15)
                .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .padding(.horizontal)
            
            Button("Back") {
                presentationMode.wrappedValue.dismiss()
            }
            .style(.body)
            .padding()
        }
        .navigationBarHidden(true)
    }
    
    private func createDemoGameScene() -> GameSceneTestView {
        let testView = GameSceneTestView()
        // Could configure specific demo settings here
        return testView
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    init(_ icon: String, _ text: String) {
        self.icon = icon
        self.text = text
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Text(icon)
                .font(.title3)
            Text(text)
                .style(.body)
                .multilineTextAlignment(.leading)
            Spacer()
        }
    }
}

#Preview {
    GameLogicDemo()
        .environmentObject(GameData.shared)
}
