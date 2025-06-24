//
//  PopupNode.swift
//  NumberQuest
//
//  Created by TaiPV on 24/6/25.
//

import SpriteKit
import UIKit

/// Modal popup node for alerts, confirmations, and information displays
class PopupNode: SKNode {
    
    // MARK: - Types
    
    enum PopupStyle {
        case alert
        case confirmation
        case info
        case success
        case warning
        case error
        case custom(UIColor)
        
        var colors: (background: UIColor, border: UIColor, text: UIColor, button: UIColor) {
            switch self {
            case .alert:
                return (
                    background: UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 0.95),
                    border: UIColor(red: 0.4, green: 0.4, blue: 0.5, alpha: 1.0),
                    text: .white,
                    button: SpriteKitColors.UI.primaryButton
                )
            case .confirmation:
                return (
                    background: UIColor(red: 0.1, green: 0.3, blue: 0.6, alpha: 0.95),
                    border: UIColor(red: 0.2, green: 0.4, blue: 0.7, alpha: 1.0),
                    text: .white,
                    button: SpriteKitColors.UI.successButton
                )
            case .info:
                return (
                    background: UIColor(red: 0.2, green: 0.4, blue: 0.7, alpha: 0.95),
                    border: UIColor(red: 0.3, green: 0.5, blue: 0.8, alpha: 1.0),
                    text: .white,
                    button: SpriteKitColors.UI.primaryButton
                )
            case .success:
                return (
                    background: UIColor(red: 0.1, green: 0.6, blue: 0.2, alpha: 0.95),
                    border: UIColor(red: 0.2, green: 0.7, blue: 0.3, alpha: 1.0),
                    text: .white,
                    button: SpriteKitColors.UI.successButton
                )
            case .warning:
                return (
                    background: UIColor(red: 0.8, green: 0.5, blue: 0.1, alpha: 0.95),
                    border: UIColor(red: 0.9, green: 0.6, blue: 0.2, alpha: 1.0),
                    text: .white,
                    button: SpriteKitColors.UI.warningButton
                )
            case .error:
                return (
                    background: UIColor(red: 0.7, green: 0.2, blue: 0.2, alpha: 0.95),
                    border: UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0),
                    text: .white,
                    button: SpriteKitColors.UI.dangerButton
                )
            case .custom(let color):
                return (
                    background: color.withAlphaComponent(0.95),
                    border: color,
                    text: .white,
                    button: color
                )
            }
        }
    }
    
    enum PopupSize {
        case small
        case medium
        case large
        case fullWidth
        case custom(CGSize)
        
        func size(for screenSize: CGSize) -> CGSize {
            switch self {
            case .small:
                return CGSize(width: min(300, screenSize.width * 0.8), height: 200)
            case .medium:
                return CGSize(width: min(400, screenSize.width * 0.85), height: 280)
            case .large:
                return CGSize(width: min(500, screenSize.width * 0.9), height: 400)
            case .fullWidth:
                return CGSize(width: screenSize.width * 0.95, height: 350)
            case .custom(let customSize):
                return customSize
            }
        }
    }
    
    enum ButtonConfiguration {
        case ok
        case okCancel
        case yesNo
        case custom([String])
        
        var buttonTitles: [String] {
            switch self {
            case .ok:
                return ["OK"]
            case .okCancel:
                return ["OK", "Cancel"]
            case .yesNo:
                return ["Yes", "No"]
            case .custom(let titles):
                return titles
            }
        }
    }
    
    struct PopupConfiguration {
        let title: String
        let message: String?
        let icon: String?
        let style: PopupStyle
        let size: PopupSize
        let buttons: ButtonConfiguration
        let dismissOnBackgroundTap: Bool
        let showCloseButton: Bool
        
        init(
            title: String,
            message: String? = nil,
            icon: String? = nil,
            style: PopupStyle = .alert,
            size: PopupSize = .medium,
            buttons: ButtonConfiguration = .ok,
            dismissOnBackgroundTap: Bool = true,
            showCloseButton: Bool = false
        ) {
            self.title = title
            self.message = message
            self.icon = icon
            self.style = style
            self.size = size
            self.buttons = buttons
            self.dismissOnBackgroundTap = dismissOnBackgroundTap
            self.showCloseButton = showCloseButton
        }
    }
    
    // MARK: - Properties
    
    private var backgroundOverlay: SKSpriteNode!
    private var popupContainer: SKNode!
    private var popupBackground: SKShapeNode!
    private var popupBorder: SKShapeNode!
    private var shadowNode: SKShapeNode!
    private var titleLabel: SKLabelNode!
    private var messageLabel: SKLabelNode?
    private var iconLabel: SKLabelNode?
    private var closeButton: GameButtonNode?
    private var actionButtons: [GameButtonNode] = []
    
    private let configuration: PopupConfiguration
    private let popupSize: CGSize
    private var isVisible: Bool = false
    
    // Callbacks
    var onButtonTap: ((Int, String) -> Void)?
    var onDismiss: (() -> Void)?
    
    // MARK: - Initialization
    
    init(configuration: PopupConfiguration, screenSize: CGSize = CGSize(width: 400, height: 600)) {
        self.configuration = configuration
        self.popupSize = configuration.size.size(for: screenSize)
        
        super.init()
        
        setupPopup(screenSize: screenSize)
        setupAnimations()
    }
    
    convenience init(
        title: String,
        message: String? = nil,
        icon: String? = nil,
        style: PopupStyle = .alert,
        buttons: ButtonConfiguration = .ok,
        screenSize: CGSize = CGSize(width: 400, height: 600)
    ) {
        let config = PopupConfiguration(
            title: title,
            message: message,
            icon: icon,
            style: style,
            buttons: buttons
        )
        self.init(configuration: config, screenSize: screenSize)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupPopup(screenSize: CGSize) {
        // Create background overlay
        createBackgroundOverlay(screenSize: screenSize)
        
        // Create popup container
        createPopupContainer()
        
        // Setup popup elements
        setupPopupElements()
        
        // Initially hidden
        alpha = 0
        isHidden = true
    }
    
    private func createBackgroundOverlay(screenSize: CGSize) {
        backgroundOverlay = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.6), size: screenSize)
        backgroundOverlay.zPosition = -10
        
        if configuration.dismissOnBackgroundTap {
            backgroundOverlay.isUserInteractionEnabled = true
        }
        
        addChild(backgroundOverlay)
    }
    
    private func createPopupContainer() {
        popupContainer = SKNode()
        addChild(popupContainer)
        
        // Create shadow
        createShadow()
        
        // Create popup background
        createPopupBackground()
        
        // Create border
        createPopupBorder()
    }
    
    private func createShadow() {
        let shadowPath = UIBezierPath(
            roundedRect: CGRect(
                origin: CGPoint(x: -popupSize.width/2, y: -popupSize.height/2),
                size: popupSize
            ),
            cornerRadius: 20
        )
        
        shadowNode = SKShapeNode(path: shadowPath.cgPath)
        shadowNode.fillColor = UIColor.black.withAlphaComponent(0.5)
        shadowNode.strokeColor = .clear
        shadowNode.position = CGPoint(x: 0, y: -8)
        shadowNode.zPosition = -3
        popupContainer.addChild(shadowNode)
    }
    
    private func createPopupBackground() {
        let backgroundPath = UIBezierPath(
            roundedRect: CGRect(
                origin: CGPoint(x: -popupSize.width/2, y: -popupSize.height/2),
                size: popupSize
            ),
            cornerRadius: 20
        )
        
        popupBackground = SKShapeNode(path: backgroundPath.cgPath)
        popupBackground.fillColor = configuration.style.colors.background
        popupBackground.strokeColor = .clear
        popupBackground.zPosition = -2
        popupContainer.addChild(popupBackground)
    }
    
    private func createPopupBorder() {
        let borderPath = UIBezierPath(
            roundedRect: CGRect(
                origin: CGPoint(x: -popupSize.width/2, y: -popupSize.height/2),
                size: popupSize
            ),
            cornerRadius: 20
        )
        
        popupBorder = SKShapeNode(path: borderPath.cgPath)
        popupBorder.fillColor = .clear
        popupBorder.strokeColor = configuration.style.colors.border
        popupBorder.lineWidth = 3
        popupBorder.zPosition = -1
        popupContainer.addChild(popupBorder)
    }
    
    private func setupPopupElements() {
        var currentY: CGFloat = popupSize.height/2 - 40
        
        // Create close button if needed
        if configuration.showCloseButton {
            createCloseButton()
        }
        
        // Create icon if provided
        if let iconText = configuration.icon {
            createIcon(iconText, y: &currentY)
        }
        
        // Create title
        createTitle(y: &currentY)
        
        // Create message if provided
        if let messageText = configuration.message {
            createMessage(messageText, y: &currentY)
        }
        
        // Create action buttons
        createActionButtons()
    }
    
    private func createCloseButton() {
        closeButton = GameButtonNode(
            text: "✕",
            style: .back,
            size: .small
        )
        closeButton?.position = CGPoint(x: popupSize.width/2 - 30, y: popupSize.height/2 - 30)
        closeButton?.zPosition = 1
        closeButton?.onTap = { [weak self] in
            self?.dismiss()
        }
        popupContainer.addChild(closeButton!)
    }
    
    private func createIcon(_ iconText: String, y: inout CGFloat) {
        iconLabel = SKLabelNode(text: iconText)
        iconLabel?.fontSize = 48
        iconLabel?.horizontalAlignmentMode = .center
        iconLabel?.verticalAlignmentMode = .center
        iconLabel?.position = CGPoint(x: 0, y: y)
        iconLabel?.zPosition = 1
        popupContainer.addChild(iconLabel!)
        
        y -= 70
    }
    
    private func createTitle(y: inout CGFloat) {
        titleLabel = SKLabelNode(text: configuration.title)
        titleLabel.fontName = "Baloo2-VariableFont_wght"
        titleLabel.fontSize = 24
        titleLabel.fontColor = configuration.style.colors.text
        titleLabel.horizontalAlignmentMode = .center
        titleLabel.verticalAlignmentMode = .center
        titleLabel.position = CGPoint(x: 0, y: y)
        titleLabel.zPosition = 1
        popupContainer.addChild(titleLabel)
        
        y -= 50
    }
    
    private func createMessage(_ messageText: String, y: inout CGFloat) {
        messageLabel = SKLabelNode(text: messageText)
        messageLabel?.fontName = "Baloo2-VariableFont_wght"
        messageLabel?.fontSize = 16
        messageLabel?.fontColor = configuration.style.colors.text.withAlphaComponent(0.9)
        messageLabel?.horizontalAlignmentMode = .center
        messageLabel?.verticalAlignmentMode = .center
        messageLabel?.preferredMaxLayoutWidth = popupSize.width - 60
        messageLabel?.numberOfLines = 0
        messageLabel?.position = CGPoint(x: 0, y: y)
        messageLabel?.zPosition = 1
        popupContainer.addChild(messageLabel!)
        
        // Adjust y based on number of lines (approximate)
        let estimatedLines = max(1, messageText.count / 40)
        y -= CGFloat(estimatedLines * 25 + 20)
    }
    
    private func createActionButtons() {
        let buttonTitles = configuration.buttons.buttonTitles
        let buttonCount = buttonTitles.count
        
        if buttonCount == 1 {
            // Single button centered
            let button = createActionButton(title: buttonTitles[0], index: 0)
            button.position = CGPoint(x: 0, y: -popupSize.height/2 + 50)
            actionButtons.append(button)
            popupContainer.addChild(button)
        } else if buttonCount == 2 {
            // Two buttons side by side
            let buttonWidth: CGFloat = 120
            let spacing: CGFloat = 20
            
            for (index, title) in buttonTitles.enumerated() {
                let button = createActionButton(title: title, index: index)
                let xPosition = (index == 0) ? -buttonWidth/2 - spacing/2 : buttonWidth/2 + spacing/2
                button.position = CGPoint(x: xPosition, y: -popupSize.height/2 + 50)
                actionButtons.append(button)
                popupContainer.addChild(button)
            }
        } else {
            // Multiple buttons stacked vertically
            let buttonHeight: CGFloat = 50
            let spacing: CGFloat = 10
            let startY = -popupSize.height/2 + CGFloat(buttonCount) * (buttonHeight + spacing)
            
            for (index, title) in buttonTitles.enumerated() {
                let button = createActionButton(title: title, index: index)
                button.position = CGPoint(x: 0, y: startY - CGFloat(index) * (buttonHeight + spacing))
                actionButtons.append(button)
                popupContainer.addChild(button)
            }
        }
    }
    
    private func createActionButton(title: String, index: Int) -> GameButtonNode {
        let buttonStyle: GameButtonNode.ButtonStyle = {
            switch configuration.buttons {
            case .ok, .okCancel:
                return index == 0 ? .primary : .secondary
            case .yesNo:
                return index == 0 ? .success : .danger
            case .custom:
                return .primary
            }
        }()
        
        let button = GameButtonNode(
            text: title,
            style: buttonStyle,
            size: .medium
        )
        
        button.onTap = { [weak self] in
            self?.onButtonTap?(index, title)
            if title != "Cancel" {
                self?.dismiss()
            }
        }
        
        return button
    }
    
    private func setupAnimations() {
        // Setup entrance animation
        popupContainer.setScale(0.8)
    }
    
    // MARK: - Public Methods
    
    func show(animated: Bool = true) {
        guard !isVisible else { return }
        
        isVisible = true
        isHidden = false
        
        if animated {
            // Fade in background
            let fadeInBackground = SKAction.fadeIn(withDuration: 0.3)
            
            // Scale and fade in popup
            let scaleIn = SKAction.scale(to: 1.0, duration: 0.4)
            scaleIn.timingMode = .easeOut
            
            let fadeInPopup = SKAction.fadeIn(withDuration: 0.3)
            let popupAnimation = SKAction.group([scaleIn, fadeInPopup])
            
            run(fadeInBackground)
            popupContainer.run(popupAnimation)
        } else {
            alpha = 1.0
            popupContainer.setScale(1.0)
        }
        
        // Play sound
        SpriteKitSoundManager.shared.playSound(.buttonTap)
    }
    
    func dismiss(animated: Bool = true) {
        guard isVisible else { return }
        
        isVisible = false
        
        if animated {
            // Scale and fade out popup
            let scaleOut = SKAction.scale(to: 0.8, duration: 0.3)
            scaleOut.timingMode = .easeIn
            
            let fadeOutPopup = SKAction.fadeOut(withDuration: 0.3)
            let popupAnimation = SKAction.group([scaleOut, fadeOutPopup])
            
            // Fade out background
            let fadeOutBackground = SKAction.fadeOut(withDuration: 0.3)
            
            run(fadeOutBackground)
            popupContainer.run(popupAnimation) { [weak self] in
                self?.isHidden = true
                self?.onDismiss?()
            }
        } else {
            alpha = 0
            isHidden = true
            onDismiss?()
        }
        
        // Play sound
        SpriteKitSoundManager.shared.playSound(.buttonTap)
    }
    
    func updateTitle(_ title: String) {
        titleLabel.text = title
    }
    
    func updateMessage(_ message: String) {
        messageLabel?.text = message
    }
    
    func updateIcon(_ icon: String) {
        iconLabel?.text = icon
    }
    
    // MARK: - Touch Handling
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        
        // Check if touch is on background overlay
        if backgroundOverlay.contains(location) && configuration.dismissOnBackgroundTap {
            // Check if it's not on the popup itself
            let popupLocation = touch.location(in: popupContainer)
            let popupRect = CGRect(
                origin: CGPoint(x: -popupSize.width/2, y: -popupSize.height/2),
                size: popupSize
            )
            
            if !popupRect.contains(popupLocation) {
                dismiss()
            }
        }
    }
}

// MARK: - Convenience Extensions

extension PopupNode {
    
    /// Create an alert popup
    static func alert(
        title: String,
        message: String? = nil,
        icon: String? = "⚠️",
        screenSize: CGSize = CGSize(width: 400, height: 600)
    ) -> PopupNode {
        return PopupNode(
            title: title,
            message: message,
            icon: icon,
            style: .alert,
            buttons: .ok,
            screenSize: screenSize
        )
    }
    
    /// Create a confirmation popup
    static func confirmation(
        title: String,
        message: String? = nil,
        icon: String? = "❓",
        screenSize: CGSize = CGSize(width: 400, height: 600)
    ) -> PopupNode {
        return PopupNode(
            title: title,
            message: message,
            icon: icon,
            style: .confirmation,
            buttons: .yesNo,
            screenSize: screenSize
        )
    }
    
    /// Create a success popup
    static func success(
        title: String,
        message: String? = nil,
        icon: String? = "✅",
        screenSize: CGSize = CGSize(width: 400, height: 600)
    ) -> PopupNode {
        return PopupNode(
            title: title,
            message: message,
            icon: icon,
            style: .success,
            buttons: .ok,
            screenSize: screenSize
        )
    }
    
    /// Create an error popup
    static func error(
        title: String,
        message: String? = nil,
        icon: String? = "❌",
        screenSize: CGSize = CGSize(width: 400, height: 600)
    ) -> PopupNode {
        return PopupNode(
            title: title,
            message: message,
            icon: icon,
            style: .error,
            buttons: .ok,
            screenSize: screenSize
        )
    }
    
    /// Create a level complete popup
    static func levelComplete(
        score: Int,
        stars: Int,
        screenSize: CGSize = CGSize(width: 400, height: 600)
    ) -> PopupNode {
        let starsText = String(repeating: "⭐", count: stars) + String(repeating: "☆", count: 3 - stars)
        let config = PopupConfiguration(
            title: "Level Complete!",
            message: "Score: \(score)\n\(starsText)",
            icon: "🎉",
            style: .success,
            size: .medium,
            buttons: .custom(["Continue", "Replay"])
        )
        
        return PopupNode(configuration: config, screenSize: screenSize)
    }
    
    /// Create a pause menu popup
    static func pauseMenu(screenSize: CGSize = CGSize(width: 400, height: 600)) -> PopupNode {
        let config = PopupConfiguration(
            title: "Game Paused",
            icon: "⏸️",
            style: .info,
            size: .medium,
            buttons: .custom(["Resume", "Main Menu"]),
            dismissOnBackgroundTap: false,
            showCloseButton: false
        )
        
        return PopupNode(configuration: config, screenSize: screenSize)
    }
}
