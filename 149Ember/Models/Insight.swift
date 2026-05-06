//
//  Insight.swift
//  149Ember
//

import Foundation

struct Insight: Identifiable, Codable, Hashable {
    let id: UUID
    var text: String
    var basedOn: String
    var createdAt: Date
}
