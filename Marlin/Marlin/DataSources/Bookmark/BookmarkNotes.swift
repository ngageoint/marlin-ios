//
//  BookmarkNotes.swift
//  Marlin
//
//  Created by Daniel Barela on 8/3/23.
//

import SwiftUI

struct BookmarkNotes: View {
    var notes: String?
    var body: some View {
        if let notes = notes {
            Text("Bookmark Notes")
                .primary()
            Text(notes)
                .secondary()
        }
    }
}

struct BookmarkNotes_Previews: PreviewProvider {
    static var previews: some View {
        BookmarkNotes()
    }
}
