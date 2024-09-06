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
    
    @ObservedObject var bookmarkViewModel: BookmarkViewModel

    init(
        bookmarkViewModel: BookmarkViewModel? = nil,
        itemKey: String? = nil,
        dataSource: String? = nil,
        notes: String? = nil
    ) {
        self.bookmarkViewModel = bookmarkViewModel ?? BookmarkViewModel()
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
    }
}
