//
//  WordDetailView.swift
//  jisho
//
//  Created by Claude on 28/9/25.
//

import SwiftUI
import TikimUI

struct WordDetailView: View {
    let wordEntry: WordEntry
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection

                if !wordEntry.japanese.isEmpty {
                    japaneseSection
                }

                if !wordEntry.senses.isEmpty {
                    sensesSection
                }

                if !wordEntry.tags.isEmpty || !wordEntry.jlpt.isEmpty {
                    tagsAndLevelsSection
                }

                attributionSection
            }
            .padding()
        }
        .background(Color.appBackground)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .foregroundColor(.appAccent)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(wordEntry.slug)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.appText)

                Spacer()

                if wordEntry.isCommon {
                    Text("Common")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.appGreen)
                        .foregroundColor(.appBackground)
                        .cornerRadius(6)
                }
            }
        }
        .padding()
        .background(Color.appSurface)
        .cornerRadius(12)
    }

    private var japaneseSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Japanese")
                .font(.headline)
                .foregroundColor(.appText)

            ForEach(wordEntry.japanese) { japanese in
                HStack(spacing: 12) {
                    if let word = japanese.word {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Kanji")
                                .font(.caption)
                                .foregroundColor(.appSubtitle)
                            Text(word)
                                .font(.title2)
                                .fontWeight(.medium)
                                .foregroundColor(.appText)
                        }
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Reading")
                            .font(.caption)
                            .foregroundColor(.appSubtitle)
                        Text(japanese.reading)
                            .font(.title2)
                            .foregroundColor(.appAccent)
                    }

                    Spacer()
                }
                .padding()
                .background(Color.appSurface1)
                .cornerRadius(8)
            }
        }
    }

    private var sensesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Definitions")
                .font(.headline)
                .foregroundColor(.appText)

            ForEach(Array(wordEntry.senses.enumerated()), id: \.offset) { index, sense in
                senseRowView(sense: sense, index: index)
            }
        }
    }

    private func senseRowView(sense: Sense, index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            senseHeaderView(sense: sense, index: index)
            senseDefinitionsView(sense: sense)
            senseTagsView(sense: sense)
            senseInfoView(sense: sense)
        }
        .padding()
        .background(Color.appSurface)
        .cornerRadius(8)
    }

    private func senseHeaderView(sense: Sense, index: Int) -> some View {
        HStack {
            Text("\(index + 1)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.appAccent)

            if !sense.partsOfSpeech.isEmpty {
                Text(sense.partsOfSpeech.joined(separator: ", "))
                    .font(.caption)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.appSurface1)
                    .foregroundColor(.appSubtitle)
                    .cornerRadius(4)
            }

            Spacer()
        }
    }

    private func senseDefinitionsView(sense: Sense) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(sense.englishDefinitions, id: \.self) { definition in
                HStack(alignment: .top, spacing: 8) {
                    Text("•")
                        .foregroundColor(.appSubtitle)
                    Text(definition)
                        .foregroundColor(.appText)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    @ViewBuilder
    private func senseTagsView(sense: Sense) -> some View {
        if !sense.tags.isEmpty {
            HStack {
                ForEach(sense.tags, id: \.self) { tag in
                    Text(tag)
                        .font(.caption2)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(Color.appYellow)
                        .foregroundColor(.appBackground)
                        .cornerRadius(3)
                }
            }
        }
    }

    @ViewBuilder
    private func senseInfoView(sense: Sense) -> some View {
        if !sense.info.isEmpty {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(sense.info, id: \.self) { info in
                    Text("ℹ️ \(info)")
                        .font(.caption)
                        .foregroundColor(.appSubtitle)
                        .italic()
                }
            }
        }
    }

    private var tagsAndLevelsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags & Levels")
                .font(.headline)
                .foregroundColor(.appText)

            VStack(alignment: .leading, spacing: 8) {
                if !wordEntry.jlpt.isEmpty {
                    HStack {
                        Text("JLPT:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.appText)

                        ForEach(wordEntry.jlpt, id: \.self) { level in
                            Text(level.uppercased())
                                .font(.caption)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.appAccent)
                                .foregroundColor(.appBackground)
                                .cornerRadius(4)
                        }
                    }
                }

                if !wordEntry.tags.isEmpty {
                    HStack {
                        Text("Tags:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.appText)

                        ForEach(wordEntry.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.appSecondaryAccent)
                                .foregroundColor(.appBackground)
                                .cornerRadius(4)
                        }
                    }
                }
            }
            .padding()
            .background(Color.appSurface)
            .cornerRadius(8)
        }
    }

    private var attributionSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Source")
                .font(.headline)
                .foregroundColor(.appText)

            VStack(alignment: .leading, spacing: 4) {
                if wordEntry.attribution.jmdict {
                    Text("• JMdict")
                        .font(.caption)
                        .foregroundColor(.appSubtitle)
                }

                if wordEntry.attribution.jmnedict {
                    Text("• JMnedict")
                        .font(.caption)
                        .foregroundColor(.appSubtitle)
                }

                if let dbpedia = wordEntry.attribution.dbpedia {
                    Text("• DBpedia: \(String(describing: dbpedia.value))")
                        .font(.caption)
                        .foregroundColor(.appSubtitle)
                }
            }
            .padding()
            .background(Color.appSurface)
            .cornerRadius(8)
        }
    }
}
