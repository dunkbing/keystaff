//
//  StaffView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 28/9/25.
//

import SwiftUI

struct StaffView: View {
    let note: MusicNote?
    let clef: Clef
    let showNote: Bool

    private let staffLineCount = 5
    private let lineSpacing: CGFloat = 16
    private let noteSize: CGFloat = 28

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Staff lines
                ForEach(0..<staffLineCount, id: \.self) { index in
                    Path { path in
                        let y = CGFloat(index) * lineSpacing + geometry.size.height / 2
                            - CGFloat(staffLineCount - 1) * lineSpacing / 2
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    .stroke(Color.appText, lineWidth: 2)
                }

                // Clef symbol
                ClefSymbolView(clef: clef)
                    .frame(width: 60, height: 120)
                    .position(
                        x: 80,
                        y: geometry.size.height / 2
                    )

                // Note if present
                if showNote, let note = note {
                    NoteSymbolView(
                        note: note,
                        clef: clef,
                        lineSpacing: lineSpacing,
                        staffCenter: geometry.size.height / 2
                    )
                    .position(
                        x: geometry.size.width - 100,
                        y: geometry.size.height / 2
                    )
                }
            }
        }
        .frame(height: 160)
    }
}

struct ClefSymbolView: View {
    let clef: Clef

    var body: some View {
        switch clef {
        case .treble:
            // Treble clef (G clef) - simplified version
            Text("𝄞")
                .font(.system(size: 100))
                .foregroundColor(Color.appText)
        case .bass:
            // Bass clef (F clef) - simplified version
            Text("𝄢")
                .font(.system(size: 80))
                .foregroundColor(Color.appText)
        case .alto:
            // Alto clef (C clef) - simplified version
            Text("𝄡")
                .font(.system(size: 80))
                .foregroundColor(Color.appText)
        }
    }
}

struct NoteSymbolView: View {
    let note: MusicNote
    let clef: Clef
    let lineSpacing: CGFloat
    let staffCenter: CGFloat

    private let noteSize: CGFloat = 28

    var body: some View {
        ZStack {
            // Note head
            Circle()
                .fill(Color.appText)
                .frame(width: noteSize, height: noteSize * 0.7)
                .offset(y: noteOffset)

            // Ledger lines if needed (positioned with the note)
            LedgerLinesView(
                position: notePosition,
                lineSpacing: lineSpacing
            )
            .offset(y: noteOffset)

            // Accidental symbol
            if note.accidental != .natural {
                Text(note.accidental.symbol)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(Color.appText)
                    .offset(x: -25, y: noteOffset)
            }
        }
    }

    private var notePosition: Int {
        note.position(for: clef)
    }

    private var noteOffset: CGFloat {
        // Calculate offset from staff center based on position
        // Position 0 is at the center line, positive goes up, negative goes down
        return -CGFloat(notePosition) * lineSpacing / 2
    }
}

struct LedgerLinesView: View {
    let position: Int
    let lineSpacing: CGFloat

    private let ledgerLineWidth: CGFloat = 40

    var body: some View {
        ZStack {
            // Draw a single ledger line through the note if it's on a ledger line
            // Ledger lines are only drawn if the note position is even (on a line, not in a space)
            // and is outside the staff (position > 4 or position < -4)

            if abs(position) > 4 && position % 2 == 0 {
                Path { path in
                    // Draw horizontal line through the note (y=0 since we're offset with the note)
                    path.move(to: CGPoint(x: -ledgerLineWidth / 2, y: 0))
                    path.addLine(to: CGPoint(x: ledgerLineWidth / 2, y: 0))
                }
                .stroke(Color.appText, lineWidth: 2)
            }
        }
    }
}

#Preview {
    VStack(spacing: 40) {
        StaffView(
            note: MusicNote(name: .c, octave: 5, accidental: .natural),
            clef: .treble,
            showNote: true
        )

        StaffView(
            note: MusicNote(name: .c, octave: 3, accidental: .sharp),
            clef: .bass,
            showNote: true
        )
    }
    .padding()
    .background(Color.appBackground)
}
