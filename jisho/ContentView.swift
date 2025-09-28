//
//  ContentView.swift
//  jisho
//
//  Created by Bùi Đặng Bình on 28/9/25.
//

import SwiftUI
import TikimUI

struct ContentView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTab = 0
    @State private var previousTab = 0
    @State private var showTabBar = true

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationView {
                    Text("Search")
                        .environmentObject(themeManager)
                        .onAppear { showTabBar = true }
                        .navigationBarTitleDisplayMode(.inline)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tag(0)

                NavigationView {
                    Text("Bookmarks")
                        .environmentObject(themeManager)
                        .onAppear {
                            showTabBar = true
                        }
                        .navigationBarTitleDisplayMode(.inline)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tag(1)

                NavigationView {
                    SettingsTabView()
                        .onAppear { showTabBar = true }
                        .navigationBarTitleDisplayMode(.inline)
                }
                .navigationViewStyle(StackNavigationViewStyle())
                .tag(2)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .edgesIgnoringSafeArea(.bottom)

            // Custom Tab Bar - Only show when not in detail view
            if showTabBar {
                CustomTabBar(
                    selectedTab: $selectedTab,
                    items: [
                        (icon: "magnifyingglass", title: "Search"),
                        (icon: "book", title: "Bookmarks"),
                        (icon: "gear", title: "Settings"),
                    ]
                )
                .padding(.bottom, 4)
                .transition(.move(edge: .bottom))
                .animation(.easeInOut(duration: 0.3), value: showTabBar)
            }
        }
        .background(Color.appBackground)
        .onAppear {
            setupNavigationBarAppearance()
            setupTabBarVisibilityNotification()
        }
        .onChange(of: selectedTab) { newTab in
            showTabBar = true
            previousTab = newTab
        }
    }

    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color.appMantle)
        appearance.titleTextAttributes = [.foregroundColor: UIColor(Color.appText)]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor(Color.appText)]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().tintColor = UIColor(Color.appAccent)
    }

    private func setupTabBarVisibilityNotification() {
        NotificationCenter.default.addObserver(
            forName: NSNotification.Name("TabBarVisibility"),
            object: nil,
            queue: .main
        ) { notification in
            if let userInfo = notification.userInfo as? [String: Bool],
                let isVisible = userInfo["isVisible"]
            {
                withAnimation {
                    showTabBar = isVisible
                }
            }
        }
    }
}
