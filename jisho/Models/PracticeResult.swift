//
//  PracticeResult.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 13/10/25.
//

import Foundation

struct SessionResult: Identifiable, Codable {
    let id: UUID
    let date: Date
    let duration: TimeInterval
    let score: Int
    let correctAttempts: Int
    let totalAttempts: Int

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        duration: TimeInterval,
        score: Int,
        correctAttempts: Int,
        totalAttempts: Int
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.score = score
        self.correctAttempts = correctAttempts
        self.totalAttempts = totalAttempts
    }

    var accuracy: Double {
        guard totalAttempts > 0 else { return 0 }
        return Double(correctAttempts) / Double(totalAttempts)
    }

    var accuracyPercentage: Double {
        accuracy * 100
    }
}
