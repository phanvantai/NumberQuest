//
//  ContentView.swift
//  NumberQuest
//
//  Created by TaiPV on 20/6/25.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        SpriteKitGameView()
            .ignoresSafeArea()
    }
}

/// Main SpriteKit game container
struct SpriteKitGameView: View {
    var body: some View {
        ZStack {
            // SpriteKit game scene - Start with main menu
            SpriteKitContainer(scene: MainMenuScene())
                .ignoresSafeArea()
        }
        .onAppear {
            // Game scene manager is already initialized as singleton
            // No additional initialization needed
        }
    }
}

#Preview {
    ContentView()
}
