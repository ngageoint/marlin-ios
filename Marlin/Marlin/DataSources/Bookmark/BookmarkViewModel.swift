//
//  BookmarkViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 7/27/23.
//

import Foundation

class BookmarkViewModel: ObservableObject {
//    var bookmarkable: (any Bookmarkable)? {
//        didSet {
//            isBookmarked = true
////            bookmark = bookmarkable?.bookmark
//        }
//    }
    
    var itemKey: String?
    var dataSource: String?
    @Published var isBookmarked: Bool = false
    
    func setViewModel(itemKey: String, dataSource: String) {
        print("set view model")
        self.itemKey = itemKey
        self.dataSource = dataSource
        let viewContext = PersistenceController.current.viewContext
        viewContext.perform {
            let request = Bookmark.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@ AND dataSource = %@", itemKey, dataSource)
            
            let bookmarks = viewContext.fetch(request: request) ?? []
            print("setting is bookmarked to \(!bookmarks.isEmpty)")
            self.isBookmarked = !bookmarks.isEmpty
        }
    }
    
    func createBookmark(notes: String) {
        let viewContext = PersistenceController.current.viewContext
        viewContext.perform {
            let bookmark = Bookmark(context: viewContext)
            bookmark.notes = notes
            bookmark.dataSource = self.dataSource
            bookmark.id = self.itemKey
            bookmark.timestamp = Date()
            do {
                try viewContext.save()
            } catch {
                print("Error saving bookmark \(error)")
            }
            self.itemKey = self.itemKey
            self.dataSource = self.dataSource
            self.isBookmarked = true
        }
    }
    
    func removeBookmark() {
        guard let itemKey = itemKey, let dataSource = dataSource else {
            return
        }
        let viewContext = PersistenceController.current.viewContext
        viewContext.perform {
            let request = Bookmark.fetchRequest()
            request.predicate = NSPredicate(format: "id = %@ AND dataSource = %@", itemKey, dataSource)
            for bookmark in viewContext.fetch(request: request) ?? [] {
                viewContext.delete(bookmark)
            }
            do {
                try viewContext.save()
                self.isBookmarked = false
            } catch {
                print("Error removing bookmark")
            }
            
        }
    }
}
