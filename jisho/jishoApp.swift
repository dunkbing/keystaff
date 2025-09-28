//
//  jishoApp.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 28/9/25.
//

import SwiftUI
import TikimUI

@main
struct jishoApp: App {
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var languageManager = LanguageManager.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(themeManager)
                .environmentObject(languageManager)
                .preferredColorScheme(themeManager.colorScheme)
                .withTheming()
                .withLanguage()
        }
    }
}
