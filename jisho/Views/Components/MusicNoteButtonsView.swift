//
//  MusicNoteButtonsView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 28/9/25.
//

import SwiftUI

enum NoteButtonHighlight {
    case none
    case correct
    case wrong
}

struct MusicNoteButtonsView: View {
    let includeAccidentals: Bool
    /// When set (after a wrong answer), the matching button is shown in green
    var highlightCorrect: (name: NoteName, accidental: Accidental)?
    /// The user's wrong pick, shown in red
    var highlightWrong: (name: NoteName, accidental: Accidental)?
    let onNotePress: (NoteName, Accidental) -> Void

    private let naturalNotes: [NoteName] = [.c, .d, .e, .f, .g, .a, .b]
    private let accidentalNotes: [(NoteName, Accidental)] = [
        (.c, .sharp),
        (.e, .flat),
        (.f, .sharp),
        (.a, .flat),
        (.b, .flat),
    ]

    var body: some View {
        VStack(spacing: 10) {
            // Accidental notes row (if enabled)
            if includeAccidentals {
                HStack(spacing: 6) {
                    ForEach(accidentalNotes, id: \.0) { note, accidental in
                        NoteButton(
                            note: note,
                            accidental: accidental,
                            highlight: highlight(for: note, accidental: accidental),
                            onPress: onNotePress
                        )
                    }
                }
            }

            // Natural notes row
            HStack(spacing: 6) {
                ForEach(naturalNotes, id: \.self) { note in
                    NoteButton(
                        note: note,
                        accidental: .natural,
                        highlight: highlight(for: note, accidental: .natural),
                        onPress: onNotePress
                    )
                }
            }
        }
    }

    private func highlight(for note: NoteName, accidental: Accidental) -> NoteButtonHighlight {
        if let wrong = highlightWrong, wrong.name == note, wrong.accidental == accidental {
            return .wrong
        }
        // Match the correct answer enharmonically (D# highlights the E♭ button)
        if let correct = highlightCorrect,
            semitone(correct.name, correct.accidental) == semitone(note, accidental)
        {
            return .correct
        }
        return .none
    }

    private func semitone(_ name: NoteName, _ accidental: Accidental) -> Int {
        var value = name.semitonesFromC
        switch accidental {
        case .sharp: value += 1
        case .flat: value -= 1
        case .natural: break
        }
        return ((value % 12) + 12) % 12
    }
}

struct NoteButton: View {
    let note: NoteName
    let accidental: Accidental
    var highlight: NoteButtonHighlight = .none
    let onPress: (NoteName, Accidental) -> Void

    @State private var isPressed = false

    private var fillColor: Color {
        switch highlight {
        case .correct: return Color.appGreen.opacity(0.85)
        case .wrong: return Color.appRed.opacity(0.85)
        case .none:
            return isPressed
                ? Color.appAccent.opacity(0.3)
                : Color.appMantle.opacity(accidental == .natural ? 1.0 : 0.6)
        }
    }

    private var strokeColor: Color {
        switch highlight {
        case .correct: return Color.appGreen
        case .wrong: return Color.appRed
        case .none:
            return isPressed ? Color.appAccent : Color.appSubtitle.opacity(0.2)
        }
    }

    var body: some View {
        Button(action: {
            isPressed = true
            onPress(note, accidental)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
            }
        }) {
            Text("\(note.rawValue)\(accidental.symbol)")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(highlight == .none ? Color.appText : .white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(fillColor)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(strokeColor, lineWidth: 2)
                )
                .animation(.easeInOut(duration: 0.15), value: highlight == .none)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 40) {
        MusicNoteButtonsView(includeAccidentals: true) { note, accidental in
            print("Pressed: \(note.rawValue)\(accidental.symbol)")
        }

        MusicNoteButtonsView(includeAccidentals: false) { note, accidental in
            print("Pressed: \(note.rawValue)\(accidental.symbol)")
        }
    }
    .padding()
    .background(Color.appBackground)
}
