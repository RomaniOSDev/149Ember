//
//  EntryCard.swift
//  149Ember
//

import SwiftUI

struct EntryCard: View {
    let entry: EmotionalEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    entry.emotionType.color.opacity(0.4),
                                    entry.emotionType.color.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(Circle().stroke(Color.white.opacity(0.12), lineWidth: 1))
                        .shadow(color: entry.emotionType.color.opacity(0.35), radius: 8, y: 4)

                    Image(systemName: entry.emotionType.icon)
                        .foregroundColor(.white)
                        .font(.title3.weight(.semibold))
                }
                .frame(width: 40, height: 40)

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.emotionType.rawValue)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(entry.shortTime)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                HStack(spacing: 2) {
                    ForEach(1...entry.intensity.rawValue, id: \.self) { _ in
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(entry.emotionType.color)
                            .shadow(color: entry.emotionType.color.opacity(0.6), radius: 2, y: 0)
                    }
                }

                if entry.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(
                            LinearGradient(colors: [.emberPositive, .yellow.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                        )
                        .font(.caption)
                        .shadow(color: .emberPositive.opacity(0.45), radius: 4, y: 2)
                }
            }

            Text(entry.preview)
                .font(.caption)
                .foregroundColor(.gray)
                .lineLimit(2)

            if !entry.triggers.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(entry.triggers, id: \.self) { trigger in
                            Text(trigger)
                                .font(.caption2)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    Capsule()
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    entry.emotionType.color.opacity(0.28),
                                                    entry.emotionType.color.opacity(0.1)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                )
                                .overlay(
                                    Capsule()
                                        .stroke(entry.emotionType.color.opacity(0.45), lineWidth: 1)
                                )
                                .foregroundColor(entry.emotionType.color)
                                .shadow(color: entry.emotionType.color.opacity(0.2), radius: 4, y: 2)
                        }
                    }
                }
            }
        }
        .padding()
        .emberGlassPanel(cornerRadius: 16, accent: entry.emotionType.color)
    }
}
