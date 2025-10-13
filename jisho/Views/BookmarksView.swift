//
//  BookmarksView.swift
//  jisho
//
//  Created by Claude on 28/9/25.
//

import SwiftUI
import TikimUI

struct BookmarksView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.appSubtitle)

            Text("Bookmarks")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.appText)

            Text("Save your favorite words here")
                .font(.body)
                .foregroundColor(.appSubtitle)
                .multilineTextAlignment(.center)

            Text("Coming Soon")
                .font(.caption)
                .foregroundColor(.appAccent)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.appAccent.opacity(0.1))
                .cornerRadius(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.appBackground)
        .navigationTitle("Bookmarks")
    }
}
