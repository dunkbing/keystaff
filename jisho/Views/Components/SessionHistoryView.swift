//
//  SessionHistoryView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 13/10/25.
//

import SwiftUI

struct SessionHistoryView: View {
    let results: [SessionResult]
    let onClose: () -> Void

    var body: some View {
        NavigationView {
            List {
                if results.isEmpty {
                    Text("No history yet. Complete a session to view past results.")
                        .foregroundColor(Color.appSubtitle)
                } else {
                    ForEach(results.reversed()) { result in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(result.date, style: .date)
                                Text(result.date, style: .time)
                            }
                            .font(.footnote)
                            .foregroundColor(Color.appSubtitle)

                            HStack(spacing: 16) {
                                HistoryStat(label: "Score", value: "\(result.score)")
                                HistoryStat(
                                    label: "Accuracy",
                                    value: String(format: "%.0f%%", result.accuracyPercentage)
                                )
                                HistoryStat(
                                    label: "Duration",
                                    value: formatted(duration: result.duration)
                                )
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Session History")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        onClose()
                    }
                }
            }
        }
    }

    private func formatted(duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

private struct HistoryStat: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased())
                .font(.caption2)
                .foregroundColor(Color.appSubtitle)
            Text(value)
                .font(.headline)
                .foregroundColor(Color.appText)
        }
    }
}
