//
//  ProgressView.swift
//  NumberQuest
//
//  Created by TaiPV on 20/6/25.
//

import SwiftUI

struct PlayerProgressView: View {
    @EnvironmentObject var gameData: GameData
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedTab = 0
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.indigo.opacity(0.3),
                    Color.purple.opacity(0.5),
                    Color.pink.opacity(0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Title
                Text("📊 Your Progress")
                    .style(.gameTitle)
                    .padding(.top, 20)
                    .padding(.bottom, 30)
                
                // Tab selector
                TabSelector(selectedTab: $selectedTab)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                
                // Content
                TabView(selection: $selectedTab) {
                    StatsTab()
                        .environmentObject(gameData)
                        .tag(0)
                    
                    BadgesTab()
                        .environmentObject(gameData)
                        .tag(1)
                    
                    AchievementsTab()
                        .environmentObject(gameData)
                        .tag(2)
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
    
    private var backButton: some View {
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }) {
            HStack {
                Image(systemName: "chevron.left")
                Text("Menu")
            }
            .foregroundColor(.white)
            .font(.headline)
        }
    }
}

struct TabSelector: View {
    @Binding var selectedTab: Int
    
    private let tabs = ["Stats", "Badges", "Goals"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<tabs.count, id: \.self) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    Text(tabs[index])
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(selectedTab == index ? .blue : .white.opacity(0.7))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(selectedTab == index ? Color.white : Color.clear)
                        )
                }
            }
        }
        .padding(4)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.2))
        )
    }
}

struct StatsTab: View {
    @EnvironmentObject var gameData: GameData
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                // Overall stats
                VStack(spacing: 20) {
                    Text("Overall Statistics")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 20) {
                        StatCard(
                            icon: "star.fill",
                            title: "Total Stars",
                            value: "\(gameData.playerProgress.totalStars)",
                            color: .yellow
                        )
                        
                        StatCard(
                            icon: "questionmark.circle.fill",
                            title: "Questions Answered",
                            value: "\(gameData.playerProgress.totalQuestionsAnswered)",
                            color: .blue
                        )
                        
                        StatCard(
                            icon: "checkmark.circle.fill",
                            title: "Correct Answers",
                            value: "\(gameData.playerProgress.correctAnswers)",
                            color: .green
                        )
                        
                        StatCard(
                            icon: "target",
                            title: "Accuracy",
                            value: String(format: "%.1f%%", gameData.playerProgress.accuracy),
                            color: .purple
                        )
                        
                        StatCard(
                            icon: "flame.fill",
                            title: "Best Streak",
                            value: "\(gameData.playerProgress.bestStreak)",
                            color: .red
                        )
                        
                        StatCard(
                            icon: "trophy.fill",
                            title: "Levels Completed",
                            value: "\(gameData.playerProgress.completedLevels.count)",
                            color: .orange
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                // Level progress
                VStack(spacing: 20) {
                    Text("Level Progress")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 15) {
                        ForEach(gameData.levels.prefix(6), id: \.id) { level in
                            LevelProgressCard(level: level)
                        }
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 100)
            }
            .padding(.top, 20)
        }
    }
}

struct StatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(20)            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.15))
            )
    }
}

struct LevelProgressCard: View {
    let level: GameLevel
    
    var body: some View {
        HStack(spacing: 15) {
            // Level icon
            ZStack {
                Circle()
                    .fill(level.isUnlocked ? Color.white.opacity(0.9) : Color.gray.opacity(0.3))
                    .frame(width: 50, height: 50)
                
                if level.isUnlocked {
                    Image(systemName: level.imageName)
                        .font(.title3)
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            
            // Level info
            VStack(alignment: .leading, spacing: 4) {
                Text(level.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(level.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .lineLimit(1)
            }
            
            Spacer()
            
            // Stars
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Image(systemName: index < level.starsEarned ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.caption)
                }
            }
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.1))
        )
    }
}

struct BadgesTab: View {
    @EnvironmentObject var gameData: GameData
    
    private let allBadges = [
        ("First Answer", "Answer your first question", "1.circle.fill"),
        ("Perfect 10", "Get 10 answers in a row", "flame.fill"),
        ("Math Master", "Earn 100 stars", "star.circle.fill"),
        ("Accuracy Expert", "Maintain 90% accuracy", "target"),
        ("Speed Demon", "Answer 50 questions in under 30 seconds", "bolt.fill"),
        ("Persistent", "Play for 7 days in a row", "calendar.badge.plus")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Badge Collection")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 20) {
                    ForEach(allBadges, id: \.0) { badge in
                        BadgeCard(
                            name: badge.0,
                            description: badge.1,
                            icon: badge.2,
                            isEarned: gameData.playerProgress.badges.contains(badge.0)
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 100)
            }
            .padding(.top, 20)
        }
    }
}

struct BadgeCard: View {
    let name: String
    let description: String
    let icon: String
    let isEarned: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(isEarned ? .yellow : .gray)
            
            Text(name)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(isEarned ? .white : .gray)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.caption)
                .foregroundColor(isEarned ? .white.opacity(0.8) : .gray.opacity(0.6))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(isEarned ? Color.yellow.opacity(0.2) : Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(isEarned ? Color.yellow.opacity(0.5) : Color.clear, lineWidth: 2)
                )
        )
        .scaleEffect(isEarned ? 1.0 : 0.95)
    }
}

struct AchievementsTab: View {
    @EnvironmentObject var gameData: GameData
    
    private var nextGoals: [String] {
        var goals: [String] = []
        
        let nextStarMilestone = ((gameData.playerProgress.totalStars / 25) + 1) * 25
        goals.append("Reach \(nextStarMilestone) stars")
        
        if gameData.playerProgress.bestStreak < 20 {
            goals.append("Achieve 20 answer streak")
        }
        
        if gameData.playerProgress.accuracy < 95 {
            goals.append("Reach 95% accuracy")
        }
        
        let unlockedLevels = gameData.levels.filter { $0.isUnlocked }.count
        if unlockedLevels < gameData.levels.count {
            goals.append("Unlock all levels")
        }
        
        return goals
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 25) {
                Text("Next Goals")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    ForEach(nextGoals, id: \.self) { goal in
                        GoalCard(goal: goal)
                    }
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 100)
            }
            .padding(.top, 20)
        }
    }
}

struct GoalCard: View {
    let goal: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "target")
                .font(.title2)
                .foregroundColor(.blue)
            
            Text(goal)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Image(systemName: "arrow.right.circle")
                .font(.title2)
                .foregroundColor(.blue.opacity(0.7))
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.15))
        )
    }
}

#Preview {
    PlayerProgressView()
        .environmentObject(GameData.shared)
}
