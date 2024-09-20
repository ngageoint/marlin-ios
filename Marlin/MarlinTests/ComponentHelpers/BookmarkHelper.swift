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
    @Injected(\.bookmarkRepository)
    var repository: BookmarkRepository
    public func verifyBookmarkButton(viewContext: NSManagedObjectContext? = nil, bookmarkable: Bookmarkable) async throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        tester().tapView(withAccessibilityLabel: "bookmark")
        tester().waitForView(withAccessibilityLabel: "Bookmark")
        tester().waitForView(withAccessibilityLabel: "notes")
        tester().enterText("Bookmark notes", intoViewWithAccessibilityLabel: "notes")
        tester().tapView(withAccessibilityLabel: "Bookmark")
        tester().waitForAbsenceOfView(withAccessibilityLabel: "Bookmark")

        let bookmark = await repository.getBookmark(itemKey: bookmarkable.itemKey, dataSource: bookmarkable.key )
//        viewContext.performAndWait {
//            let bookmark = viewContext.fetchFirst(Bookmark.self, key: "id", value: bookmarkable.itemKey ?? "")
            XCTAssertNotNil(bookmark)
        let foundItem = await repository.getDataSourceItem(itemKey: bookmarkable.itemKey, dataSource: bookmarkable.key )
            XCTAssertNotNil(foundItem)
//            XCTAssertNotNil(foundItem?.bookmark)
//            XCTAssertEqual(foundItem?.bookmark?.notes, "Bookmark notes")
//        }
        tester().waitForView(withAccessibilityLabel: "remove bookmark \(bookmarkable.itemKey )")
        tester().tapView(withAccessibilityLabel: "remove bookmark \(bookmarkable.itemKey )")

//        viewContext.performAndWait {
        let removed = await repository.getBookmark(itemKey: bookmarkable.itemKey, dataSource: bookmarkable.key)
            XCTAssertNil(removed)
//        }
    }
}
