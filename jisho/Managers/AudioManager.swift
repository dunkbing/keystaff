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

extension Notification.Name {
    static let metronomeRemotePlay = Notification.Name("com.jisho.metronome.remote.play")
    static let metronomeRemotePause = Notification.Name("com.jisho.metronome.remote.pause")
    static let metronomeRemoteStop = Notification.Name("com.jisho.metronome.remote.stop")
}
