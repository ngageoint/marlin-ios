//
//  BookmarkModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/19/23.
//

import Foundation
import CoreData

final class BookmarkModel: NSObject, Sendable {
    let dataSource: String?
    let id: String?
    let notes: String?
    let timestamp: Date?
    let itemKey: String?
    let uri: URL?

    func isEqualTo(_ other: BookmarkModel) -> Bool {
        guard let otherShape = other as? Self else { return false }
        return self.id == otherShape.id
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? BookmarkModel else {
            return false
        }
        return self.isEqualTo(object)
    }

    init(bookmark: Bookmark) {
        self.uri = bookmark.objectID.uriRepresentation()
        self.dataSource = bookmark.dataSource
        self.id = bookmark.id
        self.itemKey = bookmark.itemKey
        self.notes = bookmark.notes
        self.timestamp = bookmark.timestamp
    }

    init(dataSource: String?, id: String?, itemKey: String?, notes: String?, timestamp: Date?) {
        self.dataSource = dataSource
        self.id = id
        self.notes = notes
        self.timestamp = timestamp
        self.itemKey = itemKey
        self.uri = nil
    }
}
