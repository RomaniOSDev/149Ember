//
//  PersistenceManager.swift
//  101RoastLog
//
//  Created by Ethit Hu on 19.03.2026.
//

import Foundation

final class EmberSessionVault {
    static let shared = EmberSessionVault()

    var persistedDestinationString: String? {
        get {
            if let url = EmberURLBookmarkSlot.storedDestination {
                return url.absoluteString
            }
            return UserDefaults.standard.string(forKey: EmberRouterOpaqueKernel.udLastUrlKey)
        }
        set {
            if let urlString = newValue {
                UserDefaults.standard.set(urlString, forKey: EmberRouterOpaqueKernel.udLastUrlKey)
                if let url = URL(string: urlString) {
                    EmberURLBookmarkSlot.storedDestination = url
                }
            } else {
                UserDefaults.standard.removeObject(forKey: EmberRouterOpaqueKernel.udLastUrlKey)
                EmberURLBookmarkSlot.storedDestination = nil
            }
        }
    }

    var didCommitNativeShell: Bool {
        get {
            UserDefaults.standard.bool(forKey: EmberRouterOpaqueKernel.udNativeShownKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: EmberRouterOpaqueKernel.udNativeShownKey)
        }
    }

    var didCompleteEmbeddedLoad: Bool {
        get {
            UserDefaults.standard.bool(forKey: EmberRouterOpaqueKernel.udWebLoadedKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: EmberRouterOpaqueKernel.udWebLoadedKey)
        }
    }

    private init() {}
}
