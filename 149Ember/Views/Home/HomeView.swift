//
//  HomeView.swift
//  149Ember
//

import SwiftUI

private enum HomeTab: Int {
    case feed = 1
    case triggers = 2
    case insights = 3
    case stats = 4
}

struct HomeView: View {
    @ObservedObject var viewModel: EmberViewModel
    @Binding var selectedTab: Int

    @State private var showQuickLog = false

    private let gridSpacing: CGFloat = 12
    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundLayer

                ScrollView(showsIndicators: false) {
                    LazyVGrid(columns: columns, spacing: gridSpacing) {
                        heroBalanceWidget
                            .gridCellColumns(2)
                            .frame(maxWidth: .infinity)

                        quickLogWidget
                            .frame(maxWidth: .infinity)
                        latestEntryWidget
                            .frame(maxWidth: .infinity)

                        weekStripWidget
                            .frame(maxWidth: .infinity)
                        topTriggerWidget
                            .frame(maxWidth: .infinity)

                        favoritesWidget
                            .frame(maxWidth: .infinity)
                        insightWidget
                            .frame(maxWidth: .infinity)

                        shortcutsWidget
                            .gridCellColumns(2)
                            .frame(maxWidth: .infinity)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 28)
                }
                .frame(maxWidth: .infinity)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 6) {
                        Image(systemName: "square.grid.2x2.fill")
                            .font(.title3)
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.emberPositive, .emberPositive.opacity(0.6)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("Home")
                            .font(.headline.weight(.bold))
                            .foregroundColor(.white)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Home")
                }
            }
            .navigationDestination(for: EmotionalEntry.self) { entry in
                EntryDetailView(viewModel: viewModel, entry: entry)
            }
        }
        .sheet(isPresented: $showQuickLog) {
            AddEntryView(viewModel: viewModel, existingEntry: nil)
        }
    }

    private var backgroundLayer: some View {
        EmberScreenBackground()
    }

    // MARK: - Hero

    private var heroBalanceWidget: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.emberBackground.opacity(0.95),
                            Color.white.opacity(0.04)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [.emberPositive.opacity(0.45), .emberNegative.opacity(0.25)],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 1
                        )
                )

            HStack(spacing: 6) {
                heroSideBlock(
                    icon: "sun.max.fill",
                    tint: .emberPositive,
                    value: viewModel.positiveCount
                )
                .layoutPriority(0)

                VStack(spacing: 4) {
                    Text(viewModel.balanceText)
                        .font(.system(size: 40, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                        .minimumScaleFactor(0.25)
                        .lineLimit(1)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                    Image(systemName: "arrow.left.and.right")
                        .font(.caption.weight(.bold))
                        .foregroundColor(.gray.opacity(0.9))
                }
                .frame(minWidth: 56, maxWidth: 120)
                .layoutPriority(1)

                heroSideBlock(
                    icon: "cloud.rain.fill",
                    tint: .emberNegative,
                    value: viewModel.negativeCount
                )
                .layoutPriority(0)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 20)
        }
        .frame(maxWidth: .infinity)
        .shadow(color: Color.black.opacity(0.35), radius: 16, y: 10)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Balance \(viewModel.balanceText). Positive \(viewModel.positiveCount), negative \(viewModel.negativeCount)")
    }

    private func heroSideBlock(icon: String, tint: Color, value: Int) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.18))
                    .frame(width: 52, height: 52)
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(
                        LinearGradient(colors: [tint, tint.opacity(0.75)], startPoint: .top, endPoint: .bottom)
                    )
            }
            Text("\(value)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Quick log

    private var quickLogWidget: some View {
        Button {
            showQuickLog = true
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.emberPositive, Color.emberPositive.opacity(0.55)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                VStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 44))
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.white, Color.emberBackground.opacity(0.35))
                    Image(systemName: "pencil.and.outline")
                        .font(.title3.weight(.semibold))
                        .foregroundColor(Color.emberBackground.opacity(0.85))
                }
                .padding(.vertical, 20)
            }
            .frame(maxWidth: .infinity, minHeight: 132)
            .shadow(color: Color.emberPositive.opacity(0.35), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Log new entry")
    }

    // MARK: - Latest entry

    @ViewBuilder
    private var latestEntryWidget: some View {
        if let entry = viewModel.mostRecentEntry {
            NavigationLink(value: entry) {
                latestEntryContent(entry: entry)
            }
            .buttonStyle(.plain)
        } else {
            emptyTile(
                icon: "tray",
                tint: .gray,
                hint: "—"
            )
            .accessibilityLabel("No entries yet")
        }
    }

    private func latestEntryContent(entry: EmotionalEntry) -> some View {
        ZStack(alignment: .bottomLeading) {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.emberBackground.opacity(0.75))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(entry.emotionType.color.opacity(0.45), lineWidth: 1.2)
                )

            ZStack {
                Circle()
                    .fill(entry.emotionType.color.opacity(0.2))
                    .frame(width: 64, height: 64)
                    .offset(x: 18, y: -14)
                Image(systemName: entry.emotionType.icon)
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [entry.emotionType.color, entry.emotionType.color.opacity(0.65)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .offset(y: -4)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
            .padding(.trailing, 4)

            HStack(spacing: 6) {
                Image(systemName: "clock")
                    .font(.caption2.weight(.bold))
                Text(entry.shortTime)
                    .font(.caption.weight(.semibold))
            }
            .foregroundColor(.gray)
            .padding(10)
        }
        .frame(maxWidth: .infinity, minHeight: 132)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Latest entry \(entry.emotionType.rawValue) at \(entry.shortTime)")
    }

    // MARK: - Week strip

    private var weekStripWidget: some View {
        let scores = viewModel.dailyEmotionScore

        return ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.emberBackground.opacity(0.72))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )

            VStack(spacing: 10) {
                Image(systemName: "calendar")
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(
                        LinearGradient(colors: [.emberPositive, .emberPositive.opacity(0.5)], startPoint: .top, endPoint: .bottom)
                    )

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(scores) { day in
                            VStack(spacing: 4) {
                                Image(systemName: day.score > 0 ? "leaf.fill" : (day.score < 0 ? "flame.fill" : "circle.dotted"))
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(
                                        day.score > 0 ? Color.emberPositive :
                                            day.score < 0 ? Color.emberNegative : Color.gray.opacity(0.45)
                                    )
                                Text(String(day.day.prefix(2)))
                                    .font(.system(size: 9, weight: .heavy, design: .rounded))
                                    .foregroundColor(.gray.opacity(0.85))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.7)
                            }
                            .frame(minWidth: 28)
                        }
                    }
                    .padding(.horizontal, 4)
                }
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 6)
        }
        .frame(maxWidth: .infinity, minHeight: 132)
        .accessibilityLabel("Last seven days mood dots")
    }

    // MARK: - Top trigger

    private var topTriggerWidget: some View {
        Group {
            if let top = viewModel.topTriggers.first {
                Button {
                    selectedTab = HomeTab.triggers.rawValue
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(Color.emberBackground.opacity(0.72))
                            .overlay(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(Color.emberNegative.opacity(0.35), lineWidth: 1)
                            )

                        VStack(spacing: 8) {
                            ZStack(alignment: .topTrailing) {
                                Image(systemName: "bolt.fill")
                                    .font(.system(size: 30))
                                    .foregroundStyle(
                                        LinearGradient(colors: [.emberNegative, .emberNegative.opacity(0.65)], startPoint: .top, endPoint: .bottom)
                                    )
                                    .padding(.top, 4)
                                Text("\(top.count)")
                                    .font(.caption2.weight(.heavy))
                                    .foregroundColor(.emberBackground)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Capsule().fill(Color.emberNegative))
                                    .offset(x: 6, y: -2)
                            }
                            Text(top.name)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.white.opacity(0.92))
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.7)
                                .fixedSize(horizontal: false, vertical: true)
                                .frame(maxWidth: .infinity)
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 12)
                    }
                    .frame(maxWidth: .infinity, minHeight: 132)
                    .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Top trigger \(top.name), \(top.count) times. Opens triggers tab")
            } else {
                emptyTile(icon: "tag", tint: .gray, hint: "—")
                    .accessibilityLabel("No triggers data")
            }
        }
    }

    // MARK: - Favorites

    private var favoritesWidget: some View {
        Button {
            selectedTab = HomeTab.feed.rawValue
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.emberBackground.opacity(0.72))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.emberPositive.opacity(0.35), lineWidth: 1)
                    )

                VStack(spacing: 10) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(
                            LinearGradient(colors: [.emberPositive, Color.yellow.opacity(0.85)], startPoint: .topLeading, endPoint: .bottomTrailing)
                        )
                    Text("\(viewModel.favoritesCount)")
                        .font(.system(size: 28, weight: .heavy, design: .rounded))
                        .foregroundColor(.white)
                }
                .padding(.vertical, 18)
            }
            .frame(maxWidth: .infinity, minHeight: 132)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(viewModel.favoritesCount) favorites. Opens feed")
    }

    // MARK: - Insight

    private var insightWidget: some View {
        Button {
            selectedTab = HomeTab.insights.rawValue
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(Color.emberBackground.opacity(0.72))
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .stroke(Color.emberPositive.opacity(0.28), lineWidth: 1)
                    )

                if !viewModel.insights.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 34))
                            .foregroundStyle(
                                LinearGradient(colors: [.emberPositive, .emberPositive.opacity(0.55)], startPoint: .top, endPoint: .bottom)
                            )
                        Image(systemName: "ellipsis")
                            .font(.caption.weight(.heavy))
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 22)
                    .accessibilityLabel("Insight available. Opens insights")
                } else {
                    VStack(spacing: 10) {
                        Image(systemName: "lightbulb")
                            .font(.system(size: 34))
                            .foregroundColor(.gray.opacity(0.45))
                        Image(systemName: "moon.zzz")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.gray.opacity(0.5))
                    }
                    .padding(.vertical, 22)
                    .accessibilityLabel("No insights yet")
                }
            }
            .frame(maxWidth: .infinity, minHeight: 132)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Shortcuts

    private var shortcutsWidget: some View {
        HStack(spacing: 8) {
            tabJumpButton(icon: "book.fill", tab: HomeTab.feed.rawValue, label: "Journal")
            tabJumpButton(icon: "exclamationmark.triangle.fill", tab: HomeTab.triggers.rawValue, label: "Triggers")
            tabJumpButton(icon: "lightbulb.fill", tab: HomeTab.insights.rawValue, label: "Insights")
            tabJumpButton(icon: "chart.bar.fill", tab: HomeTab.stats.rawValue, label: "Stats")
        }
        .frame(maxWidth: .infinity)
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.emberBackground.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
        )
    }

    private func tabJumpButton(icon: String, tab: Int, label: String) -> some View {
        Button {
            selectedTab = tab
        } label: {
            Image(systemName: icon)
                .font(.title3.weight(.semibold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, .white.opacity(0.75)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white.opacity(0.06))
                )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(label)
    }

    private func emptyTile(icon: String, tint: Color, hint: String) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .fill(Color.emberBackground.opacity(0.55))
                .overlay(
                    RoundedRectangle(cornerRadius: 22, style: .continuous)
                        .stroke(Color.white.opacity(0.06), lineWidth: 1)
                )
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 32))
                    .foregroundColor(tint.opacity(0.55))
                Text(hint)
                    .font(.title3.weight(.bold))
                    .foregroundColor(.gray.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, minHeight: 132)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
    }
}

#Preview {
    HomeView(viewModel: EmberViewModel(), selectedTab: .constant(0))
}
