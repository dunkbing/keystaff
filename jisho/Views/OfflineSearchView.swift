//
//  OfflineSearchView.swift
//  jisho
//
//  Created by Claude on 28/9/25.
//

import SwiftUI
import TikimUI

struct OfflineSearchView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var databaseService = OfflineDatabaseService.shared

    @State private var searchText = ""
    @State private var searchResults: [SearchResult] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingAlert = false
    @State private var databaseStats: (totalWords: Int, commonWords: Int, jlptWords: Int) = (
        0, 0, 0
    )

    private let searchDebounceTime: TimeInterval = 0.3
    @State private var searchWorkItem: DispatchWorkItem?

    var body: some View {
        VStack(spacing: 0) {
            searchHeader

            if isLoading {
                loadingView
            } else if searchResults.isEmpty && !searchText.isEmpty {
                emptyStateView
            } else if searchText.isEmpty {
                welcomeView
            } else {
                searchResultsList
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Dictionary")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await loadDatabaseStats()
        }
        .alert("Error", isPresented: $showingAlert) {
            Button("OK") {}
        } message: {
            Text(errorMessage ?? "An unknown error occurred")
        }
    }

    private var searchHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.appSubtitle)

                TextField("Search Japanese words...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .font(.body)
                    .foregroundColor(.appText)
                    .onChange(of: searchText) { newValue in
                        debounceSearch(newValue)
                    }
                    .onSubmit {
                        performSearch()
                    }

                if !searchText.isEmpty {
                    Button(action: clearSearch) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.appSubtitle)
                    }
                }
            }
            .padding()
            .background(Color.appSurface)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.appAccent, lineWidth: 1)
            )
        }
        .padding(.horizontal)
        .padding(.top, 24)
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.2)
                .tint(.appAccent)

            Text("Searching...")
                .font(.subheadline)
                .foregroundColor(.appSubtitle)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 50))
                .foregroundColor(.appSubtitle)

            Text("No results found")
                .font(.headline)
                .foregroundColor(.appText)

            Text("Try searching with different keywords")
                .font(.subheadline)
                .foregroundColor(.appSubtitle)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }

    private var welcomeView: some View {
        VStack(spacing: 20) {
            VStack(spacing: 12) {
                Image(systemName: "book.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.appAccent)

                Text("Offline Japanese Dictionary")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.appText)

                Text("Search works completely offline with instant results")
                    .font(.body)
                    .foregroundColor(.appSubtitle)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 8) {
                Text("Database Statistics")
                    .font(.headline)
                    .foregroundColor(.appText)

                HStack(spacing: 20) {
                    VStack {
                        Text("\(databaseStats.totalWords)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appAccent)
                        Text("Total Words")
                            .font(.caption)
                            .foregroundColor(.appSubtitle)
                    }

                    VStack {
                        Text("\(databaseStats.commonWords)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appGreen)
                        Text("Common")
                            .font(.caption)
                            .foregroundColor(.appSubtitle)
                    }

                    VStack {
                        Text("\(databaseStats.jlptWords)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.appSecondaryAccent)
                        Text("JLPT")
                            .font(.caption)
                            .foregroundColor(.appSubtitle)
                    }
                }
            }
            .padding()
            .background(Color.appSurface)
            .cornerRadius(12)

            VStack(spacing: 8) {
                Text("Quick Actions")
                    .font(.headline)
                    .foregroundColor(.appText)

                LazyVGrid(
                    columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible()),
                    ], spacing: 12
                ) {
                    quickActionButton(title: "Common Words", icon: "star.fill") {
                        searchCommonWords()
                    }

                    quickActionButton(title: "JLPT N5", icon: "graduationcap.fill") {
                        searchJLPT("jlpt-n5")
                    }

                    quickActionButton(title: "JLPT N4", icon: "graduationcap") {
                        searchJLPT("jlpt-n4")
                    }

                    quickActionButton(title: "JLPT N3", icon: "book.fill") {
                        searchJLPT("jlpt-n3")
                    }
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func quickActionButton(title: String, icon: String, action: @escaping () -> Void)
        -> some View
    {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title3)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .foregroundColor(.appAccent)
            .padding()
            .background(Color.appSurface)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.appAccent, lineWidth: 1)
            )
        }
    }

    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(searchResults) { result in
                    NavigationLink(destination: OfflineWordDetailView(slug: result.slug)) {
                        OfflineWordEntryRowView(result: result)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
            .padding(.top, 16)
        }
    }

    private func debounceSearch(_ searchTerm: String) {
        searchWorkItem?.cancel()

        let workItem = DispatchWorkItem {
            if !searchTerm.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                performSearch()
            } else {
                searchResults = []
            }
        }

        searchWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + searchDebounceTime, execute: workItem)
    }

    private func performSearch() {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }

        isLoading = true
        errorMessage = nil

        Task {
            do {
                let results = try await databaseService.searchWords(query: searchText, limit: 50)
                await MainActor.run {
                    searchResults = results
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }

    private func searchCommonWords() {
        searchText = ""
        isLoading = true

        Task {
            do {
                let results = try await databaseService.getCommonWords(limit: 100)
                await MainActor.run {
                    searchResults = results
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }

    private func searchJLPT(_ level: String) {
        searchText = ""
        isLoading = true

        Task {
            do {
                let results = try await databaseService.searchWordsByJLPT(level: level, limit: 100)
                await MainActor.run {
                    searchResults = results
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                    errorMessage = error.localizedDescription
                    showingAlert = true
                }
            }
        }
    }

    private func loadDatabaseStats() async {
        do {
            let stats = try await databaseService.getDatabaseStats()
            await MainActor.run {
                databaseStats = stats
            }
        } catch {
            print("Failed to load database stats: \(error)")
        }
    }

    private func clearSearch() {
        searchText = ""
        searchResults = []
        searchWorkItem?.cancel()
    }
}
