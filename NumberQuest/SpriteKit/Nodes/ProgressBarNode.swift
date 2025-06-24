//
//  ProgressBarNode.swift
//  NumberQuest
//
//  Created by TaiPV on 24/6/25.
//

import SpriteKit
import UIKit

/// Enhanced progress bar with animations, effects, and multiple styles
class ProgressBarNode: SKNode {
    
    // MARK: - Types
    
    enum ProgressStyle {
        case standard
        case rounded
        case pill
        case segmented
        case gradient
        case streak
        
        var cornerRadius: CGFloat {
            switch self {
            case .standard:
                return 4
            case .rounded:
                return 8
            case .pill:
                return 50 // Large radius for pill shape
            case .segmented:
                return 6
            case .gradient:
                return 6
            case .streak:
                return 10
            }
        }
    }
    
    enum ProgressColor {
        case green
        case blue
        case orange
        case red
        case purple
        case rainbow
        case custom(UIColor)
        
        var color: UIColor {
            switch self {
            case .green:
                return SpriteKitColors.UI.successButton
            case .blue:
                return SpriteKitColors.UI.primaryButton
            case .orange:
                return SpriteKitColors.UI.warningButton
            case .red:
                return SpriteKitColors.UI.dangerButton
            case .purple:
                return UIColor(red: 0.6, green: 0.3, blue: 0.8, alpha: 0.9)
            case .rainbow:
                return UIColor(red: 0.8, green: 0.2, blue: 0.9, alpha: 0.9)
            case .custom(let color):
                return color
            }
        }
    }
    
    // MARK: - Properties
    
    private var backgroundBar: SKShapeNode!
    private var progressBar: SKShapeNode!
    private var glowNode: SKShapeNode?
    private var segmentNodes: [SKShapeNode] = []
    private var pulseNode: SKShapeNode?
    private var progressLabel: SKLabelNode?
    
    private let barSize: CGSize
    private let progressStyle: ProgressStyle
    private let progressColor: ProgressColor
    private let backgroundColor: UIColor
    private var currentProgress: CGFloat = 0.0
    private var targetProgress: CGFloat = 0.0
    private var showPercentage: Bool = false
    private var segmentCount: Int = 0
    
    // Animation properties
    private var animationDuration: TimeInterval = 0.5
    private var showGlowEffect: Bool = false
    private var pulseOnComplete: Bool = false
    
    // MARK: - Initialization
    
    init(
        size: CGSize,
        progress: CGFloat = 0.0,
        style: ProgressStyle = .standard,
        progressColor: ProgressColor = .green,
        backgroundColor: UIColor = UIColor.gray.withAlphaComponent(0.3),
        showPercentage: Bool = false,
        segmentCount: Int = 0
    ) {
        self.barSize = size
        self.progressStyle = style
        self.progressColor = progressColor
        self.backgroundColor = backgroundColor
        self.currentProgress = progress
        self.targetProgress = progress
        self.showPercentage = showPercentage
        self.segmentCount = segmentCount
        
        super.init()
        
        setupProgressBar()
        
        if showPercentage {
            addPercentageLabel()
        }
        
        if segmentCount > 0 {
            createSegmentedBar()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupProgressBar() {
        // Create background bar
        createBackgroundBar()
        
        // Create progress bar
        createProgressBar()
        
        // Create glow effect if enabled
        if showGlowEffect {
            createGlow()
        }
        
        // Create pulse effect node
        createPulseNode()
    }
    
    private func createBackgroundBar() {
        let backgroundPath = UIBezierPath(
            roundedRect: CGRect(
                origin: CGPoint(x: -barSize.width/2, y: -barSize.height/2),
                size: barSize
            ),
            cornerRadius: progressStyle.cornerRadius
        )
        
        backgroundBar = SKShapeNode(path: backgroundPath.cgPath)
        backgroundBar.fillColor = backgroundColor
        backgroundBar.strokeColor = .clear
        backgroundBar.zPosition = -1
        addChild(backgroundBar)
    }
    
    private func createProgressBar() {
        let progressWidth = barSize.width * currentProgress
        let progressPath = UIBezierPath(
            roundedRect: CGRect(
                origin: CGPoint(x: -barSize.width/2, y: -barSize.height/2),
                size: CGSize(width: progressWidth, height: barSize.height)
            ),
            cornerRadius: progressStyle.cornerRadius
        )
        
        progressBar = SKShapeNode(path: progressPath.cgPath)
        progressBar.fillColor = progressColor.color
        progressBar.strokeColor = .clear
        progressBar.zPosition = 0
        addChild(progressBar)
    }
    
    private func createGlow() {
        let glowPath = UIBezierPath(
            roundedRect: CGRect(
                origin: CGPoint(x: -barSize.width/2 - 2, y: -barSize.height/2 - 2),
                size: CGSize(width: barSize.width + 4, height: barSize.height + 4)
            ),
            cornerRadius: progressStyle.cornerRadius + 2
        )
        
        glowNode = SKShapeNode(path: glowPath.cgPath)
        glowNode?.fillColor = .clear
        glowNode?.strokeColor = progressColor.color.withAlphaComponent(0.6)
        glowNode?.lineWidth = 3
        glowNode?.zPosition = -0.5
        glowNode?.alpha = 0
        addChild(glowNode!)
    }
    
    private func createPulseNode() {
        let pulseSize = CGSize(width: barSize.width + 10, height: barSize.height + 10)
        let pulsePath = UIBezierPath(
            roundedRect: CGRect(
                origin: CGPoint(x: -pulseSize.width/2, y: -pulseSize.height/2),
                size: pulseSize
            ),
            cornerRadius: progressStyle.cornerRadius + 5
        )
        
        pulseNode = SKShapeNode(path: pulsePath.cgPath)
        pulseNode?.fillColor = progressColor.color.withAlphaComponent(0.3)
        pulseNode?.strokeColor = .clear
        pulseNode?.zPosition = -2
        pulseNode?.alpha = 0
        addChild(pulseNode!)
    }
    
    private func addPercentageLabel() {
        progressLabel = SKLabelNode(text: "\(Int(currentProgress * 100))%")
        progressLabel?.fontName = "Baloo2-VariableFont_wght"
        progressLabel?.fontSize = min(barSize.height * 0.6, 16)
        progressLabel?.fontColor = .white
        progressLabel?.horizontalAlignmentMode = .center
        progressLabel?.verticalAlignmentMode = .center
        progressLabel?.zPosition = 1
        addChild(progressLabel!)
    }
    
    private func createSegmentedBar() {
        guard segmentCount > 0 else { return }
        
        let segmentWidth = (barSize.width - CGFloat(segmentCount - 1) * 2) / CGFloat(segmentCount)
        let segmentHeight = barSize.height
        
        for i in 0..<segmentCount {
            let segmentX = -barSize.width/2 + CGFloat(i) * (segmentWidth + 2) + segmentWidth/2
            
            let segmentPath = UIBezierPath(
                roundedRect: CGRect(
                    origin: CGPoint(x: -segmentWidth/2, y: -segmentHeight/2),
                    size: CGSize(width: segmentWidth, height: segmentHeight)
                ),
                cornerRadius: progressStyle.cornerRadius
            )
            
            let segmentNode = SKShapeNode(path: segmentPath.cgPath)
            segmentNode.position = CGPoint(x: segmentX, y: 0)
            segmentNode.fillColor = backgroundColor
            segmentNode.strokeColor = .clear
            segmentNode.zPosition = 0
            
            segmentNodes.append(segmentNode)
            addChild(segmentNode)
        }
        
        // Hide the main progress bar for segmented style
        progressBar.alpha = 0
        updateSegmentedProgress()
    }
    
    // MARK: - Public Methods
    
    func setProgress(_ progress: CGFloat, animated: Bool = true) {
        let clampedProgress = max(0.0, min(1.0, progress))
        targetProgress = clampedProgress
        
        if animated {
            updateProgressAnimated(to: clampedProgress)
        } else {
            updateProgressInstant(to: clampedProgress)
        }
    }
    
    func updateProgress(to newProgress: CGFloat, animated: Bool = true) {
        setProgress(newProgress, animated: animated)
    }
    
    func setAnimationDuration(_ duration: TimeInterval) {
        animationDuration = duration
    }
    
    func setShowGlow(_ show: Bool) {
        showGlowEffect = show
        if show && glowNode == nil {
            createGlow()
        }
    }
    
    func setPulseOnComplete(_ pulse: Bool) {
        pulseOnComplete = pulse
    }
    
    func pulseEffect() {
        guard let pulse = pulseNode else { return }
        
        let pulseSequence = SKAction.sequence([
            SKAction.fadeIn(withDuration: 0.2),
            SKAction.scale(to: 1.1, duration: 0.2),
            SKAction.group([
                SKAction.fadeOut(withDuration: 0.4),
                SKAction.scale(to: 1.0, duration: 0.4)
            ])
        ])
        
        pulse.run(pulseSequence)
    }
    
    func celebrateCompletion() {
        // Rainbow color animation
        let colors: [UIColor] = [
            .red,
            UIColor.orange,
            .yellow,
            .green,
            .blue,
            UIColor.purple
        ]
        
        var colorActions: [SKAction] = []
        for color in colors {
            let colorAction = SKAction.run {
                self.progressBar.fillColor = color
            }
            colorActions.append(colorAction)
            colorActions.append(SKAction.wait(forDuration: 0.1))
        }
        
        // Return to original color
        let resetColor = SKAction.run {
            self.progressBar.fillColor = self.progressColor.color
        }
        colorActions.append(resetColor)
        
        let celebrationSequence = SKAction.sequence(colorActions)
        progressBar.run(celebrationSequence)
        
        // Pulse effect
        pulseEffect()
        
        // Glow effect
        if let glow = glowNode {
            let glowSequence = SKAction.sequence([
                SKAction.fadeIn(withDuration: 0.2),
                SKAction.wait(forDuration: 0.5),
                SKAction.fadeOut(withDuration: 0.3)
            ])
            glow.run(glowSequence)
        }
    }
    
    func reset(animated: Bool = true) {
        setProgress(0.0, animated: animated)
    }
    
    // MARK: - Private Methods
    
    private func updateProgressAnimated(to progress: CGFloat) {
        let progressWidth = barSize.width * progress
        let newProgressPath = UIBezierPath(
            roundedRect: CGRect(
                origin: CGPoint(x: -barSize.width/2, y: -barSize.height/2),
                size: CGSize(width: progressWidth, height: barSize.height)
            ),
            cornerRadius: progressStyle.cornerRadius
        )
        
        // Animate the progress bar path
        let pathAnimation = SKAction.customAction(withDuration: animationDuration) { node, elapsedTime in
            let progress = elapsedTime / CGFloat(self.animationDuration)
            let easedProgress = self.easeInOutCubic(progress)
            
            let currentWidth = self.barSize.width * (self.currentProgress + (progress - self.currentProgress) * easedProgress)
            let currentPath = UIBezierPath(
                roundedRect: CGRect(
                    origin: CGPoint(x: -self.barSize.width/2, y: -self.barSize.height/2),
                    size: CGSize(width: currentWidth, height: self.barSize.height)
                ),
                cornerRadius: self.progressStyle.cornerRadius
            )
            
            if let progressNode = node as? SKShapeNode {
                progressNode.path = currentPath.cgPath
            }
        }
        
        progressBar.run(pathAnimation) { [weak self] in
            self?.currentProgress = progress
            self?.updateProgressLabel()
            
            if progress >= 1.0 && self?.pulseOnComplete == true {
                self?.celebrateCompletion()
            }
        }
        
        // Update segmented progress if needed
        if segmentCount > 0 {
            updateSegmentedProgressAnimated(to: progress)
        }
        
        // Update percentage label
        if showPercentage {
            updateProgressLabelAnimated(to: progress)
        }
    }
    
    private func updateProgressInstant(to progress: CGFloat) {
        currentProgress = progress
        
        let progressWidth = barSize.width * progress
        let progressPath = UIBezierPath(
            roundedRect: CGRect(
                origin: CGPoint(x: -barSize.width/2, y: -barSize.height/2),
                size: CGSize(width: progressWidth, height: barSize.height)
            ),
            cornerRadius: progressStyle.cornerRadius
        )
        
        progressBar.path = progressPath.cgPath
        
        if segmentCount > 0 {
            updateSegmentedProgress()
        }
        
        updateProgressLabel()
        
        if progress >= 1.0 && pulseOnComplete {
            celebrateCompletion()
        }
    }
    
    private func updateSegmentedProgress() {
        let filledSegments = Int(currentProgress * CGFloat(segmentCount))
        
        for (index, segment) in segmentNodes.enumerated() {
            if index < filledSegments {
                segment.fillColor = progressColor.color
            } else {
                segment.fillColor = backgroundColor
            }
        }
    }
    
    private func updateSegmentedProgressAnimated(to progress: CGFloat) {
        let targetFilledSegments = Int(progress * CGFloat(segmentCount))
        let currentFilledSegments = Int(currentProgress * CGFloat(segmentCount))
        
        if targetFilledSegments > currentFilledSegments {
            // Fill segments one by one
            for i in currentFilledSegments..<targetFilledSegments {
                if i < segmentNodes.count {
                    let delay = Double(i - currentFilledSegments) * (animationDuration / Double(targetFilledSegments - currentFilledSegments))
                    let fillAction = SKAction.sequence([
                        SKAction.wait(forDuration: delay),
                        SKAction.run {
                            self.segmentNodes[i].fillColor = self.progressColor.color
                        }
                    ])
                    run(fillAction)
                }
            }
        } else if targetFilledSegments < currentFilledSegments {
            // Empty segments one by one
            for i in (targetFilledSegments..<currentFilledSegments).reversed() {
                if i < segmentNodes.count {
                    let delay = Double(currentFilledSegments - i - 1) * (animationDuration / Double(currentFilledSegments - targetFilledSegments))
                    let emptyAction = SKAction.sequence([
                        SKAction.wait(forDuration: delay),
                        SKAction.run {
                            self.segmentNodes[i].fillColor = self.backgroundColor
                        }
                    ])
                    run(emptyAction)
                }
            }
        }
    }
    
    private func updateProgressLabel() {
        guard let label = progressLabel else { return }
        label.text = "\(Int(currentProgress * 100))%"
    }
    
    private func updateProgressLabelAnimated(to progress: CGFloat) {
        guard let label = progressLabel else { return }
        
        let countAnimation = SKAction.customAction(withDuration: animationDuration) { _, elapsedTime in
            let progress = elapsedTime / CGFloat(self.animationDuration)
            let currentValue = self.currentProgress + (progress - self.currentProgress) * progress
            label.text = "\(Int(currentValue * 100))%"
        }
        
        label.run(countAnimation)
    }
    
    // Easing function for smooth animation
    private func easeInOutCubic(_ t: CGFloat) -> CGFloat {
        return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3) / 2
    }
}

// MARK: - Convenience Extensions

extension ProgressBarNode {
    
    /// Create a health bar
    static func healthBar(size: CGSize = CGSize(width: 200, height: 20), progress: CGFloat = 1.0) -> ProgressBarNode {
        return ProgressBarNode(
            size: size,
            progress: progress,
            style: .rounded,
            progressColor: .green,
            showPercentage: false
        )
    }
    
    /// Create a streak progress bar
    static func streakBar(size: CGSize = CGSize(width: 250, height: 15), progress: CGFloat = 0.0) -> ProgressBarNode {
        let bar = ProgressBarNode(
            size: size,
            progress: progress,
            style: .pill,
            progressColor: .orange,
            showPercentage: false
        )
        bar.setShowGlow(true)
        bar.setPulseOnComplete(true)
        return bar
    }
    
    /// Create a level progress bar
    static func levelProgressBar(size: CGSize = CGSize(width: 300, height: 25), progress: CGFloat = 0.0) -> ProgressBarNode {
        return ProgressBarNode(
            size: size,
            progress: progress,
            style: .gradient,
            progressColor: .blue,
            showPercentage: true
        )
    }
    
    /// Create a segmented progress bar (like for achievements)
    static func segmentedBar(size: CGSize = CGSize(width: 240, height: 18), segments: Int = 5, progress: CGFloat = 0.0) -> ProgressBarNode {
        return ProgressBarNode(
            size: size,
            progress: progress,
            style: .segmented,
            progressColor: .purple,
            segmentCount: segments
        )
    }
}
