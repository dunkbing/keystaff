//
//  ViolinView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 27/11/25.
//

import SwiftUI

struct ViolinView: View {
    let onNotePress: (NoteName, Accidental) -> Void

    // Violin strings: E, A, D, G (from top to bottom when horizontal)
    // Each string has finger positions showing half-step increments
    // Based on the reference image finger positions
    private let fingerboardNotes: [[NoteInfo]] = [
        // E string (top row)
        [
            NoteInfo(.f, .natural, "F"),      // 1st position
            NoteInfo(.f, .sharp, "F#"),       // 1st finger
            NoteInfo(.g, .natural, "G"),      // between 1st-2nd
            NoteInfo(.g, .sharp, "G#"),       // 2nd finger
            NoteInfo(.a, .natural, "A"),      // 3rd finger
        ],
        // A string
        [
            NoteInfo(.a, .sharp, "A#"),       // 1st position
            NoteInfo(.b, .natural, "B"),      // 1st finger
            NoteInfo(.c, .natural, "C"),      // between 1st-2nd
            NoteInfo(.c, .sharp, "C#"),       // 2nd finger
            NoteInfo(.d, .natural, "D"),      // 3rd finger
        ],
        // D string
        [
            NoteInfo(.d, .sharp, "D#"),       // 1st position
            NoteInfo(.e, .natural, "E"),      // 1st finger
            NoteInfo(.f, .natural, "F"),      // between 1st-2nd
            NoteInfo(.f, .sharp, "F#"),       // 2nd finger
            NoteInfo(.g, .natural, "G"),      // 3rd finger
        ],
        // G string (bottom row)
        [
            NoteInfo(.g, .sharp, "G#"),       // 1st position
            NoteInfo(.a, .natural, "A"),      // 1st finger
            NoteInfo(.a, .sharp, "A#"),       // between 1st-2nd
            NoteInfo(.b, .natural, "B"),      // 2nd finger
            NoteInfo(.c, .natural, "C"),      // 3rd finger
        ],
    ]

    private let stringLabels = ["E", "A", "D", "G"]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Fingerboard background (dark ebony)
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(red: 0.1, green: 0.08, blue: 0.06))

                // Strings (horizontal lines) - drawn FIRST so they appear behind notes
                VStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { stringIndex in
                        Spacer()
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.5),
                                        Color.gray.opacity(0.7),
                                        Color.white.opacity(0.5)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(height: CGFloat(stringIndex) + 1) // Thinner E (top), thicker G (bottom)
                        Spacer()
                    }
                }
                .padding(.leading, 24) // After the nut
                .allowsHitTesting(false)

                // Notes and nut - drawn AFTER strings so they appear on top
                HStack(spacing: 0) {
                    // String labels on left (nut area)
                    VStack(spacing: 0) {
                        ForEach(0..<4, id: \.self) { stringIndex in
                            Text(stringLabels[stringIndex])
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Color(red: 0.2, green: 0.15, blue: 0.1))
                                .frame(maxHeight: .infinity)
                        }
                    }
                    .frame(width: 24)
                    .background(Color(red: 0.9, green: 0.85, blue: 0.75)) // Nut (ivory)

                    // Finger positions (columns)
                    HStack(spacing: 0) {
                        ForEach(0..<5, id: \.self) { fingerPos in
                            VStack(spacing: 0) {
                                ForEach(0..<4, id: \.self) { stringIndex in
                                    let noteInfo = fingerboardNotes[stringIndex][fingerPos]
                                    ViolinNoteButton(
                                        noteInfo: noteInfo,
                                        stringIndex: stringIndex,
                                        onPress: onNotePress
                                    )
                                }
                            }

                            // Position divider line (except after last)
                            if fingerPos < 4 {
                                Rectangle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 1)
                            }
                        }
                    }
                }
            }
        }
        .frame(height: 140)
    }
}

struct NoteInfo {
    let note: NoteName
    let accidental: Accidental
    let label: String

    init(_ note: NoteName, _ accidental: Accidental, _ label: String) {
        self.note = note
        self.accidental = accidental
        self.label = label
    }
}

struct ViolinNoteButton: View {
    let noteInfo: NoteInfo
    let stringIndex: Int
    let onPress: (NoteName, Accidental) -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            isPressed = true
            onPress(noteInfo.note, noteInfo.accidental)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
            }
        }) {
            ZStack {
                // Tap area
                Rectangle()
                    .fill(Color.clear)
                    .contentShape(Rectangle())

                // Note circle with label
                Circle()
                    .fill(
                        isPressed
                            ? Color(red: 0.91, green: 0.55, blue: 0.56)
                            : Color(red: 0.7, green: 0.85, blue: 0.7)
                    )
                    .frame(width: 26, height: 26)
                    .overlay(
                        Circle()
                            .stroke(Color.black.opacity(0.3), lineWidth: 1)
                    )
                    .shadow(
                        color: isPressed ? Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.6) : Color.clear,
                        radius: 4
                    )

                // Note label
                Text(noteInfo.label)
                    .font(.system(size: noteInfo.label.count > 1 ? 9 : 11, weight: .bold))
                    .foregroundColor(Color(red: 0.2, green: 0.2, blue: 0.2))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ViolinView { note, accidental in
        print("Pressed: \(note.rawValue)\(accidental.symbol)")
    }
    .padding()
    .background(Color.appBackground)
}
