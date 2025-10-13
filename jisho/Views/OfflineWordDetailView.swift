//
//  OfflineWordDetailView.swift
//  jisho
//
//  Created by Claude on 28/9/25.
//

import SwiftUI
import TikimUI

struct OfflineWordDetailView: View {
    let slug: String
    @Environment(\.dismiss) private var dismiss
    @StateObject private var databaseService = OfflineDatabaseService.shared

    @State private var wordResult: WordResult?
    @State private var isLoading = true
    @State private var errorMessage: String?
    @State private var showingAlert = false

    var body: some View {
        Group {
            if isLoading {
                loadingView
            } else if let wordResult = wordResult {
                wordDetailContent(wordResult)
            } else {
                errorView
            }
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
        .task {
            await loadWordDetails()
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") {}
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.appAccent)

            Text("Loading...")
                .font(.subheadline)
                .foregroundColor(.appSubtitle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 50))
                .foregroundColor(.appSubtitle)

            Text("Word not found")
                .font(.headline)
                .foregroundColor(.appText)

            Text("This word could not be found in the database")
                .font(.subheadline)
                .foregroundColor(.appSubtitle)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private func wordDetailContent(_ wordResult: WordResult) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection(wordResult)

                if !wordResult.japaneseEntries.isEmpty {
                    japaneseSection(wordResult.japaneseEntries)
                }

                if !wordResult.senses.isEmpty {
                    sensesSection(wordResult.senses)
                }

                if !wordResult.tagsArray.isEmpty || !wordResult.jlptArray.isEmpty {
                    tagsAndLevelsSection(wordResult)
                }

                if let attribution = wordResult.attribution {
                    attributionSection(attribution)
                }
            }
            .padding()
        }
    }

    private func headerSection(_ wordResult: WordResult) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(wordResult.slug)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.appText)

                Spacer()

                if wordResult.isCommon {
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

    private func japaneseSection(_ japaneseEntries: [JapaneseEntry]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Japanese")
                .font(.headline)
                .foregroundColor(.appText)

            ForEach(japaneseEntries) { japanese in
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

    private func sensesSection(_ senses: [SenseWithLinks]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Definitions")
                .font(.headline)
                .foregroundColor(.appText)

            ForEach(Array(senses.enumerated()), id: \.offset) { index, senseWithLinks in
                senseRowView(sense: senseWithLinks.sense, links: senseWithLinks.links, index: index)
            }
        }
    }

    private func senseRowView(sense: DBSense, links: [DBSenseLink], index: Int) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            senseHeaderView(sense: sense, index: index)
            senseDefinitionsView(sense: sense)
            senseTagsView(sense: sense)
            senseInfoView(sense: sense)
            senseLinksView(links: links)
        }
        .padding()
        .background(Color.appSurface)
        .cornerRadius(8)
    }

    private func senseHeaderView(sense: DBSense, index: Int) -> some View {
        HStack {
            Text("\(index + 1)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.appAccent)

            if !sense.partsOfSpeechArray.isEmpty {
                Text(sense.partsOfSpeechArray.joined(separator: ", "))
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

    private func senseDefinitionsView(sense: DBSense) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            ForEach(sense.englishDefinitionsArray, id: \.self) { definition in
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
    private func senseTagsView(sense: DBSense) -> some View {
        if !sense.tagsArray.isEmpty {
            HStack {
                ForEach(sense.tagsArray, id: \.self) { tag in
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
    private func senseInfoView(sense: DBSense) -> some View {
        if !sense.infoArray.isEmpty {
            VStack(alignment: .leading, spacing: 2) {
                ForEach(sense.infoArray, id: \.self) { info in
                    Text("ℹ️ \(info)")
                        .font(.caption)
                        .foregroundColor(.appSubtitle)
                        .italic()
                }
            }
        }
    }

    @ViewBuilder
    private func senseLinksView(links: [DBSenseLink]) -> some View {
        if !links.isEmpty {
            VStack(alignment: .leading, spacing: 4) {
                ForEach(links) { link in
                    Link(destination: URL(string: link.url) ?? URL(string: "https://example.com")!)
                    {
                        Text(link.text)
                            .font(.caption)
                            .foregroundColor(.appAccent)
                            .underline()
                    }
                }
            }
        }
    }

    private func tagsAndLevelsSection(_ wordResult: WordResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Tags & Levels")
                .font(.headline)
                .foregroundColor(.appText)

            VStack(alignment: .leading, spacing: 8) {
                if !wordResult.jlptArray.isEmpty {
                    HStack {
                        Text("JLPT:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.appText)

                        ForEach(wordResult.jlptArray, id: \.self) { level in
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

                if !wordResult.tagsArray.isEmpty {
                    HStack {
                        Text("Tags:")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.appText)

                        ForEach(wordResult.tagsArray, id: \.self) { tag in
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

    private func attributionSection(_ attribution: DBAttribution) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Source")
                .font(.headline)
                .foregroundColor(.appText)

            VStack(alignment: .leading, spacing: 4) {
                if attribution.jmdict {
                    Text("• JMdict")
                        .font(.caption)
                        .foregroundColor(.appSubtitle)
                }

                if attribution.jmnedict {
                    Text("• JMnedict")
                        .font(.caption)
                        .foregroundColor(.appSubtitle)
                }

                if let dbpedia = attribution.dbpedia {
                    Text("• DBpedia: \(dbpedia)")
                        .font(.caption)
                        .foregroundColor(.appSubtitle)
                }
            }
            .padding()
            .background(Color.appSurface)
            .cornerRadius(8)
        }
    }

    private func loadWordDetails() async {
        do {
            let result = try await databaseService.getWordDetails(slug: slug)
            await MainActor.run {
                wordResult = result
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
                showingAlert = true
            }
        }
    }
}
