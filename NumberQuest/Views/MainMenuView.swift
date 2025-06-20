//
//  MainMenuView.swift
//  NumberQuest
//
//  Created by TaiPV on 20/6/25.
//

import SwiftUI

struct MainMenuView: View {
    @StateObject private var gameData = GameData.shared
    @State private var selectedTab = 0
    @State private var showingSettings = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.8),
                        Color.purple.opacity(0.6),
                        Color.pink.opacity(0.4)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Title
                        VStack(spacing: 10) {
                            Text("🔢")
                                .style(.largeEmoji)
                            
                            Text("NumberQuest")
                                .style(.gameTitle)
                            
                            Text("Math Adventure")
                                .style(.subtitle)
                        }
                        .padding(.top, 50)
                        
                        // Player stats card
                        PlayerStatsCard()
                            .environmentObject(gameData)
                        
                        // Menu buttons
                        VStack(spacing: 20) {
                            NavigationLink(destination: CampaignMapView().environmentObject(gameData)) {
                                MenuButton(
                                    title: "🌍 Campaign Mode",
                                    subtitle: "Adventure Journey",
                                    color: .green
                                )
                            }
                            
                            NavigationLink(destination: QuickPlayView().environmentObject(gameData)) {
                                MenuButton(
                                    title: "⚡️ Quick Play",
                                    subtitle: "Instant Challenge",
                                    color: .orange
                                )
                            }
                            
                            NavigationLink(destination: PlayerProgressView().environmentObject(gameData)) {
                                MenuButton(
                                    title: "📊 Progress",
                                    subtitle: "View Your Stats",
                                    color: .blue
                                )
                            }
                            
                            Button(action: { showingSettings = true }) {
                                MenuButton(
                                    title: "⚙️ Settings",
                                    subtitle: "Game Options",
                                    color: .gray
                                )
                            }
                        }
                        
                        // Add some bottom padding to ensure content is not cut off
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

struct MenuButton: View {
    let title: String
    let subtitle: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .style(.title)
            
            Text(subtitle)
                .style(.body)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(color.opacity(0.8))
                .shadow(color: color.opacity(0.3), radius: 10, x: 0, y: 5)
        )
    }
}

struct PlayerStatsCard: View {
    @EnvironmentObject var gameData: GameData
    
    var body: some View {
        HStack(spacing: 20) {
            StatItem(
                icon: "star.fill",
                value: "\(gameData.playerProgress.totalStars)",
                label: "Stars",
                color: .yellow
            )
            
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.3))
            
            StatItem(
                icon: "target",
                value: String(format: "%.0f%%", gameData.playerProgress.accuracy),
                label: "Accuracy",
                color: .green
            )
            
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.3))
            
            StatItem(
                icon: "flame.fill",
                value: "\(gameData.playerProgress.bestStreak)",
                label: "Best Streak",
                color: .red
            )
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.white.opacity(0.2))
        )
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(color)
            
            Text(value)
                .style(.scoreText)
            
            Text(label)
                .style(.smallCaption)
        }
    }
}

struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        return UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {}
}

#Preview {
    MainMenuView()
}
