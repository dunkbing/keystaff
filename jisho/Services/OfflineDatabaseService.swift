//
//  OfflineDatabaseService.swift
//  jisho
//
//  Created by Claude on 28/9/25.
//

import Combine
import Foundation
import GRDB

class OfflineDatabaseService: ObservableObject {
    static let shared = OfflineDatabaseService()

    private var dbQueue: DatabaseQueue!

    private init() {
        setupDatabase()
    }

    private func setupDatabase() {
        do {
            // Try to copy database from bundle to documents directory
            let documentsPath = FileManager.default.urls(
                for: .documentDirectory, in: .userDomainMask
            ).first!
            let databaseURL = documentsPath.appendingPathComponent("jisho_offline.db")

            // Check if database exists in documents directory
            if !FileManager.default.fileExists(atPath: databaseURL.path) {
                // Copy from bundle
                if let bundleDatabaseURL = Bundle.main.url(
                    forResource: "jisho_offline", withExtension: "db")
                {
                    try FileManager.default.copyItem(at: bundleDatabaseURL, to: databaseURL)
                    print("✅ Database copied from bundle to documents directory")
                } else {
                    print("❌ Database file not found in bundle")
                    // Create empty database as fallback
                    dbQueue = try DatabaseQueue(path: databaseURL.path)
                    return
                }
            }

            dbQueue = try DatabaseQueue(path: databaseURL.path)
            print("✅ Database initialized successfully")

        } catch {
            print("❌ Database initialization failed: \(error)")
            fatalError("Could not initialize database: \(error)")
        }
    }

    // MARK: - Search Methods

    func searchWords(query: String, limit: Int = 20) async throws -> [SearchResult] {
        return try await dbQueue.read { db in
            let searchQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)

            if searchQuery.isEmpty {
                return []
            }

            // Use FTS5 for full-text search
            let sql = """
                    SELECT
                        w.id, w.slug, w.is_common, w.jlpt,
                        j.word, j.reading,
                        s.english_definitions, s.parts_of_speech
                    FROM words_fts fts
                    JOIN words w ON w.id = fts.rowid
                    JOIN japanese_entries j ON w.id = j.word_id
                    JOIN senses s ON w.id = s.word_id
                    WHERE words_fts MATCH ?
                    ORDER BY
                        w.is_common DESC,
                        CASE
                            WHEN j.word = ? THEN 1
                            WHEN j.reading = ? THEN 2
                            WHEN j.word LIKE ? || '%' THEN 3
                            WHEN j.reading LIKE ? || '%' THEN 4
                            ELSE 5
                        END,
                        LENGTH(j.reading)
                    LIMIT ?
                """

            let rows = try Row.fetchAll(
                db, sql: sql,
                arguments: [
                    searchQuery, searchQuery, searchQuery,
                    searchQuery + "%", searchQuery + "%",
                    limit,
                ])

            return rows.compactMap { row in
                // Create Word object
                let word = Word(
                    id: row["id"],
                    slug: row["slug"],
                    isCommon: row["is_common"],
                    tags: "[]",  // We'll get this later if needed
                    jlpt: row["jlpt"],
                    createdAt: Date(),
                    updatedAt: Date()
                )

                // Create JapaneseEntry object
                let japaneseEntry = JapaneseEntry(
                    id: nil,
                    wordId: row["id"],
                    word: row["word"],
                    reading: row["reading"]
                )

                // Create Sense object
                let sense = DBSense(
                    id: nil,
                    wordId: row["id"],
                    englishDefinitions: row["english_definitions"],
                    partsOfSpeech: row["parts_of_speech"],
                    tags: "[]",
                    info: "[]",
                    seeAlso: "[]"
                )

                return SearchResult(word: word, japaneseEntry: japaneseEntry, sense: sense)
            }
        }
    }

    func getWordDetails(slug: String) async throws -> WordResult? {
        return try await dbQueue.read { db in
            // Get the word
            guard
                let word = try Word.fetchOne(
                    db, sql: "SELECT * FROM words WHERE slug = ?", arguments: [slug])
            else {
                return nil
            }

            guard let wordId = word.id else { return nil }

            // Get Japanese entries
            let japaneseEntries = try JapaneseEntry.fetchAll(
                db, sql: "SELECT * FROM japanese_entries WHERE word_id = ?", arguments: [wordId])

            // Get senses with their links
            let senses = try DBSense.fetchAll(
                db, sql: "SELECT * FROM senses WHERE word_id = ?", arguments: [wordId])
            let sensesWithLinks = try senses.map { sense in
                let links = try DBSenseLink.fetchAll(
                    db, sql: "SELECT * FROM sense_links WHERE sense_id = ?", arguments: [sense.id])
                return SenseWithLinks(sense: sense, links: links)
            }

            // Get attribution
            let attribution = try DBAttribution.fetchOne(
                db, sql: "SELECT * FROM attributions WHERE word_id = ?", arguments: [wordId])

            return WordResult(
                word: word,
                japaneseEntries: japaneseEntries,
                senses: sensesWithLinks,
                attribution: attribution
            )
        }
    }

    // MARK: - Filter Methods

    func searchWordsByJLPT(level: String, limit: Int = 50) async throws -> [SearchResult] {
        return try await dbQueue.read { db in
            let sql = """
                    SELECT
                        w.id, w.slug, w.is_common, w.jlpt,
                        j.word, j.reading,
                        s.english_definitions, s.parts_of_speech
                    FROM words w
                    JOIN japanese_entries j ON w.id = j.word_id
                    JOIN senses s ON w.id = s.word_id
                    WHERE w.jlpt LIKE ?
                    ORDER BY w.is_common DESC, LENGTH(j.reading)
                    LIMIT ?
                """

            let rows = try Row.fetchAll(db, sql: sql, arguments: ["%\(level)%", limit])

            return rows.compactMap { row in
                let word = Word(
                    id: row["id"],
                    slug: row["slug"],
                    isCommon: row["is_common"],
                    tags: "[]",
                    jlpt: row["jlpt"],
                    createdAt: Date(),
                    updatedAt: Date()
                )

                let japaneseEntry = JapaneseEntry(
                    id: nil,
                    wordId: row["id"],
                    word: row["word"],
                    reading: row["reading"]
                )

                let sense = DBSense(
                    id: nil,
                    wordId: row["id"],
                    englishDefinitions: row["english_definitions"],
                    partsOfSpeech: row["parts_of_speech"],
                    tags: "[]",
                    info: "[]",
                    seeAlso: "[]"
                )

                return SearchResult(word: word, japaneseEntry: japaneseEntry, sense: sense)
            }
        }
    }

    func getCommonWords(limit: Int = 100) async throws -> [SearchResult] {
        return try await dbQueue.read { db in
            let sql = """
                    SELECT
                        w.id, w.slug, w.is_common, w.jlpt,
                        j.word, j.reading,
                        s.english_definitions, s.parts_of_speech
                    FROM words w
                    JOIN japanese_entries j ON w.id = j.word_id
                    JOIN senses s ON w.id = s.word_id
                    WHERE w.is_common = 1
                    ORDER BY LENGTH(j.reading)
                    LIMIT ?
                """

            let rows = try Row.fetchAll(db, sql: sql, arguments: [limit])

            return rows.compactMap { row in
                let word = Word(
                    id: row["id"],
                    slug: row["slug"],
                    isCommon: row["is_common"],
                    tags: "[]",
                    jlpt: row["jlpt"],
                    createdAt: Date(),
                    updatedAt: Date()
                )

                let japaneseEntry = JapaneseEntry(
                    id: nil,
                    wordId: row["id"],
                    word: row["word"],
                    reading: row["reading"]
                )

                let sense = DBSense(
                    id: nil,
                    wordId: row["id"],
                    englishDefinitions: row["english_definitions"],
                    partsOfSpeech: row["parts_of_speech"],
                    tags: "[]",
                    info: "[]",
                    seeAlso: "[]"
                )

                return SearchResult(word: word, japaneseEntry: japaneseEntry, sense: sense)
            }
        }
    }

    // MARK: - Statistics

    func getDatabaseStats() async throws -> (totalWords: Int, commonWords: Int, jlptWords: Int) {
        return try await dbQueue.read { db in
            let totalWords = try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM words") ?? 0
            let commonWords =
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM words WHERE is_common = 1") ?? 0
            let jlptWords =
                try Int.fetchOne(db, sql: "SELECT COUNT(*) FROM words WHERE jlpt != '[]'") ?? 0

            return (totalWords, commonWords, jlptWords)
        }
    }
}
