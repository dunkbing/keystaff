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
            // Gradient background
            LinearGradient(
                colors: [
                    Color.appBackground,
                    Color.appBackground,
                    Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    // BPM Display with play button inside
                    VStack(spacing: 16) {
                        HStack(spacing: 12) {
                            Text("TEMPO")
                                .font(.system(size: 14, weight: .semibold))
                                .tracking(2)
                                .foregroundColor(Color.appSubtitle)

                            Text(metronome.bpm)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(Color.appText)

                            Text("BPM")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(Color.appSubtitle)

                            Spacer()
                        }
                        .padding(.horizontal, 24)

                        ZStack {
                            // Animated circular progress
                            Circle()
                                .stroke(Color.appMantle, lineWidth: 8)
                                .frame(width: 200, height: 200)

                            Circle()
                                .trim(from: 0, to: CGFloat((metronome.tempo - 40) / 200))
                                .stroke(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.91, green: 0.55, blue: 0.56),
                                            Color(red: 0.98, green: 0.75, blue: 0.76)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .frame(width: 200, height: 200)
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(response: 0.5), value: metronome.tempo)

                            // Play button inside circle
                            Button(action: { metronome.togglePlay() }) {
                                ZStack {
                                    Circle()
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
                                        .frame(width: 88, height: 88)

                                    Image(systemName: metronome.isPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 36, weight: .semibold))
                                        .foregroundColor(.white)
                                        .offset(x: metronome.isPlaying ? 0 : 3)
                                }
                                .shadow(
                                    color: Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.5),
                                    radius: 20,
                                    y: 8
                                )
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                        .padding(.vertical, 20)
                    }

                    // Tempo slider with enhanced design
                    VStack(spacing: 20) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("ADJUST TEMPO")
                                    .font(.system(size: 12, weight: .semibold))
                                    .tracking(2)
                                    .foregroundColor(Color.appSubtitle)

                                Text("Slide to change BPM")
                                    .font(.caption)
                                    .foregroundColor(Color.appSubtitle.opacity(0.6))
                            }

                            Spacer()
                        }

                        HStack(spacing: 20) {
                            Text("40")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.appSubtitle)
                                .frame(width: 32)

                            Slider(
                                value: $metronome.tempo,
                                in: 40...240,
                                step: 1,
                                onEditingChanged: { editing in
                                    metronome.handleTempoEditingChange(isEditing: editing)
                                }
                            )
                            .accentColor(Color(red: 0.91, green: 0.55, blue: 0.56))

                            Text("240")
                                .font(.system(size: 14, weight: .semibold, design: .rounded))
                                .foregroundColor(Color.appSubtitle)
                                .frame(width: 32)
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.appMantle)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
                    )
                    .padding(.horizontal, 24)

                    // Beat indicator with new design
                    VStack(spacing: 16) {
                        Text("BEAT")
                            .font(.system(size: 12, weight: .semibold))
                            .tracking(2)
                            .foregroundColor(Color.appSubtitle)

                        BeatIndicatorView(
                            currentBeat: metronome.currentBeat,
                            totalBeats: metronome.timeSignature.beatsPerMeasure,
                            isPlaying: metronome.isPlaying
                        )
                        .frame(height: 80)
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 20)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(Color.appMantle)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
                    )
                    .padding(.horizontal, 24)

                    // Time signature selector with card design
                    VStack(spacing: 16) {
                        HStack {
                            Text("TIME SIGNATURE")
                                .font(.system(size: 12, weight: .semibold))
                                .tracking(2)
                                .foregroundColor(Color.appSubtitle)

                            Spacer()
                        }

                        LazyVGrid(columns: timeSignatureColumns, alignment: .center, spacing: 14) {
                            ForEach(TimeSignature.allCases) { signature in
                                Button(action: {
                                    metronome.changeTimeSignature(to: signature)
                                }) {
                                    VStack(spacing: 8) {
                                        Text(signature.rawValue)
                                            .font(.system(size: 22, weight: .bold, design: .rounded))
                                            .foregroundColor(
                                                metronome.timeSignature == signature
                                                    ? Color.white : Color.appText
                                            )

                                        if metronome.timeSignature == signature {
                                            Circle()
                                                .fill(Color.white)
                                                .frame(width: 4, height: 4)
                                        }
                                    }
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 70)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(
                                                metronome.timeSignature == signature
                                                    ? LinearGradient(
                                                        colors: [
                                                            Color(red: 0.91, green: 0.55, blue: 0.56),
                                                            Color(red: 0.85, green: 0.45, blue: 0.46)
                                                        ],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                                    : LinearGradient(
                                                        colors: [Color.appSurface2, Color.appSurface2],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    )
                                            )
                                            .shadow(
                                                color: metronome.timeSignature == signature
                                                    ? Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.4)
                                                    : Color.clear,
                                                radius: 8,
                                                y: 4
                                            )
                                    )
                                }
                                .buttonStyle(ScaleButtonStyle())
                            }
                        }
                    }
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.appMantle)
                            .shadow(color: Color.black.opacity(0.1), radius: 10, y: 5)
                    )
                    .padding(.horizontal, 24)
                }
                .padding(.top, 40)
                .padding(.bottom, 200)
            }
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
                Array(repeating: GridItem(.flexible(), spacing: 18), count: count),
                56,
                18
            )
        case 5...8:
            let columns = Int(ceil(Double(totalBeats) / 2.0))
            return (
                Array(repeating: GridItem(.flexible(), spacing: 14), count: columns),
                46,
                14
            )
        default:
            let columns = Int(ceil(Double(totalBeats) / 2.0))
            return (
                Array(repeating: GridItem(.flexible(), spacing: 12), count: max(columns, 1)),
                38,
                12
            )
        }
    }

    var body: some View {
        let layout = layoutConfiguration

        LazyVGrid(columns: layout.columns, alignment: .center, spacing: layout.spacing) {
            ForEach(0..<totalBeats, id: \.self) { beat in
                ZStack {
                    // Background circle
                    Circle()
                        .fill(
                            isPlaying && beat == currentBeat
                                ? LinearGradient(
                                    colors: [
                                        Color(red: 0.91, green: 0.55, blue: 0.56),
                                        Color(red: 0.85, green: 0.45, blue: 0.46)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color.appSurface2, Color.appSurface2],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                        .frame(width: layout.circleSize, height: layout.circleSize)

                    // Accent ring for first beat
                    if beat == 0 {
                        Circle()
                            .stroke(
                                Color(red: 0.91, green: 0.55, blue: 0.56),
                                lineWidth: 3
                            )
                            .frame(
                                width: layout.circleSize + 4,
                                height: layout.circleSize + 4
                            )
                            .opacity(isPlaying && beat == currentBeat ? 0 : 0.6)
                    }

                    // Pulse effect when active
                    if isPlaying && beat == currentBeat {
                        Circle()
                            .stroke(
                                Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.6),
                                lineWidth: 2
                            )
                            .frame(
                                width: layout.circleSize + 12,
                                height: layout.circleSize + 12
                            )
                            .scaleEffect(1.2)
                            .opacity(0)
                            .animation(
                                Animation.easeOut(duration: 0.4),
                                value: currentBeat
                            )
                    }

                    // Beat number
                    Text("\(beat + 1)")
                        .font(.system(size: layout.circleSize * 0.35, weight: .bold, design: .rounded))
                        .foregroundColor(
                            isPlaying && beat == currentBeat
                                ? Color.white
                                : Color.appSubtitle
                        )
                }
                .scaleEffect(isPlaying && beat == currentBeat ? 1.15 : 1.0)
                .shadow(
                    color: isPlaying && beat == currentBeat
                        ? Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.5)
                        : Color.clear,
                    radius: 12,
                    y: 4
                )
                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentBeat)
            }
        }
    }
}
