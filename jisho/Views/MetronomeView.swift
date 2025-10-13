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

    var bpm: String {
        String(format: "%.0f", tempo)
    }

    func togglePlay() {
        if isPlaying {
            stop()
        } else {
            start()
        }
    }

    func start() {
        stop()
        isPlaying = true
        beatIndex = timeSignature.beatsPerMeasure - 1
        currentBeat = 0
        scheduleTimer(fireImmediately: true)
    }

    func stop() {
        isPlaying = false
        timer?.cancel()
        timer = nil
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
            let isAccent = self.beatIndex == 0
            self.audioManager.playMetronomeBeat(isAccent: isAccent)
        }
        timer.resume()
        self.timer = timer
    }
}

struct MetronomeView: View {
    @StateObject private var metronome = MetronomeManager()
    private let timeSignatureColumns = [GridItem(.adaptive(minimum: 80), spacing: 12)]

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

                        Slider(value: $metronome.tempo, in: 40...240, step: 1)
                            .accentColor(Color(red: 0.91, green: 0.55, blue: 0.56))
                            .disabled(metronome.isPlaying)
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
                                    if !metronome.isPlaying {
                                        metronome.timeSignature = signature
                                    }
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
                                .disabled(metronome.isPlaying)
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

    var body: some View {
        HStack(spacing: 16) {
            ForEach(0..<totalBeats, id: \.self) { beat in
                Circle()
                    .fill(
                        isPlaying && beat == currentBeat
                            ? Color(red: 0.91, green: 0.55, blue: 0.56)
                            : Color.appMantle
                    )
                    .frame(width: 50, height: 50)
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
