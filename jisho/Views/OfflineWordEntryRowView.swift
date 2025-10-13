//
//  OfflineWordEntryRowView.swift
//  jisho
//
//  Created by Claude on 28/9/25.
//

import SwiftUI
import TikimUI

struct OfflineWordEntryRowView: View {
    let result: SearchResult

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    japaneseSection
                    englishDefinitions
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    if result.isCommon {
                        commonBadge
                    }

                    jlptBadges
                }
            }

            if !result.partsOfSpeech.isEmpty {
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
        HStack(spacing: 8) {
            if let word = result.word {
                Text(word)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.appText)
            }

            Text(result.reading)
                .font(.title3)
                .foregroundColor(.appSubtitle)
        }
    }

    private var englishDefinitions: some View {
        VStack(alignment: .leading, spacing: 2) {
            let definitions = result.englishDefinitions.prefix(3)
            ForEach(Array(definitions.enumerated()), id: \.offset) { index, definition in
                HStack(alignment: .top, spacing: 4) {
                    Text("\(index + 1).")
                        .font(.caption)
                        .foregroundColor(.appSubtitle)
                        .fontWeight(.medium)

                    Text(definition)
                        .font(.body)
                        .foregroundColor(.appText)
                        .lineLimit(2)
                }
            }

            if result.englishDefinitions.count > 3 {
                Text("+ \(result.englishDefinitions.count - 3) more definitions")
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
            ForEach(result.jlpt, id: \.self) { level in
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
            ForEach(Array(Set(result.partsOfSpeech).prefix(3)), id: \.self) { pos in
                Text(pos)
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.appSurface1)
                    .foregroundColor(.appSubtitle)
                    .cornerRadius(4)
            }

            if Set(result.partsOfSpeech).count > 3 {
                Text("...")
                    .font(.caption)
                    .foregroundColor(.appSubtitle)
            }

            Spacer()
        }
    }
}
