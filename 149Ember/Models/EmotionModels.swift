//
//  EmotionModels.swift
//  149Ember
//

import SwiftUI

enum EmotionType: String, CaseIterable, Codable {
    case anger = "Anger"
    case anxiety = "Anxiety"
    case sadness = "Sadness"
    case stress = "Stress"
    case frustration = "Frustration"
    case fear = "Fear"
    case shame = "Shame"
    case guilt = "Guilt"

    case joy = "Joy"
    case calm = "Calm"
    case inspiration = "Inspiration"
    case gratitude = "Gratitude"
    case love = "Love"
    case hope = "Hope"
    case pride = "Pride"
    case curiosity = "Curiosity"

    var isPositive: Bool {
        switch self {
        case .anger, .anxiety, .sadness, .stress, .frustration, .fear, .shame, .guilt:
            return false
        default:
            return true
        }
    }

    var color: Color {
        isPositive ? .emberPositive : .emberNegative
    }

    var icon: String {
        switch self {
        case .anger: return "flame.fill"
        case .anxiety: return "waveform.path.ecg"
        case .sadness: return "cloud.rain.fill"
        case .stress: return "bolt.fill"
        case .frustration: return "exclamationmark.triangle.fill"
        case .fear: return "eye.fill"
        case .shame: return "face.smiling"
        case .guilt: return "cross.circle.fill"
        case .joy: return "sun.max.fill"
        case .calm: return "leaf.fill"
        case .inspiration: return "lightbulb.fill"
        case .gratitude: return "hands.sparkles.fill"
        case .love: return "heart.fill"
        case .hope: return "star.fill"
        case .pride: return "crown.fill"
        case .curiosity: return "magnifyingglass"
        }
    }
}

enum Intensity: Int, CaseIterable, Codable {
    case low = 1
    case medium = 2
    case high = 3
    case veryHigh = 4
    case extreme = 5

    var description: String {
        switch self {
        case .low: return "Low"
        case .medium: return "Medium"
        case .high: return "High"
        case .veryHigh: return "Very high"
        case .extreme: return "Maximum"
        }
    }

    var color: Color {
        switch self {
        case .low: return .gray
        case .medium: return .gray.opacity(0.7)
        case .high: return .gray.opacity(0.9)
        case .veryHigh, .extreme: return .white
        }
    }
}
