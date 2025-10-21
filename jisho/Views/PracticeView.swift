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

    private let noteInputModes: [InputMode] = [.musicNotes, .pianoKeys]

    private var staffNotes: [MusicNote] {
        if gameManager.currentMode == .chordIdentification {
            return gameManager.currentChordNotes
        } else if let note = gameManager.currentNote {
            return [note]
        } else {
            return []
        }
    }

    private var shouldShowStaffNotes: Bool {
        gameManager.isGameActive && !staffNotes.isEmpty
    }

    private var inputAreaBottomPadding: CGFloat {
        gameManager.currentMode == .chordIdentification ? 120 : 140
    }

    private func iconName(for mode: InputMode) -> String {
        switch mode {
        case .musicNotes:
            return "music.note"
        case .pianoKeys:
            return "pianokeys"
        case .chordIdentification:
            return "music.note.list"
        }
    }

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
                    .padding(.top, 10)
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
                    .padding(.top, 16)
                }

                // Stats row with enhanced cards
                HStack(spacing: 16) {
                    EnhancedStatView(title: "Time", value: gameManager.formattedTime, icon: "clock.fill")
                    EnhancedStatView(title: "Score", value: "\(gameManager.score)", icon: "star.fill")
                    EnhancedStatView(title: "Accuracy", value: gameManager.accuracy, icon: "target")
                }
                .padding(.horizontal, 20)
                .padding(.top, 24)

                Spacer()
                    .frame(minHeight: 20, maxHeight: 40)

                // Staff with note/chord content
                StaffView(
                    notes: staffNotes,
                    clef: gameManager.currentClef,
                    showNotes: shouldShowStaffNotes
                )
                .padding(.horizontal)
                .padding(.vertical, 20)
                .opacity(gameManager.showFeedback ? 0.3 : 1.0)
                .animation(.easeInOut(duration: 0.15), value: gameManager.showFeedback)

                Spacer()
                    .frame(minHeight: 10, maxHeight: 30)

                // Input mode toggle with enhanced design
                if gameManager.currentMode != .chordIdentification || !gameManager.isGameActive {
                    HStack(spacing: 0) {
                        ForEach(noteInputModes, id: \.self) { mode in
                            Button(action: {
                                withAnimation(.spring(response: 0.3)) {
                                    inputMode = mode
                                }
                            }) {
                                HStack(spacing: 6) {
                                    Image(systemName: iconName(for: mode))
                                        .font(.system(size: 14, weight: .semibold))
                                    Text(mode.rawValue)
                                        .font(.system(size: 14, weight: .semibold))
                                }
                                .foregroundColor(
                                    inputMode == mode ? Color.white : Color.appSubtitle
                                )
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(
                                            inputMode == mode
                                                ? LinearGradient(
                                                    colors: [
                                                        Color(red: 0.91, green: 0.55, blue: 0.56),
                                                        Color(red: 0.85, green: 0.45, blue: 0.46)
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                                : LinearGradient(
                                                    colors: [Color.clear, Color.clear],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                        )
                                        .shadow(
                                            color: inputMode == mode
                                                ? Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.3)
                                                : Color.clear,
                                            radius: 8,
                                            y: 4
                                        )
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                    }
                    .padding(4)
                    .background(
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color.appMantle)
                    )
                    .padding(.horizontal, 20)
                    .padding(.bottom, 16)
                } else {
                    Spacer()
                        .frame(height: 16)
                }

                // Input area
                Group {
                    switch gameManager.currentMode {
                    case .musicNotes:
                        MusicNoteButtonsView(
                            includeAccidentals: settings.includeAccidentals
                        ) { note, accidental in
                            if gameManager.isGameActive {
                                gameManager.checkAnswer(note, accidental: accidental)
                            }
                        }
                        .padding(.horizontal, 12)

                    case .pianoKeys:
                        PianoKeyboardView { note, accidental in
                            if gameManager.isGameActive {
                                gameManager.checkAnswer(note, accidental: accidental)
                            }
                        }
                        .padding(.horizontal, 8)

                    case .chordIdentification:
                        ChordOptionsView(
                            options: gameManager.chordAnswerOptions,
                            isEnabled: gameManager.isGameActive && !gameManager.showFeedback
                        ) { option in
                            gameManager.checkChordAnswer(option)
                        }
                        .padding(.horizontal, 20)
                    }
                }
                .padding(.bottom, inputAreaBottomPadding)
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
                    onStartNoteSession: {
                        gameManager.setMode(inputMode)
                        gameManager.startGame(mode: inputMode)
                    },
                    onStartChordSession: {
                        inputMode = .musicNotes
                        gameManager.startGame(mode: .chordIdentification)
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
                onStartNoteGame: {
                    showMenu = false
                    gameManager.setMode(inputMode)
                    gameManager.resetGame()
                },
                onStartChordGame: {
                    showMenu = false
                    inputMode = .musicNotes
                    gameManager.startGame(mode: .chordIdentification)
                }
            )
        }
        .sheet(isPresented: $showOptions) {
            OptionsView()
                .environmentObject(settings)
        }
        .onAppear {
            if gameManager.currentMode != .chordIdentification {
                gameManager.setMode(inputMode)
            }
        }
        .onChange(of: inputMode) { newMode in
            if gameManager.currentMode != .chordIdentification {
                gameManager.setMode(newMode)
            }
        }
        .navigationBarHidden(true)
    }
}

struct StatView: View {
    let title: LocalizedStringKey
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

struct EnhancedStatView: View {
    let title: LocalizedStringKey
    let value: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color(red: 0.91, green: 0.55, blue: 0.56))
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.15))
                )

            VStack(spacing: 2) {
                Text(value)
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(Color.appText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)

                Text(title)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color.appSubtitle)
                    .textCase(.uppercase)
//                    .tracking(0.5)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appMantle)
                .shadow(color: Color.black.opacity(0.08), radius: 8, y: 4)
        )
    }
}

struct ChordOptionsView: View {
    let options: [String]
    let isEnabled: Bool
    let onSelect: (String) -> Void

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
            ForEach(0..<4, id: \.self) { index in
                if options.indices.contains(index) {
                    let option = options[index]

                    Button {
                        if isEnabled {
                            onSelect(option)
                        }
                    } label: {
                        Text(option)
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .foregroundColor(.white.opacity(isEnabled ? 1 : 0.7))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(optionGradient)
                                    .opacity(isEnabled ? 1 : 0.4)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    }
                    .disabled(!isEnabled)
                    .buttonStyle(ScaleButtonStyle())
                } else {
                    PlaceholderChordOption()
                }
            }
        }
    }
}

struct PlaceholderChordOption: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color.appMantle)
            .frame(maxWidth: .infinity, minHeight: 56, maxHeight: 56)
            .overlay(
                ProgressView()
                    .progressViewStyle(
                        CircularProgressViewStyle(tint: Color.appAccent.opacity(0.7))
                    )
            )
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
    let onStartNoteGame: () -> Void
    let onStartChordGame: () -> Void

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    onStartNoteGame()
                }) {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Note Identification")
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

                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                    onStartChordGame()
                }) {
                    HStack {
                        Image(systemName: "music.note.list")
                        Text("Chord Identification")
                    }
                    .font(.headline)
                    .foregroundColor(Color.appAccent)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.appMantle)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.appAccent.opacity(0.2), lineWidth: 1)
                            )
                    )
                }

//                NavigationLink(destination: LearnView()) {
//                    HStack {
//                        Image(systemName: "book")
//                        Text("Learn")
//                    }
//                    .font(.headline)
//                    .foregroundColor(Color.appText)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(
//                        RoundedRectangle(cornerRadius: 12)
//                            .fill(Color.appMantle)
//                    )
//                }

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

struct SessionSummaryOverlay: View {
    let result: SessionResult?
    let history: [SessionResult]
    let onStartNoteSession: () -> Void
    let onStartChordSession: () -> Void
    let onClearHistory: () -> Void
    let onShowOptions: () -> Void

    private var recentHistory: [SessionResult] { history }
    private var displayedResult: SessionResult? { result ?? history.last }
    private var hasHistory: Bool { !recentHistory.isEmpty }

    var body: some View {
        ZStack(alignment: .top) {
            Color.appBackground
                .ignoresSafeArea()

            VStack(spacing: 20) {
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
                            .frame(height: 140)
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
                    Button(action: onStartNoteSession) {
                        HStack(spacing: 8) {
                            Image(systemName: "music.note")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Note Identification")
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

                    Button(action: onStartChordSession) {
                        HStack(spacing: 8) {
                            Image(systemName: "music.note.list")
                                .font(.system(size: 16, weight: .semibold))
                            Text("Chord Identification")
                                .font(.system(size: 18, weight: .semibold))
                        }
                        .foregroundColor(Color.appAccent)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.appMantle)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.appAccent.opacity(0.2), lineWidth: 1)
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
            .padding(.horizontal, 32)
            .padding(.top, 80)
            .padding(.bottom, 32)
        }
    }

    private func format(duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

struct SummaryStat: View {
    let label: LocalizedStringKey
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
