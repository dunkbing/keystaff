//
//  JishoModels.swift
//  jisho
//
//  Created by Claude on 28/9/25.
//

import Foundation

// Helper type for mixed arrays that can contain different types
struct AnyCodable: Codable {
    let value: Any

    init<T>(_ value: T?) {
        self.value = value ?? ()
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if container.decodeNil() {
            value = ()
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Unsupported type"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()

        switch value {
        case is Void:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [AnyCodable]:
            try container.encode(array)
        case let dictionary as [String: AnyCodable]:
            try container.encode(dictionary)
        default:
            throw EncodingError.invalidValue(
                value,
                EncodingError.Context(
                    codingPath: encoder.codingPath,
                    debugDescription: "Unsupported type"
                )
            )
        }
    }
}

struct JishoResponse: Codable {
    let meta: Meta
    let data: [WordEntry]
}

struct Meta: Codable {
    let status: Int
}

struct WordEntry: Codable, Identifiable {
    let id = UUID()
    let slug: String
    let isCommon: Bool
    let tags: [String]
    let jlpt: [String]
    let japanese: [Japanese]
    let senses: [Sense]
    let attribution: Attribution

    private enum CodingKeys: String, CodingKey {
        case slug
        case isCommon = "is_common"
        case tags
        case jlpt
        case japanese
        case senses
        case attribution
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        slug = try container.decode(String.self, forKey: .slug)
        isCommon = try container.decodeIfPresent(Bool.self, forKey: .isCommon) ?? false
        tags = try container.decode([String].self, forKey: .tags)
        jlpt = try container.decode([String].self, forKey: .jlpt)
        japanese = try container.decode([Japanese].self, forKey: .japanese)
        senses = try container.decode([Sense].self, forKey: .senses)
        attribution = try container.decode(Attribution.self, forKey: .attribution)
    }
}

struct Japanese: Codable, Identifiable {
    let id = UUID()
    let word: String?
    let reading: String

    private enum CodingKeys: String, CodingKey {
        case word
        case reading
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        word = try container.decodeIfPresent(String.self, forKey: .word)
        reading = try container.decodeIfPresent(String.self, forKey: .reading) ?? word ?? ""
    }
}

struct Sense: Codable, Identifiable {
    let id = UUID()
    let englishDefinitions: [String]
    let partsOfSpeech: [String]
    let links: [SenseLink]
    let tags: [String]
    let restrictions: [AnyCodable]
    let seeAlso: [String]
    let antonyms: [AnyCodable]
    let source: [AnyCodable]
    let info: [String]
    let sentences: [AnyCodable]?

    private enum CodingKeys: String, CodingKey {
        case englishDefinitions = "english_definitions"
        case partsOfSpeech = "parts_of_speech"
        case links
        case tags
        case restrictions
        case seeAlso = "see_also"
        case antonyms
        case source
        case info
        case sentences
    }
}

struct SenseLink: Codable, Identifiable {
    let id = UUID()
    let text: String
    let url: String

    private enum CodingKeys: String, CodingKey {
        case text
        case url
    }
}

struct Attribution: Codable {
    let jmdict: Bool
    let jmnedict: Bool
    let dbpedia: AnyCodable?
}
