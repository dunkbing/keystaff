//
//  VocalExerciseManager.swift
//  jisho
//

import Foundation
import SwiftUI

/// Drives a vocal exercise session: plays a guide tone for each note of the
/// pattern, listens to the user's pitch, and scores how close they sang.
final class VocalExerciseManager: ObservableObject {
    enum Phase: Equatable {
        case idle
        case countdown(Int)
        case guide
        case listening
        case roundBreak
        case finished
    }

    /// One sample of the user's sung pitch placed on the exercise timeline.
    /// `progress` is a continuous step index (pill i spans i-0.5...i+0.5);
    /// `midi` is nil at silence, breaking the drawn curve.
    struct TracePoint {
        let progress: Double
        let midi: Double?
    }

    @Published private(set) var phase: Phase = .idle
    @Published private(set) var currentRound = 0
    @Published private(set) var currentStep = 0
    /// Accuracy (0...1) of each completed step in the current round
    @Published private(set) var stepAccuracies: [Double] = []
    @Published private(set) var livePitchMidi: Double?
    /// The user's pitch curve for the current round, drawn across the timeline
    @Published private(set) var roundTrace: [TracePoint] = []
    @Published private(set) var sessionResult: VocalSessionResult?
    @Published var isPaused = false
    @Published var micDenied = false

    let exercise: VocalExercise
    let pitchDetector = PitchDetector()

    private var runTask: Task<Void, Never>?
    private var listenSamples: [Double] = []
    private var allAccuracies: [Double] = []
    private var stepStartDate = Date()
    private var stepTotalDuration = 1.0
    private let settings = VocalTrainingSettings.shared

    /// Cents tolerance for a sample to count as in tune
    private let toleranceSemitones = 0.75

    var baseMidi: Int { settings.voiceType.rootMidi }
    var rootMidi: Int { baseMidi + currentRound * exercise.ascendStep }

    func targetMidi(forStep step: Int) -> Int {
        rootMidi + exercise.pattern[step]
    }

    init(exercise: VocalExercise) {
        self.exercise = exercise
        pitchDetector.onPitch = { [weak self] midi in
            guard let self else { return }
            self.livePitchMidi = midi
            if self.phase == .listening, let midi {
                self.listenSamples.append(midi)
            }
            self.recordTracePoint(midi)
        }
    }

    // MARK: - Session Control
    func start() {
        stopRun()
        sessionResult = nil
        isPaused = false
        micDenied = false

        pitchDetector.requestPermission { [weak self] granted in
            guard let self else { return }
            guard granted else {
                self.micDenied = true
                return
            }
            self.startDetector(retriesLeft: 1)
        }
    }

    private func startDetector(retriesLeft: Int) {
        do {
            try pitchDetector.start()
        } catch {
            // Right after the first-ever permission grant the session can still
            // be mid-transition; give it a moment and try once more
            guard retriesLeft > 0 else {
                print("Failed to start pitch detection: \(error)")
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) { [weak self] in
                self?.startDetector(retriesLeft: retriesLeft - 1)
            }
            return
        }
        runTask = Task { @MainActor in
            await run()
        }
    }

    func stop() {
        stopRun()
        pitchDetector.stop()
        phase = .idle
    }

    func togglePause() {
        isPaused.toggle()
    }

    private func stopRun() {
        runTask?.cancel()
        runTask = nil
    }

    deinit {
        runTask?.cancel()
        pitchDetector.stop()
    }

    // MARK: - Run Loop
    @MainActor
    private func run() async {
        allAccuracies = []
        stepAccuracies = []
        currentRound = 0
        currentStep = 0

        // Warm up the sample player during the countdown so the first
        // guide tone plays reliably
        if settings.guideTonesEnabled {
            for offset in Set(exercise.pattern) {
                pitchDetector.preloadGuideTone(midi: Double(baseMidi + offset))
            }
        }

        for count in stride(from: 3, through: 1, by: -1) {
            phase = .countdown(count)
            await pausableSleep(0.8)
            if Task.isCancelled { return }
        }

        for round in 0..<exercise.rounds {
            currentRound = round
            stepAccuracies = []
            roundTrace = []

            for step in 0..<exercise.pattern.count {
                currentStep = step
                let target = Double(targetMidi(forStep: step))
                let guideTime = settings.guideTonesEnabled ? exercise.guideDuration + 0.1 : 0
                stepTotalDuration = guideTime + exercise.noteDuration
                stepStartDate = Date()

                phase = .guide
                if settings.guideTonesEnabled {
                    pitchDetector.playGuideTone(midi: target, duration: exercise.guideDuration)
                    await pausableSleep(exercise.guideDuration + 0.1)
                    if Task.isCancelled { return }
                }

                listenSamples = []
                phase = .listening
                await pausableSleep(exercise.noteDuration)
                if Task.isCancelled { return }

                let accuracy = stepAccuracy(samples: listenSamples, target: target)
                stepAccuracies.append(accuracy)
                allAccuracies.append(accuracy)
            }

            if round < exercise.rounds - 1 {
                phase = .roundBreak
                await pausableSleep(0.7)
                if Task.isCancelled { return }
            }
        }

        finish()
    }

    @MainActor
    private func finish() {
        pitchDetector.stop()

        let meanAccuracy =
            allAccuracies.isEmpty
            ? 0 : allAccuracies.reduce(0, +) / Double(allAccuracies.count)
        let accuracyPercent = meanAccuracy * 100
        let score = Int(allAccuracies.reduce(0) { $0 + $1 * 100 }.rounded())
        let stars: Int
        switch accuracyPercent {
        case 80...: stars = 3
        case 55..<80: stars = 2
        default: stars = 1
        }

        let result = VocalSessionResult(
            exerciseId: exercise.id,
            score: score,
            accuracy: accuracyPercent,
            stars: stars
        )
        sessionResult = result
        VocalProgressStore.shared.add(result)
        phase = .finished
    }

    private func stepAccuracy(samples: [Double], target: Double) -> Double {
        guard samples.count >= 2 else { return 0 }
        let inTune = samples.filter { abs($0 - target) <= toleranceSemitones }.count
        return Double(inTune) / Double(samples.count)
    }

    /// Places the latest mic sample on the round timeline so the view can draw
    /// the user's pitch curve next to the target pills
    private func recordTracePoint(_ midi: Double?) {
        guard phase == .guide || phase == .listening, !isPaused else { return }

        let elapsed = Date().timeIntervalSince(stepStartDate)
        let fraction = min(1, max(0, elapsed / max(0.001, stepTotalDuration)))
        let progress = Double(currentStep) - 0.5 + fraction

        // Collapse consecutive silence into a single curve break
        if midi == nil, roundTrace.last?.midi == nil { return }
        roundTrace.append(TracePoint(progress: progress, midi: midi))
    }

    /// Sleeps in small chunks so pause and cancellation stay responsive
    private func pausableSleep(_ seconds: Double) async {
        var remaining = seconds
        while remaining > 0 {
            if Task.isCancelled { return }
            if isPaused {
                try? await Task.sleep(nanoseconds: 100_000_000)
                continue
            }
            let chunk = min(0.05, remaining)
            try? await Task.sleep(nanoseconds: UInt64(chunk * 1_000_000_000))
            remaining -= chunk
        }
    }
}
