//
//  BookmarkNotes.swift
//  Marlin
//
//  Created by Daniel Barela on 8/3/23.
//

import SwiftUI

struct BookmarkNotes: View {
    var itemKey: String?
    var dataSource: String?
    var notes: String?
    
    @FetchRequest var bookmarks: FetchedResults<Bookmark>
    
    init(itemKey: String? = nil, dataSource: String? = nil, notes: String? = nil) {
        self.itemKey = itemKey
        self.dataSource = dataSource
        self.notes = notes
        self._bookmarks = FetchRequest(
            entity: Bookmark.entity(),
            sortDescriptors: Bookmark.defaultSort.map({ param in
                param.toNSSortDescriptor()
            }),
            predicate: NSPredicate(format: "id == %@ AND dataSource == %@", itemKey ?? "", dataSource ?? "")
        )
    }
    
    var body: some View {
        if let bookmark = bookmarks.first {
            if let notes = bookmark.notes {
                Text("Bookmark Notes")
                    .primary()
                Text(notes)
                    .secondary()
            }
        }
    }
}
