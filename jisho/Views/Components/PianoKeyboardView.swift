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
            ZStack(alignment: .top) {
                // White keys
                HStack(spacing: 0) {
                    ForEach(whiteKeys, id: \.self) { note in
                        WhiteKeyView(note: note) {
                            onKeyPress(note, .natural)
                        }
                    }
                }

                // Black keys
                HStack(spacing: 0) {
                    ForEach(0..<7) { index in
                        if let note = blackKeyPositions[index] {
                            BlackKeyView(note: note) {
                                onKeyPress(note, .sharp)
                            }
                            .offset(
                                x: -geometry.size.width / 14 / 2,
                                y: 0
                            )
                        } else {
                            Color.clear
                                .frame(width: geometry.size.width / 7)
                        }
                    }
                }
            }
        }
        .frame(height: 180)
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
            VStack {
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 4)
                    .fill(isPressed ? Color.gray : Color.black)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .frame(height: 110)
        .padding(.horizontal, 4)
    }
}

#Preview {
    PianoKeyboardView { note, accidental in
        print("Pressed: \(note.rawValue)\(accidental.symbol)")
    }
    .padding()
    .background(Color.appBackground)
}
