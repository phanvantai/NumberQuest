//
//  QuickPlayView.swift
//  NumberQuest
//
//  Created by TaiPV on 20/6/25.
//

import SwiftUI

struct QuickPlayView: View {
    @EnvironmentObject var gameData: GameData
    @Environment(\.presentationMode) var presentationMode
    @State private var showingGame = false
    @State private var selectedDifficulty: GameDifficulty = .easy
    @State private var selectedOperations: Set<MathOperation> = [.addition]
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.orange.opacity(0.3),
                    Color.red.opacity(0.5),
                    Color.pink.opacity(0.7)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Title
                    Text("⚡️ Quick Play")
                        .style(.gameTitle)
                        .padding(.top, 20)
                    
                    Text("Jump into a fast-paced math challenge!\nDifficulty adapts to your performance.")
                        .style(.body)
                        .multilineTextAlignment(.center)
                
                // Settings
                VStack(spacing: 25) {
                    // Difficulty Selection
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Starting Difficulty")
                            .style(.heading)
                        
                        HStack(spacing: 15) {
                            ForEach(GameDifficulty.allCases, id: \.self) { difficulty in
                                DifficultyButton(
                                    difficulty: difficulty,
                                    isSelected: selectedDifficulty == difficulty
                                ) {
                                    selectedDifficulty = difficulty
                                }
                            }
                        }
                    }
                    
                    // Operations Selection
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Math Operations")
                            .style(.heading)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            ForEach(MathOperation.allCases, id: \.self) { operation in
                                OperationButton(
                                    operation: operation,
                                    isSelected: selectedOperations.contains(operation)
                                ) {
                                    if selectedOperations.contains(operation) {
                                        selectedOperations.remove(operation)
                                    } else {
                                        selectedOperations.insert(operation)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(25)            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.15))
            )
                
                // Game info
                VStack(spacing: 15) {
                    InfoRow(icon: "timer", title: "Duration", value: "60 seconds")
                    InfoRow(icon: "target", title: "Goal", value: "Answer as many as possible")
                    InfoRow(icon: "brain.head.profile", title: "AI Adaptive", value: "Difficulty adjusts automatically")
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.white.opacity(0.1))
                )
                
                // Start button
                Button(action: {
                    if !selectedOperations.isEmpty {
                        showingGame = true
                    }
                }) {
                    Text("🚀 Start Challenge")
                        .style(.buttonLarge)
                        .frame(maxWidth: .infinity)
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(selectedOperations.isEmpty ? Color.gray : Color.green.opacity(0.8))
                                .shadow(color: selectedOperations.isEmpty ? .clear : .green.opacity(0.3), 
                                       radius: 10, x: 0, y: 5)
                        )
                }
                .disabled(selectedOperations.isEmpty)
                .padding(.horizontal, 30)
                
                if selectedOperations.isEmpty {
                    Text("Please select at least one operation")
                        .style(.caption)
                }
                
                // Add bottom padding to ensure content is not cut off
                Spacer(minLength: 100)
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
        .sheet(isPresented: $showingGame) {
            let customLevel = GameLevel(
                id: 0,
                name: "Quick Play",
                description: "Adaptive Challenge",
                requiredStars: 0,
                maxQuestions: 999,
                allowedOperations: Array(selectedOperations),
                difficulty: selectedDifficulty,
                isUnlocked: true,
                starsEarned: 0,
                imageName: "bolt.fill"
            )
            
            GameView(gameMode: .quickPlay, level: customLevel)
                .environmentObject(gameData)
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

struct DifficultyButton: View {
    let difficulty: GameDifficulty
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(difficulty.rawValue)
                    .style(.buttonMedium)
                    .foregroundColor(isSelected ? .blue : .white)
                
                Text("\(difficulty.range.min)-\(difficulty.range.max)")
                    .style(.caption)
                    .foregroundColor(isSelected ? .blue : .white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white : Color.white.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
            )
        }
    }
}

struct OperationButton: View {
    let operation: MathOperation
    let isSelected: Bool
    let action: () -> Void
    
    var operationName: String {
        switch operation {
        case .addition: return "Addition"
        case .subtraction: return "Subtraction"
        case .multiplication: return "Multiplication"
        case .division: return "Division"
        }
    }
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(operation.symbol)
                    .style(.title)
                    .foregroundColor(isSelected ? .blue : .white)
                
                Text(operationName)
                    .style(.caption)
                    .foregroundColor(isSelected ? .blue : .white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 15)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.white : Color.white.opacity(0.2))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.white.opacity(0.5), lineWidth: 1)
                    )
            )
        }
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 25)
            
            Text(title)
                .style(.body)
            
            Spacer()
            
            Text(value)
                .style(.bodySecondary)
        }
    }
}

#Preview {
    QuickPlayView()
        .environmentObject(GameData.shared)
}
