//
//  SettingsView.swift
//  NumberQuest
//
//  Created by TaiPV on 20/6/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var soundEnabled = true
    @State private var musicEnabled = true
    @State private var hapticEnabled = true
    @State private var showingResetAlert = false
    @State private var showingAbout = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.gray.opacity(0.3),
                        Color.black.opacity(0.5)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // Title
                        Text("⚙️ Settings")
                            .style(.gameTitle)
                            .padding(.top, 20)
                        
                        // Audio Settings
                        SettingsSection(title: "🔊 Audio") {
                            VStack(spacing: 15) {
                                SettingToggle(
                                    title: "Sound Effects",
                                    description: "Game sounds and feedback",
                                    isOn: $soundEnabled
                                )
                                
                                SettingToggle(
                                    title: "Background Music",
                                    description: "Relaxing background music",
                                    isOn: $musicEnabled
                                )
                            }
                        }
                        
                        // Gameplay Settings
                        SettingsSection(title: "🎮 Gameplay") {
                            VStack(spacing: 15) {
                                SettingToggle(
                                    title: "Haptic Feedback",
                                    description: "Vibration for correct/incorrect answers",
                                    isOn: $hapticEnabled
                                )
                                
                                SettingButton(
                                    title: "Parent Dashboard",
                                    description: "View detailed progress reports",
                                    icon: "person.2.fill"
                                ) {
                                    // Open parent dashboard
                                }
                            }
                        }
                        
                        // Data Settings
                        SettingsSection(title: "💾 Data") {
                            VStack(spacing: 15) {
                                SettingButton(
                                    title: "Reset Progress",
                                    description: "Clear all game progress and start over",
                                    icon: "arrow.clockwise",
                                    isDestructive: true
                                ) {
                                    showingResetAlert = true
                                }
                                
                                SettingButton(
                                    title: "Export Progress",
                                    description: "Save your progress to share or backup",
                                    icon: "square.and.arrow.up"
                                ) {
                                    // Export progress
                                }
                            }
                        }
                        
                        // App Info
                        SettingsSection(title: "ℹ️ About") {
                            VStack(spacing: 15) {
                                SettingButton(
                                    title: "About NumberQuest",
                                    description: "Learn more about the app",
                                    icon: "info.circle"
                                ) {
                                    showingAbout = true
                                }
                                
                                SettingButton(
                                    title: "Rate the App",
                                    description: "Help us improve by leaving a review",
                                    icon: "star.fill"
                                ) {
                                    // Open App Store rating
                                }
                                
                                SettingButton(
                                    title: "Privacy Policy",
                                    description: "How we protect your data",
                                    icon: "lock.shield"
                                ) {
                                    // Open privacy policy
                                }
                            }
                        }
                        
                        // Version info
                        Text("Version 1.0.0")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                            .padding(.top, 20)
                        
                        Spacer(minLength: 100)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            )
            .navigationBarTitle("", displayMode: .inline)
        }
        .alert("Reset Progress", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetProgress()
            }
        } message: {
            Text("This will permanently delete all your progress, including stars, badges, and level completion. This action cannot be undone.")
        }
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
    
    private func resetProgress() {
        UserDefaults.standard.removeObject(forKey: "PlayerProgress")
        GameData.shared.playerProgress = PlayerProgress()
        GameData.shared.objectWillChange.send()
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text(title)
                .style(.title)
            
            VStack(spacing: 12) {
                content
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white.opacity(0.15))
            )
        }
    }
}

struct SettingToggle: View {
    let title: String
    let description: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .style(.heading)
                
                Text(description)
                    .style(.caption)
            }
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
        }
    }
}

struct SettingButton: View {
    let title: String
    let description: String
    let icon: String
    var isDestructive: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isDestructive ? .red : .blue)
                    .frame(width: 25)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .style(.heading)
                        .foregroundColor(isDestructive ? .red : .white)
                    
                    Text(description)
                        .style(.caption)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
}

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.3),
                        Color.purple.opacity(0.5)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // App icon and title
                        VStack(spacing: 20) {
                            Text("🔢")
                                .font(.system(size: 80))
                            
                            Text("NumberQuest")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Math Adventure")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 40)
                        
                        // Description
                        VStack(spacing: 20) {
                            Text("About NumberQuest")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("NumberQuest is a fun and educational math adventure game designed for kids ages 5–10. With colorful graphics, friendly characters, and adaptive difficulty, children can explore magical lands while building essential math skills.")
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                        }
                        .padding(.horizontal, 20)
                        
                        // Features
                        VStack(spacing: 15) {
                            Text("✨ Features")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                FeatureRow(icon: "🌍", text: "Campaign Mode with beautiful levels")
                                FeatureRow(icon: "⚡️", text: "Quick Play with adaptive difficulty")
                                FeatureRow(icon: "🏆", text: "Stars and badges reward system")
                                FeatureRow(icon: "📊", text: "Progress tracking for parents")
                                FeatureRow(icon: "🎨", text: "Colorful and kid-friendly design")
                                FeatureRow(icon: "📱", text: "Works perfectly on iPad & iPhone")
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Credits
                        VStack(spacing: 15) {
                            Text("👨‍💻 Created by")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("TaiPV")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.9))
                            
                            Text("Made with ❤️ and SwiftUI")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding(.horizontal, 20)
                }
            }
            .navigationBarItems(
                trailing: Button("Done") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.white)
            )
            .navigationBarTitle("", displayMode: .inline)
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Text(icon)
                .font(.title3)
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
    }
}

#Preview {
    SettingsView()
}
