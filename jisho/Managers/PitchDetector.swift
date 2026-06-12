//
//  PitchDetector.swift
//  jisho
//

import AVFoundation
import Foundation

/// Detects the pitch the user is singing via the microphone, and can play
/// short guide tones through the same audio engine.
final class PitchDetector: ObservableObject {
    /// Detected pitch as a fractional MIDI note number, nil when silent/unvoiced
    @Published private(set) var midiNote: Double?
    @Published private(set) var frequency: Double?

    /// Called on the main thread for every analyzed buffer (nil = silence)
    var onPitch: ((Double?) -> Void)?

    private let engine = AVAudioEngine()
    private let guidePlayer = AVAudioPlayerNode()
    private let samplePlayer = AVAudioPlayerNode()
    private let analysisQueue = DispatchQueue(label: "com.jisho.pitch.analysis", qos: .userInitiated)
    private var guideFormat: AVAudioFormat?
    private var sampleFormat: AVAudioFormat?
    private var sampleCache: [Int: AVAudioPCMBuffer] = [:]
    private var nodesAttached = false
    private(set) var isRunning = false

    // MARK: - Permission
    func requestPermission(completion: @escaping (Bool) -> Void) {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            DispatchQueue.main.async { completion(granted) }
        }
    }

    static var permissionDenied: Bool {
        AVAudioSession.sharedInstance().recordPermission == .denied
    }

    // MARK: - Lifecycle
    func start() throws {
        guard !isRunning else { return }

        let session = AVAudioSession.sharedInstance()
        try session.setCategory(
            .playAndRecord,
            mode: .default,
            options: [.defaultToSpeaker, .allowBluetoothA2DP, .mixWithOthers]
        )
        try session.setActive(true)

        let input = engine.inputNode
        let inputFormat = input.outputFormat(forBus: 0)
        let sampleRate = inputFormat.sampleRate
        guard sampleRate > 0 else { return }

        if !nodesAttached {
            let mixerRate = engine.mainMixerNode.outputFormat(forBus: 0).sampleRate
            let format = AVAudioFormat(
                commonFormat: .pcmFormatFloat32,
                sampleRate: mixerRate > 0 ? mixerRate : sampleRate,
                channels: 1,
                interleaved: false
            )
            engine.attach(guidePlayer)
            engine.connect(guidePlayer, to: engine.mainMixerNode, format: format)
            engine.attach(samplePlayer)
            guideFormat = format
            nodesAttached = true
        }

        input.installTap(onBus: 0, bufferSize: 4096, format: inputFormat) { [weak self] buffer, _ in
            self?.analysisQueue.async {
                self?.analyze(buffer: buffer, sampleRate: sampleRate)
            }
        }

        engine.prepare()
        try engine.start()
        guidePlayer.play()
        isRunning = true
    }

    func stop() {
        guard isRunning else { return }
        guidePlayer.stop()
        samplePlayer.stop()
        sampleCache.removeAll()
        engine.inputNode.removeTap(onBus: 0)
        engine.stop()
        isRunning = false

        // Restore the playback-only session the rest of the app uses
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(
            .playback,
            mode: .default,
            options: [.mixWithOthers, .allowBluetooth, .allowBluetoothA2DP]
        )

        DispatchQueue.main.async {
            self.midiNote = nil
            self.frequency = nil
        }
    }

    deinit {
        if isRunning {
            engine.inputNode.removeTap(onBus: 0)
            engine.stop()
        }
    }

    // MARK: - Guide Tone
    func playGuideTone(midi: Double, duration: Double, volume: Float = 0.45) {
        guard isRunning else { return }

        // Prefer the bundled piano samples; fall back to the synthesized tone
        if playSampleTone(midi: Int(midi.rounded()), duration: duration, volume: min(1, volume * 1.6)) {
            return
        }
        guard let format = guideFormat else { return }

        let sampleRate = format.sampleRate
        let frequency = midiFrequency(midi)
        let samples = Int(sampleRate * duration)
        guard
            let buffer = AVAudioPCMBuffer(
                pcmFormat: format,
                frameCapacity: AVAudioFrameCount(samples)
            ),
            let channel = buffer.floatChannelData?[0]
        else { return }

        buffer.frameLength = buffer.frameCapacity

        let harmonics: [(multiplier: Double, amplitude: Double)] = [
            (1.0, 0.55), (2.0, 0.2), (3.0, 0.1), (4.0, 0.05),
        ]
        let attack = 0.015
        let release = min(0.08, duration * 0.3)

        for i in 0..<samples {
            let time = Double(i) / sampleRate
            var envelope = 1.0
            if time < attack {
                envelope = time / attack
            } else if time > duration - release {
                envelope = max(0, (duration - time) / release)
            }

            var sample = 0.0
            for harmonic in harmonics {
                let harmonicFreq = frequency * harmonic.multiplier
                if harmonicFreq < sampleRate / 2 {
                    sample += sin(2.0 * .pi * harmonicFreq * time) * harmonic.amplitude
                }
            }
            channel[i] = Float(sample * envelope) * volume
        }

        guidePlayer.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        if !guidePlayer.isPlaying {
            guidePlayer.play()
        }
    }

    /// Plays a trimmed slice of a bundled piano sample. Returns false when the
    /// note has no sample so the caller can synthesize instead.
    private func playSampleTone(midi: Int, duration: Double, volume: Float) -> Bool {
        guard let buffer = pianoBuffer(forMidi: midi) else { return false }

        let sampleRate = buffer.format.sampleRate
        let frames = min(AVAudioFrameCount(duration * sampleRate), buffer.frameLength)
        guard frames > 0,
            let slice = AVAudioPCMBuffer(pcmFormat: buffer.format, frameCapacity: frames)
        else { return false }
        slice.frameLength = frames

        // Copy the attack portion and fade the tail so it ends before listening starts
        let fadeFrames = max(1, min(AVAudioFrameCount(0.06 * sampleRate), frames))
        let fadeStart = Int(frames - fadeFrames)
        for channel in 0..<Int(buffer.format.channelCount) {
            guard let source = buffer.floatChannelData?[channel],
                let destination = slice.floatChannelData?[channel]
            else { continue }
            for i in 0..<Int(frames) {
                destination[i] = source[i]
            }
            for i in 0..<Int(fadeFrames) {
                destination[fadeStart + i] *= Float(1.0 - Double(i) / Double(fadeFrames))
            }
        }

        ensureSamplePlayerReady(format: buffer.format)
        samplePlayer.volume = volume
        samplePlayer.scheduleBuffer(slice, at: nil, options: .interrupts, completionHandler: nil)
        return true
    }

    /// Loads a sample and connects/starts the sample player ahead of time so the
    /// first audible guide tone isn't dropped while the engine wires up the node.
    func preloadGuideTone(midi: Double) {
        guard isRunning else { return }
        guard let buffer = pianoBuffer(forMidi: Int(midi.rounded())) else { return }
        ensureSamplePlayerReady(format: buffer.format)
    }

    private func ensureSamplePlayerReady(format: AVAudioFormat) {
        if sampleFormat == nil {
            engine.connect(samplePlayer, to: engine.mainMixerNode, format: format)
            sampleFormat = format
        }
        if !samplePlayer.isPlaying {
            samplePlayer.play()
        }
    }

    private func pianoBuffer(forMidi midi: Int) -> AVAudioPCMBuffer? {
        if let cached = sampleCache[midi] { return cached }
        guard let url = AudioManager.pianoSampleURL(midi: midi) else { return nil }

        do {
            let file = try AVAudioFile(forReading: url)
            guard
                let buffer = AVAudioPCMBuffer(
                    pcmFormat: file.processingFormat,
                    frameCapacity: AVAudioFrameCount(file.length)
                )
            else { return nil }
            try file.read(into: buffer)
            sampleCache[midi] = buffer
            return buffer
        } catch {
            print("Failed to load piano sample for midi \(midi): \(error)")
            return nil
        }
    }

    // MARK: - Pitch Analysis (normalized autocorrelation)
    private func analyze(buffer: AVAudioPCMBuffer, sampleRate: Double) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frames = Int(buffer.frameLength)

        let window = 2048
        let maxLag = min(frames - window, Int(sampleRate / 60.0))  // down to ~60 Hz
        let minLag = max(2, Int(sampleRate / 1100.0))  // up to ~1100 Hz
        guard maxLag > minLag, frames >= window + minLag else { return }

        // Gate on signal level
        var rms: Float = 0
        for i in 0..<window {
            rms += channelData[i] * channelData[i]
        }
        rms = sqrt(rms / Float(window))
        guard rms > 0.012 else {
            publish(frequency: nil)
            return
        }

        var energy0: Double = 0
        for i in 0..<window {
            energy0 += Double(channelData[i]) * Double(channelData[i])
        }

        var bestLag = 0
        var bestCorrelation = 0.0
        var correlations = [Double](repeating: 0, count: maxLag + 1)

        for lag in minLag...maxLag {
            var sum: Double = 0
            var energyLag: Double = 0
            for i in 0..<window {
                let lagged = Double(channelData[i + lag])
                sum += Double(channelData[i]) * lagged
                energyLag += lagged * lagged
            }
            let denominator = sqrt(energy0 * energyLag)
            let r = denominator > 0 ? sum / denominator : 0
            correlations[lag] = r
            if r > bestCorrelation {
                bestCorrelation = r
                bestLag = lag
            }
        }

        guard bestCorrelation > 0.85, bestLag > 0 else {
            publish(frequency: nil)
            return
        }

        // Prefer the smallest lag close to the maximum to avoid octave-low errors
        var chosenLag = bestLag
        for lag in minLag..<bestLag where correlations[lag] > bestCorrelation * 0.93 {
            // Only accept if it's a local peak
            if lag > minLag, lag < maxLag,
                correlations[lag] >= correlations[lag - 1],
                correlations[lag] >= correlations[lag + 1]
            {
                chosenLag = lag
                break
            }
        }

        // Parabolic interpolation around the chosen lag
        var refinedLag = Double(chosenLag)
        if chosenLag > minLag, chosenLag < maxLag {
            let alpha = correlations[chosenLag - 1]
            let beta = correlations[chosenLag]
            let gamma = correlations[chosenLag + 1]
            let denominator = alpha - 2 * beta + gamma
            if abs(denominator) > 1e-9 {
                refinedLag += 0.5 * (alpha - gamma) / denominator
            }
        }

        publish(frequency: sampleRate / refinedLag)
    }

    private func publish(frequency: Double?) {
        let midi = frequency.map { 69.0 + 12.0 * log2($0 / 440.0) }
        DispatchQueue.main.async {
            self.frequency = frequency
            self.midiNote = midi
            self.onPitch?(midi)
        }
    }
}
