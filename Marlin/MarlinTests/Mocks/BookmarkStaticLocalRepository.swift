//
//  BookmarkStaticLocalDataSource.swift
//  MarlinTests
//
//  Created by Daniel Barela on 2/10/24.
//

import Foundation
import Combine

@testable import Marlin

class BookmarkStaticLocalDataSource: BookmarkLocalDataSource {
    func bookmarks(
        filters: [Marlin.DataSourceFilterParameter]?,
        paginatedBy paginator: Marlin.Trigger.Signal?
    ) -> AnyPublisher<[Marlin.BookmarkItem], Error> {
        AnyPublisher(Just(bookmarks.values.map({ model in
            BookmarkItem.listItem(model)
        })).setFailureType(to: Error.self))
    }
    
    var bookmarks: [String: BookmarkModel] = [:]

    func createBookmark(notes: String?, itemKey: String, dataSource: String) async {
        let model = BookmarkModel(dataSource: dataSource, id: itemKey, itemKey: itemKey, notes: notes, timestamp: Date())
        bookmarks["\(dataSource)--\(itemKey)"] = model
        NSLog("Create: Bookmarks is \(bookmarks)")
    }
    
    func getBookmark(itemKey: String, dataSource: String) -> Marlin.BookmarkModel? {
        NSLog("Get: Bookmarks is \(bookmarks)")
        NSLog("get the bookmark for \(dataSource)--\(itemKey)")
        return bookmarks["\(dataSource)--\(itemKey)"]
    }

    func removeBookmark(itemKey: String, dataSource: String) -> Bool {
        NSLog("Remove: Bookmarks is \(bookmarks)")
        bookmarks["\(dataSource)--\(itemKey)"] = nil
        return true
    }
}
