//
//  GameManager.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 28/9/25.
//

import Foundation
import SwiftUI
import UIKit

@MainActor
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
    @Published var lastSessionResult: SessionResult?
    @Published var currentMode: InputMode = .musicNotes
    @Published var currentChordNotes: [MusicNote] = []
    @Published var chordAnswerOptions: [String] = []

    private var timer: Timer?
    private let settings: GameSettings
    private let audioManager: AudioManager
    private let resultStore: PracticeResultStore
    private var sessionStartDate: Date?
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    private var currentChordAnswer: String?
    private let chordDiatonicSteps = [0, 2, 4]

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

    init(
        settings: GameSettings = .shared,
        audioManager: AudioManager = .shared,
        resultStore: PracticeResultStore = .shared
    ) {
        self.settings = settings
        self.audioManager = audioManager
        self.resultStore = resultStore
        self.lastSessionResult = resultStore.recentResults().last
    }

    // MARK: - Game Control
    func startGame(mode: InputMode? = nil) {
        if let mode = mode {
            currentMode = mode
        }

        score = 0
        totalAttempts = 0
        correctAttempts = 0
        isGameActive = true
        lastSessionResult = nil
        sessionStartDate = Date()
        feedbackGenerator.prepare()

        if let duration = settings.duration.seconds {
            timeRemaining = duration
            startTimer()
        } else {
            timeRemaining = 0
        }

        prepareNextQuestion()
    }

    func stopGame(shouldRecordResult: Bool = true) {
        guard isGameActive else { return }

        isGameActive = false
        timer?.invalidate()
        timer = nil
        timeRemaining = 0

        if shouldRecordResult,
            totalAttempts > 0,
            let startDate = sessionStartDate
        {
            let duration = Date().timeIntervalSince(startDate)
            let result = SessionResult(
                duration: duration,
                score: score,
                correctAttempts: correctAttempts,
                totalAttempts: totalAttempts
            )
            lastSessionResult = result
            resultStore.add(result)
        }

        sessionStartDate = nil
        currentNote = nil
        currentChordNotes = []
        chordAnswerOptions = []
        currentChordAnswer = nil
    }

    func resetGame() {
        let previousMode = currentMode
        stopGame(shouldRecordResult: totalAttempts > 0)
        startGame(mode: previousMode)
    }

    func clearHistory() {
        resultStore.clearAll()
        lastSessionResult = nil
    }

    func setMode(_ mode: InputMode) {
        guard currentMode != mode else { return }
        currentMode = mode

        if isGameActive {
            prepareNextQuestion()
        } else {
            switch mode {
            case .chordIdentification:
                currentNote = nil
            case .musicNotes, .pianoKeys:
                currentChordNotes = []
                chordAnswerOptions = []
                currentChordAnswer = nil
            }
        }
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
    private func prepareNextQuestion() {
        switch currentMode {
        case .musicNotes, .pianoKeys:
            generateNewNote()
        case .chordIdentification:
            generateNewChord()
        }
    }

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
        currentChordNotes = []
        chordAnswerOptions = []
        currentChordAnswer = nil

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

    private func generateNewChord() {
        guard isGameActive else { return }

        let enabledClefs = Array(settings.selectedClefs)
        guard !enabledClefs.isEmpty else { return }

        let maxAttempts = 16
        var attempt = 0
        var generatedChord: (clef: Clef, notes: [MusicNote], label: String)?

        while attempt < maxAttempts, generatedChord == nil {
            let clef = enabledClefs.randomElement()!
            let quality = ChordQuality.allCases.randomElement()!
            let rootName = NoteName.allCases.randomElement()!
            let rootOctave = chordRootOctave(for: clef)
            let rootNote = MusicNote(name: rootName, octave: rootOctave, accidental: .natural)

            let chordNotes = buildChordNotes(from: rootNote, quality: quality)
            let range = settings.range(for: clef)

            if chordNotes.allSatisfy({ isNoteInRange($0, range: range) }) {
                let sortedNotes = chordNotes.sorted {
                    $0.position(for: clef) < $1.position(for: clef)
                }
                let answerLabel = "\(rootNote.displayName) \(quality.displayName)"
                generatedChord = (clef, sortedNotes, answerLabel)
            }

            attempt += 1
        }

        guard let result = generatedChord else {
            currentNote = nil
            currentChordNotes = []
            chordAnswerOptions = []
            currentChordAnswer = nil
            return
        }

        currentClef = result.clef
        currentNote = nil
        currentChordNotes = result.notes
        currentChordAnswer = result.label
        chordAnswerOptions = generateChordOptions(correctAnswer: result.label)
    }

    private func buildChordNotes(from root: MusicNote, quality: ChordQuality) -> [MusicNote] {
        zip(quality.intervals, chordDiatonicSteps).map { interval, steps in
            makeChordNote(
                root: root,
                semitoneOffset: interval,
                diatonicSteps: steps
            )
        }
    }

    private func makeChordNote(
        root: MusicNote,
        semitoneOffset: Int,
        diatonicSteps: Int
    ) -> MusicNote {
        let targetSemitone = semitoneValue(for: root) + semitoneOffset
        let noteName = advanceNoteName(root.name, steps: diatonicSteps)
        let octave = octaveForChord(root: root, steps: diatonicSteps)
        let baseNote = MusicNote(name: noteName, octave: octave, accidental: .natural)
        let baseSemitone = semitoneValue(for: baseNote)
        let difference = targetSemitone - baseSemitone

        let accidental: Accidental
        switch difference {
        case 0:
            accidental = .natural
        case 1:
            accidental = .sharp
        case -1:
            accidental = .flat
        default:
            accidental = difference > 0 ? .sharp : .flat
        }

        return MusicNote(name: noteName, octave: octave, accidental: accidental)
    }

    private func chordRootOctave(for clef: Clef) -> Int {
        switch clef {
        case .treble:
            return 4
        case .alto:
            return 3
        case .bass:
            return 3
        }
    }

    private func semitoneValue(for note: MusicNote) -> Int {
        var value = note.name.semitonesFromC + (note.octave * 12)

        switch note.accidental {
        case .sharp:
            value += 1
        case .flat:
            value -= 1
        case .natural:
            break
        }

        return value
    }

    private func advanceNoteName(_ name: NoteName, steps: Int) -> NoteName {
        guard steps != 0 else { return name }

        let ordered = NoteName.allCases
        guard let startIndex = ordered.firstIndex(of: name) else { return name }

        let newIndex = (startIndex + steps) % ordered.count
        return ordered[newIndex >= 0 ? newIndex : newIndex + ordered.count]
    }

    private func octaveForChord(root: MusicNote, steps: Int) -> Int {
        guard steps > 0 else { return root.octave }

        let ordered = NoteName.allCases
        guard let startIndex = ordered.firstIndex(of: root.name) else { return root.octave }

        var octave = root.octave
        var currentIndex = startIndex

        for _ in 0..<steps {
            let nextIndex = (currentIndex + 1) % ordered.count
            if nextIndex == 0 {
                octave += 1
            }
            currentIndex = nextIndex
        }

        return octave
    }

    private func generateChordOptions(correctAnswer: String) -> [String] {
        var options: Set<String> = [correctAnswer]
        let qualities = ChordQuality.allCases
        let roots = NoteName.allCases
        let maxIterations = 24
        var iterations = 0

        while options.count < 4 && iterations < maxIterations {
            let root = roots.randomElement()!
            let quality = qualities.randomElement()!
            let option = "\(root.rawValue) \(quality.displayName)"
            options.insert(option)
            iterations += 1
        }

        if options.count < 4 {
            outer: for root in roots {
                for quality in qualities {
                    let option = "\(root.rawValue) \(quality.displayName)"
                    options.insert(option)
                    if options.count == 4 {
                        break outer
                    }
                }
            }
        }

        return Array(options).shuffled()
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

            if settings.hapticFeedbackEnabled {
                feedbackGenerator.notificationOccurred(.success)
                feedbackGenerator.prepare()
            }
        } else {
            lastAnswerCorrect = false

            if settings.hapticFeedbackEnabled {
                feedbackGenerator.notificationOccurred(.error)
                feedbackGenerator.prepare()
            }
        }

        // Show feedback briefly
        showFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showFeedback = false
            self.prepareNextQuestion()
        }
    }

    func checkChordAnswer(_ option: String) {
        guard currentMode == .chordIdentification else { return }
        guard let correctAnswer = currentChordAnswer else { return }

        totalAttempts += 1

        if option == correctAnswer {
            correctAttempts += 1
            score += 1
            lastAnswerCorrect = true

            if settings.hapticFeedbackEnabled {
                feedbackGenerator.notificationOccurred(.success)
                feedbackGenerator.prepare()
            }
        } else {
            lastAnswerCorrect = false

            if settings.hapticFeedbackEnabled {
                feedbackGenerator.notificationOccurred(.error)
                feedbackGenerator.prepare()
            }
        }

        showFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showFeedback = false
            self.prepareNextQuestion()
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
