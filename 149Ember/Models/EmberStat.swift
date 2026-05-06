//
//  EmberStat.swift
//  149Ember
//

import Foundation

struct EmberStat {
    var totalEntries: Int
    var positiveCount: Int
    var negativeCount: Int
    var mostCommonEmotion: EmotionType?
    var mostCommonTrigger: String?
    var averageIntensity: Double
    var bestDay: Date?
    var bestDayScore: Int
}
