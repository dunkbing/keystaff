//
//  PianoKeyboardView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 28/9/25.
//

import SwiftUI

struct PianoKeyboardView: View {
    let onKeyPress: (NoteName, Accidental) -> Void

    private let whiteKeys: [NoteName] = [.c, .d, .e, .f, .g, .a, .b]
    private let blackKeyPositions: [Int: NoteName] = [
        0: .c,  // C#
        1: .d,  // D#
        3: .f,  // F#
        4: .g,  // G#
        5: .a,  // A#
    ]

    var body: some View {
        GeometryReader { geometry in
            let whiteKeyWidth = geometry.size.width / 7
            let blackKeyWidth = whiteKeyWidth * 0.6
            let blackKeyHeight: CGFloat = 85

            ZStack(alignment: .topLeading) {
                // White keys
                HStack(spacing: 0) {
                    ForEach(whiteKeys, id: \.self) { note in
                        WhiteKeyView(note: note) {
                            onKeyPress(note, .natural)
                        }
                    }
                }

                // Black keys - positioned absolutely between white keys
                // C# - between C(0) and D(1)
                BlackKeyView(note: .c) {
                    onKeyPress(.c, .sharp)
                }
                .frame(width: blackKeyWidth, height: blackKeyHeight)
                .offset(x: whiteKeyWidth - (blackKeyWidth / 2))

                // D# - between D(1) and E(2)
                BlackKeyView(note: .d) {
                    onKeyPress(.d, .sharp)
                }
                .frame(width: blackKeyWidth, height: blackKeyHeight)
                .offset(x: whiteKeyWidth * 2 - (blackKeyWidth / 2))

                // F# - between F(3) and G(4)
                BlackKeyView(note: .f) {
                    onKeyPress(.f, .sharp)
                }
                .frame(width: blackKeyWidth, height: blackKeyHeight)
                .offset(x: whiteKeyWidth * 4 - (blackKeyWidth / 2))

                // G# - between G(4) and A(5)
                BlackKeyView(note: .g) {
                    onKeyPress(.g, .sharp)
                }
                .frame(width: blackKeyWidth, height: blackKeyHeight)
                .offset(x: whiteKeyWidth * 5 - (blackKeyWidth / 2))

                // A# - between A(5) and B(6)
                BlackKeyView(note: .a) {
                    onKeyPress(.a, .sharp)
                }
                .frame(width: blackKeyWidth, height: blackKeyHeight)
                .offset(x: whiteKeyWidth * 6 - (blackKeyWidth / 2))
            }
        }
        .frame(height: 140)
    }
}

struct WhiteKeyView: View {
    let note: NoteName
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            isPressed = true
            action()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            VStack {
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isPressed ? Color.gray.opacity(0.3) : Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 4)
                            .stroke(Color.gray, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct BlackKeyView: View {
    let note: NoteName
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            isPressed = true
            action()

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            Rectangle()
                .fill(isPressed ? Color.gray : Color.black)
                .cornerRadius(4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    PianoKeyboardView { note, accidental in
        print("Pressed: \(note.rawValue)\(accidental.symbol)")
    }
    .padding()
    .background(Color.appBackground)
}
