//
//  MainMenuView.swift
//  NumberQuest
//
//  Created by TaiPV on 20/6/25.
//

import SwiftUI

// TEMPORARY: Import for SpriteKit demo
// This will be removed once we fully convert to SpriteKit

struct MainMenuView: View {
    @StateObject private var gameData = GameData.shared
    @State private var selectedTab = 0
    @State private var showingSettings = false
    @State private var isAnimating = false
    @State private var floatingOffset: CGFloat = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dynamic background with multiple layers
                ZStack {
                    // Base gradient
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.1, green: 0.2, blue: 0.8),
                            Color(red: 0.3, green: 0.1, blue: 0.7),
                            Color(red: 0.7, green: 0.2, blue: 0.9),
                            Color(red: 0.9, green: 0.4, blue: 0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    // Animated overlay for dynamic effect
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.cyan.opacity(0.3),
                            Color.clear,
                            Color.yellow.opacity(0.2)
                        ]),
                        startPoint: isAnimating ? .topTrailing : .bottomLeading,
                        endPoint: isAnimating ? .bottomLeading : .topTrailing
                    )
                    .ignoresSafeArea()
                    .animation(.easeInOut(duration: 4).repeatForever(), value: isAnimating)
                }
                
                // Floating background elements
                FloatingElements()
                
                // Stars background pattern
                StarsBackground()
                
                ScrollView {
                    VStack(spacing: 40) {
                        // Enhanced title with character
                        VStack(spacing: 15) {
                            // Floating character
                            Text("🤖")
                                .style(.largeEmoji)
                                .font(.system(size: 60))
                                .offset(y: floatingOffset)
                                .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: floatingOffset)
                                .onAppear {
                                    floatingOffset = -10
                                }
                            
                            // Game title with sparkle effect
                            HStack {
                                Text("✨")
                                    .style(.emoji)
                                    .scaleEffect(isAnimating ? 1.2 : 0.8)
                                    .animation(.easeInOut(duration: 1.5).repeatForever(), value: isAnimating)
                                
                                Text("NumberQuest")
                                    .style(.gameTitle)
                                    .shadow(color: .white.opacity(0.5), radius: 10, x: 0, y: 0)
                                
                                Text("✨")
                                    .style(.emoji)
                                    .scaleEffect(isAnimating ? 0.8 : 1.2)
                                    .animation(.easeInOut(duration: 1.5).repeatForever(), value: isAnimating)
                            }
                            
                            Text("Math Adventure Awaits!")
                                .style(.subtitle)
                                .multilineTextAlignment(.center)
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        .padding(.top, 40)
                        
                        // Enhanced player stats card
                        EnhancedPlayerStatsCard()
                            .environmentObject(gameData)
                        
                        // Game mode buttons with enhanced styling
                        VStack(spacing: 25) {
                            NavigationLink(destination: CampaignMapView().environmentObject(gameData)) {
                                GameModeButton(
                                    title: "🌍 Campaign Mode",
                                    subtitle: "Epic Adventure Journey",
                                    description: "Explore worlds and unlock new challenges!",
                                    primaryColor: .green,
                                    secondaryColor: .mint,
                                    icon: "map.fill"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: QuickPlayView().environmentObject(gameData)) {
                                GameModeButton(
                                    title: "⚡️ Quick Play",
                                    subtitle: "Lightning Fast Fun",
                                    description: "Jump right into the action!",
                                    primaryColor: .orange,
                                    secondaryColor: .yellow,
                                    icon: "bolt.fill"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            NavigationLink(destination: ProgressView().environmentObject(gameData)) {
                                GameModeButton(
                                    title: "📊 Progress",
                                    subtitle: "Your Amazing Journey",
                                    description: "See how much you've grown!",
                                    primaryColor: .blue,
                                    secondaryColor: .cyan,
                                    icon: "chart.bar.fill"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: { showingSettings = true }) {
                                GameModeButton(
                                    title: "⚙️ Settings",
                                    subtitle: "Customize Your Game",
                                    description: "Make it perfect for you!",
                                    primaryColor: .gray,
                                    secondaryColor: .white,
                                    icon: "gearshape.fill"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // TEMPORARY: SpriteKit Demo Button - Commented out for now
                            /*
                            NavigationLink(destination: SpriteKitDemoView()) {
                                GameModeButton(
                                    title: "🎮 SpriteKit Demo",
                                    subtitle: "Phase 1.1 Complete ✅",
                                    description: "Test the new SpriteKit foundation!",
                                    primaryColor: .purple,
                                    secondaryColor: .pink,
                                    icon: "gamecontroller.fill"
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            */
                        }
                        
                        // Add some bottom padding to ensure content is not cut off
                        Spacer(minLength: 120)
                    }
                    .padding(.horizontal, 20)
                }
                .onAppear {
                    isAnimating = true
                }
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView()
        }
    }
}

// MARK: - Enhanced Game Mode Button
struct GameModeButton: View {
    let title: String
    let subtitle: String
    let description: String
    let primaryColor: Color
    let secondaryColor: Color
    let icon: String
    
    var body: some View {
        HStack(spacing: 15) {
            // Icon section
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [primaryColor, secondaryColor]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 60, height: 60)
                    .shadow(color: primaryColor.opacity(0.5), radius: 8, x: 0, y: 4)
                
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Text content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .style(.title)
                    .multilineTextAlignment(.leading)
                
                Text(subtitle)
                    .style(.body)
                    .multilineTextAlignment(.leading)
                
                Text(description)
                    .style(.caption)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            // Arrow indicator
            Image(systemName: "chevron.right")
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(20)
        .background(
            ZStack {
                // Glassmorphism effect
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            primaryColor.opacity(0.3),
                            secondaryColor.opacity(0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        .white.opacity(0.6),
                                        .white.opacity(0.1)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                
                // Shimmer effect
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            .clear,
                            .white.opacity(0.1),
                            .clear
                        ]),
                        startPoint: .leading,
                        endPoint: .trailing
                    ))
                    .blur(radius: 10)
            }
        )
        .shadow(color: primaryColor.opacity(0.3), radius: 15, x: 0, y: 8)
    }
}

// MARK: - Enhanced Player Stats Card
struct EnhancedPlayerStatsCard: View {
    @EnvironmentObject var gameData: GameData
    @State private var animateStats = false
    
    var body: some View {
        VStack(spacing: 15) {
            // Header
            HStack {
                Text("🏆")
                    .style(.emoji)
                    .scaleEffect(animateStats ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(), value: animateStats)
                
                Text("Your Achievements")
                    .style(.heading)
                
                Text("🏆")
                    .style(.emoji)
                    .scaleEffect(animateStats ? 1.0 : 1.2)
                    .animation(.easeInOut(duration: 2).repeatForever(), value: animateStats)
            }
            
            // Stats grid
            HStack(spacing: 20) {
                EnhancedStatItem(
                    icon: "star.fill",
                    value: "\(gameData.playerProgress.totalStars)",
                    label: "Stars Earned",
                    color: .yellow,
                    accentColor: .orange
                )
                
                Divider()
                    .frame(height: 50)
                    .background(LinearGradient(
                        gradient: Gradient(colors: [.clear, .white.opacity(0.5), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                
                EnhancedStatItem(
                    icon: "target",
                    value: String(format: "%.0f%%", gameData.playerProgress.accuracy),
                    label: "Accuracy Rate",
                    color: .green,
                    accentColor: .mint
                )
                
                Divider()
                    .frame(height: 50)
                    .background(LinearGradient(
                        gradient: Gradient(colors: [.clear, .white.opacity(0.5), .clear]),
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                
                EnhancedStatItem(
                    icon: "flame.fill",
                    value: "\(gameData.playerProgress.bestStreak)",
                    label: "Best Streak",
                    color: .red,
                    accentColor: .pink
                )
            }
        }
        .padding(25)
        .background(
            ZStack {
                // Glassmorphism background
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(LinearGradient(
                                gradient: Gradient(colors: [
                                    .white.opacity(0.8),
                                    .white.opacity(0.2)
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ), lineWidth: 1)
                    )
            }
        )
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        .onAppear {
            animateStats = true
        }
    }
}

// MARK: - Enhanced Stat Item
struct EnhancedStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let accentColor: Color
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 10) {
            // Icon with pulsing background
            ZStack {
                Circle()
                    .fill(RadialGradient(
                        gradient: Gradient(colors: [color.opacity(0.3), accentColor.opacity(0.1)]),
                        center: .center,
                        startRadius: 5,
                        endRadius: 25
                    ))
                    .frame(width: 50, height: 50)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(), value: isAnimating)
                
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(color)
            }
            
            Text(value)
                .style(.scoreText)
                .foregroundColor(.white)
            
            Text(label)
                .style(.smallCaption)
                .multilineTextAlignment(.center)
                .foregroundColor(.white.opacity(0.8))
        }
        .onAppear {
            isAnimating = true
        }
    }
}

// MARK: - Floating Background Elements
struct FloatingElements: View {
    @State private var offsetY: CGFloat = 0
    @State private var offsetX: CGFloat = 0
    
    var body: some View {
        ZStack {
            ForEach(0..<6, id: \.self) { index in
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [
                            Color.white.opacity(0.1),
                            Color.cyan.opacity(0.05)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: CGFloat.random(in: 40...80),
                           height: CGFloat.random(in: 40...80))
                    .offset(
                        x: CGFloat.random(in: -200...200) + offsetX,
                        y: CGFloat.random(in: -400...400) + offsetY
                    )
                    .animation(
                        .easeInOut(duration: Double.random(in: 3...7))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...2)),
                        value: offsetY
                    )
            }
        }
        .onAppear {
            offsetY = 20
            offsetX = 10
        }
    }
}

// MARK: - Stars Background
struct StarsBackground: View {
    @State private var sparkle = false
    
    var body: some View {
        ZStack {
            ForEach(0..<20, id: \.self) { index in
                Image(systemName: "star.fill")
                    .font(.system(size: CGFloat.random(in: 8...16)))
                    .foregroundColor(.white.opacity(Double.random(in: 0.3...0.8)))
                    .position(
                        x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                        y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                    )
                    .scaleEffect(sparkle ? 1.5 : 0.5)
                    .animation(
                        .easeInOut(duration: Double.random(in: 1...3))
                        .repeatForever(autoreverses: true)
                        .delay(Double.random(in: 0...2)),
                        value: sparkle
                    )
            }
        }
        .onAppear {
            sparkle = true
        }
    }
}

// MARK: - Legacy Components (keeping for compatibility)
// MARK: - Legacy Components (keeping for compatibility)
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
