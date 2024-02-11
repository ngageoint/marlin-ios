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

    var bookmark: BookmarkModel?

    init(itemKey: String? = nil, dataSource: String? = nil, notes: String? = nil) {
        self.itemKey = itemKey
        self.dataSource = dataSource
        self.notes = notes
        if let itemKey = itemKey, let dataSource = dataSource {
            self.bookmark = repository.getBookmark(itemKey: itemKey, dataSource: dataSource)
        }
//        self._bookmarks = FetchRequest(
//            entity: Bookmark.entity(),
//            sortDescriptors: Bookmark.defaultSort.map({ param in
//                param.toNSSortDescriptor()
//            }),
//            predicate: NSPredicate(format: "id == %@ AND dataSource == %@", itemKey ?? "", dataSource ?? "")
//        )
    }
    
    var body: some View {
        if let bookmark = bookmark {
            if let notes = bookmark.notes {
                Text("Bookmark Notes")
                    .primary()
                Text(notes)
                    .secondary()
            }
        }
    }
}
