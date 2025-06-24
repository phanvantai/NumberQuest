//
//  SettingsScene.swift
//  NumberQuest
//
//  Created by NumberQuest on 2024.
//

import SpriteKit

/// Settings scene with sound/music controls, graphics quality options, and accessibility settings
class SettingsScene: BaseGameScene {
    
    // MARK: - Properties
    private var settingsContainer: SKNode!
    private var scrollContainer: SKNode!
    private var backgroundNode: SKSpriteNode!
    
    // Settings state
    private var soundEnabled: Bool {
        get { SoundManager.shared.isSoundEnabled }
        set { 
            SoundManager.shared.isSoundEnabled = newValue
            SoundManager.shared.savePreferences()
            updateSoundToggle()
        }
    }
    
    private var musicEnabled: Bool {
        get { SoundManager.shared.isMusicEnabled }
        set { 
            SoundManager.shared.isMusicEnabled = newValue
            SoundManager.shared.savePreferences()
            updateMusicToggle()
        }
    }
    
    private var hapticEnabled: Bool {
        get { UserDefaults.standard.bool(forKey: "HapticEnabled") }
        set { 
            UserDefaults.standard.set(newValue, forKey: "HapticEnabled")
            updateHapticToggle()
        }
    }
    
    private var graphicsQuality: GraphicsQuality {
        get { 
            let rawValue = UserDefaults.standard.integer(forKey: "GraphicsQuality")
            return GraphicsQuality(rawValue: rawValue) ?? .high
        }
        set { 
            UserDefaults.standard.set(newValue.rawValue, forKey: "GraphicsQuality")
            updateGraphicsQualityDisplay()
            applyGraphicsQualitySettings()
        }
    }
    
    private var accessibilityFontSize: AccessibilityFontSize {
        get {
            let rawValue = UserDefaults.standard.integer(forKey: "AccessibilityFontSize")
            return AccessibilityFontSize(rawValue: rawValue) ?? .normal
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: "AccessibilityFontSize")
            updateAccessibilityFontDisplay()
            applyAccessibilitySettings()
        }
    }
    
    private var reducedMotion: Bool {
        get { UserDefaults.standard.bool(forKey: "ReducedMotion") }
        set { 
            UserDefaults.standard.set(newValue, forKey: "ReducedMotion")
            updateReducedMotionToggle()
            applyAccessibilitySettings()
        }
    }
    
    // UI Elements
    private var backButton: GameButtonNode!
    private var titleLabel: SKLabelNode!
    
    // Audio section
    private var audioSectionLabel: SKLabelNode!
    private var soundToggleButton: GameButtonNode!
    private var musicToggleButton: GameButtonNode!
    private var volumeSlider: SliderNode!
    
    // Graphics section
    private var graphicsSectionLabel: SKLabelNode!
    private var graphicsQualityButton: GameButtonNode!
    private var particleEffectsToggle: GameButtonNode!
    
    // Gameplay section
    private var gameplaySectionLabel: SKLabelNode!
    private var hapticToggleButton: GameButtonNode!
    private var difficultyResetButton: GameButtonNode!
    
    // Accessibility section
    private var accessibilitySectionLabel: SKLabelNode!
    private var fontSizeButton: GameButtonNode!
    private var reducedMotionToggle: GameButtonNode!
    private var highContrastToggle: GameButtonNode!
    
    // Data section
    private var dataSectionLabel: SKLabelNode!
    private var resetProgressButton: GameButtonNode!
    private var exportProgressButton: GameButtonNode!
    
    // MARK: - Scene Lifecycle
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setupScene()
        setupUI()
        loadSettings()
    }
    
    // MARK: - Setup
    
    override func setupScene() {
        super.setupScene()
        
        // Main container
        settingsContainer = SKNode()
        addChild(settingsContainer)
        
        // Scroll container for settings content
        scrollContainer = SKNode()
        settingsContainer.addChild(scrollContainer)
    }
    
    override func setupBackground() {
        super.setupBackground()
        createGradientBackground(colors: [
            UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0),  // Blue
            UIColor(red: 0.4, green: 0.2, blue: 0.8, alpha: 1.0)   // Purple
        ])
    }
    
    override func setupUI() {
        setupHeader()
        setupAudioSection()
        setupGraphicsSection()
        setupGameplaySection()
        setupAccessibilitySection()
        setupDataSection()
        layoutSections()
    }
    
    private func setupHeader() {
        // Back button
        backButton = NodeFactory.shared.createButton(
            text: "← Back",
            style: .secondary,
            size: .medium
        ) { [weak self] in
            self?.handleBackButton()
        }
        backButton?.position = position(x: 0.15, y: 0.9)
        if let backButton = backButton {
            settingsContainer.addChild(backButton)
        }
        
        // Title
        titleLabel = NodeFactory.shared.createLabel(
            text: "⚙️ Settings",
            style: .gameTitle,
            color: .white
        )
        titleLabel.position = position(x: 0.5, y: 0.9)
        settingsContainer.addChild(titleLabel)
    }
    
    private func setupAudioSection() {
        // Section header
        audioSectionLabel = NodeFactory.shared.createLabel(
            text: "🔊 Audio Settings",
            style: .title,
            color: .white
        )
        
        // Sound toggle
        soundToggleButton = NodeFactory.shared.createButton(
            text: "Sound Effects: ON",
            style: .toggle,
            size: .large
        ) { [weak self] in
            self?.toggleSound()
        }
        
        // Music toggle
        musicToggleButton = NodeFactory.shared.createButton(
            text: "Background Music: ON",
            style: .toggle,
            size: .large
        ) { [weak self] in
            self?.toggleMusic()
        }
        
        // Volume slider (visual representation)
        volumeSlider = SliderNode(width: 250, height: 30, value: 0.8)
        
        // Add to scroll container (positioning will be done in layoutSections)
        if let soundButton = soundToggleButton, let musicButton = musicToggleButton {
            [audioSectionLabel, soundButton, musicButton].forEach {
                scrollContainer.addChild($0)
            }
        }
        scrollContainer.addChild(volumeSlider)
    }
    
    private func setupGraphicsSection() {
        // Section header
        graphicsSectionLabel = NodeFactory.shared.createLabel(
            text: "🎨 Graphics Settings",
            style: .title,
            color: .white
        )
        
        // Graphics quality selector
        graphicsQualityButton = NodeFactory.shared.createButton(
            text: "Graphics Quality: High",
            style: .selector,
            size: .large
        ) { [weak self] in
            self?.selectGraphicsQuality()
        }
        
        // Particle effects toggle
        particleEffectsToggle = NodeFactory.shared.createButton(
            text: "Particle Effects: ON",
            style: .toggle,
            size: .large
        ) { [weak self] in
            self?.toggleParticleEffects()
        }
        
        if let qualityButton = graphicsQualityButton, let particleButton = particleEffectsToggle {
            [graphicsSectionLabel, qualityButton, particleButton].forEach {
                scrollContainer.addChild($0)
            }
        }
    }
    
    private func setupGameplaySection() {
        // Section header
        gameplaySectionLabel = NodeFactory.shared.createLabel(
            text: "🎮 Gameplay Settings",
            style: .title,
            color: .white
        )
        
        // Haptic feedback toggle
        hapticToggleButton = NodeFactory.shared.createButton(
            text: "Haptic Feedback: ON",
            style: .toggle,
            size: .large
        ) { [weak self] in
            self?.toggleHapticFeedback()
        }
        
        // Difficulty reset
        difficultyResetButton = NodeFactory.shared.createButton(
            text: "Reset Adaptive Difficulty",
            style: .secondary,
            size: .large
        ) { [weak self] in
            self?.resetAdaptiveDifficulty()
        }
        
        if let hapticButton = hapticToggleButton, let difficultyButton = difficultyResetButton {
            [gameplaySectionLabel, hapticButton, difficultyButton].forEach {
                scrollContainer.addChild($0)
            }
        }
    }
    
    private func setupAccessibilitySection() {
        // Section header
        accessibilitySectionLabel = NodeFactory.shared.createLabel(
            text: "♿ Accessibility Settings",
            style: .title,
            color: .white
        )
        
        // Font size selector
        fontSizeButton = NodeFactory.shared.createButton(
            text: "Font Size: Normal",
            style: .selector,
            size: .large
        ) { [weak self] in
            self?.selectFontSize()
        }
        
        // Reduced motion toggle
        reducedMotionToggle = NodeFactory.shared.createButton(
            text: "Reduced Motion: OFF",
            style: .toggle,
            size: .large
        ) { [weak self] in
            self?.toggleReducedMotion()
        }
        
        // High contrast toggle
        highContrastToggle = NodeFactory.shared.createButton(
            text: "High Contrast: OFF",
            style: .toggle,
            size: .large
        ) { [weak self] in
            self?.toggleHighContrast()
        }
        
        if let fontButton = fontSizeButton, let motionButton = reducedMotionToggle, let contrastButton = highContrastToggle {
            [accessibilitySectionLabel, fontButton, motionButton, contrastButton].forEach {
                scrollContainer.addChild($0)
            }
        }
    }
    
    private func setupDataSection() {
        // Section header
        dataSectionLabel = NodeFactory.shared.createLabel(
            text: "💾 Data Management",
            style: .title,
            color: .white
        )
        
        // Reset progress button
        resetProgressButton = NodeFactory.shared.createButton(
            text: "Reset All Progress",
            style: .destructive,
            size: .large
        ) { [weak self] in
            self?.resetAllProgress()
        }
        
        // Export progress button
        exportProgressButton = NodeFactory.shared.createButton(
            text: "Export Progress Data",
            style: .secondary,
            size: .large
        ) { [weak self] in
            self?.exportProgressData()
        }
        
        if let resetButton = resetProgressButton, let exportButton = exportProgressButton {
            [dataSectionLabel, resetButton, exportButton].forEach {
                scrollContainer.addChild($0)
            }
        }
    }
    
    private func layoutSections() {
        let sectionSpacing: CGFloat = 0.12
        let itemSpacing: CGFloat = 0.05
        var yPos: CGFloat = 0.75
        
        // Audio section
        audioSectionLabel.position = position(x: 0.2, y: yPos)
        yPos -= 0.06
        
        soundToggleButton?.position = position(x: 0.5, y: yPos)
        yPos -= (0.08 + itemSpacing)
        
        musicToggleButton?.position = position(x: 0.5, y: yPos)
        yPos -= (0.08 + itemSpacing)
        
        volumeSlider.position = position(x: 0.5, y: yPos)
        yPos -= (0.05 + sectionSpacing)
        
        // Graphics section
        graphicsSectionLabel.position = position(x: 0.2, y: yPos)
        yPos -= 0.06
        
        graphicsQualityButton?.position = position(x: 0.5, y: yPos)
        yPos -= (0.08 + itemSpacing)
        
        particleEffectsToggle?.position = position(x: 0.5, y: yPos)
        yPos -= (0.08 + sectionSpacing)
        
        // Gameplay section
        gameplaySectionLabel.position = position(x: 0.2, y: yPos)
        yPos -= 0.06
        
        hapticToggleButton?.position = position(x: 0.5, y: yPos)
        yPos -= (0.08 + itemSpacing)
        
        difficultyResetButton?.position = position(x: 0.5, y: yPos)
        yPos -= (0.08 + sectionSpacing)
        
        // Accessibility section
        accessibilitySectionLabel.position = position(x: 0.2, y: yPos)
        yPos -= 0.06
        
        fontSizeButton?.position = position(x: 0.5, y: yPos)
        yPos -= (0.08 + itemSpacing)
        
        reducedMotionToggle?.position = position(x: 0.5, y: yPos)
        yPos -= (0.08 + itemSpacing)
        
        highContrastToggle?.position = position(x: 0.5, y: yPos)
        yPos -= (0.08 + sectionSpacing)
        
        // Data section
        dataSectionLabel.position = position(x: 0.2, y: yPos)
        yPos -= 0.06
        
        resetProgressButton?.position = position(x: 0.5, y: yPos)
        yPos -= (0.08 + itemSpacing)
        
        exportProgressButton?.position = position(x: 0.5, y: yPos)
    }
    
    // MARK: - Settings Management
    
    private func loadSettings() {
        // Initialize settings with defaults if not set
        if !UserDefaults.standard.bool(forKey: "SettingsInitialized") {
            UserDefaults.standard.set(true, forKey: "HapticEnabled")
            UserDefaults.standard.set(GraphicsQuality.high.rawValue, forKey: "GraphicsQuality")
            UserDefaults.standard.set(AccessibilityFontSize.normal.rawValue, forKey: "AccessibilityFontSize")
            UserDefaults.standard.set(false, forKey: "ReducedMotion")
            UserDefaults.standard.set(false, forKey: "HighContrast")
            UserDefaults.standard.set(true, forKey: "ParticleEffects")
            UserDefaults.standard.set(true, forKey: "SettingsInitialized")
        }
        
        // Update UI to reflect current settings
        updateAllToggles()
    }
    
    private func updateAllToggles() {
        updateSoundToggle()
        updateMusicToggle()
        updateHapticToggle()
        updateGraphicsQualityDisplay()
        updateAccessibilityFontDisplay()
        updateReducedMotionToggle()
        updateHighContrastToggle()
        updateParticleEffectsToggle()
    }
    
    private func updateSoundToggle() {
        soundToggleButton?.updateText("Sound Effects: \(soundEnabled ? "ON" : "OFF")")
        soundToggleButton?.setButtonStyle(soundEnabled ? .primary : .secondary)
    }
    
    private func updateMusicToggle() {
        musicToggleButton?.updateText("Background Music: \(musicEnabled ? "ON" : "OFF")")
        musicToggleButton?.setButtonStyle(musicEnabled ? .primary : .secondary)
    }
    
    private func updateHapticToggle() {
        hapticToggleButton?.updateText("Haptic Feedback: \(hapticEnabled ? "ON" : "OFF")")
        hapticToggleButton?.setButtonStyle(hapticEnabled ? .primary : .secondary)
    }
    
    private func updateGraphicsQualityDisplay() {
        graphicsQualityButton?.updateText("Graphics Quality: \(graphicsQuality.displayName)")
    }
    
    private func updateAccessibilityFontDisplay() {
        fontSizeButton?.updateText("Font Size: \(accessibilityFontSize.displayName)")
    }
    
    private func updateReducedMotionToggle() {
        reducedMotionToggle?.updateText("Reduced Motion: \(reducedMotion ? "ON" : "OFF")")
        reducedMotionToggle?.setButtonStyle(reducedMotion ? .primary : .secondary)
    }
    
    private func updateHighContrastToggle() {
        let highContrast = UserDefaults.standard.bool(forKey: "HighContrast")
        highContrastToggle?.updateText("High Contrast: \(highContrast ? "ON" : "OFF")")
        highContrastToggle?.setButtonStyle(highContrast ? .primary : .secondary)
    }
    
    private func updateParticleEffectsToggle() {
        let particleEffects = UserDefaults.standard.bool(forKey: "ParticleEffects")
        particleEffectsToggle?.updateText("Particle Effects: \(particleEffects ? "ON" : "OFF")")
        particleEffectsToggle?.setButtonStyle(particleEffects ? .primary : .secondary)
    }
    
    // MARK: - Settings Application
    
    private func applyGraphicsQualitySettings() {
        // Apply graphics quality settings to the scene
        switch graphicsQuality {
        case .low:
            ParticleManager.shared.setParticleQuality(.low)
            // Reduce texture quality, disable some effects
        case .medium:
            ParticleManager.shared.setParticleQuality(.medium)
            // Medium texture quality
        case .high:
            ParticleManager.shared.setParticleQuality(.high)
            // Full quality
        }
    }
    
    private func applyAccessibilitySettings() {
        // Apply accessibility settings
        let fontMultiplier = accessibilityFontSize.multiplier
        
        // Update font sizes throughout the scene
        updateFontSizes(multiplier: fontMultiplier)
        
        // Apply reduced motion settings
        if reducedMotion {
            disableAnimations()
        } else {
            enableAnimations()
        }
    }
    
    private func updateFontSizes(multiplier: CGFloat) {
        // Update all text elements with new font size
        scrollContainer.enumerateChildNodes(withName: "*") { node, _ in
            if let labelNode = node as? SKLabelNode {
                if let currentFontSize = labelNode.fontSize as CGFloat? {
                    labelNode.fontSize = currentFontSize * multiplier
                }
            }
        }
    }
    
    private func disableAnimations() {
        // Reduce or disable animations for accessibility
        scrollContainer.removeAllActions()
    }
    
    private func enableAnimations() {
        // Re-enable full animations
        // This could involve restoring default animation settings
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Touch handling is now managed by individual button nodes
        // This method is kept for any future scene-level touch handling
        super.touchesBegan(touches, with: event)
    }
    
    // MARK: - Button Action Handlers
    
    private func handleBackButton() {
        SpriteKitSoundManager.shared.playSound(.buttonTap)
        GameSceneManager.shared.presentScene(.mainMenu)
    }
    
    private func toggleSound() {
        soundEnabled.toggle()
    }
    
    private func toggleMusic() {
        musicEnabled.toggle()
    }
    
    private func selectGraphicsQuality() {
        cycleGraphicsQuality()
    }
    
    private func toggleHapticFeedback() {
        hapticEnabled.toggle()
        if hapticEnabled {
            SpriteKitSoundManager.shared.playHaptic(.light)
        }
    }
    
    private func selectFontSize() {
        cycleFontSize()
    }
    
    private func toggleReducedMotion() {
        reducedMotion.toggle()
    }
    
    // MARK: - Action Handlers
    
    private func cycleGraphicsQuality() {
        let nextQuality: GraphicsQuality
        switch graphicsQuality {
        case .low:
            nextQuality = .medium
        case .medium:
            nextQuality = .high
        case .high:
            nextQuality = .low
        }
        graphicsQuality = nextQuality
    }
    
    private func toggleParticleEffects() {
        let current = UserDefaults.standard.bool(forKey: "ParticleEffects")
        UserDefaults.standard.set(!current, forKey: "ParticleEffects")
        updateParticleEffectsToggle()
        
        // Apply particle effects setting
        ParticleManager.shared.setParticleEffectsEnabled(!current)
    }
    
    private func resetAdaptiveDifficulty() {
        // Reset the adaptive difficulty system
        GameData.shared.resetAdaptiveDifficulty()
        
        // Show confirmation
        showNotification("Adaptive difficulty has been reset to default levels")
    }
    
    private func cycleFontSize() {
        let nextSize: AccessibilityFontSize
        switch accessibilityFontSize {
        case .small:
            nextSize = .normal
        case .normal:
            nextSize = .large
        case .large:
            nextSize = .extraLarge
        case .extraLarge:
            nextSize = .small
        }
        accessibilityFontSize = nextSize
    }
    
    private func toggleHighContrast() {
        let current = UserDefaults.standard.bool(forKey: "HighContrast")
        UserDefaults.standard.set(!current, forKey: "HighContrast")
        updateHighContrastToggle()
        
        // Apply high contrast theme
        if !current {
            applyHighContrastTheme()
        } else {
            applyNormalTheme()
        }
    }
    
    private func applyHighContrastTheme() {
        // Apply high contrast colors - reconstruct background
        if let backgroundNode = backgroundNode {
            backgroundNode.removeFromParent()
        }
        createGradientBackground(colors: [
            UIColor.black,
            UIColor.darkGray
        ])
    }
    
    private func applyNormalTheme() {
        // Restore normal theme colors - reconstruct background
        if let backgroundNode = backgroundNode {
            backgroundNode.removeFromParent()
        }
        createGradientBackground(colors: [
            UIColor(red: 0.2, green: 0.4, blue: 0.8, alpha: 1.0),
            UIColor(red: 0.4, green: 0.2, blue: 0.8, alpha: 1.0)
        ])
    }
    
    private func showResetProgressConfirmation() {
        let popup = PopupNode(
            title: "Reset All Progress?",
            message: "This will permanently delete all your progress, including stars, badges, and level completion. This action cannot be undone.",
            style: .confirmation,
            buttons: .yesNo,
            screenSize: size
        )
        
        popup.onButtonTap = { [weak self] buttonIndex, buttonTitle in
            if buttonIndex == 0 { // "Yes" button
                self?.resetAllProgress()
            }
            popup.dismiss()
        }
        
        addChild(popup)
        popup.show()
    }
    
    private func resetAllProgress() {
        // Reset all game data
        GameData.shared.resetAllProgress()
        
        // Show confirmation
        showNotification("All progress has been reset")
    }
    
    private func exportProgressData() {
        // Export progress data (simplified for now)
        let progressData = GameData.shared.exportProgressData()
        
        // In a real implementation, this would trigger a share sheet
        showNotification("Progress data exported successfully")
    }
    
    private func showNotification(_ message: String) {
        let notification = NodeFactory.shared.createLabel(
            text: message,
            style: .body,
            color: .white
        )
        notification.position = position(x: 0.5, y: 0.15)
        notification.alpha = 0
        
        addChild(notification)
        
        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let wait = SKAction.wait(forDuration: 2.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.3)
        let remove = SKAction.removeFromParent()
        
        notification.run(SKAction.sequence([fadeIn, wait, fadeOut, remove]))
    }
}

// MARK: - Supporting Types

enum GraphicsQuality: Int, CaseIterable {
    case low = 0
    case medium = 1  
    case high = 2
    
    var displayName: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        }
    }
}

enum AccessibilityFontSize: Int, CaseIterable {
    case small = 0
    case normal = 1
    case large = 2
    case extraLarge = 3
    
    var displayName: String {
        switch self {
        case .small: return "Small"
        case .normal: return "Normal"
        case .large: return "Large"
        case .extraLarge: return "Extra Large"
        }
    }
    
    var multiplier: CGFloat {
        switch self {
        case .small: return 0.8
        case .normal: return 1.0
        case .large: return 1.2
        case .extraLarge: return 1.5
        }
    }
}

// MARK: - Slider Node

class SliderNode: SKNode {
    private let trackNode: SKSpriteNode
    private let thumbNode: SKSpriteNode
    private let width: CGFloat
    private let height: CGFloat
    private var currentValue: CGFloat
    
    init(width: CGFloat, height: CGFloat, value: CGFloat = 0.5) {
        self.width = width
        self.height = height
        self.currentValue = max(0, min(1, value))
        
        // Create track
        trackNode = SKSpriteNode(color: .gray, size: CGSize(width: width, height: height/3))
        trackNode.alpha = 0.5
        
        // Create thumb
        thumbNode = SKSpriteNode(color: .white, size: CGSize(width: height, height: height))
        
        super.init()
        
        addChild(trackNode)
        addChild(thumbNode)
        
        updateThumbPosition()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateThumbPosition() {
        let minX = -width/2 + height/2
        let maxX = width/2 - height/2
        let thumbX = minX + (maxX - minX) * currentValue
        thumbNode.position.x = thumbX
    }
    
    func setValue(_ value: CGFloat) {
        currentValue = max(0, min(1, value))
        updateThumbPosition()
    }
    
    func getValue() -> CGFloat {
        return currentValue
    }
}
