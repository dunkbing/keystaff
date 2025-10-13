//
//  SearchView.swift
//  jisho
//
//  Created by Claude on 28/9/25.
//

import SwiftUI
import TikimUI

struct SearchView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var apiService = JishoAPIService.shared

    @State private var searchText = ""
    @State private var searchResults: [WordEntry] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var showingAlert = false

    private let searchDebounceTime: TimeInterval = 0.5
    @State private var searchWorkItem: DispatchWorkItem?

    var body: some View {
        VStack(spacing: 0) {
            searchHeader

            if isLoading {
                loadingView
            } else if searchResults.isEmpty && !searchText.isEmpty {
                emptyStateView
            } else {
                searchResultsList
            }
        }
        .background(Color.appBackground)
        .navigationTitle("Search")
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
        .padding(.top, 48)
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

    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(searchResults) { entry in
                    NavigationLink(destination: WordDetailView(wordEntry: entry)) {
                        WordEntryRowView(entry: entry)
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
                let response = try await apiService.searchWords(keyword: searchText)
                await MainActor.run {
                    searchResults = response.data
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

    private func clearSearch() {
        searchText = ""
        searchResults = []
        searchWorkItem?.cancel()
    }
}
