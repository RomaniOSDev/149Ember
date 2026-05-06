//
//  StatsView.swift
//  149Ember
//

import Charts
import SwiftUI

struct StatsView: View {
    @ObservedObject var viewModel: EmberViewModel

    var body: some View {
        NavigationStack {
            ZStack {
                EmberScreenBackground()

                ScrollView {
                    VStack(spacing: 20) {
                        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                            StatCard(
                                title: "Total entries",
                                value: "\(viewModel.totalEntries)",
                                icon: "book.fill",
                                color: .emberPositive
                            )
                            StatCard(
                                title: "Positive",
                                value: "\(viewModel.positiveCount)",
                                icon: "sun.max.fill",
                                color: .emberPositive
                            )
                            StatCard(
                                title: "Negative",
                                value: "\(viewModel.negativeCount)",
                                icon: "cloud.rain.fill",
                                color: .emberNegative
                            )
                            StatCard(
                                title: "Balance",
                                value: viewModel.balanceText,
                                icon: "equal.circle.fill",
                                color: .emberPositive
                            )
                        }
                        .padding(.horizontal)

                        chartSection
                            .padding()
                            .emberGlassPanel(cornerRadius: 18, accent: .emberPositive)
                            .padding(.horizontal)

                        distributionSection
                            .padding()
                            .emberGlassPanel(cornerRadius: 18, accent: .emberPositive)
                            .padding(.horizontal)

                        topTriggersSection
                            .padding()
                            .emberGlassPanel(cornerRadius: 18, accent: .emberNegative)
                            .padding(.horizontal)

                        if let bestDay = viewModel.bestDay {
                            bestDaySection(bestDay)
                                .padding()
                                .emberGlassPanel(cornerRadius: 18, accent: .emberPositive)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.bottom, 24)
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.emberBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
    }

    private var chartSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Daily emotional balance")
                .font(.headline)
                .foregroundColor(.white)

            Chart(viewModel.dailyEmotionScore) { data in
                LineMark(
                    x: .value("Day", data.day),
                    y: .value("Balance", data.score)
                )
                .foregroundStyle(Color.emberPositive)

                AreaMark(
                    x: .value("Day", data.day),
                    y: .value("Balance", data.score)
                )
                .foregroundStyle(Color.emberPositive.opacity(0.2))
            }
            .frame(height: 150)
        }
    }

    private var distributionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Common emotions")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(viewModel.emotionDistribution) { item in
                HStack {
                    Image(systemName: item.icon)
                        .foregroundColor(item.color)
                        .frame(width: 30)

                    Text(item.name)
                        .foregroundColor(.white)

                    Spacer()

                    Text("\(item.count)")
                        .foregroundColor(item.color)
                        .bold()
                }
                .padding(.vertical, 4)
            }
        }
    }

    private var topTriggersSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Common triggers")
                .font(.headline)
                .foregroundColor(.white)

            ForEach(viewModel.topTriggers) { trigger in
                HStack {
                    Text(trigger.name)
                        .foregroundColor(.white)

                    Spacer()

                    Text("\(trigger.count)×")
                        .foregroundColor(.emberNegative)
                        .bold()
                }
                .padding(.vertical, 4)
            }
        }
    }

    private func bestDaySection(_ bestDay: EmberViewModel.BestDay) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Best day")
                .font(.headline)
                .foregroundColor(.white)

            HStack {
                Text(formattedDate(bestDay.date))
                    .foregroundColor(.white)

                Spacer()

                Text("+\(bestDay.score)")
                    .foregroundColor(.emberPositive)
                    .bold()
            }
        }
    }
}
