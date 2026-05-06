//
//  InsightsView.swift
//  149Ember
//

import SwiftUI

struct InsightsView: View {
    @ObservedObject var viewModel: EmberViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                EmberScreenBackground()

                ScrollView {
                    LazyVStack(spacing: 18) {
                        ForEach(viewModel.insights) { insight in
                            InsightCard(insight: insight)
                        }

                        if viewModel.insights.isEmpty {
                            VStack(spacing: 14) {
                                Image(systemName: "lightbulb")
                                    .font(.system(size: 40))
                                    .foregroundStyle(
                                        LinearGradient(colors: [.gray.opacity(0.5), .gray.opacity(0.25)], startPoint: .top, endPoint: .bottom)
                                    )
                                Text("No insights yet. Add more entries so patterns can surface.")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(22)
                            .emberGlassPanel(cornerRadius: 20, accent: .emberPositive)
                            .padding(.horizontal, 4)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 2)
                    .padding(.bottom, 16)
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.emberBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }
}
