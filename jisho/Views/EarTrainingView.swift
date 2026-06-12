//
//  EarTrainingView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 27/11/25.
//

import SwiftUI

struct EarTrainingView: View {
    @StateObject private var gameManager = EarTrainingManager()
    @ObservedObject private var resultStore = EarTrainingResultStore.shared
    @StateObject private var settings = EarTrainingSettings.shared
    @State private var showOptions = false
    @State private var showMenu = false

    var body: some View {
        ZStack {
            // Gradient background
            LinearGradient(
                colors: [
                    Color.appBackground,
                    Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.03)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with Menu button (only when game is not active)
                if !gameManager.isGameActive {
                    HStack {
                        Button(action: { showMenu = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "line.3.horizontal")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Menu")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(Color(red: 0.91, green: 0.55, blue: 0.56))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.appMantle)
                            )
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                }

                if gameManager.isGameActive {
                    HStack {
                        Spacer()
                        Button(action: {
                            gameManager.stopGame()
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "stop.fill")
                                    .font(.system(size: 12))
                                Text("End Session")
                                    .font(.system(size: 14, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.91, green: 0.55, blue: 0.56),
                                                Color(red: 0.85, green: 0.45, blue: 0.46)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(
                                        color: Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.3),
                                        radius: 8,
                                        y: 4
                                    )
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 4)
                }

                // Stats row with enhanced cards
                HStack(spacing: 16) {
                    EnhancedStatView(title: "Time", value: gameManager.formattedTime, icon: "clock.fill")
                    EnhancedStatView(title: "Score", value: "\(gameManager.score)", icon: "star.fill")
                    EnhancedStatView(title: "Accuracy", value: gameManager.accuracy, icon: "target")
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Spacer()
                    .frame(minHeight: 8, maxHeight: 16)

                // Audio visualization area
                if gameManager.isGameActive {
                    EarTrainingAudioView(
                        question: gameManager.currentQuestion,
                        isPlaying: gameManager.isPlayingAudio,
                        showHint: settings.showVisualHint,
                        onReplay: {
                            gameManager.replayCurrentQuestion()
                        }
                    )
                    .padding(.horizontal, 20)
                    .opacity(gameManager.showFeedback ? 0.3 : 1.0)
                    .animation(.easeInOut(duration: 0.15), value: gameManager.showFeedback)
                }

                Spacer()
                    .frame(minHeight: 8, maxHeight: 16)

                // Answer options
                if gameManager.isGameActive, let question = gameManager.currentQuestion {
                    EarTrainingAnswerView(
                        options: question.answerOptions,
                        isEnabled: !gameManager.showFeedback && !gameManager.isPlayingAudio,
                        correctAnswer: gameManager.revealedAnswer,
                        wrongSelection: gameManager.wrongSelection
                    ) { answer in
                        gameManager.checkAnswer(answer)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 140)
                }
            }

            // Feedback overlay
            if gameManager.showFeedback {
                FeedbackOverlay(isCorrect: gameManager.lastAnswerCorrect)
                    .transition(.scale.combined(with: .opacity))
                    .zIndex(1)
            }

            // Start game overlay or summary when session inactive
            if !gameManager.isGameActive {
                EarTrainingSummaryOverlay(
                    result: gameManager.lastSessionResult,
                    history: resultStore.recentResults(),
                    settings: settings,
                    onStartSession: {
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
            EarTrainingMenuView(
                showOptions: $showOptions,
                onStartGame: {
                    showMenu = false
                    gameManager.startGame()
                }
            )
        }
        .sheet(isPresented: $showOptions) {
            EarTrainingOptionsView()
                .environmentObject(settings)
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Audio Visualization View
struct EarTrainingAudioView: View {
    let question: EarTrainingQuestion?
    let isPlaying: Bool
    let showHint: Bool
    let onReplay: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            // Exercise type indicator
            if let question = question {
                HStack {
                    Image(systemName: question.type.iconName)
                        .font(.system(size: 16, weight: .semibold))
                    Text(question.type.rawValue)
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(Color(red: 0.91, green: 0.55, blue: 0.56))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.15))
                )
            }

            // Audio visualization / waveform
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.appMantle)
                    .frame(height: 160)

                if isPlaying {
                    // Animated waveform when playing
                    AudioWaveformView()
                } else {
                    // Static speaker icon when not playing
                    VStack(spacing: 12) {
                        Image(systemName: "speaker.wave.3.fill")
                            .font(.system(size: 48))
                            .foregroundColor(Color(red: 0.91, green: 0.55, blue: 0.56))

                        if let question = question {
                            Text(question.displayDescription)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.appSubtitle)
                        }
                    }
                }
            }

            // Visual hint (if enabled)
            if showHint, let question = question, !question.notes.isEmpty {
                HStack(spacing: 8) {
                    ForEach(question.notes, id: \.id) { note in
                        Text(note.fullName)
                            .font(.system(size: 12, weight: .medium, design: .monospaced))
                            .foregroundColor(Color.appSubtitle)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 6)
                                    .fill(Color.appMantle)
                            )
                    }
                }
            }

            // Replay button
            Button(action: onReplay) {
                HStack(spacing: 8) {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 20))
                    Text("Replay")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(Color(red: 0.91, green: 0.55, blue: 0.56))
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.appMantle)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.3), lineWidth: 1)
                        )
                )
            }
            .disabled(isPlaying)
            .opacity(isPlaying ? 0.5 : 1.0)
        }
    }
}

// MARK: - Audio Waveform Animation
struct AudioWaveformView: View {
    @State private var animating = false

    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<12, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(Color(red: 0.91, green: 0.55, blue: 0.56))
                    .frame(width: 4, height: animating ? CGFloat.random(in: 20...60) : 20)
                    .animation(
                        Animation.easeInOut(duration: 0.3)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.05),
                        value: animating
                    )
            }
        }
        .onAppear {
            animating = true
        }
    }
}

// MARK: - Answer Options View
struct EarTrainingAnswerView: View {
    let options: [String]
    let isEnabled: Bool
    /// Highlighted in green after a wrong answer
    var correctAnswer: String?
    /// The user's wrong pick, highlighted in red
    var wrongSelection: String?
    let onSelect: (String) -> Void

    private func background(for option: String) -> AnyShapeStyle {
        if option == correctAnswer {
            return AnyShapeStyle(Color.appGreen)
        }
        if option == wrongSelection {
            return AnyShapeStyle(Color.appRed)
        }
        return AnyShapeStyle(optionGradient)
    }

    private func isHighlighted(_ option: String) -> Bool {
        option == correctAnswer || option == wrongSelection
    }

    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    private var optionGradient: LinearGradient {
        LinearGradient(
            colors: [
                Color(red: 0.91, green: 0.55, blue: 0.56),
                Color(red: 0.85, green: 0.45, blue: 0.46)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(options, id: \.self) { option in
                Button {
                    if isEnabled {
                        onSelect(option)
                    }
                } label: {
                    Text(option)
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(isEnabled || isHighlighted(option) ? 1 : 0.7))
                        .lineLimit(2)
                        .minimumScaleFactor(0.7)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(background(for: option))
                                .opacity(isEnabled || isHighlighted(option) ? 1 : 0.4)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                }
                .disabled(!isEnabled)
                .buttonStyle(ScaleButtonStyle())
            }
        }
    }
}

// MARK: - Summary Overlay
struct EarTrainingSummaryOverlay: View {
    let result: EarTrainingResult?
    let history: [EarTrainingResult]
    @ObservedObject var settings: EarTrainingSettings
    let onStartSession: () -> Void
    let onClearHistory: () -> Void
    let onShowOptions: () -> Void

    private var recentHistory: [EarTrainingResult] { history }
    private var displayedResult: EarTrainingResult? { result ?? history.last }
    private var hasHistory: Bool { !recentHistory.isEmpty }

    var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 16) {
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
                        Text("Ear Training")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(Color.appText)

                        Text("Train your ear to recognize notes, intervals, and melodies.")
                            .font(.subheadline)
                            .foregroundColor(Color.appSubtitle)
                            .multilineTextAlignment(.center)
                    }

                    // Exercise type selector
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Exercise Type")
                            .font(.headline)
                            .foregroundColor(Color.appSubtitle)

                        HStack(spacing: 8) {
                            ForEach(EarTrainingExerciseType.allCases) { type in
                                ExerciseTypeButton(
                                    type: type,
                                    isSelected: settings.exerciseType == type
                                ) {
                                    settings.exerciseType = type
                                }
                            }
                        }
                    }
                    .padding(.horizontal)

                    if hasHistory {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Recent Scores")
                                .font(.headline)
                                .foregroundColor(Color.appSubtitle)

                            EarTrainingChartView(results: recentHistory)
                                .frame(minHeight: 80, maxHeight: 140)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.appMantle)
                                )
                        }
                        .padding(.horizontal)
                    }

                    VStack(spacing: 14) {
                        Button(action: onStartSession) {
                            HStack(spacing: 8) {
                                Image(systemName: "ear.fill")
                                    .font(.system(size: 16, weight: .semibold))
                                Text("Start Ear Training")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.91, green: 0.55, blue: 0.56),
                                                Color(red: 0.85, green: 0.45, blue: 0.46)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .shadow(
                                        color: Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.4),
                                        radius: 12,
                                        y: 6
                                    )
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                    .padding(.horizontal)

                    Button(action: onShowOptions) {
                        HStack(spacing: 6) {
                            Image(systemName: "slider.horizontal.3")
                                .font(.system(size: 14))
                            Text("Options")
                                .font(.system(size: 16, weight: .semibold))
                        }
                        .foregroundColor(Color.appText)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color.appMantle)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(Color.appSubtitle.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }
                    .buttonStyle(ScaleButtonStyle())
                    .padding(.horizontal)

                    if hasHistory {
                        Button(action: onClearHistory) {
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
            .padding(.horizontal, 32)
            .padding(.top, 16)
            .padding(.bottom, 110)
        }
    }

    private func format(duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - Exercise Type Button
struct ExerciseTypeButton: View {
    let type: EarTrainingExerciseType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: type.iconName)
                    .font(.system(size: 20, weight: .semibold))
                Text(type.rawValue)
                    .font(.system(size: 11, weight: .medium))
                    .lineLimit(1)
            }
            .foregroundColor(isSelected ? .white : Color.appSubtitle)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected
                            ? LinearGradient(
                                colors: [
                                    Color(red: 0.91, green: 0.55, blue: 0.56),
                                    Color(red: 0.85, green: 0.45, blue: 0.46)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                              )
                            : LinearGradient(
                                colors: [Color.appMantle, Color.appMantle],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                              )
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Chart View
struct EarTrainingChartView: View {
    let results: [EarTrainingResult]

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

// MARK: - Menu View
struct EarTrainingMenuView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var showOptions: Bool
    @ObservedObject private var store = EarTrainingResultStore.shared
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
                        Image(systemName: "ear.fill")
                        Text("Start Ear Training")
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

                Spacer()
            }
            .padding()
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Ear Training")
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
            EarTrainingHistoryView(
                results: store.results,
                onClose: { showHistory = false }
            )
        }
    }
}

// MARK: - History View
struct EarTrainingHistoryView: View {
    let results: [EarTrainingResult]
    let onClose: () -> Void

    var body: some View {
        NavigationView {
            List {
                if results.isEmpty {
                    Text("No history yet. Complete a session to view past results.")
                        .foregroundColor(Color.appSubtitle)
                        .padding()
                } else {
                    ForEach(results.reversed()) { result in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(result.exerciseType)
                                    .font(.headline)
                                    .foregroundColor(Color.appText)
                                Spacer()
                                Text(result.date, style: .date)
                                    .font(.caption)
                                    .foregroundColor(Color.appSubtitle)
                            }

                            HStack(spacing: 16) {
                                Label("\(result.score)", systemImage: "star.fill")
                                Label(String(format: "%.0f%%", result.accuracyPercentage), systemImage: "target")
                                Label(result.difficulty, systemImage: "chart.bar.fill")
                            }
                            .font(.subheadline)
                            .foregroundColor(Color.appSubtitle)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .background(Color.appBackground)
            .navigationTitle("Session History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done", action: onClose)
                        .foregroundColor(Color.appAccent)
                }
            }
        }
    }
}
