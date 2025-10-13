//
//  OfflineModels.swift
//  jisho
//
//  Created by Claude on 28/9/25.
//

import Foundation
import GRDB

// MARK: - Database Models for GRDB

struct Word: Codable, FetchableRecord, PersistableRecord, Identifiable {
    var id: Int64?
    let slug: String
    let isCommon: Bool
    let tags: String  // JSON encoded
    let jlpt: String  // JSON encoded
    let createdAt: Date
    let updatedAt: Date

    // Computed properties for convenience
    var tagsArray: [String] {
        (try? JSONDecoder().decode([String].self, from: tags.data(using: .utf8) ?? Data())) ?? []
    }

    var jlptArray: [String] {
        (try? JSONDecoder().decode([String].self, from: jlpt.data(using: .utf8) ?? Data())) ?? []
    }

    private enum CodingKeys: String, CodingKey {
        case id, slug
        case isCommon = "is_common"
        case tags, jlpt
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    static let databaseTableName = "words"

    // Associations
    static let japaneseEntries = hasMany(JapaneseEntry.self)
    static let senses = hasMany(DBSense.self)
    static let attributions = hasMany(DBAttribution.self)
}

struct JapaneseEntry: Codable, FetchableRecord, PersistableRecord, Identifiable {
    var id: Int64?
    let wordId: Int64
    let word: String?
    let reading: String

    private enum CodingKeys: String, CodingKey {
        case id
        case wordId = "word_id"
        case word, reading
    }

    static let databaseTableName = "japanese_entries"

    // Associations
    static let word = belongsTo(Word.self)
}

struct DBSense: Codable, FetchableRecord, PersistableRecord, Identifiable {
    var id: Int64?
    let wordId: Int64
    let englishDefinitions: String  // JSON encoded
    let partsOfSpeech: String  // JSON encoded
    let tags: String  // JSON encoded
    let info: String  // JSON encoded
    let seeAlso: String  // JSON encoded

    // Computed properties for convenience
    var englishDefinitionsArray: [String] {
        (try? JSONDecoder().decode(
            [String].self, from: englishDefinitions.data(using: .utf8) ?? Data())) ?? []
    }

    var partsOfSpeechArray: [String] {
        (try? JSONDecoder().decode([String].self, from: partsOfSpeech.data(using: .utf8) ?? Data()))
            ?? []
    }

    var tagsArray: [String] {
        (try? JSONDecoder().decode([String].self, from: tags.data(using: .utf8) ?? Data())) ?? []
    }

    var infoArray: [String] {
        (try? JSONDecoder().decode([String].self, from: info.data(using: .utf8) ?? Data())) ?? []
    }

    var seeAlsoArray: [String] {
        (try? JSONDecoder().decode([String].self, from: seeAlso.data(using: .utf8) ?? Data())) ?? []
    }

    private enum CodingKeys: String, CodingKey {
        case id
        case wordId = "word_id"
        case englishDefinitions = "english_definitions"
        case partsOfSpeech = "parts_of_speech"
        case tags, info
        case seeAlso = "see_also"
    }

    static let databaseTableName = "senses"

    // Associations
    static let word = belongsTo(Word.self)
    static let links = hasMany(DBSenseLink.self)
}

struct DBSenseLink: Codable, FetchableRecord, PersistableRecord, Identifiable {
    var id: Int64?
    let senseId: Int64
    let text: String
    let url: String

    private enum CodingKeys: String, CodingKey {
        case id
        case senseId = "sense_id"
        case text, url
    }

    static let databaseTableName = "sense_links"

    // Associations
    static let sense = belongsTo(DBSense.self)
}

struct DBAttribution: Codable, FetchableRecord, PersistableRecord, Identifiable {
    var id: Int64?
    let wordId: Int64
    let jmdict: Bool
    let jmnedict: Bool
    let dbpedia: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case wordId = "word_id"
        case jmdict, jmnedict, dbpedia
    }

    static let databaseTableName = "attributions"

    // Associations
    static let word = belongsTo(Word.self)
}

// MARK: - Combined Models for UI

struct WordResult: Identifiable {
    let id: Int64
    let slug: String
    let isCommon: Bool
    let tagsArray: [String]
    let jlptArray: [String]
    let japaneseEntries: [JapaneseEntry]
    let senses: [SenseWithLinks]
    let attribution: DBAttribution?

    init(
        word: Word, japaneseEntries: [JapaneseEntry], senses: [SenseWithLinks],
        attribution: DBAttribution?
    ) {
        self.id = word.id ?? 0
        self.slug = word.slug
        self.isCommon = word.isCommon
        self.tagsArray = word.tagsArray
        self.jlptArray = word.jlptArray
        self.japaneseEntries = japaneseEntries
        self.senses = senses
        self.attribution = attribution
    }
}

struct SenseWithLinks {
    let sense: DBSense
    let links: [DBSenseLink]

    init(sense: DBSense, links: [DBSenseLink]) {
        self.sense = sense
        self.links = links
    }
}

// MARK: - Search Result Model

struct SearchResult: Identifiable {
    let id: Int64
    let slug: String
    let isCommon: Bool
    let word: String?
    let reading: String
    let englishDefinitions: [String]
    let partsOfSpeech: [String]
    let jlpt: [String]

    init(word: Word, japaneseEntry: JapaneseEntry, sense: DBSense) {
        self.id = word.id ?? 0
        self.slug = word.slug
        self.isCommon = word.isCommon
        self.word = japaneseEntry.word
        self.reading = japaneseEntry.reading
        self.englishDefinitions = sense.englishDefinitionsArray
        self.partsOfSpeech = sense.partsOfSpeechArray
        self.jlpt = word.jlptArray
    }
}
