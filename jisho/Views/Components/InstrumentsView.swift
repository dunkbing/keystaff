//
//  InstrumentsView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 27/11/25.
//

import SwiftUI

struct InstrumentsView: View {
    @Binding var selectedInstrument: InstrumentType
    let onNotePress: (NoteName, Accidental) -> Void

    var body: some View {
        VStack(spacing: 12) {
            // Instrument selector
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(InstrumentType.visibleCases) { instrument in
                        InstrumentSelectorButton(
                            instrument: instrument,
                            isSelected: selectedInstrument == instrument
                        ) {
                            withAnimation(.spring(response: 0.3)) {
                                selectedInstrument = instrument
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
            }

            // Selected instrument view
            Group {
                switch selectedInstrument {
                case .piano:
                    PianoKeyboardView(onKeyPress: onNotePress)
                case .guitar:
                    GuitarFretboardView(onNotePress: onNotePress)
                case .xylophone:
                    XylophoneView(onNotePress: onNotePress)
                case .recorder:
                    RecorderView(onNotePress: onNotePress)
                case .harp:
                    HarpView(onNotePress: onNotePress)
                case .violin:
                    ViolinView(onNotePress: onNotePress)
                }
            }
            .transition(.asymmetric(
                insertion: .opacity.combined(with: .scale(scale: 0.95)),
                removal: .opacity.combined(with: .scale(scale: 0.95))
            ))
            .animation(.easeInOut(duration: 0.2), value: selectedInstrument)
        }
    }
}

struct InstrumentSelectorButton: View {
    let instrument: InstrumentType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: instrument.iconName)
                    .font(.system(size: 12, weight: .semibold))
                Text(instrument.rawValue)
                    .font(.system(size: 12, weight: .semibold))
            }
            .foregroundColor(isSelected ? .white : Color.appSubtitle)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        isSelected
                            ? LinearGradient(
                                colors: [
                                    Color(red: 0.91, green: 0.55, blue: 0.56),
                                    Color(red: 0.85, green: 0.45, blue: 0.46)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            : LinearGradient(
                                colors: [Color.appMantle, Color.appMantle],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                    )
                    .shadow(
                        color: isSelected
                            ? Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.3)
                            : Color.clear,
                        radius: 6,
                        y: 3
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

#Preview {
    struct PreviewWrapper: View {
        @State private var selectedInstrument: InstrumentType = .piano

        var body: some View {
            InstrumentsView(selectedInstrument: $selectedInstrument) { note, accidental in
                print("Pressed: \(note.rawValue)\(accidental.symbol)")
            }
            .padding()
            .background(Color.appBackground)
        }
    }

    return PreviewWrapper()
}
