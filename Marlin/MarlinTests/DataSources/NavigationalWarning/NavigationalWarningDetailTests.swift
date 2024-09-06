//
//  NavigationalWarningDetailTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/19/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

final class NavigationalWarningDetailTests: XCTestCase {

    func testLoading() {
        var newItem = NavigationalWarningModel(navArea: "P")

        newItem.cancelMsgNumber = 1
        newItem.authority = "authority"
        newItem.cancelDate = Date(timeIntervalSince1970: 0)
        newItem.cancelMsgYear = 2020
        newItem.cancelNavArea = "P"
        newItem.issueDate = Date(timeIntervalSince1970: 0)
        newItem.msgNumber = 2
        newItem.msgYear = 2019
        newItem.navArea = "P"
        newItem.status = "status"
        newItem.subregion = "subregion"
        newItem.text = "text of the warning"
        newItem.canBookmark = true

        let localDataSource = NavigationalWarningStaticLocalDataSource()
        let remoteDataSource = NavigationalWarningRemoteDataSource()
        InjectedValues[\.navWarningLocalDataSource] = localDataSource
        InjectedValues[\.navWarningRemoteDataSource] = remoteDataSource
        localDataSource.list.append(newItem)

        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        let bookmarkRepository = BookmarkRepository(localDataSource: bookmarkLocalDataSource)
        let routeWaypointRepository = RouteWaypointRepository(localDataSource: RouteWaypointStaticLocalDataSource())

        let detailView = NavigationalWarningDetailView(msgYear: newItem.msgYear!, msgNumber: newItem.msgNumber!, navArea: newItem.navArea)
            .environmentObject(bookmarkRepository)
            .environmentObject(routeWaypointRepository)

        let controller = UIHostingController(rootView: detailView)
        let window = TestHelpers.getKeyWindowVisible()
        window.rootViewController = controller
        tester().waitForView(withAccessibilityLabel: "HYDROPAC 2/2019 (subregion)")
        tester().waitForView(withAccessibilityLabel: newItem.dateString)
        
        tester().wait(forTimeInterval: 1)
        tester().waitForView(withAccessibilityLabel: "share")
        tester().tapView(withAccessibilityLabel: "share")

        
        tester().waitForTappableView(withAccessibilityLabel: "dismiss popup")
        tester().tapScreen(at: CGPoint(x:20, y:20))
        
        tester().waitForView(withAccessibilityLabel: "Authority")
        tester().waitForView(withAccessibilityLabel: newItem.authority)
        
        tester().waitForView(withAccessibilityLabel: "Cancel Date")
        tester().waitForView(withAccessibilityLabel: newItem.cancelDateString)
        
        tester().waitForView(withAccessibilityLabel: "Cancelled By")
        tester().waitForView(withAccessibilityLabel: "HYDROPAC \(newItem.cancelMsgNumber!)/\(newItem.cancelMsgYear!)")

        tester().waitForView(withAccessibilityLabel: "Text")
        let textView = viewTester().usingLabel("Text").view as! UITextView
        XCTAssertEqual(textView.text, newItem.text)
        
        BookmarkHelper().verifyBookmarkButton(repository: bookmarkRepository, bookmarkable: newItem)
    }
}
