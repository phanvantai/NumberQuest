# NumberQuest - Copilot Instructions

## Project Overview
NumberQuest is a fun, educational math adventure game for kids (ages 5-10) built with SwiftUI for iOS/iPadOS. The app features campaign and quick play modes, adaptive difficulty, friendly characters, and a colorful, engaging UI.

## Architecture & Structure

### Project Structure
```
NumberQuest/
├── Models/
│   ├── GameModels.swift      # Core game data models
│   └── GameData.swift        # Game data management
├── Views/
│   ├── MainMenuView.swift    # Main menu screen
│   ├── CampaignMapView.swift # Campaign level selection
│   ├── QuickPlayView.swift   # Quick play configuration
│   ├── GameView.swift        # Main game screen
│   ├── GameOverView.swift    # Game completion screen
│   ├── ProgressView.swift    # Player progress tracking
│   └── SettingsView.swift    # App settings
├── Characters/
│   └── GameCharacters.swift  # Character definitions
├── Utilities/
│   ├── TextStyles.swift      # Centralized text styling
│   ├── SoundManager.swift    # Audio management
│   └── AnimationHelpers.swift # Animation utilities
└── Resources/
    └── Fonts/
        ├── Chewy-Regular.ttf
        └── Baloo2-VariableFont_wght.ttf
```

## Code Standards & Conventions

### SwiftUI Patterns
- Use `@StateObject` for view models and data managers
- Use `@EnvironmentObject` for shared data (GameData)
- Prefer `@State` for local view state
- Use `@Binding` for two-way data binding
- Always use `@Environment(\.presentationMode)` for dismissal

### UI Design Principles
- **Colorful & Kid-Friendly**: Use bright gradients and vibrant colors
- **Accessibility**: Large touch targets, clear contrast
- **Responsive**: Support both iPhone and iPad
- **Scrollable**: Use ScrollView for content that might overflow

### Text Styling System
Always use the centralized text styling system from `TextStyles.swift`:

```swift
// ✅ Good - Use centralized styles
Text("Game Title")
    .style(.gameTitle)

// ❌ Avoid - Direct font styling
Text("Game Title")
    .font(.system(size: 42, weight: .bold))
    .foregroundColor(.white)
```

#### Available Text Styles
- `.gameTitle` - Large title text (Chewy font, 42pt)
- `.title` - Section titles (Chewy font, 28pt)
- `.subtitle` - Subtitles (Chewy font, 22pt)
- `.heading` - Headings (Chewy font, 18pt)
- `.body` - Body text (Baloo2 font, 16pt)
- `.bodySecondary` - Secondary body text
- `.caption` - Small text (Baloo2 font, 14pt)
- `.buttonLarge` - Large button text
- `.buttonMedium` - Medium button text
- `.questionText` - Math question display
- `.answerText` - Answer options
- `.scoreText` - Score display

### Custom Fonts
- **Primary Font**: Chewy-Regular (for titles, headings, buttons)
- **Secondary Font**: Baloo2-VariableFont_wght (for body text, better readability)
- **Fallback**: System font with .rounded design

## Game Logic

### Core Models
- `GameLevel`: Represents a campaign level with difficulty, operations, and completion status
- `MathQuestion`: Contains question text, correct answer, and wrong options
- `GameSession`: Manages active game state, score, and progress
- `PlayerProgress`: Tracks overall player statistics and achievements

### Game Modes
1. **Campaign Mode**: Structured levels with star rewards
2. **Quick Play Mode**: Customizable quick sessions with adaptive difficulty

### Difficulty System
- `GameDifficulty`: .easy, .medium, .hard, .expert
- Adaptive difficulty adjusts based on player performance
- Each difficulty has number ranges for math operations

## UI Components

### Common Patterns
- Use `LinearGradient` backgrounds for visual appeal
- Implement `RoundedRectangle` with opacity overlays for cards
- Add shadow effects for depth: `.shadow(color: .opacity(0.3), radius: 10)`
- Use `Spacer(minLength: 100)` for bottom padding in ScrollViews

### Button Styles
```swift
// Standard game button pattern
Button(action: action) {
    Text("Button Text")
        .style(.buttonLarge)
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.green.opacity(0.8))
                .shadow(color: .green.opacity(0.3), radius: 10, x: 0, y: 5)
        )
}
```

### Navigation
- Use `NavigationView` and `NavigationLink` for flow
- Custom back buttons with `navigationBarBackButtonHidden(true)`
- Sheet presentations for modal screens

## Animation & Feedback

### Animation Helpers
- Use `AnimationHelpers.swift` for consistent animations
- Spring animations for interactive elements
- Scale effects for button press feedback

### Sound Management
- `SoundManager.swift` handles all audio
- Separate methods for UI sounds vs. game sounds
- Background music management

## Data Persistence

### UserDefaults Keys
- `"PlayerProgress"` - Stores player statistics
- Settings preferences (sound, music, haptic feedback)

### Game Data
- `GameData.shared` - Singleton for global game state
- Level progression and unlock logic
- Star and badge tracking

## Performance Guidelines

### Memory Management
- Use `@StateObject` for data that owns its lifecycle
- Prefer `@ObservedObject` for passed-in data
- Clean up timers and observers in `onDisappear`

### Rendering
- Use `LazyVGrid` for large collections
- Implement proper preview providers for all views
- Use `@ViewBuilder` for complex conditional layouts

## Testing & Previews

### Preview Requirements
- Every View must have a `#Preview` block
- Use sample data for complex models
- Test both iPhone and iPad layouts when relevant

### Example Preview Pattern
```swift
#Preview {
    GameView(gameMode: .campaign, level: sampleLevel)
        .environmentObject(GameData.shared)
}
```

## Accessibility Considerations

### Design for Kids
- Large touch targets (minimum 44pt)
- High contrast text
- Simple, clear navigation
- Forgiving interaction patterns

### Voice Over Support
- Meaningful accessibility labels
- Proper heading hierarchy
- Descriptive button titles

## Error Handling

### Common Patterns
- Graceful degradation for missing data
- User-friendly error messages
- Fallback UI states for loading/empty states

## When Adding New Features

1. **Follow the existing architecture** - New views in Views/, models in Models/
2. **Use the text styling system** - Apply `.style()` modifiers consistently
3. **Maintain visual consistency** - Use established color schemes and layouts
4. **Add proper previews** - Include preview blocks for all new views
5. **Consider accessibility** - Ensure new features work for all users
6. **Update this documentation** - Keep instructions current with new patterns

## Common Code Patterns

### View Structure Template
```swift
struct NewView: View {
    @EnvironmentObject var gameData: GameData
    @Environment(\.presentationMode) var presentationMode
    @State private var localState = defaultValue
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(/* gradient config */)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Content here
                }
                .padding(.horizontal, 20)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: backButton)
    }
    
    private var backButton: some View {
        // Standard back button implementation
    }
}
```

Remember: This is a kids' educational app - prioritize fun, accessibility, and clear visual design in all implementations!