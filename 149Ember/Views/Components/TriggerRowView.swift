//
//  TriggerRowView.swift
//  149Ember
//

import SwiftUI

enum TriggerCategoryVisual {
    static func accent(for category: String) -> Color {
        switch category {
        case "Work": return Color.emberNegative
        case "Relationships": return Color.emberPositive
        case "Health": return Color(red: 0.35, green: 0.75, blue: 1.0)
        case "Finance": return Color(red: 1.0, green: 0.65, blue: 0.2)
        default: return Color.gray.opacity(0.75)
        }
    }

    static func icon(for category: String) -> String {
        switch category {
        case "Work": return "briefcase.fill"
        case "Relationships": return "person.2.fill"
        case "Health": return "heart.fill"
        case "Finance": return "dollarsign.circle.fill"
        default: return "tag.fill"
        }
    }
}

struct TriggerRowView: View {
    let trigger: Trigger
    let maxCount: Int

    private var intensity: Double {
        guard maxCount > 0 else { return 0 }
        return min(1, Double(trigger.count) / Double(maxCount))
    }

    private var accent: Color {
        TriggerCategoryVisual.accent(for: trigger.category)
    }

    var body: some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 3)
                .fill(
                    LinearGradient(
                        colors: [accent, accent.opacity(0.4)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: 5)
                .shadow(color: accent.opacity(0.55), radius: 6, x: 2, y: 0)

            HStack(spacing: 12) {
                Image(systemName: TriggerCategoryVisual.icon(for: trigger.category))
                    .font(.title2)
                    .foregroundStyle(
                        LinearGradient(colors: [accent, accent.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .frame(width: 38, height: 38)
                    .background(
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [accent.opacity(0.28), accent.opacity(0.06)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 11, style: .continuous)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .shadow(color: accent.opacity(0.3), radius: 6, y: 3)

                VStack(alignment: .leading, spacing: 6) {
                    Text(trigger.name)
                        .font(.headline)
                        .foregroundColor(.white)
                        .lineLimit(2)

                    HStack(spacing: 8) {
                        Text(trigger.category)
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(accent.opacity(0.12))
                            .clipShape(Capsule())

                        if let last = trigger.lastUsed {
                            Text("Last · \(formattedShortDate(last))")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.white.opacity(0.08))
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [accent.opacity(0.9), accent.opacity(0.35)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(8, geo.size.width * intensity))
                        }
                    }
                    .frame(height: 5)
                    .padding(.top, 2)
                }

                Spacer(minLength: 4)

                VStack(alignment: .trailing, spacing: 4) {
                    Text("\(trigger.count)")
                        .font(.title2.weight(.bold))
                        .foregroundColor(.white)
                    Text(trigger.count == 1 ? "hit" : "hits")
                        .font(.caption2)
                        .foregroundColor(.gray)
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(.gray.opacity(0.8))
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 12)
        }
        .emberGlassPanel(cornerRadius: 18, accent: accent)
    }
}
