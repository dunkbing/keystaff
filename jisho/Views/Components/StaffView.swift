//
//  StaffView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 28/9/25.
//

import SwiftUI

struct StaffView: View {
    private let notes: [MusicNote]
    let clef: Clef
    let showNote: Bool

    private let staffLineCount = 5
    private let lineSpacing: CGFloat = 16
    private let noteSize: CGFloat = 28

    init(note: MusicNote?, clef: Clef, showNote: Bool) {
        self.notes = note.map { [$0] } ?? []
        self.clef = clef
        self.showNote = showNote
    }

    init(notes: [MusicNote], clef: Clef, showNotes: Bool) {
        self.notes = notes
        self.clef = clef
        self.showNote = showNotes
    }

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
                if showNote {
                    let sortedNotes = notes.sorted {
                        $0.position(for: clef) < $1.position(for: clef)
                    }

                    ForEach(Array(sortedNotes.enumerated()), id: \.element.id) { pair in
                        NoteSymbolView(
                            note: pair.element,
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
            ForEach(ledgerLinePositions, id: \.self) { ledgerPosition in
                Rectangle()
                    .fill(Color.appText)
                    .frame(width: ledgerLineWidth, height: 2)
                    .offset(y: yOffset(for: ledgerPosition))
            }
        }
    }

    private var ledgerLinePositions: [Int] {
        guard abs(position) > 4 else { return [] }

        if position > 4 {
            let highestEven = position % 2 == 0 ? position : position - 1
            guard highestEven >= 6 else { return [] }
            return Array(stride(from: 6, through: highestEven, by: 2))
        } else {
            let lowestEven = position % 2 == 0 ? position : position + 1
            guard lowestEven <= -6 else { return [] }
            return Array(stride(from: -6, through: lowestEven, by: -2))
        }
    }

    private func yOffset(for ledgerPosition: Int) -> CGFloat {
        // Negative values move lines upward (toward the staff), positive downward
        CGFloat(position - ledgerPosition) * lineSpacing / 2
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
