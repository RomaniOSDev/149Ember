//
//  AppLegalLink.swift
//  149Ember
//

import Foundation

enum AppLegalLink {
    case privacyPolicy
    case termsOfUse

    var url: URL? {
        switch self {
        case .privacyPolicy:
            return URL(string: "https://www.termsfeed.com/live/71ab8d2f-cb38-440b-b9a8-2d33635e9149")
        case .termsOfUse:
            return URL(string: "https://www.termsfeed.com/live/f242e89d-a864-47f6-8989-f1466f50957e")
        }
    }
}
