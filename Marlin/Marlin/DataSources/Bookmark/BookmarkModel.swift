//
//  BookmarkModel.swift
//  Marlin
//
//  Created by Daniel Barela on 9/19/23.
//

import Foundation

class BookmarkModel: NSObject {
    var dataSource: String?
    var id: String?
    var notes: String?
    var timestamp: Date?
    
    func isEqualTo(_ other: BookmarkModel) -> Bool {
        guard let otherShape = other as? Self else { return false }
        return self.id == otherShape.id
    }
    
    static func == (lhs: BookmarkModel, rhs: BookmarkModel) -> Bool {
        lhs.isEqualTo(rhs)
    }
    
    init(bookmark: Bookmark) {
        self.dataSource = bookmark.dataSource
        self.id = bookmark.id
        self.notes = bookmark.notes
        self.timestamp = bookmark.timestamp
    }
}
