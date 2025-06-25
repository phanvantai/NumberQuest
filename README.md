# 🎮 NumberQuest – Math Adventure

[![iOS](https://img.shields.io/badge/iOS-13.0+-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.0+-orange.svg)](https://swift.org/)
[![SpriteKit](https://img.shields.io/badge/SpriteKit-Framework-green.svg)](https://developer.apple.com/spritekit/)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

## 🧩 Game Overview

NumberQuest is an action-packed, educational math game built with SpriteKit for smooth, animated gameplay on iOS and iPadOS. Designed for kids aged 5–10, it combines interactive math puzzles with an exciting adventure journey. Players explore vibrant worlds, solve problems, and unlock fun rewards—all while building strong math skills.

![NumberQuest Banner](Assets.xcassets/AppIcon.appiconset/icon-placeholder.png)

## 🌟 Core Game Modes

### 🗺 Campaign Mode – Adventure Trail

- **Explore magical lands** in a side-scrolling map full of animated levels
- **Progressive difficulty** with levels that unlock as players advance
- **Mini-games include:**
  - 🍎 Catch the falling answer
  - 🚪 Tap the correct door
  - 👾 Defeat number monsters
- **Story progression** with engaging characters and rewards
- **Guided learning** with levels that grow harder as skills improve

### ⚡️ Quick Play Mode – Lightning Math

- **Real-time adaptive difficulty** that adjusts to player performance
- **Smart algorithm** analyzes speed, accuracy, and streaks:
  - Fast & correct → harder problems, more distractions
  - Mistakes → slower pace, helpful tips, simplifications
- **Perfect for** brain warm-ups or short gaming sessions
- **Instant feedback** and dynamic challenge adjustment

## ✨ Key Features

- 🎨 **SpriteKit-powered** smooth animations and visual effects
- 🤖 **Adaptive difficulty** system keeps children challenged, never frustrated
- 🌈 **Colorful, playful UI** with custom characters and sound effects
- 🎁 **Reward system** - collect stars, outfits, pets, and bonus items
- 🧠 **Comprehensive math curriculum:**
  - Addition and subtraction
  - Multiplication basics
  - Number sense and patterns
  - Progressive skill building
- 👨‍👩‍👧 **Parent Mode** for progress tracking and learning goal setting
- 📱 **Cross-device compatibility** - optimized for both iPad and iPhone

## 👶 Accessibility & Design

- ✅ **Large touch targets** designed for small hands
- ✅ **Intuitive navigation** with clear visual feedback
- ✅ **Offline gameplay** - no internet connection required
- ✅ **Safe environment** - no ads, no in-app purchases, no external links
- ✅ **VoiceOver support** for accessibility
- ✅ **Multiple difficulty levels** to accommodate different skill levels

## 🛠 Technical Requirements

### System Requirements

- **iOS 13.0+** or **iPadOS 13.0+**
- **Xcode 12.0+** for development
- **Swift 5.0+**

### Frameworks Used

- **SpriteKit** - Game engine and animations
- **GameplayKit** - AI and procedural generation
- **AVFoundation** - Audio and sound effects
- **CoreData** - Progress and user data persistence

## 🚀 Getting Started

### Installation

1. **Clone the repository:**

   ```bash
   git clone https://github.com/yourusername/NumberQuest.git
   cd NumberQuest
   ```

2. **Open in Xcode:**

   ```bash
   open NumberQuest.xcodeproj
   ```

3. **Build and run:**
   - Select your target device or simulator
   - Press `Cmd + R` to build and run

### Project Structure

```text
NumberQuest/
├── GameScene.swift          # Main game scene controller
├── GameViewController.swift # View controller managing scenes
├── AppDelegate.swift        # App lifecycle management
├── GameScene.sks           # Visual scene editor file
├── Actions.sks             # SpriteKit actions and animations
├── Assets.xcassets/        # Images, icons, and visual assets
└── Base.lproj/            # Storyboards and localization
```

## 🎯 Development Roadmap

### Phase 1: Core Gameplay ✅

- [x] Basic SpriteKit setup
- [x] Scene management
- [x] Touch input handling
- [ ] Basic math problem generation

### Phase 2: Game Modes 🚧

- [ ] Campaign Mode implementation
- [ ] Quick Play Mode
- [ ] Level progression system
- [ ] Mini-game mechanics

### Phase 3: Advanced Features 📋

- [ ] Adaptive difficulty algorithm
- [ ] Reward and progression system
- [ ] Parent dashboard
- [ ] Sound effects and music
- [ ] Character customization

### Phase 4: Polish & Release 📋

- [ ] Performance optimization
- [ ] Accessibility improvements
- [ ] Beta testing with target audience
- [ ] App Store submission

## 🧪 Testing

### Running Tests

```bash
# Run unit tests
xcodebuild test -scheme NumberQuest -destination 'platform=iOS Simulator,name=iPhone 14'

# Run UI tests
xcodebuild test -scheme NumberQuestUITests -destination 'platform=iOS Simulator,name=iPad Air (5th generation)'
```

### Test Coverage

- **Unit Tests:** Math logic, difficulty algorithms, game state management
- **UI Tests:** User interactions, scene transitions, accessibility
- **Performance Tests:** Frame rate, memory usage, loading times

## 📖 Educational Curriculum

### Math Topics Covered

- **Number Recognition** (Ages 5-6)
- **Basic Addition** (Ages 6-7)
- **Basic Subtraction** (Ages 6-7)
- **Advanced Addition/Subtraction** (Ages 7-8)
- **Introduction to Multiplication** (Ages 8-9)
- **Number Patterns** (Ages 9-10)

### Learning Objectives

- Improve mental math speed and accuracy
- Build confidence with numbers
- Develop problem-solving strategies
- Foster positive associations with mathematics

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes and test thoroughly
4. Commit your changes: `git commit -m 'Add amazing feature'`
5. Push to the branch: `git push origin feature/amazing-feature`
6. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Lead Developer:** [Your Name](https://github.com/yourusername)
- **Educational Consultant:** [Consultant Name]
- **UI/UX Designer:** [Designer Name]

## 📞 Support

- **Issues:** [GitHub Issues](https://github.com/yourusername/NumberQuest/issues)
- **Email:** [support@numberquest.com](mailto:support@numberquest.com)
- **Documentation:** [Wiki](https://github.com/yourusername/NumberQuest/wiki)

## 🙏 Acknowledgments

- Thanks to the SpriteKit team for the amazing game framework
- Educational consultants who helped design the curriculum
- Beta testers and their families for valuable feedback
- The Swift community for resources and support

---

Made with ❤️ for young learners everywhere
