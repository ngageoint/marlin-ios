//
//  BookmarkViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 7/27/23.
//

import Foundation

class BookmarkViewModel: ObservableObject {
    var bookmarkable: (any Bookmarkable)? {
        didSet {
            bookmark = bookmarkable?.bookmark
        }
    }
    
    @Published var bookmark: Bookmark?
    
    func createBookmark(notes: String) {
        guard let bookmarkable = bookmarkable else {
            return
        }
        let viewContext = PersistenceController.current.viewContext
        viewContext.perform {
            let bookmark = Bookmark(context: viewContext)
            bookmark.notes = notes
            bookmark.dataSource = bookmarkable.key
            bookmark.id = bookmarkable.itemKey
            do {
                try viewContext.save()
            } catch {
                print("Error saving bookmark \(error)")
            }
            self.bookmark = bookmark
        }
    }
    
    func removeBookmark() {
        guard let bookmark = bookmark else {
            return
        }
        let viewContext = PersistenceController.current.viewContext
        viewContext.perform {
            viewContext.delete(bookmark)
            do {
                try viewContext.save()
                self.bookmark = nil
            } catch {
                print("Error removing bookmark")
            }
            
        }
    }
}
