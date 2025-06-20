//
//  GameView.swift
//  NumberQuest
//
//  Created by TaiPV on 20/6/25.
//

import SwiftUI

struct GameView: View {
    let gameMode: GameMode
    let level: GameLevel
    
    @EnvironmentObject var gameData: GameData
    @StateObject private var gameSession = GameSession()
    @Environment(\.presentationMode) var presentationMode
    
    @State private var selectedAnswer: Int?
    @State private var showingResult = false
    @State private var isCorrect = false
    @State private var showingGameOver = false
    @State private var animateAnswer = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.mint.opacity(0.4),
                        Color.cyan.opacity(0.6),
                        Color.blue.opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    GameHeader(gameSession: gameSession, gameMode: gameMode, level: level)
                    
                    if let question = gameSession.currentQuestion {
                        // Question Display
                        QuestionCard(question: question)
                        
                        // Answer Options
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 20) {
                            ForEach(question.allAnswers, id: \.self) { answer in
                                AnswerButton(
                                    answer: answer,
                                    isSelected: selectedAnswer == answer,
                                    isCorrect: showingResult ? answer == question.correctAnswer : nil,
                                    isWrong: showingResult ? selectedAnswer == answer && answer != question.correctAnswer : nil
                                ) {
                                    selectAnswer(answer)
                                }
                                .disabled(showingResult)
                            }
                        }
                        .padding(.horizontal, 20)
                        
                    } else {
                        // Loading state
                        VStack(spacing: 20) {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(1.5)
                            
                            Text("Preparing your question...")
                                .style(.heading)
                        }
                    }
                    
                    Spacer()
                    
                    // Encouragement text
                    if gameSession.streak > 0 {
                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Text("Streak: \(gameSession.streak) 🔥")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .padding()
                        .background(
                            Capsule()
                                .fill(Color.orange.opacity(0.3))
                        )
                    }
                }
                .padding(.horizontal, 20)
                
                // Result overlay
                if showingResult {
                    ResultOverlay(isCorrect: isCorrect)
                        .opacity(animateAnswer ? 1 : 0)
                        .scaleEffect(animateAnswer ? 1 : 0.5)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: animateAnswer)
                }
            }
            .navigationBarItems(
                leading: Button("Quit") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            )
            .navigationBarTitle("", displayMode: .inline)
        }
        .onAppear {
            gameSession.startGame(mode: gameMode, level: level)
        }
        .onReceive(gameSession.$isGameActive) { isActive in
            if !isActive && gameSession.questionsAnswered > 0 {
                showingGameOver = true
            }
        }
        .sheet(isPresented: $showingGameOver) {
            GameOverView(
                gameSession: gameSession,
                gameMode: gameMode,
                level: level
            ) {
                presentationMode.wrappedValue.dismiss()
            }
            .environmentObject(gameData)
        }
    }
    
    private func selectAnswer(_ answer: Int) {
        guard !showingResult else { return }
        
        selectedAnswer = answer
        isCorrect = answer == gameSession.currentQuestion?.correctAnswer
        showingResult = true
        animateAnswer = true
        
        // Submit answer after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            gameSession.submitAnswer(answer)
            resetForNextQuestion()
        }
    }
    
    private func resetForNextQuestion() {
        selectedAnswer = nil
        showingResult = false
        animateAnswer = false
    }
}

struct GameHeader: View {
    @ObservedObject var gameSession: GameSession
    let gameMode: GameMode
    let level: GameLevel
    
    var body: some View {
        VStack(spacing: 15) {
            // Level/Mode title
            Text(level.name)
                .style(.title)
            
            // Stats row
            HStack(spacing: 30) {
                if gameMode == .quickPlay {
                    StatBadge(
                        icon: "timer",
                        value: "\(gameSession.timeRemaining)s",
                        color: gameSession.timeRemaining <= 10 ? .red : .blue
                    )
                } else {
                    StatBadge(
                        icon: "questionmark.circle",
                        value: "\(gameSession.questionsAnswered)/\(level.maxQuestions)",
                        color: .blue
                    )
                }
                
                StatBadge(
                    icon: "star.fill",
                    value: "\(gameSession.score)",
                    color: .yellow
                )
                
                StatBadge(
                    icon: "target",
                    value: "\(gameSession.correctAnswers)/\(gameSession.questionsAnswered)",
                    color: .green
                )
            }
        }
        .padding(.top, 20)
    }
}

struct StatBadge: View {
    let icon: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundColor(color)
            
            Text(value)
                .style(.caption)
                .fontWeight(.bold)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            Capsule()
                .fill(Color.white.opacity(0.2))
        )
    }
}

struct QuestionCard: View {
    let question: MathQuestion
    
    var body: some View {
        VStack(spacing: 20) {
            Text("What is")
                .style(.bodySecondary)
            
            Text(question.questionText)
                .style(.questionText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(30)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.15))
        )
    }
}

struct AnswerButton: View {
    let answer: Int
    let isSelected: Bool
    let isCorrect: Bool?
    let isWrong: Bool?
    let action: () -> Void
    
    private var backgroundColor: Color {
        if let isCorrect = isCorrect, isCorrect {
            return .green
        } else if let isWrong = isWrong, isWrong {
            return .red
        } else if isSelected {
            return .blue
        } else {
            return .white.opacity(0.2)
        }
    }
    
    private var textColor: Color {
        if isCorrect == true || isWrong == true || isSelected {
            return .white
        } else {
            return .white
        }
    }
    
    var body: some View {
        Button(action: action) {
            Text("\(answer)")
                .style(.answerText)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(backgroundColor)
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(Color.white.opacity(0.3), lineWidth: 2)
                        )
                )
        }
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isCorrect)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isWrong)
    }
}

struct ResultOverlay: View {
    let isCorrect: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Text(isCorrect ? "🎉" : "😅")
                .font(.system(size: 80))
            
            Text(isCorrect ? "Correct!" : "Not quite!")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(isCorrect ? "Great job!" : "Keep trying!")
                .font(.headline)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 25)
                .fill(isCorrect ? Color.green.opacity(0.9) : Color.orange.opacity(0.9))
        )
    }
}

#Preview {
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
    
    GameView(gameMode: .campaign, level: sampleLevel)
        .environmentObject(GameData.shared)
}
