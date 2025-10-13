//
//  GameManager.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 28/9/25.
//

import Foundation
import SwiftUI

class GameManager: ObservableObject {
    @Published var currentNote: MusicNote?
    @Published var currentClef: Clef = .treble
    @Published var score: Int = 0
    @Published var totalAttempts: Int = 0
    @Published var correctAttempts: Int = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var isGameActive: Bool = false
    @Published var showFeedback: Bool = false
    @Published var lastAnswerCorrect: Bool = false

    private var timer: Timer?
    private let settings: GameSettings
    private let audioManager: AudioManager

    var accuracy: String {
        guard totalAttempts > 0 else { return "-" }
        let percentage = Double(correctAttempts) / Double(totalAttempts) * 100
        return String(format: "%.0f%%", percentage)
    }

    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    init(settings: GameSettings = .shared, audioManager: AudioManager = .shared) {
        self.settings = settings
        self.audioManager = audioManager
    }

    // MARK: - Game Control
    func startGame() {
        score = 0
        totalAttempts = 0
        correctAttempts = 0
        isGameActive = true

        if let duration = settings.duration.seconds {
            timeRemaining = duration
            startTimer()
        } else {
            timeRemaining = 0
        }

        generateNewNote()
    }

    func stopGame() {
        isGameActive = false
        timer?.invalidate()
        timer = nil
        currentNote = nil
    }

    func resetGame() {
        stopGame()
        startGame()
    }

    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            if self.timeRemaining > 0 {
                self.timeRemaining -= 1
            } else {
                self.stopGame()
            }
        }
    }

    // MARK: - Note Generation
    func generateNewNote() {
        guard isGameActive else { return }

        // Select random clef from enabled clefs
        let enabledClefs = Array(settings.selectedClefs)
        guard !enabledClefs.isEmpty else { return }

        currentClef = enabledClefs.randomElement()!
        let range = settings.range(for: currentClef)

        // Generate random note within range
        let notes = generateNotesInRange(range)
        currentNote = notes.randomElement()

        // Play note if sound is enabled
        if settings.soundEnabled, let note = currentNote {
            audioManager.playNote(note)
        }
    }

    private func generateNotesInRange(_ range: NoteRange) -> [MusicNote] {
        var notes: [MusicNote] = []

        // Calculate octave range
        let lowOctave = range.low.octave
        let highOctave = range.high.octave

        for octave in lowOctave...highOctave {
            for noteName in NoteName.allCases {
                let note = MusicNote(name: noteName, octave: octave, accidental: .natural)

                // Check if note is within range
                if isNoteInRange(note, range: range) {
                    notes.append(note)

                    // Add accidentals if enabled
                    if settings.includeAccidentals {
                        let sharpNote = MusicNote(
                            name: noteName, octave: octave, accidental: .sharp)
                        let flatNote = MusicNote(name: noteName, octave: octave, accidental: .flat)

                        if isNoteInRange(sharpNote, range: range) {
                            notes.append(sharpNote)
                        }
                        if isNoteInRange(flatNote, range: range) {
                            notes.append(flatNote)
                        }
                    }
                }
            }
        }

        return notes
    }

    private func isNoteInRange(_ note: MusicNote, range: NoteRange) -> Bool {
        let noteValue = note.name.semitonesFromC + (note.octave * 12)
        let lowValue = range.low.name.semitonesFromC + (range.low.octave * 12)
        let highValue = range.high.name.semitonesFromC + (range.high.octave * 12)

        var adjustedNoteValue = noteValue
        switch note.accidental {
        case .sharp: adjustedNoteValue += 1
        case .flat: adjustedNoteValue -= 1
        case .natural: break
        }

        return adjustedNoteValue >= lowValue && adjustedNoteValue <= highValue
    }

    // MARK: - Answer Checking
    func checkAnswer(_ answer: NoteName, accidental: Accidental = .natural) {
        guard let currentNote = currentNote else { return }

        // Check for exact match first
        var isCorrect = answer == currentNote.name && accidental == currentNote.accidental

        // If not exact match, check for enharmonic equivalent
        // (e.g., C# = Db, D# = Eb, F# = Gb, G# = Ab, A# = Bb)
        if !isCorrect {
            isCorrect = areEnharmonicEquivalents(
                note1: (answer, accidental),
                note2: (currentNote.name, currentNote.accidental)
            )
        }

        totalAttempts += 1

        if isCorrect {
            correctAttempts += 1
            score += 1
            lastAnswerCorrect = true

            if settings.responseSoundEnabled {
                audioManager.playCorrectSound()
            }
        } else {
            lastAnswerCorrect = false

            if settings.responseSoundEnabled {
                audioManager.playIncorrectSound()
            }
        }

        // Show feedback briefly
        showFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showFeedback = false
            self.generateNewNote()
        }
    }

    private func areEnharmonicEquivalents(
        note1: (NoteName, Accidental),
        note2: (NoteName, Accidental)
    ) -> Bool {
        // Calculate semitone values
        let semitone1 = calculateSemitone(note: note1.0, accidental: note1.1)
        let semitone2 = calculateSemitone(note: note2.0, accidental: note2.1)

        // Check if they're the same semitone (normalized for octave equivalence)
        return normalizedSemitone(semitone1) == normalizedSemitone(semitone2)
    }

    private func calculateSemitone(note: NoteName, accidental: Accidental) -> Int {
        var semitone = note.semitonesFromC

        switch accidental {
        case .sharp:
            semitone += 1
        case .flat:
            semitone -= 1
        case .natural:
            break
        }

        return semitone
    }

    private func normalizedSemitone(_ value: Int) -> Int {
        let remainder = value % 12
        return remainder >= 0 ? remainder : remainder + 12
    }
}
