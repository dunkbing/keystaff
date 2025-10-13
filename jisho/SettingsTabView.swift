//
//  SettingsTabView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 28/9/25.
//

import SwiftUI
import TikimUI

struct SettingsTabView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var showingAbout = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                HStack {
                    Text("Settings")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(Color.appText)
                    Spacer()
                }
                .padding(.horizontal)
                .padding(.top, 10)

                AppearanceSetting()
                LanguageSetting()

                // About Section
                SettingsSection(title: "About", icon: "info.circle") {
                    VStack(spacing: 16) {
                        Button(action: {
                            showingAbout = true
                        }) {
                            HStack {
                                Text("About KeyStaff")
                                    .foregroundColor(Color.appText)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color.appSubtitle)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())

                        HStack {
                            Text("Version")
                                .foregroundColor(Color.appText)
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(Color.appSubtitle)
                        }

                        Link(destination: URL(string: "https://db99.dev")!) {
                            HStack {
                                Text("Follow developer")
                                    .foregroundColor(Color.appAccent)
                                Spacer()
                                Image(systemName: "arrow.up.right.square")
                                    .foregroundColor(Color.appAccent)
                            }
                        }
                    }
                    .padding()
                }

                Spacer()
                    .frame(height: 100)  // Extra padding for the tab bar
            }
            .padding()
        }
        .background(Color.appBackground.ignoresSafeArea())
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content

    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color.appAccent)
                    .padding(8)
                    .background(Color.appAccent.opacity(0.1))
                    .clipShape(Circle())

                Text(title)
                    .font(.headline)
                    .foregroundColor(Color.appText)
            }
            .padding(.horizontal)

            content
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.appMantle)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.appAccent.opacity(0.15), lineWidth: 1)
                )
        }
        .padding(.horizontal)
    }
}

struct SettingRow<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.appSubtitle)

            content
        }
    }
}

struct ThemeButton: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: theme.icon)
                    .font(.system(size: 24))
                    .foregroundColor(isSelected ? Color.appAccent : Color.appText)

                Text(theme.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? Color.appAccent : Color.appText)
            }
            .frame(width: 80, height: 70)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        isSelected
                            ? Color.appAccent.opacity(0.1) : Color.appSurface2.opacity(0.5))
            )
        }
        .buttonStyle(BouncyButtonStyle())
    }
}

struct AboutView: View {
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // App Logo
                Image(systemName: "pianokeys")
                    .font(.system(size: 80))
                    .foregroundColor(Color.appAccent)
                    .padding(.top, 40)

                Text("KeyStaff")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.appText)

                Text("Version 1.0.0")
                    .foregroundColor(Color.appSubtitle)

                Divider()
                    .padding(.vertical)

                VStack(alignment: .leading, spacing: 20) {
                    Text(
                        "KeyStaff blends piano practice with note reading drills. Switch between clefs, answer from a piano keyboard, and keep tempo with the integrated metronome."
                    )
                    .foregroundColor(Color.appText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                    Text("Highlights")
                        .font(.headline)
                        .foregroundColor(Color.appText)
                        .padding(.horizontal)

                    FeatureRow(
                        icon: "music.note.list",
                        text: "Practice treble, bass, and alto clefs with instant feedback")
                    FeatureRow(
                        icon: "pianokeys",
                        text: "Answer using on-screen piano keys or letter notes with accidentals")
                    FeatureRow(
                        icon: "metronome.fill",
                        text: "Use the metronome with accents, time signatures, and visual beats")
                    FeatureRow(
                        icon: "chart.line.uptrend.xyaxis",
                        text: "Review session summaries with score history and accuracy charts")
                    FeatureRow(
                        icon: "paintpalette",
                        text: "Enjoy Catppuccin-inspired themes and customizable settings")
                }
                .padding()

                Spacer()

                Text("Crafted with ❤️ in SwiftUI")
                    .foregroundColor(Color.appSubtitle)
                    .padding(.bottom, 40)

                Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                }
                .padding(.horizontal, 30)
                .padding(.vertical, 12)
                .background(Color.appAccent)
                .foregroundColor(.white)
                .cornerRadius(16)
                .padding(.bottom, 30)
            }
        }
        .background(Color.appBackground.ignoresSafeArea())
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color.appAccent)
                .frame(width: 24, height: 24)

            Text(text)
                .foregroundColor(Color.appText)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
}
