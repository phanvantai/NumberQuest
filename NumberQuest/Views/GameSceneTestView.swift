//
//  GameSceneTestView.swift
//  NumberQuest
//
//  Created by NumberQuest Team on 21/6/25.
//

import SwiftUI
import SpriteKit

/// Test view for demonstrating GameScene functionality
/// This view allows testing the GameScene implementation
struct GameSceneTestView: View {
    @EnvironmentObject var gameData: GameData
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Create GameScene and wrap it in SpriteKitView
                SpriteKitView(scene: createGameScene(size: geometry.size))
                    .ignoresSafeArea()
                
                // Overlay with back button
                VStack {
                    HStack {
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.3))
                                .clipShape(Circle())
                        }
                        .padding()
                        
                        Spacer()
                    }
                    
                    Spacer()
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private func createGameScene(size: CGSize) -> GameScene {
        let scene = GameScene()
        scene.size = size
        scene.scaleMode = .aspectFill
        
        // Configure with sample data
        if let firstLevel = gameData.levels.first {
            scene.configure(gameMode: .campaign, level: firstLevel)
        } else {
            scene.configure(gameMode: .quickPlay)
        }
        
        return scene
    }
}

#Preview {
    GameSceneTestView()
        .environmentObject(GameData.shared)
}
