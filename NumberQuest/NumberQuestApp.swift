//
//  NumberQuestApp.swift
//  NumberQuest
//
//  Created by TaiPV on 20/6/25.
//

import SwiftUI
import SpriteKit

@main
struct NumberQuestApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(GameData.shared)
        }
    }
}
