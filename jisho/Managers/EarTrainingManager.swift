//
//  EarTrainingManager.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 27/11/25.
//

import Foundation
import SwiftUI
import UIKit

@MainActor
class EarTrainingManager: ObservableObject {
    // MARK: - Published Properties
    @Published var currentQuestion: EarTrainingQuestion?
    @Published var score: Int = 0
    @Published var totalAttempts: Int = 0
    @Published var correctAttempts: Int = 0
    @Published var timeRemaining: TimeInterval = 0
    @Published var isGameActive: Bool = false
    @Published var showFeedback: Bool = false
    @Published var lastAnswerCorrect: Bool = false
    @Published var lastSessionResult: EarTrainingResult?
    @Published var isPlayingAudio: Bool = false

    // MARK: - Private Properties
    private var timer: Timer?
    private let settings: EarTrainingSettings
    private let audioManager: AudioManager
    private let resultStore: EarTrainingResultStore
    private var sessionStartDate: Date?
    private let feedbackGenerator = UINotificationFeedbackGenerator()

    // MARK: - Computed Properties
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

    // MARK: - Initialization
    init(
        settings: EarTrainingSettings = .shared,
        audioManager: AudioManager = .shared,
        resultStore: EarTrainingResultStore = .shared
    ) {
        self.settings = settings
        self.audioManager = audioManager
        self.resultStore = resultStore
        self.lastSessionResult = resultStore.recentResults().last
    }

    // MARK: - Game Control
    func startGame() {
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

        generateNewQuestion()
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
            let result = EarTrainingResult(
                duration: duration,
                exerciseType: settings.exerciseType,
                difficulty: settings.difficulty,
                score: score,
                correctAttempts: correctAttempts,
                totalAttempts: totalAttempts
            )
            lastSessionResult = result
            resultStore.add(result)
        }

        sessionStartDate = nil
        currentQuestion = nil
    }

    func resetGame() {
        stopGame(shouldRecordResult: totalAttempts > 0)
        startGame()
    }

    func clearHistory() {
        resultStore.clearAll()
        lastSessionResult = nil
    }

    // MARK: - Timer
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

    // MARK: - Question Generation
    func generateNewQuestion() {
        guard isGameActive else { return }

        switch settings.exerciseType {
        case .singleNote:
            generateSingleNoteQuestion()
        case .interval:
            generateIntervalQuestion()
        case .melody:
            generateMelodyQuestion()
        }

        // Auto-play the question
        if let question = currentQuestion {
            playQuestion(question)
        }
    }

    private func generateSingleNoteQuestion() {
        let availableNotes = settings.availableNotes()
        guard let targetNote = availableNotes.randomElement() else { return }

        // Generate answer options (correct + 3 wrong)
        var options: Set<String> = [targetNote.displayName]
        let allNoteNames = NoteName.allCases

        while options.count < 4 {
            let randomName = allNoteNames.randomElement()!
            if settings.includeAccidentals {
                let accidentals: [Accidental] = [.natural, .sharp, .flat]
                let randomAccidental = accidentals.randomElement()!
                let note = MusicNote(name: randomName, octave: 4, accidental: randomAccidental)
                options.insert(note.displayName)
            } else {
                options.insert(randomName.rawValue)
            }
        }

        currentQuestion = EarTrainingQuestion(
            type: .singleNote,
            notes: [targetNote],
            correctAnswer: targetNote.displayName,
            answerOptions: Array(options).shuffled()
        )
    }

    private func generateIntervalQuestion() {
        let availableIntervals = settings.difficulty.intervals
        guard let targetInterval = availableIntervals.randomElement() else { return }

        let availableNotes = settings.availableNotes()
        guard let firstNote = availableNotes.randomElement() else { return }

        // Calculate second note based on interval
        let secondNote = noteAtInterval(from: firstNote, interval: targetInterval)

        // Generate answer options
        var options: Set<String> = [targetInterval.displayName]

        while options.count < 4 {
            if let randomInterval = availableIntervals.randomElement() {
                options.insert(randomInterval.displayName)
            }
        }

        currentQuestion = EarTrainingQuestion(
            type: .interval,
            notes: [firstNote, secondNote],
            correctAnswer: targetInterval.displayName,
            answerOptions: Array(options).shuffled()
        )
    }

    private func generateMelodyQuestion() {
        let melodyLength = settings.difficulty.melodyLength
        let availableNotes = settings.availableNotes()
        var melodyNotes: [MusicNote] = []

        // Generate a melody of specified length
        for _ in 0..<melodyLength {
            if let note = availableNotes.randomElement() {
                melodyNotes.append(note)
            }
        }

        let correctAnswer = melodyNotes.map { $0.displayName }.joined(separator: " - ")

        // Generate wrong options by shuffling or changing notes
        var options: Set<String> = [correctAnswer]

        while options.count < 4 {
            var wrongMelody = melodyNotes
            // Randomly change 1-2 notes
            let changCount = Int.random(in: 1...min(2, melodyLength))
            for _ in 0..<changCount {
                let indexToChange = Int.random(in: 0..<melodyLength)
                if let newNote = availableNotes.randomElement() {
                    wrongMelody[indexToChange] = newNote
                }
            }
            let wrongAnswer = wrongMelody.map { $0.displayName }.joined(separator: " - ")
            options.insert(wrongAnswer)
        }

        currentQuestion = EarTrainingQuestion(
            type: .melody,
            notes: melodyNotes,
            correctAnswer: correctAnswer,
            answerOptions: Array(options).shuffled()
        )
    }

    private func noteAtInterval(from note: MusicNote, interval: MusicalInterval) -> MusicNote {
        let baseSemitone = semitoneValue(for: note)
        let targetSemitone = baseSemitone + interval.rawValue

        // Convert back to note
        let octave = targetSemitone / 12
        let semitoneInOctave = targetSemitone % 12

        // Map semitone to note name (using natural notes where possible)
        let (noteName, accidental) = semitoneToNote(semitoneInOctave)

        return MusicNote(name: noteName, octave: octave, accidental: accidental)
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

    private func semitoneToNote(_ semitone: Int) -> (NoteName, Accidental) {
        // Map semitones to natural notes where possible
        switch semitone {
        case 0: return (.c, .natural)
        case 1: return (.c, .sharp)
        case 2: return (.d, .natural)
        case 3: return (.d, .sharp)
        case 4: return (.e, .natural)
        case 5: return (.f, .natural)
        case 6: return (.f, .sharp)
        case 7: return (.g, .natural)
        case 8: return (.g, .sharp)
        case 9: return (.a, .natural)
        case 10: return (.a, .sharp)
        case 11: return (.b, .natural)
        default: return (.c, .natural)
        }
    }

    // MARK: - Audio Playback
    func playQuestion(_ question: EarTrainingQuestion) {
        isPlayingAudio = true

        switch question.type {
        case .singleNote:
            if let note = question.notes.first {
                audioManager.playNote(note)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.isPlayingAudio = false
            }

        case .interval:
            playNotesSequentially(question.notes, delay: 0.6 / settings.playbackSpeed)

        case .melody:
            playNotesSequentially(question.notes, delay: 0.5 / settings.playbackSpeed)
        }
    }

    func replayCurrentQuestion() {
        guard let question = currentQuestion else { return }
        playQuestion(question)
    }

    private func playNotesSequentially(_ notes: [MusicNote], delay: TimeInterval) {
        isPlayingAudio = true

        for (index, note) in notes.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay * Double(index)) {
                self.audioManager.playNote(note)
            }
        }

        // Mark playback as complete after all notes
        let totalDuration = delay * Double(notes.count) + 0.5
        DispatchQueue.main.asyncAfter(deadline: .now() + totalDuration) {
            self.isPlayingAudio = false
        }
    }

    // MARK: - Answer Checking
    func checkAnswer(_ answer: String) {
        guard let question = currentQuestion else { return }

        totalAttempts += 1

        let isCorrect = answer == question.correctAnswer

        if isCorrect {
            correctAttempts += 1
            score += 1
            lastAnswerCorrect = true
            feedbackGenerator.notificationOccurred(.success)
        } else {
            lastAnswerCorrect = false
            feedbackGenerator.notificationOccurred(.error)
        }

        feedbackGenerator.prepare()

        // Show feedback briefly
        showFeedback = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.showFeedback = false
            self.generateNewQuestion()
        }
    }
}
