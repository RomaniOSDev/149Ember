//
//  EmotionalEntry.swift
//  149Ember
//

import Foundation

struct EmotionalEntry: Identifiable, Codable, Hashable {
    let id: UUID
    var date: Date
    var emotionType: EmotionType
    var intensity: Intensity
    var triggers: [String]
    var thought: String?
    var action: String?
    var copingStrategy: String?
    var notes: String?
    var isFavorite: Bool
    let createdAt: Date

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMMM yyyy, HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    var shortTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: date)
    }

    var preview: String {
        if let thought = thought, !thought.isEmpty {
            return thought
        } else if let notes = notes, !notes.isEmpty {
            return notes
        }
        return "No description"
    }
}
