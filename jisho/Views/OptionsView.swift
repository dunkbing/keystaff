//
//  OptionsView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 28/9/25.
//

import SwiftUI
import TikimUI

struct OptionsView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var settings: GameSettings

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Clef Selection
                    OptionSection(title: "SHOW NOTES OF TYPE") {
                        VStack(spacing: 12) {
                            ForEach(Clef.allCases) { clef in
                                ClefToggleRow(clef: clef, isSelected: settings.selectedClefs.contains(clef)) {
                                    if settings.selectedClefs.contains(clef) {
                                        settings.selectedClefs.remove(clef)
                                    } else {
                                        settings.selectedClefs.insert(clef)
                                    }
                                }
                            }
                        }
                    }

                    // Duration Selection
                    OptionSection(title: "DURATION") {
                        HStack(spacing: 12) {
                            ForEach(GameDuration.allCases) { duration in
                                DurationButton(
                                    duration: duration,
                                    isSelected: settings.duration == duration
                                ) {
                                    settings.duration = duration
                                }
                            }
                        }
                        .padding()

                        if settings.duration == .infinite {
                            Text("Your score won't be counted for stats when duration is set to ∞ (practice mode).")
                                .font(.caption)
                                .foregroundColor(Color.appSubtitle)
                                .padding(.horizontal)
                                .padding(.bottom, 12)
                        }
                    }

                    // Other Options
                    OptionSection(title: "OTHER OPTIONS") {
                        VStack(spacing: 16) {
                            ToggleRow(
                                title: "Sharp and Flat Notes",
                                isOn: $settings.includeAccidentals
                            )

                            ToggleRow(
                                title: "Sounds",
                                isOn: $settings.soundEnabled
                            )

                            ToggleRow(
                                title: "Haptic",
                                isOn: $settings.hapticFeedbackEnabled
                            )
                        }
                        .padding()
                    }

                    Spacer()
                        .frame(height: 40)
                }
                .padding()
            }
            .background(Color.appBackground.ignoresSafeArea())
            .navigationTitle("Options")
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

struct OptionSection<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(Color.appSubtitle)
                .padding(.horizontal)

            content
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.appMantle)
                )
        }
    }
}

struct ClefToggleRow: View {
    let clef: Clef
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(clef.rawValue)
                    .font(.body)
                    .foregroundColor(Color.appText)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(Color.appSubtitle)
            }
            .padding()
            .background(
                isSelected
                    ? Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.1) : Color.clear
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct DurationButton: View {
    let duration: GameDuration
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(duration.rawValue)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isSelected ? Color.white : Color.appText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            isSelected
                                ? Color(red: 0.91, green: 0.55, blue: 0.56) : Color.appSurface2
                                    .opacity(0.5)
                        )
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(Color.appText)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(red: 0.91, green: 0.55, blue: 0.56))
        }
    }
}

#Preview {
    OptionsView()
        .environmentObject(GameSettings.shared)
}
