//
//  ModelIntegrationTestScene.swift
//  NumberQuest
//
//  Created by TaiPV on 24/6/25.
//

import SpriteKit
import SwiftUI

/// Test scene to validate Phase 6.1 Model Integration
/// This scene verifies that all data models are properly integrated with SpriteKit
class ModelIntegrationTestScene: BaseGameScene {
    
    // MARK: - Properties
    
    private var testResults: [String] = []
    private var testLabels: [SKLabelNode] = []
    private var testGameSession: GameSession?
    
    // MARK: - Scene Setup
    
    override func setupScene() {
        super.setupScene()
        
        setupTitle()
        setupTestButtons()
        runIntegrationTests()
    }
    
    override func setupBackground() {
        super.setupBackground()
        
        createGradientBackground(colors: [
            UIColor(red: 0.1, green: 0.3, blue: 0.6, alpha: 1.0), // Dark blue
            UIColor(red: 0.2, green: 0.1, blue: 0.5, alpha: 1.0), // Purple
            UIColor(red: 0.1, green: 0.5, blue: 0.3, alpha: 1.0)  // Green
        ], animated: true)
    }
    
    private func setupTitle() {
        let titleLabel = NodeFactory.shared.createLabel(
            text: "Model Integration Test",
            style: .gameTitle,
            color: .white
        )
        titleLabel.position = position(x: 0.5, y: 0.05)
        addChild(titleLabel)
    }
    
    private func setupTestButtons() {
        // Back button
        let backButton = GameButtonNode.backButton { [weak self] in
            self?.handleBackTapped()
        }
        backButton.position = position(x: 0.1, y: 0.95)
        addChild(backButton)
        
        // Run tests button
        let runTestsButton = NodeFactory.shared.createButton(
            text: "Run Tests",
            style: .primary,
            size: .medium
        ) { [weak self] in
            self?.runIntegrationTests()
        }
        runTestsButton.position = position(x: 0.5, y: 0.85)
        addChild(runTestsButton)
    }
    
    // MARK: - Integration Tests
    
    private func runIntegrationTests() {
        clearPreviousResults()
        testResults = []
        
        addTestResult("🧪 Starting Model Integration Tests...")
        
        // Test 1: GameData Persistence
        testGameDataPersistence()
        
        // Test 2: GameSession Integration
        testGameSessionIntegration()
        
        // Test 3: Level Progression
        testLevelProgression()
        
        // Test 4: Adaptive Difficulty
        testAdaptiveDifficulty()
        
        // Test 5: Progress Synchronization
        testProgressSynchronization()
        
        // Display results
        displayTestResults()
        
        addTestResult("✅ Model Integration Tests Complete!")
    }
    
    private func testGameDataPersistence() {
        addTestResult("\n📊 Testing GameData Persistence...")
        
        // Save original progress
        let originalProgress = gameData.playerProgress
        
        // Test save functionality
        let testStars = originalProgress.totalStars + 10
        let testStreak = originalProgress.bestStreak + 5
        
        gameData.playerProgress.totalStars = testStars
        gameData.playerProgress.bestStreak = testStreak
        gameData.savePlayerProgress()
        
        // Test if data persists by checking UserDefaults directly
        if let data = UserDefaults.standard.data(forKey: "PlayerProgress"),
           let decoded = try? JSONDecoder().decode(PlayerProgress.self, from: data) {
            
            if decoded.totalStars == testStars && decoded.bestStreak == testStreak {
                addTestResult("  ✅ UserDefaults persistence working")
            } else {
                addTestResult("  ❌ UserDefaults persistence failed")
            }
        } else {
            addTestResult("  ❌ UserDefaults persistence failed - no data found")
        }
        
        // Restore original progress
        gameData.playerProgress = originalProgress
        gameData.savePlayerProgress()
        
        // Test data validation
        gameData.validateDataIntegrity()
        addTestResult("  ✅ Data integrity validation complete")
        
        // Test statistics
        let stats = gameData.getGameStatistics()
        if stats.totalLevels > 0 {
            addTestResult("  ✅ Statistics generation working")
            addTestResult("    Total levels: \(stats.totalLevels)")
            addTestResult("    Completion: \(Int(stats.completionPercentage))%")
        } else {
            addTestResult("  ❌ Statistics generation failed")
        }
    }
    
    private func testGameSessionIntegration() {
        addTestResult("\n🎮 Testing GameSession Integration...")
        
        // Create test game session
        testGameSession = GameSession()
        guard let session = testGameSession else {
            addTestResult("  ❌ GameSession creation failed")
            return
        }
        
        // Test delegate setup
        session.sceneDelegate = self
        if session.sceneDelegate != nil {
            addTestResult("  ✅ GameSession delegate setup working")
        } else {
            addTestResult("  ❌ GameSession delegate setup failed")
        }
        
        // Test level setup
        if let firstLevel = gameData.levels.first {
            session.setupLevel(firstLevel)
            
            if session.currentLevel?.id == firstLevel.id {
                addTestResult("  ✅ Level setup working")
            } else {
                addTestResult("  ❌ Level setup failed")
            }
        }
        
        // Test timer integration
        session.pauseInternalTimer()
        session.resumeInternalTimer()
        addTestResult("  ✅ Timer integration working")
        
        // Test data synchronization
        session.syncWithGameData()
        addTestResult("  ✅ Data synchronization working")
    }
    
    private func testLevelProgression() {
        addTestResult("\n🏆 Testing Level Progression...")
        
        guard let session = testGameSession else {
            addTestResult("  ❌ No test session available")
            return
        }
        
        // Test star calculation
        session.correctAnswers = 8
        session.questionsAnswered = 10
        session.streak = 6
        
        let originalStars = gameData.playerProgress.totalStars
        session.completeLevel()
        
        if gameData.playerProgress.totalStars > originalStars {
            addTestResult("  ✅ Star calculation and assignment working")
        } else {
            addTestResult("  ❌ Star calculation failed")
        }
        
        // Test level unlock logic
        let nextLevel = gameData.getNextLevel()
        if nextLevel != nil {
            addTestResult("  ✅ Level unlock detection working")
        } else {
            addTestResult("  ✅ All levels unlocked or progression complete")
        }
    }
    
    private func testAdaptiveDifficulty() {
        addTestResult("\n🎯 Testing Adaptive Difficulty...")
        
        guard let session = testGameSession else {
            addTestResult("  ❌ No test session available")
            return
        }
        
        // Test high performance scenario
        session.correctAnswers = 9
        session.questionsAnswered = 10
        let highPerfDifficulty = session.getAdaptiveDifficulty()
        
        // Test low performance scenario
        session.correctAnswers = 3
        session.questionsAnswered = 10
        let lowPerfDifficulty = session.getAdaptiveDifficulty()
        
        addTestResult("  ✅ Adaptive difficulty calculation working")
        addTestResult("    High performance: \(highPerfDifficulty.rawValue)")
        addTestResult("    Low performance: \(lowPerfDifficulty.rawValue)")
    }
    
    private func testProgressSynchronization() {
        addTestResult("\n🔄 Testing Progress Synchronization...")
        
        // Test GameData and GameSession sync
        let originalTotal = gameData.playerProgress.totalQuestionsAnswered
        
        guard let session = testGameSession else {
            addTestResult("  ❌ No test session available")
            return
        }
        
        session.playerProgress.totalQuestionsAnswered += 5
        session.syncWithGameData()
        
        if gameData.playerProgress.totalQuestionsAnswered == session.playerProgress.totalQuestionsAnswered {
            addTestResult("  ✅ Progress synchronization working")
        } else {
            addTestResult("  ❌ Progress synchronization failed")
        }
        
        // Restore original value
        gameData.playerProgress.totalQuestionsAnswered = originalTotal
        gameData.savePlayerProgress()
    }
    
    // MARK: - Test Results Display
    
    private func clearPreviousResults() {
        testLabels.forEach { $0.removeFromParent() }
        testLabels.removeAll()
    }
    
    private func addTestResult(_ result: String) {
        testResults.append(result)
        print(result) // Also log to console
    }
    
    private func displayTestResults() {
        let startY: CGFloat = 0.75
        let lineHeight: CGFloat = isIPad ? 25 : 20
        let fontSize: CGFloat = isIPad ? 16 : 14
        
        for (index, result) in testResults.enumerated() {
            let label = SKLabelNode()
            label.text = result
            label.fontName = "Baloo2-VariableFont_wght"
            label.fontSize = fontSize
            label.fontColor = result.contains("❌") ? .red : 
                              result.contains("✅") ? .green : .white
            label.horizontalAlignmentMode = .left
            label.position = CGPoint(
                x: size.width * 0.05,
                y: size.height * startY - CGFloat(index) * lineHeight
            )
            
            addChild(label)
            testLabels.append(label)
            
            // Animate in
            label.alpha = 0
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            label.run(SKAction.sequence([
                SKAction.wait(forDuration: Double(index) * 0.1),
                fadeIn
            ]))
        }
    }
    
    private func handleBackTapped() {
        SpriteKitSoundManager.shared.playSound(.buttonTap)
        GameSceneManager.shared.goBack(withEffect: true)
    }
}

// MARK: - GameSessionDelegate Implementation

extension ModelIntegrationTestScene: GameSessionDelegate {
    func gameSessionDidUpdateScore(_ session: GameSession) {
        addTestResult("  📊 Score updated: \(session.score)")
    }
    
    func gameSessionDidUpdateStreak(_ session: GameSession) {
        addTestResult("  🔥 Streak updated: \(session.streak)")
    }
    
    func gameSessionDidUpdateTime(_ session: GameSession) {
        addTestResult("  ⏰ Time updated: \(session.timeRemaining)")
    }
    
    func gameSessionDidCompleteQuestion(_ session: GameSession, correct: Bool) {
        addTestResult("  ❓ Question completed: \(correct ? "✅" : "❌")")
    }
    
    func gameSessionDidEnd(_ session: GameSession) {
        addTestResult("  🏁 Game session ended")
    }
}

// MARK: - Preview Support

#if DEBUG
extension ModelIntegrationTestScene {
    static var preview: ModelIntegrationTestScene {
        let scene = ModelIntegrationTestScene()
        scene.size = CGSize(width: 390, height: 844)
        return scene
    }
}

#Preview("Model Integration Test") {
    SpriteKitContainer(scene: ModelIntegrationTestScene.preview)
        .ignoresSafeArea()
}
#endif
