//
//  VocalTrainingModels.swift
//  jisho
//

import Foundation
import SwiftUI

// MARK: - Midi Note Helpers
let vocalNoteNames = ["C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B"]

func midiNoteName(_ midi: Int, includeOctave: Bool = true) -> String {
    let name = vocalNoteNames[((midi % 12) + 12) % 12]
    guard includeOctave else { return name }
    return "\(name)\(midi / 12 - 1)"
}

func midiFrequency(_ midi: Double) -> Double {
    440.0 * pow(2.0, (midi - 69.0) / 12.0)
}

// MARK: - Vocal Exercise Category
enum VocalExerciseCategory: String, CaseIterable, Identifiable {
    case scales = "Scales"
    case breathing = "Breathing"
    case tone = "Tone"
    case range = "Range"
    case agility = "Agility"

    var id: String { rawValue }

    var iconName: String {
        switch self {
        case .breathing: return "wind"
        case .tone: return "waveform"
        case .range: return "arrow.up.and.down"
        case .agility: return "hare.fill"
        case .scales: return "music.note.list"
        }
    }
}

// MARK: - Voice Type
enum VoiceType: String, CaseIterable, Identifiable {
    case bass = "Bass"
    case baritone = "Baritone"
    case tenor = "Tenor"
    case alto = "Alto"
    case mezzoSoprano = "Mezzo-Soprano"
    case soprano = "Soprano"

    var id: String { rawValue }

    /// Comfortable starting note for exercises (low-middle of the range)
    var rootMidi: Int {
        switch self {
        case .bass: return 45  // A2
        case .baritone: return 48  // C3
        case .tenor: return 52  // E3
        case .alto: return 55  // G3
        case .mezzoSoprano: return 57  // A3
        case .soprano: return 60  // C4
        }
    }

    static func suggested(forLowest midi: Int) -> VoiceType {
        switch midi {
        case ..<44: return .bass
        case ..<48: return .baritone
        case ..<53: return .tenor
        case ..<57: return .alto
        case ..<61: return .mezzoSoprano
        default: return .soprano
        }
    }
}

// MARK: - Vocal Exercise
struct VocalExercise: Identifiable, Equatable {
    let id: String
    let name: String
    let category: VocalExerciseCategory
    let goal: String
    let instructions: String
    /// Syllables sung per step, cycled if shorter than the pattern
    let syllables: [String]
    /// Semitone offsets from the round's root note
    let pattern: [Int]
    /// Seconds the user holds each note
    let noteDuration: Double
    /// Number of repetitions; each round transposes up by `ascendStep` semitones
    let rounds: Int
    var ascendStep: Int = 1
    var guideDuration: Double = 0.45

    func syllable(for step: Int) -> String {
        syllables[step % syllables.count]
    }

    static let all: [VocalExercise] = [
        // Breathing
        VocalExercise(
            id: "sustained-hum",
            name: "Sustained Hum",
            category: .breathing,
            goal: "Build breath support by holding a steady, even tone.",
            instructions: "Take a deep belly breath, then hold a relaxed \"Mm\" hum on the guide note without wavering.",
            syllables: ["Mm"],
            pattern: [0],
            noteDuration: 4.0,
            rounds: 4
        ),
        VocalExercise(
            id: "staccato-ha",
            name: "Staccato Ha",
            category: .breathing,
            goal: "Engage the diaphragm with short, supported pulses.",
            instructions: "Sing short, punchy \"Ha\" pulses on the same note. Let your belly bounce with each pulse.",
            syllables: ["Ha"],
            pattern: [0, 0, 0, 0],
            noteDuration: 0.55,
            rounds: 5
        ),
        // Tone
        VocalExercise(
            id: "descending-nya",
            name: "Descending Nya",
            category: .tone,
            goal: "Find a bright, forward tone placement.",
            instructions: "Make a slightly nasal \"Nya\" sound and walk down the five-tone scale. Keep the buzz in your mask.",
            syllables: ["Nya"],
            pattern: [7, 5, 4, 2, 0],
            noteDuration: 0.6,
            rounds: 6
        ),
        VocalExercise(
            id: "mum-motif",
            name: "Mum Motif",
            category: .tone,
            goal: "Develop a warm, connected tone across the triad.",
            instructions: "Sing \"Mum\" on each note of the arpeggio. Keep your jaw loose and the vowel round.",
            syllables: ["Mum"],
            pattern: [0, 4, 7, 4, 0],
            noteDuration: 0.6,
            rounds: 6
        ),
        // Range
        VocalExercise(
            id: "octave-repeat-nay",
            name: "Octave Repeat Nay",
            category: .range,
            goal: "Expand your range by incorporating mix voice.",
            instructions: "Make a bratty \"Nay\" sound. You should feel some buzzing in your nose.",
            syllables: ["Nay"],
            pattern: [0, 12, 12, 12, 7, 4, 0],
            noteDuration: 0.5,
            rounds: 6
        ),
        VocalExercise(
            id: "siren-glide",
            name: "Siren Glide",
            category: .range,
            goal: "Smooth out register transitions from chest to head voice.",
            instructions: "On a gentle \"Woo\", glide up through the arpeggio and back down like a siren.",
            syllables: ["Woo"],
            pattern: [0, 7, 12, 7, 0],
            noteDuration: 0.8,
            rounds: 4,
            ascendStep: 2
        ),
        // Agility
        VocalExercise(
            id: "quick-five",
            name: "Quick Five",
            category: .agility,
            goal: "Move quickly and precisely between neighboring notes.",
            instructions: "Sing a light \"Ah\" up and down the five-tone scale. Aim for clean, separate notes.",
            syllables: ["Ah"],
            pattern: [0, 2, 4, 5, 7, 5, 4, 2, 0],
            noteDuration: 0.4,
            rounds: 6
        ),
        VocalExercise(
            id: "arpeggio-run",
            name: "Arpeggio Run",
            category: .agility,
            goal: "Build accuracy on wider leaps at speed.",
            instructions: "Sing \"Yah\" up the arpeggio to the octave and back down. Stay light at the top.",
            syllables: ["Yah"],
            pattern: [0, 4, 7, 12, 7, 4, 0],
            noteDuration: 0.45,
            rounds: 6
        ),
        // Scales
        VocalExercise(
            id: "major-scale-ascending",
            name: "Major Scale Ascending",
            category: .scales,
            goal: "Familiarize yourself with the major scale.",
            instructions: "Sing the scale on Solfege (Do Re Mi) or a preferred vowel.",
            syllables: ["Do", "Re", "Mi", "Fa", "Sol", "La", "Ti", "Do"],
            pattern: [0, 2, 4, 5, 7, 9, 11, 12],
            noteDuration: 0.6,
            rounds: 4
        ),
        VocalExercise(
            id: "major-scale-descending",
            name: "Major Scale Descending",
            category: .scales,
            goal: "Keep pitch centered while moving down the scale.",
            instructions: "Sing the descending scale on Solfege (Do Ti La) or a preferred vowel.",
            syllables: ["Do", "Ti", "La", "Sol", "Fa", "Mi", "Re", "Do"],
            pattern: [12, 11, 9, 7, 5, 4, 2, 0],
            noteDuration: 0.6,
            rounds: 4
        ),
    ]

    static func exercises(in category: VocalExerciseCategory) -> [VocalExercise] {
        all.filter { $0.category == category }
    }
}

// MARK: - Vocal Training Settings
class VocalTrainingSettings: ObservableObject {
    static let shared = VocalTrainingSettings()

    @Published var voiceType: VoiceType {
        didSet { UserDefaults.standard.set(voiceType.rawValue, forKey: "vocal_voice_type") }
    }
    @Published var dailyGoal: Int {
        didSet { UserDefaults.standard.set(dailyGoal, forKey: "vocal_daily_goal") }
    }
    @Published var guideTonesEnabled: Bool {
        didSet { UserDefaults.standard.set(guideTonesEnabled, forKey: "vocal_guide_tones") }
    }

    private init() {
        let defaults = UserDefaults.standard
        voiceType = VoiceType(rawValue: defaults.string(forKey: "vocal_voice_type") ?? "") ?? .baritone
        let goal = defaults.integer(forKey: "vocal_daily_goal")
        dailyGoal = goal > 0 ? goal : 5
        guideTonesEnabled = defaults.object(forKey: "vocal_guide_tones") as? Bool ?? true
    }
}

// MARK: - Vocal Session Result
struct VocalSessionResult: Codable, Identifiable {
    let id: UUID
    let exerciseId: String
    let date: Date
    let score: Int
    /// 0-100
    let accuracy: Double
    let stars: Int

    init(exerciseId: String, score: Int, accuracy: Double, stars: Int) {
        self.id = UUID()
        self.exerciseId = exerciseId
        self.date = Date()
        self.score = score
        self.accuracy = accuracy
        self.stars = stars
    }
}

// MARK: - Vocal Progress Store
class VocalProgressStore: ObservableObject {
    static let shared = VocalProgressStore()

    @Published private(set) var results: [VocalSessionResult] = []

    private let fileManager = FileManager.default

    private var fileURL: URL {
        let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent("vocal_training_results.json")
    }

    private init() {
        loadResults()
    }

    func add(_ result: VocalSessionResult) {
        results.append(result)
        saveResults()
    }

    var todayCount: Int {
        let calendar = Calendar.current
        return results.filter { calendar.isDateInToday($0.date) }.count
    }

    var totalCount: Int { results.count }

    /// Consecutive practice days ending today or yesterday
    var streak: Int {
        let calendar = Calendar.current
        let days = Set(results.map { calendar.startOfDay(for: $0.date) })
        guard !days.isEmpty else { return 0 }

        var day = calendar.startOfDay(for: Date())
        if !days.contains(day) {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: day),
                days.contains(yesterday)
            else { return 0 }
            day = yesterday
        }

        var count = 0
        while days.contains(day) {
            count += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
            day = previous
        }
        return count
    }

    func bestStars(for exerciseId: String) -> Int {
        results.filter { $0.exerciseId == exerciseId }.map(\.stars).max() ?? 0
    }

    private func loadResults() {
        guard fileManager.fileExists(atPath: fileURL.path) else { return }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            results = try decoder.decode([VocalSessionResult].self, from: data)
        } catch {
            print("Failed to load vocal training results: \(error)")
        }
    }

    private func saveResults() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(results)
            try data.write(to: fileURL)
        } catch {
            print("Failed to save vocal training results: \(error)")
        }
    }
}
