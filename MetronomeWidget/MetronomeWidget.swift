//
//  MetronomeWidget.swift
//  MetronomeWidget
//
//  Created by Bùi Đặng Bình on 28/10/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct MetronomeWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: MetronomeActivityAttributes.self) { context in
            // Lock screen/banner UI
            MetronomeLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    HStack(spacing: 4) {
                        Image(systemName: "metronome")
                            .font(.title3)
                            .foregroundColor(Color(red: 0.91, green: 0.55, blue: 0.56))

                        Text("\(Int(context.state.tempo))")
                            .font(.title2)
                            .fontWeight(.bold)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    Text("BPM")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack(spacing: 12) {
                        Text(context.state.timeSignature)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.secondary.opacity(0.2))
                            .cornerRadius(6)

                        Spacer()

                        // Beat indicators
                        BeatIndicatorRow(
                            currentBeat: context.state.currentBeat,
                            timeSignature: context.state.timeSignature,
                            isPlaying: context.state.isPlaying
                        )
                    }
                    .padding(.horizontal, 12)
                }
            } compactLeading: {
                // Compact leading (left side)
                Image(systemName: "metronome")
                    .foregroundColor(Color(red: 0.91, green: 0.55, blue: 0.56))
            } compactTrailing: {
                // Compact trailing (right side)
                Text("\(Int(context.state.tempo))")
                    .font(.caption)
                    .fontWeight(.bold)
            } minimal: {
                // Minimal presentation
                Image(systemName: context.state.isPlaying ? "metronome" : "metronome")
                    .foregroundColor(context.state.isPlaying ? Color(red: 0.91, green: 0.55, blue: 0.56) : .secondary)
            }
        }
    }
}

// MARK: - Lock Screen View
@available(iOS 16.1, *)
struct MetronomeLiveActivityView: View {
    let context: ActivityViewContext<MetronomeActivityAttributes>

    var body: some View {
        HStack(spacing: 16) {
            // Left: Play/Pause icon with BPM
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: context.state.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.title)
                        .foregroundColor(Color(red: 0.91, green: 0.55, blue: 0.56))

                    VStack(alignment: .leading, spacing: 0) {
                        Text("\(Int(context.state.tempo))")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("BPM")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Text(context.state.timeSignature)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(6)
            }

            Spacer()

            // Right: Beat indicators
            VStack(spacing: 8) {
                Text("Beat \(context.state.currentBeat + 1)")
                    .font(.caption)
                    .foregroundColor(.secondary)

                BeatIndicatorRow(
                    currentBeat: context.state.currentBeat,
                    timeSignature: context.state.timeSignature,
                    isPlaying: context.state.isPlaying
                )
            }
        }
        .padding(16)
    }
}

// MARK: - Beat Indicator Row
struct BeatIndicatorRow: View {
    let currentBeat: Int
    let timeSignature: String
    let isPlaying: Bool

    private var beatsPerMeasure: Int {
        // Parse time signature (e.g., "4/4" -> 4)
        if let numerator = timeSignature.split(separator: "/").first,
           let beats = Int(numerator) {
            return beats
        }
        return 4
    }

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<beatsPerMeasure, id: \.self) { beat in
                Circle()
                    .fill(isPlaying && beat == currentBeat
                        ? Color(red: 0.91, green: 0.55, blue: 0.56)
                        : Color.secondary.opacity(0.3))
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle()
                            .stroke(beat == 0 ? Color(red: 0.91, green: 0.55, blue: 0.56) : Color.clear, lineWidth: 1.5)
                    )
                    .scaleEffect(isPlaying && beat == currentBeat ? 1.3 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentBeat)
            }
        }
    }
}
