//
//  GameOverView.swift
//  NumberQuest
//
//  Created by TaiPV on 20/6/25.
//

import SwiftUI

struct GameOverView: View {
    @ObservedObject var gameSession: GameSession
    let gameMode: GameMode
    let level: GameLevel
    let onDismiss: () -> Void
    
    @EnvironmentObject var gameData: GameData
    @State private var showingCelebration = false
    @State private var earnedStars = 0
    @State private var newBadges: [String] = []
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.purple.opacity(0.8),
                    Color.blue.opacity(0.6),
                    Color.indigo.opacity(0.4)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Title
                Text(gameMode == .campaign ? "🏆 Level Complete!" : "⚡️ Challenge Complete!")
                    .style(.gameTitle)
                    .padding(.top, 20)
                
                // Results card
                VStack(spacing: 25) {
                    // Score and performance
                    VStack(spacing: 20) {
                        ScoreDisplay(score: gameSession.score)
                        
                        HStack(spacing: 30) {
                            ResultStat(
                                icon: "target",
                                title: "Accuracy",
                                value: "\(Int(accuracy))%",
                                color: accuracy >= 80 ? .green : accuracy >= 60 ? .orange : .red
                            )
                            
                            ResultStat(
                                icon: "flame.fill",
                                title: "Best Streak",
                                value: "\(gameSession.streak)",
                                color: .orange
                            )
                            
                            ResultStat(
                                icon: "questionmark.circle.fill",
                                title: "Answered",
                                value: "\(gameSession.questionsAnswered)",
                                color: .blue
                            )
                        }
                    }
                    
                    // Stars earned (for campaign mode)
                    if gameMode == .campaign {
                        VStack(spacing: 15) {
                            Text("Stars Earned")
                                .style(.heading)
                            
                            HStack(spacing: 10) {
                                ForEach(0..<3) { index in
                                    Image(systemName: index < earnedStars ? "star.fill" : "star")
                                        .foregroundColor(.yellow)
                                        .font(.title)
                                        .scaleEffect(showingCelebration && index < earnedStars ? 1.2 : 1.0)
                                        .animation(
                                            .spring(response: 0.5, dampingFraction: 0.6)
                                            .delay(Double(index) * 0.2),
                                            value: showingCelebration
                                        )
                                }
                            }
                        }
                    }
                    
                    // New badges
                    if !newBadges.isEmpty {
                        VStack(spacing: 10) {
                            Text("🏅 New Badges!")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            ForEach(newBadges, id: \.self) { badge in
                                Text(badge)
                                    .font(.subheadline)
                                    .foregroundColor(.yellow)
                                    .padding(.horizontal, 15)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Color.yellow.opacity(0.2))
                                    )
                            }
                        }
                    }
                }
                .padding(30)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.15))
                )
                
                Spacer()
                
                // Action buttons
                VStack(spacing: 15) {
                    if gameMode == .campaign {
                        Button(action: {
                            // Restart level
                            // This would restart the game
                        }) {
                            ActionButton(
                                title: "🔄 Try Again",
                                color: .blue
                            )
                        }
                    } else {
                        Button(action: {
                            // Start new quick play
                        }) {
                            ActionButton(
                                title: "🚀 Play Again",
                                color: .green
                            )
                        }
                    }
                    
                    Button(action: onDismiss) {
                        ActionButton(
                            title: "🏠 Back to Menu",
                            color: .gray
                        )
                    }
                }
                .padding(.horizontal, 30)
            }
            .padding(.horizontal, 20)
        }
        .onAppear {
            calculateResults()
            showingCelebration = true
        }
    }
    
    private var accuracy: Double {
        guard gameSession.questionsAnswered > 0 else { return 0 }
        return Double(gameSession.correctAnswers) / Double(gameSession.questionsAnswered) * 100
    }
    
    private func calculateResults() {
        // Calculate stars for campaign mode
        if gameMode == .campaign {
            let accuracyPercent = accuracy
            
            if accuracyPercent >= 90 {
                earnedStars = 3
            } else if accuracyPercent >= 70 {
                earnedStars = 2
            } else if accuracyPercent >= 50 {
                earnedStars = 1
            } else {
                earnedStars = 0
            }
            
            // Add stars to game data
            if earnedStars > 0 {
                gameData.addStarsToLevel(level.id, stars: earnedStars)
            }
        }
        
        // Update player progress
        gameData.playerProgress.totalQuestionsAnswered += gameSession.questionsAnswered
        gameData.playerProgress.correctAnswers += gameSession.correctAnswers
        
        if gameSession.streak > gameData.playerProgress.bestStreak {
            gameData.playerProgress.bestStreak = gameSession.streak
        }
        
        // Check for new badges
        let oldBadges = Set(gameData.playerProgress.badges)
        gameData.checkBadgeEligibility()
        let newBadgesSet = Set(gameData.playerProgress.badges).subtracting(oldBadges)
        newBadges = Array(newBadgesSet)
        
        gameData.savePlayerProgress()
    }
}

struct ScoreDisplay: View {
    let score: Int
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Final Score")
                .style(.heading)
            
            Text("\(score)")
                .style(.questionText)
        }
    }
}

struct ResultStat: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .style(.title)
            
            Text(title)
                .style(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

struct ActionButton: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .style(.buttonMedium)
            .frame(maxWidth: .infinity)
            .padding(15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(color.opacity(0.8))
                    .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
            )
    }
}

#Preview {
    // Create a preview wrapper that sets up the game session properly
    struct GameOverPreview: View {
        @StateObject private var sampleSession = GameSession()
        
        var body: some View {
            let sampleLevel = GameLevel(
                id: 1,
                name: "Test Level",
                description: "Sample level",
                requiredStars: 0,
                maxQuestions: 10,
                allowedOperations: [.addition],
                difficulty: .easy,
                isUnlocked: true,
                starsEarned: 0,
                imageName: "star.fill"
            )
            
            GameOverView(
                gameSession: sampleSession,
                gameMode: .campaign,
                level: sampleLevel,
                onDismiss: {}
            )
            .environmentObject(GameData.shared)
            .onAppear {
                // Set up sample data for preview
                sampleSession.score = 450
                sampleSession.questionsAnswered = 10
                sampleSession.correctAnswers = 8
                sampleSession.streak = 5
            }
        }
    }
    
    return GameOverPreview()
}
