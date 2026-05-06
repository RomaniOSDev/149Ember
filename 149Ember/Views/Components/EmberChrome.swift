//
//  EmberChrome.swift
//  149Ember
//

import SwiftUI

// MARK: - Screen backdrop

struct EmberScreenBackground: View {
    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.07, green: 0.09, blue: 0.13),
                    Color.emberBackground,
                    Color(red: 0.04, green: 0.05, blue: 0.08)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            RadialGradient(
                colors: [Color.emberPositive.opacity(0.16), Color.clear],
                center: .topLeading,
                startRadius: 20,
                endRadius: 340
            )

            RadialGradient(
                colors: [Color.emberNegative.opacity(0.1), Color.clear],
                center: .bottomTrailing,
                startRadius: 20,
                endRadius: 300
            )
        }
        .ignoresSafeArea()
    }
}

// MARK: - Glass panel (cards, sections)

struct EmberGlassPanelModifier: ViewModifier {
    var cornerRadius: CGFloat = 16
    var accent: Color = .emberPositive
    var glowOpacity: Double = 0.16

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.1),
                                Color.emberBackground.opacity(0.55),
                                Color.black.opacity(0.25)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .background(
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(Color.emberBackground.opacity(0.35))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                accent.opacity(0.42),
                                Color.white.opacity(0.06),
                                accent.opacity(0.12)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            )
            .shadow(color: Color.black.opacity(0.45), radius: 16, x: 0, y: 12)
            .shadow(color: accent.opacity(glowOpacity), radius: 24, x: 0, y: 6)
    }
}

extension View {
    func emberGlassPanel(cornerRadius: CGFloat = 16, accent: Color = .emberPositive) -> some View {
        modifier(EmberGlassPanelModifier(cornerRadius: cornerRadius, accent: accent))
    }
}

// MARK: - Primary CTA (filled)

struct EmberPrimaryButtonModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.emberPositive, Color.emberPositive.opacity(0.72)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .stroke(Color.white.opacity(0.22), lineWidth: 1)
                        .padding(1)
                }
            )
            .shadow(color: Color.emberPositive.opacity(0.45), radius: 12, x: 0, y: 6)
            .shadow(color: Color.black.opacity(0.35), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func emberPrimaryButtonShape() -> some View {
        modifier(EmberPrimaryButtonModifier())
    }
}

// MARK: - Outline / secondary button

struct EmberOutlineButtonModifier: ViewModifier {
    var accent: Color = .emberPositive

    func body(content: Content) -> some View {
        content
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.emberBackground.opacity(0.4))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [accent.opacity(0.85), accent.opacity(0.25)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1.5
                    )
            )
            .shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

extension View {
    func emberOutlineButtonShape(accent: Color = .emberPositive) -> some View {
        modifier(EmberOutlineButtonModifier(accent: accent))
    }
}
