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
                    OptionSection(title: "SHOW NOTES OF TYPE", icon: "music.note.list") {
                        VStack(spacing: 8) {
                            ForEach(Clef.allCases) { clef in
                                ClefToggleRow(clef: clef, isSelected: settings.selectedClefs.contains(clef)) {
                                    withAnimation(.spring(response: 0.3)) {
                                        if settings.selectedClefs.contains(clef) {
                                            settings.selectedClefs.remove(clef)
                                        } else {
                                            settings.selectedClefs.insert(clef)
                                        }
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

                    // Other Options
                    OptionSection(title: "OTHER OPTIONS", icon: "slider.horizontal.3") {
                        VStack(spacing: 0) {
                            ToggleRow(
                                title: "Sharp and Flat Notes",
                                icon: "number",
                                isOn: $settings.includeAccidentals
                            )

                            Divider()
                                .padding(.leading, 48)

                            ToggleRow(
                                title: "Sounds",
                                icon: "speaker.wave.2",
                                isOn: $settings.soundEnabled
                            )

                            Divider()
                                .padding(.leading, 48)

                            ToggleRow(
                                title: "Haptic",
                                icon: "hand.tap",
                                isOn: $settings.hapticFeedbackEnabled
                            )
                        }
                        .padding(.vertical, 8)
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
    let title: LocalizedStringKey
    let icon: String
    let content: Content

    init(title: LocalizedStringKey, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(Color(red: 0.91, green: 0.55, blue: 0.56))
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .tracking(1)
                    .foregroundColor(Color.appSubtitle)
            }
            .padding(.horizontal, 20)

            content
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.appMantle)
                        .shadow(color: Color.black.opacity(0.08), radius: 10, y: 5)
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
            HStack(spacing: 16) {
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22))
                    .foregroundColor(
                        isSelected
                            ? Color(red: 0.91, green: 0.55, blue: 0.56)
                            : Color.appSubtitle.opacity(0.4)
                    )

                Text(clef.rawValue)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(Color.appText)

                Spacer()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
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
}

struct DurationButton: View {
    let duration: GameDuration
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(duration.rawValue)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? Color.white : Color.appText)

                if isSelected {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 4, height: 4)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 14)
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
                    .shadow(
                        color: isSelected
                            ? Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.4)
                            : Color.clear,
                        radius: 8,
                        y: 4
                    )
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// ScaleButtonStyle for Options
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct ToggleRow: View {
    let title: LocalizedStringKey
    let icon: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color(red: 0.91, green: 0.55, blue: 0.56))
                .frame(width: 32)

            Text(title)
                .font(.system(size: 17, weight: .medium))
                .foregroundColor(Color.appText)

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(Color(red: 0.91, green: 0.55, blue: 0.56))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}
