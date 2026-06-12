//
//  LanguageManager.swift
//  TikimUI
//
//  Created by Bùi Đặng Bình on 20/4/25.
//

import SwiftUI

public enum Language: String, CaseIterable, Hashable, Identifiable {
    case english = "en"
    case vietnamese = "vi"

    public var id: String { self.rawValue }

    public var displayName: String {
        switch self {
        case .english:
            return "English"
        case .vietnamese:
            return "Tiếng Việt"
        }
    }

    public var icon: String {
        switch self {
        case .english:
            return "🇺🇸"
        case .vietnamese:
            return "🇻🇳"
        }
    }

    public var abbreviation: String {
        switch self {
        case .english:
            return "EN"
        case .vietnamese:
            return "VI"
        }
    }
}

@MainActor
public class LanguageManager: ObservableObject {
    public static let shared = LanguageManager()

    @Published public var selectedLanguage: Language {
        didSet {
            UserDefaults.standard.set(selectedLanguage.rawValue, forKey: "selectedLanguage")
            applyLanguage()
        }
    }

    public init() {
        let storedLanguageValue = UserDefaults.standard.string(forKey: "selectedLanguage")

        if let storedLanguageValue = storedLanguageValue,
           let language = Language(rawValue: storedLanguageValue)
        {
            self.selectedLanguage = language
        } else {
            let preferredLanguage = Locale.preferredLanguages.first ?? "en"
            if preferredLanguage.starts(with: "vi") {
                self.selectedLanguage = .vietnamese
            } else {
                self.selectedLanguage = .english
            }
            UserDefaults.standard.set(self.selectedLanguage.rawValue, forKey: "selectedLanguage")
        }

        applyLanguage()
    }

    private func applyLanguage() {
        // Force update UI by using NotificationCenter
        NotificationCenter.default.post(name: Notification.Name("LanguageChanged"), object: nil)

        // You could also set the app's bundle to a specific language bundle here if needed
        // For more advanced implementations
    }

    public func setLanguage(_ language: Language) {
        selectedLanguage = language
    }
}

public struct LanguageAwareModifier: ViewModifier {
    @ObservedObject private var languageManager = LanguageManager.shared

    public func body(content: Content) -> some View {
        content
            .environment(\.locale, Locale(identifier: languageManager.selectedLanguage.rawValue))
            .id("language-\(languageManager.selectedLanguage)")
    }
}

public extension View {
    func withLanguage() -> some View {
        self.modifier(LanguageAwareModifier())
    }
}

public struct LanguageSetting: View {
    @ObservedObject private var languageManager = LanguageManager.shared

    public init() {}

    public var body: some View {
        SettingsSection(title: "Language", icon: "character.bubble") {
            VStack(spacing: 16) {
                HStack(spacing: 20) {
                    ForEach(Language.allCases) { language in
                        LanguageButton(language: language)
                    }
                    Spacer()
                }
            }
            .padding()
        }
    }
}

public struct LanguageButton: View {
    @ObservedObject private var languageManager = LanguageManager.shared
    let language: Language

    public init(language: Language) {
        self.language = language
    }

    public var body: some View {
        let isSelected = languageManager.selectedLanguage == language

        Button(action: {
            languageManager.setLanguage(language)
        }) {
            VStack(spacing: 8) {
                Text(language.abbreviation)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(isSelected ? .white : Color.appText)
                    .frame(width: 40, height: 26)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(isSelected ? Color.appAccent : Color.appSurface2)
                    )

                Text(language.displayName)
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
        .buttonStyle(PlainButtonStyle())
    }
}
