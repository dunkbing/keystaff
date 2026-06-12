//
//  CustomTabBar.swift
//  viqr
//
//  Created by Bùi Đặng Bình on 15/3/25.
//

import SwiftUI

public struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let items: [(icon: String, title: String)]

    public init(selectedTab: Binding<Int>, items: [(icon: String, title: String)]) {
        self._selectedTab = selectedTab
        self.items = items
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(0..<items.count, id: \.self) { index in
                VStack(spacing: 4) {
                    Image(systemName: items[index].icon)
                        .font(.system(size: 22))
                        .symbolVariant(selectedTab == index ? .fill : .none)

                    Text(LocalizedStringKey(items[index].title))
                        .font(.system(size: 10, weight: .semibold))
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .foregroundColor(selectedTab == index ? Color.appAccent : Color.appSubtitle)
                .background(
                    ZStack {
                        if selectedTab == index {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.appAccent.opacity(0.1))
                                .matchedGeometryEffect(id: "TAB", in: namespace)
                        }
                    }
                )
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedTab = index
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .background(Color.appSurface1)
        .cornerRadius(24)
        .padding(.horizontal)
        .shadow(color: Color.black.opacity(0.08), radius: 5, x: 0, y: 2)
    }

    @Namespace private var namespace
}
