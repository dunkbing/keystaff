//
//  XylophoneView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 27/11/25.
//

import SwiftUI

struct XylophoneView: View {
    let onNotePress: (NoteName, Accidental) -> Void

    // Xylophone bars from low to high (C to B with sharps/flats in between)
    // Standard xylophone layout - natural notes only for simplicity
    // But we can add a second row for accidentals like a keyboard

    private let naturalNotes: [NoteName] = [.c, .d, .e, .f, .g, .a, .b]

    // Colors for each bar (rainbow-like, typical of xylophones)
    private let barColors: [Color] = [
        Color(red: 0.91, green: 0.30, blue: 0.24), // C - Red
        Color(red: 0.95, green: 0.50, blue: 0.15), // D - Orange
        Color(red: 0.95, green: 0.77, blue: 0.06), // E - Yellow
        Color(red: 0.18, green: 0.80, blue: 0.44), // F - Green
        Color(red: 0.20, green: 0.60, blue: 0.86), // G - Blue
        Color(red: 0.36, green: 0.25, blue: 0.60), // A - Indigo
        Color(red: 0.61, green: 0.35, blue: 0.71)  // B - Violet
    ]

    var body: some View {
        VStack(spacing: 8) {
            // Accidental bars (sharps) - smaller, positioned above
            HStack(spacing: 8) {
                // C# bar
                XylophoneBarView(
                    note: .c,
                    accidental: .sharp,
                    color: barColors[0].opacity(0.7),
                    width: 36,
                    height: 45
                ) {
                    onNotePress(.c, .sharp)
                }

                // D# bar
                XylophoneBarView(
                    note: .d,
                    accidental: .sharp,
                    color: barColors[1].opacity(0.7),
                    width: 38,
                    height: 45
                ) {
                    onNotePress(.d, .sharp)
                }

                Spacer()
                    .frame(width: 48) // Gap where E# would be (no black key)

                // F# bar
                XylophoneBarView(
                    note: .f,
                    accidental: .sharp,
                    color: barColors[3].opacity(0.7),
                    width: 40,
                    height: 45
                ) {
                    onNotePress(.f, .sharp)
                }

                // G# bar
                XylophoneBarView(
                    note: .g,
                    accidental: .sharp,
                    color: barColors[4].opacity(0.7),
                    width: 42,
                    height: 45
                ) {
                    onNotePress(.g, .sharp)
                }

                // A# bar
                XylophoneBarView(
                    note: .a,
                    accidental: .sharp,
                    color: barColors[5].opacity(0.7),
                    width: 44,
                    height: 45
                ) {
                    onNotePress(.a, .sharp)
                }
            }
            .padding(.horizontal, 20)

            // Natural note bars - main row
            HStack(spacing: 4) {
                ForEach(Array(naturalNotes.enumerated()), id: \.element) { index, note in
                    let barWidth: CGFloat = 40 + CGFloat(index) * 4
                    XylophoneBarView(
                        note: note,
                        accidental: .natural,
                        color: barColors[index],
                        width: barWidth,
                        height: 70
                    ) {
                        onNotePress(note, .natural)
                    }
                }
            }
        }
        .frame(height: 140)
    }
}

struct XylophoneBarView: View {
    let note: NoteName
    let accidental: Accidental
    let color: Color
    let width: CGFloat
    let height: CGFloat
    let action: () -> Void

    @State private var isPressed = false

    private var displayLabel: String {
        "\(note.rawValue)\(accidental.symbol)"
    }

    var body: some View {
        Button(action: {
            isPressed = true
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                isPressed = false
            }
        }) {
            ZStack {
                // Bar shape with rounded ends
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(isPressed ? 0.6 : 1.0),
                                color.opacity(isPressed ? 0.4 : 0.8)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(
                        color: color.opacity(0.4),
                        radius: isPressed ? 2 : 4,
                        y: isPressed ? 1 : 3
                    )

                // Hole indicators (typical of xylophone bars)
                VStack {
                    Spacer()
                    HStack(spacing: width * 0.3) {
                        Circle()
                            .fill(Color.black.opacity(0.2))
                            .frame(width: 4, height: 4)
                        Circle()
                            .fill(Color.black.opacity(0.2))
                            .frame(width: 4, height: 4)
                    }
                    .padding(.bottom, 8)
                }

                // Note label
                Text(displayLabel)
                    .font(.system(size: accidental == .natural ? 14 : 10, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 1)
            }
            .frame(width: width, height: height)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
}

#Preview {
    XylophoneView { note, accidental in
        print("Pressed: \(note.rawValue)\(accidental.symbol)")
    }
    .padding()
    .background(Color.appBackground)
}
