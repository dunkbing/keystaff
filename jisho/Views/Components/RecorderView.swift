//
//  RecorderView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 27/11/25.
//

import SwiftUI

struct RecorderView: View {
    let onNotePress: (NoteName, Accidental) -> Void

    // Notes available on a recorder
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
                    RecorderNoteButton(
                        noteInfo: notes[index],
                        onPress: onNotePress
                    )
                }
            }

            // Second row: F# to B
            HStack(spacing: 4) {
                ForEach(6..<12, id: \.self) { index in
                    RecorderNoteButton(
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

struct RecorderNoteButton: View {
    let noteInfo: (note: NoteName, accidental: Accidental, label: String)
    let onPress: (NoteName, Accidental) -> Void

    @State private var isPressed = false

    private var isSharp: Bool {
        noteInfo.accidental == .sharp
    }

    // Cream/beige color for plastic recorder look
    private let recorderColor = Color(red: 0.96, green: 0.93, blue: 0.85)
    private let recorderDarkColor = Color(red: 0.90, green: 0.85, blue: 0.75)

    var body: some View {
        Button(action: {
            isPressed = true
            onPress(noteInfo.note, noteInfo.accidental)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
            }
        }) {
            ZStack {
                // Recorder body shape
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            colors: [
                                recorderColor,
                                recorderDarkColor
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(
                                isPressed
                                    ? Color(red: 0.91, green: 0.55, blue: 0.56)
                                    : Color(red: 0.75, green: 0.70, blue: 0.60),
                                lineWidth: isPressed ? 3 : 1.5
                            )
                    )
                    .shadow(
                        color: isPressed
                            ? Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.5)
                            : Color.black.opacity(0.15),
                        radius: isPressed ? 4 : 2,
                        y: isPressed ? 1 : 2
                    )

                VStack(spacing: 4) {
                    // Note label
                    Text(noteInfo.label)
                        .font(.system(size: isSharp ? 14 : 16, weight: .bold))
                        .foregroundColor(
                            isPressed
                                ? Color(red: 0.91, green: 0.55, blue: 0.56)
                                : Color(red: 0.35, green: 0.30, blue: 0.25)
                        )

                    // Simple recorder hole visual (like looking down at a recorder)
                    VStack(spacing: 3) {
                        // Top holes
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(red: 0.25, green: 0.20, blue: 0.15))
                                .frame(width: 8, height: 8)
                            Circle()
                                .fill(Color(red: 0.25, green: 0.20, blue: 0.15))
                                .frame(width: 8, height: 8)
                        }
                        // Bottom holes
                        HStack(spacing: 4) {
                            Circle()
                                .fill(Color(red: 0.25, green: 0.20, blue: 0.15))
                                .frame(width: 6, height: 6)
                            Circle()
                                .fill(Color(red: 0.25, green: 0.20, blue: 0.15))
                                .frame(width: 6, height: 6)
                        }
                    }
                }
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
    RecorderView { note, accidental in
        print("Pressed: \(note.rawValue)\(accidental.symbol)")
    }
    .padding()
    .background(Color.appBackground)
}
