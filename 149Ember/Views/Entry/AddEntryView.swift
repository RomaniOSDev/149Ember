//
//  AddEntryView.swift
//  149Ember
//

import SwiftUI

struct AddEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: EmberViewModel

    private let existingEntry: EmotionalEntry?

    @State private var emotionType: EmotionType
    @State private var intensity: Intensity
    @State private var triggers: [String]
    @State private var thought: String
    @State private var action: String
    @State private var copingStrategy: String
    @State private var notes: String
    @State private var isFavorite: Bool

    private let quickTriggers = ["Work", "Conflict", "Fatigue", "Hunger", "Loneliness", "Success"]

    init(viewModel: EmberViewModel, existingEntry: EmotionalEntry? = nil, prefilledTriggerNames: [String]? = nil) {
        self.viewModel = viewModel
        self.existingEntry = existingEntry
        _emotionType = State(initialValue: existingEntry?.emotionType ?? .calm)
        _intensity = State(initialValue: existingEntry?.intensity ?? .medium)
        _triggers = State(initialValue: {
            if let existingEntry {
                let t = existingEntry.triggers
                return t.isEmpty ? [""] : t
            }
            if let pre = prefilledTriggerNames {
                let trimmed = pre.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
                return trimmed.isEmpty ? [""] : trimmed
            }
            return [""]
        }())
        _thought = State(initialValue: existingEntry?.thought ?? "")
        _action = State(initialValue: existingEntry?.action ?? "")
        _copingStrategy = State(initialValue: existingEntry?.copingStrategy ?? "")
        _notes = State(initialValue: existingEntry?.notes ?? "")
        _isFavorite = State(initialValue: existingEntry?.isFavorite ?? false)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                EmberScreenBackground()
                formContent
            }
            .navigationTitle(existingEntry == nil ? "New entry" : "Edit entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.emberPositive)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .foregroundColor(.emberPositive)
                        .bold()
                }
            }
        }
    }

    private var formContent: some View {
        Form {
            Section {
                Picker("Emotion", selection: $emotionType) {
                    ForEach(EmotionType.allCases, id: \.self) { emotion in
                        HStack {
                            Image(systemName: emotion.icon)
                                .foregroundColor(emotion.color)
                            Text(emotion.rawValue)
                        }
                        .tag(emotion)
                    }
                }
                .listRowBackground(Color.emberBackground.opacity(0.6))

                Picker("Intensity", selection: $intensity) {
                    ForEach(Intensity.allCases, id: \.self) { value in
                        Text(value.description).tag(value)
                    }
                }
                .listRowBackground(Color.emberBackground.opacity(0.6))
            }
            .listRowBackground(Color.emberBackground.opacity(0.6))

            Section {
                ForEach($triggers.indices, id: \.self) { index in
                    HStack {
                        TextField("What triggered it?", text: $triggers[index])
                            .foregroundColor(.white)
                        Button {
                            triggers.remove(at: index)
                        } label: {
                            Image(systemName: "minus.circle")
                                .foregroundColor(accentColor)
                        }
                    }
                    .listRowBackground(Color.emberBackground.opacity(0.6))
                }

                Button("Add trigger row") {
                    triggers.append("")
                }
                .foregroundColor(accentColor)
                .listRowBackground(Color.emberBackground.opacity(0.6))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(quickTriggers, id: \.self) { quick in
                            Text(quick)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color.emberBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(accentColor, lineWidth: 1)
                                )
                                .foregroundColor(accentColor)
                                .onTapGesture {
                                    if !triggers.contains(where: { $0 == quick }) {
                                        if let last = triggers.last, last.isEmpty {
                                            triggers[triggers.count - 1] = quick
                                        } else {
                                            triggers.append(quick)
                                        }
                                    }
                                }
                        }
                    }
                }
                .listRowBackground(Color.emberBackground.opacity(0.6))
            } header: {
                Text("Triggers")
                    .foregroundColor(.gray)
            }

            Section {
                TextField("What thought showed up?", text: $thought)
                    .foregroundColor(.white)
                TextField("What did you do in response?", text: $action)
                    .foregroundColor(.white)
                TextField("What helped you cope?", text: $copingStrategy)
                    .foregroundColor(.white)
            } header: {
                Text("Thoughts & actions")
                    .foregroundColor(.gray)
            }
            .listRowBackground(Color.emberBackground.opacity(0.6))

            Section {
                TextEditor(text: $notes)
                    .frame(minHeight: 80)
                    .foregroundColor(.white)
            } header: {
                Text("Notes")
                    .foregroundColor(.gray)
            }
            .listRowBackground(Color.emberBackground.opacity(0.6))

            Section {
                Toggle("Add to favorites", isOn: $isFavorite)
                    .tint(.emberPositive)
            }
            .listRowBackground(Color.emberBackground.opacity(0.6))
        }
        .scrollContentBackground(.hidden)
        .foregroundColor(.white)
        .tint(accentColor)
    }

    private var accentColor: Color {
        emotionType.isPositive ? .emberPositive : .emberNegative
    }

    private func save() {
        let cleaned = triggers.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        let finalTriggers = cleaned.isEmpty ? [] : cleaned

        let thoughtValue = thought.trimmingCharacters(in: .whitespacesAndNewlines)
        let actionValue = action.trimmingCharacters(in: .whitespacesAndNewlines)
        let copingValue = copingStrategy.trimmingCharacters(in: .whitespacesAndNewlines)
        let notesValue = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        if let existing = existingEntry {
            let updated = EmotionalEntry(
                id: existing.id,
                date: existing.date,
                emotionType: emotionType,
                intensity: intensity,
                triggers: finalTriggers,
                thought: thoughtValue.isEmpty ? nil : thoughtValue,
                action: actionValue.isEmpty ? nil : actionValue,
                copingStrategy: copingValue.isEmpty ? nil : copingValue,
                notes: notesValue.isEmpty ? nil : notesValue,
                isFavorite: isFavorite,
                createdAt: existing.createdAt
            )
            viewModel.updateEntry(updated)
        } else {
            let new = EmotionalEntry(
                id: UUID(),
                date: Date(),
                emotionType: emotionType,
                intensity: intensity,
                triggers: finalTriggers,
                thought: thoughtValue.isEmpty ? nil : thoughtValue,
                action: actionValue.isEmpty ? nil : actionValue,
                copingStrategy: copingValue.isEmpty ? nil : copingValue,
                notes: notesValue.isEmpty ? nil : notesValue,
                isFavorite: isFavorite,
                createdAt: Date()
            )
            viewModel.addEntry(new)
        }
        dismiss()
    }
}
