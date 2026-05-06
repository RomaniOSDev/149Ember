//
//  LinkedEntryRowView.swift
//  149Ember
//

import SwiftUI

struct LinkedEntryRowView: View {
    let entry: EmotionalEntry

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                entry.emotionType.color.opacity(0.35),
                                entry.emotionType.color.opacity(0.08)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .shadow(color: entry.emotionType.color.opacity(0.25), radius: 6, y: 3)

                Image(systemName: entry.emotionType.icon)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white)
            }
            .frame(width: 44, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.emotionType.rawValue)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                Text(entry.formattedDate)
                    .font(.caption2)
                    .foregroundColor(.gray)
                Text(entry.preview)
                    .font(.caption2)
                    .foregroundColor(.gray.opacity(0.9))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(.gray.opacity(0.7))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .emberGlassPanel(cornerRadius: 16, accent: entry.emotionType.color)
    }
}
