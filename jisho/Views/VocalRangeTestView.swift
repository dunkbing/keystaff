//
//  VocalRangeTestView.swift
//  jisho
//

import SwiftUI

/// Detects the user's vocal range: sing your lowest and highest notes and the
/// view suggests a voice type, which transposes all vocal exercises.
struct VocalRangeTestView: View {
    @StateObject private var pitchDetector = PitchDetector()
    @ObservedObject private var settings = VocalTrainingSettings.shared
    @Environment(\.presentationMode) private var presentationMode

    @State private var lowestMidi: Int?
    @State private var highestMidi: Int?
    @State private var recentSamples: [Double] = []
    @State private var micDenied = false

    // Gauge spans C2...C7
    private let gaugeMin = 36.0
    private let gaugeMax = 96.0

    private var suggestedVoice: VoiceType? {
        lowestMidi.map { VoiceType.suggested(forLowest: $0) }
    }

    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                HStack {
                    Spacer()
                    Button(action: { presentationMode.wrappedValue.dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(Color.appText)
                            .padding(10)
                            .background(Circle().fill(Color.appSurface))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)

                Text("Vocal Range Test")
                    .font(.system(size: 26, weight: .bold, design: .rounded))
                    .foregroundColor(Color.appText)
                    .padding(.top, 4)

                Spacer()

                gauge
                    .frame(width: 250, height: 250)

                Spacer()

                if micDenied {
                    Text("Allow microphone access in Settings to test your range.")
                        .font(.system(size: 15))
                        .foregroundColor(Color.appSubtitle)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                } else {
                    Text("Sing \"Ah\" on your lowest note, then your highest, holding each for a moment.")
                        .font(.system(size: 16))
                        .foregroundColor(Color.appSubtitle)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 36)
                }

                HStack(spacing: 14) {
                    rangeChip(title: "Lowest", midi: lowestMidi)
                    rangeChip(title: "Highest", midi: highestMidi)
                }
                .padding(.top, 20)

                if let voice = suggestedVoice {
                    HStack(spacing: 6) {
                        Image(systemName: "music.mic")
                            .font(.system(size: 13))
                        Text("Suggested: \(voice.rawValue)")
                            .font(.system(size: 15, weight: .semibold))
                    }
                    .foregroundColor(Color.appAccent)
                    .padding(.top, 14)
                }

                Spacer()

                HStack(spacing: 12) {
                    Button(action: reset) {
                        Image(systemName: "arrow.clockwise")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(Color.appText)
                            .frame(width: 60, height: 56)
                            .background(RoundedRectangle(cornerRadius: 18).fill(Color.appSurface))
                    }

                    Button(action: save) {
                        Text("Use This Range")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 56)
                            .background(
                                RoundedRectangle(cornerRadius: 18)
                                    .fill(
                                        suggestedVoice == nil
                                            ? AnyShapeStyle(Color.appSurface2)
                                            : AnyShapeStyle(
                                                LinearGradient(
                                                    colors: [
                                                        Color(red: 0.91, green: 0.55, blue: 0.56),
                                                        Color(red: 0.85, green: 0.45, blue: 0.46),
                                                    ],
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                ))
                                    )
                            )
                    }
                    .disabled(suggestedVoice == nil)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .onAppear(perform: startDetection)
        .onDisappear { pitchDetector.stop() }
    }

    // MARK: - Gauge
    private var gauge: some View {
        ZStack {
            Circle()
                .trim(from: 0.1, to: 0.9)
                .stroke(
                    Color.appSurface1,
                    style: StrokeStyle(lineWidth: 22, lineCap: .round)
                )
                .rotationEffect(.degrees(90))

            if let pitch = pitchDetector.midiNote {
                Circle()
                    .trim(from: 0.1, to: 0.1 + 0.8 * gaugeFraction(pitch))
                    .stroke(
                        Color.appAccent,
                        style: StrokeStyle(lineWidth: 22, lineCap: .round)
                    )
                    .rotationEffect(.degrees(90))
                    .animation(.linear(duration: 0.1), value: pitch)
            }

            VStack(spacing: 4) {
                Text(currentNoteText)
                    .font(.system(size: 46, weight: .heavy, design: .rounded))
                    .foregroundColor(Color.appText)
                if let frequency = pitchDetector.frequency {
                    Text("\(Int(frequency.rounded())) Hz")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color.appSubtitle)
                }
            }

            VStack {
                Spacer()
                HStack {
                    Text("C2")
                    Spacer()
                    Text("C7")
                }
                .font(.system(size: 13, weight: .semibold, design: .rounded))
                .foregroundColor(Color.appSubtitle.opacity(0.7))
                .padding(.horizontal, 18)
            }
        }
    }

    private var currentNoteText: String {
        guard let pitch = pitchDetector.midiNote else { return "—" }
        return midiNoteName(Int(pitch.rounded()))
    }

    private func gaugeFraction(_ midi: Double) -> CGFloat {
        CGFloat(min(1, max(0, (midi - gaugeMin) / (gaugeMax - gaugeMin))))
    }

    private func rangeChip(title: LocalizedStringKey, midi: Int?) -> some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .textCase(.uppercase)
                .foregroundColor(Color.appSubtitle)
            Text(midi.map { midiNoteName($0) } ?? "—")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(Color.appText)
        }
        .frame(width: 110)
        .padding(.vertical, 12)
        .background(RoundedRectangle(cornerRadius: 16).fill(Color.appMantle))
    }

    // MARK: - Detection
    private func startDetection() {
        pitchDetector.onPitch = { midi in
            guard let midi else {
                recentSamples.removeAll()
                return
            }
            recentSamples.append(midi)
            if recentSamples.count > 6 {
                recentSamples.removeFirst(recentSamples.count - 6)
            }
            // Only register a note once the pitch has been held steadily
            guard recentSamples.count >= 5,
                let minSample = recentSamples.min(),
                let maxSample = recentSamples.max(),
                maxSample - minSample <= 1.0
            else { return }

            let stable = Int((recentSamples.reduce(0, +) / Double(recentSamples.count)).rounded())
            if lowestMidi == nil || stable < lowestMidi! {
                lowestMidi = stable
            }
            if highestMidi == nil || stable > highestMidi! {
                highestMidi = stable
            }
        }

        pitchDetector.requestPermission { granted in
            guard granted else {
                micDenied = true
                return
            }
            do {
                try pitchDetector.start()
            } catch {
                print("Failed to start range test: \(error)")
            }
        }
    }

    private func reset() {
        lowestMidi = nil
        highestMidi = nil
        recentSamples.removeAll()
    }

    private func save() {
        guard let voice = suggestedVoice else { return }
        settings.voiceType = voice
        presentationMode.wrappedValue.dismiss()
    }
}
