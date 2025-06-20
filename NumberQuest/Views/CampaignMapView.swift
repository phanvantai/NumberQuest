//
//  CampaignMapView.swift
//  NumberQuest
//
//  Created by TaiPV on 20/6/25.
//

import SwiftUI

struct CampaignMapView: View {
    @EnvironmentObject var gameData: GameData
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedLevel: GameLevel?
    @State private var showingLevelDetail = false
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.cyan.opacity(0.3),
                    Color.blue.opacity(0.5),
                    Color.indigo.opacity(0.7)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 40) {
                    // Title
                    Text("🗺️ Adventure Map")
                        .style(.gameTitle)
                        .padding(.top, 20)
                    
                    // Levels
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 30) {
                        ForEach(gameData.levels, id: \.id) { level in
                            LevelCard(level: level) {
                                if level.isUnlocked {
                                    selectedLevel = level
                                    showingLevelDetail = true
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Spacer(minLength: 100)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .sheet(isPresented: $showingLevelDetail) {
            if let level = selectedLevel {
                LevelDetailView(level: level)
                    .environmentObject(gameData)
            }
        }
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

struct LevelCard: View {
    let level: GameLevel
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 15) {
                // Level icon
                ZStack {
                    Circle()
                        .fill(level.isUnlocked ? Color.white.opacity(0.9) : Color.gray.opacity(0.5))
                        .frame(width: 80, height: 80)
                    
                    if level.isUnlocked {
                        Image(systemName: level.imageName)
                            .font(.system(size: 30))
                            .foregroundColor(.blue)
                    } else {
                        Image(systemName: "lock.fill")
                            .font(.system(size: 25))
                            .foregroundColor(.gray)
                    }
                }
                
                // Level info
                VStack(spacing: 8) {
                    Text(level.name)
                        .style(.heading)
                        .foregroundColor(level.isUnlocked ? .white : .gray)
                        .multilineTextAlignment(.center)
                    
                    if level.isUnlocked {
                        Text(level.description)
                            .style(.caption)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        
                        // Stars display
                        HStack(spacing: 4) {
                            ForEach(0..<3) { index in
                                Image(systemName: index < level.starsEarned ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                            }
                        }
                    } else {
                        Text("Requires \(level.requiredStars) ⭐")
                            .style(.caption)
                            .foregroundColor(.gray)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(level.isUnlocked ? 
                          Color.white.opacity(0.15) : 
                          Color.black.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(level.isUnlocked ? Color.white.opacity(0.3) : Color.clear, lineWidth: 1)
            )
            .scaleEffect(level.isUnlocked ? 1.0 : 0.9)
            .opacity(level.isUnlocked ? 1.0 : 0.6)
        }
        .disabled(!level.isUnlocked)
    }
}

struct LevelDetailView: View {
    let level: GameLevel
    @EnvironmentObject var gameData: GameData
    @Environment(\.presentationMode) var presentationMode
    @State private var showingGame = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.3),
                        Color.purple.opacity(0.5)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Level icon and name
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.9))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: level.imageName)
                                .font(.system(size: 50))
                                .foregroundColor(.blue)
                        }
                        
                        Text(level.name)
                            .style(.gameTitle)
                    }
                    
                    // Level details
                    VStack(spacing: 20) {
                        DetailCard(
                            title: "Description",
                            content: level.description,
                            icon: "text.alignleft"
                        )
                        
                        DetailCard(
                            title: "Operations",
                            content: level.allowedOperations.map { $0.rawValue }.joined(separator: ", "),
                            icon: "function"
                        )
                        
                        DetailCard(
                            title: "Difficulty",
                            content: level.difficulty.rawValue,
                            icon: "chart.bar.fill"
                        )
                        
                        DetailCard(
                            title: "Questions",
                            content: "\(level.maxQuestions) questions",
                            icon: "questionmark.circle.fill"
                        )
                    }
                    
                    // Stars earned
                    VStack(spacing: 10) {
                        Text("Stars Earned")
                            .style(.heading)
                        
                        HStack(spacing: 8) {
                            ForEach(0..<3) { index in
                                Image(systemName: index < level.starsEarned ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .font(.title2)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    // Start button
                    Button(action: {
                        showingGame = true
                    }) {
                        Text("🚀 Start Adventure")
                            .style(.buttonLarge)
                            .frame(maxWidth: .infinity)
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.green.opacity(0.8))
                                    .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
                            )
                    }
                    .padding(.horizontal, 30)
                }
                .padding(.horizontal, 20)
            }
            .navigationBarItems(
                leading: Button("Back") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            )
            .navigationBarTitle("", displayMode: .inline)
        }
        .sheet(isPresented: $showingGame) {
            GameView(gameMode: .campaign, level: level)
                .environmentObject(gameData)
        }
    }
}

struct DetailCard: View {
    let title: String
    let content: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(content)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(15)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.9))
        )
    }
}

#Preview {
    CampaignMapView()
        .environmentObject(GameData.shared)
}
