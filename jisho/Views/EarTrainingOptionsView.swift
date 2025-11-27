//
//  EarTrainingOptionsView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 27/11/25.
//

import SwiftUI
import TikimUI

struct EarTrainingOptionsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settings: EarTrainingSettings

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Difficulty Selection
                    OptionSection(title: "DIFFICULTY", icon: "chart.bar.fill") {
                        VStack(spacing: 8) {
                            ForEach(EarTrainingDifficulty.allCases) { difficulty in
                                DifficultyToggleRow(
                                    difficulty: difficulty,
                                    isSelected: settings.difficulty == difficulty
                                ) {
                                    withAnimation(.spring(response: 0.3)) {
                                        settings.difficulty = difficulty
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 8)
                    }

                    // Duration Selection
                    OptionSection(title: "DURATION", icon: "clock") {
                        VStack(spacing: 16) {
                            HStack(spacing: 12) {
                                ForEach(GameDuration.allCases) { duration in
                                    DurationButton(
                                        duration: duration,
                                        isSelected: settings.duration == duration
                                    ) {
                                        withAnimation(.spring(response: 0.3)) {
                                            settings.duration = duration
                                        }
                                    }
                                }
                            }

                            if settings.duration == .infinite {
                                HStack(spacing: 8) {
                                    Image(systemName: "info.circle")
                                        .font(.system(size: 12))
                                    Text("Your score won't be counted for stats when duration is set to ∞ (practice mode).")
                                        .font(.caption)
                                }
                                .foregroundColor(Color.appSubtitle)
                            }
                        }
                        .padding()
                    }

                    // Playback Speed
                    OptionSection(title: "PLAYBACK SPEED", icon: "speedometer") {
                        VStack(spacing: 16) {
                            HStack(spacing: 12) {
                                ForEach([0.5, 0.75, 1.0, 1.25, 1.5], id: \.self) { speed in
                                    PlaybackSpeedButton(
                                        speed: speed,
                                        isSelected: settings.playbackSpeed == speed
                                    ) {
                                        withAnimation(.spring(response: 0.3)) {
                                            settings.playbackSpeed = speed
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                    }

                    // Other Options
                    OptionSection(title: "OTHER OPTIONS", icon: "slider.horizontal.3") {
                        VStack(spacing: 0) {
                            ToggleRow(
                                title: "Include Accidentals",
                                icon: "number",
                                isOn: $settings.includeAccidentals
                            )

                            Divider()
                                .padding(.leading, 48)

                            ToggleRow(
                                title: "Show Visual Hint",
                                icon: "eye",
                                isOn: $settings.showVisualHint
                            )

                            Divider()
                                .padding(.leading, 48)

                            ToggleRow(
                                title: "Auto Replay",
                                icon: "repeat",
                                isOn: $settings.autoReplay
                            )
                        }
                        .padding(.vertical, 8)
                    }

                    // Interval Info (shown when interval exercise type is selected)
                    if settings.exerciseType == .interval {
                        OptionSection(title: "INTERVALS INCLUDED", icon: "arrow.left.and.right") {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(settings.difficulty.intervals) { interval in
                                    HStack(spacing: 12) {
                                        Text(interval.shortName)
                                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                                            .foregroundColor(Color(red: 0.91, green: 0.55, blue: 0.56))
                                            .frame(width: 32)

                                        Text(interval.displayName)
                                            .font(.system(size: 15, weight: .medium))
                                            .foregroundColor(Color.appText)

                                        Spacer()
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                    }

                    Spacer()
                        .frame(height: 40)
                }
                .padding()
            }
            .background(
                LinearGradient(
                    colors: [
                        Color.appBackground,
                        Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.03)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
            )
            .navigationTitle("Ear Training Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(Color(red: 0.91, green: 0.55, blue: 0.56))
                }
            }
        }
    }
}

// MARK: - Difficulty Toggle Row
struct DifficultyToggleRow: View {
    let difficulty: EarTrainingDifficulty
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(
                        isSelected
                            ? Color(red: 0.91, green: 0.55, blue: 0.56)
                            : Color.appSubtitle.opacity(0.4)
                    )

                VStack(alignment: .leading, spacing: 4) {
                    Text(difficulty.rawValue)
                        .font(.system(size: 17, weight: .medium))
                        .foregroundColor(Color.appText)

                    Text(difficultyDescription(for: difficulty))
                        .font(.system(size: 12))
                        .foregroundColor(Color.appSubtitle)
                }

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected
                            ? Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.1)
                            : Color.clear
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }

    private func difficultyDescription(for difficulty: EarTrainingDifficulty) -> String {
        switch difficulty {
        case .beginner:
            return "Basic intervals, limited range"
        case .intermediate:
            return "More intervals, wider range"
        case .advanced:
            return "All intervals, full range"
        }
    }
}

// MARK: - Playback Speed Button
struct PlaybackSpeedButton: View {
    let speed: Double
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(speedLabel)
                .font(.system(size: 14, weight: .bold, design: .rounded))
                .foregroundColor(isSelected ? Color.white : Color.appText)
                .frame(maxWidth: .infinity)
                .frame(height: 44)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            isSelected
                                ? LinearGradient(
                                    colors: [
                                        Color(red: 0.91, green: 0.55, blue: 0.56),
                                        Color(red: 0.85, green: 0.45, blue: 0.46)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                                : LinearGradient(
                                    colors: [Color.appSurface2, Color.appSurface2],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                        )
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    private var speedLabel: String {
        if speed == 1.0 {
            return "1x"
        } else if speed < 1.0 {
            return String(format: "%.1fx", speed)
        } else {
            return String(format: "%.1fx", speed)
        }
    }
}
