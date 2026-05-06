//
//  EmberViewModel.swift
//  149Ember
//

import Combine
import Foundation
import SwiftUI

@MainActor
final class EmberViewModel: ObservableObject {
    @Published var entries: [EmotionalEntry] = []
    @Published var triggers: [Trigger] = []
    @Published var insights: [Insight] = []

    var totalEntries: Int { entries.count }

    var positiveCount: Int {
        entries.filter(\.emotionType.isPositive).count
    }

    var negativeCount: Int {
        entries.filter { !$0.emotionType.isPositive }.count
    }

    var balanceText: String {
        let diff = positiveCount - negativeCount
        if diff > 0 { return "+\(diff)" }
        if diff < 0 { return "\(diff)" }
        return "0"
    }

    var weeklyPositive: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return entries.filter { $0.date >= weekAgo && $0.emotionType.isPositive }.count
    }

    var weeklyNegative: Int {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return entries.filter { $0.date >= weekAgo && !$0.emotionType.isPositive }.count
    }

    struct DailyScore: Identifiable {
        let id: String
        let day: String
        let score: Int
    }

    var dailyEmotionScore: [DailyScore] {
        let calendar = Calendar.current
        let today = Date()
        let weekDays = (0..<7).compactMap { calendar.date(byAdding: .day, value: -$0, to: today) }.reversed()
        let dayIdFormatter = DateFormatter()
        dayIdFormatter.dateFormat = "yyyy-MM-dd"
        dayIdFormatter.locale = Locale(identifier: "en_US_POSIX")
        let labelFormatter = DateFormatter()
        labelFormatter.dateFormat = "E"
        labelFormatter.locale = Locale(identifier: "en_US_POSIX")
        return weekDays.map { date in
            let dayEntries = entries.filter { calendar.isDate($0.date, inSameDayAs: date) }
            let positive = dayEntries.filter(\.emotionType.isPositive).count
            let negative = dayEntries.filter { !$0.emotionType.isPositive }.count
            let id = dayIdFormatter.string(from: calendar.startOfDay(for: date))
            return DailyScore(id: id, day: labelFormatter.string(from: date), score: positive - negative)
        }
    }

    struct EmotionDistribution: Identifiable {
        let id: String
        let name: String
        let icon: String
        let color: Color
        let count: Int
    }

    var emotionDistribution: [EmotionDistribution] {
        let grouped = Dictionary(grouping: entries, by: \.emotionType)
        return grouped.map { emotion, items in
            EmotionDistribution(
                id: emotion.rawValue,
                name: emotion.rawValue,
                icon: emotion.icon,
                color: emotion.color,
                count: items.count
            )
        }
        .sorted { $0.count > $1.count }
        .prefix(5)
        .map { $0 }
    }

    struct TopTrigger: Identifiable {
        var id: String { name }
        let name: String
        let count: Int
    }

    var topTriggers: [TopTrigger] {
        let allTriggers = entries.flatMap(\.triggers).map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        let grouped = Dictionary(grouping: allTriggers, by: { $0 })
        return grouped.map { name, occurrences in
            TopTrigger(name: name, count: occurrences.count)
        }
        .sorted { $0.count > $1.count }
        .prefix(5)
        .map { $0 }
    }

    struct BestDay: Hashable {
        let date: Date
        let score: Int
    }

    var bestDay: BestDay? {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: entries) { calendar.startOfDay(for: $0.date) }
        let scores = grouped.map { date, dayEntries -> (date: Date, score: Int) in
            let positive = dayEntries.filter(\.emotionType.isPositive).count
            let negative = dayEntries.filter { !$0.emotionType.isPositive }.count
            return (date, positive - negative)
        }
        return scores.max { $0.score < $1.score }.map { BestDay(date: $0.date, score: $0.score) }
    }

    var mostRecentEntry: EmotionalEntry? {
        entries.max(by: { $0.date < $1.date })
    }

    var favoritesCount: Int {
        entries.filter(\.isFavorite).count
    }

    func addEntry(_ entry: EmotionalEntry) {
        entries.append(entry)
        rebuildTriggersFromEntries()
        generateInsights()
        saveToUserDefaults()
    }

    func updateEntry(_ entry: EmotionalEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
            rebuildTriggersFromEntries()
            generateInsights()
            saveToUserDefaults()
        }
    }

    func deleteEntry(_ entry: EmotionalEntry) {
        entries.removeAll { $0.id == entry.id }
        rebuildTriggersFromEntries()
        generateInsights()
        saveToUserDefaults()
    }

    func toggleFavorite(_ entry: EmotionalEntry) {
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index].isFavorite.toggle()
            saveToUserDefaults()
        }
    }

    /// Recomputes trigger counts from entries; keeps manually added triggers that do not appear in any entry.
    private func rebuildTriggersFromEntries() {
        var aggregate: [String: (count: Int, last: Date)] = [:]
        for entry in entries {
            for raw in entry.triggers {
                let name = raw.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !name.isEmpty else { continue }
                if var existing = aggregate[name] {
                    existing.count += 1
                    if entry.date > existing.last {
                        existing.last = entry.date
                    }
                    aggregate[name] = existing
                } else {
                    aggregate[name] = (1, entry.date)
                }
            }
        }

        let preserved = triggers.filter { aggregate[$0.name] == nil }
        let fromEntries: [Trigger] = aggregate.map { name, value in
            let existing = triggers.first { $0.name == name }
            return Trigger(
                id: existing?.id ?? UUID(),
                name: name,
                category: existing?.category ?? guessCategory(name),
                count: value.count,
                lastUsed: value.last
            )
        }

        triggers = (fromEntries + preserved).sorted { $0.count > $1.count }
    }

    private func guessCategory(_ trigger: String) -> String {
        let lowercased = trigger.lowercased()
        if lowercased.contains("work") || lowercased.contains("project") || lowercased.contains("boss") || lowercased.contains("deadline") {
            return "Work"
        }
        if lowercased.contains("friend") || lowercased.contains("family") || lowercased.contains("partner") || lowercased.contains("relationship") {
            return "Relationships"
        }
        if lowercased.contains("health") || lowercased.contains("sleep") || lowercased.contains("tired") || lowercased.contains("fatigue") {
            return "Health"
        }
        if lowercased.contains("money") || lowercased.contains("finance") || lowercased.contains("debt") {
            return "Finance"
        }
        return "Other"
    }

    private func generateInsights() {
        var newInsights: [Insight] = []
        let calendar = Calendar.current

        let eveningEntries = entries.filter { calendar.component(.hour, from: $0.date) >= 18 }
        let eveningNegative = eveningEntries.filter { !$0.emotionType.isPositive }.count
        if eveningNegative > eveningEntries.count / 2, eveningEntries.count > 3 {
            newInsights.append(Insight(
                id: UUID(),
                text: "You tend to log more negative emotions in the evening. It may be linked to accumulated fatigue.",
                basedOn: "\(eveningEntries.count) evening entries",
                createdAt: Date()
            ))
        }

        if let topTrigger = topTriggers.first, topTrigger.count >= 3 {
            newInsights.append(Insight(
                id: UUID(),
                text: "“\(topTrigger.name)” shows up most often in your log. Consider what tends to surround that situation.",
                basedOn: "\(topTrigger.count) occurrences",
                createdAt: Date()
            ))
        }

        let lastMonth = calendar.date(byAdding: .month, value: -1, to: Date()) ?? Date()
        let recentEntries = entries.filter { $0.date >= lastMonth }
        let recentPositive = recentEntries.filter(\.emotionType.isPositive).count
        if recentEntries.count > 5, Double(recentPositive) / Double(recentEntries.count) > 0.6 {
            let pct = Int(Double(recentPositive) / Double(recentEntries.count) * 100)
            newInsights.append(Insight(
                id: UUID(),
                text: "Recently, a larger share of your entries are positive. Keep noticing what supports that.",
                basedOn: "\(pct)% positive emotions",
                createdAt: Date()
            ))
        }

        let highIntensity = entries.filter { $0.intensity == .veryHigh || $0.intensity == .extreme }
        if highIntensity.count >= 2 {
            newInsights.append(Insight(
                id: UUID(),
                text: "You’ve logged several very intense moments. Tracking what happens beforehand can help.",
                basedOn: "\(highIntensity.count) high-intensity entries",
                createdAt: Date()
            ))
        }

        insights = newInsights
    }

    func addTrigger(_ trigger: Trigger) {
        triggers.append(trigger)
        saveToUserDefaults()
    }

    func deleteTrigger(_ trigger: Trigger) {
        triggers.removeAll { $0.id == trigger.id }
        saveToUserDefaults()
    }

    /// Entries whose trigger list contains this name (case-insensitive, trimmed).
    func entries(containingTriggerName name: String) -> [EmotionalEntry] {
        let needle = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !needle.isEmpty else { return [] }
        return entries.filter { entry in
            entry.triggers.contains { t in
                t.trimmingCharacters(in: .whitespacesAndNewlines).caseInsensitiveCompare(needle) == .orderedSame
            }
        }
        .sorted { $0.date > $1.date }
    }

    var triggersTotalMentions: Int {
        triggers.reduce(0) { $0 + $1.count }
    }

    /// Updates trigger name and category; rewrites matching trigger strings in entries when the name changes.
    func applyTriggerEdits(triggerId: UUID, newName: String, newCategory: String) {
        guard let index = triggers.firstIndex(where: { $0.id == triggerId }) else { return }
        let oldName = triggers[index].name
        let trimmedNew = newName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedNew.isEmpty else { return }

        if trimmedNew != oldName {
            let oldNorm = oldName.trimmingCharacters(in: .whitespacesAndNewlines)
            for i in entries.indices {
                var e = entries[i]
                let replaced = e.triggers.map { t -> String in
                    let tn = t.trimmingCharacters(in: .whitespacesAndNewlines)
                    if tn.caseInsensitiveCompare(oldNorm) == .orderedSame {
                        return trimmedNew
                    }
                    return t
                }
                if replaced != e.triggers {
                    e.triggers = replaced
                    entries[i] = e
                }
            }
        }

        triggers[index].name = trimmedNew
        triggers[index].category = newCategory
        rebuildTriggersFromEntries()
        generateInsights()
        saveToUserDefaults()
    }

    private let entriesKey = "ember_entries"
    private let triggersKey = "ember_triggers"
    private let insightsKey = "ember_insights"

    func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: entriesKey)
        }
        if let encoded = try? JSONEncoder().encode(triggers) {
            UserDefaults.standard.set(encoded, forKey: triggersKey)
        }
        if let encoded = try? JSONEncoder().encode(insights) {
            UserDefaults.standard.set(encoded, forKey: insightsKey)
        }
    }

    func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: entriesKey),
           let decoded = try? JSONDecoder().decode([EmotionalEntry].self, from: data) {
            entries = decoded
        }

        if let data = UserDefaults.standard.data(forKey: triggersKey),
           let decoded = try? JSONDecoder().decode([Trigger].self, from: data) {
            triggers = decoded
        }

        if let data = UserDefaults.standard.data(forKey: insightsKey),
           let decoded = try? JSONDecoder().decode([Insight].self, from: data) {
            insights = decoded
        }

        if entries.isEmpty {
            loadDemoData()
        } else {
            rebuildTriggersFromEntries()
            generateInsights()
            saveToUserDefaults()
        }
    }

    private func loadDemoData() {
        let entry1 = EmotionalEntry(
            id: UUID(),
            date: Date().addingTimeInterval(-86400 * 2),
            emotionType: .joy,
            intensity: .high,
            triggers: ["Friends", "Nice weather"],
            thought: "So good we all got together!",
            action: "Invited friends for a walk",
            copingStrategy: nil,
            notes: "Great day.",
            isFavorite: true,
            createdAt: Date()
        )

        let entry2 = EmotionalEntry(
            id: UUID(),
            date: Date().addingTimeInterval(-86400 * 1),
            emotionType: .anxiety,
            intensity: .veryHigh,
            triggers: ["Work deadline", "Email from boss"],
            thought: "I won’t finish — it feels like a disaster",
            action: "Worked overtime",
            copingStrategy: "Deep breathing",
            notes: nil,
            isFavorite: false,
            createdAt: Date()
        )

        entries = [entry1, entry2]
        triggers = []
        rebuildTriggersFromEntries()
        generateInsights()
        saveToUserDefaults()
    }
}
