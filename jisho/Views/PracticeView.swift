//
//  PracticeView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 28/9/25.
//

import SwiftUI
import TikimUI

struct PracticeView: View {
    @StateObject private var gameManager = GameManager()
    @ObservedObject private var resultStore = PracticeResultStore.shared
    @EnvironmentObject var settings: GameSettings
    @State private var inputMode: InputMode = .musicNotes
    @State private var showOptions = false
    @State private var showMenu = false

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with Menu button
                HStack {
                    Button(action: { showMenu = true }) {
                        Text("Menu")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(red: 0.91, green: 0.55, blue: 0.56))
                    }
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)

                Rectangle()
                    .fill(Color(red: 0.91, green: 0.55, blue: 0.56))
                    .frame(height: 4)
                    .padding(.top, 8)

                if gameManager.isGameActive {
                    HStack {
                        Spacer()
                        Button(action: {
                            gameManager.stopGame()
                        }) {
                            Text("End Session")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(Color.appAccent)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    Capsule()
                                        .fill(Color.appMantle.opacity(0.6))
                                )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 12)
                }

                // Stats row
                HStack(spacing: 40) {
                    StatView(title: "Time", value: gameManager.formattedTime)
                    StatView(title: "Score", value: "\(gameManager.score)")
                    StatView(title: "Accuracy", value: gameManager.accuracy)
                }
                .padding(.horizontal)
                .padding(.top, 20)

                Spacer()
                    .frame(minHeight: 20, maxHeight: 40)

                // Staff with note
                StaffView(
                    note: gameManager.currentNote,
                    clef: gameManager.currentClef,
                    showNote: gameManager.isGameActive
                )
                .padding(.horizontal)
                .padding(.vertical, 20)
                .opacity(gameManager.showFeedback ? 0.3 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: gameManager.showFeedback)

                Spacer()
                    .frame(minHeight: 10, maxHeight: 30)

                // Input mode toggle
                HStack(spacing: 16) {
                    ForEach(InputMode.allCases, id: \.self) { mode in
                        Button(action: { inputMode = mode }) {
                            Text(mode.rawValue)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(
                                    inputMode == mode ? Color.appText : Color.appSubtitle)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            inputMode == mode
                                                ? Color.appMantle : Color.clear
                                        )
                                )
                        }
                    }
                }
                .padding(.bottom, 12)

                // Input area
                Group {
                    if inputMode == .musicNotes {
                        MusicNoteButtonsView(
                            includeAccidentals: settings.includeAccidentals
                        ) { note, accidental in
                            if gameManager.isGameActive {
                                gameManager.checkAnswer(note, accidental: accidental)
                            }
                        }
                        .padding(.horizontal, 12)
                    } else {
                        PianoKeyboardView { note, accidental in
                            if gameManager.isGameActive {
                                gameManager.checkAnswer(note, accidental: accidental)
                            }
                        }
                        .padding(.horizontal, 8)
                    }
                }
                .padding(.bottom, 100)
            }

            // Feedback overlay
            if gameManager.showFeedback {
                FeedbackOverlay(isCorrect: gameManager.lastAnswerCorrect)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1)
            }

            // Start game overlay or summary when session inactive
            if !gameManager.isGameActive {
                SessionSummaryOverlay(
                    result: gameManager.lastSessionResult,
                    history: resultStore.recentResults(),
                    onRestart: {
                        gameManager.startGame()
                    },
                    onClearHistory: {
                        gameManager.clearHistory()
                    },
                    onShowOptions: {
                        showOptions = true
                    }
                )
                .transition(.opacity)
            }
        }
        .sheet(isPresented: $showMenu) {
            MenuView(
                showOptions: $showOptions,
                onStartGame: {
                    showMenu = false
                    gameManager.resetGame()
                }
            )
        }
        .sheet(isPresented: $showOptions) {
            OptionsView()
                .environmentObject(settings)
        }
        .navigationBarHidden(true)
    }
}

struct StatView: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.appSubtitle)
            Text(value)
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(Color.appText)
        }
    }
}

struct FeedbackOverlay: View {
    let isCorrect: Bool

    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            Image(systemName: isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(isCorrect ? .green : .red)
        }
    }
}

struct MenuView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var showOptions: Bool
    @ObservedObject private var store = PracticeResultStore.shared
    @State private var showHistory = false
    let onStartGame: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    onStartGame()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Start Practice")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(red: 0.91, green: 0.55, blue: 0.56))
                    )
                }

                NavigationLink(destination: LearnView()) {
                    HStack {
                        Image(systemName: "book")
                        Text("Learn")
                    }
                    .font(.headline)
                    .foregroundColor(Color.appText)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.appMantle)
                    )
                }

                Spacer()
            }
            .padding()
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Menu")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showHistory = true
                    } label: {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                    .foregroundColor(store.results.isEmpty ? Color.appMantle : Color.appAccent)
                    .disabled(store.results.isEmpty)
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color.appAccent)
                }
            }
        }
        .sheet(isPresented: $showHistory) {
            SessionHistoryView(
                results: store.results,
                onClose: { showHistory = false }
            )
        }
    }
}

#Preview {
    PracticeView()
        .environmentObject(GameSettings.shared)
}

struct SessionSummaryOverlay: View {
    let result: SessionResult?
    let history: [SessionResult]
    let onRestart: () -> Void
    let onClearHistory: () -> Void
    let onShowOptions: () -> Void

    private var recentHistory: [SessionResult] { history }
    private var displayedResult: SessionResult? { result ?? history.last }
    private var hasHistory: Bool { !recentHistory.isEmpty }

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 24) {
                if let summary = displayedResult {
                    Text("Session Summary")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.appText)

                    HStack(spacing: 40) {
                        SummaryStat(label: "Score", value: "\(summary.score)")
                        SummaryStat(
                            label: "Accuracy",
                            value: String(format: "%.0f%%", summary.accuracyPercentage)
                        )
                        SummaryStat(
                            label: "Duration",
                            value: format(duration: summary.duration)
                        )
                    }
                } else {
                    Text("Ready to Practice")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(Color.appText)

                    Text("Start your first session to see performance insights.")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)
                }

                if hasHistory {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Scores")
                            .font(.headline)
                            .foregroundColor(Color.appSubtitle)

                        SimpleLineChartView(results: recentHistory)
                            .frame(height: 160)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.appMantle)
                            )
                    }
                    .padding(.horizontal)
                }

                Button(action: onRestart) {
                    Text(displayedResult == nil ? "Start Practice" : "Start New Session")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 40)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(red: 0.91, green: 0.55, blue: 0.56))
                        )
                }

                Button(action: onShowOptions) {
                    Text("Options")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(Color.appAccent)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 10)
                        .background(
                            Capsule()
                                .fill(Color.appMantle.opacity(0.6))
                        )
                }

                if hasHistory {
                    Button(action: {
                        onClearHistory()
                    }) {
                        Text("Clear History")
                            .font(.subheadline)
                            .foregroundColor(Color.appSubtitle)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(Color.appMantle)
                            )
                    }
                }
            }
            .padding(32)
        }
    }

    private func format(duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct SummaryStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(Color.appSubtitle)
            Text(value)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(Color.appText)
        }
    }
}

struct SimpleLineChartView: View {
    let results: [SessionResult]

    private var scores: [Double] {
        results.map { Double($0.score) }
    }

    private var maxScore: Double {
        max(scores.max() ?? 0, 1)
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let count = results.count

            ZStack {
                Path { path in
                    let stepY = height / 4
                    for index in 0...4 {
                        let y = CGFloat(index) * stepY
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: width, y: y))
                    }
                }
                .stroke(Color.appBackground.opacity(0.4), lineWidth: 1)

                if count == 1, let first = scores.first {
                    let point = point(for: first, index: 0, count: count, width: width, height: height)
                    Circle()
                        .fill(Color(red: 0.91, green: 0.55, blue: 0.56))
                        .frame(width: 10, height: 10)
                        .position(point)
                } else if count > 1 {
                    Path { path in
                        for (index, score) in scores.enumerated() {
                            let point = point(
                                for: score,
                                index: index,
                                count: count,
                                width: width,
                                height: height
                            )

                            if index == 0 {
                                path.move(to: point)
                            } else {
                                path.addLine(to: point)
                            }
                        }
                    }
                    .stroke(Color(red: 0.91, green: 0.55, blue: 0.56), lineWidth: 3)

                    ForEach(Array(scores.enumerated()), id: \.offset) { pair in
                        let point = point(
                            for: pair.element,
                            index: pair.offset,
                            count: count,
                            width: width,
                            height: height
                        )
                        Circle()
                            .fill(Color.white)
                            .frame(width: 10, height: 10)
                            .overlay(
                                Circle()
                                    .stroke(Color(red: 0.91, green: 0.55, blue: 0.56), lineWidth: 2)
                            )
                            .position(point)
                    }
                }
            }
        }
    }

    private func point(
        for score: Double,
        index: Int,
        count: Int,
        width: CGFloat,
        height: CGFloat
    ) -> CGPoint {
        let xSpacing = count > 1 ? width / CGFloat(count - 1) : width / 2
        let x = count > 1 ? CGFloat(index) * xSpacing : width / 2
        let normalized = maxScore > 0 ? score / maxScore : 0
        let y = height - (CGFloat(normalized) * (height - 12)) - 6
        return CGPoint(x: x, y: y)
    }
}
