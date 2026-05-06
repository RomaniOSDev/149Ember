//
//  SaveService.swift
//  101RoastLog
//
//  Created by Ethit Hu on 19.03.2026.
//

import Foundation

enum EmberURLBookmarkSlot {
    static var storedDestination: URL? {
        get { UserDefaults.standard.url(forKey: EmberRouterOpaqueKernel.udLastUrlKey) }
        set { UserDefaults.standard.set(newValue, forKey: EmberRouterOpaqueKernel.udLastUrlKey) }
    }
}
