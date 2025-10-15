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
            VStack(spacing: 28) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Learn")
                        .font(.system(size: 34, weight: .bold))
                        .foregroundColor(Color.appText)
                    Text("Master music notation with interactive references")
                        .font(.subheadline)
                        .foregroundColor(Color.appSubtitle)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)

                // Reference cards
                VStack(spacing: 16) {
                    ForEach(Clef.allCases) { clef in
                        NavigationLink(destination: ClefReferenceView(clef: clef)) {
                            EnhancedReferenceCard(
                                title: clef.referenceTitleKey,
                                icon: "music.note",
                                description: "Learn the \(clef.rawValue) clef notation"
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)

                // Info section
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "book.fill")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(red: 0.91, green: 0.55, blue: 0.56))
                            .frame(width: 36, height: 36)
                            .background(
                                Circle()
                                    .fill(Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.15))
                            )

                        Text("Music Note Basics")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundColor(Color.appText)

                        Spacer()
                    }

                    Text(
                        """
                        In music, each Note represents a sound. The Notes are named after the alphabets: A, B, C, D, E, F, G.

                        The Stave is made of five lines and four spaces (counted upwards). The Notes are written on and between the lines of a Stave.
                        """
                    )
                    .font(.body)
                    .foregroundColor(Color.appText)
                    .multilineTextAlignment(.leading)
                    .lineSpacing(4)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.appMantle)
                        .shadow(color: Color.black.opacity(0.08), radius: 10, y: 5)
                )
                .padding(.horizontal, 20)
                .padding(.top, 8)

                Spacer()
                    .frame(height: 60)
            }
            .padding(.vertical)
        }
        .background(
            LinearGradient(
                colors: [
                    Color.appBackground,
                    Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.03)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
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

struct EnhancedReferenceCard: View {
    let title: LocalizedStringKey
    let icon: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(red: 0.91, green: 0.55, blue: 0.56),
                                Color(red: 0.85, green: 0.45, blue: 0.46)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            .shadow(
                color: Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.4),
                radius: 8,
                y: 4
            )

            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(Color.appText)

                Text(description)
                    .font(.system(size: 14))
                    .foregroundColor(Color.appSubtitle)
                    .lineLimit(2)
            }

            Spacer()

            // Arrow
            Image(systemName: "chevron.right")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(Color.appSubtitle)
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.appMantle)
                .shadow(color: Color.black.opacity(0.08), radius: 10, y: 5)
        )
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
