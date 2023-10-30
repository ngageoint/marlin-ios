//
//  BookmarkListView.swift
//  Marlin
//
//  Created by Daniel Barela on 8/9/23.
//

import SwiftUI

struct BookmarkListView: View {
    @Binding var path: NavigationPath
    @ObservedObject var focusedItem: ItemWrapper = ItemWrapper()
    var watchFocusedItem: Bool = false
    
    var body: some View {
        MSIListView<Bookmark, EmptyView, EmptyView, BookmarkListEmptyState>(path: $path, focusedItem: focusedItem, watchFocusedItem: watchFocusedItem, sectionViewBuilder: { _ in EmptyView() }, content: { _ in EmptyView() }, emptyView: {
            BookmarkListEmptyState()
        })
    }
}
