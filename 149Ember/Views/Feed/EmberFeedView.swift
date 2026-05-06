//
//  EmberFeedView.swift
//  149Ember
//

import SwiftUI

struct EmberFeedView: View {
    @ObservedObject var viewModel: EmberViewModel
    @State private var showAddEntrySheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                EmberScreenBackground()

                List {
                    Section {
                        headerSection
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }

                    Section {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
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
                            .padding(.vertical, 4)
                        }
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }

                    Section {
                        weeklyBalanceCard
                            .listRowInsets(EdgeInsets())
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }

                    Section {
                        ForEach(viewModel.entries) { entry in
                            NavigationLink(value: entry) {
                                EntryCard(entry: entry)
                            }
                            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteEntry(entry)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                Button {
                                    viewModel.toggleFavorite(entry)
                                } label: {
                                    Label("Favorite", systemImage: "star")
                                }
                                .tint(.emberPositive)
                            }
                        }
                    }
                    .listRowSeparator(.hidden)

                    Section {
                        Button {
                            showAddEntrySheet = true
                        } label: {
                            Text("Add entry")
                                .font(.headline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(Color.emberBackground)
                                .emberPrimaryButtonShape()
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 24, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddEntrySheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.palette)
                            .foregroundStyle(.white, Color.emberPositive)
                            .font(.title2)
                    }
                    .accessibilityLabel("Add entry")
                }
            }
            .navigationDestination(for: EmotionalEntry.self) { entry in
                EntryDetailView(viewModel: viewModel, entry: entry)
            }
        }
        .sheet(isPresented: $showAddEntrySheet) {
            AddEntryView(viewModel: viewModel, existingEntry: nil)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your log")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(
                    LinearGradient(
                        colors: [.emberPositive, .emberPositive.opacity(0.65)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: .emberPositive.opacity(0.35), radius: 12, y: 4)

            Text("\(viewModel.totalEntries) entries · balance \(viewModel.balanceText)")
                .font(.subheadline)
                .foregroundColor(.gray.opacity(0.95))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .emberGlassPanel(cornerRadius: 20, accent: .emberPositive)
        .padding(.horizontal)
    }

    private var weeklyBalanceCard: some View {
        let total = max(viewModel.weeklyPositive + viewModel.weeklyNegative, 1)
        let posFrac = Double(viewModel.weeklyPositive) / Double(total)
        let negFrac = Double(viewModel.weeklyNegative) / Double(total)

        return VStack(alignment: .leading, spacing: 8) {
            Text("Emotional balance this week")
                .font(.headline)
                .foregroundColor(.white)

            HStack {
                Text("Positive")
                    .font(.caption)
                    .foregroundColor(.emberPositive)
                Spacer()
                Text("\(viewModel.weeklyPositive)")
                    .font(.caption)
                    .foregroundColor(.emberPositive)
            }

            ProgressView(value: posFrac)
                .tint(.emberPositive)
                .background(Color.emberNegative.opacity(0.3))

            HStack {
                Text("Negative")
                    .font(.caption)
                    .foregroundColor(.emberNegative)
                Spacer()
                Text("\(viewModel.weeklyNegative)")
                    .font(.caption)
                    .foregroundColor(.emberNegative)
            }

            ProgressView(value: negFrac)
                .tint(.emberNegative)
                .background(Color.emberPositive.opacity(0.3))
        }
        .padding()
        .emberGlassPanel(cornerRadius: 18, accent: .emberPositive)
        .padding(.horizontal)
    }
}
