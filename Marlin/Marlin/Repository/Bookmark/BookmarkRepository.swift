//
//  BookmarkRepository.swift
//  Marlin
//
//  Created by Daniel Barela on 9/19/23.
//

import Foundation
import CoreData

class BookmarkRepositoryManager: BookmarkRepository, ObservableObject {
    private var repository: BookmarkRepository
    init(repository: BookmarkRepository) {
        self.repository = repository
    }
    
    func getBookmark(itemKey: String, dataSource: String) -> BookmarkModel? {
        repository.getBookmark(itemKey: itemKey, dataSource: dataSource)
    }
}

protocol BookmarkRepository {
    @discardableResult
    func getBookmark(itemKey: String, dataSource: String) -> BookmarkModel?
}

class BookmarkCoreDataRepository: BookmarkRepository, ObservableObject {
    private var context: NSManagedObjectContext
    
    required init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func getBookmark(itemKey: String, dataSource: String) -> BookmarkModel? {
        if let bookmark = try? context.fetchFirst(
            Bookmark.self,
            predicate: NSPredicate(format: "id == %@ AND dataSource == %@", itemKey, dataSource)) {
            return BookmarkModel(bookmark: bookmark)
        }
        return nil
    }
}
