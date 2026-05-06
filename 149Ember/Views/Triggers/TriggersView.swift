//
//  TriggersView.swift
//  149Ember
//

import SwiftUI

private struct CategoryFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: isSelected
                                    ? [Color.emberPositive.opacity(0.35), Color.emberPositive.opacity(0.14)]
                                    : [Color.white.opacity(0.08), Color.white.opacity(0.03)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    Capsule()
                        .stroke(isSelected ? Color.emberPositive.opacity(0.9) : Color.white.opacity(0.12), lineWidth: isSelected ? 1.5 : 1)
                )
                .foregroundColor(isSelected ? Color.emberPositive : Color.gray)
                .shadow(color: isSelected ? Color.emberPositive.opacity(0.35) : Color.clear, radius: 8, y: 4)
        }
        .buttonStyle(.plain)
    }
}

struct TriggersView: View {
    @ObservedObject var viewModel: EmberViewModel
    @State private var showAddTriggerSheet = false
    @State private var editDraft: Trigger?
    @State private var categoryFilter = "All"

    private static let filterCategories = ["All", "Work", "Relationships", "Health", "Finance", "Other"]

    private var sortedTriggers: [Trigger] {
        let base = viewModel.triggers
        let filtered = categoryFilter == "All" ? base : base.filter { $0.category == categoryFilter }
        return filtered.sorted { $0.count > $1.count }
    }

    private var maxMentionCount: Int {
        max(sortedTriggers.map(\.count).max() ?? 1, 1)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                EmberScreenBackground()

                List {
                    Section {
                        triggersHeader
                            .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 4, trailing: 16))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)

                        filterChipsRow
                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }

                    if sortedTriggers.isEmpty {
                        Section {
                            emptyFilterState
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                        }
                    } else {
                        Section {
                            ForEach(sortedTriggers) { trigger in
                                NavigationLink(value: trigger.id) {
                                    TriggerRowView(trigger: trigger, maxCount: maxMentionCount)
                                }
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowSeparator(.hidden)
                                .listRowBackground(Color.clear)
                                .swipeActions(edge: .leading) {
                                    Button {
                                        editDraft = trigger
                                    } label: {
                                        Label("Edit", systemImage: "pencil")
                                    }
                                    .tint(.emberPositive)
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        viewModel.deleteTrigger(trigger)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }

                    Section {
                        Button {
                            showAddTriggerSheet = true
                        } label: {
                            Label("Add trigger", systemImage: "plus.circle.fill")
                                .font(.headline.weight(.semibold))
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(Color.emberBackground)
                                .emberPrimaryButtonShape()
                        }
                        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 28, trailing: 16))
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Triggers")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.emberBackground, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationDestination(for: UUID.self) { id in
                TriggerDetailView(viewModel: viewModel, triggerId: id)
            }
            .navigationDestination(for: EmotionalEntry.self) { entry in
                EntryDetailView(viewModel: viewModel, entry: entry)
            }
            .sheet(isPresented: $showAddTriggerSheet) {
                AddTriggerView(viewModel: viewModel)
            }
            .sheet(item: $editDraft) { trigger in
                EditTriggerView(viewModel: viewModel, trigger: trigger)
            }
        }
    }

    private var triggersHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Patterns")
                .font(.title2.weight(.bold))
                .foregroundStyle(
                    LinearGradient(colors: [.emberPositive, .emberPositive.opacity(0.65)], startPoint: .leading, endPoint: .trailing)
                )
                .shadow(color: .emberPositive.opacity(0.25), radius: 8, y: 2)

            Text("Tap a row to see linked entries, tone split, and shortcuts to log or edit.")
                .font(.caption)
                .foregroundColor(.gray)
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 10) {
                miniStat(title: "Saved", value: "\(viewModel.triggers.count)", icon: "tag.fill", tint: .emberPositive)
                miniStat(title: "Mentions", value: "\(viewModel.triggersTotalMentions)", icon: "link", tint: .emberNegative.opacity(0.9))
            }
        }
    }

    private func miniStat(title: String, value: String, icon: String, tint: Color) -> some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .foregroundColor(tint)
            VStack(alignment: .leading, spacing: 2) {
                Text(title.uppercased())
                    .font(.caption2.weight(.semibold))
                    .foregroundColor(.gray)
                Text(value)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            Spacer(minLength: 0)
        }
        .padding(12)
        .emberGlassPanel(cornerRadius: 14, accent: tint)
    }

    private var filterChipsRow: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Self.filterCategories, id: \.self) { cat in
                    CategoryFilterChip(title: cat, isSelected: categoryFilter == cat) {
                        categoryFilter = cat
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 4)
        }
    }

    private var emptyFilterState: some View {
        VStack(spacing: 12) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.title)
                .foregroundStyle(
                    LinearGradient(colors: [.gray.opacity(0.65), .gray.opacity(0.3)], startPoint: .top, endPoint: .bottom)
                )
            Text(categoryFilter == "All" ? "No triggers yet. Add one or log emotions with trigger tags." : "No triggers in \"\(categoryFilter)\". Pick another filter or add a new trigger.")
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(22)
        .emberGlassPanel(cornerRadius: 20, accent: .emberPositive)
        .padding(.horizontal, 4)
        .padding(.vertical, 12)
    }
}
