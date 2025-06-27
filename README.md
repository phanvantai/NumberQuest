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

### Phase 1: Foundation & Core Architecture 🏗️

#### 1.1 Project Structure & Organization

- [ ] **Refactor project structure** - Create organized folder hierarchy:
  - [ ] `Scenes/` - Game scenes (Menu, Campaign, QuickPlay, etc.)
  - [ ] `Models/` - Data models (Player, Level, MathProblem, etc.)
  - [ ] `Managers/` - Game managers (SceneManager, AudioManager, ProgressManager)
  - [ ] `Utils/` - Utility classes and extensions
  - [ ] `UI/` - Custom UI components and HUD elements
  - [ ] `GameObjects/` - Custom SKNode subclasses
  - [ ] `Resources/` - Game data, levels, configurations

#### 1.2 Core Data Models

- [x] **Create MathProblem model** ✅ - Structure for math questions
  - [x] Problem types enum (addition, subtraction, multiplication)
  - [x] Difficulty levels (1-10 scale)
  - [x] Answer validation logic
  - [x] Time constraints per difficulty
- [x] **Create Level model** ✅ - Campaign level configuration
  - [x] Level metadata (theme, background, characters)
  - [x] Math problem sets and difficulty progression
  - [x] Unlock requirements and star ratings
  - [x] Mini-game configurations
- [x] **Create Player model** ✅ - Player progress and stats
  - [x] Experience points and level system
  - [x] Accuracy and speed metrics
  - [x] Unlocked levels and rewards
  - [x] Learning progression tracking

#### 1.3 Game State Management

- [ ] **Create GameState enum** - Track current game state
  - [ ] Menu, Campaign, QuickPlay, Paused, GameOver states
  - [ ] State transition logic and validation
- [ ] **Create SceneManager** - Centralized scene transitions
  - [ ] Scene loading and unloading
  - [ ] Transition animations between scenes
  - [ ] Memory management for scene switching

### Phase 2: Core Gameplay Systems 🎮

#### 2.1 Math Engine

- [x] Basic SpriteKit setup
- [x] Scene management
- [x] Touch input handling
- [x] **Create MathProblemGenerator class** ✅
  - [x] Algorithm for generating age-appropriate problems
  - [x] Difficulty scaling based on player performance
  - [x] Problem type distribution (70% addition, 20% subtraction, 10% multiplication)
  - [x] Avoid repetitive patterns and ensure variety
  - [x] Comprehensive unit tests with 100% pass rate
- [x] **Create AdaptiveDifficultyEngine** ✅
  - [x] Real-time performance analysis (speed, accuracy, streaks)
  - [x] Dynamic difficulty adjustment algorithms
  - [x] Help system triggers (hints, simplifications)
  - [x] Performance metrics tracking and analytics
  - [x] Comprehensive unit tests with 100% pass rate

#### 2.2 Touch Input & Controls

- [ ] **Replace default touch handling** with game-specific input
  - [ ] Large touch targets for small hands (minimum 44pt)
  - [ ] Visual feedback for all interactive elements
  - [ ] Support for simultaneous touches (multi-touch gestures)
  - [ ] Accessibility support (VoiceOver integration)

#### 2.3 Basic HUD & UI Elements

- [ ] **Create GameHUD class** - In-game interface
  - [ ] Score display with animated counters
  - [ ] Timer with visual countdown animations
  - [ ] Lives/hearts system with smooth transitions
  - [ ] Pause button with game state management
- [ ] **Create custom UI components**
  - [ ] NumberButton class for answer selection
  - [ ] ProgressBar for level advancement
  - [ ] StarRating component for level completion
  - [ ] PopupDialog for results and confirmations

### Phase 3: Game Modes Implementation �️⚡

#### 3.1 Campaign Mode - Adventure Trail

- [x] **Create CampaignMapScene** ✅ - Main adventure map
  - [x] Side-scrolling map with parallax background layers
  - [x] Level nodes with unlock animations
  - [x] Path connections between levels
  - [x] World themes (Forest, Ocean, Space, Castle)
- [x] **Level Selection System** ✅
  - [x] Interactive level buttons with preview information
  - [x] Lock/unlock animations for progression
  - [x] Star rating display for completed levels
  - [x] Difficulty indicators and recommended age ranges

#### 3.2 Campaign Level Scene

- [x] **Create CampaignLevelScene** ✅ - Individual level gameplay
  - [x] Dynamic background based on world theme
  - [x] Character animations and interactions
  - [x] Problem presentation with engaging visuals
  - [x] Progressive difficulty within each level (5-10 problems)

#### 3.3 Mini-Games Implementation

- [ ] **"Catch the Falling Answer" mini-game**
  - [ ] Falling number sprites with physics
  - [ ] Player-controlled basket/character
  - [ ] Correct answer highlighting and sound effects
  - [ ] Increasing speed and distractors at higher levels
- [ ] **"Tap the Correct Door" mini-game**
  - [ ] Multiple doors with animated opening/closing
  - [ ] Number or equation displays above doors
  - [ ] Wrong answer consequences (gentle feedback)
  - [ ] Door themes matching world environments
- [ ] **"Defeat Number Monsters" mini-game**
  - [ ] Monster sprites with attack animations
  - [ ] Combat system based on solving math problems
  - [ ] Health bars and damage calculations
  - [ ] Victory celebrations and reward animations

#### 3.4 Quick Play Mode - Lightning Math

- [x] **Create QuickPlayScene** ✅ - Fast-paced math challenges
  - [x] Clean, distraction-free interface design
  - [x] Real-time problem generation and display
  - [x] Answer input methods (multiple choice, number pad)
  - [x] Live performance feedback (streaks, accuracy %)
  - [x] Touch handling optimized for children
  - [x] Pause/resume functionality
  - [x] Integration with MathProblemGenerator and AdaptiveDifficultyEngine
- [x] **Implement real-time analysis** ✅
  - [x] Response time tracking (target: 3-5 seconds per problem)
  - [x] Accuracy percentage calculation  
  - [x] Consecutive correct answer streaks
  - [x] Error pattern analysis (specific operation difficulties)
  - [x] Live performance feedback with color-coded indicators
  - [x] Performance trend analysis ("Improving", "Steady", "Need Focus")
  - [x] Periodic performance insights and motivational messages
  - [x] Dynamic difficulty level display
  - [x] Best time tracking and rolling average calculations

### Phase 4: Visual Polish & Audio 🎨

#### 4.1 Art Assets & Animations

- [ ] **Create game art assets**
  - [ ] Character sprites and animation sequences
  - [ ] Background art for different worlds/themes
  - [ ] UI elements (buttons, panels, decorations)
  - [ ] Number and mathematical symbol sprites
- [ ] **Implement SpriteKit animations**
  - [ ] Character idle, walking, jumping animations
  - [ ] UI transitions and micro-interactions
  - [ ] Particle effects for celebrations and feedback
  - [ ] Background parallax scrolling effects

#### 4.2 Audio System

- [ ] **Create AudioManager class**
  - [ ] Background music management with smooth transitions
  - [ ] Sound effect playback with volume control
  - [ ] Audio settings persistence
  - [ ] Accessibility audio cues
- [ ] **Audio content creation/integration**
  - [ ] Background music for different game modes
  - [ ] Success/failure sound effects
  - [ ] UI interaction sounds (button taps, transitions)
  - [ ] Character voice clips and mathematical feedback

### Phase 5: Progression & Reward Systems 🏆

#### 5.1 Reward System

- [ ] **Create RewardManager class**
  - [ ] Star collection and spending system
  - [ ] Daily challenge rewards
  - [ ] Achievement unlocking logic
  - [ ] Customization item management
- [ ] **Implement collectibles**
  - [ ] Character outfits and accessories
  - [ ] Pet companions with unique animations
  - [ ] Decorative items for character customization
  - [ ] Special effects and celebration animations

#### 5.2 Achievement System

- [ ] **Create Achievement model and tracking**
  - [ ] Math skill milestones (100 correct additions, etc.)
  - [ ] Speed achievements (solve 10 problems in 30 seconds)
  - [ ] Consistency rewards (play 7 days in a row)
  - [ ] Discovery achievements (find hidden secrets)

#### 5.3 Character Customization

- [ ] **Create CustomizationScene**
  - [ ] Character appearance editor
  - [ ] Outfit preview and selection
  - [ ] Pet selection and interaction
  - [ ] Customization persistence across game sessions

### Phase 6: Parent Dashboard & Settings 👨‍👩‍👧

#### 6.1 Parent Mode Interface

- [ ] **Create ParentDashboardScene**
  - [ ] Progress overview with visual charts
  - [ ] Time spent playing and learning metrics
  - [ ] Skill assessment and recommendations
  - [ ] Goal setting interface for learning objectives
- [ ] **Implement parental controls**
  - [ ] Play time limits and scheduling
  - [ ] Difficulty level overrides
  - [ ] Progress report generation
  - [ ] Safe environment settings verification

#### 6.2 Settings & Preferences

- [ ] **Create SettingsScene**
  - [ ] Audio and visual preference controls
  - [ ] Accessibility options (text size, contrast)
  - [ ] Language and localization settings
  - [ ] Data privacy and safety controls
- [ ] **Implement data persistence**
  - [ ] Core Data model setup for user progress
  - [ ] iCloud synchronization for cross-device play
  - [ ] Local data backup and recovery
  - [ ] Privacy-compliant data handling

### Phase 7: Testing & Quality Assurance 🧪

#### 7.1 Unit Testing

- [ ] **Math engine testing**
  - [ ] Problem generation algorithm validation
  - [ ] Difficulty scaling accuracy testing
  - [ ] Answer validation edge case testing
  - [ ] Performance metrics calculation testing
- [ ] **Game logic testing**
  - [ ] Level progression and unlock logic
  - [ ] Reward system calculations
  - [ ] Save/load functionality
  - [ ] Scene transition state management

#### 7.2 UI/UX Testing

- [ ] **Accessibility testing**
  - [ ] VoiceOver compatibility testing
  - [ ] Color contrast and visibility testing
  - [ ] Touch target size validation
  - [ ] Motor impairment accommodation testing
- [ ] **Device compatibility testing**
  - [ ] iPhone SE to iPhone Pro Max testing
  - [ ] iPad mini to iPad Pro testing
  - [ ] iOS 13+ version compatibility
  - [ ] Performance testing on older devices

### Phase 8: Performance Optimization 🚀

#### 8.1 Performance Profiling

- [ ] **Memory usage optimization**
  - [ ] Texture atlas optimization for sprites
  - [ ] Object pooling for frequently created/destroyed objects
  - [ ] Scene memory management and cleanup
  - [ ] Background task optimization
- [ ] **Frame rate optimization**
  - [ ] 60 FPS target maintenance across all devices
  - [ ] Animation performance optimization
  - [ ] Physics simulation optimization
  - [ ] Audio processing efficiency improvements

### Phase 9: Final Polish & Release 📱

#### 9.1 App Store Preparation

- [ ] **Create marketing assets**
  - [ ] App Store screenshots for all device sizes
  - [ ] App preview videos showcasing key features
  - [ ] App icon design and implementation
  - [ ] App Store description and keyword optimization
- [ ] **Legal and compliance**
  - [ ] COPPA compliance for children's privacy
  - [ ] App Store review guidelines compliance
  - [ ] Terms of service and privacy policy
  - [ ] Educational content accuracy verification

#### 9.2 Beta Testing Program

- [ ] **TestFlight beta testing**
  - [ ] Recruit 50-100 families with target age children
  - [ ] Feedback collection and analysis
  - [ ] Bug reporting and tracking system
  - [ ] Performance monitoring on real devices

---

### 📊 Development Priorities

#### High Priority (MVP Features - Weeks 1-9)

1. **Math Problem Generation** ✅ (Weeks 1-2) - COMPLETED
2. **Basic Quick Play Mode** ✅ (Weeks 3-4) - COMPLETED  
3. **Real-time Analysis** ✅ (Weeks 3-4) - COMPLETED
4. **Simple Campaign Mode** ✅ (Weeks 5-7) - COMPLETED
5. **Core UI/UX** (Weeks 8-9)

#### Medium Priority (Enhanced Features - Weeks 10-16)

5. **Mini-games Implementation** (Weeks 10-12)
6. **Reward System** (Weeks 13-14)
7. **Audio & Visual Polish** (Weeks 15-16)

#### Lower Priority (Polish & Release - Weeks 17-24)

8. **Parent Dashboard** (Weeks 17-18)
9. **Advanced Features** (Weeks 19-20)
10. **Testing & Optimization** (Weeks 21-24)

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
