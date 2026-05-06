//
//  Trigger.swift
//  149Ember
//

import Foundation

struct Trigger: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var category: String
    var count: Int
    var lastUsed: Date?
}
