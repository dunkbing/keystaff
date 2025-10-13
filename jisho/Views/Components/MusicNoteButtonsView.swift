//
//  MusicNoteButtonsView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 28/9/25.
//

import SwiftUI

struct MusicNoteButtonsView: View {
    let includeAccidentals: Bool
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
        VStack(spacing: 16) {
            // Accidental notes row (if enabled)
            if includeAccidentals {
                HStack(spacing: 8) {
                    ForEach(accidentalNotes, id: \.0) { note, accidental in
                        NoteButton(
                            note: note,
                            accidental: accidental,
                            onPress: onNotePress
                        )
                    }
                }
            }

            // Natural notes row
            HStack(spacing: 8) {
                ForEach(naturalNotes, id: \.self) { note in
                    NoteButton(
                        note: note,
                        accidental: .natural,
                        onPress: onNotePress
                    )
                }
            }
        }
    }
}

struct NoteButton: View {
    let note: NoteName
    let accidental: Accidental
    let onPress: (NoteName, Accidental) -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            isPressed = true
            onPress(note, accidental)

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
            }
        }) {
            Text("\(note.rawValue)\(accidental.symbol)")
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(Color.appText)
                .frame(maxWidth: .infinity)
                .frame(height: 60)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            isPressed
                                ? Color.appAccent.opacity(0.3)
                                : Color.appMantle.opacity(accidental == .natural ? 1.0 : 0.6)
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(
                            isPressed ? Color.appAccent : Color.appSubtitle.opacity(0.2),
                            lineWidth: 2
                        )
                )
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
