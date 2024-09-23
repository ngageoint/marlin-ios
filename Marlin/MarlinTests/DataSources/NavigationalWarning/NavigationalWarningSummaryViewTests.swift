//
//  NavigationalWarningSummaryViewTests.swift
//  MarlinTests
//
//  Created by Daniel Barela on 1/19/23.
//

import XCTest
import Combine
import SwiftUI

@testable import Marlin

@MainActor
final class NavigationalWarningSummaryViewTests: XCTestCase {

    func testLoading() async throws {
        try XCTSkipIf(TestHelpers.DISABLE_UI_TESTS, "UI tests are disabled")
        var nw = NavigationalWarningModel(navArea: "P")

        nw.cancelMsgNumber = 1
        nw.authority = "authority"
        nw.cancelDate = Date(timeIntervalSince1970: 0)
        nw.cancelMsgYear = 2020
        nw.cancelNavArea = "P"
        nw.issueDate = Date(timeIntervalSince1970: 0)
        nw.msgNumber = 2
        nw.msgYear = 2019
        nw.navArea = "P"
        nw.status = "status"
        nw.subregion = "subregion"
        nw.text = "text of the warning"
        nw.canBookmark = true

        let localDataSource = NavigationalWarningStaticLocalDataSource()
        let remoteDataSource = NavigationalWarningRemoteDataSource()
        InjectedValues[\.navWarningLocalDataSource] = localDataSource
        InjectedValues[\.navWarningRemoteDataSource] = remoteDataSource
        localDataSource.list.append(nw)

        let bookmarkLocalDataSource = BookmarkStaticLocalDataSource()
        InjectedValues[\.bookmarkLocalDataSource] = bookmarkLocalDataSource
        let summary = await NavigationalWarningSummaryView(navigationalWarning: nw, showMoreDetails: false)
//            .setShowMoreDetails(false)
        
        var nw2 = NWModel(navArea: "P")

        nw2.cancelMsgNumber = 1
        nw2.authority = "authority"
        nw2.cancelDate = Date(timeIntervalSince1970: 0)
        nw2.cancelMsgYear = 2020
        nw2.cancelNavArea = "P"
        nw2.issueDate = Date(timeIntervalSince1970: 0)
        nw2.msgNumber = 2
        nw2.msgYear = 2019
        nw2.navArea = "P"
        nw2.status = "status"
        nw2.subregion = "subregion"
        nw2.text = "text of the warning"
        nw2.canBookmark = true
        
//        let summary2 = await TestView()
//            .setShowMoreDetails2(false)
//
//        let controller = UIHostingController(rootView: summary)
//        let window = TestHelpers.getKeyWindowVisible()
//        window.rootViewController = controller
//        tester().waitForView(withAccessibilityLabel: "HYDROPAC 2/2019 (subregion)")
//        tester().waitForView(withAccessibilityLabel: "text of the warning")
//        tester().waitForView(withAccessibilityLabel: nw.dateString)
//        
//        tester().wait(forTimeInterval: 1)
//        tester().waitForView(withAccessibilityLabel: "share")
//        tester().tapView(withAccessibilityLabel: "share")
//        
//        tester().waitForTappableView(withAccessibilityLabel: "dismiss popup")
//        tester().tapScreen(at: CGPoint(x:20, y:20))
//        
        try await BookmarkHelper().verifyBookmarkButton(bookmarkable: nw)

    }
}
