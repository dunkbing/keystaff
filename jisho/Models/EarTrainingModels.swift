//
//  EarTrainingModels.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 27/11/25.
//

import Foundation
import SwiftUI

// MARK: - Ear Training Exercise Type
enum EarTrainingExerciseType: String, CaseIterable, Identifiable {
    case singleNote = "Single Note"
    case interval = "Interval"
    case melody = "Melody"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .singleNote:
            return "music.note"
        case .interval:
            return "arrow.left.and.right"
        case .melody:
            return "music.note.list"
        }
    }

    var description: LocalizedStringKey {
        switch self {
        case .singleNote:
            return "Identify single notes by ear"
        case .interval:
            return "Identify the interval between two notes"
        case .melody:
            return "Identify a sequence of notes"
        }
    }
}

// MARK: - Musical Interval
enum MusicalInterval: Int, CaseIterable, Identifiable {
    case unison = 0
    case minorSecond = 1
    case majorSecond = 2
    case minorThird = 3
    case majorThird = 4
    case perfectFourth = 5
    case tritone = 6
    case perfectFifth = 7
    case minorSixth = 8
    case majorSixth = 9
    case minorSeventh = 10
    case majorSeventh = 11
    case octave = 12

    var id: Int { rawValue }

    var displayName: String {
        switch self {
        case .unison: return "Unison"
        case .minorSecond: return "Minor 2nd"
        case .majorSecond: return "Major 2nd"
        case .minorThird: return "Minor 3rd"
        case .majorThird: return "Major 3rd"
        case .perfectFourth: return "Perfect 4th"
        case .tritone: return "Tritone"
        case .perfectFifth: return "Perfect 5th"
        case .minorSixth: return "Minor 6th"
        case .majorSixth: return "Major 6th"
        case .minorSeventh: return "Minor 7th"
        case .majorSeventh: return "Major 7th"
        case .octave: return "Octave"
        }
    }

    var shortName: String {
        switch self {
        case .unison: return "P1"
        case .minorSecond: return "m2"
        case .majorSecond: return "M2"
        case .minorThird: return "m3"
        case .majorThird: return "M3"
        case .perfectFourth: return "P4"
        case .tritone: return "TT"
        case .perfectFifth: return "P5"
        case .minorSixth: return "m6"
        case .majorSixth: return "M6"
        case .minorSeventh: return "m7"
        case .majorSeventh: return "M7"
        case .octave: return "P8"
        }
    }

    /// Common intervals for beginner training
    static var beginnerIntervals: [MusicalInterval] {
        [.majorSecond, .majorThird, .perfectFourth, .perfectFifth, .octave]
    }

    /// Intermediate intervals
    static var intermediateIntervals: [MusicalInterval] {
        [.minorSecond, .majorSecond, .minorThird, .majorThird, .perfectFourth, .perfectFifth, .minorSixth, .majorSixth, .octave]
    }

    /// All intervals for advanced training
    static var advancedIntervals: [MusicalInterval] {
        allCases
    }
}

// MARK: - Ear Training Difficulty
enum EarTrainingDifficulty: String, CaseIterable, Identifiable {
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"

    var id: String { rawValue }

    var noteRange: (low: Int, high: Int) {
        switch self {
        case .beginner:
            return (3, 5) // C3 to C5
        case .intermediate:
            return (2, 6) // C2 to C6
        case .advanced:
            return (1, 7) // C1 to C7
        }
    }

    var intervals: [MusicalInterval] {
        switch self {
        case .beginner:
            return MusicalInterval.beginnerIntervals
        case .intermediate:
            return MusicalInterval.intermediateIntervals
        case .advanced:
            return MusicalInterval.advancedIntervals
        }
    }

    var melodyLength: Int {
        switch self {
        case .beginner:
            return 3
        case .intermediate:
            return 4
        case .advanced:
            return 5
        }
    }
}

// MARK: - Ear Training Settings
class EarTrainingSettings: ObservableObject {
    @Published var exerciseType: EarTrainingExerciseType = .singleNote
    @Published var difficulty: EarTrainingDifficulty = .beginner
    @Published var duration: GameDuration = .oneMinute
    @Published var includeAccidentals: Bool = false
    @Published var showVisualHint: Bool = false
    @Published var playbackSpeed: Double = 1.0
    @Published var autoReplay: Bool = false

    static let shared = EarTrainingSettings()

    /// Get available notes based on difficulty and accidentals setting
    func availableNotes() -> [MusicNote] {
        var notes: [MusicNote] = []
        let range = difficulty.noteRange

        for octave in range.low...range.high {
            for noteName in NoteName.allCases {
                notes.append(MusicNote(name: noteName, octave: octave, accidental: .natural))

                if includeAccidentals {
                    // Skip B# and E# (enharmonic to C and F)
                    if noteName != .b && noteName != .e {
                        notes.append(MusicNote(name: noteName, octave: octave, accidental: .sharp))
                    }
                    // Skip C♭ and F♭ (enharmonic to B and E)
                    if noteName != .c && noteName != .f {
                        notes.append(MusicNote(name: noteName, octave: octave, accidental: .flat))
                    }
                }
            }
        }

        return notes
    }
}

// MARK: - Ear Training Question
struct EarTrainingQuestion: Identifiable {
    let id = UUID()
    let type: EarTrainingExerciseType
    let notes: [MusicNote]
    let correctAnswer: String
    let answerOptions: [String]

    var displayDescription: String {
        switch type {
        case .singleNote:
            return "What note is this?"
        case .interval:
            return "What interval is this?"
        case .melody:
            return "What is the melody?"
        }
    }
}

// MARK: - Ear Training Result
struct EarTrainingResult: Codable, Identifiable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let exerciseType: String
    let difficulty: String
    let score: Int
    let correctAttempts: Int
    let totalAttempts: Int

    init(
        duration: TimeInterval,
        exerciseType: EarTrainingExerciseType,
        difficulty: EarTrainingDifficulty,
        score: Int,
        correctAttempts: Int,
        totalAttempts: Int
    ) {
        self.id = UUID()
        self.date = Date()
        self.duration = duration
        self.exerciseType = exerciseType.rawValue
        self.difficulty = difficulty.rawValue
        self.score = score
        self.correctAttempts = correctAttempts
        self.totalAttempts = totalAttempts
    }

    var accuracyPercentage: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(correctAttempts) / Double(totalAttempts) * 100
    }
}

// MARK: - Ear Training Result Store
@MainActor
class EarTrainingResultStore: ObservableObject {
    static let shared = EarTrainingResultStore()

    @Published private(set) var results: [EarTrainingResult] = []

    private let saveKey = "ear_training_results"
    private let fileManager = FileManager.default

    private var fileURL: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("ear_training_results.json")
    }

    private init() {
        loadResults()
    }

    func add(_ result: EarTrainingResult) {
        results.append(result)
        saveResults()
    }

    func clearAll() {
        results.removeAll()
        saveResults()
    }

    func recentResults(limit: Int = 12) -> [EarTrainingResult] {
        Array(results.suffix(limit))
    }

    private func loadResults() {
        guard fileManager.fileExists(atPath: fileURL.path) else { return }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            results = try decoder.decode([EarTrainingResult].self, from: data)
        } catch {
            print("Failed to load ear training results: \(error)")
        }
    }

    private func saveResults() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(results)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save ear training results: \(error)")
        }
    }
}
