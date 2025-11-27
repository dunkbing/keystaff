//
//  GuitarFretboardView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 27/11/25.
//

import SwiftUI

struct GuitarFretboardView: View {
    let onNotePress: (NoteName, Accidental) -> Void

    // Simplified guitar - show one octave of notes as tappable buttons
    // This is more intuitive for learning note names

    // Notes in chromatic order
    private let notes: [(note: NoteName, accidental: Accidental, label: String)] = [
        (.c, .natural, "C"),
        (.c, .sharp, "C#"),
        (.d, .natural, "D"),
        (.d, .sharp, "D#"),
        (.e, .natural, "E"),
        (.f, .natural, "F"),
        (.f, .sharp, "F#"),
        (.g, .natural, "G"),
        (.g, .sharp, "G#"),
        (.a, .natural, "A"),
        (.a, .sharp, "A#"),
        (.b, .natural, "B"),
    ]

    var body: some View {
        VStack(spacing: 6) {
            // First row: C to F
            HStack(spacing: 4) {
                ForEach(0..<6, id: \.self) { index in
                    GuitarNoteButton(
                        noteInfo: notes[index],
                        onPress: onNotePress
                    )
                }
            }

            // Second row: F# to B
            HStack(spacing: 4) {
                ForEach(6..<12, id: \.self) { index in
                    GuitarNoteButton(
                        noteInfo: notes[index],
                        onPress: onNotePress
                    )
                }
            }
        }
        .padding(.horizontal, 4)
        .frame(height: 140)
    }
}

struct GuitarNoteButton: View {
    let noteInfo: (note: NoteName, accidental: Accidental, label: String)
    let onPress: (NoteName, Accidental) -> Void

    @State private var isPressed = false

    private var isSharp: Bool {
        noteInfo.accidental == .sharp
    }

    var body: some View {
        Button(action: {
            isPressed = true
            onPress(noteInfo.note, noteInfo.accidental)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
            }
        }) {
            ZStack {
                // Guitar string hole / sound hole aesthetic
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.45, green: 0.30, blue: 0.18),
                                Color(red: 0.35, green: 0.22, blue: 0.12)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(
                                isPressed
                                    ? Color(red: 0.91, green: 0.55, blue: 0.56)
                                    : Color(red: 0.55, green: 0.40, blue: 0.25),
                                lineWidth: isPressed ? 3 : 1.5
                            )
                    )
                    .shadow(
                        color: isPressed
                            ? Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.5)
                            : Color.black.opacity(0.2),
                        radius: isPressed ? 4 : 2,
                        y: isPressed ? 1 : 2
                    )

                // Fret wire indicator
                Rectangle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 2)
                    .frame(maxHeight: .infinity)
                    .offset(x: -20)

                // String lines
                VStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { _ in
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.gray.opacity(0.3), Color.white.opacity(0.5), Color.gray.opacity(0.3)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(height: 1)
                    }
                }
                .padding(.horizontal, 4)

                // Note label
                Text(noteInfo.label)
                    .font(.system(size: isSharp ? 12 : 14, weight: .bold))
                    .foregroundColor(isPressed ? Color(red: 0.91, green: 0.55, blue: 0.56) : .white)
                    .shadow(color: .black.opacity(0.5), radius: 1)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
}

#Preview {
    GuitarFretboardView { note, accidental in
        print("Pressed: \(note.rawValue)\(accidental.symbol)")
    }
    .padding()
    .background(Color.appBackground)
}
