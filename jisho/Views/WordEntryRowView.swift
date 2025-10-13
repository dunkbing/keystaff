//
//  WordEntryRowView.swift
//  jisho
//
//  Created by Claude on 28/9/25.
//

import SwiftUI
import TikimUI

struct WordEntryRowView: View {
    let entry: WordEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    japaneseSection
                    englishDefinitions
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    if entry.isCommon {
                        commonBadge
                    }

                    jlptBadges
                }
            }

            if !entry.senses.isEmpty {
                partsOfSpeechSection
            }
        }
        .padding()
        .background(Color.appSurface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.appSurface1, lineWidth: 1)
        )
    }

    private var japaneseSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(Array(entry.japanese.prefix(2))) { japanese in
                HStack(spacing: 8) {
                    if let word = japanese.word {
                        Text(word)
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appText)
                    }

                    Text(japanese.reading)
                        .font(.title3)
                        .foregroundColor(.appSubtitle)
                }
            }
        }
    }

    private var englishDefinitions: some View {
        VStack(alignment: .leading, spacing: 2) {
            ForEach(Array(entry.senses.prefix(2).enumerated()), id: \.offset) { index, sense in
                HStack(alignment: .top, spacing: 4) {
                    Text("\(index + 1).")
                        .font(.caption)
                        .foregroundColor(.appSubtitle)
                        .fontWeight(.medium)

                    Text(sense.englishDefinitions.prefix(3).joined(separator: "; "))
                        .font(.body)
                        .foregroundColor(.appText)
                        .lineLimit(2)
                }
            }

            if entry.senses.count > 2 {
                Text("+ \(entry.senses.count - 2) more definitions")
                    .font(.caption)
                    .foregroundColor(.appSubtitle)
                    .italic()
            }
        }
    }

    private var commonBadge: some View {
        Text("Common")
            .font(.caption2)
            .fontWeight(.semibold)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color.appGreen)
            .foregroundColor(.appBackground)
            .cornerRadius(6)
    }

    private var jlptBadges: some View {
        VStack(alignment: .trailing, spacing: 2) {
            ForEach(entry.jlpt, id: \.self) { level in
                Text(level.uppercased())
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.appAccent)
                    .foregroundColor(.appBackground)
                    .cornerRadius(4)
            }
        }
    }

    private var partsOfSpeechSection: some View {
        HStack {
            ForEach(Array(Set(entry.senses.flatMap(\.partsOfSpeech)).prefix(3)), id: \.self) {
                pos in
                Text(pos)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.appSurface1)
                    .foregroundColor(.appSubtitle)
                    .cornerRadius(4)
            }

            if Set(entry.senses.flatMap(\.partsOfSpeech)).count > 3 {
                Text("...")
                    .font(.caption)
                    .foregroundColor(.appSubtitle)
            }

            Spacer()
        }
    }
}
