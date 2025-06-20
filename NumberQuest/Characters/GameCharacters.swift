//
//  GameCharacters.swift
//  NumberQuest
//
//  Created by TaiPV on 20/6/25.
//

import SwiftUI

struct GameCharacter {
    let name: String
    let emoji: String
    let encouragements: [String]
    let celebrations: [String]
}

class CharacterManager: ObservableObject {
    static let shared = CharacterManager()
    
    private let characters = [
        GameCharacter(
            name: "Mathly",
            emoji: "🤖",
            encouragements: [
                "You're doing great!",
                "Keep going, champion!",
                "Math magic in action!",
                "You've got this!",
                "Fantastic work!"
            ],
            celebrations: [
                "Amazing! You're a math superstar!",
                "Incredible! You solved it perfectly!",
                "Wow! Your math skills are growing!",
                "Brilliant! Keep up the excellent work!",
                "Outstanding! You're getting stronger!"
            ]
        ),
        GameCharacter(
            name: "Professor Owl",
            emoji: "🦉",
            encouragements: [
                "Think it through step by step!",
                "You're learning so well!",
                "Math is an adventure!",
                "Every mistake helps you learn!",
                "You're becoming wiser!"
            ],
            celebrations: [
                "Wise choice! Excellent thinking!",
                "Brilliant deduction, young scholar!",
                "Your mathematical wisdom grows!",
                "Splendid work, my dear student!",
                "You've mastered this concept!"
            ]
        ),
        GameCharacter(
            name: "Number Dragon",
            emoji: "🐲",
            encouragements: [
                "Show those numbers who's boss!",
                "You have the power of math!",
                "Channel your inner mathematician!",
                "You're stronger than any equation!",
                "Math courage is your strength!"
            ],
            celebrations: [
                "You've conquered this challenge!",
                "Victory! Your math power is mighty!",
                "Legendary! You defeated that problem!",
                "Epic! Your skills are growing stronger!",
                "Triumphant! Nothing can stop you!"
            ]
        )
    ]
    
    @Published var currentCharacter: GameCharacter
    
    private init() {
        currentCharacter = characters.randomElement() ?? characters[0]
    }
    
    func getEncouragement() -> String {
        return currentCharacter.encouragements.randomElement() ?? "Keep going!"
    }
    
    func getCelebration() -> String {
        return currentCharacter.celebrations.randomElement() ?? "Great job!"
    }
    
    func switchCharacter() {
        currentCharacter = characters.randomElement() ?? characters[0]
    }
    
    func getCharacterEmoji() -> String {
        return currentCharacter.emoji
    }
    
    func getCharacterName() -> String {
        return currentCharacter.name
    }
}

// Character display view for the game
struct CharacterView: View {
    @StateObject private var characterManager = CharacterManager.shared
    let message: String
    let isHappy: Bool
    
    var body: some View {
        VStack(spacing: 10) {
            // Character emoji with animation
            Text(characterManager.getCharacterEmoji())
                .font(.system(size: 50))
                .scaleEffect(isHappy ? 1.2 : 1.0)
                .animation(.bouncy, value: isHappy)
            
            // Character name
            Text(characterManager.getCharacterName())
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            // Message bubble
            Text(message)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 15)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isHappy ? Color.green.opacity(0.8) : Color.blue.opacity(0.8))
                        .overlay(
                            // Speech bubble tail
                            Triangle()
                                .fill(isHappy ? Color.green.opacity(0.8) : Color.blue.opacity(0.8))
                                .frame(width: 15, height: 10)
                                .rotationEffect(.degrees(180))
                                .offset(y: 15)
                        )
                )
                .multilineTextAlignment(.center)
        }
        .padding()
        .onAppear {
            // Add subtle floating animation
            withAnimation(
                .easeInOut(duration: 2)
                .repeatForever(autoreverses: true)
            ) {
                // Could add floating effect here
            }
        }
    }
}

// Triangle shape for speech bubble
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

// Motivational messages for different game states
extension CharacterManager {
    func getWelcomeMessage() -> String {
        let welcomes = [
            "Welcome to NumberQuest!",
            "Ready for a math adventure?",
            "Let's explore the world of numbers!",
            "Time to show off your math skills!",
            "Adventure awaits, math hero!"
        ]
        return welcomes.randomElement() ?? "Welcome!"
    }
    
    func getStreakMessage(streak: Int) -> String {
        if streak >= 10 {
            return "🔥 You're on fire! \(streak) in a row!"
        } else if streak >= 5 {
            return "⭐ Amazing streak! Keep it up!"
        } else if streak >= 3 {
            return "🚀 Great momentum building!"
        } else {
            return getEncouragement()
        }
    }
    
    func getGameOverMessage(score: Int, accuracy: Double) -> String {
        if accuracy >= 90 {
            return "Perfect! You're a math genius!"
        } else if accuracy >= 70 {
            return "Excellent work! You're improving!"
        } else if score > 0 {
            return "Good effort! Practice makes perfect!"
        } else {
            return "Every expert was once a beginner!"
        }
    }
}
