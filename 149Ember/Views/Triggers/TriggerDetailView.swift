//
//  TriggerDetailView.swift
//  149Ember
//

import SwiftUI

struct TriggerDetailView: View {
    @ObservedObject var viewModel: EmberViewModel
    let triggerId: UUID

    @State private var editDraft: Trigger?
    @State private var showNewEntry = false
    @State private var presetTriggerNameForNewEntry = ""

    private var model: Trigger? {
        viewModel.triggers.first { $0.id == triggerId }
    }

    var body: some View {
        ZStack {
            EmberScreenBackground()
            Group {
                if let trigger = model {
                    content(for: trigger)
                } else {
                    missingView
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                if model != nil {
                    Button {
                        presetTriggerNameForNewEntry = model?.name ?? ""
                        showNewEntry = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                    .accessibilityLabel("Log entry with this trigger")

                    Button {
                        if let m = model {
                            editDraft = m
                        }
                    } label: {
                        Image(systemName: "pencil")
                    }
                    .accessibilityLabel("Edit trigger")
                }
            }
        }
        .sheet(item: $editDraft) { t in
            EditTriggerView(viewModel: viewModel, trigger: t)
        }
        .sheet(isPresented: $showNewEntry) {
            AddEntryView(
                viewModel: viewModel,
                existingEntry: nil,
                prefilledTriggerNames: {
                    let t = presetTriggerNameForNewEntry.trimmingCharacters(in: .whitespacesAndNewlines)
                    return t.isEmpty ? nil : [t]
                }()
            )
        }
    }

    private var missingView: some View {
        VStack(spacing: 12) {
            Image(systemName: "tag.slash")
                .font(.largeTitle)
                .foregroundStyle(
                    LinearGradient(colors: [.gray.opacity(0.7), .gray.opacity(0.35)], startPoint: .top, endPoint: .bottom)
                )
            Text("This trigger is no longer in your list.")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding(24)
        .emberGlassPanel(cornerRadius: 22, accent: .emberNegative)
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    @ViewBuilder
    private func content(for trigger: Trigger) -> some View {
        let linked = viewModel.entries(containingTriggerName: trigger.name)
        let positive = linked.filter(\.emotionType.isPositive).count
        let negative = linked.count - positive
        let accent = TriggerCategoryVisual.accent(for: trigger.category)

        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerCard(trigger: trigger, accent: accent, linkedCount: linked.count)

                if !linked.isEmpty {
                    toneBreakdown(positive: positive, negative: negative)
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Linked journal entries")
                        .font(.headline)
                        .foregroundColor(.emberPositive)

                    if linked.isEmpty {
                        Text("No entries mention this trigger yet. Log an emotion and add it, or tap + to start.")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding(.vertical, 8)
                    } else {
                        LazyVStack(spacing: 10) {
                            ForEach(linked) { entry in
                                NavigationLink(value: entry) {
                                    LinkedEntryRowView(entry: entry)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                VStack(spacing: 10) {
                    Button {
                        presetTriggerNameForNewEntry = trigger.name
                        showNewEntry = true
                    } label: {
                        Label("Log entry with this trigger", systemImage: "plus.circle.fill")
                            .font(.headline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(Color.emberBackground)
                            .emberPrimaryButtonShape()
                    }

                    Button {
                        editDraft = trigger
                    } label: {
                        Label("Edit name & category", systemImage: "slider.horizontal.3")
                            .font(.headline.weight(.semibold))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.emberPositive)
                            .emberOutlineButtonShape()
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 28)
            }
            .padding(.top, 4)
        }
    }

    private func headerCard(trigger: Trigger, accent: Color, linkedCount: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                Image(systemName: TriggerCategoryVisual.icon(for: trigger.category))
                    .font(.system(size: 28))
                    .foregroundStyle(accent)
                    .frame(width: 52, height: 52)
                    .background(accent.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 6) {
                    Text(trigger.name)
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text(trigger.category)
                        .font(.caption.weight(.semibold))
                        .foregroundColor(accent)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(accent.opacity(0.12))
                        .clipShape(Capsule())
                }
                Spacer()
            }

            HStack(spacing: 20) {
                statPill(title: "Mentions", value: "\(trigger.count)", color: accent)
                statPill(title: "Entries", value: "\(linkedCount)", color: .emberPositive)
            }

            if let last = trigger.lastUsed {
                Text("Last logged \(formattedShortDate(last))")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .emberGlassPanel(cornerRadius: 22, accent: accent)
        .padding(.horizontal)
    }

    private func statPill(title: String, value: String, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .foregroundColor(.gray)
            Text(value)
                .font(.title3.bold())
                .foregroundColor(.white)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [color.opacity(0.22), color.opacity(0.06)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(color.opacity(0.35), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.2), radius: 6, y: 3)
    }

    private func toneBreakdown(positive: Int, negative: Int) -> some View {
        let total = max(positive + negative, 1)
        let posFrac = Double(positive) / Double(total)
        let negFrac = Double(negative) / Double(total)

        return VStack(alignment: .leading, spacing: 10) {
            Text("Tone when this trigger appears")
                .font(.headline)
                .foregroundColor(.emberPositive)

            HStack {
                Label("Positive", systemImage: "sun.max.fill")
                    .font(.caption)
                    .foregroundColor(.emberPositive)
                Spacer()
                Text("\(positive)")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.emberPositive)
            }
            ProgressView(value: posFrac)
                .tint(.emberPositive)
                .background(Color.white.opacity(0.06))

            HStack {
                Label("Negative", systemImage: "cloud.rain.fill")
                    .font(.caption)
                    .foregroundColor(.emberNegative)
                Spacer()
                Text("\(negative)")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.emberNegative)
            }
            ProgressView(value: negFrac)
                .tint(.emberNegative)
                .background(Color.white.opacity(0.06))
        }
        .padding()
        .emberGlassPanel(cornerRadius: 18, accent: .emberPositive)
        .padding(.horizontal)
    }
}
