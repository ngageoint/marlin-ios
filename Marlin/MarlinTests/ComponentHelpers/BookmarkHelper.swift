//
//  BookmarkHelper.swift
//  MarlinTests
//
//  Created by Daniel Barela on 8/8/23.
//

import Foundation
import XCTest
import CoreData

@testable import Marlin

class BookmarkHelper: XCTestCase {
    public func verifyBookmarkButton(viewContext: NSManagedObjectContext, bookmarkable: Bookmarkable) {
        tester().tapView(withAccessibilityLabel: "bookmark")
        tester().waitForView(withAccessibilityLabel: "Bookmark")
        tester().waitForView(withAccessibilityLabel: "notes")
        tester().enterText("Bookmark notes", intoViewWithAccessibilityLabel: "notes")
        tester().tapView(withAccessibilityLabel: "Bookmark")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Bookmark")

        viewContext.performAndWait {
            let bookmark = viewContext.fetchFirst(Bookmark.self, key: "id", value: bookmarkable.itemKey ?? "")
            XCTAssertNotNil(bookmark)
            let foundItem = bookmark?.getDataSourceItem(context: viewContext)
            XCTAssertNotNil(foundItem)
            XCTAssertNotNil(foundItem?.bookmark)
            XCTAssertEqual(foundItem?.bookmark?.notes, "Bookmark notes")
        }
        tester().waitForView(withAccessibilityLabel: "remove bookmark \(bookmarkable.itemKey ?? "")")
        tester().tapView(withAccessibilityLabel: "remove bookmark \(bookmarkable.itemKey ?? "")")

        viewContext.performAndWait {
            let bookmark = viewContext.fetchFirst(Bookmark.self, key: "id", value: bookmarkable.itemKey ?? "")
            XCTAssertNil(bookmark)
        }
    }
}
