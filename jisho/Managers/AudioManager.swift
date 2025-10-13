//
//  AudioManager.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 28/9/25.
//

import AVFoundation
import Foundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()

    private var notePlayer: AVAudioPlayer?
    private var metronomePlayer: AVAudioPlayer?
    private var audioEngine: AVAudioEngine?
    private var playerNode: AVAudioPlayerNode?

    private init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Note Playback
    func playNote(_ note: MusicNote) {
        // Generate a simple sine wave for the note
        let frequency = frequencyForNote(note)
        generateTone(frequency: frequency, duration: 0.5, isMetronome: false)
    }

    // MARK: - Metronome Playback
    func playMetronomeBeat(isAccent: Bool = false) {
        let frequency: Double = isAccent ? 880.0 : 440.0 // A5 for accent, A4 for regular
        generateTone(frequency: frequency, duration: 0.1, isMetronome: true)
    }

    // MARK: - Response Sounds
    func playCorrectSound() {
        generateTone(frequency: 523.25, duration: 0.2, isMetronome: false) // C5
    }

    func playIncorrectSound() {
        generateTone(frequency: 196.00, duration: 0.3, isMetronome: false) // G3
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

    private func generateTone(frequency: Double, duration: Double, isMetronome: Bool) {
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

        // Play the buffer
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

            // Store references to prevent deallocation
            if isMetronome {
                self.audioEngine = engine
                self.playerNode = player
            }
        } catch {
            print("Failed to play tone: \(error)")
        }
    }

    func stopAll() {
        notePlayer?.stop()
        metronomePlayer?.stop()
        audioEngine?.stop()
    }
}
