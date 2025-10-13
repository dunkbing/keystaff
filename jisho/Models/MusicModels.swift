//
//  MusicModels.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 28/9/25.
//

import Foundation

// MARK: - Note Model
struct MusicNote: Identifiable, Equatable {
    let id = UUID()
    let name: NoteName
    let octave: Int
    let accidental: Accidental

    var displayName: String {
        "\(name.rawValue)\(accidental.symbol)"
    }

    var fullName: String {
        "\(name.rawValue)\(accidental.symbol)\(octave)"
    }

    // Position on staff (0 = middle line)
    // Each position is one staff line or space
    // Positive numbers go up, negative go down
    func position(for clef: Clef) -> Int {
        let baseNote: NoteName
        let baseOctave: Int

        switch clef {
        case .treble:
            // Middle line (B4) is position 0
            baseNote = .b
            baseOctave = 4
        case .bass:
            // Middle line (D3) is position 0
            baseNote = .d
            baseOctave = 3
        case .alto:
            // Middle line (C4) is position 0
            baseNote = .c
            baseOctave = 4
        }

        // Calculate position based on diatonic scale (7 notes per octave)
        let noteSteps = name.staffPosition - baseNote.staffPosition
        let octaveSteps = (octave - baseOctave) * 7

        return noteSteps + octaveSteps
    }
}

// MARK: - Note Name
enum NoteName: String, CaseIterable {
    case c = "C"
    case d = "D"
    case e = "E"
    case f = "F"
    case g = "G"
    case a = "A"
    case b = "B"

    var semitonesFromC: Int {
        switch self {
        case .c: return 0
        case .d: return 2
        case .e: return 4
        case .f: return 5
        case .g: return 7
        case .a: return 9
        case .b: return 11
        }
    }

    var staffPosition: Int {
        // Position in diatonic scale (0-6)
        switch self {
        case .c: return 0
        case .d: return 1
        case .e: return 2
        case .f: return 3
        case .g: return 4
        case .a: return 5
        case .b: return 6
        }
    }
}

// MARK: - Accidental
enum Accidental: String, CaseIterable {
    case natural = ""
    case sharp = "#"
    case flat = "♭"

    var symbol: String {
        rawValue
    }
}

// MARK: - Clef
enum Clef: String, CaseIterable, Identifiable {
    case treble = "Treble"
    case bass = "Bass"
    case alto = "Alto"

    var id: String { rawValue }

    var defaultRange: NoteRange {
        switch self {
        case .treble:
            return NoteRange(
                low: MusicNote(name: .f, octave: 3, accidental: .natural),
                high: MusicNote(name: .e, octave: 6, accidental: .natural)
            )
        case .bass:
            return NoteRange(
                low: MusicNote(name: .a, octave: 1, accidental: .natural),
                high: MusicNote(name: .g, octave: 4, accidental: .natural)
            )
        case .alto:
            return NoteRange(
                low: MusicNote(name: .g, octave: 2, accidental: .natural),
                high: MusicNote(name: .f, octave: 5, accidental: .natural)
            )
        }
    }
}

// MARK: - Note Range
struct NoteRange: Equatable {
    let low: MusicNote
    let high: MusicNote
}

// MARK: - Input Mode
enum InputMode: String, CaseIterable {
    case musicNotes = "Music Notes"
    case pianoKeys = "Piano Keys"
}

// MARK: - Game Duration
enum GameDuration: String, CaseIterable, Identifiable {
    case oneMinute = "1 min"
    case fiveMinutes = "5 mins"
    case tenMinutes = "10 mins"
    case infinite = "∞"

    var id: String { rawValue }

    var seconds: TimeInterval? {
        switch self {
        case .oneMinute: return 60
        case .fiveMinutes: return 300
        case .tenMinutes: return 600
        case .infinite: return nil
        }
    }
}

// MARK: - Game Settings
class GameSettings: ObservableObject {
    @Published var selectedClefs: Set<Clef> = [.treble]
    @Published var trebleRange: NoteRange = Clef.treble.defaultRange
    @Published var bassRange: NoteRange = Clef.bass.defaultRange
    @Published var altoRange: NoteRange = Clef.alto.defaultRange
    @Published var duration: GameDuration = .oneMinute
    @Published var includeAccidentals: Bool = true
    @Published var soundEnabled: Bool = true
    @Published var hapticFeedbackEnabled: Bool = false

    static let shared = GameSettings()

    func range(for clef: Clef) -> NoteRange {
        switch clef {
        case .treble: return trebleRange
        case .bass: return bassRange
        case .alto: return altoRange
        }
    }
}

// MARK: - Time Signature
enum TimeSignature: String, CaseIterable, Identifiable {
    case twoFour = "2/4"
    case threeFour = "3/4"
    case fourFour = "4/4"
    case sixEight = "6/8"

    var id: String { rawValue }

    var beatsPerMeasure: Int {
        switch self {
        case .twoFour: return 2
        case .threeFour: return 3
        case .fourFour: return 4
        case .sixEight: return 6
        }
    }
}
