//
//  AnimationHelpers.swift
//  NumberQuest
//
//  Created by TaiPV on 20/6/25.
//

import SwiftUI

// MARK: - Custom Animation Extensions
extension Animation {
    static let bouncy = Animation.spring(response: 0.6, dampingFraction: 0.8, blendDuration: 0)
    static let gentle = Animation.easeInOut(duration: 0.3)
    static let quick = Animation.easeInOut(duration: 0.15)
}

// MARK: - Particle Effect View
struct ParticleEffect: View {
    let particleCount: Int
    let colors: [Color]
    @State private var animate = false
    
    init(particleCount: Int = 20, colors: [Color] = [.yellow, .orange, .red]) {
        self.particleCount = particleCount
        self.colors = colors
    }
    
    var body: some View {
        ZStack {
            ForEach(0..<particleCount, id: \.self) { index in
                Circle()
                    .fill(colors.randomElement() ?? .yellow)
                    .frame(width: CGFloat.random(in: 4...12))
                    .offset(
                        x: animate ? CGFloat.random(in: -150...150) : 0,
                        y: animate ? CGFloat.random(in: -150...150) : 0
                    )
                    .opacity(animate ? 0 : 1)
                    .animation(
                        .easeOut(duration: 1.5)
                        .delay(Double(index) * 0.05),
                        value: animate
                    )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

// MARK: - Floating Number Effect
struct FloatingNumber: View {
    let number: String
    let color: Color
    @State private var offset: CGFloat = 0
    @State private var opacity: Double = 1
    
    var body: some View {
        Text(number)
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(color)
            .offset(y: offset)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeOut(duration: 1.5)) {
                    offset = -100
                    opacity = 0
                }
            }
    }
}

// MARK: - Shake Effect
struct ShakeEffect: GeometryEffect {
    var amount: CGFloat = 10
    var shakesPerUnit = 3
    var animatableData: CGFloat
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX:
            amount * sin(animatableData * .pi * CGFloat(shakesPerUnit)),
            y: 0))
    }
}

extension View {
    func shake(with attempts: Int) -> some View {
        modifier(ShakeEffect(animatableData: CGFloat(attempts)))
    }
}

// MARK: - Pulse Effect
struct PulseEffect: ViewModifier {
    @State private var scale: CGFloat = 1.0
    let duration: Double
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: duration)
                    .repeatForever(autoreverses: true)
                ) {
                    scale = 1.2
                }
            }
    }
}

extension View {
    func pulse(duration: Double = 1.0) -> some View {
        modifier(PulseEffect(duration: duration))
    }
}

// MARK: - Glow Effect
struct GlowEffect: ViewModifier {
    let color: Color
    let radius: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
            .shadow(color: color, radius: radius / 3)
    }
}

extension View {
    func glow(color: Color = .white, radius: CGFloat = 20) -> some View {
        modifier(GlowEffect(color: color, radius: radius))
    }
}

// MARK: - Bounce Animation
struct BounceAnimation: ViewModifier {
    @State private var bounced = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(bounced ? 1.0 : 0.8)
            .onAppear {
                withAnimation(.bouncy) {
                    bounced = true
                }
            }
    }
}

extension View {
    func bounceOnAppear() -> some View {
        modifier(BounceAnimation())
    }
}

// MARK: - Typewriter Effect
struct TypewriterText: View {
    let text: String
    let speed: Double
    @State private var displayedText = ""
    @State private var currentIndex = 0
    
    init(_ text: String, speed: Double = 0.05) {
        self.text = text
        self.speed = speed
    }
    
    var body: some View {
        Text(displayedText)
            .onAppear {
                startTypewriter()
            }
    }
    
    private func startTypewriter() {
        Timer.scheduledTimer(withTimeInterval: speed, repeats: true) { timer in
            if currentIndex < text.count {
                let index = text.index(text.startIndex, offsetBy: currentIndex)
                displayedText += String(text[index])
                currentIndex += 1
            } else {
                timer.invalidate()
            }
        }
    }
}

// MARK: - Confetti Effect
struct ConfettiView: View {
    @State private var animate = false
    let colors: [Color] = [.red, .green, .blue, .orange, .pink, .purple, .yellow]
    
    var body: some View {
        ZStack {
            ForEach(0..<50, id: \.self) { index in
                ConfettiPiece(
                    color: colors[index % colors.count],
                    delay: Double(index) * 0.02
                )
            }
        }
        .onAppear {
            animate = true
        }
    }
}

struct ConfettiPiece: View {
    let color: Color
    let delay: Double
    @State private var animate = false
    
    var body: some View {
        Rectangle()
            .fill(color)
            .frame(width: 8, height: 8)
            .offset(
                x: animate ? CGFloat.random(in: -200...200) : 0,
                y: animate ? CGFloat.random(in: -300...300) : -100
            )
            .rotationEffect(.degrees(animate ? Double.random(in: 0...360) : 0))
            .opacity(animate ? 0 : 1)
            .animation(
                .easeOut(duration: 2.0).delay(delay),
                value: animate
            )
            .onAppear {
                animate = true
            }
    }
}
