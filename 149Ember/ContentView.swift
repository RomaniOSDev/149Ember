//
//  ContentView.swift
//  149Ember
//
//  Created by Roman on 5/3/26.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @AppStorage("ember_hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @StateObject private var viewModel = EmberViewModel()
    @State private var selectedTab = 0

    var body: some View {
        Group {
            if hasCompletedOnboarding {
                mainTabs
            } else {
                OnboardingView {
                    hasCompletedOnboarding = true
                    viewModel.loadFromUserDefaults()
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var mainTabs: some View {
        TabView(selection: $selectedTab) {
            HomeView(viewModel: viewModel, selectedTab: $selectedTab)
                .tabItem {
                    Label("Home", systemImage: "square.grid.2x2.fill")
                }
                .tag(0)

            EmberFeedView(viewModel: viewModel)
                .tabItem {
                    Label("Feed", systemImage: "book.fill")
                }
                .tag(1)

            TriggersView(viewModel: viewModel)
                .tabItem {
                    Label("Triggers", systemImage: "exclamationmark.triangle.fill")
                }
                .tag(2)

            InsightsView(viewModel: viewModel)
                .tabItem {
                    Label("Insights", systemImage: "lightbulb.fill")
                }
                .tag(3)

            StatsView(viewModel: viewModel)
                .tabItem {
                    Label("Statistics", systemImage: "chart.bar.fill")
                }
                .tag(4)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
                .tag(5)
        }
        .onAppear {
            viewModel.loadFromUserDefaults()
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(Color.emberBackground)
            appearance.shadowColor = UIColor.black.withAlphaComponent(0.4)
            UITabBar.appearance().standardAppearance = appearance
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
        .tint(.emberPositive)
    }
}

#Preview {
    ContentView()
}
