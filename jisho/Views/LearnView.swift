//
//  LearnView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 28/9/25.
//

import SwiftUI
import TikimUI

struct LearnView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Reference cards
                ForEach(Clef.allCases) { clef in
                    NavigationLink(destination: ClefReferenceView(clef: clef)) {
                        ReferenceCard(
                            title: clef.referenceTitleKey,
                            icon: "music.note"
                        )
                    }
                }

                // Info section
                VStack(spacing: 12) {
                    Text("Music Note Basics")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color.appText)

                    Text(
                        """
                        In music, each Note represents a sound. The Notes are named after the alphabets: A, B, C, D, E, F, G.

                        The Stave is made of five lines and four spaces (counted upwards). The Notes are written on and between the lines of a Stave.
                        """
                    )
                    .font(.body)
                    .foregroundColor(Color.appText)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.appMantle)
                    )
                }
                .padding(.top, 20)

                Spacer()
                    .frame(height: 60)
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle("Learn")
        .navigationBarTitleDisplayMode(.large)
    }
}

struct ReferenceCard: View {
    let title: LocalizedStringKey
    let icon: String

    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(
                    Circle()
                        .fill(Color(red: 0.91, green: 0.55, blue: 0.56))
                )

            Text(title)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding(.leading, 8)

            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.91, green: 0.55, blue: 0.56),
                            Color(red: 0.85, green: 0.45, blue: 0.46),
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.3), radius: 10, y: 5)
    }
}

struct ClefReferenceView: View {
    let clef: Clef

    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // Staff with reference notes
                StaffReferenceView(clef: clef)
                    .padding(.top, 20)

                // Information
                VStack(alignment: .leading, spacing: 16) {
                    Text(clef.aboutTitleKey)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(Color.appText)

                    Text(
                        """
                        In music, each Note represents a sound. The Notes are named after the alphabets: A, B, C, D, E, F, G.

                        The Stave is made of five lines and four spaces (counted upwards). The Notes are written on and between the lines of a Stave.
                        """
                    )
                    .font(.body)
                    .foregroundColor(Color.appText)
                    .multilineTextAlignment(.leading)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.appMantle)
                )

                Spacer()
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .navigationTitle(clef.referenceTitleKey)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct StaffReferenceView: View {
    let clef: Clef

    // Reference notes to display
    var referenceNotes: [MusicNote] {
        switch clef {
        case .treble:
            return [
                MusicNote(name: .f, octave: 4, accidental: .natural),
                MusicNote(name: .g, octave: 4, accidental: .natural),
                MusicNote(name: .a, octave: 4, accidental: .natural),
                MusicNote(name: .b, octave: 4, accidental: .natural),
            ]
        case .bass:
            return [
                MusicNote(name: .a, octave: 2, accidental: .natural),
                MusicNote(name: .b, octave: 2, accidental: .natural),
                MusicNote(name: .c, octave: 3, accidental: .natural),
                MusicNote(name: .d, octave: 3, accidental: .natural),
            ]
        case .alto:
            return [
                MusicNote(name: .g, octave: 3, accidental: .natural),
                MusicNote(name: .a, octave: 3, accidental: .natural),
                MusicNote(name: .b, octave: 3, accidental: .natural),
                MusicNote(name: .c, octave: 4, accidental: .natural),
            ]
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            // Staff with clef only
            StaffView(note: nil, clef: clef, showNote: false)
                .frame(height: 160)

            // Individual notes with labels
            HStack(spacing: 20) {
                ForEach(referenceNotes) { note in
                    VStack(spacing: 12) {
                        StaffView(note: note, clef: clef, showNote: true)
                            .frame(height: 120)
                            .frame(width: 70)

                        Text(note.name.rawValue)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(Color.appText)
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.appMantle)
        )
    }
}

#Preview {
    NavigationView {
        LearnView()
    }
}
