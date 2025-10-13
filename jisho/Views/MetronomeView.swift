//
//  MetronomeView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 28/9/25.
//

import SwiftUI
import TikimUI

class MetronomeManager: ObservableObject {
    @Published var isPlaying: Bool = false
    @Published var tempo: Double = 120
    @Published var timeSignature: TimeSignature = .fourFour {
        didSet { updateBeatCycle() }
    }
    @Published var currentBeat: Int = 0

    private var timer: DispatchSourceTimer?
    private let audioManager = AudioManager.shared
    private var beatIndex: Int = 0
    private var resumeWorkItem: DispatchWorkItem?
    private var wasPlayingBeforeAdjustment = false
    private let autoResumeDelay: TimeInterval = 0.7

    var bpm: String {
        String(format: "%.0f", tempo)
    }

    func togglePlay() {
        if isPlaying {
            stop()
        } else {
            cancelAutoResume(resetFlag: true)
            start()
        }
    }

    func start() {
        resetTimerState()
        audioManager.stopMetronome()
        isPlaying = true
        beatIndex = timeSignature.beatsPerMeasure - 1
        currentBeat = 0
        scheduleTimer(fireImmediately: true)
        wasPlayingBeforeAdjustment = false
    }

    func stop() {
        cancelAutoResume(resetFlag: true)
        isPlaying = false
        resetTimerState()
        beatIndex = 0
        currentBeat = 0
        audioManager.stopMetronome()
    }

    func updateBeatCycle() {
        beatIndex = beatIndex % max(timeSignature.beatsPerMeasure, 1)
        currentBeat = beatIndex
    }

    private func scheduleTimer(fireImmediately: Bool) {
        guard isPlaying else { return }

        let interval = 60.0 / tempo

        let timer = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        timer.schedule(deadline: fireImmediately ? .now() : .now() + interval, repeating: interval)
        timer.setEventHandler { [weak self] in
            guard let self = self, self.isPlaying else { return }
            self.beatIndex = (self.beatIndex + 1) % self.timeSignature.beatsPerMeasure
            self.currentBeat = self.beatIndex
            let isAccent = self.timeSignature.accentBeats.contains(self.beatIndex)
            self.audioManager.playMetronomeBeat(isAccent: isAccent)
        }
        timer.resume()
        self.timer = timer
    }

    func handleTempoEditingChange(isEditing: Bool) {
        if isEditing {
            beginInteractiveChange()
        } else {
            endInteractiveChange()
        }
    }

    func changeTimeSignature(to signature: TimeSignature) {
        guard timeSignature != signature else { return }
        let shouldResume = isPlaying || wasPlayingBeforeAdjustment

        if shouldResume {
            beginInteractiveChange()
            wasPlayingBeforeAdjustment = true
        } else {
            cancelAutoResume(resetFlag: true)
        }

        timeSignature = signature

        if shouldResume {
            endInteractiveChange()
        }
    }

    private func beginInteractiveChange() {
        cancelAutoResume(resetFlag: false)

        if isPlaying {
            wasPlayingBeforeAdjustment = true
            pauseMetronomeForAdjustment()
        }
    }

    private func endInteractiveChange() {
        scheduleAutoResume()
    }

    private func pauseMetronomeForAdjustment() {
        guard isPlaying else { return }

        resetTimerState()
        audioManager.stopMetronome()
        isPlaying = false
        beatIndex = 0
        currentBeat = 0
    }

    private func scheduleAutoResume() {
        cancelAutoResume(resetFlag: false)
        guard wasPlayingBeforeAdjustment else { return }

        let workItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            self.start()
            self.wasPlayingBeforeAdjustment = false
        }

        resumeWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + autoResumeDelay, execute: workItem)
    }

    private func cancelAutoResume(resetFlag: Bool) {
        resumeWorkItem?.cancel()
        resumeWorkItem = nil

        if resetFlag {
            wasPlayingBeforeAdjustment = false
        }
    }

    private func resetTimerState() {
        timer?.cancel()
        timer = nil
    }
}

struct MetronomeView: View {
    @StateObject private var metronome = MetronomeManager()
    private let timeSignatureColumns: [GridItem] = Array(
        repeating: GridItem(.flexible(), spacing: 12),
        count: 3
    )

    var body: some View {
        ZStack {
            Color.appBackground
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    // BPM Display
                    VStack(spacing: 10) {
                        Text("TEMPO")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.appSubtitle)

                        HStack(spacing: 5) {
                            Text(metronome.bpm)
                                .font(.system(size: 80, weight: .bold))
                                .foregroundColor(Color.appText)

                            Text("BPM")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(Color.appSubtitle)
                        }
                    }

                    // Beat indicator
                    BeatIndicatorView(
                        currentBeat: metronome.currentBeat,
                        totalBeats: metronome.timeSignature.beatsPerMeasure,
                        isPlaying: metronome.isPlaying
                    )
                    .frame(height: 60)
                    .padding(.horizontal)

                    // Tempo slider
                    VStack(spacing: 16) {
                        HStack {
                            Text("40")
                                .font(.caption)
                                .foregroundColor(Color.appSubtitle)

                            Spacer()

                            Text("240")
                                .font(.caption)
                                .foregroundColor(Color.appSubtitle)
                        }

                        Slider(
                            value: $metronome.tempo,
                            in: 40...240,
                            step: 1,
                            onEditingChanged: { editing in
                                metronome.handleTempoEditingChange(isEditing: editing)
                            }
                        )
                            .accentColor(Color(red: 0.91, green: 0.55, blue: 0.56))
                    }

                    // Time signature selector
                    VStack(spacing: 12) {
                        Text("TIME SIGNATURE")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(Color.appSubtitle)

                        LazyVGrid(columns: timeSignatureColumns, alignment: .center, spacing: 12) {
                            ForEach(TimeSignature.allCases) { signature in
                                Button(action: {
                                    metronome.changeTimeSignature(to: signature)
                                }) {
                                    Text(signature.rawValue)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(
                                            metronome.timeSignature == signature
                                                ? Color.white : Color.appText
                                        )
                                        .frame(width: 70, height: 50)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(
                                                    metronome.timeSignature == signature
                                                        ? Color(red: 0.91, green: 0.55, blue: 0.56)
                                                        : Color.appMantle
                                                )
                                        )
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                    }
                }
                .padding(.top, 30)
                .padding(.horizontal, 32)
                .padding(.bottom, 140)
            }
        }
        .overlay(alignment: .bottom) {
            Button(action: { metronome.togglePlay() }) {
                Image(systemName: metronome.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 36))
                    .foregroundColor(.white)
                    .frame(width: 88, height: 88)
                    .background(
                        Circle()
                            .fill(Color(red: 0.91, green: 0.55, blue: 0.56))
                    )
                    .shadow(
                        color: Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.35),
                        radius: 16,
                        y: 6
                    )
            }
            .padding(.bottom, 140)
        }
        .navigationBarHidden(true)
        .onDisappear {
            metronome.stop()
        }
    }
}

struct BeatIndicatorView: View {
    let currentBeat: Int
    let totalBeats: Int
    let isPlaying: Bool

    private var layoutConfiguration: (columns: [GridItem], circleSize: CGFloat, spacing: CGFloat) {
        switch totalBeats {
        case 0...4:
            let count = max(totalBeats, 1)
            return (
                Array(repeating: GridItem(.flexible(), spacing: 16), count: count),
                50,
                16
            )
        case 5...8:
            let columns = Int(ceil(Double(totalBeats) / 2.0))
            return (
                Array(repeating: GridItem(.flexible(), spacing: 12), count: columns),
                40,
                12
            )
        default:
            let columns = Int(ceil(Double(totalBeats) / 2.0))
            return (
                Array(repeating: GridItem(.flexible(), spacing: 10), count: max(columns, 1)),
                34,
                10
            )
        }
    }

    var body: some View {
        let layout = layoutConfiguration

        LazyVGrid(columns: layout.columns, alignment: .center, spacing: layout.spacing) {
            ForEach(0..<totalBeats, id: \.self) { beat in
                Circle()
                    .fill(
                        isPlaying && beat == currentBeat
                            ? Color(red: 0.91, green: 0.55, blue: 0.56)
                            : Color.appMantle
                    )
                    .frame(width: layout.circleSize, height: layout.circleSize)
                    .overlay(
                        Circle()
                            .stroke(
                                beat == 0
                                    ? Color(red: 0.91, green: 0.55, blue: 0.56) : Color.appSubtitle
                                        .opacity(0.3),
                                lineWidth: 2
                            )
                    )
                    .scaleEffect(isPlaying && beat == currentBeat ? 1.2 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: currentBeat)
            }
        }
    }
}
