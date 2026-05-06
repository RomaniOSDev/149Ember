//
//  EntryDetailView.swift
//  149Ember
//

import SwiftUI

struct EntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: EmberViewModel
    let entry: EmotionalEntry

    @State private var showEditSheet = false
    @State private var showDeleteConfirmation = false

    private var current: EmotionalEntry {
        viewModel.entries.first { $0.id == entry.id } ?? entry
    }

    var body: some View {
        ZStack {
            EmberScreenBackground()

            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    headerBlock

                    if !current.triggers.isEmpty {
                        triggersBlock
                    }

                    if let thought = current.thought, !thought.isEmpty {
                        labeledBlock(title: "Thought", text: thought)
                    }
                    if let action = current.action, !action.isEmpty {
                        labeledBlock(title: "Action", text: action)
                    }
                    if let coping = current.copingStrategy, !coping.isEmpty {
                        labeledBlock(title: "What helped", text: coping)
                    }
                    if let notes = current.notes, !notes.isEmpty {
                        labeledBlock(title: "Notes", text: notes)
                    }

                    actionButtons
                }
                .padding(.bottom, 32)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showEditSheet) {
            AddEntryView(viewModel: viewModel, existingEntry: current)
        }
        .alert("Delete this entry?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                viewModel.deleteEntry(current)
                dismiss()
            }
        } message: {
            Text("This cannot be undone.")
        }
    }

    private var headerBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    current.emotionType.color.opacity(0.45),
                                    current.emotionType.color.opacity(0.12)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .overlay(Circle().stroke(Color.white.opacity(0.15), lineWidth: 1))
                        .shadow(color: current.emotionType.color.opacity(0.45), radius: 14, y: 6)

                    Image(systemName: current.emotionType.icon)
                        .foregroundStyle(.white)
                        .font(.system(size: 36, weight: .semibold))
                }
                .frame(width: 72, height: 72)

                VStack(alignment: .leading, spacing: 6) {
                    Text(current.emotionType.rawValue)
                        .font(.largeTitle)
                        .bold()
                        .foregroundStyle(
                            LinearGradient(colors: [.white, .white.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )

                    Text(current.formattedDate)
                        .font(.caption)
                        .foregroundColor(.gray)
                }

                Spacer()

                if current.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(
                            LinearGradient(colors: [.emberPositive, .yellow.opacity(0.9)], startPoint: .top, endPoint: .bottom)
                        )
                        .font(.title2)
                        .shadow(color: .emberPositive.opacity(0.45), radius: 8, y: 3)
                }
            }

            HStack {
                Text("Intensity:")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                ForEach(1...current.intensity.rawValue, id: \.self) { _ in
                    Image(systemName: "circle.fill")
                        .font(.caption)
                        .foregroundColor(current.emotionType.color)
                        .shadow(color: current.emotionType.color.opacity(0.5), radius: 3, y: 1)
                }

                Text("(\(current.intensity.description))")
                    .font(.caption)
                    .foregroundColor(current.emotionType.color)
            }
        }
        .padding(18)
        .emberGlassPanel(cornerRadius: 22, accent: current.emotionType.color)
        .padding(.horizontal)
    }

    private var triggersBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Triggers")
                .font(.headline)
                .foregroundStyle(
                    LinearGradient(colors: [current.emotionType.color, current.emotionType.color.opacity(0.7)], startPoint: .leading, endPoint: .trailing)
                )

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(current.triggers, id: \.self) { trigger in
                        Text(trigger)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                current.emotionType.color.opacity(0.3),
                                                current.emotionType.color.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                            .overlay(Capsule().stroke(current.emotionType.color.opacity(0.45), lineWidth: 1))
                            .foregroundColor(current.emotionType.color)
                            .shadow(color: current.emotionType.color.opacity(0.25), radius: 6, y: 3)
                    }
                }
            }
        }
        .padding(16)
        .emberGlassPanel(cornerRadius: 18, accent: current.emotionType.color)
        .padding(.horizontal)
    }

    private func labeledBlock(title: String, text: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundStyle(
                    LinearGradient(colors: [.emberPositive, .emberPositive.opacity(0.75)], startPoint: .leading, endPoint: .trailing)
                )

            Text(text)
                .foregroundColor(.white)
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .emberGlassPanel(cornerRadius: 14, accent: .emberPositive)
        }
        .padding(.horizontal)
    }

    private var actionButtons: some View {
        HStack(spacing: 12) {
            Button("Edit") {
                showEditSheet = true
            }
            .font(.headline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(Color.emberBackground)
            .emberPrimaryButtonShape()

            Button("Delete") {
                showDeleteConfirmation = true
            }
            .font(.headline.weight(.semibold))
            .frame(maxWidth: .infinity)
            .padding()
            .foregroundColor(.emberPositive)
            .emberOutlineButtonShape(accent: .emberNegative)
        }
        .padding(.horizontal)
        .padding(.bottom, 8)
    }
}
