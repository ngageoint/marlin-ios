//
//  BookmarkListEmptyState.swift
//  Marlin
//
//  Created by Daniel Barela on 8/4/23.
//

import SwiftUI

struct BookmarkListEmptyState: View {
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .center, spacing: 16) {
                Spacer()
                HStack(alignment: .center, spacing: 0) {
                    Spacer()
                    MultiImageContainerView(visibleImage: "bookmark", maskingImage: "bookmark.fill")
                        .frame(maxHeight: 300)
                        .padding([.trailing, .leading], 24)
                    Spacer()
                }
                Text("No Bookmarks")
                    .font(.headline5)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                    .opacity(0.94)
                Text("Bookmark an item and it will show up here.")
                    .font(.headline6)
                    .opacity(0.87)
                    .fixedSize(horizontal: false, vertical: true)
                    .multilineTextAlignment(.center)
                Spacer()
            }
            .padding(24)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.backgroundColor)
    }
}
