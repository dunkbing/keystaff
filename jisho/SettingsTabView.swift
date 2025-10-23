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
            VStack(spacing: 28) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Settings")
                            .font(.system(size: 34, weight: .bold))
                            .foregroundColor(Color.appText)
                    }
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 10)

                LanguageSetting()

                SettingsSection(title: "other_apps", icon: "app.badge") {
                    VStack(spacing: 0) {
                        Button {
                            let url =
                                "https://apps.apple.com/app/apple-store/id6746691565?pt=127348166&ct=keystaff&mt=8"
                            guard let appStoreURL = URL(string: url)
                            else { return }
                            UIApplication.shared.open(
                                appStoreURL, options: [:], completionHandler: nil)
                        } label: {
                            if let kanajiIcon = UIImage(named: "kanaji") {
                                SettingRowWithIcon(
                                    uiImage: kanajiIcon,
                                    color: Color.appAccent,
                                    title: "kanaji_title",
                                    showChevron: true
                                )
                            }
                        }
                        .buttonStyle(PlainButtonStyle())

                        Button {
                            let url =
                                "https://apps.apple.com/app/apple-store/id6727017255?pt=127348166&ct=keystaff&mt=8"
                            guard let appStoreURL = URL(string: url)
                            else { return }
                            UIApplication.shared.open(
                                appStoreURL, options: [:], completionHandler: nil)
                        } label: {
                            if let kanajiIcon = UIImage(named: "tikim") {
                                SettingRowWithIcon(
                                    uiImage: kanajiIcon,
                                    color: Color.appAccent,
                                    title: "tikim_title",
                                    showChevron: true
                                )
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.vertical, 8)
                }

                // About Section
                SettingsSection(title: "About", icon: "info.circle") {
                    VStack(spacing: 0) {
                        Button(action: {
                            showingAbout = true
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: "music.note")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(red: 0.91, green: 0.55, blue: 0.56))
                                    .frame(width: 36)

                                Text("About KeyStaff")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color.appText)

                                Spacer()

                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.appSubtitle)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                        .buttonStyle(PlainButtonStyle())

                        Divider()
                            .padding(.leading, 56)

                        HStack(spacing: 16) {
                            Image(systemName: "app.badge")
                                .font(.system(size: 20))
                                .foregroundColor(Color(red: 0.91, green: 0.55, blue: 0.56))
                                .frame(width: 36)

                            Text("Version")
                                .font(.system(size: 17, weight: .medium))
                                .foregroundColor(Color.appText)

                            Spacer()

                            Text("1.0.0")
                                .font(.system(size: 17))
                                .foregroundColor(Color.appSubtitle)
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)

                        Divider()
                            .padding(.leading, 56)

                        Link(destination: URL(string: "https://db99.dev")!) {
                            HStack(spacing: 16) {
                                Image(systemName: "person.circle")
                                    .font(.system(size: 20))
                                    .foregroundColor(Color(red: 0.91, green: 0.55, blue: 0.56))
                                    .frame(width: 36)

                                Text("Follow developer")
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(Color.appAccent)

                                Spacer()

                                Image(systemName: "arrow.up.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color.appAccent)
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 16)
                        }
                    }
                }

                Spacer()
                    .frame(height: 100)  // Extra padding for the tab bar
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
        .sheet(isPresented: $showingAbout) {
            AboutView()
        }
    }
}

struct SettingsSection<Content: View>: View {
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
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.91, green: 0.55, blue: 0.56))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color(red: 0.91, green: 0.55, blue: 0.56).opacity(0.15))
                    )

                Text(title)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color.appText)
            }
            .padding(.horizontal, 20)

            content
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.appMantle)
                        .shadow(color: Color.black.opacity(0.08), radius: 10, y: 5)
                )
        }
        .padding(.horizontal)
    }
}

struct SettingRow<Content: View>: View {
    let title: LocalizedStringKey
    let content: Content

    init(title: LocalizedStringKey, @ViewBuilder content: () -> Content) {
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
    let text: LocalizedStringKey

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
