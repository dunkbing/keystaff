//
//  AudioManager.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 28/9/25.
//

import AVFoundation
import Foundation
import MediaPlayer

class AudioManager: ObservableObject {
    static let shared = AudioManager()

    private var notePlayer: AVAudioPlayer?
    private var metronomePlayer: AVAudioPlayer?
    private var remoteCommandsConfigured = false
    private let metronomeEngine = MetronomeAudioEngine()

    private init() {
        setupAudioSession()
        setupMetronomePlayer()
        configureRemoteCommandCenter()
    }

    private func setupMetronomePlayer() {
        guard let url = Bundle.main.url(forResource: "metronome", withExtension: "mp3") else {
            print("❌ Failed to find metronome.mp3")
            return
        }

        do {
            metronomePlayer = try AVAudioPlayer(contentsOf: url)
            metronomePlayer?.prepareToPlay()
        } catch {
            print("❌ Failed to load metronome audio: \(error)")
        }
    }

    private func setupAudioSession() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker]
            )
            try audioSession.setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Note Playback
    func playNote(_ note: MusicNote) {
        // Generate a simple sine wave for the note
        let frequency = frequencyForNote(note)
        generateTone(frequency: frequency, duration: 0.5)
    }

    // MARK: - Metronome Playback
    func playMetronomeBeat(isAccent: Bool = false) {
        guard let player = metronomePlayer else {
            print("❌ Metronome player not initialized")
            return
        }

        player.volume = isAccent ? 1.0 : 0.55
        // Reset to beginning and play
        player.currentTime = 0
        player.play()
    }

    // MARK: - Response Sounds
    func playCorrectSound() {
        generateTone(frequency: 523.25, duration: 0.2) // C5
    }

    func playIncorrectSound() {
        generateTone(frequency: 196.00, duration: 0.3) // G3
    }

    // MARK: - Helper Methods
    private func frequencyForNote(_ note: MusicNote) -> Double {
        // A4 = 440 Hz
        let a4Frequency = 440.0
        let a4Note = MusicNote(name: .a, octave: 4, accidental: .natural)

        // Calculate semitone distance from A4
        let semitones = semitonesFrom(a4Note, to: note)

        // Use equal temperament: f = f0 * 2^(n/12)
        return a4Frequency * pow(2.0, Double(semitones) / 12.0)
    }

    private func semitonesFrom(_ from: MusicNote, to: MusicNote) -> Int {
        let fromValue = from.name.semitonesFromC + (from.octave * 12)
        let toValue = to.name.semitonesFromC + (to.octave * 12)

        var result = toValue - fromValue

        // Add accidental adjustments
        switch to.accidental {
        case .sharp: result += 1
        case .flat: result -= 1
        case .natural: break
        }

        switch from.accidental {
        case .sharp: result -= 1
        case .flat: result += 1
        case .natural: break
        }

        return result
    }

    private func generateTone(frequency: Double, duration: Double) {
        let sampleRate = 44100.0
        let amplitude = 0.3
        let samples = Int(sampleRate * duration)

        var sineWave = [Float]()
        for i in 0..<samples {
            let time = Double(i) / sampleRate
            let value = sin(2.0 * .pi * frequency * time)

            // Apply envelope for smoother sound
            let envelope: Double
            let attackTime = 0.01
            let releaseTime = 0.05

            if time < attackTime {
                envelope = time / attackTime
            } else if time > duration - releaseTime {
                envelope = (duration - time) / releaseTime
            } else {
                envelope = 1.0
            }

            sineWave.append(Float(value * amplitude * envelope))
        }

        // Create audio buffer
        let audioFormat = AVAudioFormat(
            commonFormat: .pcmFormatFloat32,
            sampleRate: sampleRate,
            channels: 1,
            interleaved: false
        )!

        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: audioFormat,
            frameCapacity: AVAudioFrameCount(samples)
        ) else { return }

        buffer.frameLength = buffer.frameCapacity

        if let channelData = buffer.floatChannelData?[0] {
            for i in 0..<samples {
                channelData[i] = sineWave[i]
            }
        }

        // Create a temporary engine for note playback
        do {
            let engine = AVAudioEngine()
            let player = AVAudioPlayerNode()

            engine.attach(player)
            engine.connect(player, to: engine.mainMixerNode, format: audioFormat)

            try engine.start()
            player.scheduleBuffer(buffer, at: nil, options: []) {
                DispatchQueue.main.async {
                    engine.stop()
                }
            }
            player.play()
        } catch {
            print("Failed to play tone: \(error)")
        }
    }

    func stopAll() {
        notePlayer?.stop()
        metronomePlayer?.stop()
        stopMetronome()
        clearMetronomeNowPlaying()
    }

    func stopMetronome() {
        metronomePlayer?.stop()
        metronomeEngine.stop()
    }

    func startMetronomeLoop(tempo: Double, timeSignature: TimeSignature) {
        metronomeEngine.start(tempo: tempo, timeSignature: timeSignature)
    }

    func updateMetronomeLoop(tempo: Double, timeSignature: TimeSignature, shouldPlay: Bool) {
        metronomeEngine.update(tempo: tempo, timeSignature: timeSignature, shouldPlay: shouldPlay)
    }

    // MARK: - Remote Command Center & Now Playing
    private func configureRemoteCommandCenter() {
        guard !remoteCommandsConfigured else { return }

        let commandCenter = MPRemoteCommandCenter.shared()

        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { _ in
            NotificationCenter.default.post(name: .metronomeRemotePlay, object: nil)
            return .success
        }

        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { _ in
            NotificationCenter.default.post(name: .metronomeRemotePause, object: nil)
            return .success
        }

        commandCenter.stopCommand.isEnabled = true
        commandCenter.stopCommand.addTarget { _ in
            NotificationCenter.default.post(name: .metronomeRemoteStop, object: nil)
            return .success
        }

        remoteCommandsConfigured = true
    }

    func updateMetronomeNowPlaying(isPlaying: Bool, tempo: Double, timeSignature: TimeSignature, currentBeat: Int) {
        var info = MPNowPlayingInfoCenter.default().nowPlayingInfo ?? [:]

        let displayTempo = Int(round(tempo))
        info[MPMediaItemPropertyTitle] = NSLocalizedString("Metronome", comment: "Now Playing title")
        info[MPMediaItemPropertyArtist] = "KeyStaff"
        info[MPMediaItemPropertyAlbumTitle] = "\(displayTempo) BPM • \(timeSignature.rawValue)"
        info[MPNowPlayingInfoPropertyIsLiveStream] = true
        info[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0
        info[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = elapsedTimeForBeat(currentBeat, tempo: tempo)

        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
    }

    func clearMetronomeNowPlaying() {
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
    }

    private func elapsedTimeForBeat(_ beat: Int, tempo: Double) -> Double {
        guard tempo > 0 else { return 0 }
        return Double(beat) * (60.0 / tempo)
    }
}

// MARK: - Metronome Audio Engine
private final class MetronomeAudioEngine {
    private struct Configuration: Equatable {
        let tempo: Double
        let timeSignature: TimeSignature
    }

    private let engine = AVAudioEngine()
    private let player = AVAudioPlayerNode()
    private let queue = DispatchQueue(label: "com.jisho.metronome.engine", qos: .userInitiated)

    private var sourceBuffer: AVAudioPCMBuffer?
    private var cachedConfiguration: Configuration?
    private var cachedMeasureBuffer: AVAudioPCMBuffer?
    private var isPrepared = false

    init() {
        prepareSourceBuffer()
    }

    func start(tempo: Double, timeSignature: TimeSignature) {
        queue.async { [weak self] in
            self?.scheduleIfNeeded(tempo: tempo, timeSignature: timeSignature, playImmediately: true)
        }
    }

    func update(tempo: Double, timeSignature: TimeSignature, shouldPlay: Bool) {
        queue.async { [weak self] in
            guard let self else { return }
            if shouldPlay {
                self.scheduleIfNeeded(tempo: tempo, timeSignature: timeSignature, playImmediately: true)
            } else {
                _ = self.ensureMeasureBuffer(tempo: tempo, timeSignature: timeSignature)
            }
        }
    }

    func stop() {
        queue.async { [weak self] in
            guard let self else { return }
            self.player.stop()
            self.player.reset()
        }
    }

    private func prepareSourceBuffer() {
        guard let url = Bundle.main.url(forResource: "metronome", withExtension: "mp3") else {
            print("❌ Failed to locate metronome source for engine")
            return
        }

        do {
            let file = try AVAudioFile(forReading: url)
            guard let format = AVAudioFormat(
                standardFormatWithSampleRate: file.processingFormat.sampleRate,
                channels: file.processingFormat.channelCount
            ) else {
                print("❌ Unable to create metronome format")
                return
            }

            guard let buffer = AVAudioPCMBuffer(
                pcmFormat: format,
                frameCapacity: AVAudioFrameCount(file.length)
            ) else {
                print("❌ Unable to allocate metronome buffer")
                return
            }

            try file.read(into: buffer)
            sourceBuffer = buffer
            attachEngineIfNeeded(with: format)
        } catch {
            print("❌ Failed to prepare metronome engine: \(error)")
        }
    }

    private func attachEngineIfNeeded(with format: AVAudioFormat) {
        guard !isPrepared else { return }
        engine.attach(player)
        engine.connect(player, to: engine.mainMixerNode, format: format)
        engine.prepare()
        isPrepared = true
    }

    private func scheduleIfNeeded(tempo: Double, timeSignature: TimeSignature, playImmediately: Bool) {
        guard let buffer = ensureMeasureBuffer(tempo: tempo, timeSignature: timeSignature) else { return }

        do {
            if !engine.isRunning {
                try engine.start()
            }
        } catch {
            print("❌ Unable to start metronome engine: \(error)")
            return
        }

        player.stop()
        player.scheduleBuffer(buffer, at: nil, options: [.loops], completionHandler: nil)

        if playImmediately {
            player.play()
        }
    }

    private func ensureMeasureBuffer(tempo: Double, timeSignature: TimeSignature) -> AVAudioPCMBuffer? {
        guard let sourceBuffer else { return nil }

        let configuration = Configuration(tempo: tempo, timeSignature: timeSignature)
        if cachedConfiguration != configuration {
            cachedMeasureBuffer = buildMeasureBuffer(
                from: sourceBuffer,
                tempo: tempo,
                timeSignature: timeSignature
            )
            cachedConfiguration = configuration
        }

        return cachedMeasureBuffer
    }

    private func buildMeasureBuffer(
        from source: AVAudioPCMBuffer,
        tempo: Double,
        timeSignature: TimeSignature
    ) -> AVAudioPCMBuffer? {
        let sampleRate = source.format.sampleRate
        let beatsPerMeasure = max(timeSignature.beatsPerMeasure, 1)
        let accentBeats = timeSignature.accentBeats

        let sourceFrames = Int(source.frameLength)
        let beatSamples = max(sourceFrames, Int(round((60.0 / tempo) * sampleRate)))
        let measureSamples = beatSamples * beatsPerMeasure

        guard let buffer = AVAudioPCMBuffer(
            pcmFormat: source.format,
            frameCapacity: AVAudioFrameCount(measureSamples)
        ) else {
            return nil
        }

        buffer.frameLength = buffer.frameCapacity
        let channelCount = Int(source.format.channelCount)

        for channel in 0..<channelCount {
            guard let sourceChannel = source.floatChannelData?[channel],
                  let destinationChannel = buffer.floatChannelData?[channel] else {
                continue
            }

            for sample in 0..<measureSamples {
                destinationChannel[sample] = 0
            }

            for beat in 0..<beatsPerMeasure {
                let isAccent = accentBeats.contains(beat)
                let gain: Float = isAccent ? 1.0 : 0.55
                let destinationOffset = beat * beatSamples

                for frame in 0..<sourceFrames {
                    let destinationIndex = destinationOffset + frame
                    if destinationIndex >= measureSamples {
                        break
                    }
                    destinationChannel[destinationIndex] += sourceChannel[frame] * gain
                }
            }
        }

        return buffer
    }
}

extension Notification.Name {
    static let metronomeRemotePlay = Notification.Name("com.jisho.metronome.remote.play")
    static let metronomeRemotePause = Notification.Name("com.jisho.metronome.remote.pause")
    static let metronomeRemoteStop = Notification.Name("com.jisho.metronome.remote.stop")
}
