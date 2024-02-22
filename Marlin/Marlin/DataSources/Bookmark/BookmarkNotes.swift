//
//  BookmarkNotes.swift
//  Marlin
//
//  Created by Daniel Barela on 8/3/23.
//

import SwiftUI

struct BookmarkNotes: View {
    @EnvironmentObject var repository: BookmarkRepositoryManager
    var itemKey: String?
    var dataSource: String?
    var notes: String?
    
//    @FetchRequest var bookmarks: FetchedResults<Bookmark>

    @ObservedObject var bookmarkViewModel: BookmarkViewModel

    init(bookmarkViewModel: BookmarkViewModel? = nil, itemKey: String? = nil, dataSource: String? = nil, notes: String? = nil) {
        // , itemKey: String? = nil, dataSource: String? = nil, notes: String? = nil) {
        self.bookmarkViewModel = bookmarkViewModel ?? BookmarkViewModel()
//        self.itemKey = itemKey
//        self.dataSource = dataSource
//        self.notes = notes
//        if let itemKey = itemKey, let dataSource = dataSource {
//            self.bookmark = repository.getBookmark(itemKey: itemKey, dataSource: dataSource)
//        }
//        self._bookmarks = FetchRequest(
//            entity: Bookmark.entity(),
//            sortDescriptors: Bookmark.defaultSort.map({ param in
//                param.toNSSortDescriptor()
//            }),
//            predicate: NSPredicate(format: "id == %@ AND dataSource == %@", itemKey ?? "", dataSource ?? "")
//        )
    }
    
    var body: some View {
        Group {
            if let bookmark = bookmarkViewModel.bookmark {
                if let notes = bookmark.notes {
                    Text("Bookmark Notes")
                        .primary()
                    Text(notes)
                        .secondary()
                }
            }
        }
//        .onAppear {
//            bookmarkViewModel.repository = repository
//            if let itemKey = itemKey, let dataSource = dataSource {
//                bookmarkViewModel.getBookmark(itemKey: itemKey, dataSource: dataSource)
//            }
//        }
//        .onChange(of: itemKey) { newValue in
//            if let itemKey = newValue, let dataSource = dataSource {
//                bookmarkViewModel.getBookmark(itemKey: itemKey, dataSource: dataSource)
//            }
//        }
//        .onChange(of: dataSource) { newValue in
//            if let itemKey = newValue, let dataSource = newValue {
//                bookmarkViewModel.getBookmark(itemKey: itemKey, dataSource: dataSource)
//            }
//        }
    }
}
