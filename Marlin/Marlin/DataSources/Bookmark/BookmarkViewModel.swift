//
//  BookmarkViewModel.swift
//  Marlin
//
//  Created by Daniel Barela on 7/27/23.
//

import Foundation

class BookmarkViewModel: ObservableObject {
    var itemKey: String?
    var dataSource: String?
    @Published var isBookmarked: Bool = false
    @Published var bookmark: BookmarkModel?
    
    var repository: (any BookmarkRepository)?
    
    @discardableResult
    func getBookmark(itemKey: String, dataSource: String) -> BookmarkModel? {
        self.itemKey = itemKey
        self.dataSource = dataSource
        bookmark = repository?.getBookmark(itemKey: itemKey, dataSource: dataSource)
        self.isBookmarked = bookmark != nil
        return bookmark
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
