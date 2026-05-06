//
//  InsightCard.swift
//  149Ember
//

import SwiftUI

struct InsightCard: View {
    let insight: Insight

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [.emberPositive.opacity(0.35), .emberPositive.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .stroke(Color.emberPositive.opacity(0.4), lineWidth: 1)
                        )
                        .shadow(color: .emberPositive.opacity(0.25), radius: 8, y: 4)

                    Image(systemName: "lightbulb.fill")
                        .foregroundStyle(
                            LinearGradient(colors: [.emberPositive, .emberPositive.opacity(0.65)], startPoint: .top, endPoint: .bottom)
                        )
                        .font(.title2)
                }
                .frame(width: 44, height: 44)

                Text("Insight")
                    .font(.headline)
                    .foregroundStyle(
                        LinearGradient(colors: [.emberPositive, .emberPositive.opacity(0.8)], startPoint: .leading, endPoint: .trailing)
                    )
            }

            Text(insight.text)
                .font(.body)
                .foregroundColor(.white)

            Text("Based on: \(insight.basedOn)")
                .font(.caption2)
                .foregroundColor(.gray)

            Text(formattedShortDate(insight.createdAt))
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding()
        .emberGlassPanel(cornerRadius: 18, accent: .emberPositive)
    }
}
