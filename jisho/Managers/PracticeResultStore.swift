//
//  PracticeResultStore.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 13/10/25.
//

import Foundation

@MainActor
final class PracticeResultStore: ObservableObject {
    static let shared = PracticeResultStore()

    @Published private(set) var results: [SessionResult] = []

    private let fileURL: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        encoder.outputFormatting = [.prettyPrinted]
        decoder.dateDecodingStrategy = .iso8601
        encoder.dateEncodingStrategy = .iso8601

        if let documents = FileManager.default.urls(
            for: .documentDirectory, in: .userDomainMask
        ).first {
            fileURL = documents.appendingPathComponent("practice_results.json")
        } else {
            fileURL = URL(fileURLWithPath: NSTemporaryDirectory())
                .appendingPathComponent("practice_results.json")
        }

        load()
    }

    func add(_ result: SessionResult) {
        results.append(result)
        results.sort { $0.date < $1.date }
        save()
    }

    func clearAll() {
        results.removeAll()
        save()
    }

    private func load() {
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return }

        do {
            let data = try Data(contentsOf: fileURL)
            let decoded = try decoder.decode([SessionResult].self, from: data)
            results = decoded
        } catch {
            print("Failed to load practice results:", error)
            results = []
        }
    }

    private func save() {
        do {
            let data = try encoder.encode(results)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save practice results:", error)
        }
    }

    func recentResults(limit: Int = 12) -> [SessionResult] {
        Array(results.suffix(limit))
    }
}
