//
//  OnboardingView.swift
//  149Ember
//

import SwiftUI

private struct OnboardingPageData: Identifiable {
    let id: Int
    let symbol: String
    let title: String
    let subtitle: String
    let accent: Color
    let ringColors: [Color]
}

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var page = 0

    private let pages: [OnboardingPageData] = [
        OnboardingPageData(
            id: 0,
            symbol: "waveform.path.ecg",
            title: "Log emotional waves",
            subtitle: "Note strong feelings, intensity, triggers, and what helped — in seconds.",
            accent: .emberNegative,
            ringColors: [.emberNegative, .emberPositive.opacity(0.6)]
        ),
        OnboardingPageData(
            id: 1,
            symbol: "chart.line.uptrend.xyaxis",
            title: "See your patterns",
            subtitle: "Balance over the week, top triggers, and insights update as you add entries.",
            accent: .emberPositive,
            ringColors: [.emberPositive, .emberPositive.opacity(0.35)]
        ),
        OnboardingPageData(
            id: 2,
            symbol: "lock.shield.fill",
            title: "Stays on your phone",
            subtitle: "No sign-in, no cloud sync — everything is stored locally on this device.",
            accent: .emberPositive,
            ringColors: [.emberPositive.opacity(0.55), .gray.opacity(0.4)]
        )
    ]

    var body: some View {
        ZStack {
            EmberScreenBackground()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button("Skip") {
                        onComplete()
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.gray)
                    .padding(.trailing, 20)
                    .padding(.top, 4)
                }

                TabView(selection: $page) {
                    ForEach(pages) { data in
                        pageContent(data)
                            .tag(data.id)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                pageIndicator
                    .padding(.vertical, 16)

                bottomBar
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
            }
        }
    }

    private func pageContent(_ data: OnboardingPageData) -> some View {
        VStack(spacing: 28) {
            Spacer(minLength: 8)

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [data.accent.opacity(0.35), Color.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 120
                        )
                    )
                    .frame(width: 220, height: 220)

                Circle()
                    .stroke(
                        LinearGradient(colors: data.ringColors, startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: 3
                    )
                    .frame(width: 132, height: 132)
                    .shadow(color: data.accent.opacity(0.45), radius: 16, y: 8)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.12),
                                Color.emberBackground.opacity(0.9)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 112, height: 112)
                    .overlay(
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
                    .shadow(color: Color.black.opacity(0.5), radius: 12, y: 6)

                Image(systemName: data.symbol)
                    .font(.system(size: 44, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [data.accent, data.accent.opacity(0.65)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            VStack(spacing: 12) {
                Text(data.title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.88)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text(data.subtitle)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 28)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 24)
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 8) {
            ForEach(0..<pages.count, id: \.self) { index in
                Capsule()
                    .fill(index == page ? Color.emberPositive : Color.white.opacity(0.2))
                    .frame(width: index == page ? 22 : 7, height: 7)
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: page)
            }
        }
    }

    private var bottomBar: some View {
        HStack(spacing: 14) {
            if page > 0 {
                Button {
                    withAnimation { page -= 1 }
                } label: {
                    Text("Back")
                        .font(.headline.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .foregroundColor(.emberPositive)
                        .emberOutlineButtonShape()
                }
            }

            Button {
                if page >= pages.count - 1 {
                    onComplete()
                } else {
                    withAnimation { page += 1 }
                }
            } label: {
                Text(page >= pages.count - 1 ? "Get started" : "Next")
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .foregroundColor(Color.emberBackground)
                    .emberPrimaryButtonShape()
            }
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
