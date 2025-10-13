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
            // Ledger lines if needed
            LedgerLinesView(
                position: notePosition,
                lineSpacing: lineSpacing,
                staffCenter: staffCenter
            )

            // Note head
            Circle()
                .fill(Color.appText)
                .frame(width: noteSize, height: noteSize * 0.7)
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
    let staffCenter: CGFloat

    private let ledgerLineWidth: CGFloat = 40

    var body: some View {
        ZStack {
            // Ledger lines above staff (position > 4)
            if position > 4 {
                ForEach(5...position, id: \.self) { pos in
                    if pos % 2 == 1 {  // Only draw lines for odd positions
                        Path { path in
                            let y = -CGFloat(pos) * lineSpacing / 2
                            path.move(to: CGPoint(x: -ledgerLineWidth / 2, y: y))
                            path.addLine(to: CGPoint(x: ledgerLineWidth / 2, y: y))
                        }
                        .stroke(Color.appText, lineWidth: 2)
                    }
                }
            }

            // Ledger lines below staff (position < -4)
            if position < -4 {
                ForEach(position...(-5), id: \.self) { pos in
                    if pos % 2 == 1 {  // Only draw lines for odd positions
                        Path { path in
                            let y = -CGFloat(pos) * lineSpacing / 2
                            path.move(to: CGPoint(x: -ledgerLineWidth / 2, y: y))
                            path.addLine(to: CGPoint(x: ledgerLineWidth / 2, y: y))
                        }
                        .stroke(Color.appText, lineWidth: 2)
                    }
                }
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
