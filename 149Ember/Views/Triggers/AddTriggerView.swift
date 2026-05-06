//
//  AddTriggerView.swift
//  149Ember
//

import SwiftUI

struct AddTriggerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: EmberViewModel

    @State private var name = ""
    @State private var category = "Other"

    private let categories = ["Work", "Relationships", "Health", "Finance", "Other"]

    var body: some View {
        NavigationStack {
            ZStack {
                EmberScreenBackground()
                Form {
                    Section {
                        TextField("Name", text: $name)
                            .foregroundColor(.white)
                    }
                    .listRowBackground(Color.emberBackground.opacity(0.6))

                    Section {
                        Picker("Category", selection: $category) {
                            ForEach(categories, id: \.self) { c in
                                Text(c).tag(c)
                            }
                        }
                        .listRowBackground(Color.emberBackground.opacity(0.6))
                    }
                }
                .scrollContentBackground(.hidden)
                .foregroundColor(.white)
            }
            .navigationTitle("New trigger")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.emberPositive)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !trimmed.isEmpty else { return }
                        viewModel.addTrigger(Trigger(id: UUID(), name: trimmed, category: category, count: 0, lastUsed: nil))
                        dismiss()
                    }
                    .foregroundColor(.emberPositive)
                }
            }
        }
    }
}
