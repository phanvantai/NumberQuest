# NumberQuest - Math Adventure Game

## Project Overview
NumberQuest is an educational iOS game built with SpriteKit, targeting children aged 5-10. It combines math learning with adventure gameplay through two main modes: Campaign Mode (adventure trail) and Quick Play Mode (lightning math).

## Technology Stack
- **Platform**: iOS/iPadOS
- **Language**: Swift
- **Framework**: SpriteKit for game engine and animations
- **IDE**: Xcode
- **Target Audience**: Children aged 5-10
- **Architecture**: MVC with SpriteKit scenes

## Key Components
- `GameScene.swift` - Main game scene controller
- `GameViewController.swift` - View controller managing game scenes
- `AppDelegate.swift` - App lifecycle management
- `GameScene.sks` - Visual scene editor file
- `Actions.sks` - SpriteKit actions and animations

## Game Features to Implement
### Campaign Mode
- Side-scrolling adventure map
- Progressive level unlocking
- Mini-games: catch falling answers, tap correct doors, defeat number monsters
- Story progression and character development

### Quick Play Mode
- Real-time adaptive difficulty
- Speed and accuracy analysis
- Dynamic problem adjustment
- Help tips and simplifications

### Core Systems
- Adaptive difficulty engine
- Progress tracking
- Reward system (stars, outfits, pets)
- Parent mode for progress monitoring
- Math curriculum covering addition, subtraction, multiplication, number sense

## Coding Guidelines
1. **Swift Best Practices**
   - Use proper naming conventions (camelCase for variables/functions, PascalCase for types)
   - Leverage Swift's type safety and optionals
   - Use extensions for organizing code
   - Implement proper error handling

2. **SpriteKit Patterns**
   - Use SKScene for different game screens
   - Implement SKAction for animations
   - Use physics bodies for collision detection
   - Organize sprites with proper z-positioning

3. **Game Architecture**
   - Separate game logic from presentation
   - Use delegation pattern for scene transitions
   - Implement state machines for game states
   - Create reusable components for UI elements

4. **Performance Considerations**
   - Optimize texture atlases
   - Use object pooling for frequently created/destroyed objects
   - Implement proper memory management
   - Profile performance on target devices

5. **Accessibility**
   - Large touch targets for small hands
   - Clear visual feedback
   - Support for VoiceOver when appropriate
   - Simple, intuitive navigation

## Code Organization
- Keep game scenes focused and single-purpose
- Create utility classes for math operations
- Implement data persistence for progress tracking
- Use enums for game states and difficulty levels
- Create custom SKNode subclasses for reusable game objects

## Testing Approach
- Unit tests for math logic and difficulty algorithms
- UI tests for game flow and interactions
- Performance testing on various iOS devices
- Accessibility testing for target age group

## When Helping with Code
- Always consider the target age group (5-10) when suggesting UI/UX improvements
- Focus on educational value while maintaining fun gameplay
- Ensure code is maintainable and well-documented
- Consider iPad and iPhone compatibility
- Prioritize smooth animations and responsive touch controls
- Think about parental controls and progress tracking features