//
//  VocalExerciseSessionView.swift
//  jisho
//

import SwiftUI

struct VocalExerciseSessionView: View {
    let exercise: VocalExercise
    @StateObject private var manager: VocalExerciseManager
    @Environment(\.presentationMode) private var presentationMode

    private let guideLineX: CGFloat = 84

    init(exercise: VocalExercise) {
        self.exercise = exercise
        _manager = StateObject(wrappedValue: VocalExerciseManager(exercise: exercise))
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            pitchLadder

            VStack {
                topBar
                Spacer()
                roundDots
                    .padding(.bottom, 24)
            }

            if case .countdown(let count) = manager.phase {
                countdownOverlay(count)
            }

            if manager.isPaused {
                pausedOverlay
            }

            if manager.micDenied {
                micDeniedOverlay
            }

            if manager.phase == .finished, let result = manager.sessionResult {
                VocalSessionResultOverlay(
                    result: result,
                    onRetry: { manager.start() },
                    onDone: { presentationMode.wrappedValue.dismiss() }
                )
            }
        }
        .onAppear { manager.start() }
        .onDisappear { manager.stop() }
    }

    // MARK: - Top Bar
    private var topBar: some View {
        HStack {
            Button(action: {
                manager.stop()
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Color.appText)
                    .padding(10)
                    .background(Circle().fill(Color.appSurface))
            }

            Spacer()

            if manager.phase != .finished, !manager.micDenied {
                Button(action: { manager.togglePause() }) {
                    Image(systemName: manager.isPaused ? "play.fill" : "pause.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color.appText)
                        .padding(10)
                        .background(Circle().fill(Color.appSurface))
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }

    // MARK: - Pitch Ladder
    private var pitchLadder: some View {
        GeometryReader { geo in
            let notes = exercise.pattern.map { manager.rootMidi + $0 }
            let minMidi = (notes.min() ?? 57) - 3
            let maxMidi = (notes.max() ?? 69) + 3
            let rowCount = max(1, maxMidi - minMidi)
            let yFor: (Double) -> CGFloat = { midi in
                let clamped = min(Double(maxMidi), max(Double(minMidi), midi))
                let fraction = (Double(maxMidi) - clamped) / Double(rowCount)
                return geo.size.height * 0.08 + geo.size.height * 0.84 * CGFloat(fraction)
            }
            // Maps a continuous step index (pill i = progress i) onto the pill row
            let stepCount = exercise.pattern.count
            let pillAreaStart = guideLineX + 36
            let pillAreaWidth = geo.size.width - pillAreaStart - 24
            let xFor: (Double) -> CGFloat = { progress in
                stepCount > 1
                    ? pillAreaStart + pillAreaWidth * CGFloat(progress) / CGFloat(stepCount - 1)
                    : pillAreaStart + pillAreaWidth / 2
            }

            ZStack {
                // Piano roll keys and guide dots, one row per semitone
                let rowHeight = geo.size.height * 0.84 / CGFloat(rowCount)
                let activeTarget: Int? =
                    (manager.phase == .guide || manager.phase == .listening)
                    ? manager.targetMidi(forStep: manager.currentStep) : nil
                let sungMidi = manager.livePitchMidi.map { Int($0.rounded()) }

                ForEach(minMidi...maxMidi, id: \.self) { midi in
                    let y = yFor(Double(midi))
                    let semitone = ((midi % 12) + 12) % 12
                    let isBlackKey = [1, 3, 6, 8, 10].contains(semitone)
                    let isTarget = midi == activeTarget
                    let isSung = midi == sungMidi && activeTarget != nil

                    RoundedRectangle(cornerRadius: 3)
                        .fill(
                            isTarget
                                ? Color.appAccent
                                : isSung
                                    ? Color.appAccent.opacity(0.35)
                                    : isBlackKey
                                        ? Color.appText.opacity(0.8)
                                        : Color.appMantle
                        )
                        .frame(width: isBlackKey ? 34 : 54, height: max(4, rowHeight - 2))
                        .overlay(
                            RoundedRectangle(cornerRadius: 3)
                                .stroke(Color.appSurface2.opacity(0.6), lineWidth: 0.5)
                        )
                        .overlay(
                            Text(midiNoteName(midi, includeOctave: semitone == 0))
                                .font(.system(size: 9, weight: .semibold, design: .rounded))
                                .foregroundColor(
                                    isTarget || isBlackKey ? .white : Color.appSubtitle
                                )
                                .padding(.trailing, 4),
                            alignment: .trailing
                        )
                        .position(x: isBlackKey ? 17 : 27, y: y)

                    Circle()
                        .fill(Color.appSurface2.opacity(0.8))
                        .frame(width: 5, height: 5)
                        .position(x: guideLineX, y: y)
                }

                // User's sung pitch curve across the timeline
                roundTraceCanvas(xFor: xFor, yFor: yFor)

                // Live pitch indicator at the head of the curve
                if manager.phase == .guide || manager.phase == .listening,
                    let head = manager.roundTrace.last(where: { $0.midi != nil }),
                    let headMidi = head.midi,
                    manager.livePitchMidi != nil
                {
                    Circle()
                        .fill(Color.appAccent)
                        .frame(width: 13, height: 13)
                        .shadow(color: Color.appAccent.opacity(0.7), radius: 8)
                        .position(
                            x: max(8, xFor(head.progress)),
                            y: yFor(headMidi)
                        )
                        .animation(.linear(duration: 0.08), value: headMidi)
                }

                // Target pills
                ForEach(Array(exercise.pattern.enumerated()), id: \.offset) { index, offset in
                    let midi = manager.rootMidi + offset

                    pill(for: index)
                        .position(x: xFor(Double(index)), y: yFor(Double(midi)))
                }
            }
            .animation(.easeInOut(duration: 0.4), value: manager.currentRound)
        }
    }

    private func pill(for step: Int) -> some View {
        let isCurrent =
            step == manager.currentStep
            && (manager.phase == .guide || manager.phase == .listening)
        let isDone = step < manager.stepAccuracies.count

        var background = Color.appSurface1
        if isCurrent {
            background = Color.appAccent
        } else if isDone {
            let accuracy = manager.stepAccuracies[step]
            background =
                accuracy >= 0.7
                ? Color.green.opacity(0.75)
                : (accuracy >= 0.35 ? Color.orange.opacity(0.75) : Color.appSurface2)
        }

        return Text(exercise.syllable(for: step))
            .font(.system(size: 15, weight: .bold, design: .rounded))
            .foregroundColor(isCurrent || isDone ? .white : Color.appText)
            .padding(.horizontal, 16)
            .padding(.vertical, 9)
            .background(Capsule().fill(background))
            .scaleEffect(isCurrent ? 1.12 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isCurrent)
    }

    private func roundTraceCanvas(
        xFor: @escaping (Double) -> CGFloat,
        yFor: @escaping (Double) -> CGFloat
    ) -> some View {
        Canvas { context, size in
            let trace = manager.roundTrace
            guard trace.count > 1 else { return }

            var path = Path()
            var lastWasBreak = true

            for point in trace {
                guard let midi = point.midi else {
                    lastWasBreak = true
                    continue
                }
                let location = CGPoint(x: max(8, xFor(point.progress)), y: yFor(midi))
                if lastWasBreak {
                    path.move(to: location)
                } else {
                    path.addLine(to: location)
                }
                lastWasBreak = false
            }

            let gradient = Gradient(colors: [
                Color.blue.opacity(0.85),
                Color.purple.opacity(0.85),
                Color.pink.opacity(0.85),
            ])
            let shading = GraphicsContext.Shading.linearGradient(
                gradient,
                startPoint: .zero,
                endPoint: CGPoint(x: size.width, y: 0)
            )

            // Soft glow pass behind the main stroke
            var glow = context
            glow.addFilter(.blur(radius: 4))
            glow.stroke(
                path,
                with: shading,
                style: StrokeStyle(lineWidth: 7, lineCap: .round, lineJoin: .round)
            )

            context.stroke(
                path,
                with: shading,
                style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
            )
        }
        .allowsHitTesting(false)
    }

    // MARK: - Round Progress
    private var roundDots: some View {
        HStack(spacing: 6) {
            ForEach(0..<exercise.rounds, id: \.self) { round in
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        round <= manager.currentRound && manager.phase != .idle
                            ? Color.appText : Color.appSurface2
                    )
                    .frame(width: round == manager.currentRound ? 10 : 7, height: 12)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
        .background(Capsule().fill(Color.appSurface.opacity(0.8)))
    }

    // MARK: - Overlays
    private func countdownOverlay(_ count: Int) -> some View {
        ZStack {
            Color.appBackground.opacity(0.75).ignoresSafeArea()
            VStack(spacing: 12) {
                Text("\(count)")
                    .font(.system(size: 90, weight: .heavy, design: .rounded))
                    .foregroundColor(Color.appText)
                Text("Get ready to sing")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color.appSubtitle)
            }
        }
        .transition(.opacity)
    }

    private var pausedOverlay: some View {
        ZStack {
            Color.appBackground.opacity(0.8).ignoresSafeArea()
            VStack(spacing: 20) {
                Text("Paused")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(Color.appText)
                Button(action: { manager.togglePause() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "play.fill")
                        Text("Resume")
                            .fontWeight(.bold)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 14)
                    .background(Capsule().fill(Color.appAccent))
                }
            }
        }
    }

    private var micDeniedOverlay: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            VStack(spacing: 16) {
                Image(systemName: "mic.slash.fill")
                    .font(.system(size: 44))
                    .foregroundColor(Color.appSubtitle)
                Text("Microphone Access Needed")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.appText)
                Text("Allow microphone access in Settings so we can hear your singing.")
                    .font(.system(size: 15))
                    .foregroundColor(Color.appSubtitle)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                Button(action: {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }) {
                    Text("Open Settings")
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 28)
                        .padding(.vertical, 14)
                        .background(Capsule().fill(Color.appAccent))
                }
            }
        }
    }
}

// MARK: - Result Overlay
struct VocalSessionResultOverlay: View {
    let result: VocalSessionResult
    let onRetry: () -> Void
    let onDone: () -> Void

    private var message: LocalizedStringKey {
        switch result.accuracy {
        case 80...: return "Great pitch control!"
        case 55..<80: return "Getting there — keep practicing!"
        default: return "You are quite off-pitch."
        }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                HStack(spacing: 10) {
                    ForEach(0..<3, id: \.self) { index in
                        Image(systemName: index < result.stars ? "star.fill" : "star")
                            .font(.system(size: 34))
                            .foregroundColor(
                                index < result.stars ? Color.appAccent : Color.appSurface2
                            )
                    }
                }

                Text("\(result.score)")
                    .font(.system(size: 72, weight: .heavy, design: .rounded))
                    .foregroundColor(Color.appText)
                    .padding(.top, 8)

                VStack(spacing: 12) {
                    Text("Pitch Accuracy")
                        .font(.system(size: 13, weight: .bold))
                        .textCase(.uppercase)
                        .foregroundColor(Color.appSubtitle)

                    Text("\(Int(result.accuracy.rounded()))%")
                        .font(.system(size: 44, weight: .bold, design: .rounded))
                        .foregroundColor(Color.appText)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.appSurface2)
                                .frame(height: 8)
                            Capsule()
                                .fill(Color.appAccent)
                                .frame(
                                    width: max(
                                        8, geo.size.width * CGFloat(result.accuracy / 100)),
                                    height: 8
                                )
                        }
                        .frame(maxHeight: .infinity)
                    }
                    .frame(height: 12)

                    Text(message)
                        .font(.system(size: 15))
                        .foregroundColor(Color.appSubtitle)
                }
                .padding(24)
                .background(RoundedRectangle(cornerRadius: 20).fill(Color.appMantle))
                .padding(.horizontal, 40)
                .padding(.top, 36)

                Spacer()

                HStack(spacing: 12) {
                    Button(action: onRetry) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.appText)
                            .frame(width: 60, height: 56)
                            .background(RoundedRectangle(cornerRadius: 18).fill(Color.appSurface))
                    }

                    Button(action: onDone) {
                        Text("Done")
                            .font(.system(size: 19, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color(red: 0.91, green: 0.55, blue: 0.56),
                                                Color(red: 0.85, green: 0.45, blue: 0.46),
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            )
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .transition(.opacity)
    }
}
