//
//  StatCard.swift
//  149Ember
//

import SwiftUI

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [color.opacity(0.45), color.opacity(0.12)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            Circle()
                                .stroke(Color.white.opacity(0.15), lineWidth: 1)
                        )
                        .shadow(color: color.opacity(0.35), radius: 6, y: 3)

                    Image(systemName: icon)
                        .foregroundStyle(.white)
                        .font(.body.weight(.semibold))
                }
                .frame(width: 36, height: 36)

                Text(title)
                    .foregroundColor(.gray)
                    .font(.caption)
                    .lineLimit(2)
            }

            Text(value)
                .foregroundColor(.white)
                .font(.title2)
                .bold()
                .minimumScaleFactor(0.8)
                .lineLimit(1)
        }
        .padding()
        .frame(minWidth: 140, maxWidth: .infinity, alignment: .leading)
        .emberGlassPanel(cornerRadius: 16, accent: color)
    }
}
