//
//  GameModels.swift
//  NumberQuest
//
//  Created by TaiPV on 20/6/25.
//

import Foundation

// MARK: - Game Difficulty
enum GameDifficulty: String, CaseIterable {
    case easy = "Easy"
    case medium = "Medium"
    case hard = "Hard"
    
    var range: (min: Int, max: Int) {
        switch self {
        case .easy: return (1, 10)
        case .medium: return (1, 50)
        case .hard: return (1, 100)
        }
    }
}

// MARK: - Math Operations
enum MathOperation: String, CaseIterable {
    case addition = "+"
    case subtraction = "-"
    case multiplication = "×"
    case division = "÷"
    
    var symbol: String {
        return self.rawValue
    }
}

// MARK: - Game Mode
enum GameMode {
    case campaign
    case quickPlay
}

// MARK: - Question Model
struct MathQuestion {
    let id = UUID()
    let operation: MathOperation
    let firstNumber: Int
    let secondNumber: Int
    let correctAnswer: Int
    let wrongAnswers: [Int]
    let difficulty: GameDifficulty
    
    var questionText: String {
        return "\(firstNumber) \(operation.symbol) \(secondNumber) = ?"
    }
    
    var allAnswers: [Int] {
        return ([correctAnswer] + wrongAnswers).shuffled()
    }
}

// MARK: - Level Model
struct GameLevel {
    let id: Int
    let name: String
    let description: String
    let requiredStars: Int
    let maxQuestions: Int
    let allowedOperations: [MathOperation]
    let difficulty: GameDifficulty
    let isUnlocked: Bool
    let starsEarned: Int
    let imageName: String
}

// MARK: - Player Progress
struct PlayerProgress: Codable {
    var totalStars: Int = 0
    var currentLevel: Int = 1
    var completedLevels: Set<Int> = []
    var totalQuestionsAnswered: Int = 0
    var correctAnswers: Int = 0
    var streak: Int = 0
    var bestStreak: Int = 0
    var badges: [String] = []
    
    var accuracy: Double {
        guard totalQuestionsAnswered > 0 else { return 0.0 }
        return Double(correctAnswers) / Double(totalQuestionsAnswered) * 100
    }
}

// MARK: - Game Session
class GameSession: ObservableObject {
    @Published var currentQuestion: MathQuestion?
    @Published var score: Int = 0
    @Published var streak: Int = 0
    @Published var questionsAnswered: Int = 0
    @Published var correctAnswers: Int = 0
    @Published var timeRemaining: Int = 0
    @Published var isGameActive: Bool = false
    @Published var gameMode: GameMode = .quickPlay
    @Published var currentLevel: GameLevel?
    @Published var playerProgress = PlayerProgress()
    
    private var timer: Timer?
    private var questionGenerator = QuestionGenerator()
    
    func setupLevel(_ level: GameLevel) {
        currentLevel = level
        gameMode = .campaign
        
        // Initialize game state
        score = 0
        streak = 0
        questionsAnswered = 0
        correctAnswers = 0
        isGameActive = false
        
        // No timer for campaign mode (it's question-based)
        timeRemaining = 0
        
        // Generate first question
        generateNewQuestion()
    }
    
    func startGame(mode: GameMode, level: GameLevel? = nil) {
        gameMode = mode
        currentLevel = level
        score = 0
        streak = 0
        questionsAnswered = 0
        correctAnswers = 0
        isGameActive = true
        
        if mode == .quickPlay {
            timeRemaining = 60 // 1 minute for quick play
            startTimer()
        }
        
        generateNewQuestion()
    }
    
    func generateNewQuestion() {
        let difficulty: GameDifficulty
        let operations: [MathOperation]
        
        if let level = currentLevel {
            difficulty = level.difficulty
            operations = level.allowedOperations
        } else {
            // Dynamic difficulty for quick play
            difficulty = getDynamicDifficulty()
            operations = getOperationsForDifficulty(difficulty)
        }
        
        currentQuestion = questionGenerator.generateQuestion(
            difficulty: difficulty,
            operations: operations
        )
    }
    
    func submitAnswer(_ answer: Int) {
        guard let question = currentQuestion else { return }
        
        questionsAnswered += 1
        playerProgress.totalQuestionsAnswered += 1
        
        if answer == question.correctAnswer {
            correctAnswers += 1
            playerProgress.correctAnswers += 1
            streak += 1
            score += getPointsForAnswer()
            
            if streak > playerProgress.bestStreak {
                playerProgress.bestStreak = streak
            }
        } else {
            streak = 0
        }
        
        // Generate next question
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.generateNewQuestion()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.endGame()
            }
        }
    }
    
    func endGame() {
        timer?.invalidate()
        timer = nil
        isGameActive = false
        saveProgress()
    }
    
    private func getDynamicDifficulty() -> GameDifficulty {
        let accuracy = Double(correctAnswers) / max(Double(questionsAnswered), 1.0)
        
        if accuracy > 0.8 && streak > 3 {
            return .hard
        } else if accuracy > 0.6 || streak > 1 {
            return .medium
        } else {
            return .easy
        }
    }
    
    private func getOperationsForDifficulty(_ difficulty: GameDifficulty) -> [MathOperation] {
        switch difficulty {
        case .easy:
            return [.addition, .subtraction]
        case .medium:
            return [.addition, .subtraction, .multiplication]
        case .hard:
            return MathOperation.allCases
        }
    }
    
    func getPointsForAnswer() -> Int {
        let basePoints = 10
        let streakBonus = min(streak * 2, 20)
        let difficultyMultiplier = currentQuestion?.difficulty == .hard ? 3 : 
                                 currentQuestion?.difficulty == .medium ? 2 : 1
        
        return (basePoints + streakBonus) * difficultyMultiplier
    }
    
    private func saveProgress() {
        // Save to UserDefaults or Core Data
        if let encoded = try? JSONEncoder().encode(playerProgress) {
            UserDefaults.standard.set(encoded, forKey: "PlayerProgress")
        }
    }
    
    func loadProgress() {
        if let data = UserDefaults.standard.data(forKey: "PlayerProgress"),
           let decoded = try? JSONDecoder().decode(PlayerProgress.self, from: data) {
            playerProgress = decoded
        }
    }
    
    func pauseInternalTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func resumeInternalTimer() {
        if gameMode == .quickPlay && isGameActive {
            startTimer()
        }
    }
}

// MARK: - Question Generator
class QuestionGenerator {
    func generateQuestion(difficulty: GameDifficulty, operations: [MathOperation]) -> MathQuestion {
        let operation = operations.randomElement() ?? .addition
        let range = difficulty.range
        
        var firstNumber: Int
        var secondNumber: Int
        var correctAnswer: Int
        
        switch operation {
        case .addition:
            firstNumber = Int.random(in: range.min...range.max)
            secondNumber = Int.random(in: range.min...range.max)
            correctAnswer = firstNumber + secondNumber
            
        case .subtraction:
            firstNumber = Int.random(in: range.min...range.max)
            secondNumber = Int.random(in: range.min...min(firstNumber, range.max))
            correctAnswer = firstNumber - secondNumber
            
        case .multiplication:
            firstNumber = Int.random(in: range.min...min(range.max, 12))
            secondNumber = Int.random(in: range.min...min(range.max, 12))
            correctAnswer = firstNumber * secondNumber
            
        case .division:
            // Ensure division results in whole numbers
            correctAnswer = Int.random(in: range.min...range.max)
            secondNumber = Int.random(in: 2...min(range.max, 12))
            firstNumber = correctAnswer * secondNumber
        }
        
        let wrongAnswers = generateWrongAnswers(correctAnswer: correctAnswer, difficulty: difficulty)
        
        return MathQuestion(
            operation: operation,
            firstNumber: firstNumber,
            secondNumber: secondNumber,
            correctAnswer: correctAnswer,
            wrongAnswers: wrongAnswers,
            difficulty: difficulty
        )
    }
    
    private func generateWrongAnswers(correctAnswer: Int, difficulty: GameDifficulty) -> [Int] {
        var wrongAnswers: [Int] = []
        let variance = difficulty == .easy ? 5 : difficulty == .medium ? 10 : 20
        
        while wrongAnswers.count < 3 {
            let wrongAnswer = correctAnswer + Int.random(in: -variance...variance)
            if wrongAnswer != correctAnswer && wrongAnswer > 0 && !wrongAnswers.contains(wrongAnswer) {
                wrongAnswers.append(wrongAnswer)
            }
        }
        
        return wrongAnswers
    }
}
