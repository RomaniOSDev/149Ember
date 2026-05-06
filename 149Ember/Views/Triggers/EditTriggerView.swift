//
//  EditTriggerView.swift
//  149Ember
//

import SwiftUI

struct EditTriggerView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: EmberViewModel
    let trigger: Trigger

    @State private var name: String
    @State private var category: String

    private let categories = ["Work", "Relationships", "Health", "Finance", "Other"]

    init(viewModel: EmberViewModel, trigger: Trigger) {
        self.viewModel = viewModel
        self.trigger = trigger
        _name = State(initialValue: trigger.name)
        _category = State(initialValue: trigger.category)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                EmberScreenBackground()
                Form {
                    Section {
                        TextField("Name", text: $name)
                            .foregroundColor(.white)
                    } footer: {
                        Text("Renaming updates this text in all linked journal entries.")
                            .font(.caption2)
                            .foregroundColor(.gray)
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
            .navigationTitle("Edit trigger")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.emberPositive)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.applyTriggerEdits(triggerId: trigger.id, newName: name, newCategory: category)
                        dismiss()
                    }
                    .foregroundColor(.emberPositive)
                    .bold()
                }
            }
        }
    }
}
