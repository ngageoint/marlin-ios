//
//  BookmarkListView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/9/23.
//

import SwiftUI

struct BookmarkListView: View {
    @ObservedObject var focusedItem: ItemWrapper = ItemWrapper()
    var watchFocusedItem: Bool = false
    
    var body: some View {
        MSIListView<Bookmark, EmptyView, EmptyView, BookmarkListEmptyState>(
            focusedItem: focusedItem,
            watchFocusedItem: watchFocusedItem,
            sectionViewBuilder: { _ in EmptyView() }, content: { _ in EmptyView() },
            emptyView: {
                BookmarkListEmptyState()
            }
        )
    }
}
