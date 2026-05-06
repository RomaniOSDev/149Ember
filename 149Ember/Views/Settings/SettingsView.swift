//
//  SettingsView.swift
//  149Ember
//

import StoreKit
import SwiftUI
import UIKit

struct SettingsView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                EmberScreenBackground()

                List {
                    Section {
                        Button {
                            rateApp()
                        } label: {
                            settingsRow(
                                title: "Rate us",
                                icon: "star.fill",
                                tint: .emberPositive,
                                showsExternalChevron: false
                            )
                        }

                        Button {
                            openLegal(.privacyPolicy)
                        } label: {
                            settingsRow(
                                title: "Privacy Policy",
                                icon: "hand.raised.fill",
                                tint: .emberPositive,
                                showsExternalChevron: true
                            )
                        }

                        Button {
                            openLegal(.termsOfUse)
                        } label: {
                            settingsRow(
                                title: "Terms of Service",
                                icon: "doc.text.fill",
                                tint: .emberPositive,
                                showsExternalChevron: true
                            )
                        }
                    } header: {
                        Text("Support & Legal")
                            .foregroundColor(.gray)
                    }
                    .listRowBackground(Color.emberBackground.opacity(0.55))
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.emberBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    @ViewBuilder
    private func settingsRow(title: String, icon: String, tint: Color, showsExternalChevron: Bool) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(
                    LinearGradient(colors: [tint, tint.opacity(0.7)], startPoint: .top, endPoint: .bottom)
                )
                .frame(width: 36, height: 36)
                .background(tint.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            Text(title)
                .font(.body.weight(.medium))
                .foregroundColor(.white)

            Spacer()

            if showsExternalChevron {
                Image(systemName: "arrow.up.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.gray)
            } else {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.gray.opacity(0.6))
            }
        }
        .padding(.vertical, 4)
        .contentShape(Rectangle())
    }

    private func openLegal(_ link: AppLegalLink) {
        if let url = link.url {
            UIApplication.shared.open(url)
        }
    }

    private func rateApp() {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            SKStoreReviewController.requestReview(in: windowScene)
        }
    }
}

#Preview {
    SettingsView()
}
