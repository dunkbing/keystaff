//
//  HarpView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 27/11/25.
//

import SwiftUI

struct HarpView: View {
    let onNotePress: (NoteName, Accidental) -> Void

    // Harp strings - natural notes have colored strings on real harps
    // C = Red, D = Orange, E = Yellow, F = Green, G = Blue, A = Purple, B = Pink
    // Sharps/flats are typically black or dark
    private let strings: [(note: NoteName, accidental: Accidental, color: Color)] = [
        (.c, .natural, Color.red),
        (.c, .sharp, Color.gray),
        (.d, .natural, Color.orange),
        (.d, .sharp, Color.gray),
        (.e, .natural, Color.yellow),
        (.f, .natural, Color.green),
        (.f, .sharp, Color.gray),
        (.g, .natural, Color.blue),
        (.g, .sharp, Color.gray),
        (.a, .natural, Color.purple),
        (.a, .sharp, Color.gray),
        (.b, .natural, Color.pink),
    ]

    var body: some View {
        GeometryReader { geometry in
            let stringWidth: CGFloat = (geometry.size.width - 40) / CGFloat(strings.count)

            ZStack {
                // Harp frame (curved top)
                HarpFrameShape()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.55, green: 0.35, blue: 0.20),
                                Color(red: 0.40, green: 0.25, blue: 0.12)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        HarpFrameShape()
                            .stroke(Color(red: 0.65, green: 0.45, blue: 0.25), lineWidth: 2)
                    )

                // Strings
                HStack(spacing: 0) {
                    ForEach(Array(strings.enumerated()), id: \.offset) { index, stringInfo in
                        HarpStringView(
                            note: stringInfo.note,
                            accidental: stringInfo.accidental,
                            color: stringInfo.color,
                            width: stringWidth,
                            index: index,
                            totalStrings: strings.count,
                            onPress: onNotePress
                        )
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 15)
                .padding(.bottom, 10)
            }
        }
        .frame(height: 140)
    }
}

struct HarpFrameShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()

        let topPadding: CGFloat = 8
        let bottomPadding: CGFloat = 8
        let leftPadding: CGFloat = 10
        let rightPadding: CGFloat = 10

        // Start from bottom left
        path.move(to: CGPoint(x: leftPadding, y: rect.height - bottomPadding))

        // Left edge going up
        path.addLine(to: CGPoint(x: leftPadding, y: rect.height * 0.3))

        // Curved top (like a harp's neck)
        path.addQuadCurve(
            to: CGPoint(x: rect.width - rightPadding, y: topPadding),
            control: CGPoint(x: rect.width * 0.3, y: topPadding)
        )

        // Right edge going down
        path.addLine(to: CGPoint(x: rect.width - rightPadding, y: rect.height - bottomPadding))

        // Bottom edge
        path.addLine(to: CGPoint(x: leftPadding, y: rect.height - bottomPadding))

        return path
    }
}

struct HarpStringView: View {
    let note: NoteName
    let accidental: Accidental
    let color: Color
    let width: CGFloat
    let index: Int
    let totalStrings: Int
    let onPress: (NoteName, Accidental) -> Void

    @State private var isPressed = false

    private var label: String {
        "\(note.rawValue)\(accidental.symbol)"
    }

    private var isSharp: Bool {
        accidental == .sharp
    }

    // String height varies (shorter on right, longer on left) like a real harp
    private var stringTopOffset: CGFloat {
        let progress = CGFloat(index) / CGFloat(totalStrings - 1)
        return 20 + (progress * 40) // Ranges from 20 to 60
    }

    var body: some View {
        Button(action: {
            isPressed = true
            onPress(note, accidental)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                isPressed = false
            }
        }) {
            ZStack {
                // Invisible wider tap area
                Rectangle()
                    .fill(Color.clear)
                    .frame(width: width)
                    .contentShape(Rectangle())

                // String line (visual only, thin)
                VStack(spacing: 0) {
                    Spacer()
                        .frame(height: stringTopOffset)

                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    color.opacity(isPressed ? 1.0 : 0.7),
                                    color.opacity(isPressed ? 0.8 : 0.5)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(width: isPressed ? 4 : (isSharp ? 2 : 3))
                        .shadow(
                            color: isPressed ? color.opacity(0.8) : Color.clear,
                            radius: 4
                        )
                        .allowsHitTesting(false)

                    Spacer()
                        .frame(height: 25)
                }

                // Note label at bottom
                VStack {
                    Spacer()
                    Text(label)
                        .font(.system(size: isSharp ? 9 : 11, weight: .bold))
                        .foregroundColor(isPressed ? color : .white)
                        .shadow(color: .black.opacity(0.5), radius: 1)
                        .padding(.bottom, 2)
                        .allowsHitTesting(false)
                }
            }
            .frame(width: width)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HarpView { note, accidental in
        print("Pressed: \(note.rawValue)\(accidental.symbol)")
    }
    .padding()
    .background(Color.appBackground)
}
